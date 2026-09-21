#!/usr/bin/env python3
"""Э7.6 acceptance: the screen a password is typed on, reached the way a
player reaches it.

$9672 is the second of the nine screens of bank fifteen ($ED69), and nothing
puts it up but the title screen: START on its second row writes $18 = 2.  So
this stand does not poke the cartridge into the screen -- it plays the title
the way Э7.4 plays it, waits out the first wait, walks the caret down a row
and presses START, and only then is the password screen up and the run begins.

Twelve places with an octal digit in each and a caret between them.  Six
buttons walk and turn it; START judges what stands there.  A password that is
refused says so and the screen comes up again empty; one that is taken names
which stages are behind him and which suits he has found, and the game starts.

The reading is in `work/re/pb2_password.md`.

What is compared
----------------
Everything the screen keeps, one line to a picture: the step ($19), the place
the caret stands at ($51), the count left in the wait ($50), the twelve digits
as they stand on the screen ($0690..$069B), the twelve the verdict lays out
($0680..$068B), the six bytes it finds ($06A0..$06A5), what the password said
about the stages ($5B) and the suits ($56), the caret's own three fields
($0442, $04C6, $0508), what was asked of the driver ($ECE8), and on the last
picture the screen it left for ($18) and the step of that screen ($19).

The laid-out field and the six found bytes are not scenery: they are the whole
of the verdict, and a port that took the right passwords for the wrong reason
would part from the cartridge there and nowhere else.

And the picture itself, point for point, at a handful of pictures of every
run.  The digits are background tiles, so a field that was typed into the
wrong places would look wrong and count right.

How the two are lined up
------------------------
$ED62 steps $1C and then calls the screen, so the picture step nought runs on
is the picture $19 first holds one, and the picture after it is the first step
one runs on.  That picture is found by watching, not counted out by hand: the
title takes as long as it takes.  The port's `Pb2Pass` does step nought in its
making, so the port's first stepped line is that picture.

$1C is handed over from the recording, because the going dark is stepped by it
($80E1 reads $1C AND $0F) and nothing in this port keeps a count of pictures
across screens.  That is the one number the harness gives the port; everything
else it works out for itself.

A photograph shows what the picture before it arrived at, so the cartridge is
photographed one picture later than the line compared.  And a picture where a
digit has just been turned is not photographed at all: the cartridge puts the
four tiles in the queue at $0300 for the next blank to push out, while the
port lays them on the page at once, so the two are one picture apart there and
the same everywhere else.

The raising itself needs no excusing, because it falls before line nought:
$9693 calls $CB41 twice, each call turns the screen off, plays a stream and
turns it back on, and $19 holds one only once both are done.  The picture
after that is line nought, and from it the two are the same screen point for
point.

The one picture nobody compares is the second of a re-raising.  $9835 puts $19
back to nought and the cartridge then spends two pictures putting the screen
up again while the port spends one, so the port's raising line is judged
against the picture the cartridge finished on and the picture between is left
alone.  That is the whole of the difference, and it costs the run one picture
of the cartridge's and nothing else.

Three runs of the cartridge are needed for each scene, because the emulator
watches one range at a time and the flow ($18..$5B), the caret
($0442..$0508) and the field ($0680..$06A5) are three.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_probe as P                                          # noqa: E402
import pb2_password as X                                       # noqa: E402
import verify_player as V                                      # noqa: E402
from common import ROM_PB2                                     # noqa: E402
from m6502 import Rom                                          # noqa: E402

# $48 -- the pad as the cartridge orders it, and what the emulator calls each
# button.  This screen reads six of the eight and START before any of them.
BITS = {'A': 0x80, 'B': 0x40, 'SELECT': 0x20, 'START': 0x10,
        'UP': 0x08, 'DOWN': 0x04, 'LEFT': 0x02, 'RIGHT': 0x01}

# The title screen played to its second row, in the cartridge's own pictures:
# the first wait is $80 long and the screen is deaf until it is out ($EDB3),
# so the caret is walked at 147 and START taken at 187.  Э7.4's stand walks
# the same two presses.
LEAD = [(147, 'SELECT', 2), (187, 'START', 2)]
# How long to let the title have before giving up on it ever handing over.
LEAD_WAIT = 600

# What the screen is watched at.  $19 is the step, $1C the console's count,
# $50 the wait, $51 the place the caret stands at, $53 the stage and $9C the
# area a password that was taken opens, $56 the suits and $5B the stages
# behind him -- and $18 says which screen it is, which is how the handing
# over is found.
FLOW = 0x0018, 0x009C
SCREEN, STEP, CLOCK, WAIT, SPOT = 0x18, 0x19, 0x1C, 0x50, 0x51
STAGE, SUITS, CLEARED, AREA = 0x53, 0x56, 0x5B, 0x9C
# The caret's three, which are three fields of the nought-th place, and the
# shadow palette above them, which the going dark steps ($80D9).  One range,
# because the emulator watches one at a time.
CARET = 0x03E0, 0x0508
KIND, DOWN, ALONG = 0x0442, 0x04C6, 0x0508
PAINT, PAINTS = 0x03E0, 32
# $0680..$069B -- the field laid out and the field as it stands, and
# $06A0..$06A5 -- the code, the four score bytes and the sum.
FIELD = 0x0680, 0x06A5
LAID, TYPED, FOUND = 0x0680, 0x0690, 0x06A0
PLACES, FOUNDS = 12, 6
# $ECE8 -- the driver's door, which is a call in this game and not a cell.
DOOR = 'ECE8'
# $19 -- the two steps this stand names: nought is the raising and one is the
# screen while it is typed on.
RAISE, TYPING = 0, 1
# The screen a password that was taken opens, and the step of it.
GOES_TO, GOES_TO_ALL, NEXT_STEP = 3, 4, 0x14


def tables():
    """The offsets and the shuffles, read out of the cartridge -- the same
    addresses `pb2_password.py` exports them from, so that a password built
    here is built out of the game and not out of a reader's notes."""
    rom = Rom(ROM_PB2)
    b = rom.bank(0) + rom.bank(1)

    def at(a):
        return b[a - 0x8000]

    def word(a):
        return at(a) | (at(a + 1) << 8)

    perms = [[at(word(X.PERM_TBL + i * 2) + k) for k in range(X.PLACES)]
             for i in range(X.PERM_N)]
    return ([at(X.OFFSET + i) for i in range(X.PLACES)], perms,
            [at(X.PERM_ODD + i) for i in range(X.PLACES)])


OFFSETS, PERMS, PERM_ODD = tables()
ALL_DONE = 0x1F


def password(code, suits):
    """The twelve digits a player has to type for the game to hear `code`
    stages and `suits` suits.

    The verdict ($9A03) pins almost the whole field: the four score bytes and
    the seven places that have to be nought leave only the low bit of six
    places free, and the sum fills those.  So for each of the seventeen codes
    and sixteen suit words there is exactly one field, and this is it, built
    backwards through the same five steps the cartridge judges forwards.
    """
    laid = [0] * PLACES
    high = code == ALL_DONE
    a = 3 if high else code & 3
    b = 3 if high else (code >> 2) & 3
    c, d = suits & 3, (suits >> 2) & 3
    if high:
        laid[11] = 4
    # $9C2B -- the sum over the bits that do not carry it, which here is the
    # four places the code and the suits live in, and the bit the fifth stage
    # sets.
    s = 2 * (a + b + c + d) + (4 if high else 0)
    laid[7] = 2 * a | ((s >> 1) & 1)
    laid[8] = 2 * c | ((s >> 2) & 1)
    laid[9] = 2 * b | ((s >> 3) & 1)
    laid[10] = 2 * d | ((s >> 4) & 1)
    perm = PERM_ODD if high else PERMS[code & 0x0F]
    # $9BFC lays $0690[i] into $0680[perm[i]], so reading it back is the same
    # table the other way about, and $9B09 puts the offsets on.
    return [(laid[perm[i]] + OFFSETS[i]) & 7 for i in range(PLACES)]


def typing(digits, at=8, every=4):
    """Presses that type a whole field: the caret is walked along with RIGHT
    and each digit is turned up with A or down with B, whichever is nearer.

    A press is (the port's line it goes down on, the buttons, how long it is
    held).  They are spread out so that no two edges land on one picture: the
    screen reads one button a picture, because $987A stops shifting $48 at the
    first bit that is set.
    """
    out = []
    for i, d in enumerate(digits):
        if i:
            out.append((at, 'RIGHT', 2))
            at += every
        key, n = ('A', d) if d <= 4 else ('B', 8 - d)
        for _ in range(n):
            out.append((at, key, 2))
            at += every
    return out, at


def pad_words(presses, frames):
    """What the pad holds on each of the port's lines, and what is newly
    pressed there."""
    down = [0] * frames
    for at, keys, hold in presses:
        word = 0
        for nm in keys.split('+'):
            word |= BITS[nm]
        for f in range(at, min(at + hold, frames)):
            down[f] |= word
    hit, was = [], 0
    for w in down:
        hit.append(w & ~was)
        was = w
    return down, hit


def cart_input(path, down, offset):
    """The title's two presses where the cartridge's own pictures are, and the
    screen's own presses at the port's line plus the offset.

    One line for every picture the held word changes on, which is what the
    emulator's script means: what is written stands until the next line.
    """
    order = sorted(BITS.items(), key=lambda kv: -kv[1])
    held = {}
    for at, keys, hold in LEAD:
        for f in range(at, at + hold):
            for nm in keys.split('+'):
                held[f] = held.get(f, 0) | BITS[nm]
    for i, w in enumerate(down):
        if w:
            held[i + offset] = held.get(i + offset, 0) | w
    lines, was = ['1 -'], 0
    for f in sorted(set(held) | {f + 1 for f in held}):
        now = held.get(f, 0)
        if now == was:
            continue
        was = now
        names = [nm for nm, bit in order if now & bit]
        lines.append('%d %s' % (f, ','.join(names) or '-'))
    open(path, 'w').write('\n'.join(lines) + '\n')


def cart_run(down, frames, offset, lo, hi, door=False):
    """One run of the cartridge: what the watched range held on each picture,
    and the numbers asked of the driver in order."""
    d = P.scratch('passwatch')
    try:
        inp = os.path.join(d, 'i.inp')
        cart_input(inp, down, offset)
        tr = os.path.join(d, 't.txt')
        cmd = P.emu('-input', inp, '-frames', str(frames + offset + 4),
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


_LEAD = {}


def lead_offset():
    """The cartridge's picture the port's first stepped line is.

    The title is played once with nothing else pressed and $18/$19 watched:
    the picture $18 first holds two and $19 one is the picture step nought ran
    on, and the picture after it is the first step one runs on.  What $1C held
    there is handed back with it, because the going dark counts on it.
    """
    if not _LEAD:
        wrote, _ = cart_run([], LEAD_WAIT, 0, FLOW[0], FLOW[1])
        now = {SCREEN: 0, STEP: 0, CLOCK: 0}
        for f in range(LEAD_WAIT):
            now.update({a: v for a, v in wrote.get(f, {}).items()
                        if a in now})
            if now[SCREEN] == 2 and now[STEP] == 1:
                _LEAD['at'] = f + 1
                _LEAD['clock'] = (now[CLOCK] + 1) & 0xFF
                break
        else:
            raise SystemExit('the title never handed over to the password '
                             'screen')
    return _LEAD['at'], _LEAD['clock']


def cart_state(down, frames, offset):
    """The cartridge's whole answer, one row to a picture of the port's."""
    flow, asked = cart_run(down, frames, offset, FLOW[0], FLOW[1], door=True)
    caret, _ = cart_run(down, frames, offset, CARET[0], CARET[1])
    field, _ = cart_run(down, frames, offset, FIELD[0], FIELD[1])
    now = {SCREEN: 0, STEP: 0, WAIT: 0, SPOT: 0, SUITS: 0, CLEARED: 0,
           STAGE: 0, AREA: 0, KIND: 0, DOWN: 0, ALONG: 0}
    for a in range(FIELD[0], FIELD[1] + 1):
        now[a] = 0
    for a in range(PAINT, PAINT + PAINTS):
        now[a] = 0
    rows = []
    for f in range(frames + offset + 2):
        for one in (flow, caret, field):
            now.update({a: v for a, v in one.get(f, {}).items() if a in now})
        rows.append((
            now[SCREEN], now[STEP], now[SPOT], now[WAIT],
            [now[TYPED + i] for i in range(PLACES)],
            [now[LAID + i] for i in range(PLACES)],
            [now[FOUND + i] for i in range(FOUNDS)],
            now[CLEARED], now[SUITS],
            now[DOWN], now[ALONG], now[KIND],
            [now[PAINT + i] for i in range(PAINTS)],
            (now[STAGE], now[AREA], now[CLEARED], now[SUITS]),
            list(asked.get(f, []))))
    return rows


def engine(hit, clock, shots, tmp):
    """`Pb2Pass` given the same pad, one line to a picture, and the port's own
    picture at every line asked for."""
    cfg = {'clock': clock,
           'frames': [{'hit': h} for h in hit],
           'shots': {str(f): os.path.join(tmp, 'e%d.png' % f) for f in shots}}
    path = os.path.join(tmp, 'p.json')
    open(path, 'w').write(json.dumps(cfg))
    cmd = [V.GODOT, '--path', V.GAME]
    if shots:
        cmd += ['--rendering-driver', 'opengl3', '--resolution', '256x240']
    else:
        cmd += ['--headless']
    cmd += ['--', '--pass=' + path]
    try:
        r = subprocess.run(cmd, capture_output=True, text=True,
                           timeout=V.ENGINE_WAIT)
    except subprocess.TimeoutExpired:
        sys.stderr.write('the engine never stopped\n')
        return [], {}
    out, opened = [], None
    for line in r.stdout.split('\n'):
        line = line.strip()
        if line.startswith('> '):
            # What the screen handed the game: the stage and area it opened
            # and the two counters the password granted.
            opened = tuple(int(x, 16) if i >= 2 else int(x)
                           for i, x in enumerate(line[2:].split()))
            continue
        parts = line.split('|')
        if len(parts) != 2:
            continue
        h = parts[0].split()
        if len(h) != 14 or not h[0].isdigit():
            continue
        say = parts[1].strip()
        out.append((
            (int(h[0]), int(h[1]), int(h[2], 16),
             [int(c, 16) for c in h[3]], [int(c, 16) for c in h[4]],
             [int(h[5][i * 2:i * 2 + 2], 16) for i in range(FOUNDS)],
             int(h[6], 16), int(h[7], 16),
             int(h[8], 16), int(h[9], 16), int(h[10], 16),
             [int(h[13][i * 2:i * 2 + 2], 16) for i in range(PAINTS)]),
            int(h[11]), int(h[12]),
            [] if say == '-' else [int(x, 16) for x in say.split()]))
    if not out:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return out, cfg['shots'], opened


def cart_shots(down, offset, where, tmp):
    """The cartridge photographed one picture after each line asked for.

    `where` says which of the cartridge's pictures each line was judged
    against, because a re-raising puts the two out of step by a picture.
    """
    d = P.scratch('passshots')
    try:
        inp = os.path.join(d, 'i.inp')
        cart_input(inp, down, offset)
        base = os.path.join(tmp, 'rom')
        at = {f: where[f] + 1 for f in where}
        cmd = P.emu('-input', inp, '-frames', str(max(at.values()) + 3),
                    '-png', base)
        for f in sorted(at.values()):
            cmd += ['-shot', str(f)]
        subprocess.run(cmd, check=True, capture_output=True)
        return {f: '%s_%d.png' % (base, at[f]) for f in at}
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


def _say(ns):
    return ' '.join('%02X' % n for n in ns) or '-'


def _short(row):
    """A row of either side, said in one line."""
    return '%d/%d w%02X %s %s %s %02X %02X %02X %02X %02X %s' % (
        row[0], row[1], row[2],
        ''.join('%X' % v for v in row[3]),
        ''.join('%X' % v for v in row[4]),
        ''.join('%02X' % v for v in row[5]),
        row[6], row[7], row[8], row[9], row[10],
        ''.join('%02X' % v for v in row[11]))


def check(name, presses, frames, shots, tmp):
    offset, clock = lead_offset()
    down, hit = pad_words(presses, frames)
    rows = cart_state(down, frames, offset)
    mine, pics, opened = engine(hit, clock, shots, tmp)
    if not mine:
        return None, None, None, (0, 'the engine said nothing', '-')
    n = asks = 0
    left = None
    # Line nought of the port is its making, where step nought ran; the
    # cartridge ran step nought on picture offset - 1.  A re-raising costs the
    # cartridge a picture the port does not spend, so what each line was
    # judged against is kept, for the photographs to be taken at.
    at = {}
    slip = 0
    raising = False
    for i, (head, took, nxt, ours) in enumerate(mine[1:]):
        f = i + offset + slip
        if raising:
            # $9693 all over again: the cartridge turns the screen off, plays
            # the two streams and turns it back on, and $19 holds one again
            # only on the picture that finished.  The port is up in one.
            g = f
            while g < len(rows) and rows[g][1] != 1:
                g += 1
            if g >= len(rows):
                break
            slip += g - f
            f = g
            raising = False
        if f >= len(rows):
            break
        at[i] = f
        theirs = rows[f][-1]
        was = rows[f][1:-2]
        if took >= 0:
            # $9737 -- the screen writes $18 and $19 and is gone.  The step is
            # the one it left for and not its own any more, so everything but
            # the step is judged here.
            if rows[f][0] != took or was[0] != nxt:
                return None, None, None, (
                    i, 'screen %d step %d' % (rows[f][0], was[0]),
                    'left for %d at step %d' % (took, nxt))
            if was[1:] != head[1:] or theirs != ours:
                return None, None, None, (
                    i, '%s   %s' % (_short(was), _say(theirs)),
                    '%s   %s' % (_short(head), _say(ours)))
            # $9707 -- and what the screen handed the game, which the port
            # hands over in `_pass_took` and not in the screen at all.
            if opened != rows[f][-2]:
                return None, None, None, (
                    i, 'opened %s' % (rows[f][-2],),
                    'opened %s' % (opened,))
            n += 1
            asks += len(theirs)
            left = took
            break
        if was != head or theirs != ours:
            return None, None, None, (
                i, '%s   %s' % (_short(was), _say(theirs)),
                '%s   %s' % (_short(head), _say(ours)))
        n += 1
        asks += len(theirs)
        # $9835 -- the going back put $19 to nought, so the picture after this
        # one is a raising on both sides.
        if head[0] == RAISE:
            raising = True
    if not shots:
        return n, asks, left, None
    want = [f for f in shots if f in at and f < n]
    rom = cart_shots(down, offset, {f: at[f] for f in want}, tmp)
    for f in sorted(rom):
        got = differ(rom[f], pics[str(f)])
        if got:
            return None, None, None, (f, '%d points of the picture differ'
                                      % got, 'see %s' % pics[str(f)])
    return n, asks, left, None


def scenes():
    """(name, presses, how many pictures, which pictures to photograph).

    A photograph is never asked for on the picture a digit was turned or the
    two after it: the cartridge queues those four tiles for the next blank
    ($0300) while the port lays them on the page at once.
    """
    out = []
    # Nobody presses anything: the screen stands as it was raised.
    out.append(('bored', [], 80, [0, 1, 2, 4, 20, 79]))
    # The caret walked along, down, up and back, and off each edge.  RIGHT
    # from the last place wraps to the first ($9891) and LEFT from the first
    # to the last ($98A3); DOWN from the bottom row goes four further on and
    # is masked, UP from the top row masked and then taken back.
    walk = [(8, 'RIGHT', 2), (12, 'RIGHT', 2), (16, 'DOWN', 2),
            (20, 'DOWN', 2), (24, 'UP', 2), (28, 'LEFT', 2),
            (32, 'LEFT', 2), (36, 'LEFT', 2), (40, 'UP', 2),
            (44, 'DOWN', 2), (48, 'RIGHT', 2)]
    out.append(('walk', walk, 80, [7, 11, 15, 19, 23, 31, 39, 43, 60]))
    # A digit turned up past seven and down past nought, in one place.
    turn = [(8 + 4 * i, 'A', 2) for i in range(9)]
    turn += [(48 + 4 * i, 'B', 2) for i in range(3)]
    out.append(('turn', turn, 80, [7, 11, 23, 47, 51, 63, 79]))
    # Buttons this screen does not read, held all the way.
    out.append(('deaf', [(8, 'SELECT', 60)], 80, [7, 20, 60, 79]))
    # START on an empty field, which is a password of twelve noughts and no
    # password at all: the refusal, the wait of $40, the going dark, and the
    # screen up again with the field wiped.
    out.append(('refused', [(8, 'START', 2)], 260,
                [7, 9, 12, 40, 80, 120, 150, 180, 220, 255]))
    # A field typed and then refused, so that the wiping has something to
    # wipe and the queued stream something to be written over.
    typed, at = typing([1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5])
    out.append(('typed-refused', typed + [(at + 8, 'START', 2)], at + 200,
                [at - 1, at + 7, at + 12, at + 40, at + 100, at + 180]))
    # And the passwords the game itself would hand out: nothing behind him,
    # some of it, and all of it.
    for code, suits in ((0x00, 0x0), (0x03, 0x5), (0x0F, 0xF),
                        (ALL_DONE, 0xF)):
        digits = password(code, suits)
        typed, at = typing(digits)
        out.append(('taken-%02X-%X' % (code, suits),
                    typed + [(at + 8, 'START', 2)], at + 180,
                    [at - 1, at + 7, at + 12, at + 40, at + 90]))
    return out


def main():
    want = scenes()
    pictures = True
    for a in sys.argv[1:]:
        if a.startswith('--only='):
            only = a.split('=')[1].split(',')
            want = [s for s in want if s[0] in only]
        elif a == '--no-pictures':
            pictures = False
    tmp = P.scratch('passverify')
    bad = lines = asks = shots = 0
    opened = set()
    try:
        for name, presses, frames, pics in want:
            if not pictures:
                pics = []
            n, k, left, diff = check(name, presses, frames, pics, tmp)
            if diff is None:
                lines += n
                asks += k
                shots += len(pics)
                if left is not None:
                    opened.add(left)
                print('%-16s ok   %d pictures, %d asked, %s'
                      % (name, n, k, 'stood on' if left is None
                         else 'left for screen %d' % left))
            else:
                bad += 1
                print('%-16s DIFF at picture %d' % (name, diff[0]))
                print('    game   %s' % diff[1])
                print('    engine %s' % diff[2])
            sys.stdout.flush()
    finally:
        P.sweep(tmp)
    print('%d pictures judged, %d requests, %d photographs'
          % (lines, asks, shots))
    # A run where no password was ever taken has judged the refusing and
    # nothing else, however green it looks.
    if not bad and not (opened & {GOES_TO, GOES_TO_ALL}):
        print('no password was taken: the taking is unjudged')
        return 1
    print('%d of %d scenes differ from what the cartridge does'
          % (bad, len(want)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
