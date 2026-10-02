#!/usr/bin/env python3
"""PB2 gate oracle from unmodified NES code plus PB3 party integration tests.

Fixtures isolate the gate; they are not full playthrough evidence. Capture RAM
at entry and both returns of $B5A5, filtering the actually mapped bank (7).
"""
import json
import pathlib
import struct
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'work' / 'tools'))
import pb2_probe as P

GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'


def records(path):
    if not path.exists():
        return []
    data = path.read_bytes()
    size = 8 + 2048
    if len(data) % size:
        raise RuntimeError('Truncated NES RAM capture')
    result = []
    for offset in range(0, len(data), size):
        frame, _pc, bank = struct.unpack('<IHH', data[offset:offset + 8])
        if bank == 7:
            result.append((frame, data[offset + 8:offset + size]))
    return result


def oracle(folder):
    state = P.make_state(str(folder / 'base'), stage=0, area=4)
    cases = []
    for name, kind, pad, mark, switch in [
        ('idle', 3, 0, 0, 0), ('switch-only', 3, 0, 0, 8),
        ('up', 3, 8, 0, 0), ('air-up', 3, 8, 1, 0),
        ('attack-up', 3, 8, 2, 0), ('area-no-up', 4, 0, 0, 0),
    ]:
        inp = folder / (name + '.inp')
        inp.write_text('%d %s\n' % (P.IN_LEVEL, 'UP' if pad else '-'))
        pre, post, post2 = [folder / (name + suffix)
                            for suffix in ('pre', 'post', 'post2')]
        cmd = [P.EMU, P.ROM, '-loadstate', state, '-input', str(inp),
               '-frames', str(P.IN_LEVEL + 7),
               '-ramat', str(pre) + '@B5A5', '-ramat', str(post) + '@B5B6',
               '-ramat', str(post2) + '@B5CC']
        # Initial placement only. The cartridge polls the controller and runs
        # the original contact routine; no patched ROM or forced gate result.
        values = {0x3b: switch, 0x0416: mark, 0x049a: 16,
                  0x0508: 128, 0x04c6: 143, 0x0300: 128, 0x0320: 143}
        row = [0] * 29
        row[0], row[1], row[7], row[9], row[12], row[18] = kind, 16, 255, 128, 128, 1
        values.update({P.field(i, 6): value for i, value in enumerate(row)})
        for address, value in values.items():
            cmd += ['-poke', '%04X=%02X@%d' % (address, value, P.IN_LEVEL + 1)]
        subprocess.run(cmd, check=True, capture_output=True, timeout=60)
        before = records(pre)
        after = sorted(records(post) + records(post2), key=lambda record: record[0])
        if not before or len(before) != len(after):
            raise RuntimeError('%s: missing native entry/return coverage' % name)
        initial = before[0][1]
        if (initial[0x416], initial[0x4a], initial[0x3b]) != (mark, pad, switch):
            raise RuntimeError('%s: intended initial contact was not executed' % name)
        for (frame, old), (returned, new) in zip(before, after):
            if frame != returned or old[P.field(0, 6)] != kind:
                raise RuntimeError('%s: ambiguous native call pairing' % name)
            cases.append(dict(name=name, kind=kind, hero_mark=old[0x416],
                              pad=old[0x4a], switch=old[0x3b],
                              state=old[P.field(18, 6)], mark=old[P.field(1, 6)],
                              expected_state=new[P.field(18, 6)],
                              expected_mark=new[P.field(1, 6)]))
    path = folder / 'oracle.json'
    path.write_text(json.dumps(cases))
    print('%d executed NES gate calls captured' % len(cases))
    return path


def main():
    folder = pathlib.Path(P.scratch('boss-gates'))
    try:
        path = oracle(folder)
        result = subprocess.run(
            [GODOT, '--headless', '--path', str(ROOT / 'game'),
             '--script', 'res://tests/pb3_boss_gates_test.gd', '--', '--oracle=' + str(path)],
            capture_output=True, text=True, timeout=300)
        print(result.stdout, end='')
        print(result.stderr, file=sys.stderr, end='')
        bad = (result.returncode != 0 or 'ERROR:' in result.stderr
               or 'FAIL:' in result.stdout or 'boss gate checks failed' not in result.stdout)
        print('%d of 1 boss gate suites differ' % int(bad))
        return int(bad)
    finally:
        P.sweep(str(folder))


if __name__ == '__main__':
    sys.exit(main())
