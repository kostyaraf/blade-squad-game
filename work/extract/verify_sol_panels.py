#!/usr/bin/env python3
"""Э4.15 acceptance: the panels a stage keeps, and what ducking on one buys.

The four panels are tiles set into the floor ($9D6E, four a stage), and the
hero buys from one by ducking on it: a shield for ten, the suit filled for
thirty, a try for two hundred, and a fourth that is whichever of those three
the stage names.  Using one up breaks the two places under his feet open and
hatches the puff of it between them.

So the stand finds every cell of a stage whose metatile is one of its four,
stands him on one, holds the button down, and asks both sides for the same
four things picture by picture: the sixteen slots of the pool, the thirty two
bytes of the broken mark, the hero's own sixteen numbers, and the seven that
a panel buys with and into ($56, the bonus, the suit, the shield, the tries).

Both sides are poked the same way on picture four: what a panel is paid with
is the bonus he has not been counted yet ($05C6:$05C7), and a stage raised by
the warp has none of it.  Each place is entered three ways -- with the money,
a point short of it, and with the thing already full.
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
import verify_sol_bare as B                                      # noqa: E402

SLOTS = S.SLOTS
MARK, MARKS = 0x0540, 32
LEN = 120                 # long enough for the suit to fill and be paid for
AT = 4                    # a settled picture, by which he is already ducking
LOOK = 8                  # frames looked at for a whole picture to seed from
DOWN = 0x04
NAMES = B.NAMES
ODD = B.ODD

PANELS = json.load(open(os.path.join(ROOT, 'game', 'data', 'sol',
                                     'panels.json')))
KINDS = ('shield', 'suit', 'try', 'gift')

# What each case is entered with: enough to buy, not enough to buy, and the
# thing already full.  $05C5 is the suit, $05C8 the shield.
MONEY = 0x03FF


def grid(stage):
    """Every cell of a stage, by (mx, my), the way $D09C reads one."""
    path = os.path.join(ROOT, 'game', 'data', 'sol', 'levels',
                        'stage%d.json' % stage)
    s = json.load(open(path))
    rooms, screens, blocks = s['rooms'], s['screens'], s['blocks']
    g = {}
    for ry in range(16):
        for rx in range(16):
            scr = rooms[ry][rx]
            if scr is None or scr >= len(screens):
                continue
            for br in range(8):
                for bc in range(8):
                    blk = blocks[screens[scr][br][bc]]
                    for hx in range(2):
                        for hy in range(2):
                            g[(rx * 16 + bc * 2 + hx,
                               ry * 16 + br * 2 + hy)] = blk[hx * 2 + hy]
    return g, s['props']


def spots(stage, want=2):
    """Where in a stage he can stand on each of its four panels."""
    g, props = grid(stage)

    def solid(c):
        m = g.get(c)
        return m is not None and (props[m] & 0x1F) & 0x10

    out = []
    for kind, tile in enumerate(PANELS['tiles'][stage]):
        if tile in (0x00, 0xFF):
            continue
        found = []
        for (mx, my), m in sorted(g.items()):
            if (m & 0xFE) != (tile & 0xFE):
                continue
            if not solid((mx, my)):
                continue
            # He is set down one cell above the panel and falls onto it.  A
            # panel with more of the same over it is still worth standing on:
            # on the stage that is all water nothing stops him from above at
            # all ($A26E), so he simply stands inside it.
            found.append((mx, my - 1))
            if len(found) >= want:
                break
        for spot in found:
            out.append((kind, spot))
    return out


def cartridge(state, pads, base, pokes):
    """The pool, the mark, the hero and the seven, picture by picture."""
    script = V.cartridge_script(pads, base)
    addrs = set(S.POOL) | set(S.POS) | set(S.TICKS) | set(B.T.ONE)
    addrs |= {p + i for p in S.FIELDS for i in range(SLOTS)}
    addrs |= {MARK + i for i in range(MARKS)}
    addrs |= {0x26, 0x02, 0x00F8, 0x0112, 0x56, 0x05C6, 0x05C7, 0x05C5,
              0x05C8, 0x071C, 0x80, 0x81, 0x82, 0x83, 0x05B6, 0x05B7,
              0x05B8, 0x05B9}
    rows = P.watched(state, script, base, base + len(pads), addrs, pokes=pokes)
    out, mark, hero, odds, ticks = [], [], [], [], []
    for _fr, c in rows[:-1]:
        ticks.append((c[0x0C], c[0x0E], c[0x06], c[0x7F], c[0x58], c[0x04],
                      c[0x26], c[0x02]))
        out.append(tuple(
            (c[0x0600 + i], c[0xA0 + i] | c[0xB0 + i] << 8,
             c[0xC0 + i] | c[0xD0 + i] << 8,
             c[0x0650 + i], c[0x0690 + i], c[0x0660 + i], c[0x0670 + i])
            for i in range(SLOTS)))
        mark.append(tuple(c[MARK + i] for i in range(MARKS)))
        hero.append((c[0x80] | c[0x81] << 8, c[0x82] | c[0x83] << 8,
                     V.s16(c[0x05B6], c[0x05B7]), V.s16(c[0x05B8], c[0x05B9]),
                     c[0x05A2], V.sbyte(c[0x35]), c[0x05B5], c[0x05A5],
                     c[0x05A4], c[0x05B4], c[0x05A6], c[0x05A7], c[0x05CE],
                     c[0x05B2], c[0x05A3], c[0x05AF]))
        odds.append((c[0x00F8], c[0x0112], c[0x56],
                     c[0x05C6] | c[0x05C7] << 8, c[0x05C5], c[0x05C8],
                     c[0x071C]))
    return out, mark, hero, odds, ticks


def engine(cfg, scratch):
    path = os.path.join(scratch, 'obj.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([S.GODOT, '--path', S.GAME, '--headless', '--',
                        '--solobj=%s' % path],
                       capture_output=True, text=True, timeout=900)
    rows, mark, hero, odds = [], [], [], []
    for line in r.stdout.split('\n'):
        if line.startswith('P '):
            f = line[2:].split(',')
            if len(f) == len(NAMES):
                hero.append(tuple(int(v) for v in f))
            continue
        if line.startswith('Y '):
            f = line[2:].split()
            if len(f) == len(ODD):
                odds.append(tuple(int(v) for v in f))
            continue
        f = line.split()
        if f and f[0] == 'C' and len(f) == MARKS + 1:
            mark.append(tuple(int(v) for v in f[1:]))
            continue
        if len(f) != SLOTS or not all(t.count(',') == 6 for t in f):
            continue
        rows.append(tuple(tuple(int(v) for v in t.split(',')) for t in f))
    if not rows:
        sys.stderr.write(r.stdout[-2000:] + r.stderr[-2000:])
    return rows, mark, hero, odds


def settled(state, stage):
    """The first frame to seed from whose next one begins a whole picture.

    The game does not always fit a picture into one frame: the hero is stepped
    at the top of it and the pool at the bottom, and when the frame runs out
    between the two the rest is finished in the next.  A seed taken in the
    middle of such a picture cannot be played by the engine at all -- it would
    have to begin halfway -- so the stand steps the seed on until the frame
    after it is one the game begins a picture on.
    """
    first = V.BASE if stage == 0 else P.WARP_IN
    script = [(first + i, '-') for i in range(LOOK)]
    rows = P.watched(state, script, first, first + LOOK, {0x0C})
    for i in range(LOOK - 1):
        if rows[i][1][0x0C] != rows[i + 1][1][0x0C]:
            return first + i
    return first


def run(scratch, state, cfg0, first, money, suit, shield):
    """One standing, both sides, and where they first part."""
    play = first + 1
    pads = S.hold(LEN, DOWN)
    # What he is entered with: the bonus he has not been counted yet is what a
    # panel is paid out of, and a stage raised by the warp has none of it.
    hero_put = ((0x05C5, suit), (0x05C8, shield))
    odd_put = ((0x05C6, money & 0xFF), (0x05C7, money >> 8), (0x56, 0x00))
    pk = [(a, v, play + AT) for a, v in hero_put + odd_put]
    wr, wm, wh, wo, tk = cartridge(state, pads, play, pk)
    cfg = dict(cfg0)
    cfg['pads'] = pads
    cfg['kill_at'] = AT
    cfg['hero_put'] = [[a, v] for a, v in hero_put]
    cfg['odd_put'] = [[a, v] for a, v in odd_put]
    cfg['crates'] = True
    cfg['clock_at'] = [t[0] for t in tk]
    cfg['noise_at'] = [t[1] for t in tk]
    cfg['six_at'] = [t[2] for t in tk]
    cfg['step_at'] = [t[3] for t in tk]
    cfg['ride_at'] = [t[4] for t in tk]
    cfg['new_at'] = [t[5] for t in tk]
    owed = [t[6] for t in tk]
    cfg['owed_at'] = owed[:1] + owed[:-1]
    gr, gm, gh, go = engine(cfg, scratch)
    n = min(len(wr), len(wm), len(wh), len(wo), len(gr), len(gm), len(gh),
            len(go))
    # Past the picture the shown screen changes on, the cartridge is playing
    # somebody else's stand.
    for i in range(n):
        if tk[i][7] != tk[0][7]:
            n = i + 1
            break
    fin = S.finished(tk, n)
    for i in range(n):
        if not fin[i]:
            continue
        if wo[i] != go[i]:
            return n, i, 'what a panel buys', wo[i], go[i]
        if wh[i] != gh[i]:
            return n, i, 'hero', wh[i], gh[i]
        if wm[i] != gm[i]:
            return n, i, 'mark', wm[i], gm[i]
        if wr[i] != gr[i]:
            return n, i, 'slots', wr[i], gr[i]
    return n, None, None, None, None


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    stages = [int(a.split('=')[1]) for a in sys.argv[1:]
              if a.startswith('--stage=')]
    scratch = P.scratch('panels')
    try:
        bad = total = 0
        for stage in (stages or range(20)):
            found = spots(stage)
            if not found:
                continue
            for kind, spot in found:
                state = V.stand(scratch, 's%d' % stage, stage, spot)
                first = settled(state, stage)
                cfg0 = S.seed(P.ram(state, [(first, '-')], first))
                price = PANELS['cost'][min(kind, 2)]
                cases = [('%s, money' % KINDS[kind], MONEY, 0x03, 0x00),
                         ('%s, short' % KINDS[kind], price - 1, 0x03, 0x00),
                         ('%s, full' % KINDS[kind], MONEY,
                          PANELS['suit_full'], PANELS['shield_full'])]
                for name, money, suit, shield in cases:
                    label = 's%-2d %-14s' % (stage, name)
                    if only and not any(o in label for o in only):
                        continue
                    total += 1
                    n, where, kn, w, g = run(scratch, state, cfg0, first,
                                             money, suit, shield)
                    if where is None:
                        print('%s %-10s ok, %d pictures'
                              % (label, str(spot), n))
                        sys.stdout.flush()
                        continue
                    bad += 1
                    print('%s %-10s %s differs on picture %d'
                          % (label, str(spot), kn, where))
                    if kn == 'what a panel buys':
                        for k, nm in enumerate(ODD):
                            if w[k] != g[k]:
                                print('    $%-7s cartridge %6d   engine %6d'
                                      % (nm, w[k], g[k]))
                    elif kn == 'hero':
                        for k, nm in enumerate(NAMES):
                            if w[k] != g[k]:
                                print('    %-8s cartridge %6d   engine %6d'
                                      % (nm, w[k], g[k]))
                    elif kn == 'mark':
                        for k in range(MARKS):
                            if w[k] != g[k]:
                                print('    mark %2d cartridge %3d  engine %3d'
                                      % (k, w[k], g[k]))
                    else:
                        for j in range(SLOTS):
                            if w[j] != g[j]:
                                print('    slot %2d cartridge %s  engine %s'
                                      % (j, w[j], g[j]))
                    sys.stdout.flush()
        print('%d of %d duckings on a panel differ' % (bad, total))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
