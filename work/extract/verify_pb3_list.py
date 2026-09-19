#!/usr/bin/env python3
"""Э5.6 acceptance: the sixty three areas and the twenty stages in one list.

Э5.1 to Э5.5 made a level answer both heroes, hold both on one screen, let
either game's things reach either hero, choose who is who and share one bar.
This puts every level of both games behind one cursor.

A record is three numbers -- which game, which stage, which area -- which is
all a level ever needed to be raised by, so nothing new is invented here.  The
questions are the plan's three, and a fourth the plan leaves unsaid:

  * the whole list comes up.  Every one of the eighty three records raises a
    level and puts both heroes on it, and neither of them is standing inside
    something: the place is the level's own start, so a record where that is
    not standable is a record the list cannot offer;
  * and plays.  Every record is stepped for ninety pictures, both pads
    walking, and every one of those pictures is played -- a record that stops
    short is the fault this is looking for.  Where the level has ground under
    the place it opens on, both heroes are still in the level at the end of
    it; where it has none they are not asked to be, and the level is the one
    that says which it is.  One Power Blade area opens over water with no
    floor anywhere in that column, and a hero who sinks out of it there was
    not dropped by the engine.  The count is printed either way;
  * leaving a level comes back to the list at the record it was entered from,
    and not at the top;
  * and every record is reachable with the cursor, which is the fourth: a
    list with a record nobody can walk to is a list with a record missing.
    The engine walks it out itself and says how many it reached.

There is no cartridge for a list of both games' levels, so the questions are
mechanical.  What is *not* mechanical is that each level is raised by the same
`Pb3Pair` Э5.2 was accepted on and each record by the same `Pb2Level` and
`SolLevel` the two games are read with: a record that falls over here falls
over in something already accepted.
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

# How many pictures each record is played for, and by which pads.  Both
# walking, one each way, so that neither the view nor the floor is asked the
# same thing twice.
FRAMES = 90
PADS = [0x01, 0x02]

# All four pairings, the way Э5.2 asks them.
KINDS = [['pb2', 'sol'], ['sol', 'pb2'], ['pb2', 'pb2'], ['sol', 'sol']]

RECORDS = 63 + 20


def parse(line, head, n):
    f = line.split()
    if len(f) != n or f[0] != head:
        return None
    return f


def main():
    scratch = P.scratch('pb3list')
    try:
        path = os.path.join(scratch, 'list.json')
        open(path, 'w').write(json.dumps({'frames': FRAMES, 'pads': PADS,
                                          'kinds': KINDS}))
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--pb3list=%s' % path],
                           capture_output=True, text=True, timeout=3600)
        lines = r.stdout.split('\n')
        # rec <where> <one> <two> up <0|1> solid <n> ran <n> alive <0|1>
        #     ground <n> back <n> from <n>
        rows = [p for p in (parse(l, 'rec', 18) for l in lines) if p]
        # walked <n> of <n>
        walk = [p for p in (parse(l, 'walked', 4) for l in lines) if p]
        if not rows or not walk:
            sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
            print('the engine raised nothing')
            return 1
        never = [p for p in rows if p[5] != '1']
        walled = [p for p in rows if int(p[7]) > 0]
        stopped = [p for p in rows if int(p[9]) < FRAMES
                   or (int(p[13]) == 2 and p[11] != '1')]
        back = [p for p in rows if p[15] != p[17]]
        lost = [p for p in walk if p[1] != p[3]]
        for p in (never + walled + stopped + back + lost)[:10]:
            print(' '.join(p))
        kinds = len({(p[2], p[3]) for p in rows})
        where = len({p[1] for p in rows})
        print('%d records of the %d, each in %d pairings, raised and played %d '
              'pictures' % (where, RECORDS, kinds, FRAMES))
        thin = len([p for p in rows if int(p[13]) != 2])
        print('%d raisings put a hero over a column the level has no floor '
              'in; they are played out like the rest and only the end of them '
              'is left unasked' % thin)
        print('%d never came up, %d put somebody inside something solid, %d '
              'stopped short or died, %d came back to the wrong record, %d '
              'lists had a record the cursor could not reach'
              % (len(never), len(walled), len(stopped), len(back), len(lost)))
        bad = len(never) + len(walled) + len(stopped) + len(back) + len(lost)
        print('%d of %d raisings of the list differ from what it has to do'
              % (bad, len(rows) + len(walk)))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


if __name__ == '__main__':
    sys.exit(main())
