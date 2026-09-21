#!/usr/bin/env python3
"""Э7.3 acceptance: what the build remembers between runs, and what it does
not touch.

Neither cartridge had a battery.  Power Blade 2 was played through in one
sitting and Solbrain kept its best scores only as long as the console was on,
so there is no recording to hold this against: the remembering is the port's
own, like the screen Э7.2 put in front of it, and what is written down here is
the promise it makes.

The promise:

* only a run that came through the screen remembers anything.  A run told what
  to do on the command line is a stand, and a stand must never read or write a
  file that outlives it -- so no argument leaves a file behind at all, and the
  first half of this stand deletes the file and then drives the engine by its
  arguments to show that nothing puts it back;
* what the game carries is what comes back.  For Power Blade 2 that is the two
  cells the pick screen reads, `$5B` (the stages cleared) and `$56` (the suits
  owned); for Solbrain it is `$2D` (how far through) and the table of best
  scores and the names beside them;
* the numbers come back whole.  JSON has one kind of number and gives every
  one of them back as a real one, and every number either cartridge keeps is a
  row of digits or a row of tile numbers;
* what came back is there on the game's first picture, not a picture or two
  later: the screen reads the file as it starts the game;
* the two games are remembered apart, and remembering one does not forget the
  other;
* the screen on its own writes nothing.  Until a row is taken there is no game
  to remember.

The harness is `--keep=`, and it is the one argument in the project that
touches `user://` on purpose.  Everything in it is the way a player goes -- the
screen goes up, the game is started by the screen settling, and the
looking-over every picture is the game's own -- except the pad, which is handed
over rather than pressed, and the counters, which are poked because no stand
can play a stage to its end.

The file is put back the way it was found: a stand must not cost a player
their progress.
"""
import json
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402

# Which project the engine is run out of.  It is `game/`, and it is an
# argument only so that a change can be tried on a copy before it is put in.
GAME = V.GAME

# The pad as both cartridges order it, which is what `Pad` holds.
START = 0x10
DOWN = 0x04

# Э7.2's rows, top down.
ROWS = ['pb2', 'sol']

# Arguments that must leave no file behind.  One for each way through
# `main.gd`: the game itself, the screen between stages, and Э7.2's own
# screen, which is the one place a game can be settled on without the command
# line settling it.
BY_HAND = [
    ('the game playing', ['--play=RIGHT:3,-:3']),
    ('the pick screen', ['--choose=']),
    ('the asking screen', ['--menu=']),
]

# The scripts that settle Э7.2's screen on a row: down to it, and START.  A
# button has to be let go of before it counts again, which is the pad both
# cartridges read.
def settle(row):
    keys = []
    for _ in range(row):
        keys += [DOWN, 0]
    return keys + [START, 0]


def walk(row, pokes_at, tail=4, forget=False):
    """A whole run: settle on a row, poke what a finished stage would have
    moved, and go on for a few more pictures so that the looking-over has
    something to look at twice."""
    keys = settle(row)
    pokes = {str(len(keys) + n): what for n, what in pokes_at}
    return {'forget': forget, 'keys': keys, 'pokes': pokes,
            'frames': len(keys) + tail}


PB2 = {'cleared': 0x07, 'owned': 0x03}
SOL = {'done': 2, 'scores': [30000, 20000, 10000, 5000, 1000],
       'names': [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]]}
SOL_FRESH = {'done': 0, 'scores': [5000, 8000, 10000, 15000, 20000],
             'names': [[73, 87, 65], [77, 65, 84], [77, 73, 90],
                       [84, 78, 73], [73, 83, 75]]}

# (name, the run, and the promise: what it was settled on, what the game says
#  on its first picture and on its last, and what the file holds at the end.)
# They are run in this order and each one stands on the one before: that is
# the whole point of a file that outlives a run.
WALKS = [
    # Nothing taken, so there is no game and nothing to remember.
    ('the screen alone', {'forget': True, 'keys': [0, DOWN, 0], 'frames': 3},
     dict(settled=None, first=None, last=None, file=None)),
    ('the first game, fresh', walk(0, [(1, PB2)], forget=True),
     dict(settled='pb2', first={'cleared': 0, 'owned': 0}, last=PB2,
          file={'pb2': PB2})),
    ('the first game again', walk(0, []),
     dict(settled='pb2', first=PB2, last=PB2, file={'pb2': PB2})),
    ('the other game, fresh', walk(1, [(1, SOL)]),
     dict(settled='sol', first=SOL_FRESH, last=SOL,
          file={'pb2': PB2, 'sol': SOL})),
    ('the other game again', walk(1, []),
     dict(settled='sol', first=SOL, last=SOL,
          file={'pb2': PB2, 'sol': SOL})),
    # And the first one is still there: one game remembered is not the other
    # forgotten.
    ('the first game, still there', walk(0, []),
     dict(settled='pb2', first=PB2, last=PB2,
          file={'pb2': PB2, 'sol': SOL})),
]


def keep(cfg, path):
    """One run of the harness: the lines picture by picture, what the file
    held at the end, and where the file is."""
    open(path, 'w').write(json.dumps(cfg))
    try:
        r = subprocess.run([V.GODOT, '--path', GAME, '--headless', '--',
                            '--keep=' + path], capture_output=True,
                           text=True, timeout=V.ENGINE_WAIT)
    except subprocess.TimeoutExpired:
        sys.stderr.write('the engine never stopped\n')
        return [], None, None
    rows, held, where = [], None, None
    for line in r.stdout.split('\n'):
        parts = [p.strip() for p in line.strip().split('|')]
        if len(parts) == 2 and parts[0] == 'file':
            held = None if parts[1] == '-' else json.loads(parts[1])
        elif len(parts) == 2 and parts[0] == 'path':
            where = parts[1]
        elif len(parts) == 4 and parts[0].isdigit():
            rows.append((int(parts[0]), parts[1], parts[2] == 'keeping',
                         None if parts[3] in ('-', 'on the screen')
                         else json.loads(parts[3])))
    if not rows and where is None:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return rows, held, where


def same(a, b):
    """Alike, and alike in kind.  A whole number and a real one are not the
    same answer here: that is the whole of the third promise, and Python would
    call 30000.0 and 30000 equal and let it through."""
    if isinstance(a, float) != isinstance(b, float):
        return False
    if isinstance(a, list) and isinstance(b, list):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict) and isinstance(b, dict):
        return sorted(a) == sorted(b) and all(same(a[k], b[k]) for k in a)
    return type(a) is type(b) and a == b


def check(cfg, promise, tmp):
    rows, held, _ = keep(cfg, os.path.join(tmp, 'k.json'))
    if len(rows) != cfg['frames']:
        return None, ('the engine put out %d lines, not %d'
                      % (len(rows), cfg['frames']))
    playing = [r for r in rows if r[3] is not None]
    if promise['settled'] is None:
        if playing:
            return None, 'nothing was taken, and yet a game ran'
        if any(r[2] for r in rows):
            return None, 'nothing was taken, and yet the run remembers'
    else:
        if not playing:
            return None, 'the screen was never settled'
        if playing[0][1] != promise['settled']:
            return None, ('it settled on %r, and the promise is %r'
                          % (playing[0][1], promise['settled']))
        if not all(r[2] for r in playing):
            return None, 'a picture of the game does not remember'
        for which, want in (('first', playing[0][3]),
                            ('last', playing[-1][3])):
            if not same(want, promise[which]):
                return None, ('the %s picture says %r, and the promise is %r'
                              % (which, want, promise[which]))
    if not same(held, promise['file']):
        return None, ('the file holds %r, and the promise is %r'
                      % (held, promise['file']))
    return len(rows), None


def by_hand(where, tmp):
    """The file deleted, and then the engine driven by its arguments.  What is
    counted is the runs; what is judged is that the file is still not there."""
    ran = bad = 0
    for name, args in BY_HAND:
        args = list(args)
        if args[0] == '--choose=':
            path = os.path.join(tmp, 'c.json')
            open(path, 'w').write(json.dumps(
                {'stage': 0, 'cleared': 0, 'owned': 0,
                 'frames': [{'hit': 0}, {'hit': START}]}))
            args[0] += path
        elif args[0] == '--menu=':
            path = os.path.join(tmp, 'm.json')
            open(path, 'w').write(json.dumps({'frames': [DOWN, 0, START]}))
            args[0] += path
        if os.path.exists(where):
            os.unlink(where)
        try:
            subprocess.run([V.GODOT, '--path', GAME, '--headless', '--']
                           + args, capture_output=True, text=True,
                           timeout=V.ENGINE_WAIT)
        except subprocess.TimeoutExpired:
            sys.stderr.write('the engine never stopped\n')
        ran += 1
        if os.path.exists(where):
            bad += 1
            print('%-24s WROTE  %s' % (name, open(where).read()[:200]))
        else:
            print('%-24s ok   nothing left behind' % name)
        sys.stdout.flush()
    return ran, bad


def main():
    global GAME
    for a in sys.argv[1:]:
        if a.startswith('--game='):
            GAME = a.split('=', 1)[1]
    tmp = pb2_trace.P.scratch('saveverify')
    bad = ran = pictures = 0
    kept = None
    where = None
    try:
        # Where the file is, before anything is done to it, and what was in
        # it: a player's own progress is not a stand's to lose.
        _, _, where = keep({'frames': 0}, os.path.join(tmp, 'k.json'))
        if where is None:
            print('the engine did not say where the file goes')
            return 1
        if os.path.exists(where):
            kept = os.path.join(tmp, 'was.json')
            shutil.copyfile(where, kept)
        n, b = by_hand(where, tmp)
        ran += n
        bad += b
        for name, cfg, promise in WALKS:
            ran += 1
            n, why = check(cfg, promise, tmp)
            if why is None:
                pictures += n
                print('%-24s ok   %d pictures' % (name, n))
            else:
                bad += 1
                print('%-24s BROKEN  %s' % (name, why))
            sys.stdout.flush()
    finally:
        if where is not None:
            if kept is not None and os.path.exists(kept):
                shutil.copyfile(kept, where)
            elif os.path.exists(where):
                os.unlink(where)
        pb2_trace.P.sweep(tmp)
    print('%d pictures remembered, %d ways in that must leave no file, '
          '%d games kept apart (%s)'
          % (pictures, len(BY_HAND), len(ROWS), ', '.join(ROWS)))
    print('%d of %d runs break the promise' % (bad, ran))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
