#!/usr/bin/env python3
"""Э5.3 acceptance: the screen the two of them choose on.

Э5.1 made a level answer either hero, Э5.2 put both on one screen and Э5.4
let either game's things reach either hero.  What is still missing in front of
all of it is the choosing: who is the Power Blade hero this time and who is
the Solbrain one.

There is no cartridge for this screen -- neither game ever had one -- so it is
drawn with each game's own tiles and palettes and nothing invented, and
acceptance is four mechanical questions, the ones the plan names:

  * every one of the four arrangements is reachable from every other, and
    reachable settled -- with both of them saying they are done with it,
    because an arrangement nobody can confirm is one nobody can play.  The
    engine walks it out itself, shortest first, over everything the picker
    holds and not only over what was chosen, and says how many pictures each
    of the thirty two ways took; a way it never found is what fails here;
  * a pad that presses nothing changes nothing, held for a second;
  * the same buttons make the same picture.  The screen is asked for twice
    over the same pads and the two are compared byte for byte, names, colours
    and all;
  * and what was chosen reaches `Pb3Pair` in the shape it was chosen in: the
    pair is built from the picker's own answer and asked back who it holds.

The picker knows nothing but the choice (`game/src/pb3_pick.gd`).  It does not
know what a level is, and `Pb3Pair` does not know a screen was ever shown.
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

# The four arrangements, in the order the engine names them.
WAYS = ['pb2,pb2', 'pb2,sol', 'sol,pb2', 'sol,sol']

# How long a pad that presses nothing is held for.
QUIET = 60


def parse(line, head, n):
    f = line.split()
    if len(f) != n or f[0] != head:
        return None
    return f


def main():
    scratch = P.scratch('pb3pick')
    try:
        path = os.path.join(scratch, 'pick.json')
        open(path, 'w').write(json.dumps({'ways': WAYS, 'quiet': QUIET}))
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--pb3pick=%s' % path],
                           capture_output=True, text=True, timeout=900)
        lines = r.stdout.split('\n')
        # reach <from> <to> steps <n>        -- -1 when it never got there
        reach = [p for p in (parse(l, 'reach', 5) for l in lines) if p]
        reach += [p for p in (parse(l, 'settle', 5) for l in lines) if p]
        # quiet <way> changed <0|1>
        quiet = [p for p in (parse(l, 'quiet', 4) for l in lines) if p]
        # picture <way> same <0|1> bytes <n>
        shot = [p for p in (parse(l, 'picture', 6) for l in lines) if p]
        # handed <way> who <way>
        hand = [p for p in (parse(l, 'handed', 4) for l in lines) if p]
        if not reach or not quiet or not shot or not hand:
            sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
            print('the engine chose nothing')
            return 1
        want = {(h, a, b) for h in ('reach', 'settle')
                for a in WAYS for b in WAYS}
        got = {(p[0], p[1], p[2]) for p in reach if int(p[4]) >= 0}
        lost = sorted(want - got)
        noisy = [p for p in quiet if p[3] != '0']
        differ = [p for p in shot if p[3] != '1']
        crossed = [p for p in hand if p[1] != p[3]]
        for h, a, b in lost[:8]:
            print('%s never became %s%s'
                  % (a, b, ' and settled' if h == 'settle' else ''))
        for p in (noisy + differ + crossed)[:8]:
            print(' '.join(p))
        far = max(int(p[4]) for p in reach if int(p[4]) >= 0)
        print('%d ways of the thirty two were walked, the longest in %d '
              'pictures' % (len(got), far))
        print('the screen is %s bytes of tiles and colours'
              % (shot[0][5] if shot else '?'))
        print('%d arrangements were never reached, %d changed under a pad that '
              'pressed nothing, %d drew differently the second time, %d '
              'reached the pair as something else'
              % (len(lost), len(noisy), len(differ), len(crossed)))
        bad = len(lost) + len(noisy) + len(differ) + len(crossed)
        print('%d of %d questions of the choosing screen differ from what it '
              'has to do' % (bad, len(want) + len(quiet) + len(shot)
                             + len(hand)))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


if __name__ == '__main__':
    sys.exit(main())
