#!/usr/bin/env python3
"""Э4.3 acceptance: what a thing does once it has been killed.

`verify_sol_minds.py` walks the hero about and watches the sixteen slots, but
nothing in those runs ever dies -- the hero is not made to shoot anything --
so the whole of the cartridge's second dispatch table, $827B in bank two, goes
untried.  That table is not a copy of the live one: a good half of its
sixty four entries point somewhere else entirely.

So this stand kills them by hand.  Bit 7 of $0650 is what tells $81B7 to read
the second table.  A stage's pool is empty at the door, so the run is played
once with nobody killed to find the picture that holds the most and to read the
behaviours standing on it; then it is played again with bit 7 written onto
every one of them on that picture.  The engine is handed the same picture and
the same bytes, and both must answer the same numbers for all sixteen slots,
picture by picture.
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

SLOTS = S.SLOTS
LEN = 60                  # long enough for a death animation to finish

R, L, A, B = 0x01, 0x02, 0x80, 0x40

# Dying needs no buttons, but the view has to be able to move, because a thing
# that has been let go of is taken away when it leaves the picture.
SCRIPTS = {
    'still':          S.hold(LEN, 0),
    'right':          S.hold(LEN, R),
    'there and back': S.hold(LEN, R) + S.hold(LEN, L),
}

PLACES = [('s%d' % n, n) for n in range(20)]

# Stage twenty keeps a script of its own in bank 8 ($9E63, $9E73, $9E90) which
# writes the pool by hand all through its opening.  What a slot does there is
# argued over by that script rather than by the behaviour under test, so the
# stage is counted apart until Э4.5 brings the script in.  Every one of these
# behaviours is read on its own, on stage one, by verify_sol_behaviours.py.
SCRIPTED = {'s19'}

# A stage's slots are not filled at the door: the scan at $CDBB puts things in
# over the first second or so, and the pool is at its fullest somewhere inside
# that -- so the whole run is looked at, less a tail left for the dying itself.
TAIL = 30                 # and how much of the run to leave for the dying


def killing_frame(rows, done):
    """Which picture of a run to kill everything on, and what to write.

    Only a picture the cartridge actually finished will do: a poke lands at the
    top of an emulator frame, and on a frame that carries the tail of an
    unfinished picture the walk over the pool has already read the byte.  Of
    those, the one with the most slots in it is taken.
    """
    best = None
    for k in range(1, max(1, len(rows) - TAIL)):
        if not done[k - 1]:
            continue
        held = [s for s in range(SLOTS) if rows[k - 1][s][0] != 0]
        if not held:
            continue
        if best is None or len(held) > len(best[1]):
            best = (k, held)
    return best


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    scratch = P.scratch('deaths')
    try:
        bad = total = known = 0
        owed = {}
        for label, stage in PLACES:
            if places and label not in places:
                continue
            first = V.BASE if stage == 0 else P.WARP_IN
            play = first + 1
            state = V.stand(scratch, label, stage, None)
            cfg0 = S.seed(P.ram(state, [(first, '-')], first))
            for name, pads in sorted(SCRIPTS.items()):
                if only and name not in only:
                    continue
                # A first run with nobody killed, to find the picture that has
                # the most in the pool and to read the behaviours standing on
                # it: a poke writes a whole byte, so bit 7 can only be put on a
                # value already known.
                rows, ticks = S.cartridge(state, pads, play, full=True)
                pick = killing_frame(rows, S.finished(ticks, len(rows)))
                if pick is None:
                    print('%-6s %-15s nothing in the pool' % (label, name))
                    sys.stdout.flush()
                    continue
                at, held = pick
                dead = {s: rows[at - 1][s][3] | 0x80 for s in held}
                total += 1
                pk = [(0x0650 + s, v, play + at) for s, v in sorted(dead.items())]
                want, ticks = S.cartridge(state, pads, play, full=True,
                                          pokes=pk)
                cfg = dict(cfg0)
                cfg['pads'] = pads
                cfg['kill_at'] = at
                cfg['kill'] = [[s, v] for s, v in sorted(dead.items())]
                cfg['clock_at'] = [t[0] for t in ticks]
                cfg['noise_at'] = [t[1] for t in ticks]
                cfg['six_at'] = [t[2] for t in ticks]
                cfg['step_at'] = [t[3] for t in ticks]
                cfg['ride_at'] = [t[4] for t in ticks]
                cfg['new_at'] = [t[5] for t in ticks]
                got, missing = M.engine(cfg, scratch)
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
                    print('%-6s %-15s ok, %d frames, %d killed on %d'
                          % (label, name, n, len(held), at))
                    sys.stdout.flush()
                    continue
                if label in SCRIPTED:
                    known += 1
                    print('%-6s %-15s differs on frame %d'
                          ' -- the stage has a script of its own' % (label, name, where))
                    sys.stdout.flush()
                    continue
                bad += 1
                print('%-6s %-15s differs on frame %d (killed %s on %d)'
                      % (label, name, where,
                         ' '.join('%d:$%02X' % (s, v & 0x3F)
                                  for s, v in sorted(dead.items())), at))
                if where < n:
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
                    print('    cartridge %d frames, engine %d'
                          % (len(want), len(got)))
                sys.stdout.flush()
        print('%d of %d scripts differ, %d more only where stage twenty'
              ' writes the pool itself' % (bad, total, known))
        if owed:
            print('behaviours not read yet: %s'
                  % ', '.join('%s x%d' % (k, v) for k, v in sorted(owed.items())))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
