#!/usr/bin/env python3
"""Export the tables the password screen is made of -- $9672, pair nought.

Twelve places, an octal digit in each, and nine bits of game hidden under a
sum, a shuffle and an offset.  The reading is `work/re/pb2_password.md`; what
is exported here is only what the screen reads out of the cartridge, and every
address is named where it stands.

The picture itself is not here: the screen is two streams out of the table at
$CBCC, which `pb2_screens.py` already exports, and its colours are record $15
of the palette loader, which is in the same file.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', 'tools'))
from common import ROM_PB2, outdir, write_json                   # noqa: E402
from m6502 import Rom                                            # noqa: E402

# How many places there are, and how wide the field stands: $9899 walks $51 to
# $0B and $98B6 steps it by four.
PLACES = 12
ACROSS = 4
# $9AFD -- one constant a place, taken off the typed digit by $9B09 and put
# back by $9AE9.
OFFSET = 0x9AFD
# $9B74 -- sixteen words, and the four they name in turn; $9B68 is the one the
# code $1F uses instead.  A perm says where in the laid-out field the i-th
# typed place belongs: $9BFC writes $0680[perm[i]] from $0690[i].
PERM_TBL, PERM_N = 0x9B74, 16
PERM_ODD = 0x9B68
# $9928 and $9934 -- where a place stands on the screen, along and down.
CARET_X, CARET_Y = 0x9928, 0x9934
# $99A3 -- eight pictures of a digit, four tiles each: two across and two
# down, the second row a whole name-table row ($20) further on.
DIGIT_TBL, DIGITS, DIGIT_TILES = 0x99A3, 8, 4
# $99D3 -- and where each place is written, high byte first ($9952 reads the
# high one and $9958 the low).
WHERE, WHERE_STEP = 0x99D3, 0x20
# $9870 -- the two rows the caret stands on while a password is being shown.
SHOWN_Y = 0x9870
# $9914, $985D -- what the caret is on the two halves of the screen.
KIND_TYPED, KIND_SHOWN = 0x59, 0x5A
# $803E is handed $15 at $96B7 and $9774, and $C84C is handed $16 at $96AC:
# the colours and the stream, both of which live in `screens.json`.
PALETTE, SCREEN = 0x15, 0x16
# $9693 -- the four banks the screen is drawn out of: $42/$43 background,
# $44..$47 sprites.
BG = (0x0E, 0x0F)
SPR = (0x00, 0x01, 0x10, 0x10)


def main():
    rom = Rom(ROM_PB2)
    b = rom.bank(0) + rom.bank(1)

    def at(a):
        return b[a - 0x8000]

    def word(a):
        return at(a) | (at(a + 1) << 8)

    perms = []
    for i in range(PERM_N):
        p = word(PERM_TBL + i * 2)
        perms.append([at(p + k) for k in range(PLACES)])
    doc = dict(
        places=PLACES,
        across=ACROSS,
        offset=[at(OFFSET + i) for i in range(PLACES)],
        perm=perms,
        perm_odd=[at(PERM_ODD + i) for i in range(PLACES)],
        caret_x=[at(CARET_X + i) for i in range(PLACES)],
        caret_y=[at(CARET_Y + i) for i in range(PLACES)],
        caret_kind=KIND_TYPED,
        shown_kind=KIND_SHOWN,
        shown_y=[at(SHOWN_Y), at(SHOWN_Y + 1)],
        digit=[[at(word(DIGIT_TBL + d * 2) + k) for k in range(DIGIT_TILES)]
               for d in range(DIGITS)],
        # The address is kept as the cartridge keeps it, so that the port
        # writes where the cartridge writes and not where a reader thinks it
        # ought to.
        where=[(at(WHERE + i * 2) << 8) | at(WHERE + i * 2 + 1)
               for i in range(PLACES)],
        where_step=WHERE_STEP,
        palette=PALETTE,
        screen=SCREEN,
        bg=list(BG),
        spr=list(SPR),
    )
    n = write_json(os.path.join(outdir('pb2'), 'password.json'), doc)
    print('offsets  %s' % ' '.join('%d' % v for v in doc['offset']))
    for i, p in enumerate(perms[:4]):
        print('perm %d   %s' % (i, ' '.join('%2d' % v for v in p)))
    print('perm $1F %s' % ' '.join('%2d' % v for v in doc['perm_odd']))
    print('places   %s' % ' '.join('%04X' % v for v in doc['where']))
    for d, tiles in enumerate(doc['digit']):
        print('digit %d  %s' % (d, ' '.join('%02X' % t for t in tiles)))
    print('%d bytes' % n)


if __name__ == '__main__':
    main()
