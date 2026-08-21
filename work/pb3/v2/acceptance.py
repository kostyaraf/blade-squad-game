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
    s = St(run(START + JOIN + ['2100 -', '2110 B,2B', '2120 -'], 2114, (2113,), 'punch'))
    check('both men punch at once', s.slot(0x0F) and s.slot(0x0D),
          'slot $0F=%02X  slot $0D=%02X' % (s.slot(0x0F), s.slot(0x0D)))

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
          r2.on == 1 and r2.a_hp == 8 and r2.b_hp == 8,
          'P2_ON=%d  bars %d and %d' % (r2.on, r2.a_hp, r2.b_hp))

    print('\n%s' % ('all checks passed' if ok else 'SOMETHING FAILED'))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
