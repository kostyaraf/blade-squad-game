#!/usr/bin/env python3
"""Э6.3.2 acceptance: what Solbrain asks its driver for, picture by picture.

The cartridge asks through two bytes of zero page -- $F0 for a tune and $F1
for a noise -- and a hundred and seventy-one places write them: minds three
banks away, shots, the satellite, the hero himself, the screens between
stages, the stages' own scripts.  Six and twenty of them were written down in
the port as comments and none of them were made.  Now they are made, and this
says whether the right ones are.

**Not by reading the two cells at a frame boundary.**  That was the plan and
the plan was wrong: the driver takes $F0 and $F1 and puts nought back in the
same picture the game wrote them, so at every boundary they read nought and
always will.  A stand watching them would compare nought with nought for ever
and pass.

So what is compared is the writing, not the reading.  `nesemu` is asked to
keep a note of every write into those two bytes together with the picture it
happened in, and a write of nought is the driver clearing up after itself,
not a request; a request carries a number.  The engine writes its request
down at the one moment it exists -- after the picture, before the driver is
let at it.

**Not the driver's writes into the chip.**  That would have been a stronger
comparison and it cannot be made here: the cartridge arrives at a savestate
with a tune already half played and the engine's driver starts from silence,
so the two would differ on the first picture over state, not over requests.
The driver itself was proved in Э6.1 against the cartridge from a cold start;
what is open here is only whether the game asks it for the right things.

The one write of a number that is not a request is the driver's own, when the
game is paused ($F1 <- 1).  None of the scripts below presses start.

Run with no arguments, or name scripts and places:
`verify_sol_noise.py still --place=s3`.
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
import verify_sol_draw as D                                      # noqa: E402
import verify_sol_long as L                                      # noqa: E402

LEN = 600
R = S.R
Lf = S.L
A = S.A

# Fewer and shorter than Э4.22's, because what is judged here is not the pool
# but what the pool asks for, and a noise is asked for in the first seconds or
# not at all.  Standing still is kept all the same: a stage makes noises of
# its own with nobody touching anything.
SCRIPTS = {
    'still':          S.hold(LEN, 0),
    'right':          S.hold(LEN, R),
    'there and back': S.hold(LEN // 2, R) + S.hold(LEN // 2, Lf),
    'hopping right':  (S.hold(10, R) + S.hold(8, R | A)) * (LEN // 18),
    'shooting':       (S.hold(4, R | S.B) + S.hold(4, R)) * (LEN // 8),
}

PLACES = [('s%d' % n, n) for n in range(20)]


def asked(state, pads, base, scratch):
    """Every number the cartridge put into $F0 and $F1, picture by picture."""
    inp = os.path.join(scratch, 'noise.inp')
    last = None
    with open(inp, 'w') as f:
        for i, p in enumerate(pads):
            if p != last:
                names = [n for n, b in V.BITS if p & b]
                f.write('%d %s\n' % (base + i, ','.join(names) or '-'))
                last = p
    log = os.path.join(scratch, 'noise.watch')
    # `-tracepc` is set to an address the processor never stands at, which
    # leaves the note with the watched writes in it and nothing else.
    subprocess.run([D.EMU, P.ROM, '-loadstate', state, '-input', inp,
                    '-frames', str(base + len(pads)), '-watch', '00F0-00F1',
                    '-trace', log, '-tracepc', 'FFFF-FFFF'],
                   check=True, capture_output=True)
    per = {}
    with open(log) as f:
        for line in f:
            if not line.startswith('WATCH'):
                continue
            fr, _pc, _bank, addr, val = line[6:].strip().split(',')
            if val == '00':                     # the driver clearing up
                continue
            # Two requests in one picture and the driver sees the second:
            # what is kept is the last, which is what it reads.
            per.setdefault(int(fr), {})[int(addr, 16)] = int(val, 16)
    os.remove(inp)
    os.remove(log)
    out = []
    for i in range(len(pads)):
        cell = per.get(base + i, {})
        out.append((cell.get(0xF0, 0), cell.get(0xF1, 0)))
    return out


def engine(cfg, scratch):
    """And what the port asks for, out of the same run of the same game."""
    path = os.path.join(scratch, 'noise.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([S.GODOT, '--path', S.GAME, '--headless', '--',
                        '--solobj=%s' % path],
                       capture_output=True, text=True, timeout=1800)
    rows = []
    for line in r.stdout.split('\n'):
        if not line.startswith('Q'):
            continue
        w = line.split()
        rows.append(None if w[1] == '-'
                    else (int(w[1], 16), int(w[2], 16)))
    if not rows:
        sys.stderr.write(r.stdout[-2000:] + r.stderr[-2000:])
    return rows


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    scratch = P.scratch('noise')
    try:
        bad = total = pictures = writes = spoke = 0
        for label, stage in PLACES:
            if places and label not in places:
                continue
            first = V.BASE if stage == 0 else P.WARP_IN
            play = first + 1
            state = V.stand(scratch, label, stage, None)
            cfg0 = S.seed(P.ram(state, [(first, '-')], first))
            for name, pads in sorted(SCRIPTS.items()):
                if only and name not in only:
                    continue
                total += 1
                _wp, _ws, tk = L.cartridge(state, pads, play)
                want = asked(state, pads, play, scratch)
                cfg = dict(cfg0)
                cfg['pads'] = pads
                cfg['clock_at'] = [t[0] for t in tk]
                cfg['noise_at'] = [t[1] for t in tk]
                cfg['six_at'] = [t[2] for t in tk]
                cfg['step_at'] = [t[3] for t in tk]
                cfg['ride_at'] = [t[4] for t in tk]
                cfg['new_at'] = [t[5] for t in tk]
                cfg['line_at'] = L.line(state, pads, play, scratch)
                cfg['script'] = 1
                cfg['sound'] = 1
                got = engine(cfg, scratch)
                n = min(len(want), len(got))
                done = S.finished(tk, n)
                seen = {}
                for i in range(n):
                    if not done[i] or got[i] is None:
                        continue
                    pictures += 1
                    if want[i] != (0, 0):
                        spoke += 1
                        writes += (1 if want[i][0] else 0) + (1 if want[i][1]
                                                              else 0)
                    if want[i] != got[i]:
                        seen.setdefault((want[i], got[i]), i)
                if not seen:
                    print('%-6s %-16s ok, %d pictures' % (label, name, n))
                    sys.stdout.flush()
                    continue
                bad += 1
                print('%-6s %-16s differs %d ways in %d pictures'
                      % (label, name, len(seen), n))
                for (w, g), i in sorted(seen.items(), key=lambda kv: kv[1]):
                    print('    picture %4d  cartridge $F0=%02X $F1=%02X'
                          '  port $F0=%02X $F1=%02X' % ((i,) + w + g))
                sys.stdout.flush()
        print('%d pictures, %d requests in %d of them' %
              (pictures, writes, spoke))
        print('%d of %d runs differ from what the cartridge asked for'
              % (bad, total))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
