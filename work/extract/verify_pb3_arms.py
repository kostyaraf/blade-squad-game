#!/usr/bin/env python3
"""Э5.8 acceptance: a foreign weapon against a foreign thing.

Э5.4 did one side of it -- a foreign enemy reaching a foreign hero.  The other
side was never in the plan and Э5.7 wrote it down as a debt: what a guest of a
level throws has to be able to reach the things standing on it.

Both games already ask the same question of their own weapons -- a point,
grown by whatever it reaches, laid over the thing's box -- and each asks it in
exactly one place: `$B5D5` walks the hero's five throws in `Pb2Objects`, and
`$869C` walks his eight in `SolObjects`.  So nothing is woven into either
walk.  Beside it a guest's weapons are laid over the same thing, through the
same gates, in the same picture and in the same order; what the level decides
is handed back to the guest's own game as one number, and that game is what
spends it.  `work/re/pb3_arms.md` has the whole of it.

There is no cartridge to compare against, so acceptance is mechanical, and the
places are the ones Э5.4 uses and for the same reason: the reach is the
thing's own box grown by what the weapon reaches, which is the sum both games
already do, and the weapon is put on each of the four edges of it and one step
outside each.  A step is one pixel in a Power Blade area and one sixteenth of
a pixel in a Solbrain stage, because that is the grid each game keeps its
places on.

  * inside an edge the blow lands, every time and on every edge;
  * outside it, never;
  * twice running, the second does not land: the rest each game gives a thing
    after a blow is the level's own and stays the level's own;
  * what it took off the thing is what the weapon's own game says it takes,
    unconverted -- both games count a thing's life in whole points, and "a
    point is a point" is the decision Э5.8 makes and names;
  * what the thing said it cost the weapon is the level's own number for how
    much that thing hurts: $8731's low four bits of the meaning in a stage,
    and the very same quantity, `hurt[type]`, in an area;
  * and no kind of thing is left that a guest's weapon could not reach at all.

The sorts of weapon are not invented either.  Power Blade's four come out of
its own two tables by type ($A84D); Solbrain's three are what its own code
gives -- $87BC takes one off a thing and its shot is a point, while $84B0
grows the thing's box by eight pixels before his own four slots are asked and
by eight again before the last two of them.  All seven sorts are tried in both
games' levels, because a guest of a Power Blade area may be a Power Blade hero
just as well as a Solbrain one.

The first leg says the seam is right.  A second one says it is used: the whole
list of Э5.6 is walked again in each of the four pairings, with every hero
armed -- a Power Blade one carries his blade from the first picture, and a
Solbrain one is handed one of the eight satellites by the one door that ever
hands one over ($92CD, through `Pb3Gear`).  Counted are the pictures in which
a guest had anything of his own in the air and how many of them reached a
thing of the level, and the question asked of them is the plain one: in every
pairing, and in both games' levels, a guest's weapons land.  It has to be
asked of the pairing and the level together, because seven of the eight boxes
would be filled by a single working half.
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

# How many areas each stage of Power Blade 2 has, and how many stages Solbrain
# has.  The same two numbers every stand of Э5 uses.
PB2 = [7, 8, 7, 7, 10, 14, 10]
SOL = 20

EDGES = ['in_left', 'in_right', 'in_top', 'in_bottom',
         'out_left', 'out_right', 'out_top', 'out_bottom']

# The four pairings of Э5.6, and how long each record is played for.  Nine
# hundred pictures is what Э5.7 walks; six hundred is enough here, because
# what is counted is whether a guest's weapon ever lands and not how far the
# pilot gets.
PAIRS = [['pb2', 'pb2'], ['pb2', 'sol'], ['sol', 'pb2'], ['sol', 'sol']]
FRAMES = 600


def runs():
    out = []
    for st in range(len(PB2)):
        for ar in range(PB2[st]):
            out.append({'game': 'pb2', 'stage': st, 'area': ar})
    for st in range(SOL):
        out.append({'game': 'sol', 'stage': st, 'area': 0})
    return out


def parse(line):
    """One placement: which level, which kind of thing, which sort of weapon,
    where it stood, and what came of it."""
    f = line.split()
    if len(f) != 22 or f[0] != 'arm':
        return None
    return {
        'where': f[1], 'kind': int(f[3], 16), 'sort': f[5], 'edge': f[7],
        'want': int(f[9]), 'hit': int(f[11]), 'again': int(f[13]),
        'took': int(f[15]), 'cost': int(f[17]), 'owed': int(f[19]),
        'power': int(f[21]),
    }


def played(line):
    """One record played out: how many pictures a guest had something in the
    air, and how many of those reached a thing of the level."""
    f = line.split()
    if len(f) != 10 or f[0] != 'live':
        return None
    return {
        'where': f[1], 'pair': '%s %s' % (f[2], f[3]), 'ran': int(f[5]),
        'flying': int(f[7]), 'landed': int(f[9]),
    }


def missing(line):
    """A kind of thing a guest's weapon could not reach at all."""
    f = line.split()
    if len(f) != 6 or f[0] != 'unreached':
        return None
    return {'game': f[1], 'type': int(f[3], 16), 'why': f[5]}


def main():
    scratch = P.scratch('pb3arms')
    try:
        path = os.path.join(scratch, 'arms.json')
        open(path, 'w').write(json.dumps({
            'runs': runs(), 'edges': EDGES,
            'live': {'frames': FRAMES, 'kinds': PAIRS}}))
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--pb3arms=%s' % path],
                           capture_output=True, text=True, timeout=7200)
        lines = r.stdout.split('\n')
        rows = [p for p in (parse(l) for l in lines) if p]
        gaps = [p for p in (missing(l) for l in lines) if p]
        live = [p for p in (played(l) for l in lines) if p]
        if not rows:
            sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
            print('the engine reached nothing')
            return 1
        # Inside the reach it lands, outside it does not.  One question: a
        # reach that is too big and one that is too small are the same mistake
        # seen from two sides.
        wrong = [p for p in rows if p['hit'] != p['want']]
        # The rest a thing gets after a blow is the level's, and it holds.
        twice = [p for p in rows if p['hit'] == 1 and p['again'] != 0]
        # It takes off what its own game says it takes off -- unless the thing
        # had less left than that, which none here has.
        weak = [p for p in rows
                if p['hit'] == 1 and p['took'] not in (0, p['power'])]
        # And the level says what it cost the weapon, in the level's own
        # number for how much that thing hurts.
        owed = [p for p in rows if p['hit'] == 1 and p['cost'] != p['owed']]
        for p in (wrong + twice + weak + owed)[:12]:
            print('%-6s kind %02X %-6s %-10s wanted %d got %d again %d '
                  'took %d of %d cost %d of %d'
                  % (p['where'], p['kind'], p['sort'], p['edge'], p['want'],
                     p['hit'], p['again'], p['took'], p['power'], p['cost'],
                     p['owed']))
        for g in gaps[:12]:
            print('%s type %02X has no %s' % (g['game'], g['type'], g['why']))
        kinds = sorted({(p['where'][0], p['kind']) for p in rows})
        sorts = sorted({p['sort'] for p in rows})
        print('%d placements over %d kinds of thing, weapon of %s'
              % (len(rows), len(kinds), ', '.join(sorts)))
        took = sorted({p['took'] for p in rows if p['hit']})
        print('the blows that landed took %s off the thing'
              % ', '.join(str(d) for d in took))
        print('%d landed where they should not have or missed where they '
              'should not have, %d landed through the rest, %d took the wrong '
              'amount, %d were charged the wrong amount, %d kinds of thing no '
              'guest weapon could reach'
              % (len(wrong), len(twice), len(weak), len(owed), len(gaps)))
        bad = len(wrong) + len(twice) + len(weak) + len(owed) + len(gaps)
        print('%d of %d placements differ from what a foreign weapon has to do'
              % (bad, len(rows)))
        bad += judge(live)
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


def judge(live):
    """The second leg: in every pairing, and in both games' levels, a guest's
    weapons are in the air and they land."""
    if not live:
        print('nothing was played out')
        return 1
    boxes = {}
    for p in live:
        # `where` is the record's own name; its first letter says whose level
        # this is -- `p0.1` a Power Blade area, `s3` a Solbrain stage.
        box = boxes.setdefault((p['pair'], p['where'][0]),
                               {'recs': 0, 'flying': 0, 'landed': 0, 'hit': 0})
        box['recs'] += 1
        box['flying'] += p['flying']
        box['landed'] += p['landed']
        box['hit'] += 1 if p['landed'] else 0
    empty = 0
    for key in sorted(boxes):
        b = boxes[key]
        pair, game = key
        print('%-8s in %s: %3d records, %6d pictures with something in the '
              'air, %5d blows landed, in %d records'
              % (pair, 'a Power Blade area' if game == 'p' else 'a Solbrain '
                 'stage   ', b['recs'], b['flying'], b['landed'], b['hit']))
        if b['landed'] == 0:
            empty += 1
    if len(boxes) != len(PAIRS) * 2:
        print('%d of the %d pairings in a level were never played at all'
              % (len(PAIRS) * 2 - len(boxes), len(PAIRS) * 2))
        empty += len(PAIRS) * 2 - len(boxes)
    print('%d of %d pairings in a level landed nothing at all'
          % (empty, len(PAIRS) * 2))
    return empty


if __name__ == '__main__':
    sys.exit(main())
