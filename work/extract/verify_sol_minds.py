#!/usr/bin/env python3
"""Э4.3 acceptance: what Solbrain's objects do once they are in a slot.

Э4.2 asked only who is in each of the sixteen slots.  This one asks the rest:
where the thing has got to, what it is thinking, which of its family it is and
which picture it is wearing -- every slot, every picture, against the cartridge.

The hero is walked about in a stage, the cartridge is watched, and the engine
is stood in the same place with the same buttons.  A run either matches on all
seven numbers in all sixteen slots on all of its pictures, or it is a failure
and the first picture that parts company is printed.

Behaviours that have not been read out of the cartridge yet are not guessed at:
the engine counts them and says so on the error channel, so a failure can be
told apart from a gap.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import sol_probe as P                                            # noqa: E402
import verify_sol_player as V                                    # noqa: E402
import verify_sol_spawns as S                                    # noqa: E402

SLOTS = S.SLOTS
NAMES = ('id', 'x', 'y', 'mind', 'kind', 'pic lo', 'pic hi')

# Every stage, not just the six Э4.2 picked: what a thing does is its own
# business, and each stage keeps a different set of things.
PLACES = [('s%d' % n, n) for n in range(20)]


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    scratch = P.scratch('minds')
    try:
        bad = total = 0
        owed = {}
        for label, stage in PLACES:
            if places and label not in places:
                continue
            first = V.BASE if stage == 0 else P.WARP_IN
            play = first + 1
            state = V.stand(scratch, label, stage, None)
            cfg0 = S.seed(P.ram(state, [(first, '-')], first))
            for name, pads in sorted(S.SCRIPTS.items()):
                if only and name not in only:
                    continue
                total += 1
                want, ticks = S.cartridge(state, pads, play, full=True)
                cfg = dict(cfg0)
                cfg['pads'] = pads
                cfg['clock_at'] = [t[0] for t in ticks]
                cfg['noise_at'] = [t[1] for t in ticks]
                cfg['six_at'] = [t[2] for t in ticks]
                cfg['step_at'] = [t[3] for t in ticks]
                cfg['ride_at'] = [t[4] for t in ticks]
                cfg['new_at'] = [t[5] for t in ticks]
                got, missing = engine(cfg, scratch)
                for k, v in missing.items():
                    owed[k] = owed.get(k, 0) + v
                n = min(len(want), len(got))
                done = S.finished(ticks, n)
                where = None
                for i in range(n):
                    if done[i] and want[i] != got[i]:
                        where = i
                        break
                if where is None and len(want) != len(got):
                    where = n
                if where is None:
                    print('%-6s %-15s ok, %d frames' % (label, name, n))
                    continue
                bad += 1
                print('%-6s %-15s differs on frame %d' % (label, name, where))
                if where < n:
                    for s in range(SLOTS):
                        if want[where][s] == got[where][s]:
                            continue
                        for k, nm in enumerate(NAMES):
                            if want[where][s][k] != got[where][s][k]:
                                print('    slot %2d %-6s cartridge %6d'
                                      '   engine %6d'
                                      % (s, nm, want[where][s][k],
                                         got[where][s][k]))
                else:
                    print('    cartridge %d frames, engine %d'
                          % (len(want), len(got)))
                sys.stdout.flush()
        print('%d of %d scripts differ' % (bad, total))
        if owed:
            print('behaviours not read yet: %s'
                  % ', '.join('%s x%d' % (k, v) for k, v in sorted(owed.items())))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


def engine(cfg, scratch):
    path = os.path.join(scratch, 'obj.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([S.GODOT, '--path', S.GAME, '--headless', '--',
                        '--solobj=%s' % path],
                       capture_output=True, text=True, timeout=600)
    rows = []
    for line in r.stdout.split('\n'):
        f = line.split()
        if len(f) != SLOTS or not all(t.count(',') == 6 for t in f):
            continue
        rows.append(tuple(tuple(int(v) for v in t.split(',')) for t in f))
    missing = {}
    for line in r.stderr.split('\n'):
        if line.startswith('minds not read yet: '):
            try:
                body = line.split(': ', 1)[1].replace('"', '')
                for part in body.strip('{}').split(','):
                    k, _, v = part.partition(':')
                    missing[k.strip()] = missing.get(k.strip(), 0) + int(v)
            except (IndexError, ValueError):
                pass
    if not rows:
        sys.stderr.write(r.stdout[-2000:] + r.stderr[-2000:])
    return rows, missing


if __name__ == '__main__':
    sys.exit(main())
