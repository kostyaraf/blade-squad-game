#!/usr/bin/env python3
"""Э4.6 acceptance: the four pieces Solbrain arrives as.

$02 is what the game is doing, and ninety four things can stand in it.  The one
that puts the hero into a stage is a pair: $CB96 sets four pieces going from a
page and a half out on each diagonal, and $CC77 flies them in, walking the view
back down while they come, and hands the game over to the stage the moment the
first of them lands on him.

The cartridge is stopped at $CC77, the top of that mode, so every record is one
whole picture of it and nothing else.  The engine is handed the first record and
must answer with every one that follows: the mode, the two counts the arriving
keeps ($03 and $57), where each of the four pieces is, where the view is and the
whole two hundred and fifty six bytes of sprite table with the four cursors that
walk it.

The hero is killed on the way in, which is how the mode is reached without
having to play a stage to its end: $05A2 is written with $0C (dying), the
cartridge runs the dying out itself and $97A7 spends a try and raises the stage
again.
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

AT = 0xCC77               # the top of mode $3F
REC = 8 + 2048
DIE = 10                  # pictures after the state is settled, he is killed
RUN = 600                 # long enough for the dying and the whole arrival

# The stages the stand walks.  They differ in where the hero stands and where
# the view stands, which is the whole of what the mode is made of.
STAGES = (0, 4, 9, 16, 19)


def records(path):
    out = []
    with open(path, 'rb') as f:
        while True:
            b = f.read(REC)
            if len(b) < REC:
                break
            fr, _pc, _bank = struct.unpack('<IHH', b[:8])
            out.append((fr, b[8:]))
    return out


def play(state, scratch, first):
    """Every picture of $CC77 the cartridge walks after he is killed."""
    inp = os.path.join(scratch, 'i.inp')
    out = os.path.join(scratch, 'r.bin')
    open(inp, 'w').write('0 -\n')
    cmd = [P.EMU, P.ROM, '-loadstate', state, '-input', inp,
           '-frames', str(first + RUN),
           '-ramat', '%s@%04X' % (out, AT),
           '-poke', '05A2=0C@%d' % (first + DIE)]
    subprocess.run(cmd, check=True, capture_output=True)
    return records(out)


def w16(m, lo, hi):
    return m[lo] | m[hi] << 8


def wanted(m):
    """What one record of the cartridge says, in the engine's own order."""
    return (m[0x02], m[0x03], m[0x57],
            [w16(m, 0x0720 + i, 0x0730 + i) for i in range(4)],
            [w16(m, 0x0740 + i, 0x0750 + i) for i in range(4)],
            w16(m, 0x30, 0x31), w16(m, 0x32, 0x33),
            list(m[0x200:0x300]), m[0x6A], m[0x6B], m[0x6C], m[0x6D])


def seed(m, ticks):
    """What the engine is handed to start from."""
    return dict(
        mode=m[0x02], z03=m[0x03], z57=m[0x57], z2e=m[0x2E],
        stage=m[0x55], lives=m[0x071C],
        px=[w16(m, 0x0720 + i, 0x0730 + i) for i in range(4)],
        py=[w16(m, 0x0740 + i, 0x0750 + i) for i in range(4)],
        home_x=w16(m, 0x0717, 0x0727), home_y=w16(m, 0x0737, 0x0747),
        hero_x=w16(m, 0x80, 0x81), hero_y=w16(m, 0x82, 0x83),
        hurt=m[0x05C2], state=m[0x05A2],
        cam_x=w16(m, 0x30, 0x31), cam_y=w16(m, 0x32, 0x33),
        oam=list(m[0x200:0x300]), count=m[0x6A], turn=m[0x6B],
        fwd=m[0x6C], back=m[0x6D], start=m[0x69], banks=[m[0x42], m[0x43],
                                                         m[0x44], m[0x45]],
        ticks=ticks)


def engine(cfg, scratch):
    path = os.path.join(scratch, 'flow.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                        '--solflow=%s' % path], capture_output=True, text=True,
                       timeout=300)
    rows = []
    for line in r.stdout.split('\n'):
        f = line.split()
        if len(f) != 18 or len(f[13]) != 512:
            continue
        rows.append((int(f[0], 16), int(f[1], 16), int(f[2], 16),
                     [int(x) for x in f[3:7]], [int(x) for x in f[7:11]],
                     int(f[11]), int(f[12]),
                     [int(f[13][i:i + 2], 16) for i in range(0, 512, 2)],
                     int(f[14]), int(f[15]), int(f[16]), int(f[17])))
    if not rows:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return rows


NAMES = ('mode', '$03', '$57', 'x of the four', 'y of the four',
         'view along', 'view down', 'sprite table', '$6A', '$6B', '$6C', '$6D')


def main():
    only = [int(a) for a in sys.argv[1:] if not a.startswith('--')]
    scratch = P.scratch('flow')
    try:
        bad = total = 0
        for st in STAGES:
            if only and st not in only:
                continue
            total += 1
            base = P.make_state(os.path.join(scratch, 'base'))
            first = V.BASE if st == 0 else V.WARPED
            state = (base if st == 0 else
                     P.warp(os.path.join(scratch, 's%d' % st), st, base))
            rows = play(state, scratch, first)
            if len(rows) < 8:
                print('s%-4d the mode was never reached' % st)
                bad += 1
                continue
            mem = [m for _fr, m in rows]
            # $00 as it stood at the top of each picture: that is what
            # $C72D of that picture writes into $6B, and the record that
            # shows it is the next one.
            got = engine(seed(mem[0], [m[0x00] for m in mem]), scratch)
            want = [wanted(m) for m in mem[1:]]
            n = min(len(want), len(got))
            where = None
            for i in range(n):
                if want[i] != got[i]:
                    where = i
                    break
            if where is None and len(got) >= len(want):
                print('s%-4d he arrives, %d pictures' % (st, len(want)))
                continue
            bad += 1
            if where is None:
                print('s%-4d stops after %d of %d pictures'
                      % (st, len(got), len(want)))
                continue
            print('s%-4d differs on picture %d' % (st, where))
            for name, a, b in zip(NAMES, want[where], got[where]):
                if a != b:
                    print('        %-14s cartridge %s, engine %s'
                          % (name, a, b))
        print('%d of %d arrivals differ' % (bad, total))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


if __name__ == '__main__':
    sys.exit(main())
