#!/usr/bin/env python3
"""NES background bank oracle plus cross-game belt regressions (placed fixtures)."""
import json
import os
import subprocess
import sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'tools'))
import pb2_probe as P
GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'


def main():
    tmp = P.scratch('environment')
    try:
        cases = []
        for stage, area in [(0, 2), (2, 0), (2, 3), (2, 4), (3, 5), (5, 1)]:
            state = P.make_state(os.path.join(tmp, f'{stage}-{area}.state'), stage=stage, area=area)
            # Read normal ROM execution. No patched code, frozen memory or invulnerability.
            writes = P.run(state, [(P.IN_LEVEL, '-')], P.IN_LEVEL + 540)
            rows = []
            for frame, values in P.table(writes, [0x1c, 0x43, 0x5c, 0x4d], P.IN_LEVEL, P.IN_LEVEL + 540):
                if all(addr in values for addr in [0x1c, 0x43, 0x5c]):
                    rows.append([frame, values[0x1c], values[0x43], values[0x5c], values.get(0x4d, 0)])
            if len(rows) < 100:
                raise RuntimeError(f'insufficient NES frames for {stage}:{area}: {len(rows)}')
            cases.append(dict(stage=stage, area=area, rows=rows))
        path = os.path.join(tmp, 'oracle.json')
        with open(path, 'w') as stream:
            json.dump(cases, stream)
        result = subprocess.run([GODOT, '--headless', '--path', os.path.join(P.ROOT, 'game'),
                                 '--script', 'res://tests/pb3_environment_test.gd', '--', path],
                                capture_output=True, text=True, timeout=120)
        print(result.stdout, end=''); print(result.stderr, end='')
        return int(result.returncode != 0 or 'ERROR:' in result.stderr
                   or 'environment checks failed' not in result.stdout or 'FAIL:' in result.stdout)
    finally:
        P.sweep(tmp)


if __name__ == '__main__':
    sys.exit(main())
