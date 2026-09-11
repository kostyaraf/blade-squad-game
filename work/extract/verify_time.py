#!/usr/bin/env python3
"""Э3.7 acceptance: the clock the bar shows, against the cartridge's own.

The time ($95/$96) is four binary-coded digits that go down by one every
sixty-four pictures and take the man's life with them when they run out.  It
is read anew at the top of each half of a stage ($CE45) and again every time a
life is lost ($D063); a door never touches it.

The cartridge is stood in an area and left alone, and every picture its
$95/$96 and its bell ($57) are written down.  The engine is put in the same
area, handed the cartridge's own $1C -- the count the tick is measured on --
and left alone for the same number of pictures.  Every picture has to agree.
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_probe as P                                        # noqa: E402
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402

GODOT, GAME = V.GODOT, V.GAME

# Long enough for the clock to tick a good many times over.
FRAMES = 700

# Every stage, and a couple of areas that are not the first, so that the time
# a door leaves alone is watched as well as the one a stage sets.
#
# The rest are the corners the plain run never reaches inside a few hundred
# pictures: the borrow that walks through all four digits, the bell that is
# set at $0030, and the time running out altogether.  For those the cartridge
# is handed a time to start from, and so is the engine.
AREAS = [
    ('0:0', 0, 0, None, FRAMES),
    ('0:2', 0, 2, None, FRAMES),
    ('1:0', 1, 0, None, FRAMES),
    ('2:0', 2, 0, None, FRAMES),
    ('2:3', 2, 3, None, FRAMES),
    ('3:0', 3, 0, None, FRAMES),
    ('4:0', 4, 0, None, FRAMES),
    ('5:1', 5, 1, None, FRAMES),
    ('borrow', 0, 0, 0x0100, 200),
    ('borrow-ten', 0, 0, 0x0210, 200),
    ('bell', 0, 0, 0x0032, 400),
    ('runs-out', 0, 0, 0x0003, 400),
]


# $1A = 5 -- the picture the level itself begins to be played on, and the
# first one the clock is offered.  Everything before it is the level opening:
# the record, the screen, the things.  The engine has no such opening, so the
# run is counted from there.
PLAYING = 5


def play(stage, area, frames, pokes=()):
    """Play the cartridge in that area and hand back every picture's memory,
    counted from the picture the level itself begins on."""
    state = pb2_trace.state_for(P.PICK_LEVEL, stage, area, None)
    r = P.run(state, [(P.PICK_LEVEL, '-')], P.PICK_LEVEL + frames + 80,
              watch=(0x0000, 0x0100), pokes=list(pokes))
    cur = {}
    rows = {}
    for fr in sorted(r):
        cur.update(r[fr])
        rows[fr - P.PICK_LEVEL] = dict(cur)
    for n in sorted(rows):
        if rows[n].get(0x1A) == PLAYING:
            return n, rows
    raise RuntimeError('the level never began')


def cartridge(stage, area, time, frames):
    """The cartridge's own $95/$96/$57 from the picture the level starts on,
    and the $1C that picture stood at."""
    began, rows = play(stage, area, frames)
    if time is not None:
        # The time is read when the level opens, so it can only be put back
        # once the level has opened -- which is what the first run was for.
        at = P.PICK_LEVEL + began
        began, rows = play(stage, area, frames, pokes=[
            (0x0095, time >> 8, at), (0x0096, time & 0xFF, at),
            (0x0057, 0, at)])
    out = {}
    for i in range(1, frames + 1):
        c = rows.get(began + i)
        if c is None:
            break
        out[i] = (c.get(0x95, 0), c.get(0x96, 0), 1 if c.get(0x57, 0) else 0)
        # Once it has run out the man dies, and what the death does to the
        # clock is the death's business, not the clock's.
        if out[i][0] == 0 and out[i][1] == 0:
            break
    return rows[began].get(0x1C, 0), out


def engine(stage, area, start, time, frames):
    """The same out of the engine, given the cartridge's $1C."""
    spec = '%d:%d' % (start, frames)
    if time is not None:
        spec += ':%d' % time
    r = subprocess.run([GODOT, '--headless', '--path', GAME, '--',
                        '--time=' + spec,
                        '--stage=%d' % stage, '--area=%d' % area],
                       capture_output=True, text=True)
    if r.returncode != 0:
        raise RuntimeError(r.stdout[-2000:] + r.stderr[-2000:])
    out = {}
    for line in r.stdout.split('\n'):
        f = line.strip().split(' ')
        if not f[0].isdigit():
            continue
        if len(f) == 2 and f[1] == 'out':
            # The engine says the time ran out here, and the cartridge says
            # the same by standing at nought.
            out[int(f[0])] = (0, 0, 0)
        elif len(f) == 4:
            out[int(f[0])] = (int(f[1], 16), int(f[2], 16), int(f[3]))
    return out


def run():
    bad = 0
    for name, stage, area, time, frames in AREAS:
        start, rom = cartridge(stage, area, time, frames)
        eng = engine(stage, area, start, time, frames)
        wrong = [n for n in sorted(rom) if rom[n] != eng.get(n)]
        if wrong:
            bad += 1
            n = wrong[0]
            print('%-9s %d of %d pictures differ, first at %d: '
                  'cartridge %02X%02X/%d, engine %s'
                  % (name, len(wrong), len(rom), n, rom[n][0],
                     rom[n][1], rom[n][2], eng.get(n)))
        else:
            print('%-9s ok -- %d pictures, ends at %02X%02X'
                  % (name, len(rom), rom[max(rom)][0], rom[max(rom)][1]))
    print('%d of the areas differ' % bad)
    return bad


if __name__ == '__main__':
    sys.exit(1 if run() else 0)
