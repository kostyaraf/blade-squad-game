#!/usr/bin/env python3
"""Focused ROM regression: native alpha/beta pickup and first-two-slot blink.

The cartridge is seeded in s0 after BASE=2320. A letter object is placed on
its own hero on frame 2330. The result after native contact at 2331 is compared
with SolObjects._pick_up() for identical inputs. This is a module test, not a
playthrough. born_wait=255 suppresses a satellite birth while isolating the
already-full case; it never freezes gameplay because it is above $30.
"""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys

FIELDS = {'id': 0x600, 'mind': 0x650, 'a': 0x610, 'b': 0x620,
          'letters': 0x5C4, 'blink0': 0x70C, 'blink1': 0x70D, 'blink2': 0x70E}



def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--root', default=str(Path(__file__).resolve().parents[2]))
    ap.add_argument('--rom-only', action='store_true', help='write and print fixtures; do not start Godot')
    ap.add_argument('--fixture-out', help='optional saved fixture JSON')
    args = ap.parse_args()
    root = Path(args.root).resolve()
    sys.path.insert(0, str(root / 'work' / 'tools'))
    import sol_probe as P
    scratch = P.scratch('pickups')
    try:
        state = P.make_state(os.path.join(scratch, 's0.state'), frame=2320)
        base = P.ram(state, [(2321, '-')], 2329)
        hx = base[0x80] | base[0x81] << 8
        hy = base[0x82] | base[0x83] << 8
        cases = []
        for letter, mind, pic, flags in [('alpha',8,68,0x85), ('beta',9,70,0x86)]:
            for label, letters in [('first',0), ('second',1), ('third',5), ('full',0x15)]:
                puts = {0x5C3:255,0x5C4:letters,0x70C:0,0x70D:0,0x70E:0,
                        0x600:0x41,0x650:mind,0x660:pic,0x670:0,0x610:0,0x620:0,
                        0x6E0:255,0x680:0,0xA0:hx&255,0xB0:hx>>8,
                        0xC0:hy&255,0xD0:hy>>8}
                ram = P.ram(state, [(2321, '-')], 2331,
                            pokes=[(a,v,2330) for a,v in puts.items()])
                cases.append({'name':f'{letter} {label}', 'mind':mind,
                              'flags':flags, 'letters':letters, 'hero':[hx,hy],
                              'pokes':[[a,v,2330] for a,v in puts.items()],
                              'want':{k:ram[a] for k,a in FIELDS.items()}})
        fixture = os.path.join(scratch,'cases.json')
        Path(fixture).write_text(json.dumps(cases,indent=2)+'\n')
        if args.fixture_out:
            Path(args.fixture_out).write_text(json.dumps(cases,indent=2)+'\n')
        if args.rom_only:
            for one in cases: print(one['name'], json.dumps(one['want']))
            return 0
        runner = 'res://tests/sol_pickups_test.gd'
        r = subprocess.run(['/Applications/Godot_mono.app/Contents/MacOS/Godot',
                            '--headless','--path',str(root/'game'),'--script',runner,
                            '--',fixture],capture_output=True,text=True,timeout=60)
        if r.returncode or 'ERROR:' in r.stdout+r.stderr or 'FAIL:' in r.stdout:
            print(r.stdout+r.stderr, file=sys.stderr)
            return 1
        got = {}
        for line in r.stdout.splitlines():
            if line.startswith('PICKUP '):
                one = json.loads(line[7:]); got[one['name']] = one['got']
        bad = 0
        for one in cases:
            answer = got.get(one['name'])
            if answer != one['want']:
                bad += 1; print(one['name'], 'DIFF ROM',one['want'],'engine',answer)
            else: print(one['name'],'ok')
        print(f'{bad} of {len(cases)} pickups differ')
        return int(bad != 0)
    finally:
        P.sweep(scratch)

if __name__ == '__main__':
    sys.exit(main())
