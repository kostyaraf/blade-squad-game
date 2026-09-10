#!/usr/bin/env python3
"""Э3.8 acceptance, part one: every stand of Э1..Э3 run in a row.

Each of the earlier stages was accepted on its own stand and on its own day.
This runs all of them again, one after another, out of the state the tree is
in now, and puts the numbers side by side.  A stage is accepted for good only
when its stand still says nought here.

The stands share one scratch and one emulator, so they are run one at a time,
never two at once.  The whole of what each puts out is kept under
`work/tmp/accept/` -- the verdict line alone is printed.

Run with no arguments it runs them all.  `--only=hud,flow` runs the named few;
`--list` only says what there is.
"""
import os
import re
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
LOGS = os.path.join(ROOT, 'work', 'tmp', 'accept')

# name, stage it belongs to, script, arguments.
STANDS = [
    ('engine',     'Э1',   'verify_engine.py',     []),
    ('pb2',        'Э1',   'verify_pb2.py',        []),
    ('sprites',    'Э2',   'verify_sprites.py',    []),
    ('oam',        'Э2',   'verify_oam.py',        []),
    ('player',     'Э2',   'verify_player.py',     ['--all-areas', '--random=14', '--seed=101']),
    ('flow',       'Э3.1', 'verify_flow.py',       []),
    ('spawns',     'Э3.2', 'verify_spawns.py',     ['--random=3']),
    ('weapons',    'Э3.3', 'verify_weapons.py',    ['--all-areas', '--random=3']),
    ('water',      'Э3.2', 'verify_water.py',      []),
    ('hud',        'Э3.7', 'verify_hud.py',        ['--all-areas']),
    ('hudscreen',  'Э3.7', 'verify_hud_screen.py', ['--all-areas']),
    ('run',        'Э3.8', 'verify_run.py',        []),
]

# Every stand ends on a line that counts what differs.  Two shapes are in use:
# "N of M <things> differ" and, where what is counted is pixels of a picture,
# "worst frame: N pixels".
COUNT = re.compile(r'^(\d+) of (\d+) ([^,;]+?) differ')
WORST = re.compile(r'^worst frame: (\d+) pixels')
NOTHING = re.compile(r'^0 of 0 ')


def verdict(text):
    """The last line of a stand that says how much differed, and how much.

    Returns (bad, line) -- bad is None when the stand said nothing that can be
    read as a verdict, which is itself a failure.
    """
    bad = None
    line = ''
    for row in text.splitlines():
        m = COUNT.match(row)
        if m:
            bad, line = int(m.group(1)), row.strip()
            continue
        m = WORST.match(row)
        if m:
            bad, line = int(m.group(1)), row.strip()
    return bad, line


def run(name, script, args):
    os.makedirs(LOGS, exist_ok=True)
    path = os.path.join(LOGS, name + '.txt')
    began = time.time()
    r = subprocess.run([sys.executable, '-u', os.path.join(HERE, script)]
                       + args, capture_output=True, text=True, cwd=ROOT)
    text = r.stdout + r.stderr
    with open(path, 'w') as f:
        f.write(text)
    took = time.time() - began
    if r.returncode != 0:
        return None, 'exit %d -- see %s' % (r.returncode, path), took
    bad, line = verdict(text)
    # "0 of 0 differ" is not a pass: the stand was given no work to do.
    if bad == 0 and NOTHING.match(line):
        return None, 'nothing was run -- %s' % line, took
    return bad, line, took


def main():
    picked = [s[0] for s in STANDS]
    for a in sys.argv[1:]:
        if a == '--list':
            for name, stage, script, args in STANDS:
                print('%-10s %-5s %s %s' % (name, stage, script, ' '.join(args)))
            return 0
        if a.startswith('--only='):
            picked = a.split('=')[1].split(',')
    ran = bad = 0
    for name, stage, script, args in STANDS:
        if name not in picked:
            continue
        n, line, took = run(name, script, args)
        ran += 1
        if n is None:
            bad += 1
            print('%-10s %-5s FAILED  %s' % (name, stage, line))
        else:
            if n:
                bad += 1
            print('%-10s %-5s %-7s %-52s %5.0f s'
                  % (name, stage, 'ok' if n == 0 else 'DIFFERS', line, took))
        sys.stdout.flush()
    print('%d of %d stands differ' % (bad, ran))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
