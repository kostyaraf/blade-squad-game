#!/usr/bin/env python3
"""Record what Power Blade 2's hero did, frame by frame.

This is the yardstick for the port.  It plays the real cartridge with a script
of button presses and writes one line per frame: the buttons that were held,
where the camera was, and every number the hero's physics keeps.  The engine
is then asked to play the same script and must produce the same lines.
"""
import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import pb2_probe as P                                       # noqa: E402

# What we follow.  The hero's fields are named in work/re/pb2_player.md.
WATCH = {
    'pad':   0x4A,
    'hit':   0x48,
    'cam_h': 0x66, 'cam_l': 0x67,
    'axis':  0x97,
    'stage': 0x53, 'area': 0x9C,
    'state': P.field(1),  'face': P.field(2),  'pose': P.field(3),
    'anim_t': P.field(5), 'anim_f': P.field(6),
    'yh': P.field(8),  'yp': P.field(9),  'yf': P.field(10),
    'xh': P.field(11), 'xp': P.field(12), 'xf': P.field(13),
    'vyh': P.field(14), 'vyl': P.field(15),
    'vxh': P.field(16), 'vxl': P.field(17),
    'sub': P.field(18), 'scale': P.field(19),
    # How many shots of his own are still in the air, and how many he is
    # allowed: $A3D9 refuses a new throw while the boomerang is out.
    'tick': 0x0110,          # counts the frames; animations follow its parity
    'acc0': 0x0111, 'acc1': 0x0112, 'acc2': 0x0113,
    'mode': 0x27,            # $27: 3 is ordinary play, 6 is a scripted pan
    'alive': 0x049A,         # zero the moment something kills him
    'lim': 0x99, 'p1': 0x0401, 'p2': 0x0402, 'p3': 0x0403,
}
SHOT_SLOTS = (0x0401, 0x0402, 0x0403)
SPAWN_PC = 'A2A9'        # where a new shot takes its slot in the object table

LO = min(WATCH.values())
HI = max(WATCH.values())


def trace(script, frames, state=None, first=None, stage=None, area=None,
          spot=None):
    """Play `script` and return a list of dicts, one per frame.

    Two runs are needed: the first stops at the starting frame and dumps all of
    memory, because a watch log only reports what changed; the second replays
    with the log and the starting values are carried forward.
    """
    first = P.IN_LEVEL if first is None else first
    state = state or os.path.join(tempfile.gettempdir(), 'pb2_%d_%s_%s_%s.st'
                                  % (first, stage, area, spot))
    P.make_state(state, frame=first, stage=stage, area=area, spot=spot)
    d = tempfile.mkdtemp(prefix='pb2trace')
    ram = os.path.join(d, 'start.ram')
    inp = os.path.join(d, 'i.inp')
    log = os.path.join(d, 't.log')
    with open(inp, 'w') as f:
        for fr, keys in sorted(script):
            f.write('%d %s\n' % (first + fr, keys or '-'))

    # the state of memory the run starts from
    subprocess.run([P.EMU, P.ROM, '-loadstate', state, '-frames', str(first + 1),
                    '-ramdump', ram], check=True, capture_output=True)
    mem = bytearray(open(ram, 'rb').read())

    last = first + frames
    subprocess.run([P.EMU, P.ROM, '-loadstate', state, '-input', inp,
                    '-frames', str(last + 1),
                    '-watch', '%04X-%04X' % (LO, HI), '-trace', log,
                    '-tracefrom', '999999', '-traceto', '999999'],
                   check=True, capture_output=True)
    changes = {}
    for ln in open(log):
        if not ln.startswith('WATCH'):
            continue
        fr, pc, _bank, addr, val = ln[6:].strip().split(',')
        changes.setdefault(int(fr), []).append((int(addr, 16), int(val, 16), pc))

    # Also follow the low addresses, which the watch window above may not cover.
    lo_log = os.path.join(d, 'lo.log')
    subprocess.run([P.EMU, P.ROM, '-loadstate', state, '-input', inp,
                    '-frames', str(last + 1), '-watch', '0040-00A0',
                    '-trace', lo_log, '-tracefrom', '999999',
                    '-traceto', '999999'], check=True, capture_output=True)
    for ln in open(lo_log):
        if not ln.startswith('WATCH'):
            continue
        fr, pc, _bank, addr, val = ln[6:].strip().split(',')
        changes.setdefault(int(fr), []).append((int(addr, 16), int(val, 16), pc))

    out = []
    for fr in range(first, last + 1):
        # How many of his shots were in the air when he pressed the button:
        # the frame's own throw ($A2A9) has not been counted yet, but the
        # sweep that retires dead objects has already run.
        shots = None
        for addr, val, pc in changes.get(fr, ()):
            if pc == SPAWN_PC and shots is None:
                shots = sum(1 for a in SHOT_SLOTS if mem[a])
            mem[addr] = val
        row = {'frame': fr - first}
        for name, addr in WATCH.items():
            row[name] = mem[addr]
        row['x'] = (row['xh'] << 16) | (row['xp'] << 8) | row['xf']
        row['y'] = (row['yh'] << 16) | (row['yp'] << 8) | row['yf']
        row['vx'] = _s16((row['vxh'] << 8) | row['vxl'])
        row['vy'] = _s16((row['vyh'] << 8) | row['vyl'])
        row['cam'] = (row['cam_h'] << 8) | row['cam_l']
        row['fall'] = (row['acc2'] << 16) | (row['acc1'] << 8) | row['acc0']
        if row['acc2'] & 0x80:
            row['fall'] -= 1 << 24
        row['shots'] = (sum(1 for k in ('p1', 'p2', 'p3') if row[k])
                        if shots is None else shots)
        out.append(row)
    return out


def _s16(v):
    return v - 0x10000 if v & 0x8000 else v


def main():
    script = [(2, '-')]
    for arg in sys.argv[1:]:
        fr, _, keys = arg.partition(':')
        script.append((int(fr), keys))
    rows = trace(script, 120)
    for r in rows:
        print('%3d pad=%02X cam=%4d x=%5.2f y=%5.2f vx=%7.3f vy=%7.3f '
              'st=%02X sub=%2d pose=%2d'
              % (r['frame'], r['pad'], r['cam'], r['x'] / 256.0, r['y'] / 256.0,
                 r['vx'] / 256.0, r['vy'] / 256.0, r['state'], r['sub'],
                 r['pose']))


if __name__ == '__main__':
    main()
