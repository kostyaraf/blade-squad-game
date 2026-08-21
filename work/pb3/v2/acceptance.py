#!/usr/bin/env python3
"""Stage 1 acceptance: two players, in the game, doing things.

Every check below is a gameplay measurement -- positions, health and object
slots read out of a real run -- and not a flag set by the build.  That is the
rule ver2 was written under: ver1's tests passed while the game did not work.
"""
import os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
EMU = os.path.join(ROOT, 'work/tools/nesemu')
ROM = os.path.join(ROOT, 'work/build/PB3.nes')
SHOTS = os.path.join(ROOT, 'docs/e1')
TMP = '/tmp/pb3_accept'

START = ['40 START', '50 -', '80 START', '90 -', '400 START', '410 -']
JOIN = ['2000 2START', '2010 -']

# work RAM, as build.py lays it out
P2_BLK, P2_POS, P2_ON, DOWN, TMR, P2JOIN = 0x7F00, 0x7F30, 0x7F35, 0x7F50, 0x7F52, 0x7F55
HERO1, HERO2 = 0x7F58, 0x7F59
SUIT, ENE, GUN, MOPEN = 0x7F90, 0x7F92, 0x7F98, 0x7F99
PWR = 0x05C8                    # the engine's own double-damage flag
SAT = 0x060C                    # the weapon unit's object type = the weapon ID
# the title screen is the character select; it is up from about frame 20 until
# the first start press, so the choice is made in the frames just before it
PICK = ['25 RIGHT,2LEFT', '35 -']
HP = 0x05C5


def run(lines, frames, shots=(), name=None, pokes=()):
    os.makedirs(TMP, exist_ok=True)
    inp = os.path.join(TMP, 'i.inp')
    open(inp, 'w').write('\n'.join(lines) + '\n')
    dump = os.path.join(TMP, 'r.bin')
    cmd = [EMU, ROM, '-input', inp, '-frames', str(frames), '-ramdump', dump]
    for p in pokes:
        cmd += ['-poke', p]
    if shots:
        cmd += ['-png', os.path.join(SHOTS, (name or 'shot') + '_')]
        for f in shots:
            cmd += ['-shot', str(f)]
    subprocess.run(cmd, capture_output=True)
    return open(dump, 'rb').read()


class St:
    """One RAM dump, read the way the runtime lays memory out."""

    def __init__(self, r):
        self.r, self.w = r, r[0x800:]

    def _w(self, a):
        return self.w[a - 0x6000]

    def px(self, lo):
        return (self.r[lo + 1] * 256 + self.r[lo]) / 16.0

    @property
    def a_x(self):  return self.px(0x80)
    @property
    def b_x(self):  return (self._w(P2_POS + 1) * 256 + self._w(P2_POS)) / 16.0
    @property
    def a_hp(self): return self.r[HP]
    @property
    def b_hp(self): return self._w(P2_BLK + HP - 0x05A2)
    @property
    def on(self):   return self._w(P2_ON)
    def down(self, i): return self._w(DOWN + i)
    def tmr(self, i):  return self._w(TMR + i)
    def slot(self, n): return self.r[0x600 + n]
    @property
    def h1(self):   return self._w(HERO1)
    @property
    def h2(self):   return self._w(HERO2)
    def suit(self, i): return self._w(SUIT + i)
    def ene(self, i):  return self._w(ENE + i)
    @property
    def gun(self):  return self._w(GUN)
    @property
    def mopen(self): return self._w(MOPEN)
    @property
    def sat(self):  return self.r[SAT]
    @property
    def y(self):    return self.px(0x82)

    def attrs(self):
        """Which sprite palettes the two men's own tiles are drawn with."""
        one, two = set(), set()
        for i in range(64):
            y, t, a, x = self.r[0x200 + 4 * i: 0x204 + 4 * i]
            if y >= 0xF0:
                continue
            if (t & 0xFE) < 0x20:
                one.add(a & 3)
            elif 0x40 <= (t & 0xFE) < 0x60:
                two.add(a & 3)
        return one, two


def walk(first, last, keys='RIGHT', step=40):
    """Hold a direction and tap jump, so a ledge is not the end of the run."""
    out = []
    f = first
    while f < last:
        out += ['%d %s' % (f, keys), '%d %s,A' % (f + 20, keys), '%d %s' % (f + 28, keys)]
        f += step
    return out


def main():
    ok = True

    def check(name, cond, detail):
        nonlocal ok
        ok &= bool(cond)
        print('%-42s %-4s %s' % (name, 'PASS' if cond else 'FAIL', detail))

    # 1. alone, unless pad two asks to join
    s = St(run(START + walk(1980, 2200), 2200))
    check('one player when pad 2 stays quiet', s.on == 0 and s.a_x > 400,
          'P2_ON=%d  P1 x=%.0f' % (s.on, s.a_x))

    # 2. pad two presses start: a second man appears
    s = St(run(START + JOIN + walk(2100, 2400), 2400, (2350,), 'join'))
    check('pad 2 presses start and joins', s.on == 1 and s.b_x > 0,
          'P2_ON=%d  P1 x=%.0f  P2 x=%.0f' % (s.on, s.a_x, s.b_x))

    # 3. opposite directions from the two pads, both really moving
    base = START + JOIN + ['2100 LEFT,2RIGHT']
    s = St(run(base, 2400, (2200, 2350), 'apart'))
    check('the two pads move the two men apart', abs(s.a_x - s.b_x) > 150,
          'P1 x=%.0f  P2 x=%.0f  gap %.0f' % (s.a_x, s.b_x, abs(s.a_x - s.b_x)))

    # 4. both on screen: the camera follows the pair and neither can leave it
    check('both stay inside one screen', abs(s.a_x - s.b_x) < 256,
          'gap %.0f px, screen is 256' % abs(s.a_x - s.b_x))

    # 5. both attack.  The punch is object slot $0F; the runtime gives player
    #    two slot $0D, which the engine already tests against enemies.
    s = St(run(START + JOIN + ['2100 -', '2110 B,2B', '2130 -'], 2118, (2117,), 'punch'))
    check('both men punch at once', s.slot(0x0F) and s.slot(0x0D),
          'slot $0F=%02X  slot $0D=%02X' % (s.slot(0x0F), s.slot(0x0D)))

    # 5b. and they are not the same man: player two's sprites are fetched
    #     from the second 1K of the pattern table, which holds the other
    #     game's hero redrawn into this engine's poses
    s = St(run(START + JOIN + ['2100 LEFT', '2140 -', '2200 2LEFT', '2230 -'],
               2260, (2260,), 'heroes'))
    check('player two is the other game\'s hero', s.r[0x43] >= 128,
          'his CHR bank is %d (Solbrain\'s own are 64-92)' % s.r[0x43])

    # 5c. the select screen: each pad picks its own man, and the man picked
    #     is the one whose art is loaded once the level starts
    s = St(run(PICK + START + walk(1980, 2100), 2100, (30,), 'select'))
    check('each pad picks its own man', s.h1 == 1 and s.h2 == 0,
          'pad 1 chose %d, pad 2 chose %d (0 = this game, 1 = the other)'
          % (s.h1, s.h2))
    check('the man you picked is the man you play', s.r[0x42] >= 128,
          'player one draws out of CHR bank %d, not 64-92' % s.r[0x42])
    s = St(run(PICK + START + JOIN + ['2100 LEFT', '2140 -',
                                      '2200 2LEFT', '2230 -'], 2260))
    check('and swapping the pair swaps the art',
          128 <= s.r[0x42] < 144 and s.r[0x43] >= 144,
          'banks %d and %d (128-143 the other game, 144+ this one)'
          % (s.r[0x42], s.r[0x43]))

    # 6. each takes damage on his own bar
    a = St(run(START + JOIN + walk(2100, 2600), 2600))
    check('health is per player and does drop', a.a_hp < 8 or a.b_hp < 8,
          'bars %d and %d of 8' % (a.a_hp, a.b_hp))

    # 7. one man down: the other plays on, and the downed one comes back.
    #    Which of the two contexts the RAM dump caught is not fixed -- the dump
    #    is taken mid-frame, between the two swaps -- so the revived man is
    #    identified by behaviour, not by the slot his bar sits in.
    kill = START + JOIN + walk(2100, 2600) + ['2600 -', '2750 2LEFT']
    d1 = St(run(kill, 2700, pokes=['7F23=0@2600']))
    d2 = St(run(kill, 2800, pokes=['7F23=0@2600']))
    d3 = St(run(kill, 2900, pokes=['7F23=0@2600']))
    check('one man down, the other plays on',
          d1.down(0) + d1.down(1) == 1 and d1.tmr(0) + d1.tmr(1) > 0,
          'DOWN=%d,%d  timer=%d' % (d1.down(0), d1.down(1),
                                    max(d1.tmr(0), d1.tmr(1))))
    check('the downed man is put back on his feet',
          d2.down(0) == 0 and d2.down(1) == 0 and d2.a_hp and d2.b_hp,
          'DOWN=%d,%d  bars %d and %d' % (d2.down(0), d2.down(1),
                                          d2.a_hp, d2.b_hp))
    # only pad 2 is held after the revival, so exactly one man may move
    m_a, m_b = abs(d3.a_x - d2.a_x), abs(d3.b_x - d2.b_x)
    check('the revived man answers his own pad', max(m_a, m_b) > 16,
          'moved %.0f and %.0f px on pad 2 alone' % (m_a, m_b))

    # 8. both men down at once: the engine's own death runs, the level
    #    restarts, and pad two is put back in without pressing start again
    both = START + JOIN + walk(2100, 2600) + ['2600 -'] + walk(3200, 3600)
    pk = ['5C5=0@2600', '7F23=0@2601']
    r1 = St(run(both, 3100, pokes=pk))
    r2 = St(run(both, 3300, pokes=pk))
    check('both down: the level restarts',
          r1.r[0x05A2] in (0x12, 0x13) or r2.r[0x05A2] < 0x12,
          'state %02X then %02X' % (r1.r[0x05A2], r2.r[0x05A2]))
    check('and the pair is back in play afterwards',
          r2.on == 1 and r2.a_hp and r2.b_hp,
          'P2_ON=%d  bars %d and %d' % (r2.on, r2.a_hp, r2.b_hp))

    # --- stage 3: the suits, the sub-weapons and the one bar they share ----

    # 9. every Solbrain sub-weapon is carried from the start, no letters to
    #    collect: the menu picks one and the engine builds its own unit
    carried = []
    for g in range(1, 9):
        s = St(run(START, 2100, pokes=['7F98=%d@1900' % g]))
        carried.append(s.sat)
    check('all eight sub-weapons, from the start', carried == list(range(1, 9)),
          'weapon unit type per choice: %s' % carried)

    # 10. the menu opens on SELECT and closes on it
    o = St(run(START + ['2000 SELECT', '2010 -'], 2060))
    c = St(run(START + ['2000 SELECT', '2010 -', '2040 SELECT', '2050 -'], 2100))
    check('the menu opens and closes on select', o.mopen == 1 and c.mopen == 0,
          'open %d, then %d' % (o.mopen, c.mopen))

    # 11. each pad dresses its own man
    pick = START + JOIN + ['2100 SELECT', '2110 -', '2120 RIGHT', '2130 -',
                           '2140 2RIGHT', '2150 -', '2160 2RIGHT', '2170 -',
                           '2180 SELECT', '2190 -']
    s = St(run(pick, 2260, (2200,), 'suits'))
    check('each pad dresses its own man', s.suit(0) == 1 and s.suit(1) == 2,
          'suits %d and %d of 4' % (s.suit(0), s.suit(1)))

    # 12. and the two suits are two different colours on screen: the men are
    #     drawn on different sprite palettes, which is the only way this
    #     engine can show two costumes at once
    one, two = s.attrs()
    check('the two suits are two colours', one == {0} and two == {3},
          'player one on palette %s, player two on %s'
          % (sorted(one), sorted(two)))

    # 13. a suit eats the bar and falls off when it is empty
    d = St(run(START + ['2000 SELECT', '2010 -', '2020 RIGHT', '2030 -',
                        '2040 SELECT', '2050 -'], 2700,
               pokes=['7F92=1@2100']))
    check('a suit drains the bar and then falls off',
          d.ene(0) == 0 and d.suit(0) == 0,
          'bar %d, suit %d' % (d.ene(0), d.suit(0)))

    # 14. and firing costs out of the same bar
    fire = START + ['1980 SELECT', '1990 -', '2000 UP', '2010 -',
                    '2020 SELECT', '2030 -']
    fire += [x for f in range(2100, 3000, 20)
             for x in ('%d B' % f, '%d -' % (f + 8))]
    f1 = St(run(fire, 2100))
    f2 = St(run(fire, 3000))
    check('firing costs out of the same bar', f2.ene(0) < f1.ene(0),
          'bar %d before, %d after %d shots' % (f1.ene(0), f2.ene(0), 45))

    # 15. an empty bar means no weapon unit at all -- bare hands
    e = St(run(fire, 2200, pokes=['7F92=0@2150', '7F93=0@2150']))
    check('an empty bar leaves you bare-handed', e.sat == 0,
          'weapon unit type %d' % e.sat)

    # 16. the speed suit covers more ground in the same time
    run_r = START + ['1900 RIGHT']
    a0 = St(run(run_r, 2000, pokes=['7F90=0@1850']))
    a2 = St(run(run_r, 2000, pokes=['7F90=2@1850']))
    check('the speed suit covers more ground', a2.a_x > a0.a_x + 16,
          '%.0f px against %.0f in the same 100 frames' % (a2.a_x, a0.a_x))

    # 17. the float suit falls slower while A is held
    fall = START + ['1900 RIGHT', '1930 RIGHT,A']
    b0 = St(run(fall, 1983, pokes=['7F90=0@1850']))
    b1 = St(run(fall, 1983, pokes=['7F90=1@1850']))
    check('the float suit falls slower', b1.y < b0.y - 8,
          'y %.0f against %.0f at the same frame' % (b1.y, b0.y))

    # 18. the power suit turns on the engine's own double-damage flag
    p3 = St(run(START, 2000, pokes=['7F90=3@1850']))
    check('the power suit doubles the punch', p3.r[PWR] != 0,
          "the engine's own power flag reads %02X" % p3.r[PWR])

    print('\n%s' % ('all checks passed' if ok else 'SOMETHING FAILED'))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
