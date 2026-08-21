import sys, os, pickle, collections
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from m6502 import ZP, ZPX, ZPY, ABS, ABX, ABY, IZX, IZY
hits = pickle.load(open(sys.argv[1],'rb'))
INDEXED={ZPX,ZPY,ABX,ABY}
def rows(addrs, name, aligned_only=True):
    bare=collections.Counter(); idx=collections.Counter(); sites=collections.defaultdict(list)
    for b,pc,mn,mode,opnd,al,txt in hits:
        if aligned_only and not al: continue
        if opnd in addrs:
            if mode in INDEXED: idx[b]+=1
            else: bare[b]+=1
            sites[b].append((pc,txt))
    return bare, idx, sites
if __name__=='__main__':
    pass
