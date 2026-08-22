#!/usr/bin/env python3
"""Э2 acceptance: the engine's hero must move exactly like the cartridge's.

For each script of button presses the real game is played first and every
number its physics keeps is written down.  Then the engine is given the same
buttons and the same camera and must answer with the same positions, frame for
frame.  A single pixel of difference is a failure.
"""
import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
import pb2_trace                                             # noqa: E402

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
FRAMES = 120


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


def main():
    only = sys.argv[1:]
    tmp = tempfile.mkdtemp(prefix='pb2verify')
    ran = 0
    bad = 0
    for name, script in SCRIPTS:
        if only and name not in only:
            continue
        ran += 1
        rows = pb2_trace.trace(script, FRAMES)
        start = rows[0]
        cfg = dict(
            stage=start['stage'], area=start['area'],
            x=s24(start['xh'], start['xp'], start['xf']),
            y=s24(start['yh'], start['yp'], start['yf']),
            cam=start['cam'], state=start['state'], sub=start['sub'],
            pose=start['pose'], face_left=bool(start['face'] & 0x40),
            frames=[dict(pad=r['pad'], hit=r['hit'], cam=r['cam'])
                    for r in rows[1:]],
        )
        got = run_engine(cfg, os.path.join(tmp, 'r.json'))
        want = [(s24(r['xh'], r['xp'], r['xf']), s24(r['yh'], r['yp'], r['yf']),
                 r['vx'], r['vy'], r['state'], r['sub']) for r in rows[1:]]
        first = None
        for i, w in enumerate(want):
            if i >= len(got):
                first = (i, w, None)
                break
            g = tuple(got[i][:6])
            if g != w:
                first = (i, w, g)
                break
        if first is None:
            print('%-14s ok   %d frames' % (name, len(want)))
        else:
            bad += 1
            i, w, g = first
            print('%-14s DIFF at frame %d' % (name, i + 1))
            print('    game   x=%8.3f y=%8.3f vx=%7.3f vy=%7.3f st=%02X sub=%d'
                  % (w[0] / 256.0, w[1] / 256.0, w[2] / 256.0, w[3] / 256.0,
                     w[4], w[5]))
            if g is None:
                print('    engine  (no line)')
            else:
                print('    engine x=%8.3f y=%8.3f vx=%7.3f vy=%7.3f st=%02X sub=%d'
                      % (g[0] / 256.0, g[1] / 256.0, g[2] / 256.0, g[3] / 256.0,
                         g[4], g[5]))
    print('%d of %d scripts differ' % (bad, ran))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
