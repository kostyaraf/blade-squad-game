#!/usr/bin/env python3
"""Drive a PB3 stage from a script of button presses and read the result.

`warp.py` takes pictures; this takes measurements.  Everything here is one
call: boot to the first level, warp to the stage under test, run the pad
script, and hand back the numbers that say what happened.
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import warp                                             # noqa: E402

E = warp.ENTER
CONTROL = 100                   # the hero's run-in is over by here


def go(stage, script=(), frames=300, scratch=None, pokes=(), shot=False,
       tag='probe', watch=None):
    """`script` is a list of (frame, keys); frame 0 is the moment the stage is
    up.  Returns the interesting bytes of the run's last frame."""
    scratch = scratch or warp.SCRATCH
    os.makedirs(scratch, exist_ok=True)
    st = warp._boot(scratch)
    inp = os.path.join(scratch, tag + '.inp')
    with open(inp, 'w') as f:
        for fr, keys in (script or [(0, '-')]):
            f.write('%d %s\n' % (E + 10 + fr, keys))
    ram = os.path.join(scratch, tag + '.ram')
    last = E + 10 + frames
    args = [warp.EMU, warp.ROM, '-loadstate', st, '-frames', str(last + 2),
            '-input', inp, '-ramdump', ram,
            '-poke', '0055=%02X@%d' % (stage, E + 5),
            '-poke', '0002=35@%d' % (E + 6)]
    for p in pokes:
        args += ['-poke', p]
    if shot:
        args += ['-shot', str(last), '-png', os.path.join(scratch, tag)]
    log = None
    if watch:
        log = os.path.join(scratch, tag + '.log')
        args += ['-trace', log, '-tracefrom', str(last), '-traceto',
                 str(last + 1), '-watch', watch]
    subprocess.run(args, check=True, capture_output=True)
    d = open(ram, 'rb').read()
    seen = []
    if log:
        for line in open(log):
            if line.startswith('WATCH '):
                f = line[6:].split(',')
                seen.append((int(f[0]), int(f[3], 16), int(f[4], 16)))
    return {
        'watch': seen,
        'x': (d[0x80] | (d[0x81] << 8)) // 16,
        'y': (d[0x82] | (d[0x83] << 8)) // 16,
        'stage': d[0x55], 'hp': d[0x5C5], 'mode': d[0x02],
        'state': d[0x5A2], 'camx': (d[0x30] | (d[0x31] << 8)) // 16,
        'camy': (d[0x32] | (d[0x33] << 8)) // 16,
        'shot': os.path.join(scratch, '%s_%d.png' % (tag, last)),
    }


def at(frame, keys):
    return (frame, keys)
