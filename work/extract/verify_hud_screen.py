#!/usr/bin/env python3
"""The bar reaches the screen: the queue is emptied and the tiles land.

`verify_hud.py` judges what each piece of the bar *pushes*.  This judges what
becomes of it.  The bar's own records are taken as the cartridge pushed them,
read the way $CC41 reads them, and what is left in the engine's screen is set
against the picture unit's own memory -- the name tables and the colours,
straight out of a running cartridge.

Only the bar's records are read here, not the whole queue: the level pushes
into the same queue, and it also draws where the queue cannot be seen (a fresh
screen is wiped straight through $2007), so a cell of the ground says nothing
about the reading.  Every cell the bar writes is its own and is judged.
"""
import json
import os
import struct
import subprocess
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', 'tools'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pb2_probe as P                                        # noqa: E402
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402
import verify_hud as H                                       # noqa: E402

GODOT = V.GODOT
GAME = V.GAME

# $CC41 -- the blanking.  It is reached once a frame, and the queue as it
# stands at that moment is what goes to the screen.
FLUSH = 'CC41'
QUEUE = range(0x0300, 0x0400)


def ciram(dump):
    """CIRAM out of a -vram file, and the way $2000..$2FFF folds into it."""
    raw = open(dump, 'rb').read()
    assert raw[:8] == b'PB3VRAM1', 'not a vram dump'
    nt = raw[12:12 + 2048]
    pal = raw[2060:2060 + 32]
    mirror = raw[2364]
    return nt, pal, mirror


def record(stage, area, script, at, pokes=(), early=()):
    """The bar's own records, and the screen the cartridge ended up with.

    The turns are taken by `verify_hud`, which knows which pushes are the
    bar's; the screen is taken from a second run of the same input, which is
    the same run again -- the cartridge has no mind of its own.
    """
    calls = H.record(stage, area, script, pokes, early)
    d = P.scratch('hudscr')
    try:
        inp = os.path.join(d, 'i.inp')
        with open(inp, 'w') as f:
            for fr, keys in sorted(script):
                f.write('%d %s\n' % (P.PICK_LEVEL + fr, keys or '-'))
        state = pb2_trace.state_for(P.PICK_LEVEL, stage, area, None,
                                    pokes=pokes, early=early)
        dump = os.path.join(d, 'v.bin')
        subprocess.run(P.emu('-loadstate', state, '-input', inp,
                             '-frames', str(at + 2),
                             '-vram', '%s@%d' % (dump, at)),
                       check=True, capture_output=True)
        # A turn taken in the picture before the one that is looked at has
        # certainly been emptied into the screen by now; a later one may not
        # have been.
        queues = [c['bytes'] for c in calls if c['frame'] < at - 1]
        return queues, ciram(dump)
    finally:
        P.sweep(d)


def ask_engine(queues, mirror, path):
    json.dump(dict(queues=queues, mirror=mirror), open(path, 'w'))
    r = subprocess.run([GODOT, '--path', GAME, '--headless', '--',
                        '--hudscreen=' + path], capture_output=True, text=True)
    cells, colours = {}, {}
    for ln in r.stdout.splitlines():
        if ln.startswith('c '):
            _, a, b = ln.split()
            cells[int(a, 16)] = int(b, 16)
        elif ln.startswith('p '):
            _, a, b = ln.split()
            colours[int(a, 16)] = int(b, 16)
    if not cells:
        raise SystemExit('the engine said nothing:\n' + r.stdout + r.stderr)
    return cells, colours


def check(name, stage, area, script, at, tmp, pokes=(), early=()):
    queues, (nt, pal, mirror) = record(stage, area, script, at, pokes, early)
    cells, colours = ask_engine(queues, mirror, os.path.join(tmp, 's.json'))
    bad = []
    for off in sorted(cells):
        if nt[off] != cells[off]:
            bad.append(('cell %03X' % off, nt[off], cells[off]))
    for i in sorted(colours):
        if pal[i] != colours[i]:
            bad.append(('colour %02X' % i, pal[i], colours[i]))
    n = len(cells) + len(colours)
    print('%-22s %d queues, %d cells, %d differ' % (name, len(queues), n,
                                                    len(bad)))
    for where, want, got in bad[:12]:
        print('    %-10s cartridge %02X  engine %02X' % (where, want, got))
    return n, len(bad)


def main():
    tmp = P.scratch('hudscrrun')
    hold = [(2, '-'), (60, 'B'), (200, '-'), (260, 'RIGHT,B'), (400, '-')]
    at = P.PICK_LEVEL + 500
    runs = [
        ('0:0 plain', 0, 0, hold, (), ()),
        ('0:0 suit-3', 0, 0, hold, ((0x9A, 3), (0x56, 0x0F), (0xA0, 0x0C)),
         ()),
        ('5:5 boss', 5, 5, hold, (), ((0x79, 1),)),
    ]
    targets = None
    if '--all-areas' in sys.argv[1:]:
        targets = V.areas_from_index()
    for a in sys.argv[1:]:
        if a.startswith('--areas='):
            targets = [tuple(int(x) for x in p.split(':'))
                       for p in a.split('=')[1].split(',')]
    if targets is not None:
        runs = [('%d:%d plain' % (st, ar), st, ar, hold, (), ())
                for st, ar in targets] + runs[1:]
    ran = bad = 0
    try:
        for name, stage, area, script, pokes, early in runs:
            n, b = check(name, stage, area, script, at, tmp, pokes, early)
            ran += n
            bad += b
    finally:
        P.sweep(tmp)
    print('%d of %d cells of the screen differ' % (bad, ran))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
