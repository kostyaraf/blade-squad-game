#!/usr/bin/env python3
"""Run the Nova mesh-grip integration suite; placed cases are not playthroughs."""
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[2]
result = subprocess.run([
    '/Applications/Godot_mono.app/Contents/MacOS/Godot', '--headless',
    '--path', str(root / 'game'), '--script', 'res://tests/pb3_nova_net_test.gd'],
    capture_output=True, text=True, timeout=120)
print(result.stdout, end='')
print(result.stderr, end='')
raise SystemExit(int(result.returncode != 0 or 'ERROR:' in result.stderr
                     or 'FAIL:' in result.stdout or 'Nova net checks failed' not in result.stdout))
