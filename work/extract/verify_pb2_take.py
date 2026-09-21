#!/usr/bin/env python3
"""Э6.3.6 acceptance, part three: what he picks up and what it says.

Six places ask, all of them inside `$B4CD` and the eight little routines after
it -- the ones that give him something:

    $B53C  `$1D`  a spare health tank ($9D, up to eight)
    $B551  `$1D`  a spare suit tank ($9E, up to eight)
    $B566  `$1D`  the second blade ($A2, up to one)
    $B579  `$1D`  the blade raised ($55, up to three)
    $B587  `$1D`  one more throw at once ($99, up to two)
    $B5A2  `$1F`  the suit capsule, the one with no cap at all

Health and suit energy ($B503, $B51B) ask for nothing themselves: they set the
mode and the measure of a refill, and the pouring is what is heard -- `$1B`,
once every fourth picture, which Э6.3.6's first stand judges.

How the cartridge is made to pick something up
----------------------------------------------
Nothing in an area gives these out, so a collectable is written into a slot of
the table where the hero stands: the type, the mark with bit `$40` (which is
what makes the sweep at `$B2C1` hand it to `$B4AF`), and the subtype in the
slot's `$049A`.  Five of them, one after another, so that the counter climbs
to its cap and the asking stops of itself.  Where he stands is read out of a
first recording, because the poke has to know it before the run begins.

The engine is handed `Pb2Status` alone and told, at the step the thing went
out of the table, to take that subtype.  Which step that was is read off the
table, not off the sound: the slot's type goes back to nought when `$B4AF` has
had it.  `$1D` and `$1F` are asked for by the menus of bank 0 as well, and by
`$D103`, but none of those is reachable from a level, so inside this harness
the number names the pickup and nothing else.
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
import verify_pb2_bar as B                                   # noqa: E402

MINE = {0x1D, 0x1F, 0x1B}

# The slot the collectable is written into.  High enough that nothing an area
# spawns of its own is ever in it.
SLOT = 20
# The pictures the five collectables are written on.  Far enough apart that
# the sweep has taken one before the next appears.
AT = (24, 60, 96, 132, 168)
FRAMES = 260


def field(f, slot):
    """$0400 -- the table of things, twenty-two slots to a field."""
    return 0x0400 + 22 * f + slot


# What each of the eight subtypes is, and what it fills.
SUBTYPE = {
    0x00: 'health',
    0x01: 'suit energy',
    0x02: 'a spare health tank',
    0x03: 'a spare suit tank',
    0x04: 'the suit capsule',
    0x05: 'the second blade',
    0x06: 'the blade raised',
    0x07: 'one more throw at once',
}


def pokes_for(sub, x, y):
    """A collectable of that subtype, standing where he stands.

    Type one is the sort the game forgets once it is taken ($B4AF clears the
    slot either way; type two is also written into $E580's memory, which is
    the whole game's business and not this stand's).
    """
    out = []
    for at in AT:
        out += [
            (field(0, SLOT), 0x01, at),          # $0400 -- the type
            (field(1, SLOT), 0x40, at),          # $0416 -- the mark: a pickup
            (field(2, SLOT), 0x00, at),          # $042C
            (field(3, SLOT), 0x00, at),          # $0442
            (field(7, SLOT), sub, at),           # $049A -- which of the eight
            (field(8, SLOT), 0x00, at),          # $04B0 -- on this screen
            (field(9, SLOT), y, at),             # $04C6
            (field(11, SLOT), 0x00, at),         # $04F2
            (field(12, SLOT), x, at),            # $0508
            (field(20, SLOT), 0x00, at),         # $05A4 -- not stunned
        ]
    return out


def cartridge(sub, before=(), stage=0, area=0):
    """Two recordings: one to learn where he stands, one with the pokes.

    `before` is what is written before he takes control -- how much health he
    has, how far the blade is already raised -- so that a cap can be reached
    with five collectables instead of nine.
    """
    first = pb2_trace.trace([(0, '-')], AT[0] + 4, stage=stage, area=area,
                            pokes=before)
    him = first[AT[0]]
    rows = pb2_trace.trace([(0, '-')], FRAMES, stage=stage, area=area,
                           pokes=before,
                           during=pokes_for(sub, him['xp'], him['yp']))
    out = []
    for r in rows:
        if r['area'] != rows[0]['area'] or r['stage'] != rows[0]['stage']:
            break
        out.append(r)
    return out


def cfg_for(rows):
    """What the engine is handed: the counters the run began with, every
    picture's `$1C`, and the step each collectable was taken on."""
    first = rows[0]
    cfg = {
        'stage': first['stage'], 'area': first['area'],
        'life': first['alive'], 'energy': first['energy'],
        'life_tanks': first['ltanks'], 'tanks': first['stanks'],
        'power': first['power'], 'second': first['second'],
        'extra': first['lim'], 'owned': 0,
        'time_hi': first['time_h'], 'time_lo': first['time_l'],
        'warn': first['warn'], 'mode': first['mode'],
        'frames': [],
    }
    taken = 0
    for r in rows[1:]:
        f = {'clock': r['clock'], 'frozen': r['stop'] != 0}
        # The slot going out of the table is the sweep having had it.  A
        # picture in which it was written in and taken away both shows up as
        # a birth and a death, and the death is the one that counts.
        if SLOT in r['died']:
            f['take'] = r['sub_taken']
            taken += 1
        cfg['frames'].append(f)
    return cfg, taken


def check(sub, tmp, before=()):
    rows = cartridge(sub, before)
    if len(rows) < 8:
        return None, 0, 0, ('the recording is too short', [])
    # Which subtype the slot was carrying when it went: the poke put it there
    # and nothing else writes it, but it is read back out of the recording so
    # that the engine is told what the cartridge really had.
    for r in rows:
        r['sub_taken'] = sub
    cfg, taken = cfg_for(rows)
    if taken == 0:
        return None, 0, 0, ('he never picked it up', [])
    got = B.run_engine(cfg, os.path.join(tmp, 't.json'))
    if got is None:
        return None, 0, 0, ('the engine said nothing', [])
    judged = 0
    for i, r in enumerate(rows[1:]):
        if i >= len(got):
            break
        state, said = got[i]
        was = (r['mode'], r['alive'], r['energy'], r['warn'],
               r['time_h'], r['time_l'], r['ltanks'],
               r['menu'], r['came'])
        if state != was:
            return None, judged, taken, ('the counters parted', [
                '    picture %d  engine    %s' % (r['frame'], state),
                '    picture %d  cartridge %s' % (r['frame'], was)])
        theirs = [n for n, _s, _b, _sl in r['asks'] if n in MINE]
        mine = [n for n in said if n in MINE]
        judged += len(theirs)
        if theirs != mine:
            return None, judged, taken, (
                'the sound parted from the cartridge', [
                    '    picture %d  engine %s  cartridge %s'
                    % (r['frame'], B._say(mine), B._say(theirs)),
                    '    places %s' % ' '.join('%d:$%04X=%02X' % (b, s, n)
                                               for n, s, b, _sl in r['asks'])])
    return len(got), judged, taken, None


# name, subtype, what is written before he takes control.
#
# Health and the blade are given twice over: once with room to spare, and once
# already at the top, where the cartridge turns back without asking for
# anything.  A cap reached in silence is as much of the port as the asking is.
CASES = [
    ('health',        0x00, ()),
    ('health-hurt',   0x00, ((0x049A, 0x08),)),
    ('energy',        0x01, ()),
    ('life-tank',     0x02, ()),
    ('life-tank-full', 0x02, ((0x9D, 0x07),)),
    ('suit-tank',     0x03, ()),
    ('capsule',       0x04, ()),
    ('blade-two',     0x05, ()),
    ('blade-power',   0x06, ()),
    ('blade-power-high', 0x06, ((0x55, 0x02),)),
    ('one-more',      0x07, ()),
    ('one-more-full', 0x07, ((0x99, 0x02),)),
]


def main():
    only = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--only=')]
    cases = CASES
    if only:
        want = only[0].split(',')
        cases = [c for c in CASES if c[0] in want]
    tmp = pb2_trace.P.scratch('takenoise')
    ran = bad = steps = judged = took = 0
    try:
        for name, sub, before in cases:
            ran += 1
            n, said, taken, why = check(sub, tmp, before)
            label = '%-18s %d %-24s' % (name, sub, SUBTYPE.get(sub, '?'))
            if why is not None:
                bad += 1
                print('%s FAILED -- %s' % (label, why[0]))
                for line in why[1]:
                    print(line)
            else:
                steps += n
                judged += said
                took += taken
                print('%s ok   %d pictures, %d taken, %d judged'
                      % (label, n, taken, said))
            sys.stdout.flush()
    finally:
        pb2_trace.P.sweep(tmp)
    print('%d pictures, %d collectables taken, %d requests judged'
          % (steps, took, judged))
    print('%d of %d cases differ from what the cartridge asked for'
          % (bad, ran))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
