#!/usr/bin/env python3
"""Э6.3.8 acceptance: the port must ask the tunes the level's flow asks for.

The cartridge keeps its flow in one byte, $1A, and a table of twelve entries at
$CDD3 says what each step of it does.  Five of the twelve ask the driver for
something:

    2, 7, 11, 12   the stage's own tune                 $CE25
    6, 11          the one area that has a tune of its own $CF42
    6, 12          a boss's room                        $CF9F
    8              he died                              $CFF7
    10             and then be quiet                    $D017

`Pb2Flow` is those five and nothing else: the port has no $1A, and its flow is
`main.gd`.  So what is compared here is a step at a time -- the step is poked
into $1A together with the four bytes its gates read, and what the cartridge
asks for over that step is put against what `Pb2Flow` answers for the same
four bytes.

Why a step is poked and not played
----------------------------------
Two of the seven cannot be reached by playing at all: the last boss's room
(stage 5, area 0) cannot be walked into from an area a stand can stand in, and
the twelfth step is the continue screen, which is not in the engine yet.  The
rest could be played, but a run that plays them proves the same thing far more
slowly and with the whole level in the way.

What holds the verdict up is that the gates are the only thing poked: $53, $9C,
$AD and $79 are what $CE28, $CF42 and $CF6B read, and a poke that upset
anything else would show as a difference and not as a pass.
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

# The picture the step is poked in, far enough into the area that the walk-on
# has settled and the area's own tune has been asked for.
AT = 40
# How long a step is given.  The sixth and the seventh wait on $ED11 -- a call
# into bank $30 that turns the screen off -- and that took fifty-nine pictures
# in the run this number was chosen from.
BUDGET = 240

# Which step each step ends on, because the watch reports a cell as it stood at
# the end of a picture and the steps do not all ask before they move $1A on:
# $CE14 takes it on first, $CFF7 last.  The window a step's requests are looked
# for in is AT up to and including the first picture $1A reads this.
ENDS = {2: 3, 6: 3, 7: 3, 8: 9, 10: 11, 11: 3, 12: 3}

# (name, step, stage, area, phase, boss, owned)
CASES = [
    # Step 2: the top of a stage.  One case for each of the six tunes, and the
    # last stage twice, because its nought-th area is the last boss's room and
    # is the one area that does not take its stage's tune ($CE28).
    ('open-0',         2, 0, 0, 0, 0, 0x00),
    ('open-1',         2, 1, 0, 0, 0, 0x00),
    ('open-2',         2, 2, 0, 0, 0, 0x00),
    ('open-3',         2, 3, 0, 0, 0, 0x00),
    ('open-4',         2, 4, 0, 0, 0, 0x00),
    ('open-5-last',    2, 5, 0, 0, 0, 0x00),
    ('open-5-walk',    2, 5, 1, 0, 0, 0x00),
    # Step 7: the stage built again, which comes in below both gates.
    ('again-2',        7, 2, 4, 0, 0, 0x00),
    ('again-5-last',   7, 5, 0, 0, 0, 0x00),
    # Step 6: the area built again.  The one area with a tune of its own, the
    # same area in the other half of the stage, and the boss rooms.
    ('area-special',   6, 4, 3, 0, 0, 0x00),
    ('area-late',      6, 4, 3, 1, 0, 0x00),
    ('area-both',      6, 4, 3, 0, 1, 0x00),
    ('area-boss-0',    6, 0, 6, 0, 1, 0x00),
    ('area-boss-6th',  6, 5, 5, 0, 1, 0x00),
    ('area-boss-walk', 6, 5, 2, 0, 1, 0x00),
    ('area-boss-last', 6, 5, 0, 0, 1, 0x00),
    ('area-plain',     6, 1, 2, 0, 0, 0x00),
    # Step 8 and step 10: he died, and the mourning is over.
    ('died',           8, 0, 0, 0, 0, 0x00),
    ('mourned',        10, 0, 0, 0, 0, 0x00),
    # Step 11: the life is spent.  $D02E puts $79 back first, so a boss's room
    # is never what a spent life builds, and $D7AB decides where the life
    # starts -- which is what the tunes are read from and not the area he died
    # in.  The bit of $56 is the suit the middle of the stage keeps.
    ('life-top',     11, 0, 0, 0, 0, 0x00),
    ('life-middle',  11, 0, 5, 0, 0, 0x01),
    ('life-early',   11, 0, 2, 0, 0, 0x01),
    ('life-nosuit',  11, 0, 5, 0, 0, 0x00),
    ('life-half-1',  11, 0, 5, 1, 0, 0x01),
    ('life-half-2',  11, 0, 5, 2, 0, 0x01),
    ('life-3',       11, 3, 4, 0, 0, 0x08),
    ('life-4',       11, 4, 3, 0, 0, 0x1F),
    ('life-4-half',  11, 4, 3, 1, 0, 0x1F),
    ('life-4-late',  11, 4, 9, 2, 0, 0x1F),
    ('life-5',       11, 5, 3, 0, 0, 0x3F),
    ('life-boss',    11, 0, 6, 0, 1, 0x00),
    # Step 12: the game was continued.  It comes in at $CF5A, below the gate of
    # the area with its own tune but above the boss rooms'.
    ('again-3',        12, 3, 0, 0, 0, 0x00),
    ('cont-boss',      12, 0, 6, 0, 1, 0x00),
    ('cont-special',   12, 4, 3, 0, 0, 0x00),
]


def cartridge(step, stage, area, phase, boss, owned):
    """One step of the flow, poked into an ordinary area, and what it asked.

    The window is AT up to and including the first picture $1A reads the step
    this one ends on, so that whatever the level goes on to ask for once the
    step is over is no part of the verdict.

    The eleventh step is handed back where it put him as well ($9C and $AD),
    because it works that out for itself ($D7AB) and reads its tunes from it.
    """
    during = [(0x53, stage, AT), (0x9C, area, AT), (0xAD, phase, AT),
              (0x79, boss, AT), (0x1A, step, AT), (0x56, owned, AT)]
    if step == 10:
        # $C8 -- the driver's first track, which $D017 holds the game still
        # until it has run out.  The driver is not on trial here, and the area
        # this step is poked into is playing its own tune, so the cell is
        # handed over as the cartridge would leave it when a tune has ended.
        during.append((0xC8, 0x00, AT))
    rows = pb2_trace.trace([(0, '-')], BUDGET, stage=0, area=0,
                           spot=V.settled_spot(0, 0), during=tuple(during))
    end = ENDS[step]
    asked = []
    where = None
    for i in range(AT, len(rows)):
        r = rows[i]
        for n, _site, _bank, _slot in r['asks']:
            asked.append(n)
        where = (r['stage'], r['area'], r['phase'])
        if r['w_live'] == end:
            break
    return asked, where


def engine(cases, path):
    """`Pb2Flow` asked the same questions, one line to a case."""
    cfg = {'events': [{'step': c[1], 'stage': c[2], 'area': c[3],
                       'phase': c[4], 'boss': c[5], 'owned': c[6]}
                      for c in cases]}
    open(path, 'w').write(json.dumps(cfg))
    try:
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--flow=' + path], capture_output=True, text=True,
                           timeout=V.ENGINE_WAIT)
    except subprocess.TimeoutExpired:
        sys.stderr.write('the engine never stopped\n')
        return []
    out = []
    for line in r.stdout.split('\n'):
        parts = line.strip().split('|')
        if len(parts) != 2 or not parts[0].split()[:1] or \
                not parts[0].split()[0].isdigit():
            continue
        say = parts[1].strip()
        head = parts[0].split()
        out.append(([] if say == '-' else [int(x, 16) for x in say.split()],
                    (int(head[1]), int(head[2])) if len(head) == 3 else None))
    if len(out) != len(cases):
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return out


def _say(ns):
    return ' '.join('%02X' % n for n in ns) or '-'


def main():
    cases = CASES
    for a in sys.argv[1:]:
        if a.startswith('--only='):
            want = a.split('=')[1].split(',')
            cases = [c for c in cases if c[0] in want]
    tmp = pb2_trace.P.scratch('flowverify')
    mine = engine(cases, os.path.join(tmp, 'f.json'))
    bad = judged = 0
    try:
        for i, c in enumerate(cases):
            name, step, stage, area, phase, boss, owned = c
            theirs, where = cartridge(step, stage, area, phase, boss, owned)
            ours, to = mine[i] if i < len(mine) else (None, None)
            # $53 is not the stage's to change, so a step that moved it has
            # been poked into something it cannot do and the run says so.
            assert where is None or where[0] == stage, (name, where)
            was = None if to is None else (where[1], where[2])
            label = '%-16s step %2d  %d:%-2d ph%d %s' % (
                name, step, stage, area, phase,
                'boss' if boss else '    ')
            if theirs == ours and was == to:
                judged += len(theirs)
                print('%s ok   %s%s' % (label, _say(theirs),
                                        '' if to is None
                                        else '   -> %d:%d' % to))
            else:
                bad += 1
                print('%s DIFF' % label)
                print('    game   %s%s' % (_say(theirs),
                                           '' if was is None
                                           else '   -> %d:%d' % was))
                print('    engine %s%s' % ('-' if ours is None else _say(ours),
                                           '' if to is None
                                           else '   -> %d:%d' % to))
            sys.stdout.flush()
    finally:
        pb2_trace.P.sweep(tmp)
    print('%d steps of the flow, %d requests judged' % (len(cases), judged))
    print('%d of %d steps differ from what the cartridge asked for'
          % (bad, len(cases)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
