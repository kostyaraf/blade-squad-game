#!/usr/bin/env python3
"""Э4.12 acceptance: AREA CLEARED ($1B) and the paying out that follows ($1C).

A stage ends by handing the game to $93AE, which puts $1B on $02.  $E09C lays
the screen -- $15 with the ground and the two plates of the area over it -- and
walks straight on to $E117, which is nine steps counted by $4D: the writing
slides apart, the tune is waited out, what is still to be paid is handed to the
count ten a picture and then one a picture, the suits still on him are handed
over one every sixteenth picture, the picture is walked down to black, and at
the bottom of it the bit of $2D that says this area is done with is turned on.
That bit is the one thing in the whole port nothing else sets, and STAGE SELECT
reads it to know which stages are left and when the game is over.

Neither mode is reached from the reset without playing a stage to its end, so
both sides are put on it: the cartridge by poking $02 out of a state taken in
the middle of the first stage, the engine by being told to begin its walk
there.  Everything the two would otherwise disagree about is poked on both
sides -- the stage, what the game has scored, how many suits are still on him,
what is still to be paid, and the pace of the walk of the colours.

$FD is the one input neither side shares: the sound driver zeroes it when it
begins a tune and counts it up at the end, and no tune is made in the engine.
So the cartridge is read for the picture its own fanfare ends on and the engine
is told to end the wait on the same turn.  Everything else is the mode's own
work and is compared straight:

* the chain -- $1B, then $1C, then $19, and how long each lasts;
* the board -- the two kilobytes of name map and the thirty two colours, taken
  at the third picture of every one of the nine steps;
* what the mode is holding -- $4C..$4F, $25..$28, $75, $7D, $55, the three
  counts of the eight bands ($0740, $0750, $0760), what the game has scored
  ($05FD..$05FF), the suits ($05C5), what is still to be paid ($05C6:$05C7)
  and $2D itself.
"""
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import sol_probe as P                                          # noqa: E402
import verify_sol_player as V                                  # noqa: E402
import verify_sol_boot as B                                    # noqa: E402

POKE_AT = P.IN_LEVEL + 5
## Long enough for the whole of a clearing: two and thirty pictures of the
## writing sliding apart, the fanfare, both payings out, two waits of $80 and
## the walk down to black.
RUN = POKE_AT + 1500
TURNS = 1500

## The mode the clearing hands the game to, which is where this stand stops.
LAST = 0x19

## $28 and $25 -- the pace of the walk of the colours and how much of the next
## step of it is still to come.  Neither mode sets either and a stage leaves
## its own, so both sides are given the same; the engine's own are eight and
## eight, which is what a walk that has not been asked for anything stands at.
PACE = 8

## Which stages to clear.  Between them the six areas $E223 names are all
## covered: stage 0 is the first, which sets no bit and names the stage that
## follows outright, and 10, 3, 17, 6 and 1 are the other five.
CASES = [
    ('stage 0, the opening area', 0, 5, 1000, 123456),
    ('stage 10, area one', 10, 3, 2500, 50),
    ('stage 3, area two', 3, 0, 700, 999990),
    ('stage 17, area three', 17, 8, 0, 0),
    ('stage 6, area four', 6, 1, 255, 1000),
    ('stage 1, area five', 1, 5, 1000, 123456),
    # A paying out with nothing at all to pay, which is the one way the two
    # counting steps are seen to end on the picture they begin on.
    ('stage 4, nothing owed', 4, 0, 0, 12345),
    # And one with more than a page still owed, so that both the ten a picture
    # and the one a picture are walked.
    ('stage 12, a page and more', 12, 2, 4097, 7),
]


def pokes(stage, suit, bonus, score):
    out = ['0002=1B', '0055=%02X' % stage, '0028=%02X' % PACE,
           '0025=%02X' % PACE, '002D=00',
           '05C5=%02X' % suit,
           '05C6=%02X' % (bonus & 0xFF), '05C7=%02X' % (bonus >> 8)]
    n = score
    for addr in (0x05FD, 0x05FE, 0x05FF):
        out.append('%04X=%02X' % (addr, (n >> 16) & 0xFF))
        n = (n << 8) & 0xFFFFFF
    return [x for one in out for x in ('-poke', '%s@%d' % (one, POKE_AT))]


def cmd_base(d, state, frames, stage, suit, bonus, score):
    inp = os.path.join(d, 'i.inp')
    open(inp, 'w').write('%d -\n' % (P.IN_LEVEL + 1))
    return [P.EMU, P.ROM, '-loadstate', state, '-input', inp,
            '-frames', str(frames)] + pokes(stage, suit, bonus, score)


def cart_walk(stage, suit, bonus, score):
    """The chain, the map of turns to pictures, and the two counts the engine
    is started on -- and the turn the fanfare ends on."""
    d = P.scratch('clear_walk')
    try:
        st = P.make_state(os.path.join(d, 'base'))
        tr = os.path.join(d, 't.txt')
        subprocess.run(cmd_base(d, st, RUN, stage, suit, bonus, score)
                       + ['-watch', '0000-00FF', '-trace', tr],
                       check=True, capture_output=True)
        modes, turn, tick, zero, step = {}, {}, {}, {}, {}
        clock = 0
        seen = None
        last0 = 0
        fd_at = None
        for line in open(tr):
            if not line.startswith('WATCH'):
                continue
            f, _pc, _bk, ad, v = line.split()[1].split(',')
            f, ad, v = int(f), int(ad, 16), int(v, 16)
            if f < POKE_AT:
                if ad == 0x0C:
                    seen = v
                elif ad == 0x00:
                    last0 = v
                continue
            if ad == 0x00:
                last0 = v
            elif ad == 0x0C:
                if seen is None or v != seen:
                    clock += 1
                    seen = v
                    turn[clock] = f
                    tick[clock] = v
                    zero[clock] = last0
            elif ad == 0x02:
                modes[max(clock, 1)] = v
            elif ad == 0x4D:
                step.setdefault(v, max(clock, 1))
            elif ad == 0xFD and v != 0 and fd_at is None:
                fd_at = max(clock, 1)
        out = [(c, modes[c]) for c in sorted(turn) if c in modes]
        begin = (tick[1] - 1) & 0xFF
        first0 = (zero[2] - 2) & 0xFF
        return out, turn, begin, first0, step, fd_at
    finally:
        P.sweep(d)


def cart_look(frames, into, stage, suit, bonus, score):
    d = P.scratch('clear_look')
    try:
        st = P.make_state(os.path.join(d, 'base'))
        out = {f: os.path.join(into, 'rom_%d.vram' % f) for f in frames}
        cmd = cmd_base(d, st, max(frames) + 3, stage, suit, bonus, score)
        for f in frames:
            cmd += ['-vram', '%s@%d' % (out[f], f + 1)]
        subprocess.run(cmd, check=True, capture_output=True)
        return out
    finally:
        P.sweep(d)


def cart_state(path):
    """The board, the thirty two, and what the mode is holding."""
    b = open(path, 'rb').read()
    assert b[:8] == b'PB3VRAM1', path
    board, pal, ram = b[12:12 + 2048], b[2060:2092], b[6222:6222 + 2048]
    return board, list(pal), {
        '4c': ram[0x4C], '4d': ram[0x4D], '4e': ram[0x4E], '4f': ram[0x4F],
        '25': ram[0x25], '26': ram[0x26], '27': ram[0x27], '28': ram[0x28],
        '75': ram[0x75], '7d': ram[0x7D], 'stage': ram[0x55],
        '2d': ram[0x2D], '05c5': ram[0x05C5],
        '05c6': ram[0x05C6] | (ram[0x05C7] << 8),
        'score': (ram[0x05FD] << 16) | (ram[0x05FE] << 8) | ram[0x05FF],
        '0740': list(ram[0x0740:0x0748]),
        '0750': list(ram[0x0750:0x0758]),
        '0760': list(ram[0x0760:0x0768]),
        '0100': list(ram[0x0100:0x0120]),
    }


def engine(frames, into, clock, tick, fd, stage, suit, bonus, score):
    spec = ('%d,set:mode:%d,set:stage:%d,set:clock:%d,set:tick:%d'
            ',set:score:%d,set:suit:%d,set:bonus:%d,set:fd:%d'
            % (TURNS, 0x1B, stage, clock, tick, score, suit, bonus, fd))
    board = {f: os.path.join(into, 'eng_%d.bin' % f) for f in frames}
    held = {f: os.path.join(into, 'eng_%d.json' % f) for f in frames}
    for f in sorted(frames):
        spec += ',board:%d:%s' % (f - 1, board[f])
        spec += ',state:%d:%s' % (f - 1, held[f])
    cmd = [V.GODOT, '--path', V.GAME, '--headless', '--', '--solwalk=' + spec]
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=1800)
    chain = []
    for line in r.stdout.splitlines():
        m = re.match(r'^(\d+) ([0-9A-F]{2})( |$)', line)
        if m:
            chain.append((int(m.group(1)) + 1, int(m.group(2), 16)))
    if not chain:
        raise RuntimeError(r.stdout[-3000:] + r.stderr[-3000:])
    return chain, board, held


def engine_state(board_path, state_path):
    b = open(board_path, 'rb').read()
    d = json.load(open(state_path))
    return b[:2048], list(b[2048:2080]), d


## Which of the thirty two the picture unit shows to compare.  $3F10, $3F14,
## $3F18 and $3F1C are wired to $3F00, $3F04, $3F08 and $3F0C: what is written
## to them lands elsewhere and what is read back is whatever stood there when
## the console was switched on.  The game's own thirty two at $0100 are
## compared whole below, and those four are the only ones this leaves out.
HUES = [i for i in range(32) if i < 16 or i % 4 != 0]


def one(name, stage, suit, bonus, score):
    bad, all = 0, 0
    print('-- %s' % name)
    walk, turn, clock, tick0, step, fd_at = cart_walk(stage, suit, bonus,
                                                      score)
    if fd_at is None:
        print('the fanfare does not end inside the run')
        return 1, 1
    cart = B.spans(walk, max(turn) + 1)
    eng_chain, _, _ = engine([], '', clock, tick0, fd_at - 1, stage, suit,
                             bonus, score)
    eng = B.spans(eng_chain, TURNS)
    for side in (cart, eng):
        for i, one_ in enumerate(side):
            if one_[0] == LAST:
                del side[i + 1:]
                break
    n = min(len(cart), len(eng))
    print('%-6s %-12s %-12s' % ('mode', 'cartridge', 'engine'))
    for i in range(n):
        c, e = cart[i], eng[i]
        all += 1
        mark = ''
        if c[0] != e[0]:
            mark = '  <-- another mode'
            bad += 1
        elif (c[1], c[2]) != (e[1], e[2]) and i + 1 < n:
            mark = '  <-- another turn or length'
            bad += 1
        print('%-6s %5d+%-6d %5d+%-6d%s'
              % ('%02X' % c[0], c[1], c[2], e[1], e[2], mark))
    all += 1
    if len(cart) != len(eng):
        print('the chain is %d long on the cartridge and %d in the engine'
              % (len(cart), len(eng)))
        bad += 1
    if bad:
        return bad, all

    # The third picture of every one of the nine steps, and the first picture
    # of the clearing itself.  A step that is over on the picture it begins on
    # is looked at where it stands, which is the step after it.
    pay = [c for c in cart if c[0] == 0x1C]
    want = [('lay', cart[0][1])]
    for k in sorted(step):
        at = min(step[k] + 2, pay[0][1] + pay[0][2] - 1) if pay else step[k]
        want.append(('step %d' % k, at))
    want = [(nm, at) for nm, at in want if at + 1 in turn]
    d = P.scratch('clear_at')
    try:
        rom = cart_look(sorted({turn[at + 1] for _n, at in want}
                               | {turn[at + 1] - 1 for _n, at in want}),
                        d, stage, suit, bonus, score)
        _, eb, es = engine(sorted({at for _n, at in want}), d, clock, tick0,
                           fd_at - 1, stage, suit, bonus, score)
        for nm, at in want:
            _b, _p, cheld = cart_state(rom[turn[at + 1] - 1])
            cboard, cpal, _s = cart_state(rom[turn[at + 1]])
            eboard, epal, eheld = engine_state(eb[at], es[at])
            got = sum(1 for i in range(2048) if cboard[i] != eboard[i])
            hue = sum(1 for i in HUES if cpal[i] != epal[i])
            wrong = [key for key in cheld if cheld[key] != eheld.get(key)]
            all += 3
            if got:
                bad += 1
                print('%-8s %6d cells of the board differ' % (nm, got))
            if hue:
                bad += 1
                print('%-8s %6d of the thirty two differ: %s' % (nm, hue,
                      ', '.join('%d %02X/%02X' % (i, cpal[i], epal[i])
                                for i in HUES if cpal[i] != epal[i])))
            if wrong:
                bad += 1
                print('%-8s what is held differs: %s' % (nm, ', '.join(
                    '%s %s/%s' % (key, cheld[key], eheld.get(key))
                    for key in sorted(wrong))))
            if not got and not hue and not wrong:
                print('%-8s ok' % nm)
    finally:
        P.sweep(d)
    return bad, all


def main():
    only = None
    for a in sys.argv[1:]:
        if a.startswith('--only='):
            only = a[7:]
    bad, all = 0, 0
    for name, stage, suit, bonus, score in CASES:
        if only is not None and only not in name:
            continue
        was, count = one(name, stage, suit, bonus, score)
        bad += was
        all += count
    print('%d of %d comparisons of the clearing differ' % (bad, all))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
