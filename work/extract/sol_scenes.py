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
WALKED = {0x0A: ('title', 480), 0x33: ('tale', 60), 0x30: ('select', 300)}

# And what is not: the number that goes in $02, and the name of what it shows.
MODES = (
    ('best', 0x0E),         # $D6CA -- BEST 5, the five high scores
    ('test', 0x24),         # $D79F -- TEST MODE, the maker's own menu
    ('bgm', 0x2A),          # $D863 -- BGM TEST
    ('over', 0x14),         # $D974 -- GAME OVER
    ('cleared', 0x1B),      # $E09C -- AREA x CLEARED
    ('staff', 0x4E),        # $E3E7 -- the names at the end
)

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
    left = sum(1 for i in range(0x800) if got[i] != d['ciram'][i])
    rec = {
        'how': how,
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
    print('%-8s screens %s  banks %s  %d bands  mirror %d  +%d written over'
          % (name, ' '.join('$%02X' % s for s in drew), d['chr'][:4],
             len(rec['bands']), d['mirror'], left))
    return rec


def lay(screens, numbers, mirror):
    """The board as the drawn screens leave it: wiped, then written on.

    The console has two kilobytes of name map and four places to put them, so
    which of the two a write lands in is the mirroring's business: across, the
    first two places are the same memory; down, the first and the third are.
    """
    board = bytearray(0x0800)
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
        out[name] = scene(name, same, one, lay(screens, same, one['mirror']),
                          ['walk', at])
    return out


def poked(d, screens, state, name, mode):
    inp = os.path.join(d, 'p.inp')
    open(inp, 'w').write('%d -\n' % (P.IN_LEVEL + 1))
    log = os.path.join(d, name + '.log')
    out = os.path.join(d, name + '.bin')
    subprocess.run([P.EMU, P.ROM, '-loadstate', state, '-input', inp,
                    '-frames', str(SETTLED + 1),
                    '-poke', '0002=%02X@%d' % (mode, POKE_AT),
                    '-sample', '%04X=A' % DOOR, '-trace', log,
                    '-tracefrom', '999999', '-traceto', '999999',
                    '-vram', '%s@%d' % (out, SETTLED)],
                   check=True, capture_output=True)
    drew = [n for fr, n in samples(log) if fr >= POKE_AT]
    one = vram(out)
    return scene(name, drew, one, lay(screens, drew, one['mirror']),
                 ['poke', mode, POKE_AT, SETTLED])


def main():
    import json
    screens = json.load(open(os.path.join(ROOT, 'game', 'data', 'sol',
                                          'screens.json')))
    d = P.scratch('scenes')
    try:
        out = walk(d, screens)
        state = P.make_state(os.path.join(d, 'base'))
        for name, mode in MODES:
            out[name] = poked(d, screens, state, name, mode)
        size = write_json(os.path.join(outdir('sol'), 'scenes.json'),
                          {'scenes': out})
        print('%d scenes, %d bytes' % (len(out), size))
    finally:
        P.sweep(d)


if __name__ == '__main__':
    main()
