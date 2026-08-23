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
    'pend': 0x60,            # $60: how far the view still has to slide
    'allow': 0x0116,         # $0116: how far it may slide in one frame
    'mode': 0x27,            # $27: 3 is ordinary play, 6 is a scripted pan
    'alive': 0x049A,         # zero the moment something kills him
    'lim': 0x99, 'p1': 0x0401, 'p2': 0x0402, 'p3': 0x0403,
    'hold': 0x0668,          # see HOLD below; here only to widen the window
    'px': 0x063C, 'py': 0x0652,
}
SHOT_SLOTS = (0x0401, 0x0402, 0x0403)
# $AC5C: the objects that are solid to him keep a box each -- left, right,
# top, bottom, in the screen's own numbers -- and $011F says how many.
SOLID_N = 0x011F
SOLID = (0x011F, 0x012F, 0x013F, 0x014F)
# $8E55: the count is wiped at the end of the hero's update, so the boxes have
# to be read out just before that -- a dump taken between frames shows none.
SOLID_PC = '8E55'
# $0668: what the level itself decides about him -- a boss room pins him where
# he stands by declaring floor, ceiling and both walls solid.  It has to be
# read before his own update adds the mud to it and then wipes the lot.
HOLD = 0x0668
HOLD_PC = ('B47B', '8E4C')
# $063C and $0652: how far a moving floor is carrying him this frame, along and
# down.  Wiped at the end of his update like the rest, so read the same way.
PUSH = ((0x063C, '8E46'), (0x0652, '8E49'))
# $D34D and $D389: before anything else moves, the view's own movement is taken
# off every object, because they are all kept in the view's frame of reference.
# How far is $94, which is not worth following on its own -- the store itself
# says it, being the old value less the shift.
SHIFT = ((0x04C6, 'D363'), (0x0508, 'D392'))
SPAWN_PC = 'A2A9'        # where a new shot takes its slot in the object table
# His own speed and his own step for the frame.  Only his own code -- banks 8
# and 9 -- has any business writing these, so when another bank does, he is not
# being played any more: something in the level has taken hold of him and is
# carrying him about, which belongs to the enemies and not to him.
SEIZE = (0x0534, 0x054A, 0x05FA, 0x0610)
OWN_BANKS = ('8', '9')

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
    seized = set()
    for ln in open(log):
        if not ln.startswith('WATCH'):
            continue
        fr, pc, bank, addr, val = ln[6:].strip().split(',')
        if int(addr, 16) in SEIZE and bank not in OWN_BANKS:
            seized.add(int(fr))
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
        solids = None
        hold = None
        push = [None, None]
        shift = 0
        for addr, val, pc in changes.get(fr, ()):
            for a, apc in SHIFT:
                if addr == a and pc == apc:
                    shift = _s8((mem[a] - val) & 0xFF)
            if addr == HOLD and pc in HOLD_PC and hold is None:
                hold = mem[HOLD]
            for k, (a, apc) in enumerate(PUSH):
                if addr == a and pc == apc and push[k] is None:
                    push[k] = mem[a]
            if pc == SPAWN_PC and shots is None:
                shots = sum(1 for a in SHOT_SLOTS if mem[a])
            if addr == SOLID_N and pc == SOLID_PC and solids is None:
                solids = [[mem[a + i] for a in SOLID]
                          for i in range(1, mem[SOLID_N] + 1)]
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
        # These four are wiped at the end of the hero's update, so a frame in
        # which the update did not run has nothing to say about them -- and a
        # step of the game's own can be spread over two frames.  Nothing seen
        # is written down as nothing seen, and putting the step back together
        # is left to whoever asked ($8E4C..$8E55).
        row['solids'] = solids
        row['hold'] = hold
        row['push'] = [None if push[k] is None else _s8(push[k])
                       for k in range(len(PUSH))]
        row['shift'] = shift
        row['seized'] = fr in seized
        out.append(row)
    return out


def _s8(v):
    return v - 0x100 if v & 0x80 else v


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
