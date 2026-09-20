#!/usr/bin/env python3
"""Э6.1 acceptance: the two sound drivers, ported.

Power Blade 2 and Solbrain each carry a sound driver: a short interpreter that
walks data in its own bank and writes the five channels of the APU.  Neither
is big -- a little over two kilobytes of code each -- and both are
what makes the noise: everything a player hears is decided by what those
bytes put into $4000..$4017.

So that is what is compared.  Not a waveform: a waveform is what an APU makes
of the registers, and an APU that is given the same registers on the same
picture makes the same sound.  The tape of writes is the whole of the driver's
behaviour, and it can be read off the cartridge exactly.

The cartridge is read by `work/tools/sndprobe.py`, which boots it into a stand
of its own -- no game running, the driver's two banks mapped, one call of its
per-picture entry a turn -- so that both sides start from the same place.  The
engine is asked the same things through `--sound=`, and the two tapes have to
be the same byte for byte and picture for picture.

Three kinds of run, and the third is the one a recording of each tune could
never answer:

  * every number of Power Blade 2 ($01..$4B, which is what $8013 lets
    through) on its own;
  * every tune and every sound of Solbrain on its own -- 17 and 65, counted
    not by hand but by the two screens of the cartridge's own TEST MODE
    ($D86B and $D90E, already extracted into `game/data/sol/test.json`);
  * a tune with sounds thrown on top of it, because a sound takes a channel
    away from the tune by priority ($80A5 compares with $0700,X) and gives it
    back when it ends.
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

# $8013 -- Power Blade 2 lets $01..$4B through and treats $00 as silence.
PB2_N = 0x4C
# $D86B and $D90E -- what the cartridge's own TEST MODE counts.
SOL_BGM = json.load(open(os.path.join(ROOT, 'game', 'data', 'sol',
                                      'test.json')))['bgm_n']
SOL_SFX = json.load(open(os.path.join(ROOT, 'game', 'data', 'sol',
                                      'test.json')))['sound_n']

# How long each kind of run is watched for.  A tune is watched long enough to
# get well past its beginning and into its own repeat; a sound long enough to
# end of its own accord.
LONE = 180
TUNE = 420
AT = 4


def runs():
    """Every run, as the engine and the cartridge are both asked for it."""
    out = []
    for n in range(1, PB2_N):
        out.append({'game': 'pb2', 'say': 'pb2 %02X' % n,
                    'script': [[AT, 0, n]], 'pictures': LONE})
    for n in range(SOL_BGM):
        out.append({'game': 'sol', 'say': 'sol bgm %02X' % n,
                    'script': [[AT, 0, n]], 'pictures': TUNE})
    for n in range(SOL_SFX):
        out.append({'game': 'sol', 'say': 'sol sfx %02X' % n,
                    'script': [[AT, 1, n]], 'pictures': LONE})
    # And the mixed ones: a tune, then sounds on top of it while it plays.
    for bgm in range(1, SOL_BGM, 4):
        for sfx in (0x05, 0x11, 0x25):
            out.append({'game': 'sol', 'say': 'sol bgm %02X + sfx %02X'
                        % (bgm, sfx),
                        'script': [[AT, 0, bgm], [60, 1, sfx],
                                   [90, 1, sfx], [150, 1, sfx]],
                        'pictures': TUNE})
    for a in range(1, PB2_N, 7):
        for b in (0x03, 0x07, 0x29):
            out.append({'game': 'pb2', 'say': 'pb2 %02X + %02X' % (a, b),
                        'script': [[AT, 0, a], [60, 0, b], [90, 0, b]],
                        'pictures': TUNE})
    return out


# The cartridge's tapes never change, and reading all of them takes a couple
# of minutes, so they are kept beside the other saved states of the stands and
# read again only when the ROM or this list changes.
CACHE = os.path.join(P.SCRATCH, 'soundtape.json')


def cartridge(rs, scratch):
    """The tape of each run, off the cartridge."""
    key = json.dumps([rs, [os.path.getmtime(SP.ROM[g]) for g in ('pb2', 'sol')],
                      os.path.getmtime(SP.__file__)], sort_keys=True)
    try:
        held = json.load(open(CACHE))
        if held['key'] == key:
            return [[[tuple(w) for w in p] for p in t] for t in held['tape']]
    except Exception:
        pass
    built = {}
    for game in ('pb2', 'sol'):
        rom = os.path.join(scratch, '%s_stand.nes' % game)
        built[game] = (rom,) + SP.build(game, rom)
    out = []
    for r in rs:
        rom, off, loop = built[r['game']]
        out.append(SP.tape(rom, off, loop, r['script'], r['pictures'],
                           scratch))
    try:
        os.makedirs(P.SCRATCH, exist_ok=True)
        json.dump({'key': key, 'tape': out}, open(CACHE, 'w'))
    except Exception:
        pass
    return out


def engine(rs, scratch):
    """And the tape of each run, out of the engine."""
    path = os.path.join(scratch, 'sound.json')
    open(path, 'w').write(json.dumps({'runs': rs}))
    r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                        '--sound=%s' % path],
                       capture_output=True, text=True, timeout=3600)
    out = [[[] for _ in range(x['pictures'])] for x in rs]
    for line in r.stdout.split('\n'):
        f = line.split()
        if len(f) < 3 or f[0] != 'snd':
            continue
        i = int(f[1])
        p = int(f[2])
        if i >= len(out) or p >= len(out[i]):
            continue
        for w in f[3:]:
            a, _, v = w.partition('=')
            out[i][p].append((int(a, 16), int(v, 16)))
    if not any(any(p for p in t) for t in out):
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return out


def say(w):
    return ' '.join('%04X=%02X' % (a, v) for a, v in w) or '(nothing)'


def main():
    scratch = P.scratch('sound')
    try:
        rs = runs()
        want = cartridge(rs, scratch)
        got = engine(rs, scratch)
        bad = 0
        shown = 0
        pictures = 0
        writes = 0
        for i, r in enumerate(rs):
            pictures += len(want[i])
            writes += sum(len(p) for p in want[i])
            for p in range(len(want[i])):
                a = want[i][p]
                b = got[i][p] if p < len(got[i]) else []
                if a == b:
                    continue
                bad += 1
                if shown < 12:
                    shown += 1
                    print('%-22s picture %3d' % (r['say'], p))
                    print('   cartridge %s' % say(a))
                    print('   engine    %s' % say(b))
        print('%d runs, %d pictures, %d writes off the cartridge'
              % (len(rs), pictures, writes))
        print('%d of %d pictures differ from what the cartridge wrote'
              % (bad, pictures))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


if __name__ == '__main__':
    sys.exit(main())
