"""Linear-sweep scan of all 16 Solbrain PRG banks: count every instruction that
references a given RAM address, split by addressing mode (bare vs indexed).

An offset counts as "aligned" (probable real instruction) when a linear sweep
started 20/30/40/60/80 bytes earlier lands exactly on it (>=3 of 5 anchors).
6502 linear sweeps self-synchronise within a few instructions, so this keeps
essentially all real code and drops ~2/3 of the data false positives."""
import sys, os, json
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from m6502 import decode, MODELEN, ZP, ZPX, ZPY, ABS, ABX, ABY, IZX, IZY

ROM = sys.argv[1] if len(sys.argv) > 1 else "Tokkyuu Shirei Solbrain (Japan).nes"
raw = open(ROM, 'rb').read()
PRG = raw[16:16 + 128 * 1024]
BANKS = [PRG[i * 0x2000:(i + 1) * 0x2000] for i in range(16)]

def base_of(b):
    if b == 14: return 0xC000
    if b == 15: return 0xE000
    return 0x8000 if b % 2 == 0 else 0xA000

def ilen(data, o):
    n = decode(data, o, 0)[0]
    return n if n else 1

def aligned_set(data):
    """offset -> True if it looks like an instruction boundary"""
    n = len(data)
    ok = [0] * n
    for o in range(n):
        votes = 0
        for back in (20, 30, 40, 60, 80):
            s = o - back
            if s < 0: continue
            p = s
            while p < o:
                p += ilen(data, p)
            if p == o: votes += 1
        ok[o] = votes >= 3
    return ok

INDEXED = {ZPX, ZPY, ABX, ABY, IZX, IZY}
BARE = {ZP, ABS}

def scan():
    out = []   # (bank, cpuaddr, mnemonic, mode, operand, aligned)
    for b in range(16):
        data = BANKS[b]; base = base_of(b)
        al = aligned_set(data)
        for o in range(len(data)):
            d = decode(data, o, base + o)
            if not d[0]: continue
            ln, txt, mn, mode, opnd, _ = d
            if opnd is None: continue
            if mode in INDEXED or mode in BARE:
                out.append((b, base + o, mn, mode, opnd, al[o], txt))
    return out

if __name__ == '__main__':
    hits = scan()
    import pickle
    pickle.dump(hits, open(sys.argv[2] if len(sys.argv) > 2 else '/tmp/solhits.pkl', 'wb'))
    print("instructions with a memory operand:", len(hits))
