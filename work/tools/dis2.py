"""Config-driven recursive-descent disassembler.

python3 dis2.py <cfg.json>
cfg = {
  "rom": "...", "bank": 15, "base": "E000", "out": "...",
  "entries": ["E640", ...],
  "ptrtables": [ {"addr":"E65B","count":35,"order":"lohi"} ],   # each entry is a code entry
  "data": [["E65B","E6A2"]],   # force data
  "symbols": {"0x2D":"irq_idx"}
}
"""
import sys, os, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from m6502 import Rom, decode, BRANCHES, IMP,ACC,IMM,ZP,ZPX,ZPY,ABS,ABX,ABY,IND,IZX,IZY,REL

class Dis:
    def __init__(self, data, base):
        self.data=data; self.base=base; self.size=len(data)
        self.code=set(); self.starts=set(); self.xrefs={}; self.subs=set()
        self.entries=set(); self.forced_data=set(); self.tables={}
        self.absrefs={}   # operand -> set((addr,mn))
        self.inline={0xCA0B}   # dispatchers taking an inline pointer table
        self.itables={}   # table addr -> list of targets
        self.stables={}   # (lo,hi,n) split pointer tables discovered
    def inrange(self,a): return self.base<=a<self.base+self.size
    def off(self,a): return a-self.base
    def trace(self, addr):
        stack=[addr]
        while stack:
            a=stack.pop()
            while True:
                if not self.inrange(a): break
                o=self.off(a)
                if o in self.starts or o in self.forced_data: break
                ln,txt,mn,md,operand,tgt=decode(self.data,o,a)
                if mn is None: break
                if any((o+i) in self.forced_data for i in range(ln)): break
                self.starts.add(o)
                for i in range(ln): self.code.add(o+i)
                # split lo/hi pointer table idiom:
                #   LDA t1,Y / STA zp / LDA t2,Y / STA zp+1 / JMP (zp)
                if self.data[o]in(0xB9,0xBD) and o+13<=self.size:
                    q=self.data[o:o+14]
                    if (q[3]==0x85 and q[5]==q[0] and q[8]==0x85 and q[9]==q[4]+1
                        and q[10]==0x6C and q[11]==q[4] and q[12]==0x00):
                        t1=q[1]|q[2]<<8; t2=q[6]|q[7]<<8
                        n=t2-t1
                        if 0<n<=256 and self.inrange(t1) and self.inrange(t2+n-1):
                            tg=[]
                            for k in range(n):
                                v=self.data[self.off(t1)+k]|self.data[self.off(t2)+k]<<8
                                tg.append(v)
                            self.stables[t1]=(t2,n,tg)
                            for x in range(self.off(t1), self.off(t2)+n): self.forced_data.add(x)
                            for v in tg:
                                if self.inrange(v):
                                    self.xrefs.setdefault(v,set()).add(a); stack.append(v)
                if operand is not None and md in (ABS,ABX,ABY,IND,ZP,ZPX,ZPY,IZX,IZY):
                    self.absrefs.setdefault(operand,set()).add((a,mn))
                if mn=='JSR':
                    self.xrefs.setdefault(tgt,set()).add(a)
                    if self.inrange(tgt): self.subs.add(tgt); stack.append(tgt)
                    if tgt in self.inline:
                        t=a+ln
                        tabs=[]; lim=0xFFFF
                        while t<lim and self.inrange(t) and t+1<self.base+self.size:
                            o2=self.off(t)
                            d=self.data[o2]|self.data[o2+1]<<8
                            if not self.inrange(d) or d<=t: break
                            tabs.append(d); lim=min(lim,d)
                            t+=2
                        for x in range(self.off(a+ln), self.off(t)): self.forced_data.add(x)
                        self.itables[a+ln]=tabs
                        for d2 in tabs: self.xrefs.setdefault(d2,set()).add(a+ln); stack.append(d2)
                        break
                    a+=ln; continue
                if mn=='JMP':
                    if md==ABS:
                        self.xrefs.setdefault(tgt,set()).add(a)
                        if self.inrange(tgt): stack.append(tgt)
                    break
                if mn in BRANCHES:
                    self.xrefs.setdefault(tgt,set()).add(a)
                    if self.inrange(tgt): stack.append(tgt)
                    a+=ln; continue
                if mn in ('RTS','RTI','BRK'): break
                a+=ln
    def listing(self,symbols=None,notes=None):
        symbols=symbols or {}; notes=notes or {}
        def sym(v,w):
            s=symbols.get(f"{v:04X}") or symbols.get(f"{v:02X}")
            return s
        out=[]; o=0
        while o<self.size:
            a=self.base+o
            if o in self.starts:
                ln,txt,mn,md,operand,tgt=decode(self.data,o,a)
                if a in self.xrefs or a in self.entries:
                    kind='sub' if a in self.subs else 'loc'
                    out.append('')
                    xr=sorted(self.xrefs.get(a,()))
                    out.append(f"{kind}_{a:04X}:  ; {len(xr)} xrefs: "+' '.join(f"{x:04X}" for x in xr[:10])+(" ..." if len(xr)>10 else ""))
                stxt=txt
                if operand is not None and md in (ABS,ABX,ABY,IND):
                    s=sym(operand,4)
                    if s: stxt=stxt.replace(f"${operand:04X}",s)
                elif operand is not None and md in (ZP,ZPX,ZPY,IZX,IZY):
                    s=symbols.get(f"{operand:02X}")
                    if s: stxt=stxt.replace(f"${operand:02X}",s)
                if tgt is not None and md==REL:
                    stxt=stxt.replace(f"${tgt:04X}",f"loc_{tgt:04X}")
                elif tgt is not None and mn in ('JMP','JSR') and self.inrange(tgt):
                    stxt=stxt.replace(f"${tgt:04X}",("sub_" if tgt in self.subs else "loc_")+f"{tgt:04X}")
                raw=' '.join(f'{b:02X}' for b in self.data[o:o+ln])
                n=notes.get(f"{a:04X}",'')
                out.append(f"{a:04X}  {raw:<9}{stxt:<24}"+(f"; {n}" if n else ''))
                o+=ln
            else:
                st=o
                while o<self.size and o not in self.starts: o+=1
                out.append('')
                st_=self.stables.get(self.base+st)
                if st_ is not None:
                    t2,n,tg=st_
                    out.append(f"; ==== SPLIT PTR TABLE lo=${self.base+st:04X} hi=${t2:04X} n={n} ====")
                    for k,t in enumerate(tg): out.append(f";   [{k:2}/${k:02X}] -> ${t:04X}")
                lab=self.itables.get(self.base+st)
                if lab is not None:
                    out.append(f"; ==== JUMP TABLE ${self.base+st:04X} ({len(lab)} entries) ====")
                    for k,t in enumerate(lab): out.append(f";   [{k:2}] -> ${t:04X}")
                out.append(f"; ==== data ${self.base+st:04X}..${self.base+o-1:04X}  ({o-st} bytes) ====")
                i=st
                while i<o:
                    ch=self.data[i:min(i+16,o)]
                    asc=''.join(chr(c) if 32<=c<127 else '.' for c in ch)
                    out.append(f"{self.base+i:04X}  "+' '.join(f'{b:02X}' for b in ch).ljust(48)+' |'+asc)
                    i+=16
        return '\n'.join(out)

def main(cfgpath):
    cfg=json.load(open(cfgpath))
    rom=Rom(cfg['rom'])
    d=Dis(rom.bank(cfg['bank']), int(cfg['base'],16))
    for r in cfg.get('data',[]):
        s=int(r[0],16); e=int(r[1],16)
        for x in range(d.off(s), d.off(e)+1): d.forced_data.add(x)
    ents=[int(x,16) for x in cfg.get('entries',[])]
    for pt in cfg.get('ptrtables',[]):
        base=int(pt['addr'],16); n=pt['count']; o=d.off(base)
        sz=pt.get('stride',2)
        for i in range(n):
            if pt.get('order')=='split':
                lo=d.data[o+i]; hi=d.data[o+n+i]
            else:
                lo=d.data[o+i*sz]; hi=d.data[o+i*sz+1]
            t=lo|hi<<8
            if d.inrange(t): ents.append(t)
            for k in range(sz*n if pt.get('order')!='split' else 2*n):
                d.forced_data.add(o+k)
    for e in ents:
        d.entries.add(e)
    for e in ents: d.trace(e)
    txt=d.listing(cfg.get('symbols'),cfg.get('notes'))
    if cfg.get('out'):
        open(cfg['out'],'w').write(txt)
        cov=len(d.code)/d.size*100
        print(f"wrote {cfg['out']}  coverage={cov:.1f}%  subs={len(d.subs)}")
    else:
        print(txt)
    return d

if __name__=='__main__': main(sys.argv[1])
