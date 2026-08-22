"""Reader for the emulator's -vram dump.

Layout is documented at the top of work/tools/nesemu.c; this mirrors it.
"""
import struct

MAGIC = b'PB3VRAM1'
OFF_CIRAM, OFF_PAL, OFF_OAM = 12, 2060, 2092
OFF_CHR, OFF_MIRROR = 2348, 2364
OFF_CTRL, OFF_MASK, OFF_V, OFF_FINEX = 2365, 2366, 2367, 2369
OFF_R, OFF_PRG = 2370, 2378
OFF_CHRSCAN = 2382                       # u16[240][8]
OFF_RAM = OFF_CHRSCAN + 240 * 8 * 2      # 6222, 2048 bytes
OFF_SCAN = OFF_RAM + 2048                # per-scanline scroll/mask/ctrl/palette


class VDump:
    def __init__(self, path):
        d = open(path, 'rb').read()
        assert d[:8] == MAGIC, 'not a vram dump'
        self.raw = d
        self.frame = struct.unpack_from('<I', d, 8)[0]
        self.ciram = d[OFF_CIRAM:OFF_CIRAM + 2048]
        self.pal = list(d[OFF_PAL:OFF_PAL + 32])
        self.oam = list(d[OFF_OAM:OFF_OAM + 256])
        self.chr = list(struct.unpack_from('<8H', d, OFF_CHR))
        self.mirror = d[OFF_MIRROR]
        self.ctrl, self.mask = d[OFF_CTRL], d[OFF_MASK]
        self.v = struct.unpack_from('<H', d, OFF_V)[0]
        self.fine_x = d[OFF_FINEX]
        self.regs = list(d[OFF_R:OFF_R + 8])
        self.prg = list(d[OFF_PRG:OFF_PRG + 4])
        self.chr_scan = [list(struct.unpack_from('<8H', d, OFF_CHRSCAN + y * 16))
                         for y in range(240)]
        self.ram = list(d[OFF_RAM:OFF_RAM + 2048])

    def page(self, i):
        """One 1 KB nametable page as it sits in CIRAM (0 or 1 physically)."""
        return self.ciram[i * 1024:(i + 1) * 1024]

    def nt(self, logical):
        """Logical nametable 0..3 resolved through the mirroring."""
        if self.mirror == 0:            # horizontal: 0,1 -> A ; 2,3 -> B
            return self.page(logical >> 1)
        if self.mirror == 1:            # vertical: 0,2 -> A ; 1,3 -> B
            return self.page(logical & 1)
        if self.mirror in (2, 3):
            return self.page(self.mirror - 2)
        return self.page(logical)


SCAN_LEN = 2 + 1 + 1 + 1 + 32          # v, fine x, mask, ctrl, palette


def scanline(dump, y):
    """The PPU state as it stood when scanline `y` was drawn."""
    o = OFF_SCAN + y * SCAN_LEN
    d = dump.raw
    return dict(v=struct.unpack_from('<H', d, o)[0],
                fine_x=d[o + 2], mask=d[o + 3], ctrl=d[o + 4],
                pal=list(d[o + 5:o + 37]),
                chr=dump.chr_scan[y])
