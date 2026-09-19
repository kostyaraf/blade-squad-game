#!/usr/bin/env python3
"""Э5.4 acceptance: a foreign enemy against a foreign hero.

Э5.1 taught a level to answer either hero; Э5.2 put both of them on one
screen.  A level is not only its floor, though: the things standing on it are
that game's too, and on a Power Blade area they have to be able to reach a
Solbrain hero, and the other way about.

Both games already do the same sum -- a rectangle laid over a rectangle -- and
each already asks it of exactly one hero, named in one place: `slots[0]` for
`Pb2Objects.contact`, `hero` and the box `hero_box` builds for
`SolObjects.touch`.  So nothing is woven into either sweep.  The other game's
hero is stood in that one place, the sweep is run over the same things in the
same order, and what the sweep decides is handed back to him as his own game's
blow.  `work/re/pb3_hits.md` has the whole of it.

There is no cartridge to compare against -- neither game ever saw the other's
enemies -- so acceptance is four mechanical questions, and the places they are
asked at are not guessed.  The reach of a touch is the thing's own box grown by
the hero's own box, which is the sum both games already do, and the hero is put
on each of its four edges and one step outside each.  A step is one pixel in a
Power Blade area and one sixteenth of a pixel in a Solbrain stage, because that
is the grid each game keeps its places on:

  * inside an edge he is hit, every time and on every edge;
  * outside it he is not, every time and on every edge;
  * hit twice running, the second one does not land: the grace each game gives
    him after a blow is his own and stays his own;
  * and no kind of thing is left that the engine could not translate at all --
    every kind of both games has a box and a number of damage.

A kind is not the same word in the two games.  Power Blade knows a thing by its
type, and its box, its middle and its damage are all tables by type, so the
type is the kind.  Solbrain knows it by the picture it is wearing, and the box
and the meaning both hang off that, so the kind there is a box-and-meaning pair
and the number printed is which box it is.

What is deliberately *not* asked here is how much it took off him.  The two
scales differ (sixteen for the Power Blade hero, eight for the Solbrain one)
and the number between them is a decision, not a reading; it is made by
`Pb3Pair.hurt_to_sol` and `Pb3Pair.hurt_to_pb2`, written down in
`work/re/pb3_hits.md`, and printed here rather than judged.  What is printed is
already in the numbers of the hero the blow reached.
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

# The eight places round a box: one sixteenth inside each of the four edges
# and one sixteenth outside each.  The engine knows them by these names.
EDGES = ['in_left', 'in_right', 'in_top', 'in_bottom',
         'out_left', 'out_right', 'out_top', 'out_bottom']


def runs():
    out = []
    for st in range(len(PB2)):
        for ar in range(PB2[st]):
            out.append({'game': 'pb2', 'stage': st, 'area': ar})
    for st in range(SOL):
        out.append({'game': 'sol', 'stage': st, 'area': 0})
    return out


def parse(line):
    """One placement: which level, which thing, whose hero, and what came of
    it.  `hit` is whether the blow landed, `again` whether a second one landed
    straight after, `dmg` how much the first took off him."""
    f = line.split()
    if len(f) != 16 or f[0] != 'hit':
        return None
    return {
        'where': f[1], 'type': int(f[3], 16), 'guest': f[5], 'edge': f[7],
        'want': int(f[9]), 'hit': int(f[11]), 'again': int(f[13]),
        'dmg': int(f[15]),
    }


def missing(line):
    """A kind of thing the engine could not translate at all."""
    f = line.split()
    if len(f) != 6 or f[0] != 'untranslated':
        return None
    return {'game': f[1], 'type': int(f[3], 16), 'why': f[5]}


def main():
    scratch = P.scratch('pb3hits')
    try:
        path = os.path.join(scratch, 'hits.json')
        open(path, 'w').write(json.dumps({'runs': runs(), 'edges': EDGES}))
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--pb3hits=%s' % path],
                           capture_output=True, text=True, timeout=3600)
        lines = r.stdout.split('\n')
        rows = [p for p in (parse(l) for l in lines) if p]
        gaps = [p for p in (missing(l) for l in lines) if p]
        if not rows:
            sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
            print('the engine hit nobody')
            return 1
        # Inside an edge it lands, outside it does not.  One question, because
        # a box that is too big and a box that is too small are the same
        # mistake seen from two sides.
        wrong = [p for p in rows if p['hit'] != p['want']]
        # And the grace after a blow is the hero's own.
        twice = [p for p in rows if p['hit'] == 1 and p['again'] != 0]
        for p in (wrong + twice)[:12]:
            print('%-6s type %02X guest %-3s %-10s wanted %d got %d again %d'
                  % (p['where'], p['type'], p['guest'], p['edge'],
                     p['want'], p['hit'], p['again']))
        for g in gaps[:12]:
            print('%s type %02X has no %s' % (g['game'], g['type'], g['why']))
        kinds = sorted({(p['where'][0], p['type']) for p in rows})
        guests = sorted({p['guest'] for p in rows})
        print('%d placements over %d kinds of thing, hero of %s'
              % (len(rows), len(kinds), ' and '.join(guests)))
        took = sorted({p['dmg'] for p in rows if p['hit']})
        print('the blows that landed took %s off him'
              % ', '.join(str(d) for d in took))
        print('%d landed where they should not have or missed where they '
              'should not have, %d landed through the grace, %d kinds of '
              'thing the engine could not translate'
              % (len(wrong), len(twice), len(gaps)))
        bad = len(wrong) + len(twice) + len(gaps)
        print('%d of %d placements differ from what a foreign blow has to do'
              % (bad, len(rows)))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


if __name__ == '__main__':
    sys.exit(main())
