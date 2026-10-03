#!/usr/bin/env python3
"""Compare nest children $1C with the unmodified PB2 cartridge.
Injected fixtures certify the handler, not a room playthrough.
"""
import json
import os
import pathlib
import struct
import subprocess
import sys
import tempfile
ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "work/tools"))
import pb2_probe as P
GODOT = "/Applications/Godot_mono.app/Contents/MacOS/Godot"


def records(path):
    data = pathlib.Path(path).read_bytes()
    if len(data) % 2056:
        raise RuntimeError("Incomplete RAM capture")
    for at in range(0, len(data), 2056):
        frame, _pc, _bank = struct.unpack("<IHH", data[at:at + 8])
        yield frame, list(data[at + 8:at + 2056])


def main():
    base = pathlib.Path(os.environ.get("TMPDIR", tempfile.gettempdir())) / "nova-pb2b"
    base.mkdir(parents=True, exist_ok=True)
    tmp = pathlib.Path(tempfile.mkdtemp(prefix="nest-1c-", dir=base))
    try:
        cases = []
        first = P.IN_LEVEL + 2
        for stage, area in [(0, 0), (1, 7)]:
            state = tmp / (f"p{stage}.{area}.state")
            inp = tmp / "boot.inp"
            inp.write_text(P.BOOT)
            subprocess.run(P.emu("-input", str(inp), "-frames", str(P.IN_LEVEL + 1),
                                 "-savestate", f"{state}@{P.IN_LEVEL}",
                                 "-poke", f"0053={stage:02X}@{P.PICK_LEVEL}",
                                 "-poke", f"009C={area:02X}@{P.PICK_LEVEL}"),
                           check=True, capture_output=True, timeout=180)
            fixtures = []
            for phase in (0, 1):
                for x, y in [(40, 80), (128, 120), (224, 180)]:
                    for st in (0, 1, 2):
                        fixtures.append((f"state{st}-{x}-{y}-phase{phase}", st, x, y, phase, 100))
                fixtures.append((f"burst-phase{phase}", 3, 128, 100, phase, 20))
            for name, st, x, y, phase, duration in fixtures:
                row = [0] * 29
                row[0] = 0x1C; row[1] = 8 if st == 0 else 1
                row[9] = y; row[12] = x; row[18] = st
                row[10] = 93; row[13] = 141
                if st:
                    row[7] = 1; row[14] = 1 if st == 1 else 0
                    row[16] = 255; row[17] = 0
                    row[22] = 16 if st == 3 else 0
                    anim = json.loads((ROOT / "game/data/pb2/objects.json").read_text())["anims"][1 if st == 3 else 13]
                    row[4] = 1 if st == 3 else 13
                    row[3] = anim["first"]; row[19] = anim["hold"]
                pokes = [(P.field(0, slot), 0, first) for slot in range(6, 22)]
                pokes += [(P.field(f, 6), v, first) for f, v in enumerate(row)]
                pokes.append((0x119, phase, first))
                dump = tmp / "capture.bin"
                cmd = P.emu("-loadstate", str(state), "-frames", str(first + duration),
                            "-ramat", f"{dump}@CF1C")
                for addr, val, frame in pokes:
                    cmd += ["-poke", f"{addr:04X}={val:02X}@{frame}"]
                subprocess.run(cmd, check=True, capture_output=True, timeout=180)
                snaps = [(fr, ram) for fr, ram in records(dump) if fr >= first]
                dump.unlink()
                if len(snaps) < duration - 1:
                    raise RuntimeError(f"Too few NES turns: p{stage}.{area} {name}: {len(snaps)}")
                if snaps[0][1][P.field(18, 6)] != st:
                    raise RuntimeError("Fixture was not captured before its first turn: " + name)
                cases.append(dict(name=f"p{stage}.{area}-" + name, stage=stage, area=area,
                                  snaps=[dict(frame=fr, ram=ram[:0x700]) for fr, ram in snaps]))
        path = tmp / "oracle.json"
        path.write_text(json.dumps(dict(cases=cases)))
        states = sorted({snap["ram"][P.field(18, 6)] for case in cases for snap in case["snaps"] if snap["ram"][P.field(0, 6)] == 0x1C})
        if states != [0, 1, 2, 3]:
            raise RuntimeError("Missing native states: " + str(states))
        print(f"NES nest $1C oracle: {len(cases)} fixtures, states={states}")
        if "--oracle-only" in sys.argv:
            return 0
        result = subprocess.run([GODOT, "--headless", "--path", str(ROOT / "game"),
                                 "--script", "res://tests/pb2_nest_child_1c_test.gd", "--", str(path)],
                                capture_output=True, text=True, timeout=180)
        print(result.stdout, end=""); print(result.stderr, end="")
        return result.returncode or int("SCRIPT ERROR" in result.stdout + result.stderr
                                        or "ERROR:" in result.stderr
                                        or "NES nest $1C: 0 / " not in result.stdout)
    finally:
        P.sweep(str(tmp))


if __name__ == "__main__":
    sys.exit(main())
