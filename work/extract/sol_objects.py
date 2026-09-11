#!/usr/bin/env python3
"""Export Solbrain's object templates and the two rings around the screen.

An object in Solbrain is born from two halves.  The stage's own list says
*where* and *which spawn slot*; the type byte in that list picks a nine-byte
template out of a table in the cartridge, and the template says what the thing
actually is -- how it behaves, which picture it wears, how much life it has.

Alongside that go the two twelve-by-twelve rings the game reads to decide
whether a thing may come in and whether it must go away again.  Both cover
three screens across and three down in cells of 64 pixels, and only the ring
just outside the picture counts: inside it nothing is born, outside it nothing
is kept.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import ROM_SOL, outdir, write_json                   # noqa: E402

# Where the pieces live in the cartridge.
TEMPLATES = (9, 0xBDCA)     # bank 9, nine bytes a type
N_TYPES = 0x2F              # as many as the table holds; past that it is $FF filler
BORN = (8, 0x8096)          # $8072 + $24 -- the ring the spawner reads
GONE = (14, 0xCEDE)     # $CEBA + $24 -- the ring the frame walk reads
RING = 72                   # six rows of twelve; rows 0..2 and 9..11 are never read

# What the nine bytes are, in the order $AF20 writes them.
FIELDS = ('mind', 'pic_lo', 'pic_hi', 'a', 'b', 'c', 'd', 'kind', 'life')


def bank(rom, n):
    return rom[16 + n * 0x2000: 16 + (n + 1) * 0x2000]


def at(rom, where, n):
    b, addr = where
    off = addr & 0x1FFF
    return bank(rom, b)[off:off + n]


def export():
    rom = open(ROM_SOL, 'rb').read()
    tpl = at(rom, TEMPLATES, N_TYPES * 9)
    types = []
    for t in range(N_TYPES):
        r = tpl[t * 9:t * 9 + 9]
        types.append(dict(zip(FIELDS, [int(v) for v in r])))
    obj = dict(
        # $AF20 -- the nine bytes a type is made of.
        types=types,
        # $8059 -- what the spawner gets back: 0 anywhere, 1 left, 2 right or
        # below, 3 above, and a negative number for "nowhere near".
        born=[int(v) for v in at(rom, BORN, RING)],
        # $CE44 -- the same shape, but only the sign is read: negative means
        # the thing has left the picture and is taken away.
        gone=[int(v) for v in at(rom, GONE, RING)],
        ring=dict(cols=12, rows=12, first_row=3, last_row=8,
                  cell=0x40, origin=-0x100),
    )
    d = outdir('sol')
    path = os.path.join(d, 'objects.json')
    n = write_json(path, obj)
    print('objects.json  %d types, %d bytes' % (N_TYPES, n))


if __name__ == '__main__':
    export()
