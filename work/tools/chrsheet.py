"""Render 1 KB CHR banks (64 tiles) as a labelled 8x8 sheet."""
import sys, os
_d = os.path.dirname(os.path.abspath(__file__))
sys.path[:] = [p for p in sys.path if os.path.abspath(p or '.') != _d]
from PIL import Image, ImageDraw

GREY = [(0, 0, 0), (90, 90, 90), (170, 170, 170), (255, 255, 255)]

def sheet(chr_rom, banks, out, scale=3):
    n = len(banks)
    W, H = 8 * 8 * scale, n * 8 * 8 * scale
    img = Image.new('RGB', (W + 40, H + 20 * n), (20, 20, 40))
    d = ImageDraw.Draw(img)
    for bi, kb in enumerate(banks):
        base = kb * 0x400
        top = bi * (8 * 8 * scale + 20) + 18
        d.text((2, top - 14), 'bank $%02X  (tiles $%02X-$%02X)' % (kb, 0, 63),
               fill=(255, 255, 0))
        for t in range(64):
            g = chr_rom[base + t * 16: base + t * 16 + 16]
            tx, ty = (t % 8) * 8 * scale + 20, (t // 8) * 8 * scale + top
            for r in range(8):
                a, b = g[r], g[r + 8]
                for c in range(8):
                    v = ((a >> (7 - c)) & 1) | (((b >> (7 - c)) & 1) << 1)
                    for sy in range(scale):
                        for sx in range(scale):
                            img.putpixel((tx + c * scale + sx, ty + r * scale + sy), GREY[v])
        for i in range(8):
            d.text((2, top + i * 8 * scale + 6), '%X' % i, fill=(180, 180, 180))
    img.save(out)
    print(out, img.size)


if __name__ == '__main__':
    rom = open(sys.argv[1], 'rb').read()
    prg = rom[4 + 12] if False else rom[4]
    chr_off = 16 + rom[4] * 16384
    chrom = rom[chr_off:chr_off + rom[5] * 8192]
    sheet(chrom, [int(x, 0) for x in sys.argv[3:]], sys.argv[2])
