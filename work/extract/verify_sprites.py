#!/usr/bin/env python3
"""Check that the exported tiles draw the whole picture, sprites and all.

`verify_pb2.py` excuses every pixel a sprite could have covered, because at
that stage only the background was exported.  This one excuses nothing: it
draws the background and then the sprites, out of the same tile sheet the
engine uses and out of the state the console was in on each scanline, and
holds the result against a screenshot of the game itself.

What is on trial is the drawing -- tall sprites, which half of the tile memory
each one comes out of, the colours, the eight-to-a-line limit and what stands
in front of what.  Where the sprites came from is `verify_oam.py`'s question.
"""
import os
import shutil
import subprocess
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import ROM_PB2, ROOT                                 # noqa: E402
from render import Tiles, bg_frame, spr_frame                    # noqa: E402
from vramdump import VDump                                       # noqa: E402

EMU = os.path.join(ROOT, 'work', 'tools', 'nesemu')
# The pictures and the dumps a run makes are worth nothing once read, and a
# stand run over and over would otherwise pile up gigabytes of them in the
# system's own scratch.  They go under the tree, and are wiped before use.
TMP = os.path.join(ROOT, 'work', 'tmp', 'pb3v3', 'sprites')
FRAMES = [1900, 2200, 2500, 2800, 3100, 3400, 3700, 4000]


def script(path):
    """Boot through the titles, then walk right, jumping now and then."""
    with open(path, 'w') as f:
        f.write('1 -\n300 START\n308 -\n700 START\n708 -\n1000 START\n1008 -\n')
        for fr in range(1500, 4200, 90):
            f.write('%d RIGHT\n%d RIGHT,A\n%d RIGHT\n' % (fr, fr + 40, fr + 58))


def main():
    shutil.rmtree(TMP, ignore_errors=True)
    os.makedirs(TMP, exist_ok=True)
    inp = os.path.join(TMP, 'walk.inp')
    script(inp)
    cmd = [EMU, ROM_PB2, '-input', inp, '-frames', str(max(FRAMES) + 1),
           '-png', os.path.join(TMP, 'f')]
    for fr in FRAMES:
        cmd += ['-vram', '%s/f%d.vram' % (TMP, fr) + '@%d' % fr, '-shot', str(fr)]
    subprocess.run(cmd, check=True, capture_output=True)

    tiles = Tiles('pb2')
    worst = 0
    for fr in FRAMES:
        d = VDump('%s/f%d.vram' % (TMP, fr))
        img = spr_frame(tiles, d, bg_frame(tiles, d))
        ref = Image.open('%s/f_%d.png' % (TMP, fr)).convert('RGB')
        a, b = img.load(), ref.load()
        bad = sum(1 for y in range(240) for x in range(256) if a[x, y] != b[x, y])
        worst = max(worst, bad)
        print('frame %4d  %d pixels differ' % (fr, bad))
        if bad:
            img.save('%s/mine_%d.png' % (TMP, fr))
    print('worst frame: %d pixels' % worst)
    return 0 if worst == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
