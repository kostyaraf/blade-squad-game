#!/usr/bin/env python3
"""Watch Power Blade 2's memory while it plays.

Reverse engineering by reading alone gets the shape of a thing but not its
numbers.  This runs the real game with a script of button presses and reports,
frame by frame, what any address held -- which is where the numbers come from.
"""
import os
import subprocess
import tempfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
EMU = os.path.join(ROOT, 'work', 'tools', 'nesemu')
ROM = os.path.join(ROOT, 'Power Blade 2 (USA).nes')

# The player object lives in slot 0 of a table whose fields are 22 bytes apart.
OBJ = 0x0400
STRIDE = 22
NFIELD = 24


def field(f, slot=0):
    return OBJ + STRIDE * f + slot


BOOT = """1 -
300 START
308 -
700 START
708 -
1000 START
1008 -
"""
IN_LEVEL = 1450          # the first area is up and the player has control


def make_state(path, frame=IN_LEVEL, boot=BOOT):
    """A savestate with the game in the first area, ready for input."""
    if os.path.exists(path):
        return path
    inp = path + '.inp'
    open(inp, 'w').write(boot)
    subprocess.run([EMU, ROM, '-input', inp, '-frames', str(frame + 1),
                    '-savestate', '%s@%d' % (path, frame)],
                   check=True, capture_output=True)
    return path


def run(state, script, last, watch=(0x0000, 0x07FF), pokes=()):
    """Play `script` from `state` and return {frame: {addr: value}}.

    `script` is a list of (frame, buttons) with buttons like 'RIGHT,A' or '-'.
    The value reported for a frame is the last one written during it; an
    address that was not written keeps what it had.
    """
    d = tempfile.mkdtemp(prefix='pb2probe')
    inp = os.path.join(d, 'i.inp')
    log = os.path.join(d, 't.log')
    with open(inp, 'w') as f:
        for fr, keys in sorted(script):
            f.write('%d %s\n' % (fr, keys or '-'))
    cmd = [EMU, ROM, '-loadstate', state, '-input', inp, '-frames', str(last),
           '-watch', '%04X-%04X' % watch, '-trace', log,
           '-tracefrom', '999999', '-traceto', '999999']
    for a, v, fr in pokes:
        cmd += ['-poke', '%04X=%02X@%d' % (a, v, fr)]
    subprocess.run(cmd, check=True, capture_output=True)

    out = {}
    for line in open(log):
        if not line.startswith('WATCH'):
            continue
        fr, _pc, _bank, addr, val = line[6:].strip().split(',')
        out.setdefault(int(fr), {})[int(addr, 16)] = int(val, 16)
    return out


def table(writes, addrs, first, last):
    """Carry each address forward through the frames that did not write it."""
    cur = {}
    rows = []
    for fr in range(min(writes) if writes else first, last + 1):
        cur.update({a: v for a, v in writes.get(fr, {}).items() if a in addrs})
        if first <= fr <= last:
            rows.append((fr, dict(cur)))
    return rows


def writers(writes, addr):
    """Which code writes an address -- bank and PC, with how often."""
    seen = {}
    for fr, d in writes.items():
        pass
    return seen
