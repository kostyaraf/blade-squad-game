#!/usr/bin/env python3
"""Watch Tokkyuu Shirei Solbrain's memory while it plays.

The twin of `pb2_probe` for the other cartridge.  Same emulator, same scratch
rules, same way of making a savestate that stands in a level ready for input;
what differs is the cartridge, the boot and where the hero keeps himself.

The hero of Solbrain is not a slot of an object table the way Power Blade's is.
He keeps his place in four bytes of zero page and the rest of himself in a
block of forty five at $05A2, and the whole of his frame is one routine in bank
twelve: $9159, called from $9150.  All of that was established while a probe
cartridge was built to run two of him at once -- see work/re/sol_two_players.md.
"""
import os
import shutil
import subprocess
import tempfile
import time

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
EMU = os.path.join(ROOT, 'work', 'tools', 'nesemu')
ROM = os.path.join(ROOT, 'Tokkyuu Shirei Solbrain (Japan).nes')

# $05A2..$05CE -- the hero himself, forty five bytes of him.
SELF = 0x05A2
SELF_N = 45

# Zero page, what is known so far.
PAD1 = 0x04            # and $06, the other half of the same reading
PAD2 = 0x05            # the second player's, unused by the one player game
SPEED = 0x35
POS = 0x80             # $80:$81 along and $82:$83 down, sixteen to the pixel
CAM = 0x30             # $30:$31 along and $32:$33 down, the same scale
STAGE = 0x55


def self_byte(n):
    return SELF + n


# One roof for everything the emulator writes down, swept the moment it has
# been read -- the same rule as the other cartridge, and for the same reason:
# a sweep of a few hundred runs leaves gigabytes behind otherwise.
SCRATCH = os.path.join(tempfile.gettempdir(), 'solwork')


def scratch(prefix):
    os.makedirs(SCRATCH, exist_ok=True)
    _sweep_stale()
    return tempfile.mkdtemp(prefix=prefix, dir=SCRATCH)


# A run that is killed outright -- the machine running out of memory, a Ctrl-C
# in the wrong place -- never reaches its own `sweep`, and what it had written
# down stays under the roof for good.  So before a new one is opened, anything
# left there by a run that is no longer alive goes.  A directory younger than
# an hour is left alone: a run that is going on right now owns it.
STALE = 3600


def _sweep_stale():
    now = time.time()
    for name in os.listdir(SCRATCH):
        one = os.path.join(SCRATCH, name)
        if not os.path.isdir(one):
            continue
        try:
            if now - os.path.getmtime(one) < STALE:
                continue
        except OSError:
            continue
        shutil.rmtree(one, ignore_errors=True)


def sweep(path):
    shutil.rmtree(path, ignore_errors=True)


# Bytes of the cartridge written over before a run: study runs only, never the
# yardstick.
ROMPOKE = []


def emu(*args):
    cmd = [EMU, ROM]
    for off, val in ROMPOKE:
        cmd += ['-rompoke', '%X=%02X' % (off, val)]
    return cmd + list(args)


# Three presses of START walk the title, the tale and the picking of a stage.
# The numbers are where the cartridge answers, found by watching the screen.
BOOT = """1 -
650 START
660 -
760 START
770 -
900 START
910 -
"""
IN_LEVEL = 2250          # the first stage is up and the hero answers buttons


def make_state(path, frame=IN_LEVEL, boot=BOOT, pokes=()):
    """A savestate with the game standing in a stage, ready for input."""
    if os.path.exists(path):
        return path
    inp = path + '.inp'
    open(inp, 'w').write(boot)
    cmd = [EMU, ROM, '-input', inp, '-frames', str(frame + 1),
           '-savestate', '%s@%d' % (path, frame)]
    for a, v in pokes:
        cmd += ['-poke', '%04X=%02X@%d' % (a, v, frame - 3)]
    subprocess.run(cmd, check=True, capture_output=True)
    return path


def run(state, script, last, watch=(0x0000, 0x07FF), pokes=()):
    """Play `script` from `state` and answer {frame: {addr: value}}.

    `script` is a list of (frame, buttons); the value reported for a frame is
    the last written during it, and an address nobody wrote keeps what it had.
    """
    d = scratch('probe')
    inp = os.path.join(d, 'i.inp')
    log = os.path.join(d, 't.log')
    with open(inp, 'w') as f:
        for fr, keys in sorted(script):
            f.write('%d %s\n' % (fr, keys or '-'))
    cmd = emu('-loadstate', state, '-input', inp, '-frames', str(last),
              '-watch', '%04X-%04X' % watch, '-trace', log,
              '-tracefrom', '999999', '-traceto', '999999')
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


def ram(state, script, last, pokes=()):
    """The two kilobytes of work memory as they stand at frame `last`."""
    d = scratch('ram')
    inp = os.path.join(d, 'i.inp')
    out = os.path.join(d, 'r.bin')
    with open(inp, 'w') as f:
        for fr, keys in sorted(script):
            f.write('%d %s\n' % (fr, keys or '-'))
    cmd = emu('-loadstate', state, '-input', inp, '-frames', str(last),
              '-ramdump', out)
    for a, v, fr in pokes:
        cmd += ['-poke', '%04X=%02X@%d' % (a, v, fr)]
    try:
        subprocess.run(cmd, check=True, capture_output=True)
        return open(out, 'rb').read(0x800)
    finally:
        sweep(d)


def watched(state, script, first, last, addrs, pokes=()):
    """Frame by frame values of `addrs`, started from what they already held.

    The watch only says what was written, so a byte nobody touches would read
    as nothing.  A dump taken at the first frame gives every address its
    standing value, and the writes carry it on from there.
    """
    base = ram(state, script, first, pokes=pokes)
    w = run(state, script, last, pokes=pokes)
    cur = {a: base[a] for a in addrs}
    rows = []
    for fr in range(first, last + 1):
        cur.update({a: v for a, v in w.get(fr, {}).items() if a in addrs})
        rows.append((fr, dict(cur)))
    return rows


# The game keeps its mode in $02, and mode $1D is "raise the stage named in
# $55" ($D930 in the fixed bank).  Writing both of those into a game already
# standing in the first stage is how any other stage is reached without
# playing the ones before it.
WARP_MODE = 0x1D
WARP_SET = IN_LEVEL + 80  # after any savestate the first stage is taken at
WARP_IN = 2960           # by which the asked for stage is up and steerable


def warp(path, stage, base, frame=WARP_IN, pokes=()):
    """A savestate standing in `stage`, ready for input.

    `pokes` are (addr, value, frame) written on the way in, which is how the
    hero is set down somewhere other than the stage's own door.  They are baked
    into the state rather than replayed with it, so that the state is a clean
    frame boundary and the first frame played from it is a whole frame.
    """
    if os.path.exists(path):
        return path
    inp = path + '.inp'
    open(inp, 'w').write('%d -\n' % (WARP_SET - 4))
    cmd = [EMU, ROM, '-loadstate', base, '-input', inp,
           '-frames', str(frame + 1),
           '-poke', '0055=%02X@%d' % (stage, WARP_SET),
           '-poke', '0002=%02X@%d' % (WARP_MODE, WARP_SET + 1),
           '-savestate', '%s@%d' % (path, frame)]
    for a, v, fr in pokes:
        cmd += ['-poke', '%04X=%02X@%d' % (a, v, fr)]
    subprocess.run(cmd, check=True, capture_output=True)
    return path
