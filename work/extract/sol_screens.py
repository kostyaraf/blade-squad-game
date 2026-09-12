#!/usr/bin/env python3
"""Export Solbrain's screens: the title, the tale, the picking screen and the
rest of what is drawn while the picture is off.

A stage's background comes out of the level data; a screen does not.  A screen
is a little stream of commands, and $9607 in bank four walks it straight into
the console's own name map.  One command is a byte:

    bit 7  what comes next goes down the screen, not across it
    bit 6  two bytes follow: the place to write, high byte first
    bit 5  the bytes to write are not here -- take them from the canned block
           whose number is in the low five bits, where the first byte is how
           many there are
    0..4   otherwise, how many bytes follow

A command of nought ends the stream.  $9850 holds a pointer per screen and
$9696 the thirty two canned blocks -- runs of sky, of black, of the same tile
over and over -- that the streams lean on instead of spelling them out.

What comes out here is, for every screen, the two name maps as the console
would hold them: thirty two by thirty tiles and sixty four bytes of colour
each.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import ROM_SOL, outdir, write_json                  # noqa: E402

BANK = 4                  # the pair the screens live in: four at $8000, five
                          # at $A000
TABLE = 0x9850            # a pointer per screen
SCREENS = 40
CANNED = 0x9696           # thirty two blocks, a pointer each
CANNED_N = 32


class Rom:
    def __init__(self, prg, bank):
        self.lo = prg[bank * 0x2000:(bank + 1) * 0x2000]
        self.hi = prg[(bank + 1) * 0x2000:(bank + 2) * 0x2000]

    def __getitem__(self, a):
        return self.lo[a - 0x8000] if a < 0xA000 else self.hi[a - 0xA000]

    def word(self, a):
        return self[a] | self[a + 1] << 8


def draw(rom, at, vram, limit=4096):
    """Walk one stream into `vram`, which is the console's own two kilobytes."""
    addr = 0
    step = 1
    for _ in range(limit):
        cmd = rom[at]
        at += 1
        if cmd == 0:
            return at
        step = 32 if cmd & 0x80 else 1
        if cmd & 0x40:
            addr = (rom[at] << 8 | rom[at + 1])
            at += 2
        n = cmd & 0x1F
        if cmd & 0x20:
            src = rom.word(CANNED + 2 * n)
            n = rom[src]
            src += 1
            for _ in range(n):
                put(vram, addr, rom[src])
                src += 1
                addr += step
        else:
            if n == 0:
                return at
            for _ in range(n):
                put(vram, addr, rom[at])
                at += 1
                addr += step
    raise RuntimeError('the stream at $%04X never ended' % at)


def put(vram, addr, v):
    # $2000..$2FFF, and the console has only two kilobytes of it.
    a = addr & 0x0FFF
    if a < 0x0800:
        vram[a] = v


def main():
    with open(ROM_SOL, 'rb') as f:
        prg = f.read()[16:]
    rom = Rom(prg, BANK)
    seen = {}
    out = []
    for i in range(SCREENS):
        at = rom.word(TABLE + 2 * i)
        if at not in seen:
            vram = bytearray(0x0800)
            draw(rom, at, vram)
            seen[at] = {
                'at': at,
                'maps': [list(vram[0:0x3C0]), list(vram[0x400:0x7C0])],
                'attr': [list(vram[0x3C0:0x400]), list(vram[0x7C0:0x800])],
            }
        out.append(at)
    data = {
        'screens': out,
        'streams': {'%04X' % a: s for a, s in seen.items()},
    }
    size = write_json(os.path.join(outdir('sol'), 'screens.json'), data)
    print('%d screens, %d streams, %d bytes' % (SCREENS, len(seen), size))


if __name__ == '__main__':
    main()
