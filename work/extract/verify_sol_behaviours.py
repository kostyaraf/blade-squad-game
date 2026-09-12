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


def spot(rows, ticks):
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
    # --kinds=NN holds one behaviour still and sweeps $0690 instead: several
    # of the numbers are whole families, and $3F is the largest of them.
    ask = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--kinds=')]
    ask = int(ask[0], 0) if ask else None
    # A family's table is only as long as the cartridge wrote it; past its end
    # the cartridge jumps into whatever follows, so how far to sweep and with
    # what stride is asked for rather than guessed.
    upto = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--upto=')]
    upto = int(upto[0], 0) if upto else 0x3F
    step = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--step=')]
    step = int(step[0], 0) if step else 1
    tables = [0x00, 0x80]
    if '--live' in sys.argv:
        tables = [0x00]
    if '--dead' in sys.argv:
        tables = [0x80]
    # Without a stage asked for, the first one that has something in its pool
    # to borrow is used and the rest are left alone: one stage is enough to ask
    # every behaviour what it does, and sixty four of them twice over is
    # already as long a run as the acceptance wants.
    labels = places or ['s%d' % n for n in range(20) if n != 19]
    scratch = P.scratch('behaviours')
    try:
        bad = total = known = 0
        WAYS = (('still', S.hold(LEN, 0)), ('walking', S.hold(LEN, 0x01)))
        for label in labels:
            stage = int(label[1:])
            first = V.BASE if stage == 0 else P.WARP_IN
            play = first + 1
            state = V.stand(scratch, label, stage, None)
            cfg0 = S.seed(P.ram(state, [(first, '-')], first))
            pick = None
            for way, pads in WAYS:
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
            for top in tables:
                jobs = ([(ask, k) for k in range(0, upto + 1, step)]
                        if ask is not None
                        else [(m, 0x00) for m in range(0x40)])
                for m, kd in jobs:
                    if only and (kd if ask is not None else m) not in only:
                        continue
                    total += 1
                    # The whole slot is written, not only the behaviour, so
                    # that the two sides start from the same place.
                    put = [(0x0650 + slot, top | m),
                           (0x0610 + slot, 0x00), (0x0620 + slot, 0x00),
                           (0x0630 + slot, 0x00), (0x0640 + slot, 0x00),
                           (0x0690 + slot, kd), (0x06A0 + slot, 0x00),
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
                    # the pool does after belongs to somebody else.  The look
                    # starts on the picture the behaviour is written in, not
                    # before it: the slot is very often still empty up to then.
                    for i in range(at, n):
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
                    if ask is not None:
                        name = '%s/$%02X' % (name, kd)
                    if where is None:
                        print('%-6s %-14s ok, %d frames' % (label, name, n))
                        sys.stdout.flush()
                        continue
                    if label in SCRIPTED:
                        known += 1
                        print('%-6s %-14s %s differs on frame %d'
                              ' -- the stage has a script of its own'
                              % (label, name, kind, where))
                        sys.stdout.flush()
                        continue
                    bad += 1
                    print('%-6s %-14s %s differs on frame %d'
                          % (label, name, kind, where))
                    if os.environ.get('BEH_DUMP'):
                        for i in range(max(at, where - 6), min(n, where + 2)):
                            print('  f%d want %s' % (i, want[i][slot],))
                            print('      got %s' % (got[i][slot],))
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
            if not places:
                break
        print('%d of %d behaviours differ, %d more only where stage twenty'
              ' writes the pool itself' % (bad, total, known))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
