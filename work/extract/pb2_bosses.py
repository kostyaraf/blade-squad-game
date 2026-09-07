#!/usr/bin/env python3
"""Export the boss rooms: who is put out in them and how the meter fills.

A boss room is an area of the seventh table ($79 not nought), and it holds one
thing and nothing else: type $05 for the six in the middle of a stage, type
$06 for the four at the end of one.  That thing makes the boss itself in place
fifteen, then stands and watches while the meter fills.

Everything here is read from where the code reads it: $8728 and $87B2 in bank
10 for the two triggers, $BDE9 and $BDBD in bank 11 for the shell all ten
bosses share, and $87F7..$88EB in bank 10 for the death they all die.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import ROM_PB2, outdir, write_json                   # noqa: E402

BANK = 0x2000


def bank(rom, n):
    return rom[16 + n * BANK: 16 + (n + 1) * BANK]


def s8(v):
    return v - 256 if v > 127 else v


def export():
    rom = open(ROM_PB2, 'rb').read()
    b7, b10, b11 = bank(rom, 7), bank(rom, 10), bank(rom, 11)

    def a7(addr, n=1):
        return list(b7[addr - 0xA000: addr - 0xA000 + n])

    def a10(addr, n=1):
        return list(b10[addr - 0x8000: addr - 0x8000 + n])

    def a11(addr, n=1):
        return list(b11[addr - 0xA000: addr - 0xA000 + n])

    out = dict(
        # $8739 writes the type at $040F, and the table is twenty-two places
        # of one byte a field, so that address names place fifteen.
        slot=((a10(0x873A)[0] | (a10(0x873B)[0] << 8)) - 0x0400) % 22,
        # $8737 -- the six in the middle are $50 + the area, $87C7 -- the four
        # at the end are $56 + the stage.
        mid_first=a10(0x8738)[0],
        end_first=a10(0x87C8)[0],
        # $873E..$8753: where the one in the middle stands, what it wears and
        # how full its meter goes.  Six of each, chosen by $9C.
        mid_x=a10(0x879A, 6),
        mid_y=a10(0x87A0, 6),
        mid_pic=a10(0x87A6, 6),
        mid_life=a10(0x87AC, 6),
        # $87C3..$87DB: the same for the four at the end, chosen by $53.  The
        # picture is not a table here: $87BE writes one number for all of them.
        end_x=a10(0x87E5, 6),
        end_y=a10(0x87EB, 6),
        end_life=a10(0x87F1, 6),
        end_pic=a10(0x87BF)[0],
        # $876A -- the meter fills by so much every so many pictures, and the
        # sound $C81C is given each time it does.
        bar_every=a10(0x876D)[0] + 1,
        bar_step=a10(0x877A)[0],
        bar_sound=a10(0x8771)[0],
        # $BDFE and $BE0F -- the shell every boss wears: it waits for the game
        # to be played again and then stands still for this many pictures
        # before its own mind is let go.
        wake_wait=a11(0xBE0B)[0],
        # $BDBD -- the four at the end keep their own six states and take the
        # death from the seventh on; $BDE9 -- the six in the middle keep two.
        mid_states=3,
        end_states=6,
        # $87F7 -- the death: the meter is put up again ($4E), the thing is
        # shaken through seven places, and each shake lasts this long.
        die_shake=a10(0x8808)[0],
        shake=[[s8(x), s8(y)] for x, y in
               zip(a10(0x8863, 14)[0::2], a10(0x8863, 14)[1::2])],
        die_sound=a10(0x8826)[0],
        # $8871 -- and then the health is given back, $10 of it ($2F), and
        # after that, on the last stage only, the suit's energy ($30).
        refill_life=a10(0x887E)[0],
        refill_energy=a10(0x88C9)[0],
        after_wait=a10(0x888B)[0],
        # $88B8 -- an extra life for a boss, on every stage but the last.
        life_sound=a10(0x88B9)[0],
        # $BC69 in bank 7 -- the one boss that is two things makes its other
        # half by copying its own place over another: LDX the place to write,
        # LDY the place to read.  After the copy $BC70 turns the copy round
        # and $BC78 gives it the picture it stands in.
        twin_slot=a7(0xBC6A)[0],
        twin_from=a7(0xBC6C)[0],
        twin_bits=a7(0xBC71)[0],
        twin_pic=a7(0xBC79)[0],
    )
    d = outdir('pb2')
    size = write_json(os.path.join(d, 'bosses.json'), out)
    print('bosses.json  %d bytes' % size)
    for k in ('mid_first', 'end_first', 'mid_x', 'mid_y', 'mid_pic',
              'mid_life', 'end_life', 'end_pic', 'bar_every', 'bar_step',
              'wake_wait', 'die_shake', 'shake', 'refill_life',
              'refill_energy', 'after_wait', 'twin_slot', 'twin_from',
              'twin_bits', 'twin_pic'):
        print('  %-14s %s' % (k, out[k]))


if __name__ == '__main__':
    export()
