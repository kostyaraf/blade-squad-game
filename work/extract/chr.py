#!/usr/bin/env python3
"""Export every tile of a ROM as one sheet of colour indices.

The sheet is a grey picture whose only values are 0, 85, 170 and 255 -- the
four colours a tile can name.  Nothing here decides what those colours look
like; that is the palette's job, and it changes while the game runs.
"""
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import (NES_RGB, ROM_PB2, ROM_SOL, SHEET_W, outdir, tile_pixels,
                    write_json, TOOLS, OUT)                    # noqa: E402
sys.path.insert(0, TOOLS)
from m6502 import Rom                                          # noqa: E402

STEP = 85              # what one colour index is worth in the exported grey


def sheet(chr_bytes):
    n = len(chr_bytes) // 16
    rows = (n + SHEET_W - 1) // SHEET_W
    img = Image.new('L', (SHEET_W * 8, rows * 8))
    px = img.load()
    for t in range(n):
        tx, ty = (t % SHEET_W) * 8, (t // SHEET_W) * 8
        pix = tile_pixels(chr_bytes, t)
        for y in range(8):
            for x in range(8):
                px[tx + x, ty + y] = pix[y * 8 + x] * STEP
    return img, n


def export(name, rom_path):
    rom = Rom(rom_path)
    d = outdir(name)
    img, n = sheet(rom.chr)
    img.save(os.path.join(d, 'tiles.png'))
    write_json(os.path.join(d, 'chr.json'), {
        'tiles': n,
        'sheet_width': SHEET_W,
        'banks_1k': len(rom.chr) // 1024,
        'step': STEP,
    })
    print('%-8s %5d tiles  %dx%d  tiles.png' % (name, n, img.width, img.height))


def main():
    os.makedirs(OUT, exist_ok=True)
    write_json(os.path.join(OUT, 'nes_palette.json'),
               {'rgb': ['%06X' % c for c in NES_RGB]})
    export('pb2', ROM_PB2)
    export('sol', ROM_SOL)


if __name__ == '__main__':
    main()
