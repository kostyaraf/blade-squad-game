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
import time

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
    _sweep_stale()
    return tempfile.mkdtemp(prefix=prefix, dir=SCRATCH)


# A run that is killed outright -- the machine running out of memory, a Ctrl-C
# in the wrong place -- never reaches its own `sweep`, and what it had written
# down stays under the roof for good.  (That is where the gigabytes came from.)
# So before a new one is opened, anything left there by a run that is no longer
# alive goes.  A directory younger than an hour is left alone: a run that is
# going on right now owns it.  The savestates kept here are files, not
# directories, and are not touched -- they are the cache that makes a second
# run of a stand quick.
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


# Bytes of the cartridge to write over before a run.  Nothing that changes how
# the game plays belongs here: this is for study runs, never for the yardstick.
ROMPOKE = []

# Addresses rewritten at the start of every frame from a given frame on, same
# idea and same warning: a study aid.  Pinning the hero's place on the screen at
# one end or the other makes the view chase him and walk the whole of an area,
# and a second pinning further in walks it back again.  (addr, val, from).
FREEZE = []

# Two ways he dies, both stopped, so that the view can be walked from one end
# of an area to the other -- which is what seeing the whole of a level's list of
# things needs.
#
#   $B3F5 in bank 9 is LDA #$00 / STA $049A / RTS, the fall down a pit.  An RTS
#   in its place and the fall costs nothing.
#
#   $B3D2 in bank 7 is the SBC $00 of the damage routine at $B3C0, which takes
#   the hit off his health.  Made SBC #$00 it takes nothing off, leaves the
#   carry set, and the two branches below it walk past the death.  Everything
#   else about being hit -- the flash, the knock back -- still happens.
#
#   $A17A in bank 9 is the look at where he is: no health, or off the foot of
#   the screen ($04C6 past $C7), and he is dead.  Made a jump to the RTS at its
#   own end it never finds him dead.  It is the one that catches a hero pinned
#   against an edge with nothing under him, which is how a view is walked.
IMMORTAL = ((9 * 8192 + (0xB3F5 - 0xA000), 0x60),
            (7 * 8192 + (0xB3D2 - 0xA000), 0xE9),
            (9 * 8192 + (0xA17A - 0xA000), 0x4C),
            (9 * 8192 + (0xA17B - 0xA000), 0x93),
            (9 * 8192 + (0xA17C - 0xA000), 0xA1))


def emu(*args):
    """The emulator command line, with any cartridge patches in front."""
    cmd = [EMU, ROM]
    for off, val in ROMPOKE:
        cmd += ['-rompoke', '%X=%02X' % (off, val)]
    for ent in FREEZE:
        addr, val, since = ent[0], ent[1], ent[2]
        # A fourth number is the last frame it is held for: a pinning that has
        # to be let go of again, so that what happens after it is the game's.
        upto = ent[3] if len(ent) > 3 else None
        cmd += ['-freeze', '%04X=%02X@%d%s'
                % (addr, val, since, '' if upto is None else '-%d' % upto)]
    return cmd + list(args)


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
               spot=None, pokes=(), patch=False, early=()):
    """A savestate with the game standing in a level, ready for input.

    Which level is the game's business, except that it writes the stage and
    the area into $53 and $9C one frame before it reads them back to load the
    thing -- so writing them ourselves in that gap opens any level there is.
    """
    if os.path.exists(path):
        return path
    inp = path + '.inp'
    open(inp, 'w').write(boot)
    # The boot is played on the plain cartridge: a study patch belongs to the
    # run that uses it, not to the state every run starts from.
    #
    # `patch` is the one exception, and it is asked for by name.  A boss room
    # opened out of turn takes four hundred frames to load itself properly,
    # and a boss kills an idle hero inside that time -- so the making of the
    # state itself has to be run with the cartridge patched, or there is no
    # live hero at the end of it to hand over.
    cmd = [EMU, ROM]
    if patch:
        for off, val in ROMPOKE:
            cmd += ['-rompoke', '%X=%02X' % (off, val)]
    cmd += ['-input', inp, '-frames', str(frame + 1),
            '-savestate', '%s@%d' % (path, frame)]
    if stage is not None:
        cmd += ['-poke', '0053=%02X@%d' % (stage, PICK_LEVEL)]
    if area is not None:
        cmd += ['-poke', '009C=%02X@%d' % (area, PICK_LEVEL)]
    # Bytes set in the same gap, after the stage and the area, for a room the
    # game does not open by walking into it.  A boss room is stage six's data
    # with $79 set ($86F7, $84FE), and $53 is left holding the stage the boss
    # belongs to, because that is what the boss reads to know which of the
    # twelve it is ($8737, $87C3).  So the two cannot be the same number, and
    # the one the room is filed under is not the one the cartridge wants.
    for a, v in early:
        cmd += ['-poke', '%04X=%02X@%d' % (a, v, PICK_LEVEL)]
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
    # Anything else the caller wants set before it takes control: which suit
    # he is wearing, how far the blade has been raised, how many throws may be
    # in the air at once.  None of these is reached by playing from the start
    # of the game in the time a study run has.
    for a, v in pokes:
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


def require_steps(writes, first, last, clock=0x1C):
    """Reject empty/stationary oracles; `-frames` and pokes are absolute.

    Opt-in: probes of a particular RAM address may legitimately see no writes,
    but a game-loop differential fixture must observe an advancing clock.
    """
    values = [row[clock] for frame, row in writes.items()
              if first <= frame <= last and clock in row]
    if len(values) < 2 or len(set(values)) < 2:
        raise RuntimeError(f'NES oracle executed no observable game steps in '
                           f'absolute frames {first}..{last}')


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
