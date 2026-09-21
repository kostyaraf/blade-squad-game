#!/usr/bin/env python3
"""Э6.3.6 acceptance: the clock and the bar must ask what the cartridge asks.

Three places, all of them the status routine's own ($CDB8 and what it calls):

    $CA50  `$34`  the bell, once the time is short
    $EFF0  `$1B`  one cell of the health bar poured back
    $F015  `$1B`  one cell of the suit bar poured back

None of the three is reached by playing an area: the bell wants a time under
`$0030`, which is twenty minutes of standing still, and a refill wants
something picked up.  So the cartridge is poked into them -- the time handed
over at a chosen picture, the mode and the measure of a refill written where
`$B503` and `$B51B` would have written them -- and the engine is handed the
same bytes at the same step.

What the engine is given and what it must find for itself
---------------------------------------------------------
Only `Pb2Status` runs here, one step at a time.  It is handed `$1C`, the count
both refills and the clock are measured on, and the pokes; everything else --
when the bell rings, how many cells are poured and when the pouring stops --
it must work out.  The counters are compared every step as well as the sound,
because a stream that agrees while the counters have parted proves nothing.

`$34` and `$1B` are asked for nowhere else in the game, so the stream can be
picked apart by the number alone (the rule of Э6.3.5).
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

# The numbers this stand judges.
MINE = {0x34: 'the bell', 0x1B: 'one cell of the bar'}

# Where the pokes land.  Far enough in that the level is up and playing.
AT = 24

# name, frames, what the cartridge is poked with at picture AT.
#
# $27 is the mode: five is the health bar filling ($B518), six the suit's
# ($B52F).  $2F and $30 are how many cells are left to pour, $049A the health
# and $A0 the suit's bar, $95/$96 the time and $57 whether the bell is set.
CASES = [
    # The time put at $0032, so that two ticks bring it to $0030, the bell is
    # set there ($CA6C) and rings on every tick after it.
    ('bell',        700, [(0x0095, 0x00), (0x0096, 0x32), (0x0057, 0x00)]),
    # And with the bell already set, so that the very first tick rings.
    ('bell-set',    400, [(0x0095, 0x00), (0x0096, 0x29), (0x0057, 0x01)]),
    # Four cells into a bar with room for eight: four asks, one every fourth
    # picture, and then $EFFB puts the mode back.
    ('fill-life',   200, [(0x049A, 0x08), (0x002F, 0x04), (0x0027, 0x05)]),
    # Twelve cells into a bar with room for twelve.
    ('fill-long',   200, [(0x049A, 0x04), (0x002F, 0x0C), (0x0027, 0x05)]),
    # Twelve cells into a bar with room for four: the pouring stops at the top
    # ($EFEC) and the eight that are left over are never asked for.
    ('fill-over',   200, [(0x049A, 0x0C), (0x002F, 0x0C), (0x0027, 0x05)]),
    # A bar already full: $EFEC turns back at once and nothing is heard.
    ('fill-full',   200, [(0x049A, 0x10), (0x002F, 0x04), (0x0027, 0x05)]),
    # The same three for the suit's bar, which is $A0 and $30.
    ('suit-fill',   200, [(0x00A0, 0x08), (0x0030, 0x04), (0x0027, 0x06)]),
    ('suit-over',   200, [(0x00A0, 0x0C), (0x0030, 0x0C), (0x0027, 0x06)]),
    ('suit-full',   200, [(0x00A0, 0x10), (0x0030, 0x04), (0x0027, 0x06)]),
]


def cartridge(frames, pokes, stage=0, area=0):
    """One recording, poked at picture AT, one row per picture.

    `ordinary` cannot be used here: it cuts the run at the first change of
    mode or of health, which is exactly what the pokes are for.
    """
    rows = pb2_trace.trace([(0, '-')], frames, stage=stage, area=area,
                           during=[(a, v, AT) for a, v in pokes])
    out = []
    for r in rows:
        if r['area'] != rows[0]['area'] or r['stage'] != rows[0]['stage']:
            break
        out.append(r)
    return out


def cfg_for(rows, pokes):
    """What the engine is handed: the counters the run began with, and every
    picture's `$1C` -- and at the step the poke landed in, the poke."""
    first = rows[0]
    cfg = {
        'stage': first['stage'], 'area': first['area'],
        'life': first['alive'], 'energy': first['energy'],
        'life_tanks': first['ltanks'], 'tanks': first['stanks'],
        'time_hi': first['time_h'], 'time_lo': first['time_l'],
        'warn': first['warn'], 'mode': first['mode'],
        'frames': [],
    }
    by_addr = dict(pokes)
    for r in rows[1:]:
        # $1C is taken on before the routine reads it, so the count the
        # picture was left holding is the one it read.
        f = {'clock': r['clock'], 'frozen': r['stop'] != 0}
        if r['frame'] == AT:
            # The poke landed in this picture, so the engine is put into the
            # same place by the same bytes.
            if 0x0027 in by_addr:
                f['mode'] = by_addr[0x0027]
            if 0x002F in by_addr:
                f['fill_life'] = by_addr[0x002F]
            if 0x0030 in by_addr:
                f['fill_energy'] = by_addr[0x0030]
            if 0x049A in by_addr:
                f['life'] = by_addr[0x049A]
            if 0x00A0 in by_addr:
                f['energy'] = by_addr[0x00A0]
            if 0x0095 in by_addr:
                f['time_hi'] = by_addr[0x0095]
                f['time_lo'] = by_addr[0x0096]
                f['warn'] = by_addr[0x0057]
        cfg['frames'].append(f)
    return cfg


def run_engine(cfg, path):
    open(path, 'w').write(json.dumps(cfg))
    try:
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--bar=' + path], capture_output=True,
                           text=True, timeout=V.ENGINE_WAIT)
    except subprocess.TimeoutExpired:
        sys.stderr.write('the engine never stopped\n')
        return None
    out = []
    for line in r.stdout.split('\n'):
        head, bar, say = line.strip().partition('|')
        if not bar:
            continue
        f = head.split()
        if len(f) != 9 or not f[0].isdigit():
            continue
        out.append((
            (int(f[0]), int(f[1]), int(f[2]), int(f[3]),
             int(f[4], 16), int(f[5], 16), int(f[6]),
             int(f[7]), int(f[8])),
            [] if say.strip() == '-' else [int(x, 16) for x in say.split()]))
    if not out:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
        return None
    return out


def _say(nums):
    return ' '.join('%02X' % n for n in nums) or '-'


def check(name, frames, pokes, tmp):
    rows = cartridge(frames, pokes)
    if len(rows) < 8:
        return None, 0, ('the recording is too short', [])
    got = run_engine(cfg_for(rows, pokes), os.path.join(tmp, 'b.json'))
    if got is None:
        return None, 0, ('the engine said nothing', [])
    judged = 0
    for i, r in enumerate(rows[1:]):
        if i >= len(got):
            break
        state, said = got[i]
        was = (r['mode'], r['alive'], r['energy'], r['warn'],
               r['time_h'], r['time_l'], r['ltanks'],
               r['menu'], r['came'])
        if state != was:
            return None, judged, ('the counters parted', [
                '    picture %d  engine %s' % (r['frame'], state),
                '    picture %d  cartridge %s' % (r['frame'], was)])
        theirs = [n for n, _s, _b, _sl in r['asks'] if n in MINE]
        mine = [n for n in said if n in MINE]
        judged += len(theirs)
        if theirs != mine:
            return None, judged, ('the sound parted from the cartridge', [
                '    picture %d  engine %s  cartridge %s'
                % (r['frame'], _say(mine), _say(theirs)),
                '    places %s' % ' '.join('%d:$%04X=%02X' % (b, s, n)
                                           for n, s, b, _sl in r['asks'])])
    return len(got), judged, None


def main():
    only = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--only=')]
    names = only[0].split(',') if only else None
    tmp = pb2_trace.P.scratch('barnoise')
    ran = bad = steps = judged = 0
    try:
        for name, frames, pokes in CASES:
            if names is not None and name not in names:
                continue
            ran += 1
            n, said, why = check(name, frames, pokes, tmp)
            if why is not None:
                bad += 1
                print('%-11s FAILED -- %s' % (name, why[0]))
                for line in why[1]:
                    print(line)
            else:
                steps += n
                judged += said
                print('%-11s ok   %d pictures, %d judged' % (name, n, said))
            sys.stdout.flush()
    finally:
        pb2_trace.P.sweep(tmp)
    print('%d pictures, %d requests of the bar and the clock judged'
          % (steps, judged))
    print('%d of %d cases differ from what the cartridge asked for'
          % (bad, ran))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
