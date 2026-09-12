#!/usr/bin/env python3
"""Э4.13 acceptance: the end of the game -- what it paid ($4C) and the sunrise
behind it ($4D).

The last stage hands the game to $9FF8 in bank eight, which puts $4C on $02,
and from there the modes run one into the next.  $E33A works out what the whole
game paid -- a thousand for every try left, a thousand for as many as the
satellite stands past a multiple of eight, ten thousand for finishing at all
and a hundred thousand more where GAME OVER and TEST MODE were never seen --
adds it to the count, wipes both boards to sky and lays screen $39 over them.
$E421 then holds that screen for a thousand pictures while $89A4 in bank twelve
walks the sun up behind it: eight rows of colours into $0101..$0107 and the
view from $48 to $9E a point every other picture.

Neither mode is reached from the reset without a whole game behind it, so both
sides are put on it: the cartridge by poking $02 out of a state taken in the
middle of the first stage, the engine by being told to begin its walk there.
Everything the two would otherwise disagree about is poked on both sides --
what the game has scored, how many tries are left, the satellite, whether
anything has been seen, and the pace of the walk of the colours.

What is compared:

* the chain -- $4C, then $4D, then $4E, and how long each lasts;
* the board -- the two kilobytes of name map and the thirty two colours, taken
  at the third picture of every one of the twenty one steps;
* what the mode is holding -- $4C..$4F, $25..$28, $72..$77, $7D and what the
  game has scored ($05FD..$05FF), and the thirty two as the game holds them
  ($0100..$011F).
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
## Long enough for the whole sunrise: a page held, eight rows of colour, and
## eight more with the view walking under them.
RUN = POKE_AT + 3600
TURNS = 3600

## The mode the names are typed in, which is where this stand stops.
LAST = 0x22

## $28 and $25 -- the pace of the walk of the colours and how much of the next
## step of it is still to come.  A stage leaves its own and $4C sets both to
## eight through $C6E9, but the picture it is poked on is walked before that,
## so both sides are given the same to begin with.
PACE = 8

## What the bonus is worked out of: how many tries are left ($071C), what the
## satellite stands at ($060C) and whether anything has been seen ($59).
## Between them the cases cover every part of $E39D -- no satellite at all, one
## that pays nothing because it stands on a multiple of eight, a clean run and
## one that is not, and a count already high enough to carry.
CASES = [
    ('three tries, a satellite, and nothing seen', 3, 0x04, 0, 123456),
    ('no tries left and no satellite', 0, 0x00, 0, 0),
    ('a satellite that pays nothing', 5, 0x02, 0, 50),
    ('a run that has seen GAME OVER', 2, 0x07, 1, 999000),
    ('a count that carries', 6, 0x01, 0, 995000),
]


def pokes(lives, sat, seen, score):
    out = ['0002=4C', '0028=%02X' % PACE, '0025=%02X' % PACE,
           # $73 and $74 -- the address the beam's own stop is to write, which
           # a stage leaves its own and neither mode sets until the sun
           # begins to walk.
           '0073=00', '0074=00',
           '071C=%02X' % lives, '060C=%02X' % sat, '0059=%02X' % seen]
    n = score
    for addr in (0x05FD, 0x05FE, 0x05FF):
        out.append('%04X=%02X' % (addr, (n >> 16) & 0xFF))
        n = (n << 8) & 0xFFFFFF
    return [x for one in out for x in ('-poke', '%s@%d' % (one, POKE_AT))]


def cmd_base(d, state, frames, lives, sat, seen, score):
    inp = os.path.join(d, 'i.inp')
    open(inp, 'w').write('%d -\n' % (P.IN_LEVEL + 1))
    return [P.EMU, P.ROM, '-loadstate', state, '-input', inp,
            '-frames', str(frames)] + pokes(lives, sat, seen, score)


def cart_walk(lives, sat, seen, score):
    """The chain, the map of turns to pictures, the two counts the engine is
    started on, and the picture each of the twenty one steps opens on."""
    d = P.scratch('end_walk')
    try:
        st = P.make_state(os.path.join(d, 'base'))
        tr = os.path.join(d, 't.txt')
        subprocess.run(cmd_base(d, st, RUN, lives, sat, seen, score)
                       + ['-watch', '0000-00FF', '-trace', tr],
                       check=True, capture_output=True)
        modes, turn, tick, zero, step = {}, {}, {}, {}, {}
        clock = 0
        seen_c = None
        last0 = 0
        for line in open(tr):
            if not line.startswith('WATCH'):
                continue
            f, _pc, _bk, ad, v = line.split()[1].split(',')
            f, ad, v = int(f), int(ad, 16), int(v, 16)
            if f < POKE_AT:
                if ad == 0x0C:
                    seen_c = v
                elif ad == 0x00:
                    last0 = v
                continue
            if ad == 0x00:
                last0 = v
            elif ad == 0x0C:
                if seen_c is None or v != seen_c:
                    clock += 1
                    seen_c = v
                    turn[clock] = f
                    tick[clock] = v
                    zero[clock] = last0
            elif ad == 0x02:
                modes[max(clock, 1)] = v
            elif ad == 0x4F:
                step.setdefault(v, max(clock, 1))
        out = [(c, modes[c]) for c in sorted(turn) if c in modes]
        begin = (tick[1] - 1) & 0xFF
        first0 = (zero[2] - 2) & 0xFF
        return out, turn, begin, first0, step
    finally:
        P.sweep(d)


def cart_look(frames, into, lives, sat, seen, score):
    d = P.scratch('end_look')
    try:
        st = P.make_state(os.path.join(d, 'base'))
        out = {f: os.path.join(into, 'rom_%d.vram' % f) for f in frames}
        cmd = cmd_base(d, st, max(frames) + 3, lives, sat, seen, score)
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
        '72': ram[0x72], '73': ram[0x73], '74': ram[0x74], '75': ram[0x75],
        '76': ram[0x76], '77': ram[0x77], '7d': ram[0x7D],
        'score': (ram[0x05FD] << 16) | (ram[0x05FE] << 8) | ram[0x05FF],
        '0100': list(ram[0x0100:0x0120]),
    }


def engine(frames, into, clock, tick, lives, sat, seen, score):
    spec = ('%d,set:mode:%d,set:clock:%d,set:tick:%d,set:score:%d'
            ',set:lives:%d,set:sat:%d,set:seen:%d'
            % (TURNS, 0x4C, clock, tick, score, lives, sat, seen))
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


## $3F10, $3F14, $3F18 and $3F1C are wired to $3F00, $3F04, $3F08 and $3F0C:
## what is written to them lands elsewhere and what is read back is whatever
## stood there when the console was switched on.  The game's own thirty two at
## $0100 are compared whole, and those four are the only ones left out.
HUES = [i for i in range(32) if i < 16 or i % 4 != 0]


def one(name, lives, sat, seen, score):
    bad, all = 0, 0
    print('-- %s' % name)
    walk, turn, clock, tick0, step = cart_walk(lives, sat, seen, score)
    cart = B.spans(walk, max(turn) + 1)
    eng_chain, _, _ = engine([], '', clock, tick0, lives, sat, seen, score)
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

    sun = [c for c in cart if c[0] == 0x4D]
    want = [('lay', cart[0][1])]
    for k in sorted(step):
        at = min(step[k] + 2, sun[0][1] + sun[0][2] - 1) if sun else step[k]
        want.append(('step %d' % k, at))
    ## And three pictures of every mode of the chain: just after it opens, in
    ## the middle of it, and the last one before it hands the game on.
    for c in cart:
        for nm, at in (('opens', c[1] + 1), ('midway', c[1] + c[2] / 2),
                       ('closes', c[1] + c[2] - 1)):
            want.append(('%02X %s' % (c[0], nm), at))
    seen_at = set()
    keep = []
    for nm, at in want:
        if at + 1 in turn and at not in seen_at:
            seen_at.add(at)
            keep.append((nm, at))
    want = keep
    d = P.scratch('end_at')
    try:
        rom = cart_look(sorted({turn[at + 1] for _n, at in want}
                               | {turn[at + 1] - 1 for _n, at in want}),
                        d, lives, sat, seen, score)
        _, eb, es = engine(sorted({at for _n, at in want}), d, clock, tick0,
                           lives, sat, seen, score)
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
                print('%-12s %6d cells of the board differ' % (nm, got))
            if hue:
                bad += 1
                print('%-12s %6d of the thirty two differ: %s' % (nm, hue,
                      ', '.join('%d %02X/%02X' % (i, cpal[i], epal[i])
                                for i in HUES if cpal[i] != epal[i])))
            if wrong:
                bad += 1
                print('%-12s what is held differs: %s' % (nm, ', '.join(
                    '%s %s/%s' % (key, cheld[key], eheld.get(key))
                    for key in sorted(wrong))))
            if not got and not hue and not wrong:
                print('%-12s ok' % nm)
    finally:
        P.sweep(d)
    return bad, all


def main():
    only = None
    for a in sys.argv[1:]:
        if a.startswith('--only='):
            only = a[7:]
    bad, all = 0, 0
    for name, lives, sat, seen, score in CASES:
        if only is not None and only not in name:
            continue
        was, count = one(name, lives, sat, seen, score)
        bad += was
        all += count
    print('%d of %d comparisons of the ending differ' % (bad, all))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
