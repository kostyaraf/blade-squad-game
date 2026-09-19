#!/usr/bin/env python3
"""Э5.2 acceptance: two heroes on one screen, and the view that holds both.

Э5.1 proved a level can answer either hero.  This one puts two of them into
the same level at once -- all four pairings, either game's hero in either
game's level -- and asks what a shared screen has to do:

  * neither of them is ever off the side of the screen;
  * neither is left inside something solid;
  * neither leaps further in one picture than a cell is tall, either way.
    Upwards is measured on purpose and not out of tidiness: a Power Blade
    hero's place is one byte of the screen, and a hero who went off the
    bottom of it and came round the top would show here and nowhere else;
  * one of them leaving the level does not stop the other.

Nothing is invented to make the view work that could be taken from the games.
Each level is driven by its own game's view -- `Pb2Camera` ($D924, $D3B8) for
a Power Blade area, `SolCamera` ($F1EA, $F24B) for a Solbrain stage -- inside
the band that game keeps a hero in.  What is new is only what a view with two
heroes cannot avoid deciding, and it is three things in order: the middle of
them is kept in that band; the view is pulled if it has to be so that neither
is off the screen; and when the two are further apart than a screen, it stands
halfway between the two places that would each hold one.  See
`game/src/pb3_pair.gd` and `work/re/pb3_pair.md`.

Again there is no cartridge to compare against, so the questions above are the
whole of it, and the places are found by the engine out of the level's own
answers -- with two more conditions than Э5.1 had: the place must be one a
reachable view can bring to the screen, and the cell the second hero stands on
must have a floor under it as well.  A Solbrain stage is sixteen screens tall
and its own record says how far the view may go; above the first line it can
reach the game never puts anybody, and there would be no screen to judge them
against.
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

SPOTS = 4
FRAMES = 160

# All four ways round: whose hero is the first player and whose the second.
KINDS = [['pb2', 'sol'], ['sol', 'pb2'], ['pb2', 'pb2'], ['sol', 'sol']]

# Both to the right; one right and one left, which is what pulls the view
# apart; one walking and one standing; one walking and one jumping; neither.
PADS = [[0x01, 0x01], [0x01, 0x02], [0x01, 0x00], [0x01, 0x80], [0x00, 0x00]]

# How many areas each stage of Power Blade 2 has.
PB2 = [7, 8, 7, 7, 10, 14, 10]
SOL = 20


def runs():
    out = []
    for st in range(len(PB2)):
        for ar in range(PB2[st]):
            out.append({'game': 'pb2', 'stage': st, 'area': ar,
                        'spots': SPOTS, 'frames': FRAMES,
                        'kinds': KINDS, 'pads': PADS})
    for st in range(SOL):
        out.append({'game': 'sol', 'stage': st, 'area': 0,
                    'spots': SPOTS, 'frames': FRAMES,
                    'kinds': KINDS, 'pads': PADS})
    return out


def parse(line):
    f = line.split()
    if len(f) != 28 or f[1] not in ('pb2', 'sol'):
        return None
    return {
        'where': f[0], 'one': f[1], 'two': f[2], 'cx': int(f[3]),
        'cy': int(f[4]), 'pad0': int(f[6], 16), 'pad1': int(f[7], 16),
        'ran': int(f[9]), 'off': int(f[11]), 'walled': int(f[13]),
        'drop': int(f[15]), 'apart': int(f[17]), 'left': int(f[19]),
        'held': int(f[21]), 'stuck': int(f[23]), 'went': int(f[25]),
        'below': int(f[27]),
    }


def main():
    scratch = P.scratch('pb3pair')
    try:
        path = os.path.join(scratch, 'pair.json')
        open(path, 'w').write(json.dumps({'runs': runs()}))
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--pb3pair=%s' % path],
                           capture_output=True, text=True, timeout=3600)
        rows = [p for p in (parse(l) for l in r.stdout.split('\n')) if p]
        if not rows:
            sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
            print('the engine walked nobody')
            return 1
        # The view let somebody off the screen.  A hold it could not make is
        # not counted here: being pressed by the edge into something solid is
        # being crushed, and the engine ends him for it (`work/re/pb3_pair.md`),
        # which this stand sees as one of the two leaving the level.
        out = [p for p in rows if p['off'] > 0]
        # The same two the floor was asked in Э5.1, and for the same reason:
        # a cell is sixteen lines tall, so while nobody moves further than
        # that in one picture, "never inside" and "never through" agree.
        walled = [p for p in rows if p['walled'] > 2]
        fell = [p for p in rows if p['drop'] >= 16]
        # One of them gone is not the end of the picture: the walk has to have
        # run to its last frame all the same.
        cut = [p for p in rows if p['left'] == 1 and p['ran'] < FRAMES]
        for p in (out + walled + fell + cut)[:12]:
            print('%-6s %s+%s cell %3d,%3d pads %02X %02X  ran %d off %d '
                  'walled %d drop %d left %d stuck %d below %d'
                  % (p['where'], p['one'], p['two'], p['cx'], p['cy'],
                     p['pad0'], p['pad1'], p['ran'], p['off'], p['walled'],
                     p['drop'], p['left'], p['stuck'], p['below']))
        both = len([p for p in rows if p['pad0'] == 0x01 and p['pad1'] == 0x01])
        moved = len([p for p in rows
                     if p['pad0'] == 0x01 and p['pad1'] == 0x01
                     and p['went'] >= 16])
        widest = max(p['apart'] for p in rows)
        print('%d walks of two, %d of them with both walking; %d of those '
              'carried the middle at least a cell, and the furthest the two '
              'ever got apart is %d pixels'
              % (len(rows), both, moved, widest))
        for k in KINDS:
            n = len([p for p in rows
                     if p['one'] == k[0] and p['two'] == k[1]])
            print('  %s and %s: %d' % (k[0], k[1], n))
        alone = len([p for p in rows if p['left'] == 1])
        # How far the edge ever had to reach to hold somebody: written down
        # rather than judged, because at the very top and bottom of a level
        # the view has nowhere further to go and standing there is not being
        # lost.
        print('the furthest the edge ever had to reach to hold somebody on '
              'the screen is %d lines' % max(p['below'] for p in rows))
        print('%d let somebody off the screen, %d stood inside something '
              'solid, %d leapt further in one picture than a cell is tall; '
              '%d walks had one of the two leave the level and %d of '
              'those stopped early'
              % (len(out), len(walled), len(fell), alone, len(cut)))
        # The house verdict line, in the shape the whole suite reads.
        bad = len({id(p) for p in out + walled + fell + cut})
        print('%d of %d walks of two differ from what a shared screen has to '
              'do' % (bad, len(rows)))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


if __name__ == '__main__':
    sys.exit(main())
