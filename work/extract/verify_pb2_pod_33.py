#!/usr/bin/env python3
"""Compare the pod $33 that the hatch $2F lets out, and the children it
breaks into ($30, $31, $32), with an unmodified NES cartridge.

A pod is poked into the first child place of the first area, high above the
floor and far from the hero; the cartridge then plays it with no change to its
code.  The work RAM is taken at $CF1C, just before every thing gets its turn,
and PB3 is asked to take the same turn from the same RAM.  Injected fixtures
isolate the object logic; they do not certify a level.
"""
import json
import os
import pathlib
import struct
import subprocess
import sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'tools'))
import pb2_probe as P
GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'
TURNS = 0xCF1C


def records(path):
    data = pathlib.Path(path).read_bytes()
    out = []
    for at in range(0, len(data), 2056):
        chunk = data[at:at + 2056]
        if len(chunk) != 2056:
            raise RuntimeError('Incomplete RAM capture')
        frame, _pc, _bank = struct.unpack('<IHH', chunk[:8])
        out.append((frame, list(chunk[8:])))
    return out


def main():
    tmp = P.scratch('pod-33')
    try:
        state = P.make_state(os.path.join(tmp, 'start.state'), stage=0, area=0)
        first = P.IN_LEVEL + 2
        cases = []
        for name, rec, x, y in [('pod-homing', 0, 200, 40), ('pod-hopping', 1, 200, 40),
                                  ('pod-walking', 2, 200, 40)]:
            pokes = []
            # Everything else in the room is taken away, so that nothing but
            # the pod and its own children ever stands in a child place.
            pokes += [(P.field(0, slot), 0, first) for slot in range(7, 22)]
            row = [0] * 29
            row[0] = 0x33; row[1] = 8; row[9] = y; row[12] = x
            row[18] = 3; row[22] = rec
            pokes += [(P.field(f, 6), v, first) for f, v in enumerate(row)]
            dump = os.path.join(tmp, name + '.bin')
            cmd = P.emu('-loadstate', state, '-frames', str(first + 400),
                        '-ramat', '%s@%04X' % (dump, TURNS))
            for a, v, fr in pokes:
                cmd += ['-poke', '%04X=%02X@%d' % (a, v, fr)]
            subprocess.run(cmd, check=True, capture_output=True, timeout=120)
            snaps = [(f, m) for f, m in records(dump) if f > first]
            if len(snaps) < 200:
                raise RuntimeError('Too few turns captured: %d' % len(snaps))
            kinds = set()
            for _f, m in snaps:
                for slot in range(6, 14):
                    kinds.add(m[P.field(0, slot)])
            if 0x30 + rec not in kinds:
                raise RuntimeError('%s: the pod never broke open (%s)' % (name, sorted(kinds)))
            cases.append(dict(name=name, snaps=[dict(frame=f, ram=m[:0x700]) for f, m in snaps]))
        path = os.path.join(tmp, 'oracle.json')
        with open(path, 'w') as stream:
            json.dump(dict(cases=cases), stream)
        result = subprocess.run([GODOT, '--headless', '--path', os.path.join(P.ROOT, 'game'),
                                 '--script', 'res://tests/pb2_pod_33_test.gd', '--', path],
                                capture_output=True, text=True, timeout=120)
        print(result.stdout, end=''); print(result.stderr, end='')
        return result.returncode or int('ERROR:' in result.stderr
                                        or 'NES pod $33:' not in result.stdout)
    finally:
        P.sweep(tmp)


if __name__ == '__main__':
    sys.exit(main())
