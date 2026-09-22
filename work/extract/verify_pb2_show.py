#!/usr/bin/env python3
"""Э7.7 acceptance: the screen a password is typed on, the other way about --
the game naming a password back, reached the way a player reaches it.

Nothing but the end of the game opens this half.  Step eleven of the level's
own flow ($D022) asks how many lives are left, and with none left it wipes the
game out and writes $18 := 2, $19 := 4 ($D090): the same screen as Э7.6's, put
up at its fourth step instead of its nought-th.

So this stand does not poke the screen up.  It plays the cartridge into a
level the way every other Power Blade 2 stand plays it, takes the last of his
health away ($049A := 0) with no lives left to lose ($9F := 0), and lets the
game walk its own road from there: he dies, the tune of it, two hundred
pictures of mourning, the screen going dark, and the password screen up out of
$D090.  Two cells are poked and both are cells the game itself writes.

Two more are poked in the same breath for the scenes that ask for them -- $5B,
the stages behind him, and $56, the suits he has found -- because a stand
cannot play five stages to fill them, and they are what the password is made
of.  Nothing else is touched.

What is compared
----------------
Everything Э7.6 compares, on the same line ($19, $51, $50, $0690..$069B,
$0680..$068B, $06A0..$06A5, $5B, $56, the caret's three fields, the shadow
palette and what was asked of the driver), and $4F with them: which of the two
rows the choosing half stands on, which is the one cell this half keeps and
the typing half never touches.

And the picture itself, point for point, at a handful of pictures of every
run.

The one promise on top of the cartridge
---------------------------------------
The twelve digits the game names are put against `verify_pb2_pass.password`,
which builds the same field backwards through the verdict.  The two ends of
the codec are different code -- $9A1C forwards and $9A03 back -- so a field
they both arrive at is not a field the port could have got right by copying
one of them.

How the two are lined up
------------------------
The port raises in its making, the way it does for the typing half, so its
first stepped line is the picture step five's body runs on.

One place costs the cartridge pictures the port does not spend, and it is not
the queue: $97A7 waits for $C8, and $C8 is the number the driver is playing
($80C3 writes it and $813F clears it).  Step four asks for the tune of a game
that is over and step five stands there until it has finished -- a hundred and
eighty-two pictures.  This port's screen has no way to ask the driver whether
it is still sounding, so it does not wait; that is a debt, written down in
`work/re/pb2_password.md`, and here it shows as the one gap between the two
sides.  The port's line nought is judged against the cartridge's first picture
at step six, and after that the two walk a picture at a time.

To be sure that is the only gap, the lining up is done by the step number and
not by counting: each line is judged against the cartridge's own picture at
the step the port reached, and a line at the step before it is judged against
the picture after.  A second gap anywhere would show as a line judged against
a picture far from the one before it, and the presses -- which are placed a
picture at a time from line nought -- would land in the wrong place and the
run would differ.

A photograph is never asked for while the digits are being written or on the
two pictures after: the cartridge queues those four tiles at $0300 for the
next blank to push out, while the port lays them on the page at once.
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_probe as P                                          # noqa: E402
import verify_pb2_pass as T                                    # noqa: E402

BITS = T.BITS
# $049A -- the health the bar is drawn from, which is where a hit is taken
# off ($D4ED), and $9F -- how many more times he is put back.  With no health
# and no lives the game is over on the picture after.
HEALTH, LIVES = 0x049A, 0x009F
# The picture the two go in, counted from the state the cartridge is played
# into, and how long to let the road have: a picture of dying, two hundred of
# mourning, sixty of going dark and a hundred and eighty of the tune.
POKE_AT, ROAD_WAIT = 4, 800
# How many pictures of room the cartridge is given over what the port spends.
SLACK = 24
# $19 -- the steps this stand names.  Four is the raising $D096 writes, six is
# chosen on, eight lays the field out and nine writes the digits.
SHOW_PICK, SHOW_FIELD, SHOW_DIGITS = 6, 8, 9
SHOW_HOLD = 10
# $4F -- which of the two rows is chosen.
CHOICE = T.CHOICE
# Where the two rows lead: the upper one leaves the way a taken password
# leaves, and the lower one for the title screen once it has shown one.
GOES_TO, SHOWN_GOES_TO = T.GOES_TO, 0
ALL_DONE = T.ALL_DONE
# The picture of the cartridge the state stands at; every number the emulator
# is given is counted from the start of the run and not from the state.
BASE = P.IN_LEVEL


def state():
    """The cartridge booted and standing in the first area, in control.

    It is the state `pb2_probe` makes for every other stand, and it is cached
    under the scratch roof, so a second run does not replay the boot.
    """
    os.makedirs(P.SCRATCH, exist_ok=True)
    return P.make_state(os.path.join(P.SCRATCH, 'showbase'))


def cart_input(path, held):
    """One line for every picture the held word changes on, which is what the
    emulator's script means: what is written stands until the next line."""
    order = sorted(BITS.items(), key=lambda kv: -kv[1])
    lines, was = ['%d -' % BASE], 0
    for f in sorted(set(held) | {f + 1 for f in held}):
        now = held.get(f, 0)
        if now == was:
            continue
        was = now
        names = [nm for nm, bit in order if now & bit]
        lines.append('%d %s' % (BASE + f, ','.join(names) or '-'))
    open(path, 'w').write('\n'.join(lines) + '\n')


def cart_run(held, last, lo, hi, poke, door=False):
    """One run of the cartridge from the state: the death poked in, the road
    walked, and what the watched range held on each picture."""
    d = P.scratch('showwatch')
    try:
        inp = os.path.join(d, 'i.inp')
        cart_input(inp, held)
        tr = os.path.join(d, 't.txt')
        cmd = P.emu('-loadstate', state(), '-input', inp,
                    '-frames', str(BASE + last),
                    '-watch', '%04X-%04X' % (lo, hi), '-trace', tr,
                    '-tracefrom', '999999', '-traceto', '999999')
        for a, v in poke:
            cmd += ['-poke', '%04X=%02X@%d' % (a, v, BASE + POKE_AT)]
        if door:
            cmd += ['-sample', '%s=A' % T.DOOR]
        subprocess.run(cmd, check=True, capture_output=True)
        wrote, asked = {}, {}
        for line in open(tr):
            if line.startswith('SAMPLE'):
                f, _pc, _bk, _w, v = line[7:].strip().split(',')
                asked.setdefault(int(f) - BASE, []).append(int(v, 16))
                continue
            if not line.startswith('WATCH'):
                continue
            f, _pc, _bk, ad, v = line.split()[1].split(',')
            wrote.setdefault(int(f) - BASE, {})[int(ad, 16)] = int(v, 16)
        return wrote, asked
    finally:
        P.sweep(d)


def pokes(code, suits):
    """The two that end the game, and the two the password is made of."""
    return ((HEALTH, 0), (LIVES, 0), (T.CLEARED, code), (T.SUITS, suits))


_ROAD = {}


def road(code, suits):
    """The cartridge's picture the port's first stepped line is, and what $1C
    held there.

    The road is walked once with nothing pressed and $18/$19 watched: the
    first picture $18 holds two and $19 six is the picture step five's body
    ran on, which is the port's line nought.  The hundred and eighty-two
    pictures step five spent waiting for the tune are the gap the port does
    not have, and they are all in front of that picture.
    """
    key = (code, suits)
    if key not in _ROAD:
        wrote, _ = cart_run({}, ROAD_WAIT, T.FLOW[0], T.FLOW[1],
                            pokes(code, suits))
        now = {T.SCREEN: 0, T.STEP: 0, T.CLOCK: 0}
        for f in range(ROAD_WAIT):
            now.update({a: v for a, v in wrote.get(f, {}).items()
                        if a in now})
            if now[T.SCREEN] == 2 and now[T.STEP] == SHOW_PICK:
                _ROAD[key] = (f, now[T.CLOCK])
                break
        else:
            raise SystemExit('the game never named a password back')
    return _ROAD[key]


def holding(down, at, offset):
    """What the pad holds on each picture of the cartridge.

    A press written down for a line goes in at the picture that line is.
    Which picture that is, is what `check` measures: the two do not walk
    together all the way, because the cartridge spends pictures the port does
    not.  Past the last line the walk reached, and before the first walk of
    all, a line is taken to be the picture the line before it was and one
    more -- which is what the two do as long as the step does not change.
    """
    where = {}
    f = offset - 1
    for i in range(len(down)):
        f = at[i] if i in at else f + 1
        where[i] = f
    return {where[i]: w for i, w in enumerate(down) if w}


def cart_state(held, last, code, suits):
    """The cartridge's whole answer, one row to a picture."""
    p = pokes(code, suits)
    flow, asked = cart_run(held, last, T.FLOW[0], T.FLOW[1], p, door=True)
    caret, _ = cart_run(held, last, T.CARET[0], T.CARET[1], p)
    field, _ = cart_run(held, last, T.FIELD[0], T.FIELD[1], p)
    now = {T.SCREEN: 0, T.STEP: 0, T.WAIT: 0, T.SPOT: 0, T.SUITS: 0,
           T.CLEARED: 0, T.STAGE: 0, T.AREA: 0, T.KIND: 0, T.DOWN: 0,
           T.ALONG: 0, CHOICE: 0}
    for a in range(T.FIELD[0], T.FIELD[1] + 1):
        now[a] = 0
    for a in range(T.PAINT, T.PAINT + T.PAINTS):
        now[a] = 0
    rows = []
    for f in range(last):
        for one in (flow, caret, field):
            now.update({a: v for a, v in one.get(f, {}).items() if a in now})
        rows.append((
            now[T.SCREEN], now[T.STEP], now[T.SPOT], now[T.WAIT],
            [now[T.TYPED + i] for i in range(T.PLACES)],
            [now[T.LAID + i] for i in range(T.PLACES)],
            [now[T.FOUND + i] for i in range(T.FOUNDS)],
            now[T.CLEARED], now[T.SUITS],
            now[T.DOWN], now[T.ALONG], now[T.KIND],
            [now[T.PAINT + i] for i in range(T.PAINTS)],
            now[CHOICE],
            (now[T.STAGE], now[T.AREA], now[T.CLEARED], now[T.SUITS]),
            list(asked.get(f, []))))
    return rows


def cart_shots(held, where, code, suits, tmp):
    """The cartridge photographed one picture after each line asked for."""
    d = P.scratch('showshots')
    try:
        inp = os.path.join(d, 'i.inp')
        cart_input(inp, held)
        base = os.path.join(tmp, 'rom')
        at = {f: where[f] + 1 for f in where}
        cmd = P.emu('-loadstate', state(), '-input', inp,
                    '-frames', str(BASE + max(at.values()) + 3), '-png', base)
        for a, v in pokes(code, suits):
            cmd += ['-poke', '%04X=%02X@%d' % (a, v, BASE + POKE_AT)]
        for f in sorted(at.values()):
            cmd += ['-shot', str(BASE + f)]
        subprocess.run(cmd, check=True, capture_output=True)
        return {f: '%s_%d.png' % (base, BASE + at[f]) for f in at}
    finally:
        P.sweep(d)


def walk(rows, mine, opened, offset):
    """The port's lines judged against the cartridge's pictures, one for one.

    What comes back is the same five the check gives, and the sixth is which
    picture each line was judged against -- the presses of the next walk go
    in on those.
    """
    n = asks = 0
    left = None
    named = None
    at = {}
    f = offset - 1
    was = None
    for i, (head, took, nxt, ours) in enumerate(mine[1:]):
        if took >= 0 or (was is not None and head[0] == was):
            # The two walk together: a line at the step the one before it was
            # at, and the line the screen is gone on, are the picture after.
            f += 1
        else:
            # A step the port has just reached, judged against the cartridge's
            # own first picture at it.
            f += 1
            while f < len(rows) and rows[f][1] != head[0]:
                f += 1
        if f >= len(rows):
            break
        at[i] = f
        was = head[0]
        theirs = rows[f][-1]
        state_was = rows[f][1:-2]
        if took >= 0:
            # $981A and $9737 -- the screen writes $18 and $19 and is gone.
            if rows[f][0] != took or state_was[0] != nxt:
                return None, None, None, None, (
                    i, 'screen %d step %d' % (rows[f][0], state_was[0]),
                    'left for %d at step %d' % (took, nxt)), at
            if state_was[1:] != head[1:] or theirs != ours:
                return None, None, None, None, (
                    i, '%s   %s' % (T._short(state_was), T._say(theirs)),
                    '%s   %s' % (T._short(head), T._say(ours))), at
            n += 1
            asks += len(theirs)
            left = took
            # $9822 -- the row that showed a password hands the game nothing
            # but the title; the other row goes on to the screen a stage is
            # picked on, and says which stage that is.
            if took == 0 and opened != ('title', True):
                return None, None, None, None, (
                    i, 'the title screen goes up',
                    'the port opened %s' % (opened,)), at
            break
        if state_was != head or theirs != ours:
            return None, None, None, None, (
                i, '%s   %s' % (T._short(state_was), T._say(theirs)),
                '%s   %s' % (T._short(head), T._say(ours))), at
        n += 1
        asks += len(theirs)
        # $9807 -- the twelve digits as they stand once the last of them is
        # written, which is the password the game named.  The line the
        # twelfth is written on is already the step after, because writing it
        # is what ends step nine.
        if named is None and head[1] == T.PLACES and head[0] >= SHOW_HOLD:
            named = list(head[3])
    return n, asks, left, named, None, at


# How many times the walk is tried.  The first walk puts the presses in at the
# picture of the same number, learns which picture each line really is, and
# the next one puts them in there; two walks are enough for every scene here,
# and the third is only ever a proof that nothing moved.
TRIES = 4


def check(name, presses, frames, shots, code, suits, tmp):
    offset, clock = road(code, suits)
    down, hit = T.pad_words(presses, frames)
    mine, pics, opened = T.engine(hit, clock, shots, tmp, show=(code, suits))
    if not mine:
        return None, None, None, None, (0, 'the engine said nothing', '-')
    # The cartridge is given room for the pictures the port does not spend.
    last = offset + frames + SLACK
    at = {}
    held = holding(down, at, offset)
    got = None
    for _ in range(TRIES):
        rows = cart_state(held, last, code, suits)
        got = walk(rows, mine, opened, offset)
        was, at = held, got[-1]
        held = holding(down, at, offset)
        if held == was:
            break
    else:
        return None, None, None, None, (
            0, 'the presses settle on a picture',
            'they moved on every one of %d walks' % TRIES)
    n, asks, left, named, diff, at = got
    if diff is not None:
        return None, None, None, None, diff
    if not shots:
        return n, asks, left, named, None
    want = [f for f in shots if f in at and f < n]
    rom = cart_shots(held, {f: at[f] for f in want}, code, suits, tmp)
    for f in sorted(rom):
        got = T.differ(rom[f], pics[str(f)])
        if got:
            return None, None, None, None, (
                f, '%d points of the picture differ' % got,
                'see %s' % pics[str(f)])
    return n, asks, left, named, None


def scenes():
    """(name, presses, how many pictures, which to photograph, the stages
    behind him, the suits he has found).

    A press is (the port's line it goes down on, the buttons, how long it is
    held), the same shape Э7.6's scenes are written in.
    """
    out = []
    # Nobody presses anything: the two rows stand and the caret on the first.
    out.append(('bored', [], 80, [0, 1, 2, 4, 20, 79], 0x00, 0x0))
    # SELECT walks the caret between the two rows and back; the six buttons
    # the typing half reads are pressed in turn and this half is deaf to all
    # of them.
    walk = [(8, 'SELECT', 2), (16, 'SELECT', 2), (24, 'SELECT', 2),
            (32, 'A', 2), (36, 'B', 2), (40, 'RIGHT', 2), (44, 'LEFT', 2),
            (48, 'UP', 2), (52, 'DOWN', 2), (56, 'SELECT', 2)]
    out.append(('walk', walk, 80, [7, 15, 23, 31, 47, 60], 0x00, 0x0))
    # START on the upper row, which shows nothing: the wait of one that the
    # raising left in $50, the going dark, and the screen a stage is picked
    # on, entered at the step a taken password enters it at.
    out.append(('back', [(8, 'START', 2)], 140,
                [7, 9, 12, 40, 100, 130], 0x03, 0x5))
    # And the lower row, which is the whole of this half: the going dark, the
    # field screen raised while it is dark, twelve digits a picture apart, the
    # colours back with the last of them, and START for the title screen.
    #
    # The last of the digits is written around line ninety; the photographs
    # keep away from the twelve pictures they are written on and the two
    # after, and START comes well after all of them.
    for code, suits in ((0x00, 0x0), (0x03, 0x5), (0x0F, 0xF),
                        (ALL_DONE, 0xF)):
        shown = [(8, 'SELECT', 2), (16, 'START', 2), (120, 'START', 2)]
        out.append(('shown-%02X-%X' % (code, suits), shown, 260,
                    [7, 15, 20, 40, 60, 100, 110, 119, 130, 200, 250],
                    code, suits))
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
    tmp = P.scratch('showverify')
    bad = lines = asks = shots = named = 0
    left_for = set()
    try:
        for name, presses, frames, pics, code, suits in want:
            if not pictures:
                pics = []
            n, k, left, said, diff = check(name, presses, frames, pics,
                                           code, suits, tmp)
            if diff is not None:
                bad += 1
                print('%-16s DIFF at picture %d' % (name, diff[0]))
                print('    game   %s' % diff[1])
                print('    engine %s' % diff[2])
                sys.stdout.flush()
                continue
            note = 'stood on' if left is None else 'left for screen %d' % left
            if said is not None:
                # $9A03 the other way about: the field Э7.6 builds backwards
                # out of the verdict is the field this half built forwards.
                ought = T.password(code, suits)
                if said != ought:
                    bad += 1
                    print('%-16s DIFF in the password named' % name)
                    print('    verdict %s'
                          % ''.join('%X' % v for v in ought))
                    print('    shown   %s'
                          % ''.join('%X' % v for v in said))
                    sys.stdout.flush()
                    continue
                named += 1
                note += ', named %s' % ''.join('%X' % v for v in said)
            lines += n
            asks += k
            shots += len(pics)
            if left is not None:
                left_for.add(left)
            print('%-16s ok   %d pictures, %d asked, %s' % (name, n, k, note))
            sys.stdout.flush()
    finally:
        P.sweep(tmp)
    print('%d pictures judged, %d requests, %d photographs, %d passwords '
          'named' % (lines, asks, shots, named))
    # A run where the lower row was never chosen has judged the choosing and
    # nothing else, however green it looks.
    if not bad and not named:
        print('no password was ever named: the naming is unjudged')
        return 1
    if not bad and not {SHOWN_GOES_TO, GOES_TO} <= left_for:
        print('one of the two rows never took the screen away: the leaving '
              'is unjudged')
        return 1
    print('%d of %d scenes differ from what the cartridge does'
          % (bad, len(want)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
