#!/bin/sh
# start the playthrough stand of this worktree if it is not running
R=$(cd "$(dirname "$0")/../../.." && pwd)
pgrep -f "$R/game --script res://tests/playthrough.gd" >/dev/null && exit 0
/Applications/Godot_mono.app/Contents/MacOS/Godot --path "$R/game" --script res://tests/playthrough.gd > "$TMPDIR/nova-pb2c/stand.log" 2>&1 &
sleep 6
