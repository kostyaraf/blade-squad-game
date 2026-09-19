#!/usr/bin/env python3
"""Э5.7 acceptance: the whole list played by two, with the levels running.

Э5.6 walked the same eighty three records with the levels empty -- two heroes
and a view and nothing else in the room.  This raises each record with its own
game round it and plays it out with both heroes in it, whichever games they
came from: one pool of things belonging to the level and not to a hero, and the
level's own order stepping it -- `Pb2Turn` ($CEF0) for a Power Blade area,
`SolTurn` ($CDB3) for a Solbrain stage, the very classes the single game plays.
Whoever came from the game the level did stands in the one place that game
keeps for a hero; the other is a guest of it (Э5.4).

A pilot holds the two of them along the level, taps the buttons and turns them
round when neither of them has got anywhere for two seconds.  The pilot is not
on trial and cannot play either game: it keeps both of them alive, the way
every other run here does.

The questions:

  * the whole list comes up and plays.  Every one of the eighty three records,
    in each of the four pairings, raises a level with its own game round it and
    is stepped for every one of the pictures asked for.  A record that stops
    short is the fault this is looking for;
  * the level's own game really ran.  Every record put its things out --
    counted as a place in the level's own pool going from empty to taken.
    Where a Power Blade area put nothing out, the pilot must never have walked
    as far as the column its earliest thing stands in ($E44D counts the list in
    sixteens, and the pool says how far along it was ever read).  That is asked
    of the level's own list and not allowed for by name;
  * no mode the engine does not know.  Every picture ended as one of the five
    the order has a name for; no Solbrain routine ran off the end of its own
    table and none asked for a record the export has never seen; and no
    behaviour of a thing, a shot, a weapon or a satellite was one the engine
    has not read out of the ROM.

There is no cartridge for two heroes in one level, so the questions are
mechanical.  What is not mechanical is that the order stepping each record is
the same class the single game is accepted on: a record that falls over here
falls over in `verify_run.py` or `verify_sol_run.py` as well.
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

# How long each record is played for, and by whom.  Nine hundred pictures is
# fifteen seconds of it, which is what `--through` gives a Power Blade area.
FRAMES = 900
KINDS = [['pb2', 'sol'], ['sol', 'pb2'], ['pb2', 'pb2'], ['sol', 'sol']]
RECORDS = 63 + 20

# The five ends `Pb2Turn` has a name for.  Anything else is a mode the engine
# does not know, which is the whole point of putting the name out.
ENDS = {'none', 'door', 'scene', 'died', 'held'}


def reached(p):
    """Whether the pilot was carried as far as the level's first thing.

    A Power Blade area keeps its things in a list sorted along the level and
    counted in sixteens ($E44D); the pool says how far along that list it was
    ever read, so "as far as the first one" is exact.  A Solbrain stage has no
    such list: it puts out the group the room it is in names ($9A), so "as far
    as the first one" is having left the room it opened in.  A level with
    nothing of its own to put out is not asked at all.
    """
    if int(p[11]) == 0:
        return False
    if int(p[13]) >= 0:
        return int(p[13]) <= int(p[15])
    return int(p[17]) > 1


def parse(line, head, n):
    f = line.split()
    if len(f) != n or f[0] != head:
        return None
    return f


def main():
    scratch = P.scratch('pb3run')
    try:
        path = os.path.join(scratch, 'run.json')
        open(path, 'w').write(json.dumps({'frames': FRAMES, 'kinds': KINDS}))
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--pb3run=%s' % path],
                           capture_output=True, text=True, timeout=7200)
        lines = r.stdout.split('\n')
        # run <where> <one> <two> ran <n> things <n> born <n> has <n>
        #     first <n> reach <n> rooms <n> went <n> <n> solid <n>
        #     ends <names> owed <n> wild <n> lost <n> up <0|1>
        rows = [p for p in (parse(l, 'run', 33) for l in lines) if p]
        if not rows:
            sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
            print('the engine raised nothing')
            return 1
        never = [p for p in rows if p[32] != '1']
        short = [p for p in rows if int(p[5]) != FRAMES]
        silent = [p for p in rows if reached(p) and int(p[9]) == 0]
        strange = [p for p in rows
                   if not set(p[24].split('+')) <= ENDS]
        owed = [p for p in rows if p[26] != '0' or p[28] != '0'
                or p[30] != '0']
        for p in (never + short + silent + strange + owed)[:10]:
            print(' '.join(p))
        kinds = len({(p[2], p[3]) for p in rows})
        where = len({p[1] for p in rows})
        print('%d records of the %d, each in %d pairings, raised with their '
              'own game round them and played %d pictures'
              % (where, RECORDS, kinds, FRAMES))
        out = len([p for p in rows if int(p[9]) > 0])
        short_of = len([p for p in rows if int(p[9]) == 0 and not reached(p)])
        print('%d of %d put the level\'s own things out; in %d the pilot never '
              'got as far as the level keeps its first thing, and only that '
              'one question is left unasked' % (out, len(rows), short_of))
        ends = sorted({e for p in rows for e in p[24].split('+')})
        print('the pictures ended as: %s' % ', '.join(ends))
        print('%d never came up, %d stopped short, %d put nothing out where '
              'the level had something to put, %d ended as a mode the engine '
              'does not know, %d met a behaviour or a record it has not read'
              % (len(never), len(short), len(silent), len(strange),
                 len(owed)))
        bad = len(never) + len(short) + len(silent) + len(strange) + len(owed)
        print('%d of %d playings of the list differ from what a level running '
              'under two has to do' % (bad, len(rows)))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


if __name__ == '__main__':
    sys.exit(main())
