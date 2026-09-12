#!/usr/bin/env python3
"""Export TEST MODE -- the maker's own menu and where its nine lines lead.

Sixteen buttons in a row on the title ($D226) open it.  $D79F lays screen $19
and $D7C2 is the menu itself: SELECT walks a cursor of one sprite down nine
lines, START takes the line the cursor stands on and puts the mode the table
at $D816 names into $02.

Seven of the nine are the same thing with a different number: a little stub in
the fixed bank that puts a stage into $55 and asks for it ($1D).  That is the
only door in the game to the stages the boss rooms stand in, so it is also
what the scroll scripts of those rooms are reached through.

```
line  goes to   what it is
  0     $2A     BGM TEST -- screen $1B, a number from 0 to $10
  1     $33     sound test -- screen $2F, a number from 0 to $40
  2     $48     stage $08        5     $42     stage $0E
  3     $30     stage $0C        6     $4A     stage $12
  4     $41     stage $0D        7     $4B     stage $11
  8     $04     the title
```

($49, stage $13, is in the same row of stubs but no line of the menu names
it.)  The two tests draw their number with $D847, which writes two digits
straight into the board at $216F.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import ROM_SOL, outdir, write_json                  # noqa: E402

FIXED = 14

## $D80D -- where the cursor stands on each of the nine lines, $D816 -- the
## mode each line leads to.
CURSOR_Y = 0xD80D
GOES = 0xD816
LINES = 9

## $D7FD and $D802 -- the cursor is one sprite and never moves sideways.
CURSOR_X = 0x58
CURSOR_TILE = 0x1B

## The stubs that put a stage into $55 and ask for it ($CA91 and $D930 whole,
## the rest falling into $CA91).  Each begins `LDA #stage`.
STUBS = {0x30: 0xD930, 0x41: 0xCA7D, 0x42: 0xCA81, 0x48: 0xCA85,
         0x49: 0xCA91, 0x4A: 0xCA89, 0x4B: 0xCA8D}

## $D7A5, $D86B and $D90E -- the screens of the menu and of the two tests, and
## how far each test's number counts ($D89F and $D903).
SCREEN = 0x19
BGM_SCREEN = 0x1B
BGM_N = 0x11
SOUND_SCREEN = 0x2F
SOUND_N = 0x41

## $D84F -- where $D847 writes the two digits of the number.
NUMBER_AT = 0x216F

## $D7BA and $D87B -- the table all three screens of TEST MODE take their
## colours out of.  The menu takes twenty of it ($C6E9 with X=$13) and the two
## tests sixteen ($C6E9 with X=$0F); the byte one past the last taken is the
## backdrop and goes into every fourth of the thirty two ($C711), so the
## twenty one that cover both cases are exported.
PALETTE = 0xD485
PALETTE_N = 0x15
MENU_N = 0x14
TEST_N = 0x10


def main():
    with open(ROM_SOL, 'rb') as f:
        prg = f.read()[16:]
    fixed = prg[FIXED * 0x2000:(FIXED + 2) * 0x2000]

    def at(a, n):
        return list(fixed[a - 0xC000:a - 0xC000 + n])

    stages = {}
    for mode, a in sorted(STUBS.items()):
        one = at(a, 2)
        assert one[0] == 0xA9, '$%04X is not LDA #' % a
        stages['%02X' % mode] = one[1]
    data = {
        'screen': SCREEN,
        'cursor_y': at(CURSOR_Y, LINES),
        'goes': at(GOES, LINES),
        'cursor_x': CURSOR_X,
        'cursor_tile': CURSOR_TILE,
        'stage_of': stages,
        'bgm_screen': BGM_SCREEN,
        'bgm_n': BGM_N,
        'sound_screen': SOUND_SCREEN,
        'sound_n': SOUND_N,
        'number_at': NUMBER_AT,
        'palette': at(PALETTE, PALETTE_N),
        'menu_n': MENU_N,
        'test_n': TEST_N,
    }
    size = write_json(os.path.join(outdir('sol'), 'test.json'), data)
    print('%d lines, %d stubs, %d bytes'
          % (LINES, len(stages), size))


if __name__ == '__main__':
    main()
