#!/usr/bin/env python3
"""Can the player actually get anywhere?

`areatest` only proves an area loads.  This one drops the player into it and
holds the stick, tapping jump, for a few seconds: if the level is playable the
camera moves.  An area where the camera never budges is one the player is
walled into, and that is the difference between a level and a picture of one.
"""
import os, subprocess, sys, tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'work/tools'))
sys.path.insert(0, os.path.join(ROOT, 'work/pb3'))
import mkinput, sol2pb2

EMU = os.path.join(ROOT, 'work/tools/nesemu')
ROM = os.path.join(ROOT, 'work/build/PB3.nes')
STAGES = {7: 0, 8: 1, 9: 2, 10: 3, 11: 4, 12: 5, 13: 6, 14: 13, 15: 15}
HOLD = 480                      # eight seconds of walking


def hold(entry, keys='RIGHT'):
    """Hold a direction, tapping jump twice a second so a ledge is not the end
    of the run."""
    lf = mkinput.launch_frame(entry)
    play = [(lf + 60, keys)]
    for i in range(lf + 90, lf + 60 + HOLD, 30):
        play += [(i, keys + ' A'), (i + 8, keys)]
    return mkinput.script(entry, play=play), lf


def run(entry, area, keys, d):
    inp, dump = os.path.join(d, 'i.inp'), os.path.join(d, 'r.bin')
    text, lf = hold(entry, keys)
    open(inp, 'w').write(text)
    subprocess.run([EMU, ROM, '-input', inp, '-frames', str(lf + 60 + HOLD),
                    '-ramdump', dump, '-freeze', '9C=%02X' % area],
                   capture_output=True)
    r = open(dump, 'rb').read()
    return r


def main():
    moved = stuck = 0
    d = tempfile.mkdtemp()
    for entry, stage in STAGES.items():
        st = sol2pb2.convert(stage)[0]
        line = []
        for a, kind in enumerate(st.pb3_kinds):
            best = 0
            for keys in ('RIGHT', 'LEFT') if kind == 'h' else ('RIGHT', 'LEFT'):
                r = run(entry, a, keys, d)
                if r[0x27] != 3:
                    continue
                best = max(best, r[0x66] * 256 + r[0x67] if kind == 'h'
                           else r[0x66] * 240 + r[0x67])
            line.append('.' if best == 0 else
                        ('-' if best < 64 else str(min(best // 256, 9))))
            moved += best >= 64
            stuck += best < 64
        print(f"entry {entry:2d} solbrain {stage:2d}: {''.join(line)}")
    print(f"{moved}/{moved + stuck} areas the player can move through")
    return 0


if __name__ == '__main__':
    sys.exit(main())
