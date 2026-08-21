"""Recursive-descent code discovery over all 16 Solbrain PRG banks.

Seeds: NMI/RESET/IRQ vectors, the $C000 trampoline table in bank 14, the
`JMP` header table at the start of every bank pair, every PC observed in the
supplied nesemu traces, and every documented jump table.  Then follows every
JSR/JMP/branch target reachable inside the same bank window.

Because MMC3 pairs banks (even -> $8000, odd -> $A000) a target in $8000-$9FFF
is resolved in the even bank of the pair and $A000-$BFFF in the odd one; a
target in $C000-$FFFF always resolves to bank 14/15.
"""
import sys, os, re, pickle, collections
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from m6502 import decode, TERMINAL

ROM = "Tokkyuu Shirei Solbrain (Japan).nes"
raw = open(ROM,'rb').read()
PRG = raw[16:16+128*1024]
BANK = [PRG[i*0x2000:(i+1)*0x2000] for i in range(16)]
def base_of(b): return 0xC000 if b==14 else (0xE000 if b==15 else (0x8000 if b%2==0 else 0xA000))

def resolve(bank, addr):
    """which bank does `addr` live in, when we are executing in `bank`?"""
    if 0xE000 <= addr: return 15
    if 0xC000 <= addr: return 14
    if bank >= 14: return None                    # fixed bank calling a switchable one: unknown pair
    pair = bank & ~1
    return pair if addr < 0xA000 else pair+1

BR = {'BPL','BMI','BVC','BVS','BCC','BCS','BNE','BEQ'}

def descend(seeds):
    code = collections.defaultdict(set)          # bank -> set of cpu addrs
    work = list(seeds)
    seen = set(seeds)
    while work:
        b, a = work.pop()
        base = base_of(b); data = BANK[b]
        if not (base <= a < base+0x2000): continue
        while True:
            o = a - base
            if o < 0 or o >= 0x2000: break
            if a in code[b]: break
            code[b].add(a)
            d = decode(data, o, a)
            ln = d[0]
            if not ln: break
            mn = d[2]; opnd = d[4]
            if mn in BR and opnd is not None:
                nb = resolve(b, opnd)
                if nb is not None and (nb,opnd) not in seen:
                    seen.add((nb,opnd)); work.append((nb,opnd))
            elif mn == 'JSR' and opnd is not None:
                nb = resolve(b, opnd)
                if nb is not None and (nb,opnd) not in seen:
                    seen.add((nb,opnd)); work.append((nb,opnd))
            elif mn == 'JMP':
                if d[1].startswith('JMP ($'):
                    break
                nb = resolve(b, opnd)
                if nb is not None and (nb,opnd) not in seen:
                    seen.add((nb,opnd)); work.append((nb,opnd))
                break
            elif mn in ('RTS','RTI','BRK'):
                break
            a += ln
    return code

def header_seeds():
    s = []
    for b in range(0,14,2):
        for bank,base in ((b,0x8000),(b+1,0xA000)):
            data = BANK[bank]
            for o in range(0, 0x80):
                if data[o] != 0x4C: continue
                t = data[o+1] | data[o+2]<<8
                if not (base <= t < base+0x2000): continue
                nb = resolve(bank, t)
                if nb is not None: s.append((nb,t))
    # bank 14 trampoline table at $C000
    data = BANK[14]; o = 0
    while o < 0x100 and data[o]==0x4C:
        t = data[o+1]|data[o+2]<<8
        nb = 14 if t < 0xE000 else 15
        s.append((nb,t)); o += 3
    # vectors
    v = BANK[15]
    for k in (0x1FFA,0x1FFC,0x1FFE):
        t = v[k]|v[k+1]<<8
        s.append((15 if t>=0xE000 else 14, t))
    return s

def word_table(bank, addr, n):
    base = base_of(bank); data = BANK[bank]; o = addr-base
    out=[]
    for i in range(n):
        t = data[o+2*i] | data[o+2*i+1]<<8
        nb = resolve(bank, t)
        if nb is not None: out.append((nb,t))
    return out

def trace_seeds(paths):
    pat = re.compile(r'^F\d+ (\d+):([0-9A-F]{4}) ')
    s=set()
    for p in paths:
        for ln in open(p):
            m = pat.match(ln)
            if m: s.add((int(m.group(1)), int(m.group(2),16)))
    return list(s)

if __name__=='__main__':
    seeds = header_seeds()
    # documented jump tables
    for bank,addr,n in [(2,0x81EA,64),(2,0x827B,64),(2,0x83A9,48),(2,0x836A,48),
                        (13,0xA594,16),(13,0xB1A6,32),(13,0xB1E1,32),
                        (8,0x93E8,20),(8,0x9422,32),(12,0x8000,0)]:
        if n: seeds += word_table(bank,addr,n)
    seeds += trace_seeds(sys.argv[2:])
    code = descend(seeds)
    tot = sum(len(v) for v in code.values())
    print("discovered instruction addresses:", tot,
          " per bank:", {b:len(code[b]) for b in sorted(code)})
    pickle.dump({b:code[b] for b in code}, open(sys.argv[1],'wb'))
