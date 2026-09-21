#!/usr/bin/env python3
"""Э6.3.9 acceptance: the screen a stage is picked on must ask what it asks.

The screen is $859D in bank 0, and its flow is one byte -- $19 -- with a table
of twenty four steps at $85A2.  Six of them ask the driver for something:

    0   $85DD  $45   the fade is over and the screen comes up
    10  $86DD  $44   the map laid out, the other way in
    12  $8743  $29   START was taken and the stage is his
    12  $8787  $36   he turns round on the spot
    13  $89B3  $36   he changes his mind mid-ride and turns round
    21  $8886  $44   the map laid out, the way the map itself hands over

Four of the six are the port's: `Pb2Select` is the screen, its steps as well
as its picture, and steps twelve to eighteen and twenty-one are all there.
The fifth ($45) waits on the fade -- $80D9, which the port does not have at
all, because the fade is a picture and the picture of this screen is Э3.10b.
The sixth ($44 of step ten) is the same number asked the same way from an
entry the port does not use.

What is compared is a stream, one line to a picture, as everywhere else in
Э6.3: which numbers were asked for, in which picture, in what order.  The
three counters of the screen -- which step it is on, which stage is picked and
which way he looks -- are compared in the same line, because a request judged
in a picture where the two sides have already parted is no proof at all.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_probe as P                                        # noqa: E402
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402
import verify_select as SEL                                  # noqa: E402

# $19 := $14 and $18 := 3 is what the map hands over, and $53/$5B/$56 go in a
# picture earlier because $8838 reads them the moment it starts.  Both numbers
# are `verify_select`'s, and so is READY: step twenty runs in the picture after
# the poke, step twenty-one in the one after that, and by READY the screen is
# on step twelve waiting for the pad.
SET_AT, PUSH_AT, READY = SEL.SET_AT, SEL.PUSH_AT, SEL.READY
# A row of the trace is counted from the frame the run starts at, and that is
# `P.PICK_LEVEL` here, so a row's number is the frame's own.  The step poked
# in at PUSH_AT is read out two pictures later: step twenty runs in PUSH_AT+2
# and leaves twenty-one behind it, step twenty-one runs in PUSH_AT+3 and
# leaves twelve.  Both of them are the making of `Pb2Select`, which is the
# engine's line nought, so the pad is first read a picture after that.
#
# `verify_select`'s own READY counts pictures and not frames -- a photograph
# shows what the frame before it worked out -- so it is not the number here.
LAID = [PUSH_AT + 2, PUSH_AT + 3]
FIRST_PAD = PUSH_AT + 4

# (name, stage, $5B, $56, script)
SCENES = [
    ('still',        0, 0x00, 0x00, [('-', 40)]),
    ('cleared',      0, 0x0F, 0x00, [('-', 40)]),
    ('ride-right',   0, 0x00, 0x00, [('-', 8), ('RIGHT', 4), ('-', 180)]),
    ('ride-left',    2, 0x00, 0x00, [('-', 8), ('LEFT', 4), ('-', 180)]),
    ('turn-about',   0, 0x00, 0x00, [('-', 8), ('LEFT', 4), ('-', 60)]),
    ('turn-and-go',  2, 0x00, 0x00, [('-', 8), ('LEFT', 4), ('-', 40),
                                     ('LEFT', 4), ('-', 180)]),
    ('changed-mind', 0, 0x00, 0x00, [('-', 8), ('RIGHT', 4), ('-', 30),
                                     ('LEFT', 4), ('-', 200)]),
    ('mind-late',    2, 0x00, 0x00, [('-', 8), ('LEFT', 4), ('-', 90),
                                     ('RIGHT', 4), ('-', 200)]),
    ('edge-right',   3, 0x00, 0x00, [('-', 8), ('RIGHT', 4), ('-', 60)]),
    ('edge-left',    0, 0x00, 0x00, [('-', 8), ('LEFT', 4), ('-', 60)]),
    ('fifth',        3, 0x0F, 0x00, [('-', 8), ('RIGHT', 4), ('-', 200)]),
    ('start',        0, 0x00, 0x00, [('-', 8), ('START', 4), ('-', 8)]),
    ('refused',      0, 0x01, 0x01, [('-', 8), ('START', 4), ('-', 40)]),
    ('start-fifth',  4, 0x0F, 0x00, [('-', 8), ('START', 4), ('-', 8)]),
]

# The numbers this screen asks for, so that a run says which of them it saw.
MINE = {0x00: 'be quiet', 0x44: 'the map laid out',
        0x36: 'he turns round', 0x29: 'the stage is his'}


def script_frames(script):
    return SEL.script_frames(script)


def cartridge(stage, cleared, owned, script):
    """The screen played on the cartridge, one row to a picture.

    The same standing as `verify_select`: the stage, the stages already
    finished and the suits already taken go in at SET_AT, because $8838 reads
    them the moment it starts, and the step the map hands over goes in at
    PUSH_AT.  The pad is read from READY on.
    """
    frames = script_frames(script)
    script_at = [(FIRST_PAD + n, keys or '-')
                 for n, keys in enumerate(frames)]
    return pb2_trace.trace([(0, '-')] + script_at,
                           FIRST_PAD + len(frames) + 2,
                           first=P.PICK_LEVEL, stage=0, area=0, spot=None,
                           during=((0x53, stage, SET_AT),
                                   (0x5B, cleared, SET_AT),
                                   (0x56, owned, SET_AT),
                                   (0x19, 0x14, PUSH_AT),
                                   (0x18, 0x03, PUSH_AT)))


def engine(stage, cleared, owned, script, path):
    """`Pb2Select` given the same pad, one line to a picture."""
    cfg = {'stage': stage, 'cleared': cleared, 'owned': owned,
           'frames': [{'hit': _bits(keys)} for keys in script_frames(script)]}
    open(path, 'w').write(json.dumps(cfg))
    try:
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--choose=' + path], capture_output=True,
                           text=True, timeout=V.ENGINE_WAIT)
    except subprocess.TimeoutExpired:
        sys.stderr.write('the engine never stopped\n')
        return []
    out = []
    for line in r.stdout.split('\n'):
        parts = line.strip().split('|')
        if len(parts) != 2 or not parts[0].split()[:1] or \
                not parts[0].split()[0].isdigit():
            continue
        head = [int(x) for x in parts[0].split()]
        say = parts[1].strip()
        out.append((head, [] if say == '-'
                    else [int(x, 16) for x in say.split()]))
    if not out:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return out


# $48 -- the pad as the cartridge orders it, which is what `Pb2Select` reads.
BITS = {'START': 0x10, 'RIGHT': 0x01, 'LEFT': 0x02}


def _bits(keys):
    down = 0
    for nm in (keys or '-').split('+'):
        down |= BITS.get(nm, 0)
    return down


def _say(ns):
    return ' '.join('%02X' % n for n in ns) or '-'


def check(name, stage, cleared, owned, script, tmp):
    rows = cartridge(stage, cleared, owned, script)
    mine = engine(stage, cleared, owned, script, os.path.join(tmp, 'c.json'))
    if not mine:
        return None, None, (0, 'the engine said nothing', '-')
    seen = {}
    n = 0
    for i, (head, ours) in enumerate(mine):
        # Line nought is the making of the class, which is steps twenty and
        # twenty-one both; the pictures of those two steps are folded into it.
        if i == 0:
            w = list(LAID)
        else:
            w = [FIRST_PAD + i - 1]
        if w[-1] >= len(rows):
            break
        theirs = []
        for k in w:
            for num, _site, _bank, _slot in rows[k]['asks']:
                theirs.append(num)
        r = rows[w[-1]]
        was = (r['sel_step'], r['choice'], 1 if r['face'] & 0x40 else 0)
        got = (head[0], head[1], head[2])
        if theirs != ours or was != got:
            return None, None, (i, '%s   %s' % (_say(theirs), was),
                                '%s   %s' % (_say(ours), got))
        for num in theirs:
            seen[num] = seen.get(num, 0) + 1
        n += 1
        # $8730 -- once START has been taken the screen fades away, and what it
        # does there is Э3.10b's and not this stand's.
        if head[3] >= 0:
            break
    return n, seen, None


def main():
    scenes = SCENES
    for a in sys.argv[1:]:
        if a.startswith('--only='):
            want = a.split('=')[1].split(',')
            scenes = [s for s in scenes if s[0] in want]
    tmp = pb2_trace.P.scratch('chooseverify')
    bad = pics = 0
    total = {}
    try:
        for name, stage, cleared, owned, script in scenes:
            n, seen, diff = check(name, stage, cleared, owned, script, tmp)
            if diff is None:
                pics += n
                for k, v in seen.items():
                    total[k] = total.get(k, 0) + v
                print('%-13s ok   %d pictures, %s' % (
                    name, n, ', '.join('%d of %02X' % (v, k)
                                       for k, v in sorted(seen.items()))
                    or 'nothing asked'))
            else:
                bad += 1
                print('%-13s DIFF at picture %d' % (name, diff[0]))
                print('    game   %s' % diff[1])
                print('    engine %s' % diff[2])
            sys.stdout.flush()
    finally:
        pb2_trace.P.sweep(tmp)
    print('%d pictures, %s' % (pics, ', '.join(
        '%d of %02X (%s)' % (v, k, MINE.get(k, '?'))
        for k, v in sorted(total.items())) or 'nothing asked'))
    print('%d of %d scenes differ from what the cartridge asked for'
          % (bad, len(scenes)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
