#!/usr/bin/env python3
"""Э6.2 acceptance: the sound chip, twice over.

Э6.1 proved the drivers: on every picture the port writes into $4000..$4017
the bytes the cartridge writes.  What those bytes mean -- two squares, a
triangle, a noise ring and a recorded sample, all fed through a mixer that is
not a sum -- is the chip's business, and the chip is where this stand starts.

There is nothing to read the chip off.  The cartridge holds no wave; the wave
is made by hardware the cartridge does not contain.  So the chip is written
twice, once in `work/tools/nesemu.c` and once in `game/src/snd_chip.gd`, from
the same reading of the hardware (`work/re/apu.md`), and the two are made to
agree sample for sample.  Two readings agreeing is a proof; one reading
agreeing with itself would not be.

The comparison cannot be made picture by picture the way Э6.1's was.  The
port hands a picture's writes over all at once; the cartridge spreads the
same writes over thousands of cycles, and a square whose period is a hundred
cycles hears the difference.  So the emulator writes down two things instead:

  * `-apulog` -- every write to $4000..$4017 with the cycle it landed on;
  * `-pcm`    -- the wave it made of them, one sample every fortieth cycle.

The engine is handed the tape, puts the same bytes on the same cycles through
its own chip, and its wave has to be the same file.

Two kinds of run:

  * the stand of Э6.1 -- every number of both cartridges, on its own and
    mixed -- so that every duty, every sweep, every length and every noise
    period the two games ever ask for is actually synthesised;
  * each cartridge from cold for a long stretch, which is the only place the
    sample channel is heard: Power Blade 2's drums are DMC ($4010 = $0F at
    $8173), and 1200 pictures of its title screen are forty-odd strikes.
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
import sndprobe as SP                                            # noqa: E402
import verify_sol_player as V                                    # noqa: E402
import verify_sound as S                                         # noqa: E402

# How long each cartridge is run from cold, and how it is nudged along.
# Power Blade 2 plays its title tune, drums and all, without being asked;
# Solbrain sits on its opening screens in silence until START is pressed
# ($F9C5's walk, the same press `verify_sol_boot.py` uses), so both are given
# the same slow tapping and both end up inside a stage.
COLD = 2600
PRESS = range(240, COLD, 180)


def pilot(path):
    """A press of START every three seconds, four pictures long."""
    rows = ['1 -']
    for f in PRESS:
        rows += ['%d START' % f, '%d -' % (f + 4)]
    open(path, 'w').write('\n'.join(rows) + '\n')


def runs():
    """Every run, as both chips are asked for it."""
    out = [dict(r, kind='stand') for r in S.runs()]
    for game in ('pb2', 'sol'):
        out.append({'game': game, 'kind': 'cold', 'frames': COLD,
                    'say': '%s from cold' % game})
    return out


def cartridge(rs, scratch):
    """Run every one in the emulator, which writes the tape and the wave.
    Gives back, per run, (tape path, wave path, how many cycles it took)."""
    built = {}
    out = []
    for i, r in enumerate(rs):
        log = os.path.join(scratch, 'apu%03d.log' % i)
        pcm = os.path.join(scratch, 'apu%03d.pcm' % i)
        if r['kind'] == 'stand':
            if r['game'] not in built:
                rom = os.path.join(scratch, '%s_stand.nes' % r['game'])
                built[r['game']] = (rom,) + SP.build(r['game'], rom)
            rom, off, loop = built[r['game']]
            frames = r['pictures'] // 8 + 8
            extra = SP.pokes(off, r['script'])
        else:
            rom = SP.ROM[r['game']]
            frames = r['frames']
            inp = os.path.join(scratch, 'cold%03d.inp' % i)
            pilot(inp)
            extra = ['-input', inp]
        cmd = [SP.NESEMU, rom, '-frames', str(frames),
               '-pcm', pcm, '-apulog', log] + extra
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=1200)
        cycles = 0
        for line in p.stderr.split('\n'):
            if line.startswith('done:'):
                cycles = int(line.split('frames, ')[1].split(' ')[0])
        if not cycles:
            sys.stderr.write(p.stdout[-2000:] + p.stderr[-2000:])
        out.append((log, pcm, cycles))
    return out


def engine(rs, tapes, scratch):
    """And the wave the engine's own chip makes of the same tapes."""
    want = []
    for i, r in enumerate(rs):
        log, _, cycles = tapes[i]
        want.append({'game': r['game'], 'say': r['say'], 'log': log,
                     'cycles': cycles,
                     'out': os.path.join(scratch, 'eng%03d.pcm' % i)})
    path = os.path.join(scratch, 'apu.json')
    open(path, 'w').write(json.dumps({'runs': want}))
    p = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                        '--apu=%s' % path],
                       capture_output=True, text=True, timeout=7200)
    if 'apu ' not in p.stdout:
        sys.stderr.write(p.stdout[-3000:] + p.stderr[-3000:])
    return [w['out'] for w in want]


def first_difference(a, b):
    """Which sample the two waves first part on, and what each said there."""
    n = min(len(a), len(b)) // 2
    for k in range(n):
        x = a[k * 2] | (a[k * 2 + 1] << 8)
        y = b[k * 2] | (b[k * 2 + 1] << 8)
        if x != y:
            return k, x - (x & 0x8000) * 2, y - (y & 0x8000) * 2
    return n, 0, 0


def main():
    scratch = P.scratch('apu')
    try:
        rs = runs()
        # One run at a time while the chip is being written: a word on the
        # command line keeps the runs whose name has it.
        if len(sys.argv) > 1:
            rs = [r for r in rs if all(w in r['say'] for w in sys.argv[1:])]
            if not rs:
                print('no run is named that')
                return 1
        tapes = cartridge(rs, scratch)
        mine = engine(rs, tapes, scratch)
        bad = 0
        shown = 0
        samples = 0
        writes = 0
        # A wave that never moves is silence, and two silences agreeing prove
        # nothing.  Counted so that a chip gone dumb cannot pass for a chip.
        mute = []
        for i, r in enumerate(rs):
            log, pcm, cycles = tapes[i]
            writes += sum(1 for _ in open(log))
            want = open(pcm, 'rb').read()
            samples += len(want) // 2
            if len(want) >= 2 and want == want[:2] * (len(want) // 2):
                mute.append(r['say'])
            try:
                got = open(mine[i], 'rb').read()
            except OSError:
                got = b''
            if want == got and want:
                continue
            bad += 1
            if shown < 12:
                shown += 1
                k, x, y = first_difference(want, got)
                print('%-24s %d samples, parts at %d: cartridge %d, '
                      'engine %d' % (r['say'], len(want) // 2, k, x, y))
        if mute:
            print('silent: ' + ', '.join(mute[:10])
                  + (' ...' if len(mute) > 10 else ''))
        print('%d runs, %d samples, %d writes on the tape, %d of the runs '
              'are silent' % (len(rs), samples, writes, len(mute)))
        print('%d of %d waves differ from what the cartridge sounds like'
              % (bad, len(rs)))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


if __name__ == '__main__':
    sys.exit(main())
