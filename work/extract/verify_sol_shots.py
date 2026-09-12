#!/usr/bin/env python3
"""Э4.3 acceptance: the sixteen shots.

Besides the sixteen slots for things, Solbrain keeps sixteen more at $0780 for
everything that has been thrown: an enemy's bullet, a splash, a spark, the puff
a thing leaves when it is finished off.  They are walked once a picture by
$B2E9 in bank 3, before the things themselves are walked at all.

The hero is stood in a stage and walked about with the same scripts Э4.2 uses;
the cartridge is watched and the engine is stood in the same place.  A run must
match on all six numbers -- behaviour, place, the two steps and what is left of
its life -- in all sixteen shot slots on all of its pictures.

Behaviours not read out of the cartridge yet are counted, not guessed at, so a
gap can be told apart from a wrong answer.
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

SHOTS = S.SHOTS
NAMES = ('kind', 'x', 'y', 'a', 'b', 'life')
PAGES = (0x0780, 0x0790, 0x07A0, 0x07B0, 0x07C0, 0x07D0, 0x07E0, 0x07F0)

PLACES = [('s%d' % n, n) for n in range(20)]


def cartridge(state, pads, base):
    """The cartridge's own $0780 page, picture by picture."""
    script = V.cartridge_script(pads, base)
    addrs = set(S.TICKS)
    for p in PAGES:
        addrs |= {p + i for i in range(SHOTS)}
    rows = P.watched(state, script, base, base + len(pads), addrs)
    out = []
    ticks = []
    for _fr, c in rows[:-1]:
        ticks.append((c[0x0C], c[0x0E], c[0x06], c[0x7F], c[0x58]))
        out.append(tuple(
            (c[0x0780 + i],
             c[0x0790 + i] | c[0x07A0 + i] << 8,
             c[0x07B0 + i] | c[0x07C0 + i] << 8,
             c[0x07D0 + i], c[0x07E0 + i], c[0x07F0 + i])
            for i in range(SHOTS)))
    return out, ticks


def engine(cfg, scratch):
    path = os.path.join(scratch, 'obj.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([S.GODOT, '--path', S.GAME, '--headless', '--',
                        '--solobj=%s' % path],
                       capture_output=True, text=True, timeout=600)
    rows = []
    for line in r.stdout.split('\n'):
        if not line.startswith('S '):
            continue
        f = line[2:].split()
        if len(f) != SHOTS or not all(t.count(',') == 5 for t in f):
            continue
        rows.append(tuple(tuple(int(v) for v in t.split(',')) for t in f))
    missing = {}
    for line in r.stderr.split('\n'):
        if line.startswith('shots not read yet: '):
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


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    scratch = P.scratch('shots')
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
                want, ticks = cartridge(state, pads, play)
                cfg = dict(cfg0)
                cfg['pads'] = pads
                cfg['clock_at'] = [t[0] for t in ticks]
                cfg['noise_at'] = [t[1] for t in ticks]
                cfg['six_at'] = [t[2] for t in ticks]
                cfg['step_at'] = [t[3] for t in ticks]
                cfg['ride_at'] = [t[4] for t in ticks]
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
                    for s in range(SHOTS):
                        if want[where][s] == got[where][s]:
                            continue
                        for k, nm in enumerate(NAMES):
                            if want[where][s][k] != got[where][s][k]:
                                print('    shot %2d %-5s cartridge %6d'
                                      '   engine %6d'
                                      % (s, nm, want[where][s][k],
                                         got[where][s][k]))
                else:
                    print('    cartridge %d frames, engine %d'
                          % (len(want), len(got)))
                sys.stdout.flush()
        print('%d of %d scripts differ' % (bad, total))
        if owed:
            print('shot behaviours not read yet: %s'
                  % ', '.join('%s x%d' % (k, v) for k, v in sorted(owed.items())))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
