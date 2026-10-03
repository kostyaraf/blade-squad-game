#!/usr/bin/env python3
"""Extract PB2 kind-4 raster constants from ROM and live PPU scanlines."""
import json
import os
import pathlib
import subprocess
import sys
import tempfile
ROOT = pathlib.Path(__file__).resolve().parents[2] if pathlib.Path(__file__).parent.name == "extract" else pathlib.Path.cwd()
sys.path[:0] = [str(ROOT / "work/tools"), str(ROOT / "work/extract")]
import pb2_probe as P
from vramdump import VDump, scanline


def tempdir(prefix):
    base = pathlib.Path(os.environ.get("TMPDIR", tempfile.gettempdir())) / "nova-pb2b"
    base.mkdir(parents=True, exist_ok=True)
    return pathlib.Path(tempfile.mkdtemp(prefix=prefix, dir=base))


def capture(tmp, frames):
    inp = tmp / "boot.inp"
    inp.write_text(P.BOOT)
    cmd = P.emu("-input", str(inp), "-frames", str(max(frames) + 1),
                "-poke", f"0053=01@{P.PICK_LEVEL}", "-poke", f"009C=00@{P.PICK_LEVEL}",
                "-png", str(tmp / "nes"))
    for fr in frames:
        cmd += ["-vram", f"{tmp}/{fr}.vram@{fr}", "-shot", str(fr)]
    subprocess.run(cmd, check=True, capture_output=True, timeout=180)
    return [VDump(tmp / f"{fr}.vram") for fr in frames]


def extract(dump):
    player = json.loads((ROOT / "game/data/pb2/player.json").read_text())
    top, bottom = player["view_top"], player["view_bottom"]
    original = scanline(dump, top)["chr"][:4]
    bands = []
    last = original
    for y in range(top + 1, bottom):
        banks = scanline(dump, y)["chr"][:4]
        if banks != last:
            bands.append((y, banks))
            last = banks
    if len(bands) != 2 or bands[-1][1] != original:
        raise RuntimeError("Unexpected native kind-4 raster layout: " + str(bands))
    blank, floor = bands
    v = scanline(dump, floor[0])["v"]
    row = ((v >> 5) & 31) * 8 + ((v >> 12) & 7)
    rom = (ROOT / "Power Blade 2 (USA).nes").read_bytes()[16:]
    return dict(blank_banks=blank[1], blank_bias=blank[0] - dump.ram[0x29],
                floor_at=floor[0], floor_scroll_y=row - floor[0],
                draw_wrap=rom[14 * 8192 + 0x1178]) # $D177 CMP #$F0


def main():
    tmp = tempdir("raster-extract-")
    try:
        values = [extract(d) for d in capture(tmp, [1450, 1500, 1600])]
        if any(v != values[0] for v in values):
            raise RuntimeError("Raster constants changed between native frames")
        path = ROOT / "game/data/pb2/raster.json"
        for arg in sys.argv[1:]:
            if arg.startswith("--out="): path = pathlib.Path(arg[6:])
        path.write_text(json.dumps(dict(kind4=values[0]), separators=(",", ":")))
        print("PB2 raster:", values[0])
    finally:
        P.sweep(str(tmp))


if __name__ == "__main__":
    main()
