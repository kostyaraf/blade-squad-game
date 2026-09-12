#!/usr/bin/env python3
"""Э4.3 acceptance: every behaviour of the two tables, one at a time.

The walk-about stand meets only the behaviours a stage happens to spawn, and
most of the sixty four in $81EA never turn up in the first few seconds of any
of them.  So this one asks for them by name: it takes a slot the cartridge has
already filled, writes one behaviour number into it -- with bit seven down for
the living table and up for the dead one -- and lets the same picture run in
both the cartridge and the engine.

Nothing is judged by eye.  A behaviour either matches on all sixteen slots and
on the thirty two bytes of the broken mark for every picture it lasts, or the
first picture that parts company is printed.
"""
import json
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
import verify_sol_crates as C                                    # noqa: E402

SLOTS = S.SLOTS
MARKS = C.MARKS
LEN = 110                 # long enough for the longest turn to come round
TAIL = 60                 # room left after the picture the behaviour starts on

# Stage twenty keeps a script of its own in bank 8 which writes the pool by
# hand all through its opening, so anything poked into a slot there is argued
# over by the script rather than by the behaviour under test.
SCRIPTED = {'s19'}


def spot(state, pads, play, rows, ticks):
    """The first finished picture that has something in the pool to borrow."""
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
    tables = [0x00, 0x80]
    if '--live' in sys.argv:
        tables = [0x00]
    if '--dead' in sys.argv:
        tables = [0x80]
    labels = places or ['s0']
    scratch = P.scratch('behaviours')
    try:
        bad = total = known = 0
        pads = S.hold(LEN, 0)
        for label in labels:
            stage = int(label[1:])
            first = V.BASE if stage == 0 else P.WARP_IN
            play = first + 1
            state = V.stand(scratch, label, stage, None)
            cfg0 = S.seed(P.ram(state, [(first, '-')], first))
            rows, ticks = S.cartridge(state, pads, play, full=True)
            pick = spot(state, pads, play, rows, ticks)
            if pick is None:
                print('%-6s nothing in the pool to borrow' % label)
                continue
            at, slot = pick
            for top in tables:
                for m in range(0x40):
                    if only and m not in only:
                        continue
                    total += 1
                    # The whole slot is written, not only the behaviour, so
                    # that the two sides start from the same place.
                    put = [(0x0650 + slot, top | m),
                           (0x0610 + slot, 0x00), (0x0620 + slot, 0x00),
                           (0x0630 + slot, 0x00), (0x0640 + slot, 0x00),
                           (0x0690 + slot, 0x00), (0x06A0 + slot, 0x00),
                           (0x06B0 + slot, 0x00), (0x06C0 + slot, 0x00),
                           (0x06D0 + slot, 0x00), (0x06E0 + slot, 0x00),
                           (0x06F0 + slot, 0x08)]
                    pk = [(a, v, play + at) for a, v in put]
                    want, wmark, tk = C.cartridge(state, pads, play, pk)
                    cfg = dict(cfg0)
                    cfg['pads'] = pads
                    cfg['kill_at'] = at
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
                    got, gmark = C.engine(cfg, scratch)
                    n = min(len(want), len(got), len(gmark))
                    # Once the slot is empty the behaviour is over, and what
                    # the pool does after belongs to somebody else.
                    for i in range(n):
                        if want[i][slot][0] == 0:
                            n = i + 1
                            break
                    fin = S.finished(tk, n)
                    where = kind = None
                    for i in range(n):
                        if not fin[i]:
                            continue
                        if want[i] != got[i]:
                            where, kind = i, 'pool'
                            break
                        if wmark[i] != gmark[i]:
                            where, kind = i, 'mark'
                            break
                    name = '%s $%02X' % ('dead' if top else 'live', m)
                    if where is None:
                        print('%-6s %-10s ok, %d frames' % (label, name, n))
                        sys.stdout.flush()
                        continue
                    if label in SCRIPTED:
                        known += 1
                        print('%-6s %-10s %s differs on frame %d'
                              ' -- the stage has a script of its own'
                              % (label, name, kind, where))
                        sys.stdout.flush()
                        continue
                    bad += 1
                    print('%-6s %-10s %s differs on frame %d'
                          % (label, name, kind, where))
                    if kind == 'pool':
                        for s in range(SLOTS):
                            if want[where][s] == got[where][s]:
                                continue
                            for k, nm in enumerate(M.NAMES):
                                if want[where][s][k] != got[where][s][k]:
                                    print('    slot %2d %-6s cartridge %6d'
                                          '   engine %6d'
                                          % (s, nm, want[where][s][k],
                                             got[where][s][k]))
                    else:
                        for i in range(MARKS):
                            if wmark[where][i] != gmark[where][i]:
                                print('    mark %2d cartridge $%02X'
                                      ' engine $%02X'
                                      % (i, wmark[where][i], gmark[where][i]))
                    sys.stdout.flush()
        print('%d of %d behaviours differ, %d more only where stage twenty'
              ' writes the pool itself' % (bad, total, known))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
