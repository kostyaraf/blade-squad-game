#!/usr/bin/env python3
"""Э5.5 acceptance: one bar for the two of them, and everything on it at once.

Unlike the rest of Э5 this one is not all mechanical questions.  Two of the
three things the plan asks for can be compared against something real -- each
game's own class, run alone on the same input -- and where that is so, it is
what is compared:

  * **every suit and every gun is choosable by both players.**  Five suits
    ($D259's ring) and eight guns ($92CD's eight combinations), and the point
    of Э5.5 is that none of them has to be found first.  The engine walks the
    menu out itself and says which it reached;
  * **the wear is the same size as in its own game.**  A Power Blade hero in a
    suit is stepped for a thousand pictures twice over: once inside a plain
    `Pb2Status`, which is the cartridge's own ($D2BE), and once inside
    `Pb3Gear`.  The two have to take the same cells off in the same pictures,
    suit by suit;
  * **and two of them take it off the one bar.**  Two heroes in two suits,
    and what comes off between them is what each would have taken alone.  A
    bar that is really shared cannot do anything else;
  * **an empty bar ends each of them the way his own game ends him.**  For the
    Power Blade hero that is $D312 -- the suit comes off, the tiles go back
    and what he has thrown is cleared; for the Solbrain hero it is $9347 with
    no life given, which is how his own game takes the satellite away.  Both
    endings are compared against the class that owns them, field for field.

What a Solbrain gun costs had to be decided, because its own game charges it
nothing by the picture: the satellite is not worn down, it is shot down.  It
is given sixteen of life at $9347, and sixteen is also how many cells the
Power Blade bar holds, so a hit on the satellite costs a cell, one for one,
and no number is invented between the two.  `work/re/pb3_gear.md`.
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

SUITS = 5
GUNS = 8
# Long enough for the slowest suit to eat the whole bar several times over.
FRAMES = 4000


def parse(line, head, n):
    f = line.split()
    if len(f) != n or f[0] != head:
        return None
    return f


def main():
    scratch = P.scratch('pb3gear')
    try:
        path = os.path.join(scratch, 'gear.json')
        open(path, 'w').write(json.dumps({'suits': SUITS, 'guns': GUNS,
                                          'frames': FRAMES}))
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--pb3gear=%s' % path],
                           capture_output=True, text=True, timeout=900)
        lines = r.stdout.split('\n')
        # choose p<i> <suit|gun> n <k> got <0|1>
        chose = [p for p in (parse(l, 'choose', 7) for l in lines) if p]
        # wear <suit|gun> n <k> alone <s> shared <s>
        wear = [p for p in (parse(l, 'wear', 8) for l in lines) if p]
        # shared cells <n> apart <a> <b>
        both = [p for p in (parse(l, 'shared', 6) for l in lines) if p]
        # empty <suit|gun> n <k> alone <s> shared <s>
        gone = [p for p in (parse(l, 'empty', 8) for l in lines) if p]
        if not chose or not wear or not both or not gone:
            sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
            print('the engine armed nobody')
            return 1
        unreached = [p for p in chose if p[6] != '1']
        # The whole run of cells, picture by picture, said as one word: a suit
        # that took the same total by a different road is not the same suit.
        differ = [p for p in wear if p[5] != p[7]]
        split = [p for p in both if int(p[2]) != int(p[4]) + int(p[5])]
        ends = [p for p in gone if p[5] != p[7]]
        for p in (unreached + differ + split + ends)[:10]:
            print(' '.join(p if len(p) < 8 else p[:4] + [p[5], p[7]]))
        print('%d suits and %d guns were offered to each of the two'
              % (len([p for p in chose if p[2] == 'suit']) / 2,
                 len([p for p in chose if p[2] == 'gun']) / 2))
        print('%d were never reached, %d wore the bar differently from their '
              'own game, %d bars were not really shared, %d ended differently '
              'when the bar ran out'
              % (len(unreached), len(differ), len(split), len(ends)))
        bad = len(unreached) + len(differ) + len(split) + len(ends)
        print('%d of %d questions of the shared arsenal differ from what it '
              'has to do'
              % (bad, len(chose) + len(wear) + len(both) + len(gone)))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


if __name__ == '__main__':
    sys.exit(main())
