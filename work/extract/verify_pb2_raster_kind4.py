#!/usr/bin/env python3
"""Compare the actual PB3 shader with live NES moving-ceiling backgrounds."""
import json
import pathlib
import subprocess
import sys
from PIL import Image
ROOT = pathlib.Path(__file__).resolve().parents[2] if pathlib.Path(__file__).parent.name == "extract" else pathlib.Path.cwd()
sys.path[:0] = [str(ROOT / "work/tools"), str(ROOT / "work/extract")]
import pb2_probe as P
from pb2_raster import capture, extract, tempdir
from render import Tiles, bg_frame, sprite_mask
from vramdump import scanline
GODOT = "/Applications/Godot_mono.app/Contents/MacOS/Godot"
FRAMES = [1450, 1500, 1600, 1700, 1800, 2100, 2300]


def main():
    tmp = tempdir("raster-verify-")
    try:
        dumps = capture(tmp, FRAMES)
        constants = json.loads((ROOT / "game/data/pb2/raster.json").read_text())["kind4"]
        player = json.loads((ROOT / "game/data/pb2/player.json").read_text())
        top, bottom = player["view_top"], player["view_bottom"]
        tiles = Tiles("pb2")
        cases = []
        refs = []
        for d in dumps:
            if extract(d) != constants:
                raise RuntimeError("Native raster constants changed at " + str(d.frame))
            ref = bg_frame(tiles, d)
            actual_nes = Image.open(tmp / f"nes_{d.frame}.png").convert("RGB")
            mask = sprite_mask(d)
            bad = sum(ref.getpixel((x, y)) != actual_nes.getpixel((x, y))
                      for y in range(top, bottom) for x in range(8, 256) if not mask[y][x])
            if bad:
                raise RuntimeError(f"NES screenshot oracle mismatch at {d.frame}: {bad}")
            for y in range(top, bottom):
                sc = scanline(d, y)
                native = sc["chr"][:4]
                original = scanline(d, top)["chr"][:4]
                want = constants["blank_banks"] if d.ram[0x29] + constants["blank_bias"] <= y < constants["floor_at"] else original
                if native != want:
                    raise RuntimeError(f"CHR band mismatch at frame={d.frame}, y={y}")
            refs.append(ref)
            cases.append(dict(frame=d.frame, water=d.ram[0x29], draw=d.ram[0xFC],
                              cycle=d.ram[0x5C], cam=(d.ram[0x66] << 8) | d.ram[0x67],
                              palette=d.pal, out=str(tmp / f"godot-{d.frame}.png")))
        print(f"NPB2-41 NES oracle: {len(cases)} frames, CHR bands and screenshots agree")
        if "--oracle-only" in sys.argv:
            return 0
        path = tmp / "oracle.json"
        path.write_text(json.dumps(dict(cases=cases)))
        result = subprocess.run([GODOT, "--path", str(ROOT / "game"), "--script",
                                 "res://tests/pb2_raster_kind4_test.gd", "--", str(path)],
                                capture_output=True, text=True, timeout=180)
        print(result.stdout, end=""); print(result.stderr, end="")
        if result.returncode or "SCRIPT ERROR" in result.stdout + result.stderr or "ERROR:" in result.stderr:
            return 1
        failed = checked = 0
        for case, ref in zip(cases, refs):
            got = Image.open(case["out"]).convert("RGB")
            bad = sum(got.getpixel((x, y)) != ref.getpixel((x, y))
                      for y in range(top, bottom) for x in range(8, 256))
            failed += bad; checked += (bottom - top) * 248
            print(f"frame {case['frame']}: {bad} background pixels differ")
        print(f"NPB2-41 GPU raster: {failed} / {checked} pixels differ")
        return int(failed != 0)
    finally:
        P.sweep(str(tmp))


if __name__ == "__main__":
    sys.exit(main())
