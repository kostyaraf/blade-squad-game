"""Disassemble a 16KB bank pair mapped at $8000 (even) / $A000 (odd)."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from m6502 import Rom
from sol_dis import Dis, ROM

def pair(rom, even): return rom.bank(even)+rom.bank(even+1)
def head_entries(data):
    ents=[]; o=4
    while o<0x800 and data[o]==0x4C:
        ents.append(data[o+1]|data[o+2]<<8); o+=3
    return ents

def build(even, extra=(), jt=()):
    rom=Rom(ROM); data=pair(rom,even)
    d=Dis(data,0x8000,f'pair{even}')
    for a,n in jt: d.add_jumptable(a,n)
    for e in list(head_entries(data))+list(extra):
        if 0x8000<=e<0xC000: d.entries.add(e); d.trace(e)
    return d

if __name__=='__main__':
    even=int(sys.argv[1])
    extra=[]; jt=[]
    for a in sys.argv[2:]:
        if ':' in a:
            x,y=a.split(':'); jt.append((int(x,16),int(y)))
        else: extra.append(int(a,16))
    d=build(even,extra,jt)
    print(f"; ==== PRG bank pair {even}/{even+1} @ $8000/$A000 ====")
    print(d.listing())
