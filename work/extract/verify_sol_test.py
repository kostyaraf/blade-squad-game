#!/usr/bin/env python3
"""Э4.10 acceptance: TEST MODE -- the maker's own menu and the two tests.

Sixteen buttons in a row on the title ($D226) open a nine line menu ($D79F
lays it, $D7C2 walks it).  Two of the nine are tests of their own -- BGM TEST
($D863 and $D880) and the sound test ($D8C7 and $D8E4) -- six are doors into
stages that are otherwise only reached by playing to them, and the last goes
back to the opening.

Nothing here is poked: both sides are started from the switch being turned on
and given the same sixteen buttons, so the screen TEST MODE lays stands on
exactly what the title left behind.  That matters, because the menu's own
colours are only twenty of the thirty two ($C6E9 with X = $13) and the other
twelve are whatever was there before.

Three things are compared:

* the chain -- which mode follows which and how long each lasts, up to the
  stage a door opens (what happens inside a stage is another stand's);
* the board -- the two kilobytes of name map and the thirty two colours;
* what the mode is holding -- $4C..$4F, $2E, $59, $0D, $41 (the pair of
  kilobytes the number under test is drawn out of), $55, $7D, the four bytes
  of the walk of the colours, and the cursor, which is the first sprite.
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

## How long both walks are, in pictures for the cartridge and in turns for the
## engine.  A turn that lays a screen costs the cartridge half a dozen
## pictures and the engine one, so the cartridge is given the longer run and
## the comparison stops where the shorter one does.
RUN = 1400
TURNS = 700

## $D226 -- the sixteen: A four times, B four times, and then the two by
## turns.  One press every fourth turn, which is long enough for the release
## to be seen between them.
CODE = ['A'] * 4 + ['B'] * 4 + ['A', 'B'] * 4
CODE_AT = 10
CODE_EVERY = 8

## The turn the last of the sixteen lands on, and the first turn after it that
## anything else may be pressed on.
AFTER = CODE_AT + CODE_EVERY * len(CODE)

## The modes this stand answers for.  A door into a stage is followed only as
## far as the chain.
MINE = (0x24, 0x25, 0x2A, 0x2B, 0x33, 0x34, 0x26)

## The mode the comparison of the chain stops at: from $1D on what is on the
## screen is a stage.
LAST = 0x1D

## Which of the thirty two are compared.  $3F04, $3F08 and $3F0C are the only
## three the console never shows -- the background reads its own colour nought
## out of $3F00 -- and the picture unit is handed the other twenty nine, so
## whatever stood in those three before is still standing.  The shadow at
## $0100 the engine keeps has the backdrop in them, the cartridge's picture
## unit has something older, and neither is on the screen.
HUES = [i for i in range(32) if i % 4 != 0 or i >= 16]

## Where inside a mode to look at it.
INTO = [0, 2, 12, 40, 70, 92, 101, 112]

## The walks.  The menu walked round, both tests walked, and every one of the
## six doors opened.
def _sel(n, first=AFTER, every=10):
    return [(first + i * every, 'SELECT') for i in range(n)]


CASES = [
    ('the menu walked round', _sel(11)),
    ('BGM TEST', _sel(0) + [(AFTER, 'START'), (AFTER + 20, 'A'),
                            (AFTER + 30, 'A'), (AFTER + 40, 'B'),
                            (AFTER + 50, 'B'), (AFTER + 60, 'B'),
                            (AFTER + 70, 'SELECT'), (AFTER + 80, 'START')]),
    ('the sound test', _sel(1) + [(AFTER + 20, 'START'), (AFTER + 40, 'B'),
                                  (AFTER + 50, 'A'), (AFTER + 60, 'A'),
                                  (AFTER + 70, 'SELECT'),
                                  (AFTER + 80, 'START')]),
    ('the opening again', _sel(8) + [(AFTER + 100, 'START')]),
]
for _i in range(2, 8):
    CASES.append(('the door on line %d' % _i,
                  _sel(_i) + [(AFTER + 100, 'START')]))


def held(path, presses, turn):
    """The input file: every press one turn long, named by the turn it lands
    on and written out at the picture that turn began."""
    out = ['1 -']
    for t, name in presses:
        at = turn.get(t)
        if at is None:
            continue
        out.append('%d %s' % (at, name))
        out.append('%d -' % (at + 4))
    open(path, 'w').write('\n'.join(out) + '\n')


def cart_walk(presses=(), turn0=None):
    """The cartridge's walk: for every turn of the main loop, which mode it
    was in and which picture that turn began at."""
    d = P.scratch('test_walk')
    try:
        inp = os.path.join(d, 'i.inp')
        held(inp, presses, turn0 or {})
        tr = os.path.join(d, 't.txt')
        subprocess.run([P.EMU, P.ROM, '-input', inp, '-frames', str(RUN),
                        '-watch', '0002-000C', '-trace', tr],
                       check=True, capture_output=True)
        mode, turn = {}, {}
        clock = -1
        seen = None
        for line in open(tr):
            if not line.startswith('WATCH'):
                continue
            f, _pc, _bk, ad, v = line.split()[1].split(',')
            f, ad, v = int(f), int(ad, 16), int(v, 16)
            if ad == 0x0C:
                if seen is None or v != seen:
                    clock += 1
                    seen = v
                    turn[clock] = f
            elif ad == 0x02:
                mode[max(clock, 0)] = v
        out = [(c, mode[c]) for c in sorted(turn) if c in mode]
        return out, turn
    finally:
        P.sweep(d)


def cart_look(frames, into, presses, turn0):
    """A `-vram` dump at every picture asked for: the board, the thirty two
    colours and the whole of the console's memory with it."""
    d = P.scratch('test_look')
    try:
        inp = os.path.join(d, 'i.inp')
        held(inp, presses, turn0)
        out = {f: os.path.join(into, 'rom_%d.vram' % f) for f in frames}
        cmd = [P.EMU, P.ROM, '-input', inp, '-frames', str(max(frames) + 3)]
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
    return board, list(pal), {
        '4c': ram[0x4C], '4d': ram[0x4D], '4e': ram[0x4E], '4f': ram[0x4F],
        '2e': ram[0x2E], '59': ram[0x59], '0d': ram[0x0D], '41': ram[0x41],
        '25': ram[0x25], '26': ram[0x26], '27': ram[0x27], '28': ram[0x28],
        '7d': ram[0x7D], 'stage': ram[0x55],
        'cur': list(ram[0x0200:0x0204]),
    }


def engine(frames, into, presses):
    spec = str(TURNS)
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


def one(name, presses):
    bad, all = 0, 0
    print('-- %s' % name)
    # The input file names pictures, the walk names turns, and the two are
    # only the same while nothing lays a screen: a laying costs the cartridge
    # half a dozen pictures and everything after it slides.  So the map is
    # taken again out of each run and the run made again until the pictures
    # the presses land on stop moving.
    turn0 = cart_walk()[1]
    walk, turn = cart_walk(presses, turn0)
    for _ in range(5):
        if [turn0.get(t) for t, _n in presses] == \
                [turn.get(t) for t, _n in presses]:
            break
        turn0 = turn
        walk, turn = cart_walk(presses, turn0)
    cart = B.spans(walk, max(turn) + 1)
    eng_chain, _, _ = engine([], '', presses)
    eng = B.spans(eng_chain, TURNS)
    while cart and cart[0][0] != eng[0][0]:
        cart.pop(0)
    # The chain is followed only as far as the door into a stage.
    for side in (cart, eng):
        for i, one_ in enumerate(side):
            if one_[0] == LAST:
                del side[i + 1:]
                break
    # The cartridge is given more pictures than the engine is given turns, so
    # a mode that begins past the end of the engine's walk is not a mode the
    # engine failed to reach.
    cart = [c for c in cart if c[1] <= TURNS]
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
        if cart[i][0] != eng[i][0] or cart[i][0] not in MINE:
            continue
        for k in INTO:
            k = min(k, cart[i][2] - 1, eng[i][2] - 1)
            if k < 0 or (cart[i][0], k) in [(w[0], w[1]) for w in want]:
                continue
            at = cart[i][1] + k
            if at + 1 not in turn:
                continue
            # Two dumps.  A turn that lays a screen takes the cartridge half a
            # dozen pictures, so the end of turn N is the picture before turn
            # N+1 began; that is where memory is read.  The board is the one
            # the console then shows, a picture later.
            want.append((cart[i][0], k, turn[at + 1] - 1, turn[at + 1],
                         eng[i][1] + k))
    if not want:
        return bad, all
    d = P.scratch('test_at')
    try:
        rom = cart_look(sorted({w[2] for w in want} | {w[3] for w in want}),
                        d, presses, turn0)
        _, eb, es = engine(sorted({w[4] for w in want}), d, presses)
        for m, k, cf, bf, ef in want:
            _b, _p, cstate = cart_state(rom[cf])
            cboard, cpal, _s = cart_state(rom[bf])
            eboard, epal, estate = engine_state(eb[ef], es[ef])
            got = sum(1 for i in range(2048) if cboard[i] != eboard[i])
            hue = sum(1 for i in HUES if cpal[i] != epal[i])
            wrong = [key for key in cstate if cstate[key] != estate.get(key)]
            all += 3
            if got:
                bad += 1
                print('%02X +%-5d %6d cells of the board differ' % (m, k, got))
            if hue:
                bad += 1
                print('%02X +%-5d %6d of the thirty two colours differ: %s'
                      % (m, k, hue, ', '.join(
                          '%d %02X/%02X' % (i, cpal[i], epal[i])
                          for i in HUES if cpal[i] != epal[i])))
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
    for name, presses in CASES:
        if only is not None and only not in name:
            continue
        was, count = one(name, [(CODE_AT + i * CODE_EVERY, b)
                                for i, b in enumerate(CODE)] + list(presses))
        bad += was
        all += count
    print('%d of %d comparisons of TEST MODE differ' % (bad, all))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
