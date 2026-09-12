#!/usr/bin/env python3
"""Export the boxes Solbrain touches things with.

Every picture in the game -- the hero's and everything else's -- carries two
bytes in bank eight's table at $8A19 ($814C reads them): what the touch means
and which box it is.  A box is eight bytes at $91B5: where it starts from the
thing's own place and how big it is, both in sixteenths of a pixel, the same
units a place is kept in.

    $814C   A = picture low + carry, Y = picture high
            $90:$91 = $8A19 + 2 * picture
            flags   = the first byte, returned in A
            $1A:$1B = $91B5 + 8 * the second byte

The meaning byte:

    bit 7   this is something to pick up, and the low three bits say which
    bit 6   it only hurts a hero who is not wearing the suit
    bit 5   it hurts for one whatever else it says
    low 4   how much it hurts

The third table is bank fourteen's at $CFF1: $CFBA reads it with the thing's
behaviour number and, where it answers nought, tests the hero against the
thing only on every other picture.  The table itself is twenty bytes long and
the code that follows it is read as more of the table whenever a behaviour is
numbered above nineteen -- so the whole hundred and twenty eight bytes are
taken here as they stand, which is what the console reads.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import ROM_SOL, outdir, write_json                  # noqa: E402

PICS = 974                 # as many as the picture table itself holds
PIC_AT = 0x8A19
BOX_AT = 0x91B5
SLOW_AT, SLOW_N = 0xCFF1, 128


def window(bank, base):
    with open(ROM_SOL, 'rb') as f:
        prg = f.read()[16:]
    d = prg[bank * 0x2000: bank * 0x2000 + 0x4000]
    return lambda a: d[a - base]


def main():
    b8 = window(8, 0x8000)
    b14 = window(14, 0xC000)
    pic = [[b8(PIC_AT + 2 * i), b8(PIC_AT + 2 * i + 1)] for i in range(PICS)]
    boxes = max(p[1] for p in pic) + 1
    box = [[b8(BOX_AT + 8 * k + 2 * j) | b8(BOX_AT + 8 * k + 2 * j + 1) << 8
            for j in range(4)]
           for k in range(boxes)]
    out = dict(pic=pic, box=box,
               slow=[b14(SLOW_AT + i) for i in range(SLOW_N)])
    d = outdir('sol')
    size = write_json(os.path.join(d, 'hits.json'), out)
    print('%d pictures, %d of them with a box, %d boxes, %d bytes'
          % (PICS, sum(1 for p in pic if p[1]), boxes, size))


if __name__ == '__main__':
    main()
