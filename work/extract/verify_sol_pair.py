#!/usr/bin/env python3
"""Э4.21 acceptance: the turns of mind $1B, and the pair they let go.

`verify_sol_behaviours.py --kinds=0x1B` already sweeps the thirty three turns
of $A53D, but it only ever looks at the object pool.  Two of those turns --
$14 at $A5B2 and $16 at $A598 -- do not touch the pool at all: they ask bank
six for entry $79, and bank six puts two shots of behaviour $86 into the other
pool, standing exactly where the thing does.

So this stand is the same sweep watched from the other side: every turn is
written into a slot by hand, and both pools -- all sixteen object slots and all
sixteen shot slots -- must answer the same numbers on every picture the turn
lasts.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import sol_probe as P                                            # noqa: E402
import verify_sol_player as V                                    # noqa: E402
import verify_sol_spawns as S                                    # noqa: E402
import verify_sol_minds as M                                     # noqa: E402
import verify_sol_shots as H                                     # noqa: E402
import verify_sol_shotkinds as K                                 # noqa: E402
import verify_sol_behaviours as B                                # noqa: E402

SLOTS = S.SLOTS
SHOTS = S.SHOTS
MIND = 0x1B               # $A53D, the long one
TURNS = 0x21              # as many turns as its table at $A548 has rows
# The two turns that ask for the pair only do so when their walk runs out, and
# the walk of turn $16 is $C0 pictures long, so the run has to be long enough
# to reach it -- the sweeps that stop at a hundred never see entry $79 at all.
LEN = 340
TAIL = 60


def spot(rows, ticks):
    """B.spot, but with this stand's own room left at the end."""
    done = S.finished(ticks, len(rows))
    for k in range(1, max(1, len(rows) - TAIL)):
        if not done[k - 1]:
            continue
        for s in range(SLOTS):
            if rows[k - 1][s][0] != 0:
                return k, s
    return None


def main():
    only = [int(a, 0) for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    labels = places or ['s%d' % n for n in range(20) if n != 19]
    scratch = P.scratch('pair')
    try:
        bad = total = 0
        ways = (('still', S.hold(LEN, 0)), ('walking', S.hold(LEN, 0x01)))
        for label in labels:
            stage = int(label[1:])
            first = V.BASE if stage == 0 else P.WARP_IN
            play = first + 1
            state = V.stand(scratch, label, stage, None)
            cfg0 = S.seed(P.ram(state, [(first, '-')], first))
            pick = None
            for way, pads in ways:
                rows, ticks = S.cartridge(state, pads, play, full=True)
                pick = spot(rows, ticks)
                if pick is not None:
                    break
            if pick is None:
                print('%-6s nothing in the pool to borrow' % label)
                sys.stdout.flush()
                continue
            at, slot = pick
            print('%-6s %s, slot %d from frame %d' % (label, way, slot, at))
            sys.stdout.flush()
            # Each turn is written twice, a picture apart: turn $16 asks bit
            # nought of the clock which way to go, and one start in two never
            # reaches entry $79 at all.
            for kd, off in [(k, f) for k in range(TURNS) for f in (0, 1)]:
                if only and kd not in only:
                    continue
                total += 1
                put = [(0x0650 + slot, MIND),
                       (0x0610 + slot, 0x00), (0x0620 + slot, 0x00),
                       (0x0630 + slot, 0x00), (0x0640 + slot, 0x00),
                       (0x0690 + slot, kd), (0x06A0 + slot, 0x00),
                       (0x06B0 + slot, 0x00), (0x06C0 + slot, 0x00),
                       (0x06D0 + slot, 0x00), (0x06E0 + slot, 0x00),
                       (0x06F0 + slot, 0x08)]
                pk = [(a, v, play + at + off) for a, v in put]
                wp, ws, tk = K.cartridge(state, pads, play, pk)
                cfg = dict(cfg0)
                cfg['pads'] = pads
                cfg['kill_at'] = at + off
                cfg['put'] = [[a, v] for a, v in put]
                cfg['crates'] = True
                cfg['clock_at'] = [t[0] for t in tk]
                cfg['noise_at'] = [t[1] for t in tk]
                cfg['six_at'] = [t[2] for t in tk]
                cfg['step_at'] = [t[3] for t in tk]
                cfg['ride_at'] = [t[4] for t in tk]
                cfg['new_at'] = [t[5] for t in tk]
                owed = [t[6] for t in tk]
                cfg['owed_at'] = owed[:1] + owed[:-1]
                gp, gs = K.engine(cfg, scratch)
                n = min(len(wp), len(ws), len(gp), len(gs))
                # The turn is over once the slot is empty; what the pools do
                # after that belongs to somebody else.
                for i in range(at + off, n):
                    if wp[i][slot][0] == 0:
                        n = i + 1
                        break
                fin = S.finished(tk, n)
                where = kind = None
                for i in range(n):
                    if not fin[i]:
                        continue
                    if ws[i] != gs[i]:
                        where, kind = i, 'shots'
                        break
                    if wp[i] != gp[i]:
                        where, kind = i, 'pool'
                        break
                name = 'turn $%02X%s' % (kd, '+1' if off else '')
                if where is None:
                    print('%-6s %-12s ok, %d frames' % (label, name, n))
                    sys.stdout.flush()
                    continue
                bad += 1
                print('%-6s %-12s %s differs on frame %d'
                      % (label, name, kind, where))
                w, g, names, count = (ws, gs, H.NAMES, SHOTS) \
                    if kind == 'shots' else (wp, gp, M.NAMES, SLOTS)
                for j in range(count):
                    if w[where][j] == g[where][j]:
                        continue
                    for k, nm in enumerate(names):
                        if w[where][j][k] != g[where][j][k]:
                            print('    slot %2d %-6s cartridge %6d'
                                  '   engine %6d'
                                  % (j, nm, w[where][j][k], g[where][j][k]))
                sys.stdout.flush()
            if not places:
                break
        print('%d of %d turns differ' % (bad, total))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
