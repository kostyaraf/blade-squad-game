#!/usr/bin/env python3
"""Э4.11 acceptance: the strip at the bottom of the picture.

Everything the player is told while a stage is playing stands in the bottom
left corner: the mark of the suit he is wearing, which blinks below the third
one, and the five figures of what he has still to be paid.  Both are sprites
and nothing else on the strip is; the cartridge lays them down in $91DD, right
after the hero himself has gone into the table and before the satellite's
letters are looked at.

The stand is a straight before-and-after, the same shape as the hero's own
($91DA/$91DD).  The cartridge is stopped at $91DD, where the strip has not
been laid yet, and at $923B, the instruction after the last of it.  The engine
is handed the first record -- the whole table as it stood, the four cursors,
the four tile books, and the three cells the strip reads ($05C5 the suit, $0C
the picture counter, $05C6:$05C7 what is still to be paid) -- and must hand
back the second: two hundred and fifty six bytes of table, four cursors and
four books.

The three cells are poked rather than played for.  A suit is not something a
stage hands over in a few hundred pictures, and the sum owed only moves when
something is killed; both are simply stood at every value that matters while
the picture counter walks by itself.
"""
import json
import os
import struct
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import sol_probe as P                                            # noqa: E402
import verify_sol_player as V                                    # noqa: E402

EMU = os.path.join(ROOT, 'work', 'tools', 'nesemu')
BEFORE, AFTER, BANK = 0x91DD, 0x923B, 12
REC = 8 + 2048

# How many pictures each walk is.  The counter $0C is what makes the mark blink
# and what holds the figures back every other picture, so a walk has to be long
# enough for both of its bits to come round several times.
LEN = 96

# $05C5 -- the suits.  Nought is no suit at all, and from the third up the mark
# stands still instead of blinking, so both sides of that line are walked.  The
# two past the last real one are walked as well: the cartridge does not check,
# it simply asks the picture list for suit plus two.
SUITS = (0, 1, 2, 3, 4, 5, 6, 7)

# $05C6:$05C7 -- what is still to be paid.  Nought, one of each figure, the
# rollover at ten thousand and past what five figures can hold ($ECB5 answers
# nine nines to that).
OWED = (0x0000, 0x0009, 0x0063, 0x03E7, 0x270F, 0x2710, 0xFFFF)


def records(path):
    out = []
    with open(path, 'rb') as f:
        while True:
            b = f.read(REC)
            if len(b) < REC:
                break
            fr, _pc, bank = struct.unpack('<IHH', b[:8])
            if bank == BANK:
                out.append((fr, b[8:]))
    return out


def play(state, base, scratch, pokes):
    """Stand the cartridge still and stop it either side of the strip."""
    inp = os.path.join(scratch, 'i.inp')
    pre = os.path.join(scratch, 'pre.bin')
    post = os.path.join(scratch, 'post.bin')
    open(inp, 'w').write('%d -\n' % base)
    cmd = [EMU, P.ROM, '-loadstate', state, '-input', inp,
           '-frames', str(base + LEN),
           '-ramat', '%s@%04X' % (pre, BEFORE),
           '-ramat', '%s@%04X' % (post, AFTER)]
    for a, v, fr in pokes:
        cmd += ['-poke', '%04X=%02X@%d' % (a, v, fr)]
    subprocess.run(cmd, check=True, capture_output=True)
    a, b = records(pre), records(post)
    n = min(len(a), len(b))
    return [(a[i][0], a[i][1], b[i][1]) for i in range(n)
            if a[i][0] == b[i][0] and a[i][0] >= base]


def frame(m):
    return dict(
        suit=m[0x05C5], clock=m[0x0C], bonus=m[0x05C6] | m[0x05C7] << 8,
        count=m[0x6A], turn=m[0x6B], fwd=m[0x6C], back=m[0x6D],
        banks=[m[0x42], m[0x43], m[0x44], m[0x45]],
        oam=list(m[0x200:0x300]),
    )


def wanted(m):
    return (list(m[0x200:0x300]), m[0x6A], m[0x6B], m[0x6C], m[0x6D],
            [m[0x42], m[0x43], m[0x44], m[0x45]])


def engine(cfg, scratch):
    path = os.path.join(scratch, 'strip.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                        '--solstrip=%s' % path], capture_output=True,
                       text=True, timeout=300)
    rows = []
    for line in r.stdout.split('\n'):
        f = line.split()
        if len(f) == 9 and len(f[0]) == 512:
            rows.append(([int(f[0][i:i + 2], 16) for i in range(0, 512, 2)],
                         int(f[1]), int(f[2]), int(f[3]), int(f[4]),
                         [int(x) for x in f[5:9]]))
    if not rows:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return rows


def walks(base):
    """One walk per suit, and inside it the sum owed is stood at each value.

    The picture counter is left alone: it is the console's own and both sides
    read the same one out of the record.
    """
    out = []
    for suit in SUITS:
        pokes = [(0x05C5, suit, base + 1)]
        for i, owed in enumerate(OWED):
            at = base + 2 + i * (LEN // len(OWED))
            pokes.append((0x05C6, owed & 0xFF, at))
            pokes.append((0x05C7, owed >> 8, at))
        out.append(('suit %d' % suit, pokes))
    return out


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    scratch = P.scratch('strip')
    try:
        bad = total = 0
        state = V.stand(scratch, 's0', 0, None)
        base = V.BASE + 1
        for name, pokes in walks(base):
            if only and name not in only:
                continue
            total += 1
            rows = play(state, base, scratch, pokes)
            cfg = dict(frames=[frame(a) for _fr, a, _b in rows])
            got = engine(cfg, scratch)
            want = [wanted(b) for _fr, _a, b in rows]
            n = min(len(want), len(got))
            where = None
            for i in range(n):
                if want[i] != got[i]:
                    where = i
                    break
            if where is None and len(got) == len(want):
                print('%-8s ok, %d pictures' % (name, n))
                continue
            bad += 1
            if where is None:
                print('%-8s the engine gave %d pictures, not %d'
                      % (name, len(got), len(want)))
                continue
            print('%-8s differs on picture %d' % (name, where))
            w, g = want[where], got[where]
            shown = 0
            for k in range(256):
                if w[0][k] != g[0][k] and shown < 6:
                    print('    sprite %d.%d  cartridge %3d  engine %3d'
                          % (k // 4, k % 4, w[0][k], g[0][k]))
                    shown += 1
            for k, nm in enumerate(('count', 'turn', 'fwd', 'back'), 1):
                if w[k] != g[k]:
                    print('    %-6s cartridge %3d  engine %3d'
                          % (nm, w[k], g[k]))
            if w[5] != g[5]:
                print('    tiles  cartridge %s  engine %s' % (w[5], g[5]))
        print('%d of %d walks of the strip differ' % (bad, total))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


if __name__ == '__main__':
    sys.exit(main())
