#!/usr/bin/env python3
"""Э3.4 acceptance: the fourth suit's two satellites ($A945).

The satellites are places four and five of the table.  They belong to no
record, they carry no type, and nothing in the level puts them out: the hero's
own frame makes them when he puts the fourth suit on ($A95F) and takes them
away when he takes it off ($A951).  In between they walk an ellipse round him,
and whenever a thing has marked itself in $0117 or $0118 one of them leaves
the walk, goes for it, and eats it.

Every other stand hands the first six places over whole, so the two are told
and never judged.  Here they are the only thing judged.  For each frame the
world is set to what the cartridge held the instant before $8E2C called $A945
-- the whole table of twenty-two places, the two bytes of marks, the suit and
the picture count -- the engine is asked for that one call, and the two places
it answers with must be the cartridge's own, field for field, along with the
same things eaten.

The marks are only ever set by things the bosses throw, so the rooms of the
seventh table are where the chase happens; the walked areas prove the walk.
"""
import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_probe as P                                        # noqa: E402
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402
import verify_spawns as S                                    # noqa: E402

SLOTS = pb2_trace.SLOTS
FIELDS = pb2_trace.FIELDS

SUIT = 0x9A          # $9A -- which suit he is wearing; four is the one
TICK = 0x0110        # $0110 -- one up a frame
MARKS = (0x0117, 0x0118)

# The emulator stamps a write with the address of the instruction after it, so
# these are one instruction past the store they stand for.
#
#   $A968 INC $05E4,X  -- the first thing $A945 does on an ordinary frame
#   $AA94 STA $05FA,X  -- and on the frame the two are made
#   $D6D6 STA $0400,X  -- the first store of the clear, which on place four
#                         can only be $A951 taking them away again
#
# The address is looked at as well as the stamp, and it is always place four's:
# a stamp alone would also catch the stack, which the JSR right after the first
# of them writes to, and that is already one turn too late.
FIRST = (('A96B', 0x05E4 + 4), ('AA97', 0x05FA + 4))
# The clear is the one stamp that other code shares: the break in the middle of
# the fifth stage empties his five places ($D768) and the room the door opens
# empties the whole table, and either of those would open a line in the middle
# of a frame whose $A945 has not run yet.  So it only counts while he is out of
# the fourth suit, which is the one case in which $A951 is the only thing that
# can be emptying place four.
TEARDOWN = ('D6D9', 0x0400 + 4)
# $8E34 STA $05CE -- the first store of the wipe that ends the hero's frame,
# and so the first moment after $A945 at which the two places are settled.
AFTER = '8E37'

# Low enough to hold $9A, high enough to hold the whole table.
LO = 0x0090
HI = 0x0400 + 22 * FIELDS - 1

FRAMES = 900
WEAR = 5             # the frame the fourth suit is put on
DOFF = 700           # and the frame it is taken off again


def rows_for(stage, area, script, spot=None, first=None, pokes=(),
             patch=False, early=()):
    """One line per frame in which $A945 did anything: the world it found, and
    the two places it left behind."""
    state = pb2_trace.state_for(first, stage, area, spot, pokes, patch, early)
    d = P.scratch('orbit')
    try:
        ram = os.path.join(d, 'start.ram')
        inp = os.path.join(d, 'i.inp')
        log = os.path.join(d, 't.log')
        with open(inp, 'w') as f:
            for fr, keys in sorted(script):
                f.write('%d %s\n' % (first + fr, keys or '-'))
        subprocess.run(P.emu('-loadstate', state, '-frames', str(first + 1),
                             '-ramdump', ram), check=True, capture_output=True)
        mem = bytearray(open(ram, 'rb').read())
        last = first + FRAMES
        subprocess.run(P.emu('-loadstate', state, '-input', inp,
                             '-frames', str(last + 1),
                             '-watch', '%04X-%04X' % (LO, HI), '-trace', log,
                             '-tracefrom', '999999', '-traceto', '999999',
                             '-poke', '%04X=04@%d' % (SUIT, first + WEAR),
                             '-poke', '%04X=00@%d' % (SUIT, first + DOFF)),
                       check=True, capture_output=True)
        changes = {}
        for ln in open(log):
            if not ln.startswith('WATCH'):
                continue
            fr, pc, _bank, addr, val = ln[6:].strip().split(',')
            changes.setdefault(int(fr), []).append(
                (int(addr, 16), int(val, 16), pc))
        out = []
        # A step of the game is not a frame of the console: the hero's own
        # frame can begin in one and end in the next, so what is opened in one
        # frame is closed wherever it closes.
        before = None
        for fr in range(first, last + 1):
            for addr, val, pc in changes.get(fr, ()):
                if before is None and ((pc, addr) in FIRST
                                       or ((pc, addr) == TEARDOWN
                                           and mem[SUIT] != 0x04)):
                    before = _snap(mem)
                mem[addr] = val
                if before is not None and pc == AFTER and addr == 0x05CE:
                    before['after'] = [_row(mem, n) for n in (4, 5)]
                    before['ate'] = [n for n in range(6, SLOTS)
                                     if mem[0x0400 + n] == 0
                                     and before['before'][n][0] != 0]
                    out.append(before)
                    before = None
        return out
    finally:
        P.sweep(d)


def _row(mem, n):
    return [mem[0x0400 + 22 * f + n] for f in range(FIELDS)]


def _snap(mem):
    return {'before': [_row(mem, n) for n in range(SLOTS)],
            'suit': mem[SUIT], 'tick': mem[TICK],
            'marks': mem[MARKS[0]], 'marks2': mem[MARKS[1]]}


def run_engine(cfg, path):
    open(path, 'w').write(json.dumps(cfg))
    try:
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--orbit=' + path], capture_output=True,
                           text=True, timeout=V.ENGINE_WAIT)
    except subprocess.TimeoutExpired:
        sys.stderr.write('the engine never stopped\n')
        return []
    out = []
    for line in r.stdout.split('\n'):
        line = line.strip()
        if line.count('|') != 2:
            continue
        four, five, ate = line.split('|')
        try:
            rows = [[int(x) for x in four.split(',')],
                    [int(x) for x in five.split(',')]]
        except ValueError:
            continue
        out.append((rows, [] if ate == '-' else [int(x) for x in ate.split()]))
    if not out:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return out


def check(name, stage, area, script, tmp, spot=None, first=None, pokes=(),
          patch=False, early=()):
    rows = rows_for(stage, area, script, spot, first, pokes, patch, early)
    if not rows:
        return 0, 0, None
    cfg = {'stage': stage, 'area': area,
           'came': dict(early).get(0x53, stage),
           'frames': [{'before': r['before'], 'suit': r['suit'],
                       'tick': r['tick'], 'marks': r['marks'],
                       'marks2': r['marks2']} for r in rows]}
    got = run_engine(cfg, os.path.join(tmp, 'o.json'))
    chased = sum(1 for r in rows
                 if r['after'][0][18] != 0 or r['after'][1][18] != 0)
    for i, r in enumerate(rows):
        if i >= len(got):
            return None, None, (i + 1, 'a line', 'nothing')
        have, ate = got[i]
        for k in (0, 1):
            if have[k] != r['after'][k]:
                bad = [(f, have[k][f], r['after'][k][f])
                       for f in range(FIELDS) if have[k][f] != r['after'][k][f]]
                return None, None, (i + 1, 'place %d' % (4 + k), bad)
        if ate != r['ate']:
            return None, None, (i + 1, 'eaten %s' % r['ate'], 'eaten %s' % ate)
    return len(rows), chased, None


def main():
    args = [a for a in sys.argv[1:]]
    only = None
    for a in list(args):
        if a.startswith('--areas='):
            only = [tuple(int(x) for x in p.split(':'))
                    for p in a[8:].split(',')]
            args.remove(a)
    jobs = []
    bs = S.boss_stage()
    for area in range(12):
        jobs.append(('boss %d' % area, bs, area, True))
    for stage, area in V.areas_from_index():
        jobs.append(('%d:%d' % (stage, area), stage, area, False))
    if only is not None:
        jobs = [j for j in jobs if (j[1], j[2]) in only]
    script = [(2, '-')] + V.random_scripts(1, seed=11)[0][1][1:]
    tmp = tempfile.mkdtemp(prefix='orbit', dir=P.SCRATCH
                           if os.path.isdir(P.SCRATCH) else None)
    bad = 0
    steps = chased = 0
    try:
        for name, stage, area, boss in jobs:
            P.ROMPOKE = list(P.IMMORTAL)
            try:
                if boss:
                    n, ch, err = check(name, stage, area, script, tmp,
                                       None, P.IN_LEVEL + S.BOSS_WAIT,
                                       S.BOSS_POKES, True, S.boss_early(area))
                else:
                    spot = V.settled_spot(stage, area)
                    if spot is None:
                        print('%-10s skipped -- not played from a cold start'
                              % name)
                        continue
                    n, ch, err = check(name, stage, area, script, tmp, spot,
                                       P.IN_LEVEL)
            finally:
                P.ROMPOKE = []
            if err is not None:
                bad += 1
                print('%-10s DIFF at step %d\n    %s\n    %s'
                      % (name, err[0], err[1], err[2]))
            else:
                steps += n
                chased += ch
                print('%-10s ok   %d turns of the two, %d of them away from '
                      'the walk' % (name, n, ch))
        print('%d of %d areas differ, %d turns, %d away from the walk'
              % (bad, len(jobs), steps, chased))
    finally:
        P.sweep(tmp)
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
