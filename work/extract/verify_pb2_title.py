#!/usr/bin/env python3
"""Э7.4 acceptance: the screen Power Blade 2 opens on, from the switch being
turned on.

$ED7B is the nought-th of the nine screens of bank fifteen and the only one of
them that lives in that bank itself.  It has four steps, kept in $19: the
screen goes up, it waits out $80 pictures, it is lived on for $0100 more, and
it goes out over $80 while the row that was taken blinks.  Two of its numbers
are asked of the driver ($39 when the caret walks, $29 when START is taken)
and three ways lead off it: START on the first row to $18 = 3, START on the
second to $18 = 2, and nobody pressing anything for long enough to $18 = 1.
A fourth is not a row but a piece of code: A and B and LEFT held on START.

The reading is in `work/re/pb2_level_flow.md`.

What is compared
----------------
Everything, one line to a picture: the step, the row the caret stands on, the
count left in the wait, the three fields the caret is written into ($0442,
$04C6, $0508), what was asked of the driver, and the screen it left for.  A
number judged in a picture where the two sides have already parted is no proof
at all, so they are judged together or not at all.

And the picture itself, point for point, at a handful of pictures of every
run.  The going out is a picture and nothing else -- $EE12 plays a queued
stream ($CCBC) with its tiles blanked every eighth picture, and there is no
counter anywhere that says whether it did -- so a run that never photographed
the screen would leave the blinking unjudged.

How the two are lined up
------------------------
The cartridge spends six pictures switching on and runs step nought on the
seventh, leaving step one behind it; the port's `Pb2Title` does step nought in
its making, and its line nought is the first picture of step one.  So the
port's line N is the cartridge's picture N + OFFSET, and the pad is handed to
both at the same line.

A photograph shows what the picture before it arrived at -- the main loop
writes the table and the NMI hands it over at the top of the next picture --
so the cartridge is photographed one picture later than the line compared.

The raising itself is not photographed.  $CB41 turns the screen off, plays a
stream into $2006/$2007 and turns it back on, and it is called twice -- the
wipe and then the title over it -- so the cartridge stands dark for three
pictures after step nought has run and only comes up on the fourth.  The port
lays both streams in the making of the class and is up at once.  That is a
knowing difference and the only one: from SETTLE on the two are the same
screen point for point, and before it the cartridge is black.  Which is
checked, not assumed -- a raising that stopped being black would be a raising
that had started drawing something else.

Two runs of the cartridge are needed for each scene and not one: the emulator
watches a single range of addresses at a time, and the flow ($18..$53) and the
caret ($0442..$0508) are not one range.
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_probe as P                                          # noqa: E402
import verify_player as V                                      # noqa: E402

# The cartridge's picture the port's line nought is: $EDAD leaves step one
# behind it on picture six, and picture seven is the first the step runs on.
OFFSET = 7

# $48 -- the pad as the cartridge orders it, and what the emulator calls each
# button.  Nothing here is doubled up: the screen reads four of the eight and
# the other four are only ever held to be ignored.
BITS = {'A': 0x80, 'B': 0x40, 'SELECT': 0x20, 'START': 0x10,
        'UP': 0x08, 'DOWN': 0x04, 'LEFT': 0x02, 'RIGHT': 0x01}
# A button named with a two in front of it is the second player's, which this
# screen needs: $EBCC writes $48,X and $4A,X for X of nought and one, so $48
# is the first pad's newly pressed and $4B the second pad's held, and the way
# out through the code reads the second.

# The addresses the flow is read at.  $18 is which screen, $19 the step inside
# it, $22 the row, and $52/$53 the two bytes of the count ($EEBF).
WHERE = 0x0018, 0x0053
SCREEN, STEP, ROW, LOW, HIGH = 0x18, 0x19, 0x22, 0x52, 0x53
# And the caret's own three, which are three fields of the nought-th place:
# $0442 is what stands there, $04C6 how far down and $0508 how far along.
CARET = 0x0442, 0x0508
KIND, DOWN, ALONG = 0x0442, 0x04C6, 0x0508
# $ECE8 -- the driver's door, which is a call in this game and not a cell.
DOOR = 'ECE8'
# How many of the port's lines the cartridge is still dark for.
SETTLE = 3


# (name, presses, how many pictures, which pictures to photograph).  A press
# is (the port's line it goes down on, the buttons, how many pictures it is
# held for).
SCENES = [
    # Nobody presses anything: $80 of waiting, $0100 of standing, and then
    # $EDB0 takes it to the screen next along.
    ('bored', [], 400, [0, 1, 2, 4, 60, 128, 200, 390]),
    # START on the first row, which is the screen a stage is picked on.  The
    # screen is not live until the first wait is out, which is picture 129.
    ('start', [(140, 'START', 2)], 300,
     [4, 100, 139, 140, 141, 145, 149, 153, 220, 267]),
    # And pressed before that, where $EDB3 does not read the pad at all: the
    # first press is nothing and the second is the one that counts.
    ('start-early', [(20, 'START', 2), (140, 'START', 2)], 300,
     [21, 60, 141, 145, 267]),
    # The caret walked once and START taken on the second row, which is the
    # screen a password is typed on.
    ('select-start', [(140, 'SELECT', 2), (180, 'START', 2)], 340,
     [139, 141, 181, 185, 189, 307]),
    # And walked twice, which is back to the first row again.
    ('select-twice', [(140, 'SELECT', 2), (160, 'SELECT', 2),
                      (180, 'START', 2)], 340, [141, 161, 181, 185]),
    # $EDE9 -- the three held on START, which goes somewhere else entirely.
    ('cheat', [(140, '2A+2B+2LEFT', 20), (150, 'START', 2)], 200,
     [141, 149, 150, 151]),
    # The walk puts the standing back to $0100, so the screen is stood on for
    # longer than it would have been.
    ('select-late', [(300, 'SELECT', 2)], 600, [299, 301, 450, 550]),
    # Buttons this screen does not read, held all the way: nothing moves and
    # nothing is asked for.
    ('deaf', [(140, 'UP+DOWN+RIGHT', 200)], 420, [141, 250, 380]),
]


def pad_words(presses, frames):
    """What each pad holds on each of the port's lines, and what the first
    one newly pressed there."""
    down = [[0] * frames, [0] * frames]
    for at, keys, hold in presses:
        word = [0, 0]
        for nm in keys.split('+'):
            who = 1 if nm.startswith('2') else 0
            word[who] |= BITS[nm[1:] if who else nm]
        for f in range(at, min(at + hold, frames)):
            for who in (0, 1):
                down[who][f] |= word[who]
    hit = []
    was = 0
    for w in down[0]:
        hit.append(w & ~was)
        was = w
    return down, hit


def cart_input(path, down):
    """The same two pads for the cartridge, written where its own pictures
    are.

    One line for every picture either held word changes on, which is what the
    emulator's script means: what is written stands until the next line.
    """
    order = sorted(BITS.items(), key=lambda kv: -kv[1])
    lines = ['1 -']
    was = [0, 0]
    for i in range(len(down[0])):
        now = [down[0][i], down[1][i]]
        if now == was:
            continue
        was = now
        names = [nm for nm, bit in order if now[0] & bit]
        names += ['2' + nm for nm, bit in order if now[1] & bit]
        lines.append('%d %s' % (i + OFFSET, ','.join(names) or '-'))
    open(path, 'w').write('\n'.join(lines) + '\n')


def cart_run(down, frames, lo, hi, door=False):
    """One run of the cartridge, and what the watched range held on each of
    its pictures: {picture: {address: value}}, only where something was
    written, plus the numbers asked of the driver in order."""
    d = P.scratch('titlewatch')
    try:
        inp = os.path.join(d, 'i.inp')
        cart_input(inp, down)
        tr = os.path.join(d, 't.txt')
        cmd = P.emu('-input', inp, '-frames', str(frames + OFFSET + 4),
                    '-watch', '%04X-%04X' % (lo, hi), '-trace', tr,
                    '-tracefrom', '999999', '-traceto', '999999')
        if door:
            cmd += ['-sample', '%s=A' % DOOR]
        subprocess.run(cmd, check=True, capture_output=True)
        wrote, asked = {}, {}
        for line in open(tr):
            if line.startswith('SAMPLE'):
                f, _pc, _bk, _w, v = line[7:].strip().split(',')
                asked.setdefault(int(f), []).append(int(v, 16))
                continue
            if not line.startswith('WATCH'):
                continue
            f, _pc, _bk, ad, v = line.split()[1].split(',')
            wrote.setdefault(int(f), {})[int(ad, 16)] = int(v, 16)
        return wrote, asked
    finally:
        P.sweep(d)


def cart_state(pads, frames):
    """The cartridge's whole answer, one row to a picture of the port's:
    (screen, step, row, count, kind, down, along, asked)."""
    flow, asked = cart_run(pads, frames, WHERE[0], WHERE[1], door=True)
    caret, _ = cart_run(pads, frames, CARET[0], CARET[1])
    now = {SCREEN: 0, STEP: 0, ROW: 0, LOW: 0, HIGH: 0,
           KIND: 0, DOWN: 0, ALONG: 0}
    rows = []
    for f in range(frames + OFFSET + 2):
        now.update(flow.get(f, {}))
        now.update({a: v for a, v in caret.get(f, {}).items() if a in now})
        rows.append((now[SCREEN], now[STEP], now[ROW],
                     now[HIGH] * 0x100 + now[LOW],
                     now[KIND], now[DOWN], now[ALONG],
                     list(asked.get(f, []))))
    return rows


def engine(pads, hit, shots, tmp):
    """`Pb2Title` given the same pads, one line to a picture, and the port's
    own picture at every line asked for."""
    import json
    cfg = {'frames': [{'hit': hit[i], 'held': pads[1][i]}
                      for i in range(len(hit))],
           'shots': {str(f): os.path.join(tmp, 'e%d.png' % f) for f in shots}}
    path = os.path.join(tmp, 't.json')
    open(path, 'w').write(json.dumps(cfg))
    cmd = [V.GODOT, '--path', V.GAME]
    if shots:
        cmd += ['--rendering-driver', 'opengl3', '--resolution', '256x240']
    else:
        cmd += ['--headless']
    cmd += ['--', '--title=' + path]
    try:
        r = subprocess.run(cmd, capture_output=True, text=True,
                           timeout=V.ENGINE_WAIT)
    except subprocess.TimeoutExpired:
        sys.stderr.write('the engine never stopped\n')
        return [], {}
    out = []
    for line in r.stdout.split('\n'):
        parts = line.strip().split('|')
        if len(parts) != 2:
            continue
        head = parts[0].split()
        if len(head) != 7 or not head[0].isdigit():
            continue
        say = parts[1].strip()
        out.append(([int(head[0]), int(head[1]), int(head[2]),
                     int(head[3], 16), int(head[4], 16), int(head[5], 16),
                     int(head[6])],
                    [] if say == '-' else [int(x, 16) for x in say.split()]))
    if not out:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return out, cfg['shots']


def cart_shots(pads, frames, want, tmp):
    """The cartridge photographed one picture after each line asked for."""
    d = P.scratch('titleshots')
    try:
        inp = os.path.join(d, 'i.inp')
        cart_input(inp, pads)
        base = os.path.join(tmp, 'rom')
        at = {f: f + OFFSET + 1 for f in want}
        cmd = P.emu('-input', inp, '-frames',
                    str(max(at.values()) + 3), '-png', base)
        for f in sorted(at.values()):
            cmd += ['-shot', str(f)]
        subprocess.run(cmd, check=True, capture_output=True)
        return {f: '%s_%d.png' % (base, at[f]) for f in want}
    finally:
        P.sweep(d)


def differ(a, b):
    from PIL import Image
    x = Image.open(a).convert('RGB')
    y = Image.open(b).convert('RGB')
    if x.size != y.size:
        return x.size[0] * x.size[1]
    px, py = x.load(), y.load()
    return sum(1 for j in range(x.size[1]) for i in range(x.size[0])
               if px[i, j] != py[i, j])


def black(a):
    """Is this picture nothing but the darkest colour it has?"""
    from PIL import Image
    x = Image.open(a).convert('RGB')
    return len(x.getcolors(8) or [(0, 0)]) == 1


def _say(ns):
    return ' '.join('%02X' % n for n in ns) or '-'


def check(name, presses, frames, shots, tmp):
    pads, hit = pad_words(presses, frames)
    rows = cart_state(pads, frames)
    mine, pics = engine(pads, hit, shots, tmp)
    if not mine:
        return None, None, None, (0, 'the engine said nothing', '-')
    # Line nought of the port is the cartridge's picture OFFSET, which is the
    # first picture step one runs on; the making of the class is the picture
    # before it, where step nought ran.
    n = asks = 0
    left = None
    for i, (head, ours) in enumerate(mine[1:]):
        f = i + OFFSET
        if f >= len(rows):
            break
        screen, step, row, count, kind, down, along, theirs = rows[f]
        was = (step, row, count, kind, down, along)
        got = (head[0], head[1], head[2], head[5], head[3], head[4])
        # The screen it left for, which the cartridge says by writing $18 and
        # the port by handing the number back.
        gone = head[6]
        if gone >= 0 and (screen != gone or step != 0):
            return None, None, None, (
                i + 1, 'screen %d step %d' % (screen, step),
                'left for %d' % gone)
        if was != got or theirs != ours:
            return None, None, None, (
                i + 1, '%s   %s' % (_say(theirs), was),
                '%s   %s' % (_say(ours), got))
        n += 1
        asks += len(theirs)
        if gone >= 0:
            left = gone
            break
    if not shots:
        return n, asks, left, None
    rom = cart_shots(pads, frames, [f for f in shots if f < n], tmp)
    for f in sorted(rom):
        got = differ(rom[f], pics[str(f)])
        if f < SETTLE:
            # The screen is still dark there, and dark is all it may be.
            if not black(rom[f]):
                return None, None, None, (
                    f, 'the raising is not black any more',
                    'and the port is up already')
            continue
        if got:
            return None, None, None, (f, '%d points of the picture differ'
                                      % got, 'see %s' % pics[str(f)])
    return n, asks, left, None


def main():
    scenes = SCENES
    pictures = True
    for a in sys.argv[1:]:
        if a.startswith('--only='):
            want = a.split('=')[1].split(',')
            scenes = [s for s in scenes if s[0] in want]
        elif a == '--no-pictures':
            pictures = False
    tmp = P.scratch('titleverify')
    bad = lines = asks = shots = 0
    try:
        for name, presses, frames, want in scenes:
            if not pictures:
                want = []
            n, k, left, diff = check(name, presses, frames, want, tmp)
            if diff is None:
                lines += n
                asks += k
                shots += len([f for f in want if f >= SETTLE])
                print('%-13s ok   %d pictures, %d asked, %s'
                      % (name, n, k, 'stood on'if left is None
                         else 'left for screen %d' % left))
            else:
                bad += 1
                print('%-13s DIFF at picture %d' % (name, diff[0]))
                print('    game   %s' % diff[1])
                print('    engine %s' % diff[2])
            sys.stdout.flush()
    finally:
        P.sweep(tmp)
    print('%d pictures judged, %d requests, %d photographs'
          % (lines, asks, shots))
    print('%d of %d scenes differ from what the cartridge does'
          % (bad, len(scenes)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
