#!/usr/bin/env python3
"""Э6.3.4 acceptance: the hero's own step must ask for the noises it asks for.

Э6.3.3 judged the noises a thing's mind asks for, on the harness that drives
the minds.  The hero is not driven there -- his row is handed over as the
cartridge left it -- so his own six places were named and left alone.  This
stand is the other half: the harness is `verify_player`'s (`--replay=`), where
the engine drives his step and nothing else, and what is judged is what that
step asked for.

Which places are his is settled by the **place in the cartridge**, not by the
slot: the hero has no slot of his own to be told apart by, and everything else
asking in the same step belongs to a table of things this harness does not
have.  His six are all in bank 8, and they are listed below.

Everything else the cartridge asked for in the same step is counted and put
out, so a run says out loud how much of the stream it left alone.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402

# The places the hero's own step asks from, and what each of them is.  All
# six are in bank 8, which is his; nothing else in that bank asks.
MINE = {
    # $915A -- out of a slide he catches the wall in front of him.  The
    # cartridge throws the return address away and jumps into the climb.
    0x9184: 'he caught the wall',
    # $938D and $93B9 -- the other road to the same noise: a wall caught in
    # mid air.  Two routines ask it, both through $9417.
    0x9419: 'he caught the wall in the air',
    # $9423 -- landing, and only a landing hard enough to drop him into a
    # crouch ($0112 at $40 or over) is heard.
    0x9455: 'he came down hard',
    # $9491 -- catching a ladder out of the air.  Bare he catches it in
    # silence; in a suit ($9A) it clangs.
    0x949F: 'a ladder in a suit',
    # $927A and $9315 -- suit one, mid air, taking hold of a ceiling.
    0x92EA: 'a ceiling in suit one',
    # $9B0A -- suit three flying: its engine is heard every twentieth step,
    # counted in $0112.
    0x9BA6: 'the flying engine',
}
BANK = 8


def run_engine(cfg, path):
    """The replay harness, told to put the noises out as well.

    One field more on each line, after a bar: the numbers the step asked for,
    in order, or a dash.
    """
    import json
    import subprocess
    cfg = dict(cfg, noise=True)
    open(path, 'w').write(json.dumps(cfg))
    try:
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--replay=' + path], capture_output=True,
                           text=True, timeout=V.ENGINE_WAIT)
    except subprocess.TimeoutExpired:
        sys.stderr.write('the engine never stopped\n')
        return []
    out = []
    for line in r.stdout.split('\n'):
        if '|' not in line:
            continue
        head, say = line.strip().split('|')
        f = head.split()
        if len(f) != 8 or not all(x.lstrip('-').isdigit() for x in f):
            continue
        out.append((tuple(int(x) for x in f[:7]),
                    [] if say.strip() == '-'
                    else [int(x, 16) for x in say.split()]))
    if not out:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return out


# Every place the cartridge asked from over a run, and how often.
SEEN = {}


def _say(v):
    return ' '.join('%02X' % n for n in v) or '-'


def check(name, script, stage, area, tmp, spot=None, pokes=()):
    """One script on the cartridge and in the engine.

    Returns the steps compared and how many of the stream was judged, or the
    first step that disagreed.
    """
    rows = V.logic_frames(V.ordinary(pb2_trace.trace(
        script, V.FRAMES, stage=stage, area=area, spot=spot, pokes=pokes)))
    rows = rows[:-1]
    if spot is not None:
        rows = rows[V.SETTLE:]
    if len(rows) < 2:
        return 0, (0, 0, 0), None
    got = run_engine(V.replay(rows), os.path.join(tmp, 'r.json'))
    # Where the cartridge's own hero stood at the end of each step, as
    # `verify_player` reckons it.  A step from which the two no longer stand
    # in the same place cannot have its sound judged: what a suit does in the
    # air is not yet held against the cartridge anywhere (verify_player's
    # regression run wears no suit), and a stream compared past a parting of
    # the ways would be judging that parting and not the sound.  So the run is
    # cut there and the cut is counted.
    vertical = V.Area(stage, area).vertical
    want = []
    for r in rows[1:]:
        x = V.s24(r['xh'], r['xp'], r['xf'])
        y = V.s24(r['yh'], r['yp'], r['yf'])
        if vertical:
            y += r['shift_after'] << 8
        else:
            x += r['shift_after'] << 8
        want.append((x, y, r['vx'], r['vy'], r['state'], r['sub'],
                     r['pose']))
    judged = named = 0
    cut = 0
    for i, r in enumerate(rows[1:]):
        if i >= len(got):
            break
        if got[i][0] != want[i]:
            cut = i + 1
            break
        asked = r['asks']
        for num, site, bank, _slot in asked:
            was = SEEN.setdefault((bank, site), [0, set()])
            was[0] += 1
            was[1].add(num)
        theirs = [num for num, site, bank, _slot in asked
                  if bank == BANK and site in MINE]
        named += len(asked) - len(theirs)
        judged += len(theirs)
        if theirs != got[i][1]:
            where = ['%d:$%04X=%02X' % (bank, site, num)
                     for num, site, bank, _slot in asked]
            return None, None, (i + 1, _say(theirs), _say(got[i][1]), where)
    return (cut - 1 if cut else len(rows) - 1), (judged, named, cut), None


def main():
    n_random = 3
    seed = 909
    suits = [0, 1, 2, 3, 4, 5]
    targets = V.areas_from_index()
    for a in sys.argv[1:]:
        if a.startswith('--random='):
            n_random = int(a.split('=')[1])
        elif a.startswith('--seed='):
            seed = int(a.split('=')[1])
        elif a.startswith('--suits='):
            suits = [int(x) for x in a.split('=')[1].split(',')]
        elif a.startswith('--areas='):
            targets = [tuple(int(x) for x in p.split(':'))
                       for p in a.split('=')[1].split(',')]
    tmp = pb2_trace.P.scratch('heronoise')
    ran = bad = steps = judged = named = short = 0
    try:
        for suit in suits:
            # A suit is put on behind the game's back, as verify_player does
            # it: $9A says which and $56 that it is owned.
            pokes = () if suit == 0 else ((0x9A, suit), (0x56, 0x0F))
            for stage, area in targets:
                spot = V.settled_spot(stage, area)
                if spot is None:
                    continue
                for name, script in V.random_scripts(
                        n_random, seed + 31 * (stage * 16 + area)):
                    ran += 1
                    n, b, diff = check(name, script, stage, area, tmp, spot,
                                       pokes)
                    label = 'suit%d %d:%-2d %-12s' % (suit, stage, area, name)
                    if diff is None:
                        steps += n
                        judged += b[0]
                        named += b[1]
                        if b[2]:
                            short += 1
                        print('%s ok   %d steps, %d judged, %d named%s'
                              % (label, n, b[0], b[1],
                                 '   (cut at %d: he stands elsewhere)' % b[2]
                                 if b[2] else ''))
                    else:
                        bad += 1
                        print('%s DIFF at step %d' % (label, diff[0]))
                        print('    game   %s' % (diff[1],))
                        print('    engine %s' % (diff[2],))
                        print('    places %s' % ' '.join(diff[3]))
                    sys.stdout.flush()
    finally:
        pb2_trace.P.sweep(tmp)
    print('%d steps, %d requests judged, %d named and left alone'
          % (steps, judged, named))
    print('%d of %d runs were cut short because the two no longer stood in '
          'the same place' % (short, ran))
    print('%d places asked over these runs:' % len(SEEN))
    for (bank, site), (n_times, nums) in sorted(SEEN.items()):
        print('    %2d:$%04X  %5d times  asks %s%s'
              % (bank, site, n_times,
                 ' '.join('%02X' % v for v in sorted(nums)),
                 '   judged' if bank == BANK and site in MINE else ''))
    print('%d of %d scripts differ from what the cartridge asked for'
          % (bad, ran))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
