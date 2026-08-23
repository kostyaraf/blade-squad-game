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
# $8401 in bank 10: which picture a collectable wears.  $83F2 masks the record's
# third byte with $0F and indexes this; the run ends at $8409, which is the RTS
# the mind jumps to, so there are eight.
PICKUP_PIC = 0x8401
NPICKUP_PIC = 8
CLASSES = 0x8212
MARGINS = 0x820A            # four pairs: how far past the left / right edge

# The runs of pictures a thing walks through.  $E2D5 switches to bank pair 6/7
# and reads the table's address out of $802D there, so the table is in bank 6,
# not in the bank the mind itself lives in.  It is a table of words, and the
# first word is the address of the first record, so the count is the distance
# between them halved.
ANIM_PTR = 0x802D
# A record is three bytes -- last step, how many frames a step is held, the
# picture of the first step -- and the pictures of the rest follow it in order.
# When the top bit of the first byte is set the record is four, and the fourth
# says which run of offsets ($E39C in the fixed bank) the pictures come from
# instead.
ANIM_OFFSETS = 0xE39C

# Tables the minds read straight out of their own bank.
SWING = 0x9D72      # $19: how long it walks one way, by the record's nibble
SPIN_LO = 0x9EE1    # $10: eight turning speeds, low byte
SPIN_HI = 0x9EE9    # and high
TRIG = 0xF301       # $F2E6: a quarter turn of cosine, 65 entries

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


def anims(rom):
    """Every run of pictures, as {last, hold, first} and, for the long ones,
    the list of offsets that stands in for a plain run."""
    b6 = rom.bank(6)
    b7 = rom.bank(7)
    b15 = rom.bank(15)

    def byte(a):
        return b6[a - 0x8000] if a < 0xA000 else b7[a - 0xA000]

    def word(a):
        return byte(a) | (byte(a + 1) << 8)

    table = word(ANIM_PTR)
    count = (word(table) - table) // 2
    out = []
    for i in range(count):
        a = word(table + 2 * i)
        last = byte(a)
        rec = dict(last=last & 0x7F, hold=byte(a + 1), first=byte(a + 2))
        if last & 0x80:
            # $E374: the fourth byte picks a run of offsets, and the picture is
            # the first plus the offset of the step -- so the steps need not be
            # one after another.  The run is as long as the record has steps.
            which = byte(a + 3)
            lo = ANIM_OFFSETS - 0xE000 + 2 * which
            at = b15[lo] | (b15[lo + 1] << 8)
            rec['steps'] = list(b15[at - 0xE000:
                                    at - 0xE000 + (last & 0x7F) + 1])
        out.append(rec)
    return out


def export():
    rom = pb2_spawns.Rom()
    b10 = rom.bank(10)
    b15 = rom.bank(15)
    pickup = list(b15[PICKUP_BITS - 0xE000:PICKUP_BITS - 0xE000 + NPICKUP])
    classes = list(b10[CLASSES - 0x8000:CLASSES - 0x8000 + NTYPES])
    margins = list(b10[MARGINS - 0x8000:MARGINS - 0x8000 + 8])
    runs = anims(rom)
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
        pickup_pic=list(b10[PICKUP_PIC - 0x8000:
                            PICKUP_PIC - 0x8000 + NPICKUP_PIC]),
        anims=runs,
        # $9D72, read by the low nibble of the record's byte.  Only a few of
        # the sixteen are ever asked for; the rest is whatever follows in the
        # bank, and is carried across because the nibble can reach it.
        swing=list(b10[SWING - 0x8000:SWING - 0x8000 + 16]),
        # $9EE1 and $9EE9: how fast the one that circles turns, by the low
        # three bits of the record's byte.  The pair is one signed number.
        spin_lo=list(b10[SPIN_LO - 0x8000:SPIN_LO - 0x8000 + 8]),
        spin_hi=list(b10[SPIN_HI - 0x8000:SPIN_HI - 0x8000 + 8]),
        # $F301: sixty-five points of a quarter turn.  The first two are never
        # read -- $F2E6 answers the whole length for those -- but they are
        # kept so the table is indexed as the cartridge indexes it.
        trig=list(b15[TRIG - 0xE000:TRIG - 0xE000 + 65]),
    ))
    print('%d types, %d classes, %d runs of pictures, %d bytes'
          % (NTYPES, len(set(classes)), len(runs), size))


if __name__ == '__main__':
    export()
