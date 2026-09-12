#!/usr/bin/env python3
"""Export the board STAGE SELECT is played on.

Mode $19 ($DAE3) draws screen $13 -- five empty frames and the man below them
-- and mode $1A ($DBAE) walks it up the screen and then writes a picture into
each frame, one frame at a time.

Writing one frame is $DD84.  It takes two numbers: which frame ($4F or $4D,
nought to five) and which picture (the caller's Y).  $DDDE looks at $2D, the
stages already cleared, and if the one this frame stands for is cleared it
makes the picture nought, which is the empty frame.  Then:

* six bytes of colour go out of $DF17 (three at a time) or $DF2F (two at a
  time, which is what the frame in the middle wants), starting at the offset
  $DE35 gives for that picture, to the two places $DDEF holds for the frame;
* six rows of eight tiles go out of one of seven blocks -- $E037 for a frame
  that is done with, and one apiece for the five stages and the middle -- to
  the place $DE27 holds for the frame, a row every thirty two tiles.

The pointer is a picture of its own drawn over the frame $4E stands on, at
$DD52,$DD4C; $DD5E turns $4E into $4C, and $DD58 turns that into the number of
the stage in $55.

`work/re/sol_flow.md` says how the mode uses all of it.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import ROM_SOL, outdir, write_json                  # noqa: E402

## The two banks the game always has: $C000..$FFFF.
FIXED = 14

## $DDEF -- seven bytes a frame, eight apart: the two places the colour goes,
## each as a count and an address, and then the sign that picks which of the
## two colour tables is read.
ATTR = 0xDDEF
ATTR_STRIDE = 8
FRAMES = 6

## $DE27 -- two bytes a frame: where the tiles go.
TILES = 0xDE27

## $DE35 -- where in the colour table a picture's six bytes begin.
OFFSET = 0xDE35
PICTURES = 7

## $DF17 three at a time and $DF2F two at a time.
ATTR3 = 0xDF17
ATTR2 = 0xDF2F
ATTR_N = 24

## The seven blocks of tiles, six rows of eight: the frame that is done with
## first, then the five stages, then the one in the middle.
ART = (0xE037, 0xDF47, 0xDF77, 0xDFA7, 0xDFD7, 0xE007, 0xE067)
ART_N = 48
WIDE = 8
TALL = 6

## $DD52 and $DD4C -- where the pointer stands on each frame; $DD5E and $DD58
## -- which frame the pointer is on, and which stage that is.
MARK_X = 0xDD52
MARK_Y = 0xDD4C
PICK = 0xDD5E
STAGE = 0xDD58


def main():
    with open(ROM_SOL, 'rb') as f:
        prg = f.read()[16:]
    fixed = prg[FIXED * 0x2000:(FIXED + 2) * 0x2000]

    def at(a, n):
        return list(fixed[a - 0xC000:a - 0xC000 + n])

    attr_at, attr_wide = [], []
    for n in range(FRAMES):
        row = at(ATTR + ATTR_STRIDE * n, 7)
        # A count and an address twice, and then the byte whose top bit says
        # the colour comes two at a time instead of three.
        attr_at.append([(row[1] << 8) | row[2], (row[4] << 8) | row[5]])
        attr_wide.append(row[0] & 0x1F)
        assert (row[3] & 0x1F) == (row[0] & 0x1F)
        assert (row[6] >= 0x80) == ((row[0] & 0x1F) == 2)

    tiles = at(TILES, FRAMES * 2 + 2)
    data = {
        'attr_at': attr_at,
        'attr_wide': attr_wide,
        'tiles_at': [(tiles[2 * n + 1] << 8) | tiles[2 * n]
                     for n in range(PICTURES)],
        'attr_off': at(OFFSET, PICTURES),
        'attr3': at(ATTR3, ATTR_N),
        'attr2': at(ATTR2, ATTR_N),
        'art': [at(a, ART_N) for a in ART],
        'wide': WIDE,
        'tall': TALL,
        'mark_x': at(MARK_X, FRAMES),
        'mark_y': at(MARK_Y, FRAMES),
        # Seven, not six: $DC89 puts $4E at six when the board is still
        # walking up, and $DCBB reads $DD5E with it.
        'pick': at(PICK, FRAMES + 1),
        'stage': at(STAGE, FRAMES),
    }
    size = write_json(os.path.join(outdir('sol'), 'board.json'), data)
    print('%d frames, %d pictures, %d bytes'
          % (FRAMES, len(ART), size))


if __name__ == '__main__':
    main()
