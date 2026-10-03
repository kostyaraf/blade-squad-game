#!/bin/sh
# beam.sh PREFIX(dir name in docs/qa/playthrough or json path) OUT.json WP [qa_beam args...]
R=$(cd "$(dirname "$0")/../../.." && pwd)
P=$1; case $P in /*) ;; *) P=$R/docs/qa/playthrough/$P/replay.json;; esac
O=$2; W=$3; shift 3
/Applications/Godot_mono.app/Contents/MacOS/Godot --headless --path "$R/game" --script res://tests/qa_beam.gd -- --replay="$P" --out="$TMPDIR/nova-pb2c/$O" --wp="$W" "$@" 2>&1 | grep -E "^it|RESULT|STUCK|DEAD|SCRIPT ERROR" | tail -6
