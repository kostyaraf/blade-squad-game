#!/usr/bin/env python3
"""Draw a level from the exported data, in Python.

This is the yardstick the Godot engine is measured against.  It earns that
role by having been measured itself: the pictures it draws were laid over
screenshots of both real games and matched pixel for pixel.
"""
import json
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import NES_RGB, OUT                                  # noqa: E402
from render import Tiles                                         # noqa: E402

PB2_ORIGIN_Y, PB2_VIEW_H = 16, 160     # the lines Power Blade 2 gives the level
SOL_ORIGIN_Y, SOL_VIEW_H = 0, 224      # ... and Solbrain

_cache = {}


def _tiles(game):
    if game not in _cache:
        _cache[game] = Tiles(game)
    return _cache[game]


def pb2_map(stage, area):
    """(tile, palette) for every tile of one area, and the area's size."""
    key = ('pb2map', stage, area)
    if key in _cache:
        return _cache[key]
    d = json.load(open(os.path.join(OUT, 'pb2', 'levels', 'stage%d.json' % stage)))
    a = d['areas'][area]
    screens, blocks, attrs = a['screens'], d['blocks'], d['attributes']
    sh = d['screens'][screens[0]]['h'] * 4
    vert = bool(a['vertical'])
    w = 32 if vert else 32 * len(screens)
    h = sh * len(screens) if vert else sh
    grid = [[(0, 0)] * w for _ in range(h)]
    for n, si in enumerate(screens):
        sc = d['screens'][si]
        ox = 0 if vert else n * 32
        oy = n * sh if vert else 0
        for br in range(sc['h']):
            for bc in range(8):
                b = sc['blocks'][br * 8 + bc]
                blk = blocks[b] if b < len(blocks) else [0] * 16
                at = attrs[b] if b < len(attrs) else 0
                for r in range(4):
                    for c in range(4):
                        quad = (r // 2) * 2 + (c // 2)
                        grid[oy + br * 4 + r][ox + bc * 4 + c] = (
                            blk[r * 4 + c], (at >> (quad * 2)) & 3)
    out = (grid, w, h, a['palette'], a['chr'][:4])
    _cache[key] = out
    return out


def sol_map(stage):
    key = ('solmap', stage)
    if key in _cache:
        return _cache[key]
    d = json.load(open(os.path.join(OUT, 'sol', 'levels', 'stage%d.json' % stage)))
    rooms, screens, blocks = d['rooms'], d['screens'], d['blocks']
    quads, props, alt = d['quads'], d['props'], d['alt']
    w = h = 16 * 32
    grid = [[None] * w for _ in range(h)]
    for ry in range(16):
        for rx in range(16):
            scr = rooms[ry][rx]
            # Row 0 of every room map is padding whose bytes are not screen
            # numbers at all; the game never looks there.
            if scr is None or scr >= len(screens):
                continue
            s = screens[scr]
            for br in range(8):
                for bc in range(8):
                    blk = blocks[s[br][bc]]
                    for hx in range(2):
                        for hy in range(2):
                            m = blk[hx * 2 + hy]
                            if props[m] & 0x20:
                                m = alt[m]
                            pal = props[m] >> 6
                            mx, my = rx * 16 + bc * 2 + hx, ry * 16 + br * 2 + hy
                            for tx in range(2):
                                for ty in range(2):
                                    grid[my * 2 + ty][mx * 2 + tx] = (
                                        quads[m][tx * 2 + ty], pal)
    c = d['chr']
    banks = [c[0] & 0xFE, (c[0] & 0xFE) + 1, c[1] & 0xFE, (c[1] & 0xFE) + 1]
    out = (grid, w, h, d['palette'], banks)
    _cache[key] = out
    return out


def _draw(game, grid, w, h, pal, banks, sx, sy, top, view_h):
    tiles = _tiles(game)
    img = Image.new('RGB', (256, 240), (0, 0, 0))
    px = img.load()
    back = tuple(NES_RGB[pal[0] & 0x3F].to_bytes(3, 'big'))
    for y in range(top, top + view_h):
        wy = sy + y - top
        for x in range(256):
            wx = sx + x
            cell = None
            if 0 <= wx // 8 < w and 0 <= wy // 8 < h:
                cell = grid[wy // 8][wx // 8]
            if cell is None:
                px[x, y] = back
                continue
            t, ph = cell
            c = tiles.at(banks[t // 64], t % 64)[(wy % 8) * 8 + wx % 8]
            idx = pal[0] if c == 0 else pal[ph * 4 + c]
            px[x, y] = tuple(NES_RGB[idx & 0x3F].to_bytes(3, 'big'))
    return img


def pb2_view(stage, area, sx, sy):
    grid, w, h, pal, banks = pb2_map(stage, area)
    return _draw('pb2', grid, w, h, pal, banks, sx, sy, PB2_ORIGIN_Y, PB2_VIEW_H)


def sol_view(stage, sx, sy):
    grid, w, h, pal, banks = sol_map(stage)
    return _draw('sol', grid, w, h, pal, banks, sx, sy, SOL_ORIGIN_Y, SOL_VIEW_H)
