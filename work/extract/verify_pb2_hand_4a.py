#!/usr/bin/env python3
"""Compare both boss $52 shutters ($4A) with the unmodified PB2 cartridge.
Injected fixtures certify the module, not a level playthrough.
"""
import json
import os
import pathlib
import struct
import subprocess
import sys
ROOT = pathlib.Path(__file__).resolve().parents[2] if pathlib.Path(__file__).parent.name == "extract" else pathlib.Path.cwd()
sys.path.insert(0, str(ROOT / "work" / "tools"))
import pb2_probe as P
GODOT = "/Applications/Godot_mono.app/Contents/MacOS/Godot"
TURNS = 0xCF1C


def records(path):
    data = pathlib.Path(path).read_bytes()
    if len(data) % 2056:
        raise RuntimeError("Incomplete RAM capture")
    for at in range(0, len(data), 2056):
        frame, _pc, _bank = struct.unpack("<IHH", data[at:at + 8])
        yield frame, list(data[at + 8:at + 2056])


def row(self_value=0, state=0, x=0, y=0, vx=0, vy=0, fractions=False):
    r = [0] * 29
    r[0] = 0x4A; r[1] = 8; r[21] = self_value
    r[18] = state; r[12] = x; r[9] = y; r[16] = vx; r[14] = vy
    if state:
        r[7] = 255; r[4] = 12
        animation = json.loads((ROOT / "game/data/pb2/objects.json").read_text())["anims"][12]
        r[3] = animation["first"]; r[19] = animation["hold"]
    if fractions:
        r[10] = 93; r[13] = 141; r[15] = 129; r[17] = 193
    return r


def main():
    tmp = P.scratch("hand-4a")
    try:
        state = P.make_state(os.path.join(tmp, "start.state"), stage=0, area=0)
        first = P.IN_LEVEL + 2
        fixtures = [
            ("birth-right", row(0), 1100),
            ("birth-left", row(1), 1100),
            ("two-shutters", [row(0), row(1)], 1100),
        ]
        # Each initial clock phase covers strict/equal edge comparisons and
        # the native wait-for-eighth-clock rule without replacing ROM code.
        for phase in range(8):
            for name, st, x, y, vx, vy in [
                ("right", 1, 237, 154, 1, 0),
                ("up", 2, 238, 37, 0, 255),
                ("left", 3, 19, 71, 255, 0),
                ("down", 4, 18, 153, 0, 1),
            ]:
                fixtures.append((f"corner-{name}-{phase}", row(0, st, x, y, vx, vy), 24, phase))
        for name, st, x, y, vx, vy in [
            ("right", 1, 237, 154, 1, 0),
            ("up", 2, 238, 37, 0, 255),
            ("left", 3, 19, 71, 255, 0),
            ("down", 4, 18, 153, 0, 1),
        ]:
            fixtures.append(("fraction-" + name, row(0, st, x, y, vx, vy, True), 24))
        cases = []
        for fixture in fixtures:
            name, rows, duration = fixture[:3]
            phase = fixture[3] if len(fixture) == 4 else None
            if isinstance(rows[0], int):
                rows = [rows]
            pokes = [(P.field(0, slot), 0, first) for slot in range(6, 22)]
            for slot, fixture_row in enumerate(rows, 6):
                pokes += [(P.field(f, slot), v, first) for f, v in enumerate(fixture_row)]
            if phase is not None:
                pokes.append((0x119, phase, first))
            dump = os.path.join(tmp, name + ".bin")
            cmd = P.emu("-loadstate", state, "-frames", str(first + duration),
                        "-ramat", "%s@%04X" % (dump, TURNS))
            for a, v, fr in pokes:
                cmd += ["-poke", "%04X=%02X@%d" % (a, v, fr)]
            subprocess.run(cmd, check=True, capture_output=True, timeout=180)
            snaps = [(f, m) for f, m in records(dump) if f >= first]
            if len(snaps) < duration - 1:
                raise RuntimeError("Too few turns captured for %s: %d" % (name, len(snaps)))
            if snaps[0][1][P.field(18, 6)] != rows[0][18]:
                raise RuntimeError("Fixture was not captured before first object turn: " + name)
            if duration > 100:
                seen = {m[P.field(18, 6)] for _, m in snaps}
                if not {0, 1, 2, 3, 4} <= seen:
                    raise RuntimeError("Missing native states for %s: %s" % (name, sorted(seen)))
            cases.append(dict(name=name, snaps=[dict(frame=f, ram=m[:0x700]) for f, m in snaps]))
        path = os.path.join(tmp, "oracle.json")
        pathlib.Path(path).write_text(json.dumps(dict(cases=cases)))
        if "--oracle-only" in sys.argv:
            print("NES hand $4A oracle: %d fixtures, %d captured turns" % (len(cases), sum(len(c["snaps"]) for c in cases)))
            return 0
        result = subprocess.run([GODOT, "--headless", "--path", str(ROOT / "game"),
                                 "--script", "res://tests/pb2_hand_4a_test.gd", "--", path],
                                capture_output=True, text=True, timeout=180)
        print(result.stdout, end=""); print(result.stderr, end="")
        return result.returncode or int("SCRIPT ERROR" in result.stdout + result.stderr
                                        or "ERROR:" in result.stderr
                                        or "NES hand $4A: 0 / " not in result.stdout)
    finally:
        P.sweep(tmp)


if __name__ == "__main__":
    sys.exit(main())
