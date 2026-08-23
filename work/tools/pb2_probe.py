#!/usr/bin/env python3
"""Watch Power Blade 2's memory while it plays.

Reverse engineering by reading alone gets the shape of a thing but not its
numbers.  This runs the real game with a script of button presses and reports,
frame by frame, what any address held -- which is where the numbers come from.
"""
import os
import shutil
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


# Everything the emulator is asked to write down goes under one roof, so that a
# run that dies half way leaves one place to sweep and not a hundred.  A trace
# of a few hundred frames is megabytes, and a sweep makes thousands of them, so
# each is thrown away the moment it has been read.
SCRATCH = os.path.join(tempfile.gettempdir(), 'pb2work')


def scratch(prefix):
    os.makedirs(SCRATCH, exist_ok=True)
    return tempfile.mkdtemp(prefix=prefix, dir=SCRATCH)


def sweep(path):
    shutil.rmtree(path, ignore_errors=True)


BOOT = """1 -
300 START
308 -
700 START
708 -
1000 START
1008 -
"""
IN_LEVEL = 1450          # the first area is up and the player has control
PICK_LEVEL = 1052        # $53 and $9C are chosen at 1051; this is right after


def make_state(path, frame=IN_LEVEL, boot=BOOT, stage=None, area=None,
               spot=None):
    """A savestate with the game standing in a level, ready for input.

    Which level is the game's business, except that it writes the stage and
    the area into $53 and $9C one frame before it reads them back to load the
    thing -- so writing them ourselves in that gap opens any level there is.
    """
    if os.path.exists(path):
        return path
    inp = path + '.inp'
    open(inp, 'w').write(boot)
    cmd = [EMU, ROM, '-input', inp, '-frames', str(frame + 1),
           '-savestate', '%s@%d' % (path, frame)]
    if stage is not None:
        cmd += ['-poke', '0053=%02X@%d' % (stage, PICK_LEVEL)]
    if area is not None:
        cmd += ['-poke', '009C=%02X@%d' % (area, PICK_LEVEL)]
    if spot is not None:
        # Where he stands is his own business everywhere except here, where
        # the area was opened behind the game's back and his feet are still
        # standing on the map it meant to give him.
        sx, sy = spot
        for a, v in ((field(11), 0), (field(12), sx), (field(13), 0),
                     (field(8), 0), (field(9), sy), (field(10), 0),
                     (field(14), 0), (field(15), 0),
                     (field(16), 0), (field(17), 0)):
            cmd += ['-poke', '%04X=%02X@%d' % (a, v, frame - 3)]
    subprocess.run(cmd, check=True, capture_output=True)
    return path


def run(state, script, last, watch=(0x0000, 0x07FF), pokes=()):
    """Play `script` from `state` and return {frame: {addr: value}}.

    `script` is a list of (frame, buttons) with buttons like 'RIGHT,A' or '-'.
    The value reported for a frame is the last one written during it; an
    address that was not written keeps what it had.
    """
    d = scratch('probe')
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
    try:
        subprocess.run(cmd, check=True, capture_output=True)
        out = {}
        for line in open(log):
            if not line.startswith('WATCH'):
                continue
            fr, _pc, _bank, addr, val = line[6:].strip().split(',')
            out.setdefault(int(fr), {})[int(addr, 16)] = int(val, 16)
        return out
    finally:
        sweep(d)


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
