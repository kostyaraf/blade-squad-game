"""Standalone builder: apply patches/pb2_all_suits.py to the stock PB2 .nes."""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'pb3', 'patches'))
import pb2_all_suits as patch

SRC = 'Power Blade 2 (USA).nes'
DST = 'work/build/pb2_allsuits.nes'

class Ctx:
    def __init__(self, data):
        self.d = bytearray(data)
        self.prg = 16
    def _o(self, bank, off): return self.prg + bank * 0x2000 + off
    def get(self, bank, off, n): return bytes(self.d[self._o(bank, off):self._o(bank, off)+n])
    def put(self, bank, off, b): self.d[self._o(bank, off):self._o(bank, off)+len(b)] = b

ctx = Ctx(open(SRC, 'rb').read())
patch.apply(ctx)
open(DST, 'wb').write(bytes(ctx.d))
print('wrote', DST, len(ctx.d), 'bytes;', patch.NAME)
