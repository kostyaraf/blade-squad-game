#!/usr/bin/env python3
"""Warp into a PB3 stage and take pictures of it.

The engine has a mode ($35) whose whole job is "load the level $55 names", so
a test run is: play the title screen normally until the first level is up --
which is what sets the status bar and the raster split -- then write the stage
number and drop the game back into that mode.

    python3 work/pb3/v2/warp.py 20 21 22 -at 60,240,600
"""
import argparse
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
EMU = os.path.join(ROOT, 'work/tools/nesemu')
ROM = os.path.join(ROOT, 'work/build/PB3.nes')
SCRATCH = os.environ.get('PB3_SCRATCH', '/tmp/pb3')
ENTER = 3290                    # the first level is up and running by here


def _boot(scratch):
    """Play the title screen through to the first level, and stop there.

    A saved state carries the cartridge's work RAM with it, and the runtime
    lives there, so a state saved from an older build is not merely stale but
    actively wrong.  The state is therefore stamped with the ROM it came from
    and thrown away when that changes.
    """
    stamp = os.path.join(scratch, 'ingame.rom')
    now = '%d %d' % (os.path.getmtime(ROM), os.path.getsize(ROM))
    st = os.path.join(scratch, 'ingame.st')
    if os.path.exists(st) and os.path.exists(stamp) \
            and open(stamp).read() == now:
        return st
    inp = os.path.join(scratch, 'start.inp')
    with open(inp, 'w') as f:
        for fr in range(60, ENTER - 300, 60):
            f.write('%d START\n%d -\n' % (fr, fr + 6))
    subprocess.run([EMU, ROM, '-input', inp, '-frames', str(ENTER + 2),
                    '-savestate', '%s@%d' % (st, ENTER)],
                   check=True, capture_output=True)
    open(stamp, 'w').write(now)
    return st


def run(stage, at, scratch, tag=None, extra=()):
    st = _boot(scratch)
    tag = tag or 's%d' % stage
    last = ENTER + 10 + max(at)
    args = [EMU, ROM, '-loadstate', st, '-frames', str(last),
            '-poke', '0055=%02X@%d' % (stage, ENTER + 5),
            '-poke', '0002=35@%d' % (ENTER + 6),
            '-shot', ','.join(str(ENTER + 10 + a) for a in at),
            '-png', os.path.join(scratch, tag)] + list(extra)
    subprocess.run(args, check=True, capture_output=True)
    return [os.path.join(scratch, '%s_%d.png' % (tag, ENTER + 10 + a))
            for a in at]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('stage', nargs='+', type=lambda s: int(s, 0))
    ap.add_argument('-at', default='300')
    ap.add_argument('-scratch', default=SCRATCH)
    a = ap.parse_args()
    os.makedirs(a.scratch, exist_ok=True)
    at = [int(x) for x in a.at.split(',')]
    _boot(a.scratch)
    for s in a.stage:
        for p in run(s, at, a.scratch):
            print(p)


if __name__ == '__main__':
    main()
