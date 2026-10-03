#!/usr/bin/env python3
"""Replay completed input-only routes; never inject game state."""
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[2]
GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'


def main():
    result = subprocess.run(
        [GODOT, '--headless', '--path', str(ROOT / 'game'), '--script',
         'res://tests/pb3_playthrough_test.gd'],
        capture_output=True, text=True, timeout=900)
    print(result.stdout, end='')
    print(result.stderr, end='')
    bad = int(result.returncode != 0 or 'FAIL:' in result.stdout
               or 'ERROR:' in result.stderr
               or 'recorded playthroughs failed' not in result.stdout)
    print('%d of 1 playthrough suites differ' % bad)
    return bad


if __name__ == '__main__':
    raise SystemExit(main())
