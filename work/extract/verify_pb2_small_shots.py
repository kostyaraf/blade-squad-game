#!/usr/bin/env python3
"""Compare missing bullet/trail minds with an unmodified NES cartridge.
Injected fixtures isolate object logic; they do not certify level completion.
"""
import json
import os
import subprocess
import sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'tools'))
import pb2_probe as P
GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'


def main():
    tmp = P.scratch('small-shots')
    try:
        state = P.make_state(os.path.join(tmp, 'start.state'), stage=0, area=0)
        cases = []
        for name, kind, vx, vy, parent in [
            ('bullet-right', 0x16, 3, 0, 0),
            ('bullet-left', 0x16, 0xFD, 0, 0),
            ('bullet-down', 0x16, 0, 3, 0),
            ('trail-expiry', 0x18, 0, 0, 0x17),
            ('trail-orphan', 0x18, 0, 0, 0),
            ('aimed-delay', 0x2A, 0, 3, 0),
            ('aimed-no-delay', 0x2A, 3, 0, 0),
            ('hatchling', 0x1F, 0, 0, 0),
        ]:
            row = [0] * 29
            row[0] = kind; row[1] = 8; row[9] = 80; row[12] = 100
            row[14] = vy; row[16] = vx; row[21] = 20 if kind == 0x18 else (5 if name == 'aimed-delay' else 0)
            pokes = [(P.field(f, 6), v, 2) for f, v in enumerate(row)]
            # Parent placed above the hero, out of contact. Native AI runs normally.
            par = [0] * 29
            par[0] = parent; par[9] = 50; par[12] = 160
            pokes += [(P.field(f, 20), v, 2) for f, v in enumerate(par)]
            writes = P.run(state, [(1, '-')], 70, pokes=pokes)
            addrs = [P.field(f, 6) for f in range(29)] + [0x1c, 0x66, 0x67, 0x119, P.field(0,20)]
            cur = {P.field(f, 6): v for f, v in enumerate(row)}
            cur.update({0x1c: 0, 0x119: 0, 0x66: 2, 0x67: 0, P.field(0,20):parent})
            frames = []; initial = None; last = 0
            for fr, values in P.table(writes, addrs, 2, 70):
                cur.update(values)
                vals = [cur[a] for a in addrs[:29]]
                if initial is None:
                    initial = vals; cam = cur[0x66] * 256 + cur[0x67]; clock = cur[0x119]
                else:
                    frames.append(dict(frame=fr, turns=(cur[0x1c]-last)&255,
                                       row=vals, parent=cur[P.field(0,20)]))
                last = cur[0x1c]
            cases.append(dict(name=name, initial=initial, cam=cam, clock=clock, frames=frames))
        path = os.path.join(tmp, 'oracle.json')
        with open(path, 'w') as stream:
            json.dump(dict(cases=cases), stream)
        result = subprocess.run([GODOT, '--headless', '--path', os.path.join(P.ROOT,'game'),
                                 '--script', 'res://tests/pb2_small_shots_test.gd', '--', path],
                                capture_output=True, text=True, timeout=40)
        print(result.stdout, end=''); print(result.stderr, end='')
        return result.returncode or int('ERROR:' in result.stderr)
    finally:
        P.sweep(tmp)


if __name__ == '__main__':
    sys.exit(main())
