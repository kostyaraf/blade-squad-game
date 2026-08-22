#!/usr/bin/env python3
"""Draw a background frame the way the console would, from exported data.

This exists to be argued with: it takes the tile sheet and the palette that
the engine will use, plus the state the real machine was in on each scanline,
and produces a picture.  If that picture differs from a screenshot of the
game, the exported data is wrong -- and the difference says where.
"""
import json
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import NES_RGB, OUT, SHEET_W                        # noqa: E402
import vramdump                                                 # noqa: E402


class Tiles:
    """The exported sheet, read back as colour indices."""

    def __init__(self, game):
        d = os.path.join(OUT, game)
        img = Image.open(os.path.join(d, 'tiles.png')).convert('L')
        self.meta = json.load(open(os.path.join(d, 'chr.json')))
        step = self.meta['step']
        px = list(img.getdata())
        w = img.width
        self.tiles = []
        for t in range(self.meta['tiles']):
            tx, ty = (t % SHEET_W) * 8, (t // SHEET_W) * 8
            self.tiles.append(bytes(
                px[(ty + y) * w + tx + x] // step
                for y in range(8) for x in range(8)))

    def at(self, bank1k, index):
        """Tile `index` (0..63) of a 1 KB CHR bank."""
        return self.tiles[bank1k * 64 + index]


def bg_frame(tiles, dump, rows=240):
    """The background layer, 256 px wide, `rows` tall."""
    img = Image.new('RGB', (256, rows))
    px = img.load()
    for y in range(rows):
        s = vramdump.scanline(dump, y)
        if not (s['mask'] & 0x08):                  # background switched off
            continue
        v, fx = s['v'], s['fine_x']
        base = 0x1000 if (s['ctrl'] & 0x10) else 0x0000
        fine_y = (v >> 12) & 7
        for x in range(256):
            if x < 8 and not (s['mask'] & 0x02):
                # The console can hide the leftmost eight pixels of the
                # background, and both games use it to cover the seam the
                # scroll leaves there.
                px[x, y] = tuple(NES_RGB[s['pal'][0] & 0x3F].to_bytes(3, 'big'))
                continue
            # Walk the address the way the PPU does: coarse X advances with
            # the pixel, and crossing 32 columns flips the horizontal
            # nametable bit.
            col = ((v & 0x1F) + (x + fx) // 8)
            nt = ((v >> 10) & 3) ^ ((col // 32) & 1)
            cx, cy = col % 32, (v >> 5) & 0x1F
            page = dump.nt(nt)
            t = page[cy * 32 + cx]
            a = page[0x3C0 + (cy // 4) * 8 + cx // 4]
            quad = ((cy % 4) // 2) * 2 + ((cx % 4) // 2)
            pal_hi = (a >> (quad * 2)) & 3
            bank = s['chr'][(base // 0x400) + t // 64]
            c = tiles.at(bank, t % 64)[fine_y * 8 + (x + fx) % 8]
            idx = s['pal'][0] if c == 0 else s['pal'][pal_hi * 4 + c]
            px[x, y] = tuple(NES_RGB[idx & 0x3F].to_bytes(3, 'big'))
    return img


def sprite_mask(dump, rows=240):
    """Which pixels a sprite could have covered, so they can be excused."""
    big = 16 if (dump.ctrl & 0x20) else 8
    out = [[False] * 256 for _ in range(rows)]
    for i in range(64):
        y = dump.oam[i * 4] + 1
        x = dump.oam[i * 4 + 3]
        for dy in range(big):
            for dx in range(8):
                yy, xx = y + dy, x + dx
                if 0 <= yy < rows and 0 <= xx < 256:
                    out[yy][xx] = True
    return out
