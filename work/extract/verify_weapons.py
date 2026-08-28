#!/usr/bin/env python3
"""Э3.3 acceptance: what the hero throws must fly exactly as the cartridge's does.

The cartridge is played first and the whole table of things is written down
once a picture.  The engine is then given the same buttons, the same hero and
everything the weapon code reads but does not yet work out -- where he stands,
what the level declared solid, the suit, the blade's power -- and must answer
with the three places his throws take, field for field.  A single byte of
difference is a failure.

Damage is not judged here: a throw hurts what it touches in the sweep at
$CF08, which `verify_spawns.py` already drives with the shots handed to it.
What is on trial here is the flight.
"""
import json
import os
import random
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402
from pb2_map import Area                                     # noqa: E402

GODOT = V.GODOT
GAME = V.GAME
FRAMES = 600

# The names of the twenty-nine fields, so that a difference reads as something
# and not as a number between nought and twenty-eight.
FIELD = ['type', 'mark', 'bits', 'kind', 'anim', 'step', 'rec', 'life',
         'yhi', 'y', 'yfr', 'xhi', 'x', 'xfr', 'vy', 'vyfr', 'vx', 'vxfr',
         'state', 'hold', 'stun', 'self', 'count', 'keep', 'keep2', 'push',
         'ang', 'recb', 'ground']

# Scripts that throw: standing, walking, in the air, out of a crouch, hanging,
# aimed up and aimed down, and held for every one of the four charges.
SCRIPTS = [
    ('throw-still',   [(2, '-'), (30, 'B'), (34, '-')]),
    ('throw-held',    [(2, '-'), (30, 'B'), (60, '-')]),
    ('throw-walk',    [(2, '-'), (10, 'LEFT'), (30, 'LEFT,B'), (34, 'LEFT')]),
    ('throw-up',      [(2, '-'), (30, 'UP,B'), (34, '-')]),
    ('throw-up-side', [(2, '-'), (30, 'LEFT,UP,B'), (34, 'LEFT')]),
    ('throw-crouch',  [(2, '-'), (10, 'DOWN'), (30, 'DOWN,B'), (34, 'DOWN')]),
    ('throw-crouch-side',
                      [(2, '-'), (10, 'DOWN'), (30, 'LEFT,DOWN,B'),
                       (40, 'DOWN'), (60, '-')]),
    ('throw-jump',    [(2, '-'), (20, 'A'), (26, 'B'), (30, '-'), (60, '-')]),
    ('throw-jump-down',
                      [(2, '-'), (20, 'A'), (26, 'DOWN,B'), (30, '-')]),
    ('throw-jump-side',
                      [(2, '-'), (20, 'LEFT,A'), (26, 'LEFT,DOWN,B'),
                       (34, 'LEFT'), (60, '-')]),
    # Out of the crouch he is moved before he is asked to throw ($8F8C:
    # $A036 down, $A06D along, and only then $8FA2), so a crouch taken while
    # he still has speed left in him is the one script that tells a throw
    # thrown from where he was from a throw thrown from where he is.
    ('throw-crouch-moving',
                      [(2, '-'), (10, 'LEFT'), (30, 'LEFT,DOWN'),
                       (31, 'LEFT,DOWN,B'), (34, 'LEFT,DOWN'), (60, '-')]),
    ('throw-fast',    [(2, '-'), (10, 'B'), (12, '-'), (14, 'B'), (16, '-'),
                       (18, 'B'), (20, '-'), (40, 'B'), (42, '-')]),
    ('throw-turn',    [(2, '-'), (10, 'LEFT'), (20, 'RIGHT,B'), (24, 'RIGHT'),
                       (40, 'LEFT,B'), (44, 'LEFT')]),
]
# What a random script may press.  B is in it three times over: a run in which
# he never throws proves nothing.
BUTTONS = ['-', 'LEFT', 'RIGHT', 'A', 'LEFT,A', 'RIGHT,A', 'DOWN', 'UP',
           'B', 'B', 'B', 'LEFT,B', 'RIGHT,B', 'UP,B', 'DOWN,B',
           'LEFT,DOWN', 'LEFT,DOWN,B', 'A,B', 'LEFT,A,B']


# What he cannot have this early in the game, poked into place before he takes
# control: $9A which suit he wears and $56 which suits he owns, $55 how far the
# blade has been raised, $A2 which of the two blades it is, $99 how many throws
# may be in the air beyond the first.  Without these only the bare blade at its
# lowest power is ever thrown, and the suit's beam is never thrown at all.
# The four marks of the blade's power, which $D8F1 copies into $8C..$8F when
# it is raised.  Raising it behind the game's back means copying them too, or
# the ceiling would be the new power's and the three marks the old one's.
MARKS = [(0x04, 0x01, 0x02, 0x03), (0x08, 0x02, 0x04, 0x07),
         (0x0C, 0x04, 0x08, 0x0B), (0x10, 0x06, 0x0C, 0x0F)]


def raised(n):
    """The pokes that raise the blade to `n`, marks and all."""
    return ((0x55, n),) + tuple((0x8C + i, MARKS[n][i]) for i in range(4))


GEAR = [
    ('plain',   ()),
    ('power-1', raised(1)),
    ('power-2', raised(2)),
    ('power-3', raised(3)),
    ('blade-2', ((0xA2, 1),) + raised(2)),
    ('many',    ((0x99, 2),) + raised(3)),
    ('suit-1',  ((0x9A, 1), (0x56, 0x0F))),
    ('suit-2',  ((0x9A, 2), (0x56, 0x0F))),
    ('suit-3',  ((0x9A, 3), (0x56, 0x0F))),
    ('suit-4',  ((0x9A, 4), (0x56, 0x0F))),
    ('suit-4-power-3',
     ((0x9A, 4), (0x56, 0x0F), (0x99, 2)) + raised(3)),
]


def random_scripts(n, seed=7):
    rnd = random.Random(seed)
    out = []
    for i in range(n):
        script = [(2, '-')]
        f = 10
        while f < FRAMES - 10:
            script.append((f, rnd.choice(BUTTONS)))
            f += rnd.randint(2, 24)
        out.append(('random-%02d' % i, script))
    return out


def cfg_for(rows):
    """The script the engine is given: `verify_player`'s, and with it the
    table of things once a picture and the four bytes the weapon code reads."""
    cfg = V.replay(rows)
    cfg['charge'] = rows[0]['held_b']
    frames = []
    for line, r in zip(cfg['frames'], rows[1:]):
        frames.append(dict(line,
                           whole=r['whole'], clocks=r['ticks'],
                           turns=r['turns'], seeds=r['seeds'],
                           suits=r['suits'], waters=r['waters'],
                           helds=r['helds'], draws=r['draws'],
                           cams=r['cams'],
                           power=r['power'], second=r['second']))
    cfg['frames'] = frames
    return cfg


def run_engine(cfg, path):
    open(path, 'w').write(json.dumps(cfg))
    try:
        r = subprocess.run([GODOT, '--path', GAME, '--headless', '--',
                            '--weapon=' + path], capture_output=True,
                           text=True, timeout=V.ENGINE_WAIT)
    except subprocess.TimeoutExpired:
        sys.stderr.write('the engine never stopped\n')
        return None
    out = []
    for line in r.stdout.split('\n'):
        f = line.strip().split(' ', 1)
        if len(f) == 2 and f[0].isdigit():
            out.append((int(f[0]), [] if f[1] == '-' else f[1].split()))
    if not out:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
        return None
    return out


def show(where, told):
    """One difference, in words."""
    slot, field, mine, theirs = (int(x) for x in told.split(':'))
    return '    step %d  slot %d  %-6s engine %3d  cartridge %3d' % (
        where, slot, FIELD[field], mine, theirs)


def check(name, script, stage, area, tmp, spot=None, pokes=()):
    rows = V.logic_frames(V.ordinary(pb2_trace.trace(
        script, FRAMES, stage=stage, area=area, spot=spot, pokes=pokes)))
    rows = rows[:-1]
    # The first line of a recording is a mixture and cannot be the starting
    # point.  A watch log says only what changed, so the run's starting memory
    # is read out separately -- and one picture late.  An address written every
    # picture is put right at once; $54, written once in four, keeps the wrong
    # value.  From the second line on everything is the cartridge's own.
    rows = rows[1:]
    if spot is not None:
        rows = rows[V.SETTLE:]
    if len(rows) < 4:
        return 0, 0, None
    got = run_engine(cfg_for(rows), os.path.join(tmp, 'w.json'))
    if got is None:
        return None, 0, ('the engine said nothing', [])
    # How many steps had a throw of his in the air at all: a run of nothing but
    # empty places agrees with the cartridge and proves nothing.
    live = 0
    for i, r in enumerate(rows[1:]):
        if i >= len(got):
            break
        if any(w[n][0] for w in r['whole'] for n in (1, 2, 3)):
            live += 1
        charge, bad = got[i]
        if charge != r['held_b']:
            return None, live, ("the button's count parted",
                                ['    step %d  engine %d  cartridge %d'
                                 % (i + 1, charge, r['held_b'])])
        if bad:
            return None, live, ('a throw parted from the cartridge',
                                [show(i + 1, b) for b in bad[:8]])
    return len(got), live, None


def main():
    n_random = 0
    targets = [(0, 0)]
    seed = 7
    for a in sys.argv[1:]:
        if a.startswith('--random='):
            n_random = int(a.split('=')[1])
        elif a.startswith('--seed='):
            seed = int(a.split('=')[1])
        elif a == '--all-areas':
            targets = V.areas_from_index()
        elif a.startswith('--areas='):
            targets = [tuple(int(x) for x in p.split(':'))
                       for p in a.split('=')[1].split(',')]
    tmp = pb2_trace.P.scratch('weapons')
    ran = bad = live = 0
    for stage, area in targets:
        scripts = list(SCRIPTS) if targets == [(0, 0)] else []
        scripts += random_scripts(n_random, seed + 31 * (stage * 16 + area))
        spot = None
        if targets != [(0, 0)]:
            spot = V.settled_spot(stage, area)
            if spot is None:
                print('%d:%d  not played out of turn -- left out'
                      % (stage, area))
                continue
        for gear, pokes in (GEAR if targets == [(0, 0)] else GEAR[:1]):
            for name, script in scripts:
                tag = '%s/%s' % (gear, name)
                steps, seen, why = check(name, script, stage, area, tmp, spot,
                                         pokes)
                ran += 1
                live += seen
                if why is not None:
                    bad += 1
                    print('%d:%d %-30s FAILED -- %s'
                          % (stage, area, tag, why[0]))
                    for line in why[1]:
                        print(line)
                else:
                    print('%d:%d %-30s ok   %d steps, %d with a throw in the '
                          'air' % (stage, area, tag, steps, seen))
    print('%d of %d scripts differ; %d steps had a throw in the air'
          % (bad, ran, live))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
