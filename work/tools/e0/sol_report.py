import sys, os, pickle, collections
sys.path.insert(0,'work/tools')
from m6502 import ZP,ZPX,ZPY,ABS,ABX,ABY,IZX,IZY
hits=pickle.load(open(sys.argv[1],'rb'))
code=pickle.load(open(sys.argv[2],'rb'))
IDX={ZPX,ZPY,ABX,ABY}
def sel(confirmed=True):
    for b,pc,mn,mode,opnd,al,txt in hits:
        if confirmed:
            if pc not in code.get(b,()): continue
        else:
            if not al: continue
        yield b,pc,mn,mode,opnd,txt
CONF=list(sel(True)); LIN=list(sel(False))
def count(addrs, src):
    bare=collections.Counter(); idx=collections.Counter(); sites=[]
    for b,pc,mn,mode,opnd,txt in src:
        if opnd in addrs:
            if mode in IDX: idx[b]+=1
            else: bare[b]+=1
            sites.append((b,pc,txt,mode in IDX))
    return bare,idx,sites
def line(name, addrs):
    cb,ci,cs=count(addrs,CONF); lb,li,_=count(addrs,LIN)
    banks=collections.Counter()
    for b in set(list(cb)+list(ci)): banks[b]=cb[b]+ci[b]
    bs=' '.join(f"b{b}:{cb[b]}/{ci[b]}" for b in sorted(banks))
    print(f"{name:28s} conf bare={sum(cb.values()):4d} idx={sum(ci.values()):3d} | lin bare={sum(lb.values()):4d} idx={sum(li.values()):3d} | {bs}")
    return cs
if __name__=='__main__':
    pass
