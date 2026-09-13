#!/usr/bin/env python3
"""Э4.2 acceptance: who gets into Solbrain's sixteen slots, and where.

The hero is stood in a stage and walked about; the cartridge is asked, every
picture, which spawn id sits in each of the sixteen slots and at what place.
The engine is stood in the same spot with the same buttons and must answer the
same numbers.

Only the slots themselves are on trial here, not what the things in them do.
A thing moves on the very picture it is born on -- the pool walk $CE1D runs
after the scan $AE69 in the same frame -- so its place is already its own
business by the time anyone can look at it.  What is held here is the sixteen
spawn ids, picture by picture: when a thing is let in, from which side, into
which slot, and when it is taken away again.  Where it then goes is Э4.3.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import sol_probe as P                                            # noqa: E402
import verify_sol_player as V                                    # noqa: E402

GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'
GAME = os.path.join(ROOT, 'game')

SLOTS = 16
SHOTS = 16
MARKS = 64
LEN = 40                  # short: nothing in the pool has started to move yet

R, L, D, U, A, B = 0x01, 0x02, 0x04, 0x08, 0x80, 0x40


def hold(n, pad):
    return [pad] * n


# Walks that carry the view about, because the view is what lets things in.
SCRIPTS = {
    'still':     hold(LEN, 0),
    'right':     hold(LEN, R),
    'left':      hold(LEN, L),
    'right far': hold(LEN * 3, R),
    'left far':  hold(LEN * 3, L),
    'there and back': hold(LEN, R) + hold(LEN * 2, L),
    'jump right': hold(10, R) + hold(8, R | A) + hold(LEN - 18, R),
}

# Stages picked for what they hold: the first, one that scrolls down, and a
# couple whose rooms are crowded.
PLACES = [('s0', 0), ('s1', 1), ('s2', 2), ('s3', 3), ('s5', 5), ('s9', 9)]

POOL = [0x0600 + i for i in range(SLOTS)]
POS = ([0xA0 + i for i in range(SLOTS)] + [0xB0 + i for i in range(SLOTS)]
       + [0xC0 + i for i in range(SLOTS)] + [0xD0 + i for i in range(SLOTS)])


def ids(rows):
    """Just who is in each slot; where they have got to is not on trial.

    The top two bits of the slot are not the spawn id: a behaviour may raise
    bit 6 to say "do not take me away yet" ($9050 in bank 2 does), and the
    behaviours are Э4.3.  They are masked off here so that this stand answers
    only its own question.
    """
    return [tuple(r[s][0] & 0x3F for s in range(SLOTS)) for r in rows]


# $0C counts pictures; $0E is the hash of RAM that $CD57 stirs, and until that
# is ported the engine is handed the cartridge's own.
TICKS = [0x0C, 0x0E, 0x06, 0x7F, 0x58, 0x04]
FIELDS = [0x0650, 0x0690, 0x0660, 0x0670]


def cartridge(state, pads, base, full=False, pokes=()):
    script = V.cartridge_script(pads, base)
    addrs = set(POOL) | set(POS) | set(TICKS)
    if full:
        addrs |= {p + i for p in FIELDS for i in range(SLOTS)}
    rows = P.watched(state, script, base, base + len(pads), addrs,
                     pokes=pokes)
    out = []
    ticks = []
    for _fr, c in rows[:-1]:
        ticks.append((c[0x0C], c[0x0E], c[0x06], c[0x7F], c[0x58], c[0x04]))
        if full:
            out.append(tuple(
                (c[0x0600 + i], c[0xA0 + i] | c[0xB0 + i] << 8,
                 c[0xC0 + i] | c[0xD0 + i] << 8,
                 c[0x0650 + i], c[0x0690 + i], c[0x0660 + i], c[0x0670 + i])
                for i in range(SLOTS)))
        else:
            out.append(tuple(
                (c[0x0600 + i], c[0xA0 + i] | c[0xB0 + i] << 8,
                 c[0xC0 + i] | c[0xD0 + i] << 8)
                for i in range(SLOTS)))
    return out, ticks


def finished(ticks, n):
    """Which of the emulator's pictures hold a whole one of the game's own.

    The game does not always fit a picture into the frame it began in: $0C
    stays where it was and the rest of the walk over the pool is finished in
    the next frame.  Only the last frame of such a run holds a state worth
    comparing; the ones before it are caught halfway.
    """
    out = []
    for i in range(n):
        out.append(i + 1 >= len(ticks) or ticks[i][0] != ticks[i + 1][0])
    return out


def engine(cfg, scratch):
    path = os.path.join(scratch, 'obj.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([GODOT, '--path', GAME, '--headless', '--',
                        '--solobj=%s' % path],
                       capture_output=True, text=True, timeout=600)
    rows = []
    for line in r.stdout.split('\n'):
        f = line.split()
        if len(f) != SLOTS or not all(t.count(',') == 6 for t in f):
            continue
        rows.append(tuple(tuple(int(v) for v in t.split(',')) for t in f))
    if not rows:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return rows


def seed(base):
    """The pool, the view and the scroll bookkeeping as the cartridge has them."""
    cfg = V.snapshot(base)
    cfg['cam_x'] = base[0x30] | base[0x31] << 8
    cfg['cam_y'] = base[0x32] | base[0x33] << 8
    cfg['born_wait'] = base[0x05C3]
    cfg['ride_fall'] = base[0x34]
    cfg['vx'] = V.s16(base[0x05B6], base[0x05B7])
    cfg['vy'] = V.s16(base[0x05B8], base[0x05B9])
    cfg['due'] = base[0x05EC]
    cfg['col_due'] = base[0x37]
    cfg['row_due'] = base[0x36]
    cfg['seen_x'] = base[0x05E0] | base[0x05E1] << 8
    cfg['seen_y'] = base[0x05E2] | base[0x05E3] << 8
    cfg['room'] = base[0x05EB]
    cfg['stage'] = base[0x55]
    cfg['z75'] = base[0x75]
    cfg['z7c'] = base[0x7C]
    cfg['z58'] = base[0x58]
    cfg['z26'] = base[0x26]
    # $0399 -- the first of the three numbers of the tile set the screen is
    # next owed.  $B966 is the only thing that reads it back, and it does so to
    # ask whether the world is already the other way up.
    cfg['z399'] = base[0x0399]
    cfg['letters'] = base[0x05C4]
    cfg['z5ab'] = base[0x05AB]
    cfg['z5fa'] = base[0x05FA]
    # Э4.14 -- what the game is to be put to next, and the colour the shimmer
    # of the shield walks.
    cfg['zf8'] = base[0x00F8]
    cfg['z0112'] = base[0x0112]
    cfg['bonus'] = base[0x05C6] | base[0x05C7] << 8
    cfg['mark'] = [base[0x0560 + i] for i in range(MARKS)]
    # The sixteen shots.  Э4.2 does not read them either, but a shot can reach
    # the hero on the very first picture, so the seed carries them too.
    cfg['skind'] = [base[0x0780 + i] for i in range(SHOTS)]
    cfg['sx'] = [base[0x0790 + i] | base[0x07A0 + i] << 8 for i in range(SHOTS)]
    cfg['sy'] = [base[0x07B0 + i] | base[0x07C0 + i] << 8 for i in range(SHOTS)]
    cfg['sa'] = [base[0x07D0 + i] for i in range(SHOTS)]
    cfg['sb'] = [base[0x07E0 + i] for i in range(SHOTS)]
    cfg['slife'] = [base[0x07F0 + i] for i in range(SHOTS)]
    # And the third pool, the one the satellite throws into.  Nothing puts
    # anything in it until the satellite is ported, so in every stand but its
    # own it is sixteen empty slots.
    cfg['wkind'] = [base[0x0700 + i] for i in range(SLOTS)]
    cfg['wx'] = [base[0x0710 + i] | base[0x0720 + i] << 8 for i in range(SLOTS)]
    cfg['wy'] = [base[0x0730 + i] | base[0x0740 + i] << 8 for i in range(SLOTS)]
    cfg['wvx'] = [base[0x0750 + i] for i in range(SLOTS)]
    cfg['wvy'] = [base[0x0760 + i] for i in range(SLOTS)]
    cfg['wpen'] = [base[0x0770 + i] for i in range(SLOTS)]
    cfg['id'] = [base[0x0600 + i] for i in range(SLOTS)]
    cfg['ox'] = [base[0xA0 + i] | base[0xB0 + i] << 8 for i in range(SLOTS)]
    cfg['oy'] = [base[0xC0 + i] | base[0xD0 + i] << 8 for i in range(SLOTS)]
    # The rest of the slot: what it thinks, what it wears and where its walk
    # has got to.  Э4.2 does not read any of it, but the stand seeds the whole
    # pool so that Э4.3 can lean on the same seed.
    for name, page in (('omind', 0x0650), ('okind', 0x0690),
                       ('opic_lo', 0x0660), ('opic_hi', 0x0670),
                       ('oa', 0x0610), ('ob', 0x0620), ('oc', 0x0630),
                       ('od', 0x0640), ('oface', 0x0680),
                       ('oanim_a', 0x06A0), ('oanim_b', 0x06B0),
                       ('oleft', 0x06C0), ('oframe', 0x06D0),
                       ('ocool', 0x06E0), ('olife', 0x06F0)):
        cfg[name] = [base[page + i] for i in range(SLOTS)]
    return cfg


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    scratch = P.scratch('spawns')
    try:
        bad = total = 0
        for label, stage in PLACES:
            if places and label not in places:
                continue
            first = V.BASE if stage == 0 else P.WARP_IN
            play = first + 1
            state = V.stand(scratch, label, stage, None)
            cfg0 = seed(P.ram(state, [(first, '-')], first))
            for name, pads in sorted(SCRIPTS.items()):
                if only and name not in only:
                    continue
                total += 1
                rows, ticks = cartridge(state, pads, play)
                want = ids(rows)
                cfg = dict(cfg0)
                cfg['pads'] = pads
                cfg['clock_at'] = [t[0] for t in ticks]
                cfg['noise_at'] = [t[1] for t in ticks]
                cfg['six_at'] = [t[2] for t in ticks]
                cfg['step_at'] = [t[3] for t in ticks]
                cfg['ride_at'] = [t[4] for t in ticks]
                cfg['new_at'] = [t[5] for t in ticks]
                got = ids(engine(cfg, scratch))
                n = min(len(want), len(got))
                done = finished(ticks, n)
                where = None
                for i in range(n):
                    if done[i] and want[i] != got[i]:
                        where = i
                        break
                if where is None and len(want) != len(got):
                    where = n
                if where is None:
                    print('%-6s %-15s ok, %d frames' % (label, name, n))
                    continue
                bad += 1
                print('%-6s %-15s differs on frame %d' % (label, name, where))
                if where < n:
                    for s in range(SLOTS):
                        if want[where][s] != got[where][s]:
                            print('    slot %2d  cartridge %3d   engine %3d'
                                  % (s, want[where][s], got[where][s]))
                else:
                    print('    cartridge %d frames, engine %d'
                          % (len(want), len(got)))
                sys.stdout.flush()
        print('%d of %d scripts differ' % (bad, total))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
