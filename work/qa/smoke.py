#!/usr/bin/env python3
"""QAI smoke explorer driver: every level x team from its normal entry.

Plays game/tests/smoke_explore.gd (seeded heuristic pad input only) in at
most two Godot processes, survives crashes/hangs (the run in flight is
reported as `crash`/`hang` and the shard resumes after it), and writes:

    <out>/smoke.json    every run with its anomalies
    <out>/smoke.md      short report: anomalies grouped by kind, with repro
    <out>/replays/      playthrough.gd-format replays of runs with anomalies

    python3 work/qa/smoke.py                       # all 83 levels x nova,sol,coop
    python3 work/qa/smoke.py --levels=p0.0,s3.0 --teams=sol --ticks=6000
    python3 work/qa/smoke.py --seed=7 --out=/tmp/smoke7
    python3 work/qa/smoke.py --repro=s3.0:sol:SEED_BASE --ticks=N   # one run, trace around --trace=TICK

Exit code 0 when no anomaly was found, 1 otherwise.
Defaults: --ticks=4000 --seed=1 --jobs=2 --out=$TMPDIR/pb3-smoke.
"""
import json
import os
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile
import threading
import time

ROOT = pathlib.Path(__file__).resolve().parents[2]
GAME = ROOT / 'game'
GODOT = os.environ.get('GODOT', '/Applications/Godot_mono.app/Contents/MacOS/Godot')
PB2_AREAS = [7, 8, 7, 7, 10, 14, 10]


def levels():
    out = []
    for st, n in enumerate(PB2_AREAS):
        for ar in range(n):
            out.append('p%d.%d' % (st, ar))
    for st in range(20):
        out.append('s%d.0' % st)
    return out


def arg(argv, name, default):
    for a in argv:
        if a.startswith('--%s=' % name):
            return a.split('=', 1)[1]
    return default


def run_shard(jobs, ticks, seed, out_jsonl, replays, per_run_timeout, results, lock):
    """Run jobs in one Godot; restart after the last finished run on crash."""
    pending = list(jobs)
    while pending:
        if os.path.exists(out_jsonl):
            os.unlink(out_jsonl)
        args = [GODOT, '--headless', '--path', str(GAME), '--script',
                'res://tests/smoke_explore.gd', '--',
                '--jobs=' + ','.join('%d:%s' % j for j in pending),
                '--ticks=%d' % ticks, '--seed=%d' % seed,
                '--out=' + out_jsonl, '--replays=' + replays]
        timeout = per_run_timeout * len(pending) + 30
        tail = []
        try:
            p = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                               stdin=subprocess.DEVNULL, timeout=timeout, text=True,
                               errors='replace')
            code = p.returncode
            text = p.stdout
        except subprocess.TimeoutExpired as e:
            code = 'hang'
            text = (e.stdout or b'').decode(errors='replace') if isinstance(e.stdout, bytes) else (e.stdout or '')
        done = []
        if os.path.exists(out_jsonl):
            for line in open(out_jsonl):
                line = line.strip()
                if line:
                    done.append(json.loads(line))
        with lock:
            results.extend(done)
        pending = pending[len(done):]
        if pending:
            # The run in flight died with the process.
            entry, team = pending[0]
            tail = [l for l in text.splitlines() if 'ERROR' in l or 'error' in l][-3:]
            with lock:
                results.append({'entry': entry, 'level': levels()[entry], 'team': team,
                                'seed': None, 'base_seed': seed, 'ticks': None,
                                'outcome': 'crash' if code != 'hang' else 'hang',
                                'events': [], 'span': [],
                                'anomalies': [{'kind': 'crash' if code != 'hang' else 'hang',
                                               'tick': None, 'player': -1,
                                               'detail': 'exit=%s %s' % (code, ' | '.join(tail))[:300]}]})
            pending = pending[1:]
    if os.path.exists(out_jsonl):
        os.unlink(out_jsonl)


def report(results, out, ticks, seed, took):
    results.sort(key=lambda r: (r['entry'], r['team']))
    (out / 'smoke.json').write_text(json.dumps({'ticks': ticks, 'seed': seed, 'runs': results}, indent=1))
    kinds = {}
    for r in results:
        for a in r['anomalies']:
            kinds.setdefault(a['kind'], []).append((r, a))
    outcomes = {}
    for r in results:
        o = r['outcome'] if r['outcome'] in ('died', 'timeout', 'crash', 'hang') else 'cleared/other'
        outcomes[o] = outcomes.get(o, 0) + 1
    advanced = sum(1 for r in results if any(':changed:' in e for e in r['events']))
    lines = ['# PB3 smoke explorer', '',
             'seed %d, %d input frames per run, %d runs, %.0f s. Outcomes: %s; '
             'reached another room: %d.' % (seed, ticks, len(results), took,
                                             ', '.join('%s %d' % kv for kv in sorted(outcomes.items())), advanced),
             '']
    if not kinds:
        lines.append('No anomalies.')
    for kind, items in sorted(kinds.items()):
        lines.append('## %s (%d)' % (kind, len(items)))
        lines.append('')
        seen = {}
        for r, a in items:
            key = (kind, r['level'], a['detail'] if kind in ('missing_handler', 'script_error', 'engine_error') else r['team'])
            if key in seen:
                seen[key] += 1
                continue
            seen[key] = 1
            at = ' at %s' % a['at'] if a.get('at') else ''
            lines.append('- %s %s p%s tick %s%s: %s  \n  repro: `python3 work/qa/smoke.py --repro=%s:%s:%s --ticks=%s --trace=%s`'
                         % (r['level'], r['team'], a['player'], a['tick'], at, a['detail'],
                            r['level'], r['team'], r['base_seed'], ticks, a['tick']))
        lines.append('')
    (out / 'smoke.md').write_text('\n'.join(lines))
    return kinds, outcomes, advanced


def main(argv):
    ticks = int(arg(argv, 'ticks', 4000))
    seed = int(arg(argv, 'seed', 1))
    jobs_n = int(arg(argv, 'jobs', 2))
    out = pathlib.Path(arg(argv, 'out', os.path.join(os.environ.get('TMPDIR', '/tmp'), 'pb3-smoke')))
    quiet = '--quiet' in argv
    all_levels = levels()
    repro = arg(argv, 'repro', None)
    if repro:
        level, team, base = repro.split(':')
        trace = arg(argv, 'trace', None)
        cmd = [GODOT, '--headless', '--path', str(GAME), '--script', 'res://tests/smoke_explore.gd', '--',
               '--jobs=%d:%s' % (all_levels.index(level), team), '--ticks=%d' % ticks,
               '--seed=%s' % base, '--replays=' + str(out)]
        out.mkdir(parents=True, exist_ok=True)
        if trace:
            cmd.append('--trace=' + trace)
        p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, stdin=subprocess.DEVNULL)
        for line in p.stdout.splitlines():
            if line.startswith(('TRACE', '{', 'SCRIPT ERROR', 'ERROR', '   at:')):
                print(line[:400])
        return p.returncode
    wanted = arg(argv, 'levels', None)
    chosen = [all_levels.index(l) for l in wanted.split(',')] if wanted else list(range(len(all_levels)))
    teams = arg(argv, 'teams', 'nova,sol,coop').split(',')
    if shutil.disk_usage('/').free < 12 * 2**30:
        print('less than 12 GB free on /, refusing to start Godot')
        return 2
    if out.exists():
        shutil.rmtree(out)
    (out / 'replays').mkdir(parents=True)
    jobs = [(e, t) for e in chosen for t in teams]
    # Interleave so each shard gets a mix of short and long levels.
    shards = [jobs[i::jobs_n] for i in range(jobs_n)]
    results, lock = [], threading.Lock()
    per_run_timeout = max(60, ticks // 40)
    start = time.time()
    threads = [threading.Thread(target=run_shard, args=(s, ticks, seed, str(out / ('shard%d.jsonl' % i)),
                                                        str(out / 'replays'), per_run_timeout, results, lock))
               for i, s in enumerate(shards) if s]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    kinds, outcomes, advanced = report(results, out, ticks, seed, time.time() - start)
    total = sum(len(v) for v in kinds.values())
    print('smoke: %d runs, %d anomalies (%s); outcomes %s; %.0fs' % (
        len(results), total, ', '.join('%s %d' % (k, len(v)) for k, v in sorted(kinds.items())) or 'none',
        ', '.join('%s %d' % kv for kv in sorted(outcomes.items())), time.time() - start))
    if not quiet:
        print('report: %s' % (out / 'smoke.md'))
    return 1 if total else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
