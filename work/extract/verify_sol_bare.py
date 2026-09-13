#!/usr/bin/env python3
"""Э4.14 acceptance: a hero with no suit on, and the shimmer of the shield.

Two pieces of him were read long ago and left unported, and both are here.

* The suitless branch of `$937A` ($9384).  With `$05C5` at nought he is not
  drawn out of his animation at all: three fixed pictures stand for him, and
  the last of the three is where the game finishes him off for good --
  `$05AB`, `$05A2`, `$F8` and his satellite's own slot are all written there.
* The shimmer, the first half of `$9689`.  With a shield up, and in a state
  that does not put it out ($96EA), the third colour of the sprites' first
  set walks `$15 $24 $05 $24` every other picture.

On a settled picture the state byte is written by hand, together with the two
bytes on trial, and both sides are then let run.  Compared are the hero's
sixteen numbers, his own four slots, and the two bytes that live nowhere else:
`$F8` and `$0112`.
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
import verify_sol_states as T                                    # noqa: E402

LEN = T.LEN
AT = T.AT
STATES = T.STATES
NAMES = T.NAMES
SLOT_NAMES = T.SLOT_NAMES
FIRST, LAST = T.FIRST, T.LAST
ODD = ('F8', '0112', '56', '05C6', '05C5', '05C8', '071C')

# What is written by hand on picture AT, beside the state itself.  The shield
# is put up in every case: with no suit on it is what keeps him alive, and
# $96EA is the whole point of the second piece.
CASES = (
    ('no suit', ((0x05C5, 0x00), (0x05C8, 0x01))),
    ('a suit on', ((0x05C8, 0x01),)),
)
# And two the states alone do not reach: being hit with no suit on, and the
# picture he is finished off in.
CORNERS = (
    ('hit, free to move', ((0x05A2, 0x01), (0x05AF, 0x00), (0x05A3, 0x20),
                           (0x05C5, 0x00), (0x05C8, 0x01))),
    ('finished off', ((0x05A2, 0x00), (0x05A3, 0xFF),
                      (0x05C5, 0x00), (0x05C8, 0x01))),
)


def cartridge(state, pads, base, pokes):
    """The hero, his four slots and the two odd bytes, picture by picture."""
    script = V.cartridge_script(pads, base)
    addrs = set(S.TICKS) | set(T.ONE) | {0x26, 0x02, 0x00F8, 0x0112, 0x56,
                                            0x05C6, 0x05C7, 0x05C5, 0x05C8,
                                            0x071C}
    for lo, hi in T.HERE_AT.values():
        addrs |= {lo, hi}
    for p in (0xA0, 0xB0, 0xC0, 0xD0):
        addrs |= {p + i for i in range(FIRST, LAST + 1)}
    for p in T.SLOT_AT:
        addrs |= {p + i for i in range(FIRST, LAST + 1)}
    rows = P.watched(state, script, base, base + len(pads), addrs, pokes=pokes)
    hero, hands, odds, ticks = [], [], [], []
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
        odds.append((c[0x00F8], c[0x0112], c[0x56],
                     c[0x05C6] | c[0x05C7] << 8, c[0x05C5], c[0x05C8],
                     c[0x071C]))
    return hero, hands, odds, ticks


def engine(cfg, scratch):
    path = os.path.join(scratch, 'obj.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([S.GODOT, '--path', S.GAME, '--headless', '--',
                        '--solobj=%s' % path],
                       capture_output=True, text=True, timeout=900)
    hero, hands, odds = [], [], []
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
            continue
        if line.startswith('Y '):
            f = line[2:].split()
            if len(f) == len(ODD):
                odds.append(tuple(int(v) for v in f))
    if not hero:
        sys.stderr.write(r.stdout[-2000:] + r.stderr[-2000:])
    return hero, hands, odds


def one(scratch, label, state, cfg0, name, put):
    """One poking, both sides, and where they first part."""
    pads = S.hold(LEN, 0x00)
    first = V.BASE if int(label[1:]) == 0 else P.WARP_IN
    play = first + 1
    pk = [(a, v, play + AT) for a, v in put]
    wh, wd, wo, tk = cartridge(state, pads, play, pk)
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
    gh, gd, go = engine(cfg, scratch)
    n = min(len(wh), len(wd), len(wo), len(gh), len(gd), len(go))
    # $02 is which screen the game is showing: past the picture it changes on
    # the cartridge is not playing the same picture at all, and the flow is
    # another stand's.
    for i in range(n):
        if tk[i][7] != tk[0][7]:
            n = i + 1
            break
    fin = S.finished(tk, n)
    for i in range(n):
        if not fin[i]:
            continue
        if wh[i] != gh[i]:
            return n, i, 'hero', wh[i], gh[i]
        if wd[i] != gd[i]:
            return n, i, 'slots', wd[i], gd[i]
        if wo[i] != go[i]:
            return n, i, 'odds', wo[i], go[i]
    return n, None, None, None, None


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    labels = places or ['s0', 's3']
    scratch = P.scratch('bare')
    try:
        bad = total = 0
        for label in labels:
            stage = int(label[1:])
            first = V.BASE if stage == 0 else P.WARP_IN
            state = V.stand(scratch, label, stage, None)
            cfg0 = S.seed(P.ram(state, [(first, '-')], first))
            runs = [('%s $%02X' % (nm, m), put + ((0x05A2, m),))
                    for nm, put in CASES for m in range(STATES)]
            runs += list(CORNERS)
            for name, put in runs:
                if only and not any(o in name for o in only):
                    continue
                total += 1
                n, where, kind, w, g = one(scratch, label, state, cfg0,
                                           name, put)
                if where is None:
                    print('%-4s %-16s ok, %d pictures' % (label, name, n))
                    sys.stdout.flush()
                    continue
                bad += 1
                print('%-4s %-16s %s differs on picture %d'
                      % (label, name, kind, where))
                if kind == 'hero':
                    for k, nm in enumerate(NAMES):
                        if w[k] != g[k]:
                            print('    %-8s cartridge %6d   engine %6d'
                                  % (nm, w[k], g[k]))
                elif kind == 'odds':
                    for k, nm in enumerate(ODD):
                        if w[k] != g[k]:
                            print('    $%-7s cartridge %6d   engine %6d'
                                  % (nm, w[k], g[k]))
                else:
                    for j in range(LAST - FIRST + 1):
                        if w[j] == g[j]:
                            continue
                        for k, nm in enumerate(SLOT_NAMES):
                            if w[j][k] != g[j][k]:
                                print('    slot %2d %-6s cartridge %6d'
                                      '   engine %6d'
                                      % (FIRST + j, nm, w[j][k], g[j][k]))
                sys.stdout.flush()
        print('%d of %d pokings of a suitless hero differ' % (bad, total))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
