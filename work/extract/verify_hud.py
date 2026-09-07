#!/usr/bin/env python3
"""Э3.7 acceptance: the status bar must fill the queue as the cartridge does.

Nothing in Power Blade 2 writes to video memory where it pleases.  Everything
the bottom of the screen shows is put into a queue at $0300 and the blanking
between two pictures empties it ($CC41).  So what is judged here is the queue:
the cartridge is played, every turn of a piece of the bar is caught where it
begins, and the bytes it pushed are written down.  The engine is then given
the same numbers, asked for the same piece, and must push the same bytes.

The schedule -- which piece is drawn in which picture -- belongs to the level's
own count ($1A/$1B) and is judged with it; here it is the drawing that is on
trial, a piece at a time.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_probe as P                                        # noqa: E402
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402

GODOT = V.GODOT
GAME = V.GAME

# Where each piece of the bar begins.  $D40A (a number) is left out on
# purpose: it is never entered but through one of these, so its bytes belong
# to the piece that called it.  The boss's meter is in, because it has a door
# of its own at $C8C4 -- it is redrawn on its own whenever he is hit.
PIECES = {
    'D431': 'stage_area',
    'D522': 'boss_bar',
    'D489': 'score',
    'D4A7': 'right_1',
    'D4B6': 'right_2',
    'D4C5': 'right_3',
    'D4D9': 'suit_bar',
    'D4ED': 'health_bar',
    'D58D': 'charge_bar',
    'D5C1': 'face',
}
# Two places push a byte that belongs to no piece of the bar: $CC41, which
# tops the queue with a nought before it is emptied into the screen, and
# $CD14, the frame's own "push a nought" that closes the list once the drawing
# for the frame is done.
FLUSH = ('CC41', 'CD14')

# The bar is not alone in the queue.  The level pushes into it too -- a new
# column of the ground as the screen slides, a square of colour -- and so does
# the room of a boss.  Every one of those has to close whatever piece of the
# bar was being written down, or its bytes would be counted as the bar's.
#
# They are not listed by hand.  There are six doors into the queue, and every
# place in the cartridge that goes through one of them and does not itself
# belong to the bar ($D400..$D600) or to the doors ($CC00..$CD30) is a
# stranger: reaching it ends the piece.
DOORS = (0xCD18, 0xCD1C, 0xCD09, 0xCD0B, 0xCD14, 0xCCBC)
BAR = range(0xD400, 0xD600)
GATE = range(0xCC00, 0xCD30)


def strangers():
    """Every call into the queue that is not the bar's own."""
    rom = open(os.path.join(ROOT, 'Power Blade 2 (USA).nes'), 'rb').read()
    out = set()
    for n in range(16):
        img = rom[16 + n * 0x2000:16 + (n + 1) * 0x2000]
        bases = [0x8000, 0xA000] if n < 14 else [0xC000 + (n - 14) * 0x2000]
        for base in bases:
            for i in range(len(img) - 2):
                if img[i] not in (0x20, 0x4C):
                    continue
                if img[i + 1] | (img[i + 2] << 8) not in DOORS:
                    continue
                a = base + i
                if a in BAR or a in GATE:
                    continue
                out.add('%04X' % a)
    return sorted(out)


# What the bar reads.  Each is a byte of the game's own memory.
INPUTS = dict(boss=0x79, stage=0x53, area=0x9C,
              score_hi=0x95, score_lo=0x96,
              health_tanks=0x9D, suit_tanks=0x9E, lives=0x9F,
              health=0x049A, fuel=0xA0, charge=0x54,
              boss_life=0x04A9, suit=0x9A)

# The doors on to the queue.  $CD0D is the one every piece uses a byte at a
# time; $CCE2 and $CCED are $CCBC's own, which copies a ready-made strip
# straight in.  The log names the instruction after the store, so these are
# one along.
PUSH_PC = frozenset(('CD10', 'CCE5', 'CCF0'))
QUEUE = range(0x0300, 0x0400)

FRAMES = 900


def record(stage, area, script, pokes=(), early=()):
    """Play the cartridge and write down every turn of every piece."""
    d = P.scratch('hud')
    try:
        state = pb2_trace.state_for(P.PICK_LEVEL, stage, area, None,
                                    pokes=pokes, early=early)
        ram = os.path.join(d, 'start.ram')
        inp = os.path.join(d, 'i.inp')
        log = os.path.join(d, 't.log')
        with open(inp, 'w') as f:
            for fr, keys in sorted(script):
                f.write('%d %s\n' % (P.PICK_LEVEL + fr, keys or '-'))
        subprocess.run(P.emu('-loadstate', state,
                             '-frames', str(P.PICK_LEVEL + 1),
                             '-ramdump', ram), check=True,
                       capture_output=True)
        mem = bytearray(open(ram, 'rb').read())
        sample = []
        for pc in list(PIECES) + list(FLUSH) + strangers():
            sample += ['-sample', '%s=%04X' % (pc, 0x001B)]
        subprocess.run(P.emu('-loadstate', state, '-input', inp,
                             '-frames', str(P.PICK_LEVEL + FRAMES),
                             '-watch', '0000-07FF', '-trace', log,
                             '-tracefrom', '999999', '-traceto', '999999',
                             *sample), check=True, capture_output=True)
        calls = []
        open_call = None
        for ln in open(log):
            if ln.startswith('SAMPLE'):
                fr, pc, _bank, _what, _val = ln[7:].strip().split(',')
                open_call = None
                if pc in PIECES:
                    open_call = dict(frame=int(fr), piece=PIECES[pc],
                                     bytes=[],
                                     **{k: mem[a] for k, a in INPUTS.items()})
                    calls.append(open_call)
                continue
            if not ln.startswith('WATCH'):
                continue
            _fr, pc, _bank, addr, val = ln[6:].strip().split(',')
            addr, val = int(addr, 16), int(val, 16)
            if pc in PUSH_PC and addr in QUEUE and open_call is not None:
                open_call['bytes'].append(val)
            mem[addr] = val
        return calls
    finally:
        P.sweep(d)


def ask_engine(calls, path):
    """The engine's answer for the same turns."""
    open(path, 'w').write(json.dumps(calls))
    r = subprocess.run([GODOT, '--path', GAME, '--headless', '--',
                        '--hud=' + path], capture_output=True, text=True,
                       timeout=V.ENGINE_WAIT)
    out = []
    for line in r.stdout.split('\n'):
        line = line.strip()
        if line.startswith('q'):
            out.append([int(x, 16) for x in line[1:].split()])
    if not out:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return out


def check(name, stage, area, script, tmp, pokes=(), early=()):
    calls = record(stage, area, script, pokes, early)
    if not calls:
        print('%-24s no piece of the bar was drawn at all' % name)
        return 0, 1
    got = ask_engine(calls, os.path.join(tmp, 'h.json'))
    bad = 0
    for i, c in enumerate(calls):
        mine = got[i] if i < len(got) else None
        if mine != c['bytes']:
            bad += 1
            if bad <= 3:
                print('%-24s %s at frame %d' % (name, c['piece'], c['frame']))
                print('    cartridge %s'
                      % ' '.join('%02X' % b for b in c['bytes']))
                print('    engine    %s'
                      % ('-' if mine is None
                         else ' '.join('%02X' % b for b in mine)))
    print('%-24s %d turns, %d differ' % (name, len(calls), bad))
    return len(calls), bad


def main():
    tmp = P.scratch('hudrun')
    hold = [(2, '-'), (60, 'B'), (200, '-'), (260, 'RIGHT,B'), (400, '-')]
    runs = [
        ('0:0 plain', 0, 0, hold, (), ()),
        # $9A the suit worn, $56 the ones he owns, $A0 what is left in it:
        # without them the suit's bar and its portrait are never drawn.
        ('0:0 suit-3', 0, 0, hold, ((0x9A, 3), (0x56, 0x0F), (0xA0, 0x0C)),
         ()),
        # $79 -- a boss's room, where the stage and the area give way to a
        # word and the boss's own meter.
        ('5:5 boss', 5, 5, hold, (), ((0x79, 1),)),
    ]
    # Every area of the game, so that the stage and the area the bar shows are
    # judged as they really are and not only in the first room.
    if '--all-areas' in sys.argv[1:]:
        runs = [('%d:%d plain' % (st, ar), st, ar, hold, (), ())
                for st, ar in V.areas_from_index()] + runs[1:]
    ran = bad = 0
    try:
        for name, stage, area, script, pokes, early in runs:
            n, b = check(name, stage, area, script, tmp, pokes, early)
            ran += n
            bad += b
    finally:
        P.sweep(tmp)
    print('%d of %d turns of the bar differ' % (bad, ran))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
