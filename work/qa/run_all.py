#!/usr/bin/env python3
"""PB3 one-command regression.

Runs every Godot-only check of the tree: the replay of all accepted
input-only playthroughs (docs/qa/playthrough/cases.json) and every
game/tests/*_test.gd unit/fixture suite that needs no NES oracle data.
Optionally (--smoke) the smoke explorer on a short budget.

A check fails on a non-zero exit code, a timeout, or any "SCRIPT ERROR" /
"SHADER ERROR" / "Parse Error" in the Godot output.  The full output of each
check goes to a scratch file under $TMPDIR/pb3-qa (deleted on success);
only a one-line verdict per check is printed.

    python3 work/qa/run_all.py              # everything (2 Godot at a time)
    python3 work/qa/run_all.py --only=replay,combat
    python3 work/qa/run_all.py --list
    python3 work/qa/run_all.py --smoke      # + quick explorer pass
    python3 work/qa/run_all.py --oracle     # + NES-emulator stands (slow)

Exit code: 0 only when every selected check passed.
NES-oracle stands (work/extract/verify_all.py) are not run here: they need
the emulator and take far longer; run them separately when touching
native algorithms.
"""
import concurrent.futures
import os
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile
import time

ROOT = pathlib.Path(__file__).resolve().parents[2]
GAME = ROOT / 'game'
GODOT = os.environ.get('GODOT', '/Applications/Godot_mono.app/Contents/MacOS/Godot')
SCRATCH = pathlib.Path(os.environ.get('TMPDIR', '/tmp')) / 'pb3-qa'

# Suites that need oracle input produced by the NES emulator (they read
# OS.get_cmdline_user_args()[0] and hang without it).  `--oracle` runs them
# through their work/extract/verify_*.py stands, which build that input.
ORACLE = {
    'pb2_death_test': 'verify_pb2_death.py',
    'pb2_small_shots_test': 'verify_pb2_small_shots.py',
    'sol_pickups_test': 'verify_sol_pickups.py',
    'pb2_hand_4a_test': 'verify_pb2_hand_4a.py',
    'pb2_nest_1c_test': 'verify_pb2_nest_1c.py',
    'pb2_nest_child_1c_test': 'verify_pb2_nest_child_1c.py',
    'pb2_pod_33_test': 'verify_pb2_pod_33.py',
    'pb2_raster_kind4_test': 'verify_pb2_raster_kind4.py',
    'pb3_environment_test': 'verify_pb3_environment.py',
}
# Native Nova movement against the cartridge, frame by frame.
ORACLE_EXTRA = [('oracle:player', ['verify_player.py', '--areas=0:0', '--random=2', '--seed=59'])]
# Not a check: writes screenshots into docs/qa/.
NOT_CHECKS = {'pb3_visual_test'}
# Need a real GPU framebuffer: run with a window instead of --headless.
WINDOWED = {'pb3_display_test', 'pb3_geometry_test'}
# Generous per-check timeouts (seconds); default below.
TIMEOUT = {'pb3_playthrough_test': 1200, 'pb3_traversal_test': 900,
           'pb3_display_test': 600, 'pb3_session_test': 600}
DEFAULT_TIMEOUT = 420
BAD = re.compile(r'SCRIPT ERROR|SHADER ERROR|Parse Error|Failed to load script')
# Lines worth echoing on failure.
NOTE = re.compile(r'FAIL|ERROR|failed|differ|Error', re.I)


def checks(oracle=False):
    out = []
    if oracle:
        for test, stand in sorted(ORACLE.items()):
            out.append(('oracle:' + test.removesuffix('_test'),
                        [sys.executable, str(ROOT / 'work/extract' / stand)], 1800))
        for name, cmd in ORACLE_EXTRA:
            out.append((name, [sys.executable, str(ROOT / 'work/extract' / cmd[0])] + cmd[1:], 1800))
    for path in sorted((GAME / 'tests').glob('*_test.gd')):
        name = path.stem
        if name in ORACLE or name in NOT_CHECKS:
            continue
        short = 'replay' if name == 'pb3_playthrough_test' else name.removesuffix('_test')
        args = [GODOT] + ([] if name in WINDOWED else ['--headless'])
        args += ['--path', str(GAME), '--script', 'res://tests/%s.gd' % name]
        out.append((short, args, TIMEOUT.get(name, DEFAULT_TIMEOUT)))
    return out


def run(check):
    name, args, timeout = check
    SCRATCH.mkdir(parents=True, exist_ok=True)
    log = SCRATCH / ('%s.log' % name)
    start = time.time()
    with open(log, 'w') as f:
        try:
            code = subprocess.run(args, stdout=f, stderr=subprocess.STDOUT,
                                  stdin=subprocess.DEVNULL, timeout=timeout).returncode
        except subprocess.TimeoutExpired:
            code = 'timeout'
    took = time.time() - start
    text = log.read_text(errors='replace')
    errors = len(BAD.findall(text))
    ok = code == 0 and errors == 0
    lines = [l for l in text.splitlines() if l.strip() and not l.startswith('Godot Engine')
             and not l.startswith('OpenGL API')]
    if ok:
        log.unlink()
        detail = lines[-1][:70] if lines else ''
    else:
        noted = [l for l in lines if NOTE.search(l)][:3] or lines[-2:]
        detail = ' | '.join(l.strip()[:90] for l in noted)
    return name, ok, code, errors, took, detail, str(log)


def main(argv):
    every = checks('--oracle' in argv)
    if '--list' in argv:
        for name, args, _ in every:
            print(name)
        return 0
    only = next((a.split('=', 1)[1].split(',') for a in argv if a.startswith('--only=')), None)
    if only:
        every = [c for c in every if c[0] in only]
    jobs = int(next((a.split('=', 1)[1] for a in argv if a.startswith('--jobs=')), 2))
    if '--smoke' in argv:
        every.append(('smoke', [sys.executable, str(ROOT / 'work/qa/smoke.py'),
                                '--ticks=1500', '--quiet'], 1800))
    if shutil.disk_usage('/').free < 12 * 2**30:
        print('less than 12 GB free on /, refusing to start Godot')
        return 2
    start = time.time()
    results = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as pool:
        for r in pool.map(run, every):
            results.append(r)
    failed = [r for r in results if not r[1]]
    passed = ['%s(%.0fs)' % (r[0], r[4]) for r in results if r[1]]
    line = 'ok:'
    for item in passed:
        if len(line) + len(item) > 100:
            print(line)
            line = '   '
        line += ' ' + item
    print(line)
    for name, ok, code, errors, took, detail, log in failed:
        print('FAIL %s exit=%s script_errors=%d (%.0fs) log=%s' % (name, code, errors, took, log))
        print('     ' + detail[:200])
    print('%d of %d checks failed (%.0fs)' % (len(failed), len(results), time.time() - start))
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
