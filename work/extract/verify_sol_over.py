#!/usr/bin/env python3
"""Э4.8 acceptance: GAME OVER ($14, $15) and BEST 5 ($0E, $0F).

Both screens are drawn and then written into: counts turned into digits, three
letters of a name, and the plate of the stage the game was left in.  None of
that is in the screen the cartridge draws, so a screen that matches says
nothing -- what is compared is the picture the mode leaves behind.

Neither mode is reached from the reset, so both sides are put on it: the
cartridge by poking $02 out of a saved state, the engine by being told to begin
its walk there.  Everything the two would otherwise disagree about is poked on
both sides as well -- what the game scored, the five counts and the five names,
which stage it was left in, and $4C, which BEST 5 waits by.

What is compared is the board and not a photograph of it.  The cartridge is put
on the mode out of a state taken in the middle of a stage, and a stage leaves
its own splitting of the picture behind -- half way down the screen the
cartridge is still showing the other page and still sliding the bottom band
thirty points sideways, because the routine that does the splitting was never
told to stop.  Nothing the mode itself does clears that, so a photograph is of
the stage's leavings and not of the mode's work.  The two kilobytes the mode
writes, and the thirty two colours it writes them under, are the mode's work,
and those are taken from both sides straight.
"""
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
RUN = POKE_AT + 400

## What the game is given to show.  The count is $05FD..$05FF, low byte last.
SCORE = 123456

## $4C -- what BEST 5 counts its waiting by.  Anything: both sides are given
## the same, and neither reaches the end of it inside the run.
Z4C = 0x40

## Where inside a mode to photograph it.
INTO = [4, 40, 120, 300]

ALLOW = {}

## Five lines out of order, so the putting in order ($ED02) is seen to happen
## and to carry each name with its count.  The middle two share a count, which
## is where an order that is not the cartridge's shows itself.
SHUFFLE = ((12000, (0x50, 0x41, 0x4C)),
           (30000, (0x42, 0x45, 0x53)),
           (7000, (0x4D, 0x49, 0x44)),
           (7000, (0x44, 0x49, 0x4D)),
           (1000, (0x4C, 0x4F, 0x57)))

## Which screens to walk, and on which stage.  The six plates $E223 names are
## all covered: stage 0 is the first, 1 the sixth, 3 the third, 4 the fourth,
## 6 the fifth and 10 the second.
CASES = []
for _mode, _name in ((0x14, 'game over'), (0x0E, 'best 5')):
    for _stage in (0, 1, 3, 4, 6, 10):
        CASES.append(('%s, stage %d' % (_name, _stage), _mode, _stage, None))
CASES.append(('best 5 out of order', 0x0E, 2, SHUFFLE))
CASES.append(('game over out of order', 0x14, 2, SHUFFLE))


def _five(five):
    """The five lines either side is given: the cartridge's own, or a set."""
    import json
    d = json.load(open(os.path.join(ROOT, 'game', 'data', 'sol', 'over.json')))
    if five is None:
        return [(int(d['scores'][i]), tuple(d['names'][i])) for i in range(5)]
    return [(int(s), tuple(n)) for s, n in five]


def _score_pokes(at, five):
    """The count and the five lines, put on the cartridge by hand.

    The five are what the reset leaves, which is what the engine begins with;
    a saved state taken in the middle of a game has its own, so they are
    written back before the screen is drawn.
    """
    lines = _five(five)
    out = []
    n = SCORE
    for addr in (0x05FD, 0x05FE, 0x05FF):
        out.append('%04X=%02X' % (addr, (n >> 16) & 0xFF))
        n = (n << 8) & 0xFFFFFF
    for i, (one, _nm) in enumerate(lines):
        out.append('%04X=%02X' % (0x075B + i, one & 0xFF))
        out.append('%04X=%02X' % (0x076B + i, (one >> 8) & 0xFF))
        out.append('%04X=%02X' % (0x077B + i, (one >> 16) & 0xFF))
    for i, (_sc, one) in enumerate(lines):
        out.append('%04X=%02X' % (0x072B + i, one[0]))
        out.append('%04X=%02X' % (0x073B + i, one[1]))
        out.append('%04X=%02X' % (0x074B + i, one[2]))
    out.append('004C=%02X' % Z4C)
    return ['-poke', '%s@%d' % (one, at)] if False else \
        [x for one in out for x in ('-poke', '%s@%d' % (one, at))]


def cmd_base(d, state, frames, mode, stage, five=None):
    inp = os.path.join(d, 'i.inp')
    open(inp, 'w').write('%d -\n' % (P.IN_LEVEL + 1))
    return [P.EMU, P.ROM, '-loadstate', state, '-input', inp,
            '-frames', str(frames),
            '-poke', '0002=%02X@%d' % (mode, POKE_AT),
            '-poke', '0055=%02X@%d' % (stage, POKE_AT)] \
        + _score_pokes(POKE_AT, five)


def cart_walk(mode, stage, five):
    d = P.scratch('over_walk')
    try:
        state = P.make_state(os.path.join(d, 'base'))
        tr = os.path.join(d, 't.txt')
        subprocess.run(cmd_base(d, state, RUN, mode, stage, five)
                       + ['-watch', '0000-000C', '-trace', tr],
                       check=True, capture_output=True)
        modes, turn, tick, zero = {}, {}, {}, {}
        clock = 0
        seen = None
        # $00 is raised inside the picture routine and $0C right after it, so
        # what stands in $00 when the count of pictures moves is that picture's.
        last0 = 0
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
        # The mode poked in is not a write the watch sees; what the chain
        # begins with is what that mode writes on the turn it runs, which is
        # what the engine's own first step prints.
        out = [(c, modes[c]) for c in sorted(turn) if c in modes]
        begin = (tick[1] - 1) & 0xFF
        # $00 counts pictures and $0C counts turns, and the two part company
        # on a turn that lays a screen: the cartridge spends several pictures
        # laying it and the engine one.  Both modes walked here lay on their
        # first turn, so what is handed over is $00 as it stands on the second,
        # which is the first turn the two count alike.
        first0 = (zero[2] - 2) & 0xFF
        return out, turn, begin, first0
    finally:
        P.sweep(d)


def cart_boards(frames, into, mode, stage, five):
    """The cartridge's two kilobytes of name map, once for every frame asked.

    `-vram FILE@N` is written before frame N, so a board as it stands after
    frame N is asked for at N + 1.
    """
    d = P.scratch('over_boards')
    try:
        state = P.make_state(os.path.join(d, 'base'))
        out = {f: os.path.join(into, 'rom_%d.vram' % f) for f in frames}
        cmd = cmd_base(d, state, max(frames) + 3, mode, stage, five)
        for f in frames:
            cmd += ['-vram', '%s@%d' % (out[f], f + 1)]
        subprocess.run(cmd, check=True, capture_output=True)
        return out
    finally:
        P.sweep(d)


def board_of(path):
    """The two kilobytes and the thirty two colours, whichever side wrote it."""
    b = open(path, 'rb').read()
    if b[:8] == b'PB3VRAM1':
        return b[12:12 + 2048], b[12 + 2048:12 + 2048 + 32]
    return b[:2048], b[2048:2048 + 32]


def engine(frames, into, clock, mode, stage, tick, five):
    n = RUN - POKE_AT
    spec = ('%d,set:mode:%d,set:stage:%d,set:clock:%d,set:score:%d,set:z4c:%d'
            ',set:tick:%d' % (n, mode, stage, clock, SCORE, Z4C, tick))
    if five is not None:
        for i, (sc, nm) in enumerate(five):
            spec += ',best:%d:%d:%d:%d:%d' % (i, sc, nm[0], nm[1], nm[2])
    out = {f: os.path.join(into, 'eng_%d.bin' % f) for f in frames}
    for f in sorted(frames):
        spec += ',board:%d:%s' % (f - 1, out[f])
    cmd = [V.GODOT, '--path', V.GAME, '--headless', '--', '--solwalk=' + spec]
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=900)
    chain = []
    for line in r.stdout.splitlines():
        m = re.match(r'^(\d+) ([0-9A-F]{2})( |$)', line)
        if m:
            chain.append((int(m.group(1)) + 1, int(m.group(2), 16)))
    if not chain:
        raise RuntimeError(r.stdout[-2000:] + r.stderr[-2000:])
    return chain, out


def one(name, mode, stage, five):
    bad, all = 0, 0
    print('-- %s' % name)
    walk, turn, clock, tick0 = cart_walk(mode, stage, five)
    cart = B.spans(walk, max(turn) + 1)
    eng_chain, _ = engine([], '', clock, mode, stage, tick0, five)
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
        for k in INTO:
            k = min(k, cart[i][2] - 1, eng[i][2] - 1)
            if k < 0 or (cart[i][0], k) in [(w[0], w[1]) for w in want]:
                continue
            at = cart[i][1] + k
            if at + 1 not in turn:
                continue
            want.append((cart[i][0], k, turn[at + 1], eng[i][1] + k))
    d = P.scratch('over_at')
    try:
        rom = cart_boards(sorted({w[2] for w in want}), d, mode, stage,
                          five)
        _, eng_b = engine(sorted({w[3] for w in want}), d, clock, mode,
                          stage, tick0, five)
        for m, k, cf, ef in want:
            cb, cp = board_of(rom[cf])
            eb, ep = board_of(eng_b[ef])
            got = sum(1 for i in range(2048) if cb[i] != eb[i])
            hue = sum(1 for i in range(32) if cp[i] != ep[i])
            all += 2
            if got:
                bad += 1
                print('%02X +%-5d %6d cells of the board differ' % (m, k, got))
            else:
                print('%02X +%-5d ok, the board is the same' % (m, k))
            if hue:
                bad += 1
                print('%02X +%-5d %6d of the thirty two colours differ'
                      % (m, k, hue))
            else:
                print('%02X +%-5d ok, the colours are the same' % (m, k))
    finally:
        P.sweep(d)
    return bad, all


def main():
    only = None
    for a in sys.argv[1:]:
        if a.startswith('--only='):
            only = a[7:]
    bad, all = 0, 0
    for name, mode, stage, five in CASES:
        if only is not None and only not in name:
            continue
        was, count = one(name, mode, stage, five)
        bad += was
        all += count
    print('%d of %d comparisons of the two screens differ' % (bad, all))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
