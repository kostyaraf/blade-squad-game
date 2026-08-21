#!/usr/bin/env python3
"""Boot straight into every area of every converted stage and check it runs.

The stage list only ever starts at area 0, so the rest of a converted stage
goes untested until the player walks there.  Freezing $9C makes the engine
load whichever area we name, which is enough to catch a level whose data does
not decode -- the game either reaches gameplay ($27 = 3) or it does not."""
import os, subprocess, sys, tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'work/tools'))
sys.path.insert(0, os.path.join(ROOT, 'work/pb3'))
import mkinput, build, sol2pb2

EMU = os.path.join(ROOT, 'work/tools/nesemu')
ROM = os.path.join(ROOT, 'work/build/PB3.nes')
STAGES = {7: 0, 8: 1, 9: 2, 10: 3, 11: 4, 12: 5, 13: 6, 14: 13, 15: 15}


def run(entry, area, extra=400, png=None):
    d = tempfile.mkdtemp()
    inp, dump = os.path.join(d, 'i.inp'), os.path.join(d, 'r.bin')
    open(inp, 'w').write(mkinput.script(entry))
    n = mkinput.launch_frame(entry) + extra
    cmd = [EMU, ROM, '-input', inp, '-frames', str(n), '-ramdump', dump,
           '-freeze', '9C=%02X' % area]
    if png:
        cmd += ['-png', png, '-shot', str(n - 10)]
    subprocess.run(cmd, capture_output=True)
    r = open(dump, 'rb').read()
    return r[0x27]


def main(png_dir=None):
    ok = bad = 0
    for entry, stage in STAGES.items():
        st = sol2pb2.convert(stage)[0]
        line = []
        for a, kind in enumerate(st.pb3_kinds):
            p = os.path.join(png_dir, 'e%02d_a%02d' % (entry, a)) if png_dir else None
            good = run(entry, a, png=p) == 3
            ok += good; bad += not good
            line.append(('V' if kind == 'v' else 'h') if good else '!')
        print(f"entry {entry:2d} solbrain {stage:2d}: {''.join(line)}")
    print(f"{ok}/{ok + bad} areas reach gameplay")
    return 0 if not bad else 1


if __name__ == '__main__':
    sys.exit(main(*sys.argv[1:]))
