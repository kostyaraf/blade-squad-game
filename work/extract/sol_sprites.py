#!/usr/bin/env python3
"""Export what Solbrain's hero is drawn out of.

Three tables, and each one leads to the next.

An animation is a little script.  Its number ($05B5 for the state's own, or
$05A5 when a state has asked for a named one) picks a pointer out of the
table at $BB65, and while the hero is hurt out of the table at $BBBD instead
($B7CE reads $05C2 and adds two to the index).  The script is three bytes a
step -- how long the step lasts, and the two bytes of the picture -- and a
length of nought sends it back to its first step ($B837).  A length of $FF
means the step never ends.  Beside it stands the little table at $B83E: when
the step count reaches its low four bits the animation lets something go, a
shot or an afterimage, which is the objects' business and not the picture's.

A picture is a number too ($05A6 and the low five bits of $05A7, and one more
when he faces left, $9463).  It picks a four-byte entry out of the table
whose address stands at $8004 of bank ten, which is $86FF:

    chr    which kilobyte of tiles this picture wants ($42,X, nought means
           "leave it alone" and bit seven means "do not draw at all")
    flags  turned into $9E ($F47A): $40 mirrors it left to right, $80 top to
           bottom, bits two and three say which of the four kilobytes the
           first byte is for, and the low two bits swap the colours
    block   where the picture itself stands

The picture is two lists walked side by side ($F4E2 with one index into both):
the first two bytes of the block point at a count and then that many
down/along pairs, and the block's own bytes from two onwards are the tile and
the colours of each little sprite.  The sprites are 8x16 -- which is why
mirroring top to bottom takes sixteen off the step down ($F4F7) and mirroring
left to right eight off the step along ($F563).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import ROM_SOL, outdir, write_json                   # noqa: E402

# Banks ten and eleven stand at $8000 and $A000 together, so one window of
# sixteen kilobytes reads both ($F421).
SPR_BANK, SPR_BASE = 10, 0x8000
# Banks twelve and thirteen, the same way -- the hero's own code and scripts.
ANI_BANK, ANI_BASE = 12, 0x8000

# $801C and $8020 of bank twelve: the plain scripts and the hurt ones.
SCRIPTS, SCRIPTS_N = 0xBB65, 44
HURT, HURT_N = 0xBBBD, 32
# $B83E -- when to let something go, one byte an animation.
LOOP, LOOP_N = 0xB83E, 36
# $8004 of bank ten -- where the pictures' own table stands.
TABLE_AT = 0x8004


def _signed(v):
    return v - 0x100 if v >= 0x80 else v


class Win(object):
    """Sixteen kilobytes of the cartridge, read where the console reads it."""

    def __init__(self, rom, bank, base):
        with open(rom, 'rb') as f:
            prg = f.read()[16:]
        self.d = prg[bank * 0x2000: bank * 0x2000 + 0x4000]
        self.base = base

    def b(self, a):
        return self.d[a - self.base]

    def w(self, a):
        return self.b(a) | (self.b(a + 1) << 8)


def scripts(win, at, n):
    """One table's worth of little scripts, read the way $B803 reads them."""
    out = []
    for i in range(n):
        p, steps = win.w(at + 2 * i), []
        while True:
            dur = win.b(p)
            if dur == 0:                       # $B80A -- back to the start
                break
            steps.append([dur, win.b(p + 1), win.b(p + 2)])
            p += 3
            if dur == 0xFF:                    # $B7DC -- and never moves on
                break
        out.append(steps)
    return out


def pictures(win):
    """Every picture the hero's banks hold, read the way $F461 reads them."""
    base = win.w(TABLE_AT)
    # The table runs up to the first picture it points at: the data begins
    # where the pointers end.
    end = 0x10000
    i = 0
    while base + i * 4 < end:
        p = win.w(base + i * 4 + 2)
        if base < p < end:
            end = p
        i += 1
    out = []
    for k in range(i):
        e = base + k * 4
        chr_bank, flags, block = win.b(e), win.b(e + 1), win.w(e + 2)
        if not (base <= block < 0xC000):       # picture nought is no picture
            out.append(dict(chr=chr_bank, flags=flags, parts=[]))
            continue
        geom = win.w(block)
        n = win.b(geom)
        parts = [[_signed(win.b(geom + 1 + 2 * j)),     # down
                  _signed(win.b(geom + 2 + 2 * j)),     # along
                  win.b(block + 2 + 2 * j),             # tile
                  win.b(block + 3 + 2 * j)]             # colours
                 for j in range(n)]
        out.append(dict(chr=chr_bank, flags=flags, parts=parts))
    return out, base, end


def main():
    ani = Win(ROM_SOL, ANI_BANK, ANI_BASE)
    spr = Win(ROM_SOL, SPR_BANK, SPR_BASE)
    pics, base, end = pictures(spr)
    obj = dict(
        scripts=scripts(ani, SCRIPTS, SCRIPTS_N),
        hurt=scripts(ani, HURT, HURT_N),
        loop=[ani.b(LOOP + i) for i in range(LOOP_N)],
        pictures=pics,
    )
    d = outdir('sol')
    size = write_json(os.path.join(d, 'hero.json'), obj)
    print('%d scripts, %d hurt, %d pictures ($%04X..$%04X), %d bytes'
          % (SCRIPTS_N, HURT_N, len(pics), base, end, size))


if __name__ == '__main__':
    main()
