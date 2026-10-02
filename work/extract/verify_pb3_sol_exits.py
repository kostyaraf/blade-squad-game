#!/usr/bin/env python3
"""Solbrain standing gates and full departure sequences for every party.

These are integration regressions, not proof of a complete playthrough.
Godot can exit successfully after script errors, so inspect stderr too.
"""
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'


def main():
    result = subprocess.run(
        [GODOT, '--headless', '--path', str(ROOT / 'game'),
         '--script', 'res://tests/pb3_sol_exits_test.gd', '--'] + sys.argv[1:],
        capture_output=True, text=True, timeout=300)
    print(result.stdout, end='')
    errors = ('SCRIPT ERROR:', 'SHADER ERROR:', 'ERROR:')
    bad = (result.returncode != 0
           or any(e in result.stderr for e in errors)
           or 'exit checks failed' not in result.stdout
           or 'FAIL:' in result.stdout)
    if result.stderr:
        print(result.stderr, file=sys.stderr, end='')
    print('%d of 1 exit suites differ' % int(bad))
    return int(bad)


if __name__ == '__main__':
    sys.exit(main())
