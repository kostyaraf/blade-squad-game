#!/usr/bin/env python3
"""Э4.2 acceptance: who gets into Solbrain's sixteen slots, and where.

The hero is stood in a stage and walked about; the cartridge is asked, every
picture, which spawn id sits in each of the sixteen slots and at what place.
The engine is stood in the same spot with the same buttons and must answer the
same numbers.

Only the slots themselves are on trial here, not what the things in them do.
A thing moves on the very picture it is born on -- the pool walk $CE1D runs
after the scan $AE69 in the same frame -- so its place is already its own
business by the time anyone can look at it.  What is held here is the sixteen
spawn ids, picture by picture: when a thing is let in, from which side, into
which slot, and when it is taken away again.  Where it then goes is Э4.3.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import sol_probe as P                                            # noqa: E402
import verify_sol_player as V                                    # noqa: E402

GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'
GAME = os.path.join(ROOT, 'game')

SLOTS = 16
MARKS = 64
LEN = 40                  # short: nothing in the pool has started to move yet

R, L, D, U, A, B = 0x01, 0x02, 0x04, 0x08, 0x80, 0x40


def hold(n, pad):
    return [pad] * n


# Walks that carry the view about, because the view is what lets things in.
SCRIPTS = {
    'still':     hold(LEN, 0),
    'right':     hold(LEN, R),
    'left':      hold(LEN, L),
    'right far': hold(LEN * 3, R),
    'left far':  hold(LEN * 3, L),
    'there and back': hold(LEN, R) + hold(LEN * 2, L),
    'jump right': hold(10, R) + hold(8, R | A) + hold(LEN - 18, R),
}

# Stages picked for what they hold: the first, one that scrolls down, and a
# couple whose rooms are crowded.
PLACES = [('s0', 0), ('s1', 1), ('s2', 2), ('s3', 3), ('s5', 5), ('s9', 9)]

POOL = [0x0600 + i for i in range(SLOTS)]
POS = ([0xA0 + i for i in range(SLOTS)] + [0xB0 + i for i in range(SLOTS)]
       + [0xC0 + i for i in range(SLOTS)] + [0xD0 + i for i in range(SLOTS)])


def ids(rows):
    """Just who is in each slot; where they have got to is not on trial.

    The top two bits of the slot are not the spawn id: a behaviour may raise
    bit 6 to say "do not take me away yet" ($9050 in bank 2 does), and the
    behaviours are Э4.3.  They are masked off here so that this stand answers
    only its own question.
    """
    return [tuple(n & 0x3F for n, _x, _y in r) for r in rows]


def cartridge(state, pads, base):
    script = V.cartridge_script(pads, base)
    addrs = set(POOL) | set(POS)
    rows = P.watched(state, script, base, base + len(pads), addrs)
    out = []
    for _fr, c in rows[:-1]:
        out.append(tuple(
            (c[0x0600 + i], c[0xA0 + i] | c[0xB0 + i] << 8,
             c[0xC0 + i] | c[0xD0 + i] << 8)
            for i in range(SLOTS)))
    return out


def engine(cfg, scratch):
    path = os.path.join(scratch, 'obj.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([GODOT, '--path', GAME, '--headless', '--',
                        '--solobj=%s' % path],
                       capture_output=True, text=True, timeout=600)
    rows = []
    for line in r.stdout.split('\n'):
        f = line.split()
        if len(f) != SLOTS or not all(t.count(',') == 2 for t in f):
            continue
        rows.append(tuple(tuple(int(v) for v in t.split(',')) for t in f))
    if not rows:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return rows


def seed(base):
    """The pool, the view and the scroll bookkeeping as the cartridge has them."""
    cfg = V.snapshot(base)
    cfg['cam_x'] = base[0x30] | base[0x31] << 8
    cfg['cam_y'] = base[0x32] | base[0x33] << 8
    cfg['ride_hold'] = base[0x05C3]
    cfg['ride_fall'] = base[0x34]
    cfg['vx'] = V.s16(base[0x05B6], base[0x05B7])
    cfg['vy'] = V.s16(base[0x05B8], base[0x05B9])
    cfg['due'] = base[0x05EC]
    cfg['col_due'] = base[0x37]
    cfg['row_due'] = base[0x36]
    cfg['seen_x'] = base[0x05E0] | base[0x05E1] << 8
    cfg['seen_y'] = base[0x05E2] | base[0x05E3] << 8
    cfg['room'] = base[0x05EB]
    cfg['mark'] = [base[0x0560 + i] for i in range(MARKS)]
    cfg['id'] = [base[0x0600 + i] for i in range(SLOTS)]
    cfg['ox'] = [base[0xA0 + i] | base[0xB0 + i] << 8 for i in range(SLOTS)]
    cfg['oy'] = [base[0xC0 + i] | base[0xD0 + i] << 8 for i in range(SLOTS)]
    return cfg


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    scratch = P.scratch('spawns')
    try:
        bad = total = 0
        for label, stage in PLACES:
            if places and label not in places:
                continue
            first = V.BASE if stage == 0 else P.WARP_IN
            play = first + 1
            state = V.stand(scratch, label, stage, None)
            cfg0 = seed(P.ram(state, [(first, '-')], first))
            for name, pads in sorted(SCRIPTS.items()):
                if only and name not in only:
                    continue
                total += 1
                want = ids(cartridge(state, pads, play))
                cfg = dict(cfg0)
                cfg['pads'] = pads
                got = ids(engine(cfg, scratch))
                n = min(len(want), len(got))
                where = None
                for i in range(n):
                    if want[i] != got[i]:
                        where = i
                        break
                if where is None and len(want) != len(got):
                    where = n
                if where is None:
                    print('%-6s %-15s ok, %d frames' % (label, name, n))
                    continue
                bad += 1
                print('%-6s %-15s differs on frame %d' % (label, name, where))
                if where < n:
                    for s in range(SLOTS):
                        if want[where][s] != got[where][s]:
                            print('    slot %2d  cartridge %3d   engine %3d'
                                  % (s, want[where][s], got[where][s]))
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
