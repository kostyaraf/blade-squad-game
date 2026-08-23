#!/usr/bin/env python3
"""Э2 acceptance: the engine's hero must move exactly like the cartridge's.

For each script of button presses the real game is played first and every
number its physics keeps is written down.  Then the engine is given the same
buttons and the same camera and must answer with the same positions, frame for
frame.  A single pixel of difference is a failure.
"""
import json
import os
import random
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
import pb2_trace                                             # noqa: E402
from pb2_map import Area                                     # noqa: E402

GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'
GAME = os.path.join(ROOT, 'game')

SCRIPTS = [
    ('stand',        [(2, '-')]),
    ('walk-left',    [(2, '-'), (10, 'LEFT')]),
    ('walk-right',   [(2, '-'), (10, 'RIGHT')]),
    ('tap-left',     [(2, '-'), (10, 'LEFT'), (14, '-'), (30, 'LEFT'), (35, '-')]),
    ('jump',         [(2, '-'), (10, 'LEFT'), (20, 'LEFT,A'), (60, 'LEFT')]),
    ('short-jump',   [(2, '-'), (10, 'LEFT'), (20, 'LEFT,A'), (24, 'LEFT')]),
    ('jump-in-place', [(2, '-'), (10, 'LEFT'), (11, '-'), (20, 'A'), (60, '-')]),
    ('crouch',       [(2, '-'), (10, 'DOWN'), (60, '-')]),
    ('slide',        [(2, '-'), (10, 'LEFT'), (12, 'LEFT,DOWN'),
                      (14, 'LEFT,DOWN,A'), (60, '-')]),
    ('walk-and-stop', [(2, '-'), (10, 'RIGHT'), (40, '-'), (60, 'LEFT'), (90, '-')]),
    ('turn-around',  [(2, '-'), (10, 'LEFT'), (30, 'RIGHT'), (60, 'LEFT')]),
    ('hop-about',    [(2, '-'), (10, 'A'), (20, '-'), (30, 'LEFT,A'),
                      (45, 'LEFT'), (60, 'RIGHT,A'), (80, '-')]),
]
FRAMES = 600
BUTTONS = ['-', 'LEFT', 'RIGHT', 'A', 'LEFT,A', 'RIGHT,A', 'DOWN',
           'DOWN,A', 'LEFT,DOWN', 'RIGHT,DOWN', 'UP', 'B', 'LEFT,B']


def random_scripts(n, seed=7):
    """Scripts nobody would write by hand, which is the point."""
    rnd = random.Random(seed)
    out = []
    for i in range(n):
        script = [(2, '-')]
        f = 10
        while f < FRAMES - 10:
            script.append((f, rnd.choice(BUTTONS)))
            f += rnd.randint(3, 40)
        out.append(('random-%02d' % i, script))
    return out


def s24(h, p, f):
    v = (h << 16) | (p << 8) | f
    return v - (1 << 24) if h & 0x80 else v


def run_engine(cfg, path):
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([GODOT, '--path', GAME, '--headless', '--',
                        '--replay=' + path], capture_output=True, text=True)
    rows = []
    for line in r.stdout.split('\n'):
        f = line.strip().split()
        if len(f) == 8 and all(x.lstrip('-').isdigit() for x in f):
            rows.append([int(x) for x in f])
    if not rows:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return rows


def areas_from_index(flat_only=False):
    """Every area of every stage, as the extractor found them."""
    path = os.path.join(ROOT, 'game', 'data', 'pb2', 'levels', 'index.json')
    index = json.load(open(path))
    out = []
    for st in index['stages']:
        for a in range(st['areas']):
            if flat_only and Area(st['stage'], a).vertical:
                continue
            out.append((st['stage'], a))
    return out


_SPOTS = {}


def spot_for(stage, area):
    """Where to stand the hero when a test opens an area out of turn.

    Opening any area is a matter of writing its number before the game reads
    it back, but that leaves him standing wherever the last area left him --
    which in a new area may be inside a wall.  So he is put on a floor this
    area really has, in view of the camera it really starts with.
    """
    key = (stage, area)
    if key not in _SPOTS:
        cam = pb2_trace.trace([(2, '-')], 2, stage=stage, area=area)[0]['cam']
        _SPOTS[key] = Area(stage, area).spot_on_screen(cam)
    return _SPOTS[key]


def check(name, script, stage, area, tmp, spot=None):
    """Play one script on the cartridge and in the engine.  Returns the frames
    compared, or a description of the first frame that disagreed."""
    rows = pb2_trace.trace(script, FRAMES, stage=stage, area=area, spot=spot)
    start = rows[0]
    # Only ordinary play in the area he started in can be compared: once the
    # game moves on -- a new area, or one of its scripted camera pans, which
    # freeze the hero outright -- its numbers mean something else.
    for i, r in enumerate(rows):
        if (r['area'] != start['area'] or r['stage'] != start['stage']
                or r['mode'] != start['mode']):
            rows = rows[:i]
            break
    cfg = dict(
        stage=start['stage'], area=start['area'],
        x=s24(start['xh'], start['xp'], start['xf']),
        y=s24(start['yh'], start['yp'], start['yf']),
        cam=start['cam'], state=start['state'], sub=start['sub'],
        pose=start['pose'], face_left=bool(start['face'] & 0x40),
        fall=start['fall'],
        frames=[dict(pad=r['pad'], hit=r['hit'], cam=r['cam'],
                     shots=r['shots'], lim=r['lim'])
                for r in rows[1:]],
    )
    got = run_engine(cfg, os.path.join(tmp, 'r.json'))
    want = [(s24(r['xh'], r['xp'], r['xf']), s24(r['yh'], r['yp'], r['yf']),
             r['vx'], r['vy'], r['state'], r['sub'], r['pose'])
            for r in rows[1:]]
    for i, w in enumerate(want):
        g = tuple(got[i][:7]) if i < len(got) else None
        if g != w:
            return None, (i + 1, w, g)
    return len(want), None


def show(w, g):
    def line(tag, v):
        if v is None:
            return '    %s  (no line)' % tag
        return ('    %s x=%8.3f y=%8.3f vx=%7.3f vy=%7.3f st=%02X sub=%2d '
                'pose=%02X' % (tag, v[0] / 256.0, v[1] / 256.0, v[2] / 256.0,
                               v[3] / 256.0, v[4], v[5], v[6]))
    print(line('game  ', w))
    print(line('engine', g))


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('-')]
    n_random = 0
    targets = [(0, 0)]
    seed = 7
    for a in sys.argv[1:]:
        if a.startswith('--random='):
            n_random = int(a.split('=')[1])
        elif a.startswith('--seed='):
            seed = int(a.split('=')[1])
        elif a == '--all-areas':
            targets = areas_from_index()
        elif a == '--flat-areas':
            targets = areas_from_index(flat_only=True)
        elif a.startswith('--areas='):
            targets = [tuple(int(x) for x in p.split(':'))
                       for p in a.split('=')[1].split(',')]
    tmp = tempfile.mkdtemp(prefix='pb2verify')
    ran = bad = covered = 0
    for stage, area in targets:
        scripts = list(SCRIPTS) if targets == [(0, 0)] else []
        scripts += random_scripts(n_random, seed + 31 * (stage * 16 + area))
        spot = None if targets == [(0, 0)] else spot_for(stage, area)
        if spot is None and targets != [(0, 0)]:
            print('%d:%-2d no place to stand' % (stage, area))
            continue
        for name, script in scripts:
            if args and name not in args:
                continue
            ran += 1
            n, diff = check(name, script, stage, area, tmp, spot)
            label = '%d:%-2d %-14s' % (stage, area, name)
            if diff is None:
                covered += n
                print('%s ok   %d frames' % (label, n))
            else:
                bad += 1
                print('%s DIFF at frame %d' % (label, diff[0]))
                show(diff[1], diff[2])
            sys.stdout.flush()
    print('%d of %d scripts differ, %d frames matched' % (bad, ran, covered))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
