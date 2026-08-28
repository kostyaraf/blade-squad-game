#!/usr/bin/env python3
"""Export the little pictures every thing in Power Blade 2 is drawn out of.

Bank 6, $8038, walks the twenty-two places once a picture and draws each one.
What it draws is named by field three ($0442) -- nought means "not drawn" --
and where that name leads depends on the place: the hero and the three throws
(places 0..5) read the pointers at $8148/$81B4, everything else the pointers
at $8C88/$8D83.  Both sets of pictures live in banks 6 and 7, which the
switcher hands over as a pair ($ECA7 with Y=$36).

A picture is a count and then that many little sprites, each of them:

    dy2   how far down, doubled, and the lowest bit says "the same colours as
          the one before" ($80B6: an arithmetic shift right, the bit shifted
          out kept in the carry)
    tile  which tile
    attr  the colours and the two flips -- left out when the lowest bit above
          was set
    dx    how far along

The three things the drawing does to `attr` are not baked in here, because
they are the thing's business and not the picture's: the thing's own two low
bits of $042C replace the picture's when they are not nought ($80DC), the
thing's $20 is added ($80E9), and the thing's $40 turns the picture's own
$40 about ($80EB).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import ROM_PB2, outdir, write_json                   # noqa: E402

BANK = 0x2000
# Banks 6 and 7 stand at $8000 and $A000 at the same time, so one window of
# sixteen kilobytes reads both.
BASE = 0x8000
# $8148/$81B4 -- one hundred and eight pictures for the hero and his throws;
# the data starts at $8220, right where the second table ends.
HERO_LO, HERO_HI, HERO_N = 0x8148, 0x81B4, 108
# $8C88/$8D83 -- two hundred and fifty-one for everything else; the data
# starts at $8E7E and the last of the pointers is the last that still points
# inside the pair of banks.
OBJ_LO, OBJ_HI, OBJ_N = 0x8C88, 0x8D83, 251
# $EF3F in bank 15 -- the kilobyte of tiles at $1000 is the hero's own, and
# which kilobyte it is his picture decides ($EF03 reads $0442).  A suit moves
# it six along, but only for the pictures that are his and not his machine's.
PLAYER_BANK, PLAYER_BANK_N = 0xEF3F, 62
# $D290 and $D294 -- the kilobyte at $1400 is one of two, by whether he has a
# suit on at all.
SUIT_BANK = (0x11, 0x12)


def _signed(v):
    return v - 0x100 if v >= 0x80 else v


def _asr(v):
    """$80B6 -- one shift right with the sign kept, and the bit shifted out."""
    s = _signed(v)
    return (s >> 1), (v & 1)


def _picture(mem, addr):
    """One little picture, read the way $80A9 reads it."""
    n = mem[addr - BASE]
    i = addr - BASE + 1
    out = []
    attr = 0
    for _ in range(n):
        dy, same = _asr(mem[i])
        i += 1
        tile = mem[i]
        i += 1
        if not same:
            attr = mem[i]
            i += 1
        dx = _signed(mem[i])
        i += 1
        out.append([dy, tile, attr, dx])
    return out


def _table(mem, lo, hi, n):
    out = []
    for i in range(n):
        p = mem[lo - BASE + i] | (mem[hi - BASE + i] << 8)
        out.append(_picture(mem, p))
    return out


def export():
    rom = open(ROM_PB2, 'rb').read()
    mem = rom[16 + 6 * BANK: 16 + 8 * BANK]
    b15 = rom[16 + 15 * BANK: 16 + 16 * BANK]
    write_json(os.path.join(outdir('pb2'), 'sprites.json'), dict(
        hero=_table(mem, HERO_LO, HERO_HI, HERO_N),
        objects=_table(mem, OBJ_LO, OBJ_HI, OBJ_N),
        player_bank=list(b15[PLAYER_BANK - 0xE000:
                             PLAYER_BANK - 0xE000 + PLAYER_BANK_N]),
        suit_bank=list(SUIT_BANK),
    ))


if __name__ == '__main__':
    export()
