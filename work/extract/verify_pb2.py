#!/usr/bin/env python3
"""Check the exported Power Blade 2 data against the game itself.

Two questions, asked at several moments of a real playthrough:

  * does the level data build the same nametable the console built?
  * does the tile sheet and the palette draw the same picture?

A pixel under a sprite is excused, because the background is all this stage
of the work exports.
"""
import json
import os
import subprocess
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import OUT, ROM_PB2, ROOT                            # noqa: E402
from render import Tiles, bg_frame, sprite_mask                  # noqa: E402
from vramdump import VDump                                       # noqa: E402

EMU = os.path.join(ROOT, 'work', 'tools', 'nesemu')
TMP = '/tmp/pb3v3/verify'
FRAMES = [1900, 2200, 2500, 2800, 3100, 3400, 3700, 4000]


def script(path):
    """Boot through the titles, then walk right, jumping now and then."""
    with open(path, 'w') as f:
        f.write('1 -\n300 START\n308 -\n700 START\n708 -\n1000 START\n1008 -\n')
        for fr in range(1500, 4200, 90):
            f.write('%d RIGHT\n%d RIGHT,A\n%d RIGHT\n' % (fr, fr + 40, fr + 58))


def screen_grid(st, si):
    """The 32-wide tile grid of one exported screen."""
    sc = st['screens'][si]
    grid = [[0] * 32 for _ in range(sc['h'] * 4)]
    attr = [0] * 64
    for br in range(sc['h']):
        for bc in range(8):
            b = sc['blocks'][br * 8 + bc]
            blk = st['blocks'][b] if b < len(st['blocks']) else [0] * 16
            attr[br * 8 + bc] = (st['attributes'][b]
                                 if b < len(st['attributes']) else 0)
            for r in range(4):
                for c in range(4):
                    grid[br * 4 + r][bc * 4 + c] = blk[r * 4 + c]
    return grid, attr


def check_nametable(st, area, dump):
    """Every page of CIRAM that holds a screen this area names."""
    hits = []
    for pg in (0, 1):
        page = dump.page(pg)
        best = None
        for si in area['screens']:
            grid, attr = screen_grid(st, si)
            tiles_ok = sum(page[r * 32 + c] == grid[r][c]
                           for r in range(len(grid)) for c in range(32))
            attr_ok = sum(page[0x3C0 + i] == attr[i]
                          for i in range(len(grid) // 4 * 8))
            n = len(grid) * 32
            if best is None or tiles_ok > best[1]:
                best = (si, tiles_ok, n, attr_ok, len(grid) // 4 * 8)
        hits.append(best)
    return hits


def main():
    os.makedirs(TMP, exist_ok=True)
    inp = os.path.join(TMP, 'walk.inp')
    script(inp)
    cmd = [EMU, ROM_PB2, '-input', inp, '-frames', str(max(FRAMES) + 1),
           '-png', os.path.join(TMP, 'f')]
    for fr in FRAMES:
        cmd += ['-vram', '%s/f%d.vram@%d' % (TMP, fr, fr), '-shot', str(fr)]
    subprocess.run(cmd, check=True, capture_output=True)

    tiles = Tiles('pb2')
    stages = {}
    worst = 0
    for fr in FRAMES:
        d = VDump('%s/f%d.vram' % (TMP, fr))
        # the game's own idea of where it is
        cam, area_i = d.ram[0x66], d.ram[0x9C]
        st = stages.setdefault(0, json.load(
            open(os.path.join(OUT, 'pb2', 'levels', 'stage0.json'))))
        area = st['areas'][area_i] if area_i < len(st['areas']) else st['areas'][0]

        hits = check_nametable(st, area, d)
        nt = ' '.join('scr%d %d/%d tiles %d/%d attr' % h for h in hits)

        img = bg_frame(tiles, d)
        ref = Image.open('%s/f_%d.png' % (TMP, fr)).convert('RGB')
        m = sprite_mask(d)
        a, b = img.load(), ref.load()
        bad = sum(1 for y in range(240) for x in range(256)
                  if a[x, y] != b[x, y] and not m[y][x])
        worst = max(worst, bad)
        print('frame %4d  area %d cam %d  |  %s  |  %d stray pixels'
              % (fr, area_i, cam, nt, bad))
    print('worst frame: %d pixels outside sprites' % worst)
    return 0 if worst == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
