#!/usr/bin/env python3
"""Э4.5 acceptance: every one of the hero's twenty one states, one at a time.

`verify_sol_player.py` plays buttons at him, so it meets only the states the
first seconds of a stage can reach: standing, the air, landing, ducking.  The
other seventeen -- the wire, the doors, dying, the two rides -- are never
reached that way at all, so this stand asks for them by name.

On a settled picture the state byte $05A2 is written by hand and both sides are
then let run.  The cartridge and the engine must answer the same sixteen
numbers of the hero for every picture, and the same four slots $0C..$0F, which
are the ones his own machinery (the satellite, and the wire) lives in.
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
import verify_sol_spawns as S                                    # noqa: E402
import verify_sol_shots as H                                     # noqa: E402

SLOTS = S.SLOTS
SHOTS = S.SHOTS
FIRST, LAST = 0x0C, 0x0F  # the four slots the hero's own machinery keeps
LEN = 90
AT = 40                   # a settled picture, well past the door
STATES = 0x15             # $96C0 holds twenty one pointers

# The sixteen numbers of the hero, in the order main.gd prints them.
NAMES = ('x', 'y', 'vx', 'vy', 'state', 'speed', 'pose', 'scripted',
         'step_t', 'step_i', 'pic_lo', 'pic_hi', 'anim', 'face', 'timer',
         'fuel')
HERE_AT = {'x': (0x80, 0x81), 'y': (0x82, 0x83),
           'vx': (0x05B6, 0x05B7), 'vy': (0x05B8, 0x05B9)}
ONE = [0x05A2, 0x35, 0x05B5, 0x05A5, 0x05A4, 0x05B4, 0x05A6, 0x05A7,
       0x05CE, 0x05B2, 0x05A3, 0x05AF]

# The eighteen numbers of one of his four slots, as main.gd prints them.
SLOT_NAMES = ('id', 'x', 'y', 'mind', 'kind', 'a', 'b', 'c', 'd', 'face',
              'anim_a', 'anim_b', 'left', 'frame', 'cool', 'life',
              'pic_lo', 'pic_hi')
SLOT_AT = [0x0600, 0x0610, 0x0620, 0x0630, 0x0640, 0x0650, 0x0660, 0x0670,
           0x0680, 0x0690, 0x06A0, 0x06B0, 0x06C0, 0x06D0, 0x06E0, 0x06F0]

SCRIPTED = {'s19'}


def cartridge(state, pads, base, pokes):
    """The hero and his four slots, picture by picture."""
    script = V.cartridge_script(pads, base)
    addrs = set(S.TICKS) | set(ONE) | {0x26, 0x02}
    for lo, hi in HERE_AT.values():
        addrs |= {lo, hi}
    for p in (0xA0, 0xB0, 0xC0, 0xD0):
        addrs |= {p + i for i in range(FIRST, LAST + 1)}
    for p in SLOT_AT:
        addrs |= {p + i for i in range(FIRST, LAST + 1)}
    rows = P.watched(state, script, base, base + len(pads), addrs, pokes=pokes)
    hero, hands, ticks = [], [], []
    for _fr, c in rows[:-1]:
        ticks.append((c[0x0C], c[0x0E], c[0x06], c[0x7F], c[0x58], c[0x04],
                      c[0x26], c[0x02]))
        hero.append((c[0x80] | c[0x81] << 8, c[0x82] | c[0x83] << 8,
                     V.s16(c[0x05B6], c[0x05B7]), V.s16(c[0x05B8], c[0x05B9]),
                     c[0x05A2], V.sbyte(c[0x35]), c[0x05B5], c[0x05A5],
                     c[0x05A4], c[0x05B4], c[0x05A6], c[0x05A7], c[0x05CE],
                     c[0x05B2], c[0x05A3], c[0x05AF]))
        hands.append(tuple(
            (c[0x0600 + i], c[0xA0 + i] | c[0xB0 + i] << 8,
             c[0xC0 + i] | c[0xD0 + i] << 8,
             c[0x0650 + i], c[0x0690 + i], c[0x0610 + i], c[0x0620 + i],
             c[0x0630 + i], c[0x0640 + i], c[0x0680 + i], c[0x06A0 + i],
             c[0x06B0 + i], c[0x06C0 + i], c[0x06D0 + i], c[0x06E0 + i],
             c[0x06F0 + i], c[0x0660 + i], c[0x0670 + i])
            for i in range(FIRST, LAST + 1)))
    return hero, hands, ticks


def engine(cfg, scratch):
    path = os.path.join(scratch, 'obj.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([S.GODOT, '--path', S.GAME, '--headless', '--',
                        '--solobj=%s' % path],
                       capture_output=True, text=True, timeout=900)
    hero, hands = [], []
    for line in r.stdout.split('\n'):
        if line.startswith('P '):
            f = line[2:].split(',')
            if len(f) == len(NAMES):
                hero.append(tuple(int(v) for v in f))
            continue
        if line.startswith('H '):
            f = line[2:].split()
            if len(f) == LAST - FIRST + 1 and all(t.count(',') == 17
                                                  for t in f):
                hands.append(tuple(tuple(int(v) for v in t.split(','))
                                   for t in f))
    if not hero:
        sys.stderr.write(r.stdout[-2000:] + r.stderr[-2000:])
    return hero, hands


def main():
    only = [int(a, 0) for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    labels = places or ['s%d' % n for n in range(20) if n != 19]
    pads = S.hold(LEN, 0x00)
    scratch = P.scratch('states')
    try:
        bad = total = known = 0
        for label in labels:
            stage = int(label[1:])
            first = V.BASE if stage == 0 else P.WARP_IN
            play = first + 1
            state = V.stand(scratch, label, stage, None)
            cfg0 = S.seed(P.ram(state, [(first, '-')], first))
            print('%-6s asking for each of the %d states from frame %d'
                  % (label, STATES, AT))
            sys.stdout.flush()
            for m in range(STATES):
                if only and m not in only:
                    continue
                total += 1
                put = [(0x05A2, m)]
                pk = [(a, v, play + AT) for a, v in put]
                wh, wd, tk = cartridge(state, pads, play, pk)
                cfg = dict(cfg0)
                cfg['pads'] = pads
                cfg['kill_at'] = AT
                cfg['hero_put'] = [[a, v] for a, v in put]
                cfg['clock_at'] = [t[0] for t in tk]
                cfg['noise_at'] = [t[1] for t in tk]
                cfg['six_at'] = [t[2] for t in tk]
                cfg['step_at'] = [t[3] for t in tk]
                cfg['ride_at'] = [t[4] for t in tk]
                cfg['new_at'] = [t[5] for t in tk]
                owed = [t[6] for t in tk]
                cfg['owed_at'] = owed[:1] + owed[:-1]
                gh, gd = engine(cfg, scratch)
                n = min(len(wh), len(wd), len(gh), len(gd))
                # $02 is which screen the game is showing.  Two of the states
                # end by handing the game on -- dying goes to the try that
                # follows, the ride out goes to the next stage -- and past that
                # point the cartridge is not playing the same picture at all.
                # The stage flow is Э4.5's, so the comparison stops there.
                # The picture the byte changes on is still his own -- the
                # game only reads it back at the top of the next one -- so it
                # is the one after that the comparison stops at.
                for i in range(n):
                    if tk[i][7] != tk[0][7]:
                        n = i + 1
                        break
                fin = S.finished(tk, n)
                where = kind = None
                for i in range(n):
                    if not fin[i]:
                        continue
                    if wh[i] != gh[i]:
                        where, kind = i, 'hero'
                        break
                    if wd[i] != gd[i]:
                        where, kind = i, 'slots'
                        break
                name = 'state $%02X' % m
                if where is None:
                    print('%-6s %-11s ok, %d frames' % (label, name, n))
                    sys.stdout.flush()
                    continue
                if label in SCRIPTED:
                    known += 1
                    print('%-6s %-11s %s differs on frame %d'
                          ' -- the stage has a script of its own'
                          % (label, name, kind, where))
                    sys.stdout.flush()
                    continue
                bad += 1
                print('%-6s %-11s %s differs on frame %d'
                      % (label, name, kind, where))
                if kind == 'hero':
                    for k, nm in enumerate(NAMES):
                        if wh[where][k] != gh[where][k]:
                            print('    %-8s cartridge %6d   engine %6d'
                                  % (nm, wh[where][k], gh[where][k]))
                else:
                    for j in range(LAST - FIRST + 1):
                        if wd[where][j] == gd[where][j]:
                            continue
                        for k, nm in enumerate(SLOT_NAMES):
                            if wd[where][j][k] != gd[where][j][k]:
                                print('    slot %2d %-6s cartridge %6d'
                                      '   engine %6d'
                                      % (FIRST + j, nm, wd[where][j][k],
                                         gd[where][j][k]))
                sys.stdout.flush()
            if not places:
                break
        print('%d of %d states differ, %d more only where stage twenty writes'
              ' the pool itself' % (bad, total, known))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
