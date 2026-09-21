#!/usr/bin/env python3
"""Э6.3.7 acceptance: the suits' menu must ask what the cartridge asks.

Two places, both of them inside `$D0A6`, the routine `$CDBB` calls before
anything else in a picture:

    $D0D5  `$17`  START, and the menu opens
    $D29A  `$30`  UP or DOWN, and another suit is put on
    $D103  `$1F`  START again over a different suit, and the change begins

Shutting the menu over the suit he came in with is no change at all ($D0DF),
and the cartridge asks for nothing there -- silence is as much of the port as
the asking is, so it is judged too.

What the engine is given and what it must find for itself
---------------------------------------------------------
`Pb2Status` alone runs here, on the `--bar=` harness of Э6.3.6, one picture at
a time.  It is handed `$1C`, `$48` (what has just gone down, which is all the
routine reads of the pad), `$9A` (the suit, because the picking of it is
`$D259` and no part of this stand) and `$CD` (the driver's fifth track, which
the change of suit waits on).  Whether the menu opens or shuts, what it
remembers of the suit he came in with, and whether that makes a change of suit
-- all of it the engine works out for itself, and all of it is compared every
picture along with the sound.

`$17` and `$30` are asked for nowhere else in the game.  `$1F` is asked in
one other place -- `$B5A2`, the suit capsule -- and nothing here picks
anything up, so the number is the site (the rule of Э6.3.5).
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402
import verify_pb2_bar as B                                   # noqa: E402

MINE = {0x17: 'the menu opens', 0x30: 'a suit put on',
        0x1F: 'the suit he chose'}

# When the first press falls.  Far enough in that the level is up and playing,
# and the eight settling pictures of a trace are behind it.
AT = 30

# name, stage, area, frames, the script of the pad, and what else the
# cartridge is poked with before the run.
#
# $56 is poked to fifteen in every run, and the suit's bar ($A0) to a full
# sixteen: the ring the menu walks is the suits he owns, and $D25F refuses to
# walk it at all while there is nothing left to wear them on.
CASES = [
    # START once: it opens, and nothing shuts it again.
    ('open', 0, 0, 200, [(0, '-'), (AT, 'START'), (AT + 2, '-')], ()),
    # START twice over the same suit: it opens and shuts, and the shutting is
    # silent ($D0F6).
    ('open-shut', 0, 0, 260,
     [(0, '-'), (AT, 'START'), (AT + 2, '-'), (AT + 60, 'START'),
      (AT + 62, '-')], ()),
    # START held down: the routine reads $48, which is what has just gone
    # down, so a button held is one press and not forty.
    ('held', 0, 0, 200, [(0, '-'), (AT, 'START')], ()),
    # Open, walk the ring to another suit, then START: a change, and $27 goes
    # to seven.
    ('open-change', 0, 0, 400,
     [(0, '-'), (AT, 'START'), (AT + 2, '-'), (AT + 40, 'UP'),
      (AT + 42, '-'), (AT + 90, 'START'), (AT + 92, '-')], ()),
    # The same, walked the other way.
    ('open-change-down', 0, 0, 400,
     [(0, '-'), (AT, 'START'), (AT + 2, '-'), (AT + 40, 'DOWN'),
      (AT + 42, '-'), (AT + 90, 'START'), (AT + 92, '-')], ()),
    # Round the ring and back to where he started: two walks the same way
    # through a ring of one owned suit and nothing, and the shutting is silent
    # again.
    ('ring-round', 0, 0, 460,
     [(0, '-'), (AT, 'START'), (AT + 2, '-'), (AT + 40, 'UP'),
      (AT + 42, '-'), (AT + 80, 'UP'), (AT + 82, '-'),
      (AT + 150, 'START'), (AT + 152, '-')], ()),
    # The last boss of all is fought without the menu ($D0AC): not a boss's
    # room, the last stage, its nought-th area.  START does nothing at all,
    # and the silence is the whole of the case.  It is not an area ordinary
    # play can be dropped into,
    # so the run stands in the area beside it and $9C is written to nought --
    # which is all the gate reads.  Nothing is built or drawn from it after
    # the level is up, and the counters are compared as everywhere else, so a
    # poke that upset anything would show as a difference and not as a pass.
    ('last-boss', 5, 1, 200, [(0, '-'), (AT, 'START'), (AT + 2, '-'),
                              (AT + 60, 'START'), (AT + 62, '-')],
     ((0x9C, 0x00),)),
    # And twice over: opened, shut, opened again.
    ('twice', 0, 0, 460,
     [(0, '-'), (AT, 'START'), (AT + 2, '-'), (AT + 60, 'START'),
      (AT + 62, '-'), (AT + 120, 'START'), (AT + 122, '-')], ()),
]


def cartridge(script, frames, stage, area, spot, extra=()):
    """One recording, one row per picture, cut where the area changes."""
    rows = pb2_trace.trace(script, frames, stage=stage, area=area, spot=spot,
                           pokes=((0x56, 0x0F), (0x00A0, 0x10)) + tuple(extra))
    out = []
    for r in rows:
        if r['area'] != rows[0]['area'] or r['stage'] != rows[0]['stage']:
            break
        out.append(r)
    return out


def cfg_for(rows):
    """What the engine is handed: the counters the run began with, and every
    picture's `$1C`, `$48` and `$9A`."""
    first = rows[0]
    cfg = {
        'stage': first['stage'], 'area': first['area'],
        'suit': first['wear'], 'owned': 0x0F,
        'life': first['alive'], 'energy': first['energy'],
        'life_tanks': first['ltanks'], 'tanks': first['stanks'],
        # $85:$86 -- how far into the next cell a worn suit already is.
        'drain_hi': first['drain_h'], 'drain_lo': first['drain_l'],
        'time_hi': first['time_h'], 'time_lo': first['time_l'],
        'warn': first['warn'], 'mode': first['mode'],
        'frames': [],
    }
    for r in rows[1:]:
        cfg['frames'].append({
            'clock': r['clock'], 'frozen': r['stop'] != 0,
            # $48 -- and it is the picture's own, because the routine runs
            # before anything else in the picture and reads it as it stands.
            'hit': r['hit'],
            # $9A -- the ring is walked by $D259, which is not on trial here.
            'suit': r['wear'],
            # $CD -- the driver's fifth track.  The change of suit lasts as
            # long as the fanfare does ($F02B), and the driver belongs to
            # Э6.3.1, not here.
            'tune': r['tune'],
        })
    return cfg


def check(name, stage, area, frames, script, extra, tmp):
    spot = V.settled_spot(stage, area) if (stage, area) != (0, 0) else None
    if spot is None and (stage, area) != (0, 0):
        return None, 0, 0, ('not ordinary play', [])
    rows = cartridge(script, frames, stage, area, spot, extra)
    if len(rows) < 8:
        return None, 0, 0, ('the recording is too short', [])
    got = B.run_engine(cfg_for(rows), os.path.join(tmp, 'm.json'))
    if got is None:
        return None, 0, 0, ('the engine said nothing', [])
    judged = 0
    opened = 0
    was_menu = rows[0]['menu']
    for i, r in enumerate(rows[1:]):
        if i >= len(got):
            break
        state, said = got[i]
        if r['menu'] != was_menu:
            was_menu = r['menu']
            if was_menu:
                opened += 1
        was = (r['mode'], r['alive'], r['energy'], r['warn'],
               r['time_h'], r['time_l'], r['ltanks'],
               r['menu'], r['came'])
        if state != was:
            return None, judged, opened, ('the counters parted', [
                '    picture %d  engine    %s' % (r['frame'], state),
                '    picture %d  cartridge %s' % (r['frame'], was)])
        theirs = [n for n, _s, _b, _sl in r['asks'] if n in MINE]
        mine = [n for n in said if n in MINE]
        judged += len(theirs)
        if theirs != mine:
            return None, judged, opened, (
                'the sound parted from the cartridge', [
                    '    picture %d  engine %s  cartridge %s'
                    % (r['frame'], B._say(mine), B._say(theirs)),
                    '    places %s' % ' '.join('%d:$%04X=%02X' % (b, s, n)
                                               for n, s, b, _sl in r['asks'])])
    return len(got), judged, opened, None


def main():
    only = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--only=')]
    names = only[0].split(',') if only else None
    tmp = pb2_trace.P.scratch('menunoise')
    ran = bad = steps = judged = opened = 0
    try:
        for name, stage, area, frames, script, extra in CASES:
            if names is not None and name not in names:
                continue
            ran += 1
            n, said, opens, why = check(name, stage, area, frames, script,
                                        extra, tmp)
            if why is not None:
                bad += 1
                print('%-17s FAILED -- %s' % (name, why[0]))
                for line in why[1]:
                    print(line)
            else:
                steps += n
                judged += said
                opened += opens
                print('%-17s ok   %d pictures, %d judged, %d openings'
                      % (name, n, said, opens))
            sys.stdout.flush()
    finally:
        pb2_trace.P.sweep(tmp)
    print('%d pictures, %d requests of the menu judged, %d openings'
          % (steps, judged, opened))
    print('%d of %d cases differ from what the cartridge asked for'
          % (bad, ran))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
