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
ANIMS = (12, 0x80B2)        # bank 12, the object animation set (the fifth)
N_ANIMS = 128               # what the word list holds before the steps start
ANIMS3 = (12, 0x8065)       # the fourth set, which a few minds reach for instead
N_ANIMS3 = 38               # as many as fit before the fifth set begins
ANIMS1 = (13, 0xBDB9)       # the second set, which the hero's satellite wears
N_ANIMS1 = 38               # as many as the word list holds before the steps
BORN = (8, 0x8096)          # $8072 + $24 -- the ring the spawner reads
GONE = (14, 0xCEDE)     # $CEBA + $24 -- the ring the frame walk reads
RING = 72                   # six rows of twelve; rows 0..2 and 9..11 are never read
HATCH = (3, 0xAB77)         # bank 3, $AB10 -- what a behaviour may let out
N_HATCH = 0x120             # nine bytes a template, same order as the types;
                            # $EA is the last index anything asks for
HATCH2 = (12, 0x8D14)       # bank 12, $8C83/$8CAA -- the other one, which fills
N_HATCH2 = 0x60             # the first free slot counting up rather than down;
                            # $24 is the last index anything asks for
ARCTAN = (12, 0x8ED2)       # bank 12, $8E99 -- two lengths become a heading
N_ARCTAN = 0x100
STEPS = (12, 0x9060)        # bank 12, $8FF6 -- how far a heading carries a thing
N_STEPS = 0x100             # sixteen headings a row, and sixteen rows of speed

# What the nine bytes are, in the order $AF20 writes them.
FIELDS = ('mind', 'pic_lo', 'pic_hi', 'a', 'b', 'c', 'd', 'kind', 'life')


def bank(rom, n):
    return rom[16 + n * 0x2000: 16 + (n + 1) * 0x2000]


def at(rom, where, n):
    b, addr = where
    off = addr & 0x1FFF
    return bank(rom, b)[off:off + n]


def anims(rom, where=None, count=None):
    """$8026 in bank 12 -- one animation set, and the steps each of its ids holds.

    A step is three bytes: how many pictures to hold it for, and the two bytes
    of the picture.  A hold of zero is not a step; it means "start again".  A
    hold of $FF is the last one: it is held and never left.
    """
    where = where or ANIMS
    count = count or N_ANIMS
    b = bank(rom, where[0])
    base = where[1] & 0x1FFF
    out = []
    for i in range(count):
        p = (b[base + i * 2] | b[base + i * 2 + 1] << 8) & 0x1FFF
        steps = []
        while b[p] and len(steps) < 64:
            steps.append([b[p], b[p + 1], b[p + 2]])
            last = b[p] == 0xFF
            p += 3
            if last:
                break
        out.append(steps)
    return out


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
        # $80B2 -- the pictures an object walks through, one list per id.
        anims=anims(rom),
        # $8065 -- the fourth set; $8985 in bank 2 hands $BDAB a three, not a
        # four, so a handful of behaviours wear these pictures instead.
        anims3=anims(rom, ANIMS3, N_ANIMS3),
        # $BDB9 -- the second set.  $8DA6 and $8DD6 both hand $8DEF a one, so
        # everything in the hero's own four slots wears these pictures.
        anims1=anims(rom, ANIMS1, N_ANIMS1),
        # $AB77 -- nine bytes apiece, but reached by a plain byte offset, so
        # they are kept as bytes and read out where a behaviour asks.
        hatch=[int(v) for v in at(rom, HATCH, N_HATCH)],
        # $8D14 -- the same nine bytes in the same order, but read by $8CAA,
        # which takes the first free slot counting up from nought.
        hatch2=[int(v) for v in at(rom, HATCH2, N_HATCH2)],
        # $9060 -- a quarter circle: a heading and a speed become a step along
        # and a step down.  $8FF6 reads it twice, once each way round.
        steps=[int(v) for v in at(rom, STEPS, N_STEPS)],
        # $8ED2 -- sixteen by sixteen: how far round a heading lies once the
        # two lengths have been squeezed into a nibble each.
        arctan=[int(v) for v in at(rom, ARCTAN, N_ARCTAN)],
    )
    d = outdir('sol')
    path = os.path.join(d, 'objects.json')
    n = write_json(path, obj)
    print('objects.json  %d types, %d animations, %d bytes'
          % (N_TYPES, N_ANIMS, n))


if __name__ == '__main__':
    export()
