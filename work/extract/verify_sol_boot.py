#!/usr/bin/env python3
"""Э4.6 acceptance: the chain of modes Solbrain walks from the switch being
turned on, and the pictures along it.

Two things are asked of the port.

The chain itself: which mode follows which, and how long each one lasts.  The
cartridge is asked by watching $02 -- the byte that says what the game is
doing -- and the engine by having it print every change of its own.

The pictures: at a few points inside each mode the screen is photographed on
both sides and compared point for point.  A point is one of the sixty-one
thousand the screen has.

Neither is counted in pictures of the run, because the two do not spend the
same number of pictures on the same work.  A mode that writes a screen turns
the picture off, waits for the picture unit twice, hands $EF8C its stream and
waits again while the queue at $0300 drains; nothing of the game moves over
those pictures, and the engine, which writes a screen in one go, does not
spend them.  What both do spend is a turn of the main loop, and the cartridge
counts those itself in $0C at $F9C5: $0C does not move while a screen is being
written.  So $0C is the clock both sides are read by -- the engine's own
`clock` is the same count -- and everything here is lined up on it.

One picture of slack is left in that lining up, and it is the console's own:
the main loop writes the colours, the sprite table and where the picture
stands into RAM, and the NMI hands all three to the picture unit at the top of
the next picture.  So what stands on the screen in picture N is what the main
loop of picture N-1 arrived at, and the engine, which shows what it has just
worked out, is read one earlier.
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

## How long the walk is and when START goes down: past the title's own wait,
## so the tale is watched to its end and the change is watched whole.
RUN = 2160
PRESS = 640

## The picture of the run START goes down on.  The cartridge spends nine
## pictures of switching on before the first turn of the main loop, so the turn
## the engine presses on is this picture of the cartridge's run; that the two
## land on the same turn is what the walk of the modes below would show up if
## they did not.  It is held for four pictures, which is what `--solwalk` holds
## it for.
PRESS_FRAME = 650

## What the cartridge is given.  `sol_probe.BOOT` presses START three more
## times on its way into a stage, and those presses are read by the tale, which
## types faster while a button is held; the engine is given one press and one
## only, so the cartridge must be given the same and nothing else.
def boot_input(path):
    open(path, 'w').write('1 -\n%d START\n%d -\n'
                          % (PRESS_FRAME, PRESS_FRAME + 4))

## Where inside a mode to photograph it: so many turns of the loop after it
## began.  A mode shorter than the number asked for is photographed at its
## last turn instead.
INTO = [4, 40, 90, 250]

## How many points a mode may differ by, and why.  Nought unless something of
## the mode is knowingly not ported.
ALLOW = {
    # The tale types its words out one letter at a time out of bank four, and
    # that typing is not ported: the mode is held for as long as the cartridge
    # holds it and the words are not written.
    0x5D: 9000,
}

## A mode the walk stops photographing at, because what is on the screen from
## there on is a stage and not a screen.
LAST = 0x00


def cart_walk():
    """The cartridge's walk: for every turn of the main loop, which mode it
    was in, and which picture of the run stood on the screen at the end of it.

    $0C at $F9C5 is the turn; $02 is the mode.  Both are watched at once.
    """
    d = P.scratch('boot_walk')
    try:
        inp = os.path.join(d, 'i.inp')
        boot_input(inp)
        tr = os.path.join(d, 't.txt')
        subprocess.run([P.EMU, P.ROM, '-input', inp, '-frames', str(RUN),
                        '-watch', '0002-000C', '-trace', tr],
                       check=True, capture_output=True)
        mode = {}
        turn = {}
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
        out = []
        for c in sorted(turn):
            if c in mode:
                out.append((c, mode[c]))
        return out, turn
    finally:
        P.sweep(d)


def cart_shots(frames, into):
    d = P.scratch('boot_shots')
    try:
        inp = os.path.join(d, 'i.inp')
        boot_input(inp)
        base = os.path.join(into, 'rom')
        cmd = [P.EMU, P.ROM, '-input', inp, '-frames', str(max(frames) + 3),
               '-png', base]
        for f in frames:
            cmd += ['-shot', str(f)]
        subprocess.run(cmd, check=True, capture_output=True)
        return {f: '%s_%d.png' % (base, f) for f in frames}
    finally:
        P.sweep(d)


def engine(frames, into):
    """The engine's own chain, and a picture at each turn asked for.

    The engine's `clock` is $0C, and it counts one for every turn: the turn
    numbered N is the step numbered N-1.
    """
    spec = str(RUN) + ',START:%d' % PRESS
    shots = {f: os.path.join(into, 'eng_%d.png' % f) for f in frames}
    for f in sorted(frames):
        spec += ',shot:%d:%s' % (f - 1, shots[f])
    cmd = [V.GODOT, '--path', V.GAME]
    if frames:
        cmd += ['--rendering-driver', 'opengl3', '--resolution', '256x240']
    else:
        cmd += ['--headless']
    cmd += ['--', '--solwalk=' + spec]
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=900)
    chain = []
    for line in r.stdout.splitlines():
        m = re.match(r'^(\d+) ([0-9A-F]{2})( |$)', line)
        if m:
            chain.append((int(m.group(1)) + 1, int(m.group(2), 16)))
    if not chain:
        raise RuntimeError(r.stdout[-2000:] + r.stderr[-2000:])
    return chain, shots


def differ(a, b):
    from PIL import Image
    x = Image.open(a).convert('RGB')
    y = Image.open(b).convert('RGB')
    if x.size != y.size:
        return x.size[0] * x.size[1]
    px, py = x.load(), y.load()
    return sum(1 for j in range(x.size[1]) for i in range(x.size[0])
               if px[i, j] != py[i, j])


def spans(chain, last):
    """Each mode of a chain as (mode, first turn, how many turns)."""
    out = []
    for i, (at, mode) in enumerate(chain):
        end = chain[i + 1][0] if i + 1 < len(chain) else last
        out.append((mode, at, end - at))
    return out


def main():
    bad = 0
    walk, turn = cart_walk()
    cart = spans(walk, max(turn) + 1)
    eng_chain, _ = engine([], '')
    eng = spans(eng_chain, RUN)
    # The engine is started at $01, which the cartridge reaches over the
    # pictures it spends switching on; the walk is compared from there.
    while cart and cart[0][0] != eng[0][0]:
        cart.pop(0)
    n = min(len(cart), len(eng))
    print('%-6s %-10s %-10s' % ('mode', 'cartridge', 'engine'))
    for i in range(n):
        c, e = cart[i], eng[i]
        mark = ''
        if c[0] != e[0]:
            mark = '  <-- another mode'
            bad += 1
        elif (c[1], c[2]) != (e[1], e[2]) and i + 1 < n:
            mark = '  <-- another turn or length'
            bad += 1
        print('%-6s %5d+%-4d %5d+%-4d%s'
              % ('%02X' % c[0], c[1], c[2], e[1], e[2], mark))
    if len(cart) != len(eng):
        print('the chain is %d long on the cartridge and %d in the engine'
              % (len(cart), len(eng)))
        bad += 1

    # The pictures, by mode and by how far into it.
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
            # The picture that stood while the loop's turn N+1 ran is what the
            # turn N arrived at.
            want.append((cart[i][0], k, turn[at + 1], eng[i][1] + k))
    d = P.scratch('boot_pics')
    try:
        rom = cart_shots(sorted({w[2] for w in want}), d)
        _, pic = engine(sorted({w[3] for w in want}), d)
        for mode, k, cf, ef in want:
            got = differ(rom[cf], pic[ef])
            cap = ALLOW.get(mode, 0)
            if got > cap:
                bad += 1
                print('%02X +%-4d %6d points differ, more than the %d allowed'
                      % (mode, k, got, cap))
            else:
                print('%02X +%-4d ok, %d points differ of the %d allowed'
                      % (mode, k, got, cap))
    finally:
        P.sweep(d)
    print('%d of the walk is wrong' % bad)
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
