"""Decode Power Blade 2's object-placement lists.

Chain (see work/re/pb2_spawns.md): $E515[stage] in bank 15 -> a word in bank
pair 6/7 -> a per-stage table of one word per area -> a list of 4-byte records
terminated by $FF.
"""
import sys, os

PB2 = "Power Blade 2 (USA).nes"


class Rom:
    def __init__(self, path=PB2):
        d = open(path, 'rb').read()
        self.hdr, d = d[:16], d[16:]
        n = self.hdr[4] * 16384
        self.prg, self.chr = d[:n], d[n:]

    def bank(self, i):
        return self.prg[i * 0x2000:(i + 1) * 0x2000]

    def b15(self, a):
        return self.bank(15)[a - 0xE000]

    def w15(self, a):
        return self.b15(a) | self.b15(a + 1) << 8

    def pair(self, even):
        return self.bank(even) + self.bank(even + 1)

    def pb(self, data, a):
        return data[a - 0x8000]

    def pw(self, data, a):
        return self.pb(data, a) | self.pb(data, a + 1) << 8


def stage_lists(rom, stage):
    p = rom.pair(6)
    hdr = rom.w15(0xE515 + stage * 2)
    tbl = rom.pw(p, hdr)
    first = rom.pw(p, tbl)
    n = (first - tbl) // 2
    out = []
    for a in range(n):
        addr = rom.pw(p, tbl + a * 2)
        recs = []
        while True:
            b = [rom.pb(p, addr + k) for k in range(4)]
            if b[0] == 0xFF:
                break
            recs.append(tuple(b))
            addr += 4
        out.append((addr, recs))
    return tbl, out


if __name__ == '__main__':
    rom = Rom()
    for s in ([int(x) for x in sys.argv[1:]] or range(7)):
        tbl, areas = stage_lists(rom, s)
        print(f"stage {s}: table ${tbl:04X}, {len(areas)} areas")
        for i, (end, recs) in enumerate(areas):
            print(f"  area {i:2d} ({len(recs):2d}): " +
                  "  ".join("%02X:%02X@%02X/%02X" % (r[1], r[0], r[2], r[3])
                            for r in recs))
