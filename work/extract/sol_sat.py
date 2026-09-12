#!/usr/bin/env python3
"""Export the tables the hero's own four slots are driven by.

Slots $0C..$0F of the object pool are not things that were let into the stage:
they are the hero's satellite, what it throws in close, and his punch.  They
are walked by $A489 in bank twelve, which $9150 reaches every picture after
the hero himself and after the $0700 pool.

Everything here is read by that walk or by something under it.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import ROM_SOL, outdir, write_json                  # noqa: E402

# bank, address, how many bytes
ROWS = [
    # $A5C1 -- what the hero being busy does to his own four slots: nothing,
    # or one of three ways of standing the satellite somewhere else.
    ('mode',  13, 0xA5C1, 24),
    # $AE5F -- the satellite's bob, sixteen pictures of it.
    ('bob',  13, 0xAE5F, 16),
    # $ADEF and $ADF2 -- how far round it may be swung each way, and where it
    # drifts back to.  Two bytes apiece, read as $ADEF,Y and $ADF2,Y.
    ('arc',  13, 0xADEF, 6),
    # $A6B2 -- how far up the satellite is held while the hero is on his wire,
    # by which picture of him is up.  Four words, and the game reads past them
    # when the picture is not one of the four, so the code that follows is
    # carried along as well.
    ('wire',  13, 0xA6B2, 32),
    # $AB47 -- the fan of the fifth weapon, thirty two steps round.
    ('fan',  13, 0xAB47, 32),
    # $9337 and $933F -- the eight letter combinations and the weapon each one
    # gives; $932E, $9331 and $9334 are where the three letters are drawn and
    # which picture each of the four letters wears.
    ('combos', 12, 0x9337, 8),
    ('weapon_of', 12, 0x933F, 8),
    ('letter_x', 12, 0x932E, 3),
    ('letter_a', 12, 0x9331, 4),
    ('letter_b', 12, 0x9334, 4),
    # $B8F7 and $B927 -- where the seventh weapon's slash is put and what it
    # is.  Eight bytes a stance, two words of them, right then left.
    ('melee_at', 13, 0xB8F7, 48),
    ('melee_is', 13, 0xB927, 12),
]


def main():
    with open(ROM_SOL, 'rb') as f:
        prg = f.read()[16:]
    out = {}
    for name, b, at, n in ROWS:
        d = prg[b * 0x2000: (b + 1) * 0x2000]
        off = at & 0x1FFF
        out[name] = [d[off + i] for i in range(n)]
    size = write_json(os.path.join(outdir('sol'), 'sat.json'), out)
    print('%d rows, %d bytes' % (len(ROWS), size))


if __name__ == '__main__':
    main()
