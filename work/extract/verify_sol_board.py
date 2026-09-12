#!/usr/bin/env python3
"""Э4.7 acceptance: STAGE SELECT, mode $1A.

The mode is only ever reached with a stage behind it, so neither side is
walked to it from the switch being turned on.  Both are put on it instead: the
cartridge by poking $02 and $55 out of a saved state, the engine by being told
to begin its walk there.  From that picture on both go by themselves.

What is asked is the same two things `verify_sol_boot.py` asks.  The chain:
which mode follows which and how long each lasts, counted in turns of the main
loop ($0C, which does not move while a screen is being written).  And the
pictures: at a few points inside each mode the screen is photographed on both
sides and compared point for point.

One picture of slack is left in the lining up, and it is the console's own:
what stands on the screen in picture N is what the main loop of picture N-1
arrived at.
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

## Where the mode is poked in, and how long to watch.  $1A alone is a thousand
## and a half turns long when the game picks for itself, so the run has to be
## longer than that.
POKE_AT = P.IN_LEVEL + 5
RUN = POKE_AT + 1800

## Which stage is put in $55.  Anything but nought: $DAF2 sends nought straight
## on to $1D without drawing a thing.
STAGE = 1

## $2D -- which stages are done with, one bit each.  The screen is two screens:
## with a stage left undone the player picks and the pointer blinks, and with
## every one done with the board picks for itself.  Both are walked.
## The pad the third walk is given: which turn of the loop a button is pressed
## on, and which.  The board takes some two hundred and forty turns to come up
## and another thirty to fill, so nothing is pressed before that.
PRESSES = ((320, 'RIGHT'), (360, 'DOWN'), (400, 'LEFT'), (440, 'UP'),
           (480, 'SELECT'), (520, 'START'))

CASES = (('picking', 0x00, ()),
         ('all done', 0x1F, ()),
         ('picked by hand', 0x00, PRESSES))

## Where inside a mode to photograph it: so many turns of the loop after it
## began.  A mode shorter than the number asked for is photographed at its last
## turn instead.  The thick of them is round the presses of the third walk.
INTO = [4, 60, 200, 250, 280, 322, 330, 362, 370, 402, 410, 442, 450,
        482, 490, 522, 530, 560, 700, 1300]

## How many points a mode may differ by.  Nought unless something of it is
## knowingly not ported.
ALLOW = {}

## The mode the walk stops photographing at: from there on what is on the
## screen is a stage and not a screen.
LAST = 0x00


def held(path, presses, turn):
    """What the cartridge is given: nothing held, and then each of the presses
    asked for at the frame the turn it is named by fell on.  A press is let go
    of four frames later, which is what the boot stand gives as well."""
    out = ['%d -' % (P.IN_LEVEL + 1)]
    for t, name in presses:
        at = turn[t]
        out.append('%d %s' % (at, name))
        out.append('%d -' % (at + 4))
    open(path, 'w').write('\n'.join(out) + '\n')


def cmd_base(d, state, frames, done, presses, turn):
    inp = os.path.join(d, 'i.inp')
    held(inp, presses, turn)
    return [P.EMU, P.ROM, '-loadstate', state, '-input', inp,
            '-frames', str(frames),
            '-poke', '0002=%02X@%d' % (0x19, POKE_AT),
            '-poke', '0055=%02X@%d' % (STAGE, POKE_AT),
            '-poke', '002D=%02X@%d' % (done, POKE_AT)]


def cart_walk(done, presses=(), turn0=None):
    """For every turn of the main loop from the poke on, which mode it was in
    and which picture of the run stood on the screen at the end of it."""
    d = P.scratch('board_walk')
    try:
        state = P.make_state(os.path.join(d, 'base'))
        tr = os.path.join(d, 't.txt')
        subprocess.run(cmd_base(d, state, RUN, done, presses, turn0)
                       + ['-watch', '0002-000C', '-trace', tr],
                       check=True, capture_output=True)
        # The turns are counted from one, which is what the engine calls the
        # step it takes first: its own count moves on the way in.
        mode, turn, tick = {}, {}, {}
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
                mode[max(clock, 0)] = v
        out = [(c, mode[c]) for c in sorted(turn) if c in mode]
        # The engine is handed the count the cartridge was on when the first
        # mode of the chain was written: its own `step` counts one on the way
        # in, so it is handed the one before.
        begin = (tick[out[0][0]] - 1) & 0xFF if out else 0
        return out, turn, begin
    finally:
        P.sweep(d)


def cart_shots(frames, into, done, presses, turn0):
    d = P.scratch('board_shots')
    try:
        state = P.make_state(os.path.join(d, 'base'))
        base = os.path.join(into, 'rom')
        cmd = cmd_base(d, state, max(frames) + 3, done, presses,
                       turn0) + ['-png', base]
        for f in frames:
            cmd += ['-shot', str(f)]
        subprocess.run(cmd, check=True, capture_output=True)
        return {f: '%s_%d.png' % (base, f) for f in frames}
    finally:
        P.sweep(d)


def engine(frames, into, clock, done, presses=()):
    """The engine's own chain, and a picture at each turn asked for.  Its
    `clock` is $0C and the turn numbered N is the step numbered N-1."""
    n = RUN - POKE_AT
    spec = ('%d,set:mode:%d,set:stage:%d,set:clock:%d,set:done:%d'
            % (n, 0x19, STAGE, clock, done))
    for t, name in presses:
        spec += ',%s:%d' % (name, t - 1)
    shots = {f: os.path.join(into, 'eng_%d.png' % f) for f in frames}
    for f in sorted(frames):
        spec += ',shot:%d:%s' % (f - 1, shots[f])
    cmd = [V.GODOT, '--path', V.GAME]
    if frames:
        cmd += ['--rendering-driver', 'opengl3', '--resolution', '256x240']
    else:
        cmd += ['--headless']
    cmd += ['--', '--solwalk=' + spec]
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=1800)
    chain = []
    for line in r.stdout.splitlines():
        m = re.match(r'^(\d+) ([0-9A-F]{2})( |$)', line)
        if m:
            chain.append((int(m.group(1)) + 1, int(m.group(2), 16)))
    if not chain:
        raise RuntimeError(r.stdout[-2000:] + r.stderr[-2000:])
    return chain, shots


def one(name, done, presses):
    """One walk of the screen on both sides, compared.  Returns how many of
    the comparisons came out wrong and how many were made."""
    bad = 0
    all = 0
    print('-- %s, $2D = %02X' % (name, done))
    # The presses are named by the turn of the loop they fall on, and the
    # cartridge is given frames: which frame a turn fell on is what a walk with
    # nothing pressed says, and up to the first press the two are the same.
    turn0 = None
    if presses:
        turn0 = cart_walk(done)[1]
    walk, turn, clock = cart_walk(done, presses, turn0)
    cart = B.spans(walk, max(turn) + 1)
    eng_chain, _ = engine([], '', clock, done, presses)
    eng = B.spans(eng_chain, RUN - POKE_AT)
    while cart and cart[0][0] != eng[0][0]:
        cart.pop(0)
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
        if cart[i][0] != eng[i][0] or cart[i][0] == LAST:
            continue
        for k in INTO:
            k = min(k, cart[i][2] - 1, eng[i][2] - 1)
            if k < 0 or (cart[i][0], k) in [(w[0], w[1]) for w in want]:
                continue
            at = cart[i][1] + k
            if at + 1 not in turn:
                continue
            want.append((cart[i][0], k, turn[at + 1], eng[i][1] + k))
    d = P.scratch('board_pics')
    try:
        rom = cart_shots(sorted({w[2] for w in want}), d, done,
                         presses, turn0)
        _, pic = engine(sorted({w[3] for w in want}), d, clock, done,
                        presses)
        for mode, k, cf, ef in want:
            got = B.differ(rom[cf], pic[ef])
            all += 1
            cap = ALLOW.get(mode, 0)
            if got > cap:
                bad += 1
                print('%02X +%-5d %6d points differ, more than the %d allowed'
                      % (mode, k, got, cap))
            else:
                print('%02X +%-5d ok, %d points differ of the %d allowed'
                      % (mode, k, got, cap))
    finally:
        P.sweep(d)
    return bad, all


def main():
    bad, all = 0, 0
    for name, done, presses in CASES:
        was, count = one(name, done, presses)
        bad += was
        all += count
    print('%d of %d comparisons of the board differ' % (bad, all))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
