"""Render a decoded Power Blade 2 area to a PNG using the game's own CHR
and palette, so the result is pixel-identical to what the NES shows."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pb2_levels import PB2Levels, SCREEN_W
from vram import NES_PAL, write_png, load_chr


def render_area(lv, st, ai, chrom, pal, bg_banks, out):
    idxs = st['areas'][ai]
    scrs = [i for i in idxs if i < len(st['screens'])]
    if not scrs:
        return False
    h = max(st['screens'][i]['h'] for i in scrs)
    W = len(scrs) * 32
    H = h * 4
    IW, IH = W * 8, H * 8
    img = bytearray(IW * IH * 3)

    for n, si in enumerate(scrs):
        s = st['screens'][si]
        for br in range(s['h']):
            for bc in range(SCREEN_W):
                b = s['data'][br * SCREEN_W + bc]
                if b >= st['nblocks']:
                    continue
                blk = st['blocks'][b]
                att = st['attr'][b]
                for r in range(4):
                    for c in range(4):
                        t = blk[r * 4 + c]
                        # the attribute byte covers the whole 32x32 block:
                        # 2 bits per 16x16 quadrant
                        q = (r // 2) * 2 + (c // 2)
                        pl = (att >> (q * 2)) & 3
                        bank = bg_banks[((t >> 6) & 3) + 4]
                        off = bank * 1024 + (t & 0x3F) * 16
                        px0 = (n * 32 + bc * 4 + c) * 8
                        py0 = (br * 4 + r) * 8
                        for y in range(8):
                            lo = chrom[off + y]
                            hi = chrom[off + 8 + y]
                            base = ((py0 + y) * IW + px0) * 3
                            for x in range(8):
                                v = ((lo >> (7 - x)) & 1) | (((hi >> (7 - x)) & 1) << 1)
                                col = NES_PAL[pal[0] if v == 0 else pal[pl * 4 + v]]
                                o = base + x * 3
                                img[o] = (col >> 16) & 0xFF
                                img[o + 1] = (col >> 8) & 0xFF
                                img[o + 2] = col & 0xFF
    write_png(out, img, IW, IH)
    return True


if __name__ == '__main__':
    from vram import Vram
    rom = "Power Blade 2 (USA).nes"
    lv = PB2Levels(rom)
    chrom = load_chr(rom)
    v = Vram(sys.argv[1] if len(sys.argv) > 1 else '/tmp/vB.bin')
    sc = v.scan[100]
    pal = list(sc['pal'])
    banks = list(v.chr_scan[100])
    os.makedirs('work/build/levels', exist_ok=True)
    st = lv.stage(0)
    st['attr'] = st['collision']
    for ai in range(len(st['areas'])):
        out = f"work/build/levels/s0_a{ai}.png"
        if render_area(lv, st, ai, chrom, pal, banks, out):
            print("wrote", out)
