#!/usr/bin/env python3
"""Export what a screen needs besides its tiles: the colours and the tile banks.

`sol_screens.py` reads the streams out of the cartridge and so knows what every
screen of Solbrain writes.  It does not know what the screen looks like,
because the writes on their own are nothing: the console draws them out of four
thousand bytes of tiles, which the cartridge swaps as the beam goes down, and
in sixteen colours it keeps in a shadow at $0100 and flushes at the top of the
frame.  Both are settled by the mode that put the screen up, and each mode
settles them its own way out of a little table of its own.

Rather than read a dozen of those ways out of the cartridge by hand, this walks
the cartridge to each screen and writes down what stands there: which screens
were drawn, the thirty two colours, the four background banks line by line, and
how the two name maps are mirrored.  Which screens were drawn is not guessed --
$EF8C is the one door a screen goes through, and the emulator is asked to note
the number in A every time the cartridge stands there.

The maker's mark, the title, the tale and the picking of a stage are all on the
way the cartridge walks when it is switched on, so they are taken by letting it
walk.  The rest are reached by putting their number in $02, which is what the
flow does ($C9B4, and `work/re/sol_flow.md` names them all).
"""
import os
import struct
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
from common import outdir, write_json                           # noqa: E402
import sol_probe as P                                           # noqa: E402

DOOR = 0xEF8C             # the one way a screen is drawn
WALK = 2300               # frames of the switch-on walk worth watching

# What is on the walk, named by the screen the walk draws: how long after it is
# drawn the picture has settled enough to be written down.
WALKED = {0x0A: ('title', 480), 0x33: ('tale', 60), 0x30: ('select', 60)}
# The city is waited on for sixty pictures and no more.  Wait longer and what
# is written down is the change going off over it: mode $3A flashes three of
# the colours white and $3D leaves them there, so a later picture has a screen
# of white and says nothing about the city at all.

# And what is not: the number that goes in $02, and the name of what it shows.
## A screen and how long to wait for it: the number that goes in $02, the name
## of what it shows, and, where the mode does not stand still, how many pictures
## after the poke the board should be written down.  Where nothing is said the
## usual wait is taken.
MODES = (
    ('best', 0x0E),         # $D6CA -- BEST 5, the five high scores
    ('test', 0x24),         # $D79F -- TEST MODE, the maker's own menu
    ('bgm', 0x2A),          # $D863 -- BGM TEST
    ('sound', 0x33),       # $D8C7 -- the sound test
    ('over', 0x14),         # $D974 -- GAME OVER
    ('cleared', 0x1B),      # $E09C -- AREA x CLEARED
    ('staff', 0x4E),        # $E3E7 -- the names at the end
    ('bonus', 0x4C),        # $E33A -- what the whole game paid, at the end of it
    # $DAE3 -- the board STAGE SELECT is played on: five empty frames and the
    # man below them.  It does not stand: $DBAE walks the board up the screen
    # and then writes a picture into each frame, so the board has to be
    # written down early, while it is still the screen and nothing else.  $55
    # has to be something other than nought or $DAF2 goes straight on to $1D
    # and draws nothing at all.
    ('stages', 0x19, 40, ('0055=01',)),
)

## What a mode does to the board besides laying its screens, which the dump on
## its own cannot say.
##
## * `fill` -- the tile each of the two kilobytes is wiped with before the
##   screens go on, the last sixty four of each always being nought.  $E350
##   fills both with $0F, which is the sky behind whatever screen $39 writes,
##   and $E353 then wipes the second back to nought; every other mode wipes
##   both with nought.
## * `fold` -- which way the two boards were mirrored **while the screens were
##   being written**, where that is not the way they are mirrored afterwards.
##   $E38B turns the ending's boards across only after screen $39 has gone on,
##   so its writes above $2400 landed in the second kilobyte and stayed there.
EXTRA = {'bonus': {'fill': [0x0F, 0x00], 'fold': 1}}

POKE_AT = P.IN_LEVEL + 5
SETTLED = P.IN_LEVEL + 130


def samples(log):
    """Frame and number of every screen the run drew."""
    out = []
    for line in open(log):
        if line.startswith('SAMPLE'):
            fr, _pc, _bank, _reg, val = line[7:].strip().split(',')
            out.append((int(fr), int(val, 16)))
    return out


def vram(path):
    """One `-vram` dump, unpacked.  The layout is `nesemu.c`'s own."""
    b = open(path, 'rb').read()
    assert b[:8] == b'PB3VRAM1', path
    scan = struct.unpack('<%dH' % (240 * 8), b[2382:2382 + 240 * 8 * 2])
    return {
        'ciram': b[12:12 + 2048],
        'pal': list(b[2060:2092]),
        'chr': list(struct.unpack('<8H', b[2348:2364])),
        'oam': list(b[2092:2348]),
        'mirror': b[2364],
        'ctrl': b[2365],
        'mask': b[2366],
        'v': struct.unpack('<H', b[2367:2369])[0],
        'fine_x': b[2369],
        'scan': [list(scan[y * 8:y * 8 + 8]) for y in range(240)],
    }


def bands(d):
    """The four background banks, line by line, folded into runs."""
    out = []
    for y in range(240):
        four = d['scan'][y][:4]
        if not out or out[-1][1] != four:
            out.append([y, four])
    return out


def scene(name, drew, d, got, how):
    """One record, and a line saying how well it is understood.

    `got` is what the console's own name map held; the tiles the screens
    account for are counted against it, and what is left over is what the mode
    wrote itself -- a score, a name, a cursor.  Printing it is the whole check:
    a screen that is all its own writes reads +0.
    """
    over = [i for i in range(0x800) if got[i] != d['ciram'][i]]
    left = len(over)
    fill = EXTRA.get(name, {}).get('fill', [0, 0])
    rec = {
        'how': how,
        'fill': fill,
        'fold': EXTRA.get(name, {}).get('fold', d['mirror']),
        'screens': drew,
        'palette': d['pal'],
        'chr': d['chr'],
        'bands': bands(d),
        'mirror': d['mirror'],
        'ctrl': d['ctrl'],
        'mask': d['mask'],
        'scroll': [(d['v'] & 0x1F) * 8 + d['fine_x'],
                   ((d['v'] >> 5) & 0x1F) * 8 + ((d['v'] >> 12) & 7)],
    }
    print('%-8s screens %s  banks %s  %d bands  mirror %d  wipe $%02X/$%02X'
          '  +%d written over'
          % (name, ' '.join('$%02X' % s for s in drew), d['chr'][:4],
             len(rec['bands']), d['mirror'], fill[0], fill[1], left))
    return rec


def lay(screens, numbers, mirror, fill=(0, 0)):
    """The board as the drawn screens leave it: wiped, then written on.

    The console has two kilobytes of name map and four places to put them, so
    which of the two a write lands in is the mirroring's business: across, the
    first two places are the same memory; down, the first and the third are.
    """
    board = bytearray(0x0800)
    for k in (0, 1):
        for i in range(0x3C0):
            board[k * 0x400 + i] = fill[k]
    for n in numbers:
        key = '%04X' % screens['screens'][n]
        for addr, step, bytes_ in screens['streams'][key]['writes']:
            for b in bytes_:
                a = addr & 0x0FFF
                a = (a & 0x03FF) | (0x400 if (a & (0x400 if mirror else 0x800))
                                    else 0)
                board[a] = b
                addr += step
    return board


def walk(d, screens):
    """The switch-on walk, watched once and then taken again for the pictures."""
    inp = os.path.join(d, 'walk.inp')
    open(inp, 'w').write(P.BOOT)
    log = os.path.join(d, 'walk.log')
    subprocess.run([P.EMU, P.ROM, '-input', inp, '-frames', str(WALK),
                    '-sample', '%04X=A' % DOOR, '-trace', log,
                    '-tracefrom', '999999', '-traceto', '999999'],
                   check=True, capture_output=True)
    drew = samples(log)
    want = {}                     # frame to dump -> (name, screens by then)
    for i, (fr, n) in enumerate(drew):
        if n not in WALKED:
            continue
        name, after = WALKED[n]
        same = [m for f, m in drew if fr <= f <= fr + 2]
        want[fr + after] = (name, same)
    cmd = [P.EMU, P.ROM, '-input', inp, '-frames', str(WALK)]
    for at in sorted(want):
        cmd += ['-vram', '%s/w%d.bin@%d' % (d, at, at)]
    subprocess.run(cmd, check=True, capture_output=True)
    out = {}
    for at in sorted(want):
        name, same = want[at]
        one = vram('%s/w%d.bin' % (d, at))
        out[name] = scene(name, same, one, lay(
            screens, same, EXTRA.get(name, {}).get('fold', one['mirror']),
            EXTRA.get(name, {}).get('fill', (0, 0))), ['walk', at])
    return out


def poked(d, screens, state, name, mode, wait=None, also=()):
    inp = os.path.join(d, 'p.inp')
    open(inp, 'w').write('%d -\n' % (P.IN_LEVEL + 1))
    log = os.path.join(d, name + '.log')
    out = os.path.join(d, name + '.bin')
    at = POKE_AT + wait if wait is not None else SETTLED
    cmd = [P.EMU, P.ROM, '-loadstate', state, '-input', inp,
           '-frames', str(at + 1),
           '-poke', '0002=%02X@%d' % (mode, POKE_AT)]
    for one in also:
        cmd += ['-poke', '%s@%d' % (one, POKE_AT)]
    cmd += ['-sample', '%04X=A' % DOOR, '-trace', log,
            '-tracefrom', '999999', '-traceto', '999999',
            '-vram', '%s@%d' % (out, at)]
    subprocess.run(cmd, check=True, capture_output=True)
    drew = [n for fr, n in samples(log) if fr >= POKE_AT]
    one = vram(out)
    # What is written down is everything the shot needs to be taken again:
    # the mode poked, the picture it is poked on, the picture the board is
    # read off, and whatever else had to be poked alongside it.
    return scene(name, drew, one, lay(
        screens, drew, EXTRA.get(name, {}).get('fold', one['mirror']),
        EXTRA.get(name, {}).get('fill', (0, 0))),
        ['poke', mode, POKE_AT, at, list(also)])


def main():
    import json
    screens = json.load(open(os.path.join(ROOT, 'game', 'data', 'sol',
                                          'screens.json')))
    d = P.scratch('scenes')
    try:
        out = walk(d, screens)
        state = P.make_state(os.path.join(d, 'base'))
        for one in MODES:
            name, mode = one[0], one[1]
            wait = one[2] if len(one) > 2 else None
            also = one[3] if len(one) > 3 else ()
            out[name] = poked(d, screens, state, name, mode, wait, also)
        size = write_json(os.path.join(outdir('sol'), 'scenes.json'),
                          {'scenes': out})
        print('%d scenes, %d bytes' % (len(out), size))
    finally:
        P.sweep(d)


if __name__ == '__main__':
    main()
