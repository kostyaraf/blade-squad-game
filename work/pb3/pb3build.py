"""PB3 build driver.

A patch module lives in work/pb3/patches/ and exposes:

    NAME  = "pb2_allsuits"
    GAME  = "pb2" | "sol"
    def apply(ctx): ...

`ctx` gives it:
    ctx.put(bank, off, data)          patch bytes into an ORIGINAL bank (0..15)
    ctx.asm(bank, off, addr, source)  assemble at `addr` and patch it in
    ctx.get(bank, off, n)             read original bytes
    ctx.newbank(name, pos=None)       claim a free block position (14..29) for new code
    ctx.put_new(pos, off, data)       write into a claimed new bank
    ctx.asm_new(pos, off, addr, src)  assemble into a claimed new bank

Every write is recorded with the patch name, so two patches touching the same
byte is a build error rather than a silent corruption.
"""
import os, sys, importlib.util

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(HERE), "tools"))
from rombuild import load, ca65, BANK, PB2, SOL
import compose as C

FREE_LO, FREE_HI = C.FREE_LO, C.FREE_HI

class GameCtx:
    def __init__(self, game, prg, chrom):
        self.game = game
        self.prg = bytearray(prg)
        self.chr = bytearray(chrom)
        self.new = {}                 # position -> bytearray
        self.newnames = {}            # position -> name
        self.claims = {}              # ('orig'|'new', bank, off) -> patch name
        self.cur = "?"

    # --- original banks -----------------------------------------------------
    def _claim(self, kind, bank, off, n):
        for i in range(n):
            k = (kind, bank, off + i)
            prev = self.claims.get(k)
            if prev is not None and prev != self.cur:
                raise RuntimeError(
                    f"{self.game}: patch collision at {kind} bank {bank} +${off+i:04X}: "
                    f"{prev} vs {self.cur}")
            self.claims[k] = self.cur

    def put(self, bank, off, data):
        assert 0 <= bank <= 15, bank
        assert off + len(data) <= BANK
        self._claim('orig', bank, off, len(data))
        self.prg[bank*BANK + off : bank*BANK + off + len(data)] = data

    def get(self, bank, off, n):
        return bytes(self.prg[bank*BANK+off : bank*BANK+off+n])

    def asm(self, bank, off, addr, source):
        self.put(bank, off, ca65(source, addr))

    # --- new banks ----------------------------------------------------------
    def newbank(self, name, pos=None):
        """Claim a free block position for new code.

        `pos` asks for a specific position; positions 14 and 15 are the only
        ones the engines' own bank helpers can reach (they mask with #$0F), so
        code that is entered through a patched LDY #imm must ask for one of
        those explicitly rather than take whatever is free.
        """
        if pos is not None:
            if not (FREE_LO <= pos <= FREE_HI):
                raise RuntimeError(
                    f"{self.game}: bank position {pos} is outside the free range "
                    f"{FREE_LO}..{FREE_HI}")
            if pos in self.new:
                raise RuntimeError(
                    f"{self.game}: bank position {pos} already claimed by "
                    f"{self.newnames[pos]}, requested by {self.cur}:{name}")
            self.new[pos] = bytearray(b'\xFF' * BANK)
            self.newnames[pos] = f"{self.cur}:{name}"
            return pos
        for p in range(FREE_LO, FREE_HI + 1):
            if p not in self.new:
                self.new[p] = bytearray(b'\xFF' * BANK)
                self.newnames[p] = f"{self.cur}:{name}"
                return p
        raise RuntimeError(f"{self.game}: no free bank positions left")

    def put_new(self, pos, off, data):
        assert pos in self.new, f"bank position {pos} not claimed"
        assert off + len(data) <= BANK
        self._claim('new', pos, off, len(data))
        self.new[pos][off:off+len(data)] = data

    def asm_new(self, pos, off, addr, source):
        self.put_new(pos, off, ca65(source, addr))

def load_patches(only=None):
    out = []
    d = os.path.join(HERE, "patches")
    for fn in sorted(os.listdir(d)):
        if not fn.endswith(".py") or fn.startswith("_"):
            continue
        spec = importlib.util.spec_from_file_location(fn[:-3], os.path.join(d, fn))
        m = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(m)
        if only and m.NAME not in only:
            continue
        out.append(m)
    return out

def build(out="PB3.nes", only=None, shell_bin=None, shell_chr=None, verbose=True):
    pb2_prg, pb2_chr = load(PB2)
    sol_prg, sol_chr = load(SOL)
    ctxs = {"pb2": GameCtx("pb2", pb2_prg, pb2_chr),
            "sol": GameCtx("sol", sol_prg, sol_chr)}
    for m in load_patches(only):
        ctx = ctxs[m.GAME]
        ctx.cur = m.NAME
        m.apply(ctx)
        if verbose:
            print(f"  applied {m.NAME} -> {m.GAME}")
    shell = {}
    if shell_bin:
        shell[31] = open(shell_bin, 'rb').read()
    schr = open(shell_chr, 'rb').read() if shell_chr else b''
    p2, s2 = ctxs["pb2"], ctxs["sol"]
    C.compose(out=out,
              pb2_new={k: bytes(v) for k, v in p2.new.items()},
              sol_new={k: bytes(v) for k, v in s2.new.items()},
              shell_banks=shell, shell_chr=schr,
              pb2_patch=lambda prg, chrom: (prg.__setitem__(slice(0, len(prg)), p2.prg),
                                            chrom.__setitem__(slice(0, len(chrom)), p2.chr)),
              sol_patch=lambda prg, chrom: (prg.__setitem__(slice(0, len(prg)), s2.prg),
                                            chrom.__setitem__(slice(0, len(chrom)), s2.chr)))
    for g, c in ctxs.items():
        if c.new:
            print(f"  {g} new banks: " + ", ".join(f"{p}={c.newnames[p]}" for p in sorted(c.new)))
    return out

if __name__ == '__main__':
    build(out=sys.argv[1] if len(sys.argv) > 1 else "work/build/PB3.nes",
          shell_bin="work/shell/build/shell_bank.bin",
          shell_chr="work/shell/build/shell_chr.bin")
