#!/usr/bin/env python3
"""PB3 cross-game geometry: rendered pixels, obstacle regressions and routes.

The pixel oracle reads the original atlas at the collision system's point.
Traversal covers sampled map segments, not full boss/level completion.
"""
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'


def main():
    scripts = [('geometry', 'geometry checks failed', '--headless' not in sys.argv),
               ('obstacles', 'obstacle checks failed', False)]
    if '--quick' not in sys.argv:
        scripts.append(('traversal', 'traversal cases failed', False))
    if '--capture' in sys.argv:
        scripts.append(('visual', 'Visual captures complete', True))
    bad = 0
    for name, verdict, rendered in scripts:
        command = [GODOT, '--path', str(ROOT / 'game'),
                   '--script', f'res://tests/pb3_{name}_test.gd']
        if not rendered:
            command.insert(1, '--headless')
        result = subprocess.run(command, capture_output=True, text=True, timeout=360)
        print(result.stdout, end='', flush=True)
        print(result.stderr, end='', file=sys.stderr, flush=True)
        errors = ('SCRIPT ERROR:', 'SHADER ERROR:', 'ERROR:', 'FAIL ')
        failed = result.returncode != 0 or verdict not in result.stdout or any(
            term in result.stdout + result.stderr for term in errors)
        bad += int(failed)
    print(f'{bad} of {len(scripts)} geometry suites differ')
    return int(bad > 0)


if __name__ == '__main__':
    sys.exit(main())
