#!/usr/bin/env python3
"""Export how Solbrain settles its colours.

Nothing in the game writes the console's colours straight.  A mode names a
table of thirty two ($E9B1, which is nothing but `$20:$21 = the table`) and
then asks for a walk ($F86D, which is `$26 = what kind` and `$27 = which of
the eight palettes`), and bank ten walks it a picture at a time: $8520 moves
each palette's own level in $05BA..$05C1 by one and $8608 writes the thirty
two bytes out again at that level.

A level is a number from minus eight to seven.  A colour of the table is split
into its hue -- the low nibble -- and one of four brightnesses the cartridge
wrote it at; $86C5 turns that pair into a number from nought to seven, the
level is added to it and the sum clamped, and $8645 turns the hue and the sum
back into a colour of the console's own sixty four.  At minus eight every
colour comes out black, which is how a screen is faded up from nothing, and at
nought every colour comes out exactly as the table wrote it.

What is exported is the three tables that takes: the palettes themselves, the
brightness a hue and a shade come to, and the colour a hue and a brightness
come to.  `work/re/sol_screens.md` says which mode names which palette.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import ROM_SOL, outdir, write_json                  # noqa: E402

BANK = 10                 # the pair the colours live in: ten at $8000
FIRST = 0x8000            # and the ground they are spread over
LAST = 0x8520
BRIGHT = 0x86C5           # sixteen hues by four shades
BRIGHT_N = 64
COLOURS = 0x8645          # sixteen hues by eight brightnesses
COLOURS_N = 128

## Not every table is in bank ten.  The title ($D1D1) and the three screens of
## TEST MODE ($D7BA, $D87B) name tables that stand in the fixed bank, and a
## screen that takes only some of a table leaves the rest as the table before
## it wrote them -- so the one before has to be here as well.
FIXED_BANK = 14
FIXED = (0xD485, 0xD499, 0xD481)

## And the ending names one that does not stand on a boundary of thirty two:
## $E36B takes the whole of the table at $8010, which is not where the spread
## above lands.
EXTRA = (0x8010,)


def main():
    with open(ROM_SOL, 'rb') as f:
        prg = f.read()[16:]
    lo = prg[BANK * 0x2000:(BANK + 1) * 0x2000]
    fixed = prg[FIXED_BANK * 0x2000:(FIXED_BANK + 2) * 0x2000]

    def at(a, n):
        return list(lo[a - 0x8000:a - 0x8000 + n])

    tables = {'%04X' % a: at(a, 32) for a in range(FIRST, LAST, 32)}
    for a in FIXED:
        tables['%04X' % a] = list(fixed[a - 0xC000:a - 0xC000 + 32])
    for a in EXTRA:
        tables['%04X' % a] = at(a, 32)

    data = {
        'tables': tables,
        'bright': at(BRIGHT, BRIGHT_N),
        'colours': at(COLOURS, COLOURS_N),
    }
    size = write_json(os.path.join(outdir('sol'), 'fade.json'), data)
    print('%d palettes, %d bytes' % (len(data['tables']), size))


if __name__ == '__main__':
    main()
