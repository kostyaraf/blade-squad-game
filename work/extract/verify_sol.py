#!/usr/bin/env python3
"""Check the exported Solbrain data by drawing the level from it.

Solbrain scrolls in both directions, so there is no fixed relation between a
place in the world and a place in the console's nametable.  Instead of
reproducing the engine's bookkeeping, this draws the playfield straight from
the world -- room, screen, block, metatile, tile -- and lays the result over
a screenshot of the running game.
"""
import json
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import NES_RGB, OUT                                  # noqa: E402
from render import Tiles, sprite_mask                            # noqa: E402
from vramdump import VDump, scanline                             # noqa: E402

PLAYFIELD_H = 224              # the level owns this many lines; the rest is the bar


class World:
    """The picture the level data says is at a given world pixel."""

    def __init__(self, stage_json):
        s = json.load(open(stage_json))
        self.rooms = s['rooms']
        self.screens = s['screens']
        self.blocks = s['blocks']
        self.quads = s['quads']
        self.props = s['props']
        self.alt = s['alt']

    def metatile(self, wx, wy, broken=False):
        rx, ry = (wx >> 8) & 15, (wy >> 8) & 15
        scr = self.rooms[ry][rx]
        if scr is None:
            return None
        b = self.screens[scr][(wy >> 5) & 7][(wx >> 5) & 7]
        m = self.blocks[b][((wx >> 4) & 1) * 2 + ((wy >> 4) & 1)]
        # A block that can be broken starts out in its alternate, solid state:
        # the engine fills the whole $0540 bitmap when the level is entered.
        if (self.props[m] & 0x20) and not broken:
            m = self.alt[m]
        return m

    def tile(self, wx, wy):
        m = self.metatile(wx, wy)
        if m is None:
            return None, 0
        t = self.quads[m][((wx >> 3) & 1) * 2 + ((wy >> 3) & 1)]
        return t, self.props[m] >> 6


def draw(world, tiles, dump, cam_x, cam_y, rows=PLAYFIELD_H):
    img = Image.new('RGB', (256, 240))
    px = img.load()
    for y in range(rows):
        s = scanline(dump, y)
        if not (s['mask'] & 0x08):
            continue
        wy = cam_y + y
        for x in range(256):
            if x < 8 and not (s['mask'] & 0x02):
                px[x, y] = tuple(NES_RGB[s['pal'][0] & 0x3F].to_bytes(3, 'big'))
                continue
            wx = cam_x + x
            t, pal_hi = world.tile(wx, wy)
            if t is None:
                continue
            bank = s['chr'][t // 64]
            c = tiles.at(bank, t % 64)[(wy & 7) * 8 + (wx & 7)]
            idx = s['pal'][0] if c == 0 else s['pal'][pal_hi * 4 + c]
            px[x, y] = tuple(NES_RGB[idx & 0x3F].to_bytes(3, 'big'))
    return img


def check(dump_path, shot_path, out_prefix=None):
    d = VDump(dump_path)
    stage = d.ram[0x55]
    cam_x = (d.ram[0x30] | d.ram[0x31] << 8) // 16
    cam_y = (d.ram[0x32] | d.ram[0x33] << 8) // 16
    world = World(os.path.join(OUT, 'sol', 'levels', 'stage%d.json' % stage))
    tiles = Tiles('sol')
    img = draw(world, tiles, d, cam_x, cam_y)
    ref = Image.open(shot_path).convert('RGB')
    m = sprite_mask(d)
    a, b = img.load(), ref.load()
    bad = 0
    diff = Image.new('RGB', (256, 240))
    dp = diff.load()
    for y in range(PLAYFIELD_H):
        for x in range(256):
            if a[x, y] != b[x, y]:
                if m[y][x]:
                    dp[x, y] = (0, 0, 255)
                else:
                    dp[x, y] = (255, 0, 0)
                    bad += 1
    if out_prefix:
        img.save(out_prefix + '_mine.png')
        diff.save(out_prefix + '_diff.png')
    return stage, cam_x, cam_y, bad


if __name__ == '__main__':
    st, cx, cy, bad = check(sys.argv[1], sys.argv[2],
                            sys.argv[3] if len(sys.argv) > 3 else None)
    print('stage %d cam (%d,%d): %d pixels differ outside sprites' % (st, cx, cy, bad))
