#!/usr/bin/env python3
"""Draw a Power Blade 2 area (original or hybrid) with its real tiles, and
print / draw the catalogue of 32x32 blocks an area can be built from.

    python3 work/hybrid/pb2_draw.py area  <stage> <area> out.png [--file F] [--grid]
    python3 work/hybrid/pb2_draw.py blocks <stage> <area> out.png

`--file` reads a hybrid stage file (game/data/pb3/hybrid/*.json) instead of
game/data/pb2/levels/stageN.json.  The drawing follows game/src/pb2_level.gd:
a tile's 1 KB bank is the area's chr[t // 64], its palette quarter comes from
the block's attribute byte.
"""
import json
import os
import sys

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import levelgrid as LG  # noqa: E402

sys.path.insert(0, os.path.join(LG.ROOT, 'work', 'extract'))
from common import NES_RGB, SHEET_W  # noqa: E402


class Sheet:
    def __init__(self, game='pb2'):
        d = os.path.join(LG.DATA, game)
        img = Image.open(os.path.join(d, 'tiles.png')).convert('L')
        meta = json.load(open(os.path.join(d, 'chr.json')))
        self.step = meta['step']
        self.px = img.load()

    def tile(self, bank, index):
        t = bank * 64 + index
        tx, ty = (t % SHEET_W) * 8, (t // SHEET_W) * 8
        return [[self.px[tx + x, ty + y] // self.step for x in range(8)]
                for y in range(8)]


def rgb(i):
    return tuple(NES_RGB[i & 0x3F].to_bytes(3, 'big'))


def stage_data(stage, file=None):
    if file:
        return LG.load(os.path.join(LG.DATA, file) if not os.path.isabs(file) else file)
    return LG.load(os.path.join(LG.DATA, 'pb2', 'levels', 'stage%d.json' % stage))


def draw_block(img, sheet, area, blk, attr, ox, oy):
    banks = area['chr'][:4]
    pal = area['palette']
    for r in range(4):
        for c in range(4):
            t = int(blk[r * 4 + c])
            quad = (r // 2) * 2 + (c // 2)
            p = (attr >> (quad * 2)) & 3
            tl = sheet.tile(int(banks[t // 64]), t % 64)
            for y in range(8):
                for x in range(8):
                    v = tl[y][x]
                    col = pal[0] if v == 0 else pal[p * 4 + v]
                    img.putpixel((ox + c * 8 + x, oy + r * 8 + y), rgb(col))


def draw_area(stage, area_i, out, file=None, grid=False):
    d = stage_data(stage, file)
    a = d['areas'][area_i]
    sheet = Sheet()
    vertical = int(a['vertical']) != 0
    scr = [d['screens'][int(s)] for s in a['screens']]
    sh = int(scr[0]['h'])
    W = 8 * 32 if vertical else 8 * 32 * len(scr)
    H = sh * 32 * len(scr) if vertical else sh * 32
    img = Image.new('RGB', (W, H))
    for n, s in enumerate(scr):
        for br in range(sh):
            for bc in range(8):
                b = int(s['blocks'][br * 8 + bc])
                ox = bc * 32 + (0 if vertical else n * 256)
                oy = br * 32 + (n * sh * 32 if vertical else 0)
                draw_block(img, sheet, a, d['blocks'][b], int(d['attributes'][b]), ox, oy)
    dr = ImageDraw.Draw(img)
    if grid:
        for x in range(0, W, 256 if not vertical else W):
            dr.line([x, 0, x, H], fill=(255, 255, 0))
    for sp in a['spawns']:
        if vertical:
            x, y = sp['across'], sp['along'] * 16
        else:
            x, y = sp['along'] * 16, sp['across']
        col = (255, 255, 255) if sp['type'] == 2 else \
            (255, 160, 0) if sp['type'] in (3, 4) else (255, 40, 200)
        dr.rectangle([x - 3, y - 3, x + 3, y + 3], outline=col)
        dr.text((x + 4, y - 4), '%02X' % sp['type'], fill=col)
    st = a['start']
    sx = st['x'] + (int(a['cam_screen']) * 256 if not vertical else 0)
    dr.rectangle([sx - 4, st['y'] - 24, sx + 4, st['y']], outline=(0, 255, 0))
    img.save(out)


def block_kinds(d, a, b):
    blk = d['blocks'][b]
    ter = a['terrain']
    cls = a['terrain_class']
    out = ''
    for (r, c) in ((0, 0), (0, 2), (2, 0), (2, 2)):
        t = int(blk[r * 4 + c])
        k = LG.PB2_TERRAIN.get(int(ter[t]), '?')
        if k == '.' and int(cls[t]) == 3:
            k = '^'
        out += k
    return out


def used_blocks(d, a):
    seen = []
    for s in a['screens']:
        for b in d['screens'][int(s)]['blocks']:
            if int(b) not in seen:
                seen.append(int(b))
    return seen


def draw_blocks(stage, area_i, out):
    d = stage_data(stage)
    a = d['areas'][area_i]
    sheet = Sheet()
    used = used_blocks(d, a)
    cols = 16
    rows = (len(used) + cols - 1) // cols
    img = Image.new('RGB', (cols * 40, rows * 48), (40, 0, 40))
    dr = ImageDraw.Draw(img)
    for i, b in enumerate(used):
        ox, oy = (i % cols) * 40, (i // cols) * 48
        draw_block(img, sheet, a, d['blocks'][b], int(d['attributes'][b]), ox, oy)
        dr.text((ox, oy + 33), '%d' % b, fill=(255, 255, 255))
    img.save(out)
    for b in used:
        k = block_kinds(d, a, b)
        print('%3d  %s %s' % (b, k[:2], k[2:]))


if __name__ == '__main__':
    cmd, st, ar, out = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
    f = sys.argv[sys.argv.index('--file') + 1] if '--file' in sys.argv else None
    if cmd == 'area':
        draw_area(st, ar, out, f, '--grid' in sys.argv)
    else:
        draw_blocks(st, ar, out)
