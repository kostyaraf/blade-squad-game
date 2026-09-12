#!/usr/bin/env python3
"""Э4.5 acceptance: the stage's own script.

Every stage of Solbrain has a script of its own, and it is what makes a stage
more than a level: it moves the edges the view may walk to, turns the book of
tiles the background is drawn out of, opens and shuts the rooms of the bosses,
puts the bosses themselves in, and at the end of a stage writes which stage
comes next.  It lives in banks eight and nine, is entered at $93B5 from $CDB3,
and is three layers of table deep: the stage picks one of eight dispatchers,
the room he stands in picks a routine out of that, and about half of those
routines walk a step counter of their own ($7F, or $58 at the very end).

The stand is a straight before-and-after.  The cartridge is stopped twice in
the same frame -- at $93B5, the top of the script, and at $CDB6, the picture
after the call has returned -- so each pair of records is one whole running of
the script and nothing else.  The engine is handed the first of each pair,
runs `SolScript.step()` once, and must hand back the second, byte for byte,
across the whole two kilobytes of work memory.

Two pages are left out of the comparison and no others: the stack, which the
cartridge's own JSRs walk and the engine has none of, and the handful of bytes
the two unported calls out of the script write ($C05A and $C05D, which are
loads of a whole screen of background and are the engine's standing debt).

Coverage is forced rather than played for.  The camera ($30..$33) is what
decides which room of the script runs, and the step counters $7F and $58 are
what decides which of a room's steps runs; both are poked on a schedule while
the cartridge plays.  Nothing can accumulate from that, because the engine is
re-seeded from the cartridge for every single picture.
"""
import json
import os
import struct
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import sol_probe as P                                            # noqa: E402
import verify_sol_player as V                                    # noqa: E402

TOP = 0x93B5              # the top of the script
BANK = 8                  # and the bank it lives in
BACK = 0xCDB6             # the picture after the call has returned
REC = 8 + 2048
RUN = 480                 # pictures played in each stage

# What is never compared: the deep end of the stack page, which the JSRs of the
# cartridge walk and the engine has none of.  The shallow end of that page is
# compared, because the script keeps two bytes of real data there ($010A and
# $010B, which $A0EF and $A0FC write).
SKIP = set(range(0x0180, 0x0200))

STAGES = tuple(range(20))

# Which of the script's own routines an acceptance run has seen run.
SEEN = set()


def records(path, bank=None):
    """What the emulator wrote down, one record per time it stood at the PC.

    $93B5 is an address, not a routine: whatever bank happens to be mapped at
    $8000 when the console walks over it is written down too, so the records
    are sifted by the bank the script actually lives in.
    """
    out = []
    if not os.path.exists(path):
        return out
    with open(path, 'rb') as f:
        while True:
            b = f.read(REC)
            if len(b) < REC:
                break
            fr, _pc, bk = struct.unpack('<IHH', b[:8])
            if bank is None or bk == bank:
                out.append((fr, b[8:]))
    return out


def spots():
    """Every room a stage can hold, three times over.

    A room is sixteen columns by thirteen rows of camera, and a room that is a
    script of several steps only shows one of them per visit, so each room is
    stood in three times with the step counters started in three different
    places.
    """
    out = []
    for rep in range(3):
        i = 0
        for row in range(0, 0xD0, 0x10):
            for col in range(0x10):
                out.append((col, row, rep * 3 + i % 3, (i + rep * 7) % 21))
                i += 1
    return out


# One poke row is four bytes, and the emulator takes two hundred and fifty six
# pokes in a run, so a stage is walked in a handful of runs.
PER_RUN = 60


def play(state, scratch, first, chunk, tag):
    """One run: the camera and the two step counters walked over `chunk`."""
    inp = os.path.join(scratch, 'i%s.inp' % tag)
    pre = os.path.join(scratch, 'pre%s.bin' % tag)
    post = os.path.join(scratch, 'post%s.bin' % tag)
    open(inp, 'w').write('%d RIGHT\n%d -\n' % (first + 2, first + 40))
    last = first + 8 + 2 * len(chunk) + 4
    cmd = [P.EMU, P.ROM, '-loadstate', state, '-input', inp,
           '-frames', str(last),
           '-ramat', '%s@%04X' % (pre, TOP),
           '-ramat', '%s@%04X' % (post, BACK)]
    fr = first + 8
    for col, row, z7f, z58 in chunk:
        cmd += ['-poke', '0031=%02X@%d' % (col * 0x10, fr),
                '-poke', '0033=%02X@%d' % (row, fr),
                '-poke', '007F=%02X@%d' % (z7f, fr),
                '-poke', '0058=%02X@%d' % (z58, fr)]
        fr += 2
    r = subprocess.run(cmd, capture_output=True)
    if r.returncode != 0:
        sys.stderr.write(r.stderr.decode()[-800:])
        return [], []
    return records(pre, BANK), records(post)


def pairs(pre, post):
    """One before and one after for each picture that ran the script.

    A picture is only taken when the emulator saw exactly one of each in the
    frame.  Anything else means the frame's interrupt fell between the two
    samples, and then what stands in memory afterwards is the interrupt's work
    as much as the script's -- nothing the port can be asked about.
    """
    a = {}
    b = {}
    for fr, m in pre:
        a.setdefault(fr, []).append(m)
    for fr, m in post:
        b.setdefault(fr, []).append(m)
    out = []
    for fr in sorted(a):
        if len(a[fr]) != 1 or len(b.get(fr, ())) != 1:
            continue
        out.append((fr, a[fr][0], b[fr][0]))
    return out


def engine(rams, scratch):
    path = os.path.join(scratch, 'script.json')
    open(path, 'w').write(json.dumps({'ram': [m.hex() for m in rams]}))
    r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                        '--solscript=%s' % path], capture_output=True,
                       text=True, timeout=600)
    out = []
    for line in r.stdout.split('\n'):
        line, _, trail = line.strip().partition(' ')
        for a in trail.split(','):
            if a:
                SEEN.add(a)
        if line[:1] in ('!', '?'):
            out.append(line[0])
        elif len(line) == 4096:
            out.append(bytes.fromhex(line))
    if not out:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return out


def differ(want, got):
    return [a for a in range(0x0800)
            if a not in SKIP and want[a] != got[a]]


def main():
    only = [int(a) for a in sys.argv[1:] if not a.startswith('--')]
    scratch = P.scratch('script')
    try:
        bad = total = seen = 0
        for st in STAGES:
            if only and st not in only:
                continue
            base = P.make_state(os.path.join(scratch, 'base'))
            first = V.BASE if st == 0 else V.WARPED
            state = (base if st == 0 else
                     P.warp(os.path.join(scratch, 's%d' % st), st, base))
            rows = []
            all_spots = spots()
            for k in range(0, len(all_spots), PER_RUN):
                pre, post = play(state, scratch, first,
                                 all_spots[k:k + PER_RUN], '%d_%d' % (st, k))
                rows += pairs(pre, post)
            if len(rows) < 8:
                print('s%-4d the script was never entered' % st)
                bad += 1
                total += 1
                continue
            total += 1
            seen += len(rows)
            got = engine([m for _fr, m, _p in rows], scratch)
            if len(got) != len(rows):
                print('s%-4d the engine answered %d of %d pictures'
                      % (st, len(got), len(rows)))
                bad += 1
                continue
            where = None
            wild = owed = 0
            for i, (_fr, _m, want) in enumerate(rows):
                if got[i] == '!':
                    wild += 1
                    continue
                if got[i] == '?':
                    owed += 1
                    continue
                d = differ(want, got[i])
                if d:
                    where = (i, d)
                    break
            if where is None:
                print('s%-4d ok, %d pictures, %d off the end of a table, '
                      '%d on an owed call'
                      % (st, len(rows) - wild - owed, wild, owed))
                continue
            bad += 1
            i, d = where
            fr, seed, want = rows[i]
            print('s%-4d differs on picture %d (frame %d, room $%02X, '
                  '$7F=%02X $58=%02X)'
                  % (st, i, fr, (((seed[0x33] + 8) & 0xF0)
                                 + (((seed[0x31] + 8) & 0xFF) >> 4)) & 0xFF,
                     seed[0x7F], seed[0x58]))
            for a in d[:12]:
                print('        $%04X  was $%02X, cartridge $%02X, engine $%02X'
                      % (a, seed[a], want[a], got[i][a]))
        known = set()
        d = json.load(open(os.path.join(ROOT, 'game', 'data', 'sol',
                                        'script.json')))
        for one in d['dispatch']:
            known.update('%04X' % a for a in one['routines'])
        for t in d['tables'].values():
            known.update('%04X' % a for a in t)
        print('%d of %d stages differ, %d pictures compared, '
              '%d of %d routines seen run'
              % (bad, total, seen, len(SEEN & known), len(known)))
        rest = sorted(known - SEEN)
        if rest:
            print('not seen run: ' + ' '.join(rest))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


if __name__ == '__main__':
    sys.exit(main())
