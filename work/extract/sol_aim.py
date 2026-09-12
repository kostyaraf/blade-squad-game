#!/usr/bin/env python3
"""Export the table Solbrain turns an angle into a step with.

Bank twelve's $8FF6 (reached through $C078) is handed an angle byte and gives
back a step: $90:$91 along and $92:$93 down.  It reads one quarter of a circle
out of the table at $9060 and mirrors it into the other three.

    low 4 bits      how far round the quarter, 0..15
    bit 4           swap the two, so the quarter is read backwards
    bits 5 and 4    which quarter:  00 right-down, 10 right-up,
                    20 left-up, 30 left-down (the two negations)
    $90 on the way in     which ring, sixteen bytes apart

The table is fifteen rings of sixteen bytes, $9060 to $914F, of radius $10 to
$F0.  Each ring starts at its own radius and falls to nearly nothing, and the
other half of the pair is read from the same ring backwards -- index `k` for
the one, `(k - 1) ^ 15` for the other, with nought when `k` is nought.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import ROM_SOL, outdir, write_json                  # noqa: E402

AIM_AT = 0x9060
RINGS = 15


def main():
    with open(ROM_SOL, 'rb') as f:
        prg = f.read()[16:]
    d = prg[12 * 0x2000: 12 * 0x2000 + 0x2000]
    ring = [d[AIM_AT - 0x8000 + i] for i in range(RINGS * 16)]
    out = dict(ring=ring)
    size = write_json(os.path.join(outdir('sol'), 'aim.json'), out)
    print('%d rings of 16, %d bytes' % (RINGS, size))


if __name__ == '__main__':
    main()
