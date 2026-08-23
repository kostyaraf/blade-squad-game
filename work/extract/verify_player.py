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


def settled(stage, area, spot):
    """Whether an area opened out of turn is really being played.

    Some of them are not: a room the game only ever enters with a scripted
    walk-on, or one where slot zero is a boss's and not the hero's.  There the
    numbers we compare mean nothing, so the area is left out.  Left alone for a
    while, a hero who is really being played comes to rest on his feet, unhurt,
    with the game in its ordinary mode throughout.
    """
    rows = pb2_trace.trace([(2, '-')], 60, stage=stage, area=area, spot=spot)
    if any(r['mode'] != 3 or r['alive'] != rows[0]['alive'] for r in rows):
        return False
    if rows[0]['alive'] == 0:
        return False
    return all(r['sub'] == 4 and r['state'] == 0 for r in rows[-20:])


def logic_frames(rows):
    """Put the console's frames back together into the game's own steps.

    The cartridge's thinking is not tied to the picture: it counts a step of its
    own ($0110), and one step can run on past the end of a frame -- so a frame
    may show the view already moved and the hero not yet, and a step with more
    work in it than fits gets no frame of its own at all.  What is wanted is one
    line per step: the buttons and the view as the step began, how far the view
    slid before he was moved and how far after, and the hero as the step left
    him.  The step runs in the first frame of its group, so the slide of that
    frame comes before he moves and the rest of the group's slides after.
    """
    out = []
    for r in rows:
        r = dict(r, shift_after=0, frames=1)
        if out and r['tick'] == out[-1]['tick']:
            merged = dict(r)
            for k in ('pad', 'hit', 'cam', 'shots', 'lim'):
                merged[k] = out[-1][k]
            for k in ('solids', 'hold'):
                merged[k] = r[k] if r[k] is not None else out[-1][k]
            merged['push'] = [r['push'][i] if r['push'][i] is not None
                              else out[-1]['push'][i] for i in (0, 1)]
            merged['shift'] = out[-1]['shift']
            # The step of the game ran in one frame of the group, and only that
            # frame saw the view decided.  Whichever frame it was, keep it.
            for k in ('see_x', 'see_y'):
                merged[k] = (out[-1][k] if out[-1][k] is not None else r[k])
            merged['shift_after'] = out[-1]['shift_after'] + r['shift']
            merged['born'] = out[-1]['born'] + r['born']
            merged['died'] = out[-1]['died'] + r['died']
            merged['taken'] = out[-1]['taken'] + r['taken']
            merged['culled'] = out[-1]['culled'] + r['culled']
            merged['place'] = out[-1]['place'] + r['place']
            merged['seized'] = out[-1]['seized'] or r['seized']
            merged['frames'] = out[-1]['frames'] + 1
            out[-1] = merged
        else:
            out.append(r)
    return out


def replay(rows):
    """The script the engine is given: where the hero starts and, one line per
    frame, everything the cartridge decided that the engine does not yet."""
    start = rows[0]
    return dict(
        stage=start['stage'], area=start['area'],
        x=s24(start['xh'], start['xp'], start['xf']),
        y=s24(start['yh'], start['yp'], start['yf']),
        vx=start['vx'], vy=start['vy'],
        anim_t=start['anim_t'], anim_i=start['anim_f'],
        # $60 is one byte with a sign in it: back is a number near 256.
        cam=start['cam'],
        cam_pend=start['pend'] - 256 if start['pend'] > 127 else start['pend'],
        clock=start['clock'],
        state=start['state'],
        sub=start['sub'],
        pose=start['pose'], face_left=bool(start['face'] & 0x40),
        fall=start['fall'], tick=start['tick'],
        frames=[dict(pad=r['pad'], hit=r['hit'],
                     shots=r['shots'], lim=r['lim'],
                     solids=r['solids'] or [], hold=r['hold'] or 0,
                     push=[r['push'][0] or 0, r['push'][1] or 0],
                     ticks=r['frames'])
                for r in rows[1:]],
    )


def ordinary(rows):
    """The stretch of the run that can be compared at all.

    Only ordinary play in the area he started in: once the game moves on -- a
    new area, one of its scripted camera pans, which freeze the hero outright,
    a hit, which throws him about, or something in the level taking hold of him
    and carrying him off -- its numbers belong to the next stage of the work.
    """
    start = rows[0]
    for i, r in enumerate(rows):
        if (r['area'] != start['area'] or r['stage'] != start['stage']
                or r['mode'] != start['mode'] or r['alive'] != start['alive']
                or r['seized']):
            return rows[:i]
    return rows


# An area opened out of turn is entered by writing the hero into it, and the
# step in which that lands is neither one thing nor the other -- half of what he
# is was decided before he was moved.  A few steps later he is himself again.
SETTLE = 8


def check(name, script, stage, area, tmp, spot=None):
    """Play one script on the cartridge and in the engine.  Returns the frames
    compared, or a description of the first frame that disagreed."""
    rows = logic_frames(ordinary(pb2_trace.trace(
        script, FRAMES, stage=stage, area=area, spot=spot)))
    # The recording stops at a frame, not at a step, and the step the last frame
    # was in the middle of has only half happened in it -- the game's own count
    # already moved on while the hero had not.  That half a step is thrown away.
    rows = rows[:-1]
    if spot is not None:
        rows = rows[SETTLE:]
    got = run_engine(replay(rows), os.path.join(tmp, 'r.json'))
    # A step that spills over the end of a picture is caught by the recording
    # in its last frame, and by then the NEXT step's slide of the view has
    # already been taken off him.  That borrowed slide is put back, so that
    # what is compared is the hero as his own step left him.
    vertical = Area(stage, area).vertical
    want = []
    for r in rows[1:]:
        x = s24(r['xh'], r['xp'], r['xf'])
        y = s24(r['yh'], r['yp'], r['yf'])
        if vertical:
            y += r['shift_after'] << 8
        else:
            x += r['shift_after'] << 8
        want.append((x, y, r['vx'], r['vy'], r['state'], r['sub'], r['pose']))
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
    tmp = pb2_trace.P.scratch('verify')
    ran = bad = covered = 0
    for stage, area in targets:
        scripts = list(SCRIPTS) if targets == [(0, 0)] else []
        scripts += random_scripts(n_random, seed + 31 * (stage * 16 + area))
        spot = None if targets == [(0, 0)] else spot_for(stage, area)
        if targets != [(0, 0)]:
            if spot is None:
                print('%d:%-2d no place to stand' % (stage, area))
                continue
            if not settled(stage, area, spot):
                print('%d:%-2d not ordinary play' % (stage, area))
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
    pb2_trace.P.sweep(tmp)
    print('%d of %d scripts differ, %d frames matched' % (bad, ran, covered))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
