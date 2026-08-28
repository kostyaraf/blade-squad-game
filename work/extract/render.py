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


def spr_frame(tiles, dump, bg, rows=240):
    """The sprites, drawn over `bg` the way the console draws them.

    Power Blade 2 runs the console in its tall-sprite mode ($2000 bit five), so
    a place in the table is eight wide and sixteen down, and the lowest bit of
    its tile number -- not $2000 bit three -- says which half of the tile
    memory it comes out of.

    Only eight sprites are drawn on any one line, and they are looked for in
    the order they stand in the table; that is why the game shuffles where in
    the table it writes them ($8038 adds $44 to $28 every picture), and why
    what is drawn flickers when there is too much of it.
    """
    img = bg.copy()
    px = img.load()
    tall = 16 if (dump.ctrl & 0x20) else 8
    for y in range(rows):
        s = vramdump.scanline(dump, y)
        if not (s['mask'] & 0x10):                  # sprites switched off
            continue
        row = []
        for i in range(64):
            top = dump.oam[i * 4] + 1
            if top <= y < top + tall:
                row.append(i)
                if len(row) == 8:                   # the console draws no more
                    break
        # The one in front wins, and the one in front is the one that stands
        # earlier in the table, so a pixel once painted is left alone.
        drawn = [False] * 256
        for i in row:
            top = dump.oam[i * 4] + 1
            tile = dump.oam[i * 4 + 1]
            attr = dump.oam[i * 4 + 2]
            left = dump.oam[i * 4 + 3]
            fine = y - top
            if attr & 0x80:                         # turned upside down
                fine = tall - 1 - fine
            if tall == 16:
                base = 0x1000 if (tile & 1) else 0x0000
                index = (tile & 0xFE) + (1 if fine >= 8 else 0)
                fine &= 7
            else:
                base = 0x1000 if (dump.ctrl & 0x08) else 0x0000
                index = tile
            bank = s['chr'][(base // 0x400) + index // 64]
            line = tiles.at(bank, index % 64)
            for dx in range(8):
                x = left + dx
                if not (0 <= x < 256):
                    continue
                if x < 8 and not (s['mask'] & 0x04):
                    continue
                c = line[fine * 8 + (7 - dx if (attr & 0x40) else dx)]
                if c == 0 or drawn[x]:
                    continue
                drawn[x] = True
                if (attr & 0x20) and _bg_solid(tiles, dump, s, x, y):
                    continue                        # behind the background
                idx = s['pal'][0x10 + (attr & 3) * 4 + c]
                px[x, y] = tuple(NES_RGB[idx & 0x3F].to_bytes(3, 'big'))
    return img


def _bg_solid(tiles, dump, s, x, y):
    """Is the background at this pixel one of the three colours that hide a
    sprite marked as being behind it?"""
    if not (s['mask'] & 0x08):
        return False
    if x < 8 and not (s['mask'] & 0x02):
        return False
    v, fx = s['v'], s['fine_x']
    base = 0x1000 if (s['ctrl'] & 0x10) else 0x0000
    fine_y = (v >> 12) & 7
    col = ((v & 0x1F) + (x + fx) // 8)
    nt = ((v >> 10) & 3) ^ ((col // 32) & 1)
    cx, cy = col % 32, (v >> 5) & 0x1F
    page = dump.nt(nt)
    t = page[cy * 32 + cx]
    bank = s['chr'][(base // 0x400) + t // 64]
    return tiles.at(bank, t % 64)[fine_y * 8 + (x + fx) % 8] != 0


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
