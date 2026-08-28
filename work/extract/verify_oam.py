#!/usr/bin/env python3
"""Э3.9 acceptance: the engine must fill the console's sprite table itself.

The cartridge is played and the whole of its memory written down on a run of
pictures in a row.  For each of them the engine is handed the twenty-two
places exactly as the cartridge held them and the count that says where in the
sprite table this picture starts ($28), and must answer with the same two
hundred and fifty-six bytes the cartridge wrote to $0200.

Nothing else is handed over: which little picture each place is drawn out of,
where each of its sprites goes, which of them are dropped for being off the
level and which sixty-four of the table are used are all the engine's own.

The table is not wiped between pictures -- a sprite the drawing does not touch
keeps what it said last time -- so the engine keeps its own copy across the
run and is seeded only once, at the start.
"""
import json
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import ROM_PB2, ROOT                                 # noqa: E402
from vramdump import VDump                                       # noqa: E402
import verify_player as V                                        # noqa: E402

EMU = os.path.join(ROOT, 'work', 'tools', 'nesemu')
TMP = '/tmp/pb3v3/oam'
SLOTS, FIELDS = 22, 29
# Four runs of a hundred pictures each, spread over a walk through the first
# stage: standing about, walking, jumping and throwing.
RUNS = [1900, 2400, 2900, 3400]
RUN_LEN = 100


def script(path):
    """Boot through the titles, then walk right, jumping and throwing."""
    with open(path, 'w') as f:
        f.write('1 -\n300 START\n308 -\n700 START\n708 -\n1000 START\n1008 -\n')
        for fr in range(1500, 4200, 45):
            f.write('%d RIGHT\n%d RIGHT,A\n%d RIGHT,B\n%d RIGHT\n'
                    % (fr, fr + 12, fr + 24, fr + 30))


def table(ram):
    """The twenty-two places, twenty-nine fields each."""
    return [[ram[0x0400 + 22 * f + n] for f in range(FIELDS)]
            for n in range(SLOTS)]


def main():
    os.makedirs(TMP, exist_ok=True)
    inp = os.path.join(TMP, 'walk.inp')
    script(inp)
    wanted = [fr for a in RUNS for fr in range(a, a + RUN_LEN + 1)]
    cmd = [EMU, ROM_PB2, '-input', inp, '-frames', str(max(wanted) + 1)]
    for fr in wanted:
        cmd += ['-vram', '%s/f%d.vram@%d' % (TMP, fr, fr)]
    subprocess.run(cmd, check=True, capture_output=True)

    bad = ran = 0
    for a in RUNS:
        d = [VDump('%s/f%d.vram' % (TMP, fr)) for fr in range(a, a + RUN_LEN + 1)]
        # A dump is taken before the picture it is named for begins, so what
        # it holds is the end of the one before: the table as the game step
        # left it and the sprite table as the drawing left it.  The drawing
        # runs after the step ($8E15 at line 1942 of the trace, $8038 at 5159),
        # so the sprite table found in dump i+1 is built out of the places
        # found in that same dump -- but out of the count $28 as it stood
        # before that drawing raised it, which is the one in dump i.
        cfg = dict(seed=list(d[0].ram[0x200:0x300]),
                   frames=[dict(slots=table(d[i + 1].ram), rot=d[i].ram[0x28])
                           for i in range(RUN_LEN)])
        path = os.path.join(TMP, 'o.json')
        open(path, 'w').write(json.dumps(cfg))
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--oam=' + path], capture_output=True, text=True,
                           timeout=V.ENGINE_WAIT)
        got = [ln.strip() for ln in r.stdout.split('\n')
               if len(ln.strip()) == 512]
        if len(got) != RUN_LEN:
            sys.stderr.write(r.stdout[-2000:] + r.stderr[-2000:])
            print('run %d: the engine said nothing' % a)
            bad += 1
            continue
        first = None
        for i in range(RUN_LEN):
            ran += 1
            mine = bytes.fromhex(got[i])
            theirs = bytes(d[i + 1].ram[0x200:0x300])
            if mine == theirs:
                continue
            bad += 1
            if first is not None:              # one report a run is enough
                continue
            first = i
            for k in range(256):
                if mine[k] != theirs[k]:
                    print('run %d picture %d  byte %d (sprite %d.%d)  '
                          'engine %d cartridge %d'
                          % (a, i, k, k // 4, k % 4, mine[k], theirs[k]))
                    break
        if first is None:
            print('%d..%d  ok  %d pictures' % (a, a + RUN_LEN, RUN_LEN))
    print('%d of %d pictures differ' % (bad, ran))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
