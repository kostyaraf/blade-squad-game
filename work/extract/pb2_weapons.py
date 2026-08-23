#!/usr/bin/env python3
"""Export what the hero throws, straight out of the cartridge.

Two weapons share one set of tables.  Without a suit he throws the blade that
comes back ($A298, types 1 and 2); with one he fires the beam ($A37F, type 3).
Every number below is read from the address the code reads it from, and
`work/re/pb2_weapons.md` says where each came from.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import ROM_PB2, outdir, write_json                   # noqa: E402

BANK = 0x2000


def bank(rom, n):
    return rom[16 + n * BANK: 16 + (n + 1) * BANK]


def export():
    rom = open(ROM_PB2, 'rb').read()
    b9, b14 = bank(rom, 9), bank(rom, 14)

    def a9(addr, n=1):
        return list(b9[addr - 0xA000: addr - 0xA000 + n])

    def a14(addr, n=1):
        return list(b14[addr - 0xC000: addr - 0xC000 + n])

    # --- where the throw comes out of him -------------------------------
    # $A4FD: the pose $A403 chose says how far up and how far along from him
    # the new thing is put.  The step along is turned about when he faces left.
    spawn_dy = a9(0xA545, 15)
    spawn_dx = a9(0xA554, 15)

    # --- how hard the blade is thrown -----------------------------------
    # $A2AE: type (1 or 2) times eight and the world times two index a table
    # of pointers at $A84D; each of the four they point at holds one speed for
    # each of the four steps of the hold, low byte first.
    ptr = a9(0xA84D, 32)
    throw = []
    for t in (1, 2):
        rows = []
        for w in range(4):
            y = t * 8 + w * 2
            p = ptr[y] | (ptr[y + 1] << 8)
            row = a9(p, 8)
            rows.append([row[i * 2] | (row[i * 2 + 1] << 8) for i in range(4)])
        throw.append(rows)

    # --- and how it bends in the air ------------------------------------
    # $A5A7: the same eight of the type, or sixteen once it has turned about,
    # plus the way it was thrown.  Four bytes make the two speeds it gains
    # each step: along the level, then down it, low byte first.
    accel = []
    for y in range(24):
        accel.append([a9(0xA8BD + y)[0], a9(0xA8CD + y)[0],
                      a9(0xA89D + y)[0], a9(0xA8AD + y)[0]])

    # --- the beam -------------------------------------------------------
    # $A38C: one picture, one speed and one gain for each of the eight ways.
    beam_tile = a9(0xA8E5, 8)
    beam_v = [[a9(0xA905 + i)[0], a9(0xA90D + i)[0],
               a9(0xA915 + i)[0], a9(0xA91D + i)[0]] for i in range(8)]
    beam_a = [[a9(0xA925 + i)[0], a9(0xA92D + i)[0],
               a9(0xA935 + i)[0], a9(0xA93D + i)[0]] for i in range(8)]
    # $A3AD: the world picks one of four rows and the step of the hold picks
    # the byte in it -- how many steps the beam lasts.
    bptr = a9(0xA8ED, 8)
    beam_life = [a9(bptr[w * 2] | (bptr[w * 2 + 1] << 8), 4) for w in range(4)]

    # --- holding the button ---------------------------------------------
    # $D23A: once every four pictures, up to the world's own ceiling.
    hold_cap = a14(0xD255, 4)
    # $D8F1: four bytes a world, laid at $8C..$8F.  $8D, $8E and $8F are the
    # three marks the hold is measured against; $8C nothing reads.
    cptr = a14(0xD90C, 8)
    hold_mark = [a14(cptr[w * 2] | (cptr[w * 2 + 1] << 8), 4) for w in range(4)]

    write_json(os.path.join(outdir('pb2'), 'weapons.json'), dict(
        spawn_dy=spawn_dy, spawn_dx=spawn_dx,
        throw=throw, accel=accel,
        beam_tile=beam_tile, beam_v=beam_v, beam_a=beam_a,
        beam_life=beam_life,
        hold_cap=hold_cap, hold_mark=hold_mark,
    ))


if __name__ == '__main__':
    export()
