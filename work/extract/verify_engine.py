#!/usr/bin/env python3
"""Э1 acceptance: does the Godot engine draw what the data says?

Every area of Power Blade 2 and every stage of Solbrain is drawn at several
places, once by the Python yardstick and once by the engine, and the two are
compared pixel for pixel.  The yardstick itself was checked against the real
games, so a match here means the engine draws what the console drew.
"""
import json
import os
import shutil
import subprocess
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import OUT, ROOT                                     # noqa: E402
import oracle                                                    # noqa: E402

GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'
GAME = os.path.join(ROOT, 'game')
# The pictures and the dumps a run makes are worth nothing once read, and a
# stand run over and over would otherwise pile up gigabytes of them in the
# system's own scratch.  They go under the tree, and are wiped before use.
TMP = os.path.join(ROOT, 'work', 'tmp', 'pb3v3', 'engine')


def pb2_views():
    idx = json.load(open(os.path.join(OUT, 'pb2', 'levels', 'index.json')))
    out = []
    for s in idx['stages']:
        st = s['stage']
        for a in range(s['areas']):
            grid, w, h, _pal, _b = oracle.pb2_map(st, a)
            span_x = max(0, w * 8 - 256)
            span_y = max(0, h * 8 - 160)
            for k in (0, 1, 2):
                x = span_x * k // 2
                y = span_y * k // 2
                out.append(('pb2', st, a, x, y))
    return out


def sol_views():
    idx = json.load(open(os.path.join(OUT, 'sol', 'levels', 'index.json')))
    out = []
    for s in idx['stages']:
        st = s['stage']
        d = json.load(open(os.path.join(OUT, 'sol', 'levels', 'stage%d.json' % st)))
        n = len(d['screens'])
        used = [(rx, ry) for ry in range(16) for rx in range(16)
                if d['rooms'][ry][rx] is not None and d['rooms'][ry][rx] < n]
        if not used:
            continue
        # a few rooms spread through the stage, drawn from their top left
        for k in (0, len(used) // 2, len(used) - 1):
            rx, ry = used[k]
            out.append(('sol', st, 0, rx * 256, ry * 256))
    return out


def main():
    shutil.rmtree(TMP, ignore_errors=True)
    os.makedirs(TMP, exist_ok=True)
    views = pb2_views() + sol_views()
    lines = []
    for i, (g, st, a, x, y) in enumerate(views):
        lines.append('%s %d %d %d %d %s/g%04d.png' % (g, st, a, x, y, TMP, i))
    shots = os.path.join(TMP, 'shots.txt')
    open(shots, 'w').write('\n'.join(lines) + '\n')

    print('%d views (%d Power Blade 2, %d Solbrain)'
          % (len(views), len(pb2_views()), len(sol_views())))
    subprocess.run([GODOT, '--path', GAME, '--', '--shots=' + shots],
                   check=True, capture_output=True)

    bad = 0
    for i, (g, st, a, x, y) in enumerate(views):
        path = '%s/g%04d.png' % (TMP, i)
        if not os.path.exists(path):
            print('%-3s stage %2d area %2d @ (%5d,%4d): the engine drew nothing'
                  % (g, st, a, x, y))
            bad += 1
            continue
        want = (oracle.pb2_view(st, a, x, y) if g == 'pb2'
                else oracle.sol_view(st, x, y))
        got = Image.open(path).convert('RGB')
        wp, gp = want.load(), got.load()
        n = sum(1 for yy in range(240) for xx in range(256)
                if wp[xx, yy] != gp[xx, yy])
        if n:
            bad += 1
            print('%-3s stage %2d area %2d @ (%5d,%4d): %d pixels differ'
                  % (g, st, a, x, y, n))
    print('%d of %d views differ' % (bad, len(views)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
