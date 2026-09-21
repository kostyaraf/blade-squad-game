#!/usr/bin/env python3
"""Э6.3.5 acceptance: what he throws must ask for the noises the cartridge asks.

Three places in bank 9 ask, and they are the whole of the weapon's sound:

    $A338  `$1A`  the blade leaves his hand
    $A3D3  `$22`  the suit's beam leaves his hand
    $A58C  `$1A`  the blade in the air, once in every ten pictures

`$1A` and `$22` are asked for from nowhere else in the game -- the table in
work/re/sound_game.md is the proof -- so a stand may pick the stream apart by
the number alone and need not ask which routine the asking was in.  That
matters here: the harness is `verify_weapons`', which drives the throws and his
own step and nothing else, and everything else the cartridge asked for in the
same step (his own footing, the things, the bar) belongs to other stands.  Left
out by number on the cartridge's side, left out by number on the engine's --
the rule of Э6.3.3, and the verdict goes the wrong way if the two sides leave
out different things.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402
import verify_weapons as W                                   # noqa: E402

# The numbers this stand judges, and the places that ask for them.
MINE = {0x1A: 'the blade thrown, and its whirr',
        0x22: 'the beam thrown'}
# The places behind them, for the census: bank 9 and nowhere else.
SITES = {0xA33A: 'the blade thrown',
         0xA3D5: 'the beam thrown',
         0xA58E: 'the whirr of the blade in the air'}
BANK = 9

# Every place the cartridge asked from over a run, and how often.
SEEN = {}


def run_engine(cfg, path):
    """The weapons harness, told to put the sound out as well.

    Three fields to a line instead of two: the button's count, the differences
    of the throws' fields, and what was asked for, in order.
    """
    cfg = dict(cfg, noise=True)
    open(path, 'w').write(json.dumps(cfg))
    try:
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--weapon=' + path], capture_output=True,
                           text=True, timeout=V.ENGINE_WAIT)
    except subprocess.TimeoutExpired:
        sys.stderr.write('the engine never stopped\n')
        return None
    out = []
    for line in r.stdout.split('\n'):
        head, _, say = line.strip().partition('|')
        if not _:
            continue
        f = head.strip().split(' ', 1)
        if not f[0].isdigit():
            continue
        out.append([] if say.strip() == '-'
                   else [int(x, 16) for x in say.split()])
    if not out:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
        return None
    return out


def _say(nums):
    return ' '.join('%02X' % n for n in nums) or '-'


def check(name, script, stage, area, tmp, spot=None, pokes=()):
    """One run: the same recording `verify_weapons` judges the flight on."""
    rows = V.logic_frames(V.ordinary(pb2_trace.trace(
        script, W.FRAMES, stage=stage, area=area, spot=spot, pokes=pokes)))
    rows = rows[:-1][1:]
    if spot is not None:
        rows = rows[V.SETTLE:]
    if len(rows) < 4:
        return 0, 0, None
    got = run_engine(W.cfg_for(rows), os.path.join(tmp, 'a.json'))
    if got is None:
        return None, 0, ('the engine said nothing', [])
    judged = 0
    for i, r in enumerate(rows[1:]):
        if i >= len(got):
            break
        for n, site, bank, slot in r['asks']:
            was = SEEN.setdefault((bank, site), [0, set()])
            was[0] += 1
            was[1].add(n)
        theirs = [n for n, _s, _b, _sl in r['asks'] if n in MINE]
        mine = [n for n in got[i] if n in MINE]
        judged += len(theirs)
        if theirs != mine:
            where = ['%d:$%04X=%02X' % (bank, site, n)
                     for n, site, bank, _sl in r['asks']]
            return None, judged, ('the sound parted from the cartridge',
                                  ['    step %d  engine %s  cartridge %s'
                                   % (i + 1, _say(mine), _say(theirs)),
                                   '    places %s' % ' '.join(where)])
    return len(got), judged, None


def main():
    n_random = 0
    targets = [(0, 0)]
    seed = 7
    # Which gear he carries.  The bare blade asks for `$1A` and nothing else;
    # a suit is what opens `$22`, so a run of `plain` alone judges two thirds
    # of the weapon's sound.
    gear = None
    for a in sys.argv[1:]:
        if a.startswith('--random='):
            n_random = int(a.split('=')[1])
        elif a.startswith('--seed='):
            seed = int(a.split('=')[1])
        elif a == '--all-areas':
            targets = V.areas_from_index()
        elif a.startswith('--areas='):
            targets = [tuple(int(x) for x in p.split(':'))
                       for p in a.split('=')[1].split(',')]
        elif a.startswith('--gear='):
            want = a.split('=')[1].split(',')
            gear = [g for g in W.GEAR if g[0] in want]
    tmp = pb2_trace.P.scratch('arms')
    ran = bad = steps = judged = 0
    try:
        for stage, area in targets:
            scripts = list(W.SCRIPTS) if targets == [(0, 0)] else []
            scripts += W.random_scripts(n_random,
                                        seed + 31 * (stage * 16 + area))
            spot = None
            if targets != [(0, 0)]:
                spot = V.settled_spot(stage, area)
                if spot is None:
                    print('%d:%d  not played out of turn -- left out'
                          % (stage, area))
                    continue
            kit = gear if gear is not None else (
                W.GEAR if targets == [(0, 0)] else W.GEAR[:1])
            for worn, pokes in kit:
                for name, script in scripts:
                    tag = '%s/%s' % (worn, name)
                    n, said, why = check(name, script, stage, area, tmp,
                                         spot, pokes)
                    ran += 1
                    judged += said
                    if why is not None:
                        bad += 1
                        print('%d:%d %-30s FAILED -- %s'
                              % (stage, area, tag, why[0]))
                        for line in why[1]:
                            print(line)
                    else:
                        steps += n
                        print('%d:%d %-30s ok   %d steps, %d judged'
                              % (stage, area, tag, n, said))
                    sys.stdout.flush()
    finally:
        pb2_trace.P.sweep(tmp)
    print('%d steps, %d requests of the weapon judged' % (steps, judged))
    print('%d places asked over these runs:' % len(SEEN))
    for (bank, site), (n_times, nums) in sorted(SEEN.items()):
        print('    %2d:$%04X  %5d times  asks %s%s'
              % (bank, site, n_times, _say(sorted(nums)),
                 '   judged' if bank == BANK and site in SITES else ''))
    print('%d of %d scripts differ from what the cartridge asked for'
          % (bad, ran))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
