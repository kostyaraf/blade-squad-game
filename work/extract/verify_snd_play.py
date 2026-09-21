#!/usr/bin/env python3
"""Э6.3.1 acceptance: the seat the sound sits in.

Э6.1 proved the drivers write what the cartridge writes; Э6.2 proved the chip
makes of those bytes what the console makes.  Between them and a loudspeaker
there is one number left, and it is the one that can be wrong without anybody
hearing it wrong: how many cycles of the chip a picture is worth.

An NTSC picture is 29780.5 cycles.  Half a cycle a picture is a part in sixty
thousand -- a tune drifts by a second every twenty minutes and not one note of
it is out of tune.  Nobody would ever hear that and find it.  So this stand
does not listen; it counts.

  * after N pictures the player has run exactly floor(N * 29780.5) cycles,
    which for three pictures is 89341 and not 89340;
  * the chip takes one sample every fortieth cycle, so what it has made is
    exactly floor(cycles / 40): none swallowed, none doubled, and the count
    carries across a picture rather than starting again inside it;
  * the cartridge agrees about the length of a picture.  This is the one
    thing `nesemu` is asked, and it is asked because 29780.5 is otherwise a
    number copied out of a book: a thousand pictures of the real cartridge
    are 29780500 cycles, give or take two.

The give or take is the console and not a slack rule.  A picture is 341 dots
by 262 lines, and on every other picture the beam skips one of them -- but
only while it is drawing.  A picture with the drawing turned off, which is
what a screen changing is, is the long one, so the cartridge's own pictures
come out one cycle over or under as the drawing goes on and off.  It does not
pile up: two and a half thousand pictures of Power Blade 2 are one cycle over
the average and not five hundred.  Taking the average is therefore the right
thing for a port with no beam in it, and the stand says so rather than
pretending the two agree exactly.

Odd counts as well as even, because a half cycle thrown away hides on the even
ones; and one long run, because a half cycle rounded rather than kept hides on
the short ones.

Run with no arguments.
"""
import json
import math
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import sol_probe as P                                            # noqa: E402
import sndprobe as SP                                            # noqa: E402
import verify_sol_player as V                                    # noqa: E402

CYCLES = 29780.5
EVERY = 40

# Short and odd, a second, and a minute; and both games, because each brings
# its own driver and Power Blade 2's also brings the sample channel.
PICTURES = [1, 2, 3, 7, 59, 60, 61, 601, 3600]

# What the cartridge is asked, to tell one picture from the next: two runs far
# enough apart that the cycles the reset itself took fall out of the subtraction.
FROM, TO = 100, 2600
# How far the cartridge may sit from the average, for the reason above.
SLACK = 4


def engine(scratch):
    """Every run through the engine's own seat."""
    runs = []
    for game in ('pb2', 'sol'):
        for n in PICTURES:
            # $00 is the number that quiets both drivers, so a run with no
            # request in it is a run with the chip idling; one with a request
            # is a run with all five channels going.  Both are counted, and
            # the count must not care which.
            runs.append({'game': game, 'pictures': n})
            runs.append({'game': game, 'pictures': n, 'ask': 1})
    path = os.path.join(scratch, 'play.json')
    open(path, 'w').write(json.dumps({'runs': runs}))
    p = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                        '--sndplay=%s' % path],
                       capture_output=True, text=True, timeout=3600)
    out = []
    for line in p.stdout.split('\n'):
        if line.startswith('play '):
            w = line.split()
            out.append((w[1], int(w[2]), int(w[3]), int(w[4]), int(w[5])))
    if not out:
        sys.stderr.write(p.stdout[-3000:] + p.stderr[-3000:])
    return out


def cartridge_cycles(game, frames):
    """How many cycles the real cartridge spends on that many pictures."""
    p = subprocess.run([SP.NESEMU, SP.ROM[game], '-frames', str(frames)],
                       capture_output=True, text=True, timeout=600)
    for line in p.stderr.split('\n'):
        if line.startswith('done:'):
            return int(line.split('frames, ')[1].split(' ')[0])
    sys.stderr.write(p.stdout[-1000:] + p.stderr[-1000:])
    return 0


def main():
    scratch = P.scratch('sndplay')
    bad = 0
    rows = engine(scratch)
    for game, n, cycles, made, dropped in rows:
        want_c = int(math.floor(n * CYCLES))
        want_s = cycles // EVERY
        note = []
        if cycles != want_c:
            note.append('cycles %d, wanted %d' % (cycles, want_c))
        if made != want_s:
            note.append('samples %d, wanted %d' % (made, want_s))
        if note:
            bad += 1
        print('%-3s %5d pictures  %9d cycles  %8d samples  %s'
              % (game, n, cycles, made,
                 '; '.join(note) if note else 'ok'))
    # And the cartridge's own opinion of how long a picture is.
    tally = 0
    for game in ('pb2', 'sol'):
        a = cartridge_cycles(game, FROM)
        b = cartridge_cycles(game, TO)
        want = int(round((TO - FROM) * CYCLES))
        got = b - a
        tally += 1
        off = abs(got - want)
        if off > SLACK:
            bad += 1
        print('%-3s %5d pictures of the cartridge  %9d cycles  %s'
              % (game, TO - FROM, got,
                 'ok, %d off the average' % (got - want) if off <= SLACK
                 else 'wanted %d' % want))
    print('%d of %d counts differ from what a picture is worth'
          % (bad, len(rows) + tally))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
