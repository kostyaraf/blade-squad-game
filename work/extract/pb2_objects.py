#!/usr/bin/env python3
"""Export the tables that decide how an object leaves the screen.

Two things stand between a thing being in the table and getting a turn: the
class it belongs to for the purpose of being thrown away, and the margins that
class allows it past the edge.  Both are plain tables in bank 10; see section
10 of work/re/pb2_spawns.md.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import outdir, write_json, TOOLS                     # noqa: E402
sys.path.insert(0, TOOLS)
import pb2_spawns                                                # noqa: E402

NTYPES = 90                 # $8212 is exactly 90 bytes long
# $E5B1 in the fixed bank: which bit of $2B/$2C a collectable answers to.
# $E534 masks the record's top nibble with $0F and indexes this, so sixteen
# bytes are read even though only the first eight are bits.
PICKUP_BITS = 0xE5B1
NPICKUP = 16
CLASSES = 0x8212
MARGINS = 0x820A            # four pairs: how far past the left / right edge

# $814A / $8152 -- the eight class handlers, and what each of them checks.
# The two checks are not "along the level" and "across" it: whichever way the
# level runs, one reads the pair of bytes that hold the place across the screen
# ($04F2 / $0508) and the other the pair that hold it down the screen ($04B0 /
# $04C6).  A number names a pair in `cull_margin`; the words are the special
# rules:
#   'none'  -- never thrown away                             ($8148)
#   'page'  -- gone the moment either high byte is not zero   ($8172)
#   'drop'  -- $81BD: below the screen at once, above it 32 points of grace
#   'floor' -- $81EF: as 'drop', and also gone at $D0 while still on screen
CLASS_RULES = [
    dict(handler=0x815A, horiz=0, vert='drop'),
    dict(handler=0x8162, horiz=2, vert='drop'),
    dict(handler=0x816A, horiz=0, vert=0),
    dict(handler=0x8148, horiz='none', vert='none'),
    dict(handler=0x8172, horiz='page', vert='page'),
    dict(handler=0x817E, horiz=0, vert=2),
    dict(handler=0x8186, horiz=4, vert='floor'),
    dict(handler=0x818E, horiz=6, vert=6),
]


def export():
    rom = pb2_spawns.Rom()
    b10 = rom.bank(10)
    b15 = rom.bank(15)
    pickup = list(b15[PICKUP_BITS - 0xE000:PICKUP_BITS - 0xE000 + NPICKUP])
    classes = list(b10[CLASSES - 0x8000:CLASSES - 0x8000 + NTYPES])
    margins = list(b10[MARGINS - 0x8000:MARGINS - 0x8000 + 8])
    d = outdir('pb2')
    size = write_json(os.path.join(d, 'objects.json'), dict(
        cull_class=classes,
        # Read in pairs, one pair per Y of 0, 2, 4 and 6.  Off the near side
        # a thing is kept while its low byte is >= the first of the pair; off
        # the far side, while the low byte is < the second.
        cull_margin=margins,
        cull_rules=CLASS_RULES,
        # $E5B1: which bit of $2B / $2C a collectable answers to.  Only the
        # first eight are bits; the rest is whatever follows in the bank, and
        # is carried across because $E534 can reach it.
        pickup_bit=pickup,
    ))
    print('%d types, %d classes, %d bytes'
          % (NTYPES, len(set(classes)), size))


if __name__ == '__main__':
    export()
