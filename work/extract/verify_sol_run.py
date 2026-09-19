#!/usr/bin/env python3
"""Э4.6 acceptance, part two: the whole of Solbrain played by the engine alone.

Every other Solbrain stand holds the engine against the cartridge on a short
stretch and hands it the parts it cannot yet work out for itself.  This one
hands it nothing at all.  It is stood at the raising of the first stage and
left to run: its own hero, its own view, its own pool, its own minds, its own
script, its own clearing, its own passage from one stage to the next, its own
picking of what comes after and its own ending.

A pilot holds him towards the far edge and taps the two buttons, and walks the
pointer of STAGE SELECT round the five frames until it stands on one that is
left.  The pilot is not on trial and cannot play the game: where a stage is not
played out inside STEPS pictures it is ended where it stands, the two ways the
stage's own script ends one -- a stage with another of its own area left goes
out through the passage ($55 and $02 = $35), and the last of an area through
the clearing ($02 = $1B).  Both are counted and put out.

What is on trial is the run itself: every one of the twenty stages must raise,
put him together, run its minds and its script for hundreds of pictures without
the engine falling over, and hand on to the stage that comes after.  A mode the
engine does not port is a failure, and so is a run that comes round to a stage
it has already played while an area is still left.
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'
GAME = os.path.join(ROOT, 'game')

# How long a stage is given before the pilot ends it where it stands, and how
# many lines the run may put out before it is called a loop.  Twenty stages,
# the ending and a little room.
STEPS = 1500
LIMIT = 40
# A flow the engine cannot parse leaves it sitting in one mode for ever, so
# every run is given an end.
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
                            '--solrun=%d,%d' % (steps, limit)],
                           capture_output=True, text=True, timeout=WAIT)
    except subprocess.TimeoutExpired:
        print('the engine never stopped')
        return 1
    lines = [l for l in r.stdout.split('\n')
             if l[:1].isdigit() or ' stages played' in l]
    if not lines:
        sys.stderr.write(r.stdout[-4000:] + r.stderr[-4000:])
        print('the engine said nothing')
        return 1
    for l in lines:
        print(l)
    last = lines[-1]
    bad = 0
    if ' of 20 stages played' not in last:
        bad += 1
    else:
        played = int(last.split()[0])
        if played != 20:
            bad += 20 - played
        for part in last.split(','):
            f = part.strip().split()
            if f[-1] in ('stuck', 'over'):
                bad += int(f[0])
    # The run is only home once the ending has run out.
    if not any('the game is out' in l for l in lines):
        bad += 1
        print('the run never came out of the game')
    print('%d of 20 stages of the run differ' % bad)
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
