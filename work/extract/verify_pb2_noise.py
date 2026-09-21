#!/usr/bin/env python3
"""Э6.3.3 acceptance: the port must ask for the noises Power Blade 2 asks for.

Solbrain writes a number into a cell of zero page and the driver picks it up
next picture, so a stand there can watch the cell.  Power Blade 2 has no cell:
a request is a **call**, and the door is `$ECE8`.  What is compared here is
therefore a stream -- which number was asked for, in which step of the game,
in what order.

A hundred and sixteen places reach that door.  Seventy-nine ask for a number;
thirty-seven ask for nought through `$EC0C` (`LDA #$00 / JMP $ECE8`), which is
how the game says "be quiet", and the driver on nought silences all eight
channels.  Almost every request is the pair of them.

What is judged and what is only named
-------------------------------------
The harness is `verify_spawns`': the cartridge is recorded, the engine is
handed everything it cannot know for itself, and its own minds run against the
record.  Only the places whose type the engine drives itself are judged there,
and only their requests are judged here.

The cartridge says which place asked: a thing's turn runs with the place in
`X`, and the emulator is told to report `X` at the door.  The engine says the
same, because `Pb2Objects.turns` puts the place in `Pb2Sound.at_slot` for as
long as a mind runs.

Everything else the cartridge asked for in the same step -- the hero's own
noises, the level's, the bar's, the screens between areas -- is counted and
printed, so that a run says out loud how much of the stream it left alone.
Those places belong to stands of their own.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402
import verify_spawns as SP                                   # noqa: E402

def run_engine(cfg, path):
    """The spawns harness, told to put the sound out as well.

    Seven fields to a line instead of six: the places whose turn was the
    engine's own, and what was asked for, in order.
    """
    import json
    import subprocess
    cfg = dict(cfg, noise=True)
    open(path, 'w').write(json.dumps(cfg))
    try:
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--spawns=' + path], capture_output=True,
                           text=True, timeout=V.ENGINE_WAIT)
    except subprocess.TimeoutExpired:
        sys.stderr.write('the engine never stopped\n')
        return []
    out = []
    for line in r.stdout.split('\n'):
        line = line.strip()
        parts = line.split('|')
        if len(parts) != 7 or not parts[0].isdigit():
            continue
        own, say = parts[6].split(';')
        out.append((
            set() if own == '-' else {int(x) for x in own.split()},
            [] if say == '-' else [(int(p.split(':')[0]),
                                    int(p.split(':')[1], 16))
                                   for p in say.split()]))
    if not out:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return out


# Places that ask through a piece of the game this harness does not run for
# itself, and whose requests are therefore named here and judged elsewhere.
# The place in `X` still names a thing, but the code is not that thing's mind.
ELSEWHERE = {
    # $B36A -- the blow that reaches the hero, inside the touch sweep.  This
    # harness hands the hero's row over as the cartridge left it, with his
    # forty pictures of grace already counted, so the engine's own sweep turns
    # back at the door and never gets as far as the noise.  His own step is
    # what `verify_player` drives, and that is where this one belongs.
    0xB371: 'the hero is hit',
    # $B4CD and the eight little routines after it -- what a collectable gives
    # him.  Those are his own counters, not the table's, and a harness that
    # keeps none of them leaves `status` empty; this one does, so the engine
    # never reaches the noise.  `verify_status` is where they belong.
    0xB53C: 'a spare health tank',
    0xB551: 'a spare suit tank',
    0xB566: 'the second blade',
    0xB579: 'the blade raised',
    0xB587: 'one more throw at once',
    0xB5A2: 'the suit capsule',
}

# Numbers no other place in the game asks for, so that leaving them out on the
# engine's side leaves nothing else out with them.  $18 is the blow that
# reaches the hero and $B371 is the only place that asks for it; the six
# pick-ups all ask for $1D or $1F, which plenty of other places ask for too,
# and they need no entry here because the harness leaves `status` empty and the
# engine cannot reach them at all.
ASIDE = {0x18}


def want(rows):
    """What the cartridge asked for, one entry per step, in order."""
    out = []
    for r in rows[1:]:
        out.append(r['asks'])
    return out


# Every place the cartridge asked from over a run, and how often: the roadmap
# of the work, since a place no run ever reaches cannot be ported by a stand.
SEEN = {}


def _say(asked):
    """A list of requests as the cartridge writes them: place and number."""
    return ' '.join('%d:%02X' % (slot, n) for slot, n in asked) or '-'


def _check(script, stage, area, tmp, spot, frames, pokes=(), first=None,
           patch=False, early=()):
    rows = V.logic_frames(V.ordinary(pb2_trace.trace(
        script, frames, stage=stage, area=area, spot=spot, pokes=pokes,
        first=first, patch=patch, early=early)))
    rows = rows[:-1][V.SETTLE:]
    if len(rows) < 2:
        return 0, (0, 0, 0), None
    theirs = want(rows)
    got = run_engine(SP.script_for(rows, stage, area, spot, script, pokes,
                                   first, patch, early),
                     os.path.join(tmp, 'n.json'))
    judged = named = 0
    # How many place-steps the engine drove by itself at all.  A run where
    # this is nought has proved nothing, however green it looks.
    drove = 0
    for i, asked in enumerate(theirs):
        if i >= len(got):
            break
        own, mine = got[i]
        drove += len(own)
        # The cartridge's requests that belong to a place the engine drove
        # itself this step.  What names the place is X, which is where a
        # thing's turn keeps it; the bank cannot name it, because the things
        # are spread over four pairs of banks and the hero sits in one of
        # them.  The rest are named, not judged.
        # $0400 -- what stood in the place that asked, which is the one thing
        # that says whose code a place belongs to.
        table = rows[i + 1]['whole'][-1] if rows[i + 1]['whole'] else None
        for n, site, bank, slot in asked:
            key = (bank, site)
            was = SEEN.setdefault(key, [0, set(), set(), set()])
            was[0] += 1
            was[1].add(n)
            if table is not None:
                was[3].add((slot, table[slot][0]))
            if slot in own and site not in ELSEWHERE:
                was[2].add(slot)
        theirs_here = [(slot, n) for n, site, _bank, slot in asked
                       if slot in own and site not in ELSEWHERE]
        named += len(asked) - len(theirs_here)
        judged += len(theirs_here)
        # The engine names a place the way the cartridge does and cannot say
        # which of its own routines the asking was in, so a number left out on
        # one side has to be left out on the other or the verdict goes the
        # wrong way: a run that holds the hero up by patching the cartridge
        # ($ROMPOKE) leaves him unhurt there and hurt here, and the engine
        # would then ask where the cartridge did not.
        mine_here = [(slot, n) for slot, n in mine
                     if slot in own and n not in ASIDE]
        if theirs_here != mine_here:
            where = ['%d:$%04X=%02X/%d' % (bank, site, n, slot)
                     for n, site, bank, slot in asked]
            return None, None, (i + 1, _say(theirs_here), _say(mine_here),
                                where)
    return len(theirs), (judged, named, drove), None


def check(name, script, stage, area, tmp, spot, frames, drag=False,
          gates=False, boss=False):
    P = pb2_trace.P
    first = P.IN_LEVEL + (SP.BOSS_WAIT if boss else 0)
    pokes = SP.BOSS_POKES if boss else ()
    early = SP.boss_early(area) if boss else ()
    P.ROMPOKE = list(P.IMMORTAL) if drag or boss else []
    if drag:
        pin, far, near = (SP.PIN_DOWN if V.Area(stage, area).vertical
                          else SP.PIN_ALONG)
        P.FREEZE = [(pin, far, 0), (pin, near, first + frames // 2)]
    else:
        P.FREEZE = []
    if gates:
        P.FREEZE = P.FREEZE + SP.GATES
    try:
        return _check(script, stage, area, tmp, spot, frames, pokes, first,
                      boss, early)
    finally:
        P.ROMPOKE = []
        P.FREEZE = []


def main():
    n_random = 2
    seed = 7
    targets = V.areas_from_index()
    for a in sys.argv[1:]:
        if a.startswith('--random='):
            n_random = int(a.split('=')[1])
        elif a.startswith('--seed='):
            seed = int(a.split('=')[1])
        elif a.startswith('--areas='):
            targets = [tuple(int(x) for x in p.split(':'))
                       for p in a.split('=')[1].split(',')]
    boss = SP.boss_stage()
    tmp = pb2_trace.P.scratch('noiseverify')
    ran = bad = steps = judged = named = drove = 0
    try:
        for stage, area in targets:
            here = stage == boss
            spot = None if here else V.settled_spot(stage, area)
            if spot is None and not here:
                continue
            scripts = [(n, s, V.FRAMES, False, False) for n, s in
                       V.random_scripts(n_random,
                                        seed + 31 * (stage * 16 + area))]
            scripts.append(('drag', [(0, '-')], SP.DRAG, True, False))
            for name, script, frames, drag, gates in scripts:
                ran += 1
                n, b, diff = check(name, script, stage, area, tmp, spot,
                                   frames, drag, gates, here)
                label = '%d:%-2d %-12s' % (stage, area, name)
                if diff is None:
                    steps += n
                    judged += b[0]
                    named += b[1]
                    drove += b[2]
                    print('%s ok   %d steps, %d judged, %d named, %d drove'
                          % (label, n, b[0], b[1], b[2]))
                else:
                    bad += 1
                    print('%s DIFF at step %d' % (label, diff[0]))
                    print('    game   %s' % (diff[1],))
                    print('    engine %s' % (diff[2],))
                    print('    places %s' % ' '.join(diff[3]))
                sys.stdout.flush()
    finally:
        pb2_trace.P.sweep(tmp)
    print('%d steps, %d requests judged, %d named and left alone, '
          '%d place-steps the engine drove itself'
          % (steps, judged, named, drove))
    print('%d places asked over these runs:' % len(SEEN))
    for (bank, site), (n_times, nums, slots, who) in sorted(SEEN.items()):
        print('    %2d:$%04X  %5d times  asks %s  from %s%s'
              % (bank, site, n_times,
                 ' '.join('%02X' % v for v in sorted(nums)),
                 ' '.join('%d/%02X' % w for w in sorted(who)),
                 '   judged' if slots else ''))
    print('%d of %d scripts differ from what the cartridge asked for'
          % (bad, ran))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
