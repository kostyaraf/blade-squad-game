#!/usr/bin/env python3
"""Э4.1 acceptance: Solbrain's hero, engine against cartridge, frame by frame.

The cartridge is stood in the first stage with the hero in hand, a list of
buttons is played into it, and every frame his place, his speed, his state and
his running byte are written down.  The engine is stood in the same place with
the same list and must answer the same numbers -- not nearly, exactly.

Nothing here is a matter of opinion: a run either matches on all six numbers on
all of its frames or it is a failure, and the first frame that parts company is
printed.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
import sol_probe as P

GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'
GAME = os.path.join(ROOT, 'game')

# The pad, in the order the cartridge reads it into $06.
BITS = [('RIGHT', 0x01), ('LEFT', 0x02), ('DOWN', 0x04), ('UP', 0x08),
        ('START', 0x10), ('SELECT', 0x20), ('B', 0x40), ('A', 0x80)]

BASE = 2320               # a frame by which the first stage is his to steer
WARPED = P.WARP_IN        # the same, for a stage the game was asked to raise
LEN = 96                  # short enough that nothing else in the level reaches him

R, L, D, U, A, B = 0x01, 0x02, 0x04, 0x08, 0x80, 0x40


def hold(n, pad):
    return [pad] * n


# What he is asked to do.  Each is a list of (frames, buttons), and between
# them they touch every line of the run and the jump: speeding up to the top,
# letting go, turning at speed, tapping the jump and leaning on it, jumping
# while running, ducking, and the wall at the end of the floor.
SCRIPTS = {
    'still':      hold(LEN, 0),
    'right':      hold(LEN, R),
    'left':       hold(LEN, L),
    'right stop': hold(30, R) + hold(LEN - 30, 0),
    'left stop':  hold(30, L) + hold(LEN - 30, 0),
    'turn':       hold(30, R) + hold(LEN - 30, L),
    'turn back':  hold(20, L) + hold(20, R) + hold(20, L) + hold(LEN - 60, R),
    'tap jump':   hold(2, A) + hold(LEN - 2, 0),
    'hold jump':  hold(LEN, A),
    'half jump':  hold(4, A) + hold(LEN - 4, 0),
    'run jump':   hold(20, R) + hold(20, R | A) + hold(LEN - 40, R),
    'jump turn':  hold(20, R) + hold(4, R | A) + hold(LEN - 24, L),
    'duck':       hold(20, D) + hold(LEN - 20, 0),
    'duck run':   hold(20, D) + hold(LEN - 20, R),
    'wall':       hold(LEN, R),
    'jump wall':  hold(40, R) + hold(6, R | A) + hold(LEN - 46, R),
    'stutter':    ([R] * 4 + [0] * 4) * (LEN // 8),
    'taps':       ([A] + [0] * 7) * (LEN // 8),
    'shoot':      hold(10, 0) + hold(2, B) + hold(LEN - 12, 0),
    'run shoot':  hold(10, R) + hold(2, R | B) + hold(LEN - 12, R),
    'duck shoot': hold(10, D) + hold(2, D | B) + hold(LEN - 12, D),
    'air shoot':  hold(6, A) + hold(6, 0) + hold(2, B) + hold(LEN - 14, 0),
    'rapid':      ([B] + [0] * 3) * (LEN // 4),
}

WATCH = {'x': (0x80, 0x81), 'y': (0x82, 0x83),
         'vx': (0x05B6, 0x05B7), 'vy': (0x05B8, 0x05B9)}

# Where he is stood before the buttons start.  The first stage is plain floor
# and plain air, so the rest of the ground the game has -- water, the two belts
# and a bed of spikes -- is reached by asking the game for that stage and
# setting him down above it.  (mx, my) are metatiles; he is dropped half a tile
# in from the left edge of the one named.
PLACES = [
    ('s0',    0, None),
    ('water', 5, (56, 103)),
    ('belt',  11, (24, 60)),
    ('belt2', 10, (59, 24)),
    ('spike', 2, (23, 236)),
    ('ice',   4, (49, 38)),
]


def s16(lo, hi):
    v = lo | hi << 8
    return v - 0x10000 if v >= 0x8000 else v


def sbyte(v):
    return v - 0x100 if v >= 0x80 else v


def cartridge(state, pads, base, pokes=()):
    """Play `pads` into the cartridge and answer a row per frame."""
    script = []
    last = None
    for i, p in enumerate(pads):
        if p != last:
            names = [n for n, b in BITS if p & b]
            script.append((base + i, ','.join(names) if names else '-'))
            last = p
    addrs = set()
    for lo, hi in WATCH.values():
        addrs |= {lo, hi}
    addrs |= {0x05A2, 0x35, 0x05A4, 0x05A5, 0x05B4, 0x05B5, 0x05A6, 0x05A7,
              0x05CE}
    rows = P.watched(state, script, base, base + len(pads), addrs,
                     pokes=pokes)
    out = []
    # A savestate is taken inside a frame, not between two, so resuming plays
    # the rest of the frame it was taken in: the first row is already a frame
    # of play, the same as the engine's first step.
    for fr, c in rows[:-1]:
        out.append((c[0x80] | c[0x81] << 8, c[0x82] | c[0x83] << 8,
                    s16(c[0x05B6], c[0x05B7]), s16(c[0x05B8], c[0x05B9]),
                    c[0x05A2], sbyte(c[0x35]),
                    c[0x05B5], c[0x05A5], c[0x05A4], c[0x05B4],
                    c[0x05A6], c[0x05A7], c[0x05CE]))
    return out


def engine(cfg, scratch):
    path = os.path.join(scratch, 'play.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([GODOT, '--path', GAME, '--headless', '--',
                        '--solplay=%s' % path],
                       capture_output=True, text=True, timeout=300)
    rows = []
    for line in r.stdout.split('\n'):
        f = line.split()
        if len(f) == 13 and all(x.lstrip('-').isdigit() for x in f):
            rows.append(tuple(int(x) for x in f))
    if not rows:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return rows


NAMES = ('x', 'y', 'vx', 'vy', 'state', 'speed',
         'pose', 'scripted', 'step_t', 'step_i', 'pic_lo', 'pic_hi', 'anim')


def snapshot(base):
    """The hero as the cartridge has him, in the words the engine's stand uses."""
    return {
        'stage': base[0x55],
        'x': base[0x80] | base[0x81] << 8,
        'y': base[0x82] | base[0x83] << 8,
        'state': base[0x05A2],
        'speed': sbyte(base[0x35]),
        'jump': base[0x05E8],
        'face_left': bool(base[0x05B2] & 0x80),
        'timer': base[0x05A3],
        'hold': base[0x05AC],
        'rise': s16(base[0x05AD], base[0x05AE]),
        'ground': base[0x05CD],
        'hurt': base[0x05C2],
        'scripted': base[0x05A5],
        'suit': base[0x05C5],
        'gravity': base[0x05E9],
        'hold_max': base[0x05EA],
        'flags': base[0x05CB],
        'jump_flags': base[0x05C9],
        'seen': base[0x05CA],
        'swim': base[0x05CC],
        'shield': base[0x05C8],
        'fuel': base[0x05AF],
        'step_down': base[0x5B],
        'clock': base[0x0C],
        'pad_held': base[0x06],
        'map_kind': base[0x70],
        'pose': base[0x05B5],
        'step_t': base[0x05A4],
        'step_i': base[0x05B4],
        'pic_lo': base[0x05A6],
        'pic_hi': base[0x05A7],
        'anim': base[0x05CE],
    }


DROP = 60                 # frames between setting him down and the first button


def stand(scratch, label, stage, spot):
    """A savestate with him standing where the place wants him.

    He is set down a few tiles above the ground the place is about and left to
    fall for `DROP` frames, so that by the time the buttons start he is standing
    on it.  Everything is baked into the state: what is played from it is
    whole frames, the same as the first stage's own.
    """
    lvl = P.make_state(os.path.join(scratch, 'lvl.state'), frame=BASE)
    if stage == 0:
        return lvl
    pokes = ()
    if spot is not None:
        mx, my = spot
        x, y = mx * 256 + 128, my * 256
        at = WARPED - DROP
        pokes = tuple((a, v, at) for a, v in
                      ((0x80, x & 0xFF), (0x81, x >> 8),
                       (0x82, y & 0xFF), (0x83, y >> 8),
                       (0x35, 0), (0x05B6, 0), (0x05B7, 0),
                       (0x05AD, 0), (0x05AE, 0)))
    return P.warp(os.path.join(scratch, '%s.state' % label), stage, lvl,
                  pokes=pokes)


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    scratch = P.scratch('accept')
    try:
        bad = 0
        total = 0
        for label, stage, spot in PLACES:
            if places and label not in places:
                continue
            # A savestate is taken before the frame it is named for is played,
            # so loading it and asking for that frame plays it whole.  What the
            # engine is seeded with is therefore the end of that frame, and the
            # first frame it is on trial for is the one after.
            first = BASE if stage == 0 else WARPED
            play = first + 1
            state = stand(scratch, label, stage, spot)
            # Where the cartridge has him standing before a button is touched,
            # so that the engine starts from the cartridge's own numbers and
            # what is on trial is what he does next and nothing else.
            cfg0 = snapshot(P.ram(state, [(first, '-')], first))
            for name, pads in sorted(SCRIPTS.items()):
                if only and name not in only:
                    continue
                total += 1
                want = cartridge(state, pads, play)
                cfg = dict(cfg0)
                cfg['pads'] = pads
                got = engine(cfg, scratch)
                n = min(len(want), len(got))
                where = None
                for i in range(n):
                    if want[i] != got[i]:
                        where = i
                        break
                if where is None and len(want) != len(got):
                    where = n
                if where is None:
                    print('%-6s %-11s ok, %d frames' % (label, name, n))
                    continue
                bad += 1
                print('%-6s %-11s differs on frame %d' % (label, name, where))
                if where < n:
                    for k, nm in enumerate(NAMES):
                        if want[where][k] != got[where][k]:
                            print('    %-5s cartridge %6d   engine %6d'
                                  % (nm, want[where][k], got[where][k]))
                else:
                    print('    cartridge %d frames, engine %d'
                          % (len(want), len(got)))
                sys.stdout.flush()
        print('%d of %d scripts differ' % (bad, total))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
