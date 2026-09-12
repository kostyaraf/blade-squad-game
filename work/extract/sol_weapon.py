#!/usr/bin/env python3
"""Export the tables Solbrain throws a weapon into the $0700 pool with.

Bank thirteen's $AEBD is the only way anything gets into that pool.  It is
handed the kind of weapon in A and the slot of whoever is throwing it in X,
and it reads twenty two rows of tables to decide where the new thing starts,
how fast it goes and how much it can go through.

    $B152   which slot of the pool to try first; the search then counts down
    $AFDC   how many things it may go through before it gives up

Then one of two halves, chosen by bit 7 of $05CB:

    clear   $AF84 step along, $AFB0 step down
    set     $AF9A step along, $AFC6 step down

and one of four sets of starting offsets, chosen by that same bit and by
whether $05A2 -- how the thrower is standing -- is three:

    clear, three      $AFF2 $B01E along,  $B04A $B076 down
    clear, otherwise  $B0A2 $B0CE along,  $B0FA $B126 down
    set,   three      $B008 $B034 along,  $B060 $B08C down
    set,   otherwise  $B0B8 $B0E4 along,  $B110 $B13C down

The offset along is negated when the thrower faces left ($0680,X bit 7), and
then $AE8A adds both offsets to the thrower's own place and fills the slot.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import ROM_SOL, outdir, write_json                  # noqa: E402

KINDS = 22

# name in the export -> where the row lives in bank thirteen
ROWS = [
    ('slot', 0xB152), ('pen', 0xAFDC),
    ('vx', 0xAF84), ('vy', 0xAFB0),
    ('alt_vx', 0xAF9A), ('alt_vy', 0xAFC6),
    ('dx_lo_3', 0xAFF2), ('dx_hi_3', 0xB01E),
    ('dy_lo_3', 0xB04A), ('dy_hi_3', 0xB076),
    ('dx_lo', 0xB0A2), ('dx_hi', 0xB0CE),
    ('dy_lo', 0xB0FA), ('dy_hi', 0xB126),
    ('alt_dx_lo_3', 0xB008), ('alt_dx_hi_3', 0xB034),
    ('alt_dy_lo_3', 0xB060), ('alt_dy_hi_3', 0xB08C),
    ('alt_dx_lo', 0xB0B8), ('alt_dx_hi', 0xB0E4),
    ('alt_dy_lo', 0xB110), ('alt_dy_hi', 0xB13C),
]


def main():
    with open(ROM_SOL, 'rb') as f:
        prg = f.read()[16:]
    d = prg[13 * 0x2000: 13 * 0x2000 + 0x2000]
    out = {}
    for name, at in ROWS:
        out[name] = [d[at - 0xA000 + i] for i in range(KINDS)]
    # The two offsets are signed sixteen-bit pairs; they are kept as they lie
    # in the cartridge so that the engine can add them the same way.
    out['kinds'] = KINDS
    size = write_json(os.path.join(outdir('sol'), 'weapon.json'), out)
    print('%d kinds, %d rows, %d bytes' % (KINDS, len(ROWS), size))


if __name__ == '__main__':
    main()
