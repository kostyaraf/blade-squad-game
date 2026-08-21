"""Decode a -vram dump and re-render the screen from ROM CHR + ripped VRAM.

The point of this module is fidelity: if the picture it produces is bit-for-bit
what the emulator drew, then every pixel of the original game can be rebuilt
outside the NES from data alone, which is what "looks 1:1" has to mean.
"""
import struct, zlib, sys, os

NES_PAL = [
    0x666666,0x002A88,0x1412A7,0x3B00A4,0x5C007E,0x6E0040,0x6C0600,0x561D00,
    0x333500,0x0B4800,0x005200,0x004F08,0x00404D,0x000000,0x000000,0x000000,
    0xADADAD,0x155FD9,0x4240FF,0x7527FE,0xA01ACC,0xB71E7B,0xB53120,0x994E00,
    0x6B6D00,0x388700,0x0C9300,0x008F32,0x007C8D,0x000000,0x000000,0x000000,
    0xFFFEFF,0x64B0FF,0x9290FF,0xC676FF,0xF36AFF,0xFE6ECC,0xFE8170,0xEA9E22,
    0xBCBE00,0x88D800,0x5CE430,0x45E082,0x48CDDE,0x4F4F4F,0x000000,0x000000,
    0xFFFEFF,0xC0DFFF,0xD3D2FF,0xE8C8FF,0xFBC2FF,0xFEC4EA,0xFECCC5,0xF7D8A5,
    0xE4E594,0xCFEF96,0xBDF4AB,0xB3F3CC,0xB5EBF2,0xB8B8B8,0x000000,0x000000,
]

MIR_HORZ, MIR_VERT, MIR_S0, MIR_S1, MIR_FOUR = range(5)

class Vram:
    def __init__(self, path):
        d = open(path, 'rb').read()
        assert d[:8] == b'PB3VRAM1', "not a PB3 vram dump"
        self.frame  = struct.unpack_from('<I', d, 8)[0]
        self.ciram  = d[12:12+2048]
        self.pal    = d[2060:2060+32]
        self.oam    = d[2092:2092+256]
        self.chr_banks = list(struct.unpack_from('<8H', d, 2348))
        self.mirror = d[2364]
        self.ppuctrl = d[2365]
        self.ppumask = d[2366]
        self.vreg   = struct.unpack_from('<H', d, 2367)[0]
        self.fine_x = d[2369]
        self.mmc3   = list(d[2370:2378])
        self.prg    = list(d[2378:2382])
        # per-scanline CHR banks: the whole reason a mid-frame bank swap does
        # not turn the rebuilt picture into garbage
        self.chr_scan = [list(struct.unpack_from('<8H', d, 2382 + y*16))
                         for y in range(240)] if len(d) >= 2382 + 240*16 else None
        # per-scanline scroll and palette: a NES frame is not one picture but
        # 240 of them, and mid-frame writes are how the status bar stays still
        # while the level scrolls behind it
        self.ram = d[2382 + 240*16 : 2382 + 240*16 + 2048]
        self.scan = None
        base = 2382 + 240*16 + 2048
        if len(d) >= base + 240*37:
            self.scan = []
            for y in range(240):
                o = base + y*37
                self.scan.append(dict(
                    v=struct.unpack_from('<H', d, o)[0],
                    fx=d[o+2], mask=d[o+3], ctrl=d[o+4], pal=d[o+5:o+37]))

    # --- PPU address decoding -----------------------------------------------
    def nt_index(self, nt):
        """Which of the two 1K CIRAM pages nametable `nt` (0-3) resolves to."""
        if self.mirror == MIR_HORZ: return (0, 0, 1, 1)[nt]
        if self.mirror == MIR_VERT: return (0, 1, 0, 1)[nt]
        if self.mirror == MIR_S0:   return 0
        if self.mirror == MIR_S1:   return 1
        return nt & 1

    def nt_byte(self, nt, tx, ty):
        return self.ciram[self.nt_index(nt) * 1024 + ty * 32 + tx]

    def attr(self, nt, tx, ty):
        b = self.ciram[self.nt_index(nt) * 1024 + 0x3C0 + (ty // 4) * 8 + (tx // 4)]
        return (b >> (((ty & 2)) + ((tx & 2) >> 1)) * 2) & 3

    def chr_tile(self, chrom, tile, table, scan=None):
        """16 raw bytes of one 8x8 tile, honouring the MMC3 1K bank mapping."""
        addr = table * 0x1000 + tile * 16
        banks = self.chr_scan[scan] if (scan is not None and self.chr_scan) else self.chr_banks
        bank = banks[addr // 0x400]
        return chrom[bank * 0x400 + (addr & 0x3FF): bank * 0x400 + (addr & 0x3FF) + 16]

    def pixel_rows(self, chrom, tile, table, scan=None):
        raw = self.chr_tile(chrom, tile, table, scan)
        return [[((raw[y] >> (7 - x)) & 1) | (((raw[y + 8] >> (7 - x)) & 1) << 1)
                 for x in range(8)] for y in range(8)]

def render(v, chrom, w=256, h=240, sprites=True):
    """Rebuild one frame exactly as the PPU drew it, scanline by scanline."""
    tilecache = {}
    def rows(t, table, scan):
        key = (t, table, tuple(v.chr_scan[scan]) if v.chr_scan else 0)
        if key not in tilecache:
            tilecache[key] = v.pixel_rows(chrom, t, table, scan)
        return tilecache[key]

    img = bytearray(w * h * 3)
    for py in range(h):
        sc = v.scan[py] if v.scan else None
        vr   = sc['v']    if sc else v.vreg
        fx   = sc['fx']   if sc else v.fine_x
        mask = sc['mask'] if sc else v.ppumask
        ctrl = sc['ctrl'] if sc else v.ppuctrl
        pal  = sc['pal']  if sc else v.pal
        bg_table = 1 if (ctrl & 0x10) else 0
        show_bg  = bool(mask & 0x08)
        # loopy v holds this scanline's own vertical position; the horizontal
        # part is reloaded from t at dot 257 every line, so it is per-line too
        coarse_x = vr & 0x1F
        coarse_y = (vr >> 5) & 0x1F
        fine_y   = (vr >> 12) & 7
        nt       = (vr >> 10) & 3
        for px in range(w):
            pi = 0
            if show_bg and not (px < 8 and not (mask & 0x02)):
                xx = coarse_x * 8 + fx + px
                tx = (xx // 8) & 0x1F
                ntx = (nt & 1) ^ ((xx // 256) & 1)
                nty = (nt >> 1) & 1
                n = ntx | (nty << 1)
                t = v.nt_byte(n, tx, coarse_y)
                c = rows(t, bg_table, py)[fine_y][xx % 8]
                pi = 0 if c == 0 else v.attr(n, tx, coarse_y) * 4 + c
            rgb = NES_PAL[pal[pi] & 0x3F]
            o = (py * w + px) * 3
            img[o] = rgb >> 16 & 0xFF; img[o+1] = rgb >> 8 & 0xFF; img[o+2] = rgb & 0xFF

    if sprites:
        tall = bool(v.ppuctrl & 0x20)
        spr_table = 1 if (v.ppuctrl & 0x08) else 0
        for i in range(63, -1, -1):
            y, tile, at, x = v.oam[i*4:i*4+4]
            if y >= 0xEF: continue
            hgt = 16 if tall else 8
            for r in range(hgt):
                py = y + 1 + r
                if not (0 <= py < h): continue
                sc = v.scan[py] if v.scan else None
                if sc and not (sc['mask'] & 0x10): continue
                pal = sc['pal'] if sc else v.pal
                rr = (hgt - 1 - r) if (at & 0x80) else r
                if tall:
                    tn = (tile & 0xFE) + (1 if rr >= 8 else 0); tbl = tile & 1
                else:
                    tn, tbl = tile, spr_table
                line = v.pixel_rows(chrom, tn, tbl, py)[rr % 8]
                for c8 in range(8):
                    cc = line[7 - c8] if (at & 0x40) else line[c8]
                    if cc == 0: continue
                    px = x + c8
                    if not (0 <= px < w): continue
                    if px < 8 and sc and not (sc['mask'] & 0x04): continue
                    rgb = NES_PAL[pal[0x10 + (at & 3) * 4 + cc] & 0x3F]
                    o = (py * w + px) * 3
                    img[o] = rgb >> 16 & 0xFF; img[o+1] = rgb >> 8 & 0xFF; img[o+2] = rgb & 0xFF
    return img

def write_png(path, img, w, h):
    raw = b''.join(b'\x00' + bytes(img[y*w*3:(y+1)*w*3]) for y in range(h))
    def chunk(t, d):
        c = t + d
        return struct.pack('>I', len(d)) + c + struct.pack('>I', zlib.crc32(c) & 0xFFFFFFFF)
    png = (b'\x89PNG\r\n\x1a\n'
           + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0))
           + chunk(b'IDAT', zlib.compress(raw, 9))
           + chunk(b'IEND', b''))
    open(path, 'wb').write(png)

def load_chr(rom_path):
    d = open(rom_path, 'rb').read()
    prg_n, chr_n = d[4], d[5]
    return d[16 + prg_n*16384: 16 + prg_n*16384 + chr_n*8192]

if __name__ == '__main__':
    dump, rom, out = sys.argv[1], sys.argv[2], sys.argv[3]
    v = Vram(dump)
    chrom = load_chr(rom)
    img = render(v, chrom)
    write_png(out, img, 256, 240)
    print(f"frame {v.frame}  chr banks {v.chr_banks}  scroll v=${v.vreg:04X} finex={v.fine_x} "
          f"ctrl=${v.ppuctrl:02X} mask=${v.ppumask:02X} -> {out}")
