#!/usr/bin/env python3
"""Boot PB3, walk its stage list, and check that every entry reaches gameplay.

The ramdump is $0000-$07FF followed by $6000-$7FFF, so a work-RAM address is
at 0x800 + (addr - 0x6000)."""
import os, subprocess, sys, tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'work/tools'))
sys.path.insert(0, os.path.join(ROOT, 'work/pb3'))
import mkinput, build

EMU = os.path.join(ROOT, 'work/tools/nesemu')
ROM = os.path.join(ROOT, 'work/build/PB3.nes')


def run(entry, players=1, hero=0, extra=300):
    d = tempfile.mkdtemp()
    inp, dump = os.path.join(d, 'i.inp'), os.path.join(d, 'r.bin')
    open(inp, 'w').write(mkinput.script(entry, players, hero))
    n = mkinput.launch_frame(entry, players, hero) + extra
    subprocess.run([EMU, ROM, '-input', inp, '-frames', str(n),
                    '-ramdump', dump], capture_output=True)
    r = open(dump, 'rb').read()
    return {'state': r[0x27], 'stage': r[0x53], 'world': r[0x800 + 0x71],
            'want2p': r[0x800 + 0x73], 'hero': r[0x800 + 0x74],
            'p2': r[0x442 + build.P2_SLOT]}


def main():
    ok = 0
    for i, (label, world, node) in enumerate(build.MENU_LIST):
        r = run(i)
        good = r['state'] == 3 and r['stage'] == node and r['world'] == world
        ok += good
        print(f"{i:2d} {label:16s} $27={r['state']} $53={r['stage']} "
              f"world={r['world']}  {'ok' if good else 'FAILED'}")
    r = run(7, players=2)
    two = r['state'] == 3 and r['want2p'] == 1 and r['p2'] != 0
    print(f"\ntwo players: $27={r['state']} want2p={r['want2p']} "
          f"slot{build.P2_SLOT}={r['p2']:02X}  {'ok' if two else 'FAILED'}")
    print(f"{ok}/{len(build.MENU_LIST)} stages reach gameplay")
    return 0 if ok == len(build.MENU_LIST) and two else 1


if __name__ == '__main__':
    sys.exit(main())
