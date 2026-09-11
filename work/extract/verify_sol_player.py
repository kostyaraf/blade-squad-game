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
}

WATCH = {'x': (0x80, 0x81), 'y': (0x82, 0x83),
         'vx': (0x05B6, 0x05B7), 'vy': (0x05B8, 0x05B9)}


def s16(lo, hi):
    v = lo | hi << 8
    return v - 0x10000 if v >= 0x8000 else v


def sbyte(v):
    return v - 0x100 if v >= 0x80 else v


def cartridge(state, pads):
    """Play `pads` into the cartridge and answer a row per frame."""
    script = []
    last = None
    for i, p in enumerate(pads):
        if p != last:
            names = [n for n, b in BITS if p & b]
            script.append((BASE + i, ','.join(names) if names else '-'))
            last = p
    addrs = set()
    for lo, hi in WATCH.values():
        addrs |= {lo, hi}
    addrs |= {0x05A2, 0x35}
    rows = P.watched(state, script, BASE, BASE + len(pads), addrs)
    out = []
    # A savestate is taken inside a frame, not between two, so resuming plays
    # the rest of the frame it was taken in: the first row is already a frame
    # of play, the same as the engine's first step.
    for fr, c in rows[:-1]:
        out.append((c[0x80] | c[0x81] << 8, c[0x82] | c[0x83] << 8,
                    s16(c[0x05B6], c[0x05B7]), s16(c[0x05B8], c[0x05B9]),
                    c[0x05A2], sbyte(c[0x35])))
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
        if len(f) == 6 and all(x.lstrip('-').isdigit() for x in f):
            rows.append(tuple(int(x) for x in f))
    if not rows:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return rows


NAMES = ('x', 'y', 'vx', 'vy', 'state', 'speed')


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    scratch = P.scratch('accept')
    try:
        state = P.make_state(os.path.join(scratch, 'lvl.state'), frame=BASE)
        # Where the cartridge has him standing before a button is touched, so
        # that the engine starts from the cartridge's own numbers and what is
        # on trial is what he does next and nothing else.
        base = P.ram(state, [(BASE, '-')], BASE)
        cfg0 = {
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
            'ground': {0x18: 1, 0x30: 2}.get(base[0x05CD], 0),
            'hurt': base[0x05C2],
            'scripted': base[0x05A5],
            'suit': base[0x05C5],
            'face_left': bool(base[0x05B2] & 0x80),
        }
        bad = 0
        total = 0
        for name, pads in sorted(SCRIPTS.items()):
            if only and name not in only:
                continue
            total += 1
            want = cartridge(state, pads)
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
                print('%-11s ok, %d frames' % (name, n))
                continue
            bad += 1
            print('%-11s differs on frame %d' % (name, where))
            if where < n:
                for k, nm in enumerate(NAMES):
                    if want[where][k] != got[where][k]:
                        print('    %-5s cartridge %6d   engine %6d'
                              % (nm, want[where][k], got[where][k]))
            else:
                print('    cartridge %d frames, engine %d' % (len(want), len(got)))
        print('%d of %d scripts differ' % (bad, total))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
