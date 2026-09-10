#!/usr/bin/env python3
"""Э3.8 acceptance, part two: the whole game played by the engine alone.

Every other stand holds the engine against the cartridge on a short stretch,
and hands it the parts it cannot yet work out for itself.  This one hands it
nothing at all.  It is stood in the first area of the first stage and left to
run: its own hero, its own view, its own sweep, its own minds, its own doors,
its own bar, area after area, to the end of the seventh stage.

A pilot holds it towards the far edge and taps A.  The pilot is not on trial
and cannot play the game -- where the hero sticks it shoves him a few points
on, and where the door is not reached in time it opens the door where it
stands, the same two bytes $B5A5 writes.  Both are counted and put out.

What is on trial is the run itself: every area must load, run its minds for
hundreds of steps without the engine falling over, put out its door, and hand
on to the area the door names.  A stage the run cannot get out of is a
failure, and so is a run that comes round to an area it has already played.
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'
GAME = os.path.join(ROOT, 'game')

# How many steps an area is given, and how many areas the run may play before
# it is called a loop.  Forty-five areas and ten boss rooms is the whole game.
STEPS = 900
LIMIT = 80
# A script the engine cannot parse leaves it sitting in an empty main loop for
# ever, so every run is given an end.
WAIT = 3600


def main():
    steps, limit = STEPS, LIMIT
    for a in sys.argv[1:]:
        if a.startswith('--steps='):
            steps = int(a.split('=')[1])
        elif a.startswith('--limit='):
            limit = int(a.split('=')[1])
    try:
        r = subprocess.run([GODOT, '--path', GAME, '--headless', '--',
                            '--run=%d,%d' % (steps, limit)],
                           capture_output=True, text=True, timeout=WAIT)
    except subprocess.TimeoutExpired:
        print('the engine never stopped')
        return 1
    text = r.stdout
    lines = [l for l in text.split('\n')
             if l.startswith(tuple('0123456789')) or ' areas played' in l]
    if not lines:
        sys.stderr.write(text[-4000:] + r.stderr[-4000:])
        print('the engine said nothing')
        return 1
    for l in lines:
        print(l)
    # An area the run had to step over is as much a failure as one it got
    # stuck in: in both the engine never put out the door of the area.
    last = lines[-1]
    bad = 0
    for part in last.split(','):
        f = part.strip().split()
        if f[-1] == 'stuck' or f[-1] == 'over':
            bad += int(f[0])
    print('%d of %d areas of the run differ' % (bad, len(lines) - 1))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
