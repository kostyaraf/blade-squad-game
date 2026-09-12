#!/usr/bin/env python3
"""Э4.9 acceptance: NAME ENTRY -- $D4AD and the four modes it opens.

A game that beats the lowest of the five gets its count put in and three
letters typed for it.  The asking is $D4AD, reached from seven modes; the two
that matter carry their own three along -- $43 goes on to $44, $45, $46 and
then the opening, $55 to $56, $57, $58 and then the lamp and the game begun
again.

Neither is reached from the reset, so both sides are put on it: the cartridge
by poking $02 out of a saved state, the engine by being told to begin its walk
there.  What the game scored, the five counts and the five names are poked on
both sides as well.

Three things are compared, turn for turn or at chosen turns:

* the chain -- which mode follows which and how long each lasts;
* the board -- the two kilobytes of name map and the thirty two colours.  Not
  a photograph: the cartridge is put on the mode out of a state taken in the
  middle of a stage, and the stage's own cutting of the beam is left behind
  (see `verify_sol_over.py`);
* what the mode is holding -- $4C..$4F, $75, $7D, the eight bands ($0740,
  $0750, $0760), the two banks the letters are drawn out of, the cursor, and
  the five lines themselves.
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
RUN = POKE_AT + 600

## Which stage the game was left in -- it picks the plate laid on the board.
STAGE = 4

## The letters typed, and on which turn of the loop.  The five lines take
## eighty turns to slide in, so nothing is pressed before that.
PRESSES = ((100, 'DOWN'), (110, 'DOWN'), (120, 'A'),
           (130, 'UP'), (140, 'A'),
           (150, 'B'), (160, 'DOWN'), (170, 'A'), (180, 'A'))

## The modes this stand answers for.  A walk that comes out of them lands in
## the opening, which is another stand's ($D176 and what follows); its chain is
## still compared, but what it holds and what it draws are not.
MINE = (0x43, 0x44, 0x45, 0x46, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A)

## What a mode that stands on no screen of its own is answerable for.
BARE = ('25', '26', '27', '28', '4c', 'lives', 'score', 'names', 'scores')

## Where inside a mode to look at it.
INTO = [0, 4, 40, 79, 101, 111, 121, 131, 141, 151, 161, 171, 200]

## The counts and names the five lines are given.  The reset's own, so that a
## count named below lands where it is meant to.
FIVE = None

## The walks.  A count that beats the top, one that only beats the lowest, and
## one that beats nothing at all -- from both of the two modes that ask.
CASES = (
    ('the top line, from $43', 0x43, 999999, PRESSES),
    ('the top line, from $55', 0x55, 999999, PRESSES),
    ('the lowest line, from $43', 0x43, 5001, PRESSES),
    ('a line in the middle, from $43', 0x43, 12000, PRESSES),
    ('nothing beaten, from $43', 0x43, 100, ()),
    # The asking that beats nothing is put on from GAME OVER itself and not
    # from $55: a mode that only looks at the count writes neither board nor
    # bands, so poked onto $55 out of a stage the cartridge would be left
    # standing in the stage's own colours and bands and the engine in none.
    ('nothing beaten, from $55', 0x55, 100, ()),
)


def _lines():
    d = json.load(open(os.path.join(ROOT, 'game', 'data', 'sol', 'over.json')))
    return [(int(d['scores'][i]), tuple(d['names'][i])) for i in range(5)]


def _pokes(at, score):
    """The count and the five lines, put on the cartridge by hand."""
    out = []
    n = score
    for addr in (0x05FD, 0x05FE, 0x05FF):
        out.append('%04X=%02X' % (addr, (n >> 16) & 0xFF))
        n = (n << 8) & 0xFFFFFF
    # $05BA..$05C1 -- the eight levels the colours stand at.  A mode is
    # always come to off a screen that stands at its own, so both sides are
    # put at nought; out of a state taken in the middle of a stage the
    # cartridge would otherwise carry the stage's own.
    for addr in range(0x05BA, 0x05C2):
        out.append('%04X=00' % addr)
    # $25 and $28 -- and the pace the walk steps at, which a stage leaves at
    # six and every screen puts back to eight.
    out.append('0025=08')
    out.append('0028=08')
    for i, (one, nm) in enumerate(_lines()):
        out.append('%04X=%02X' % (0x075B + i, one & 0xFF))
        out.append('%04X=%02X' % (0x076B + i, (one >> 8) & 0xFF))
        out.append('%04X=%02X' % (0x077B + i, (one >> 16) & 0xFF))
        out.append('%04X=%02X' % (0x072B + i, nm[0]))
        out.append('%04X=%02X' % (0x073B + i, nm[1]))
        out.append('%04X=%02X' % (0x074B + i, nm[2]))
    return [x for one in out for x in ('-poke', '%s@%d' % (one, at))]


def held(path, presses, turn):
    out = ['%d -' % (P.IN_LEVEL + 1)]
    for t, name in presses:
        at = turn[t]
        out.append('%d %s' % (at, name))
        out.append('%d -' % (at + 4))
    open(path, 'w').write('\n'.join(out) + '\n')


def cmd_base(d, state, frames, mode, score, presses, turn):
    inp = os.path.join(d, 'i.inp')
    held(inp, presses, turn)
    return [P.EMU, P.ROM, '-loadstate', state, '-input', inp,
            '-frames', str(frames),
            '-poke', '0002=%02X@%d' % (mode, POKE_AT),
            '-poke', '0055=%02X@%d' % (STAGE, POKE_AT)] + _pokes(POKE_AT, score)


def cart_walk(mode, score, presses=(), turn0=None):
    d = P.scratch('name_walk')
    try:
        state = P.make_state(os.path.join(d, 'base'))
        tr = os.path.join(d, 't.txt')
        subprocess.run(cmd_base(d, state, RUN, mode, score, presses, turn0)
                       + ['-watch', '0002-000C', '-trace', tr],
                       check=True, capture_output=True)
        modes, turn, tick = {}, {}, {}
        clock = 0
        seen = None
        for line in open(tr):
            if not line.startswith('WATCH'):
                continue
            f, _pc, _bk, ad, v = line.split()[1].split(',')
            f, ad, v = int(f), int(ad, 16), int(v, 16)
            if f < POKE_AT:
                if ad == 0x0C:
                    seen = v
                continue
            if ad == 0x0C:
                if seen is None or v != seen:
                    clock += 1
                    seen = v
                    turn[clock] = f
                    tick[clock] = v
            elif ad == 0x02:
                modes[max(clock, 1)] = v
        out = [(c, modes[c]) for c in sorted(turn) if c in modes]
        return out, turn, (tick[1] - 1) & 0xFF
    finally:
        P.sweep(d)


def cart_look(frames, into, mode, score, presses, turn0):
    """A `-vram` dump at every frame asked for: the board, the colours and the
    whole of the console's memory with it."""
    d = P.scratch('name_look')
    try:
        state = P.make_state(os.path.join(d, 'base'))
        out = {f: os.path.join(into, 'rom_%d.vram' % f) for f in frames}
        cmd = cmd_base(d, state, max(frames) + 3, mode, score, presses, turn0)
        for f in frames:
            cmd += ['-vram', '%s@%d' % (out[f], f + 1)]
        subprocess.run(cmd, check=True, capture_output=True)
        return out
    finally:
        P.sweep(d)


def cart_state(path):
    """What the cartridge is holding, read out of a dump, in the shape the
    engine writes its own."""
    b = open(path, 'rb').read()
    assert b[:8] == b'PB3VRAM1', path
    board, pal, ram = b[12:12 + 2048], b[2060:2092], b[6222:6222 + 2048]
    names = [[ram[0x072B + k * 0x10 + i] for k in range(3)] for i in range(5)]
    scores = [ram[0x075B + i] | (ram[0x076B + i] << 8) | (ram[0x077B + i] << 16)
              for i in range(5)]
    state = {
        '4c': ram[0x4C], '4d': ram[0x4D], '4e': ram[0x4E], '4f': ram[0x4F],
        '25': ram[0x25], '26': ram[0x26], '27': ram[0x27], '28': ram[0x28],
        '75': ram[0x75], '7d': ram[0x7D],
        '010a': ram[0x010A], '010b': ram[0x010B],
        '0740': list(ram[0x0740:0x0748]),
        '0750': list(ram[0x0750:0x0758]),
        '0760': list(ram[0x0760:0x0768]),
        'mark': list(ram[0x0204:0x0208]),
        'names': names, 'scores': scores,
        'lives': ram[0x071C],
        'score': ram[0x05FF] | (ram[0x05FE] << 8) | (ram[0x05FD] << 16),
    }
    return board, list(pal), state


def engine(frames, into, clock, mode, score, presses=()):
    n = RUN - POKE_AT
    spec = ('%d,set:mode:%d,set:stage:%d,set:clock:%d,set:score:%d'
            % (n, mode, STAGE, clock, score))
    for t, name in presses:
        spec += ',%s:%d' % (name, t - 1)
    board = {f: os.path.join(into, 'eng_%d.bin' % f) for f in frames}
    state = {f: os.path.join(into, 'eng_%d.json' % f) for f in frames}
    for f in sorted(frames):
        spec += ',board:%d:%s' % (f - 1, board[f])
        spec += ',state:%d:%s' % (f - 1, state[f])
    cmd = [V.GODOT, '--path', V.GAME, '--headless', '--', '--solwalk=' + spec]
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=1800)
    chain = []
    for line in r.stdout.splitlines():
        m = re.match(r'^(\d+) ([0-9A-F]{2})( |$)', line)
        if m:
            chain.append((int(m.group(1)) + 1, int(m.group(2), 16)))
    if not chain:
        raise RuntimeError(r.stdout[-2000:] + r.stderr[-2000:])
    return chain, board, state


def engine_state(board_path, state_path):
    b = open(board_path, 'rb').read()
    return b[:2048], list(b[2048:2080]), json.load(open(state_path))


def one(name, mode, score, presses):
    bad, all = 0, 0
    print('-- %s' % name)
    turn0 = None
    if presses:
        turn0 = cart_walk(mode, score)[1]
    walk, turn, clock = cart_walk(mode, score, presses, turn0)
    cart = B.spans(walk, max(turn) + 1)
    eng_chain, _, _ = engine([], '', clock, mode, score, presses)
    eng = B.spans(eng_chain, RUN - POKE_AT)
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

    want = []
    for i in range(n):
        if cart[i][0] != eng[i][0]:
            continue
        if cart[i][0] not in MINE:
            continue
        for k in INTO:
            k = min(k, cart[i][2] - 1, eng[i][2] - 1)
            if k < 0 or (cart[i][0], k) in [(w[0], w[1]) for w in want]:
                continue
            at = cart[i][1] + k
            if at + 1 not in turn:
                continue
            # Two dumps.  A turn that lays a screen takes the cartridge half a
            # dozen pictures, so the end of turn N is not the picture after it
            # began -- it is the picture before turn N+1 began.  That is where
            # memory is read.  The board is the one the console then shows,
            # a picture later (the same rule `verify_sol_over.py` was taken
            # on).
            want.append((cart[i][0], k, turn[at + 1] - 1, turn[at + 1],
                         eng[i][1] + k))
    if not want:
        return bad, all
    d = P.scratch('name_at')
    try:
        rom = cart_look(sorted({w[2] for w in want} | {w[3] for w in want}),
                        d, mode, score, presses, turn0)
        _, eb, es = engine(sorted({w[4] for w in want}), d, clock, mode,
                           score, presses)
        for m, k, cf, bf, ef in want:
            _b, _p, cstate = cart_state(rom[cf])
            cboard, cpal, _s = cart_state(rom[bf])
            eboard, epal, estate = engine_state(eb[ef], es[ef])
            # A mode standing on no screen leaves the console showing
            # whatever was there before, which on the cartridge is the stage
            # the state was taken in.  There is nothing of the mode's in it,
            # so neither board nor colours are compared then.
            on = estate.get('screen', '') != ''
            got = sum(1 for i in range(2048)
                      if cboard[i] != eboard[i]) if on else 0
            hue = sum(1 for i in range(32)
                      if cpal[i] != epal[i]) if on else 0
            # A mode that lays no screen writes neither bands nor mark nor
            # the two banks the letters come out of: what the cartridge holds
            # there is the stage the state was taken in, and the engine's is
            # its own.  Only what such a mode does touch is compared.
            keys = cstate if on else BARE
            wrong = [key for key in keys
                     if cstate[key] != estate.get(key)]
            all += 3 if on else 1
            if got:
                bad += 1
                print('%02X +%-5d %6d cells of the board differ' % (m, k, got))
            if hue:
                bad += 1
                print('%02X +%-5d %6d of the thirty two colours differ'
                      % (m, k, hue))
            if wrong:
                bad += 1
                print('%02X +%-5d what is held differs: %s' % (m, k, ', '.join(
                    '%s %s/%s' % (key, cstate[key], estate.get(key))
                    for key in sorted(wrong))))
            if not got and not hue and not wrong:
                print('%02X +%-5d ok' % (m, k))
    finally:
        P.sweep(d)
    return bad, all


def main():
    only = None
    for a in sys.argv[1:]:
        if a.startswith('--only='):
            only = a[7:]
    bad, all = 0, 0
    for name, mode, score, presses in CASES:
        if only is not None and only not in name:
            continue
        was, count = one(name, mode, score, presses)
        bad += was
        all += count
    print('%d of %d comparisons of the typing differ' % (bad, all))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
