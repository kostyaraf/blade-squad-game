#!/usr/bin/env python3
"""Э5.1 acceptance: each hero made to walk somebody else's level.

The PB3 mode puts the Solbrain hero into Power Blade 2's levels and the Power
Blade hero into Solbrain's.  Neither hero is touched to make that work: what
changes is only what the level answers, through two adapters
(`game/src/pb2_as_sol.gd` and `game/src/sol_as_pb2.gd`) that turn one game's
idea of a cell into the other's.

There is no cartridge to compare against here -- no console ever ran this -- so
the acceptance is not a comparison but three questions the floor has to answer
the same way in anybody's level:

  * he never goes down through a floor that is there;
  * he is never left standing inside something solid;
  * where there is somewhere to walk, he walks.

The places are not chosen here.  The engine finds them out of the level's own
answers -- a cell with nothing in it, nothing over it, something solid under
it, and four clear cells to its right -- so the same rule picks them whichever
way round the pair is, and "he did not move" is a fair question afterwards.

What the adapters do NOT change is either game on its own: the only two things
this step put into the shared code are a slide downwards the Power Blade hero
never gets (`shift_y`, nought in his own game) and a door in both level classes
for building one without a file.  So every stand of Э3 and Э4 must stay where
it was, and the suite is what says so.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import sol_probe as P                                            # noqa: E402
import verify_sol_player as V                                    # noqa: E402

SPOTS = 20
FRAMES = 150

# Right; right and a jump; left; a jump on the spot; nothing at all.
RIGHT = 0x01
PADS = [0x01, 0x81, 0x02, 0x80, 0x00]

# How many areas each stage of Power Blade 2 has.
PB2 = [7, 8, 7, 7, 10, 14, 10]
SOL = 20


def runs():
    out = []
    for st in range(len(PB2)):
        for ar in range(PB2[st]):
            out.append({'hero': 'sol', 'game': 'pb2', 'stage': st, 'area': ar,
                        'spots': SPOTS, 'frames': FRAMES, 'pads': PADS})
    for st in range(SOL):
        out.append({'hero': 'pb2', 'game': 'sol', 'stage': st,
                    'spots': SPOTS, 'frames': FRAMES, 'pads': PADS})
    return out


def parse(line):
    f = line.split()
    if len(f) < 20 or f[0] not in ("sol", "pb2"):
        return None
    return {
        'hero': f[0], 'where': f[1], 'cx': int(f[2]), 'cy': int(f[3]),
        'pad': int(f[5], 16), 'x0': int(f[7]), 'x1': int(f[9]),
        'y1': int(f[11]), 'walled': int(f[13]), 'drop': int(f[15]),
        'left': int(f[17]), 'front': int(f[19]),
    }


def main():
    scratch = P.scratch('pb3floor')
    try:
        path = os.path.join(scratch, 'floor.json')
        open(path, 'w').write(json.dumps({'runs': runs()}))
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--pb3floor=%s' % path],
                           capture_output=True, text=True, timeout=1800)
        rows = [p for p in (parse(l) for l in r.stdout.split('\n')) if p]
        if not rows:
            sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
            print('the engine walked nobody')
            return 1
        # A cell is sixteen lines tall, so while no single picture drops him
        # further than that, "never inside something solid" is also "never
        # through a floor".  The two are checked together.
        fell = [p for p in rows if p['drop'] >= 16]
        walled = [p for p in rows if p['walled'] > 2]
        stuck = [p for p in rows
                 if p['pad'] == RIGHT and not p['front'] and not p['left']
                 and p['x1'] - p['x0'] < 16]
        for p in (fell + walled + stuck)[:12]:
            print('%s %-6s cell %3d,%3d pad %02X  x %5d -> %5d  y %5d  '
                  'walled %d drop %d left %d front %d'
                  % (p['hero'], p['where'], p['cx'], p['cy'], p['pad'],
                     p['x0'], p['x1'], p['y1'], p['walled'], p['drop'],
                     p['left'], p['front']))
        walk = [p for p in rows if p['pad'] == RIGHT]
        moved = len([p for p in walk if p['x1'] - p['x0'] >= 16])
        deep = max(p['drop'] for p in rows)
        print('%d walks to the right, %d of them got at least a cell along; '
              'the deepest one picture ever dropped anybody is %d lines'
              % (len(walk), moved, deep))
        sol = len([p for p in rows if p['hero'] == 'sol'])
        pb2 = len(rows) - sol
        print('%d walks: %d of Solbrain\'s hero in Power Blade 2, %d of '
              'Power Blade\'s hero in Solbrain' % (len(rows), sol, pb2))
        left = len([p for p in rows if p['left']])
        print('%d fell further in one picture than a cell is tall, %d stood '
              'inside something solid, %d would not walk (%d walked off the '
              'end, which is no fault)'
              % (len(fell), len(walled), len(stuck), left))
        # The house verdict line, in the shape the whole suite reads.
        bad = len({id(p) for p in fell + walled + stuck})
        print('%d of %d walks in a borrowed level differ from what a floor '
              'has to do' % (bad, len(rows)))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


if __name__ == '__main__':
    sys.exit(main())
