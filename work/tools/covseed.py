"""Merge nesemu coverage bitmaps -> per-unit entry seeds + data ranges."""
import sys,os,glob
def load(paths):
    n=131072//8
    m=bytearray(n)
    for p in paths:
        b=open(p,'rb').read()
        for i in range(min(len(b),n)): m[i]|=b[i]
    return m
def isexec(m,off): return (m[off>>3]>>(off&7))&1
def ranges(m,size=131072):
    out=[];i=0
    while i<size:
        if isexec(m,i):
            s=i
            while i<size and isexec(m,i): i+=1
            out.append((s,i-1))
        else: i+=1
    return out
if __name__=='__main__':
    m=load(sys.argv[1:])
    rs=ranges(m)
    tot=sum(e-s+1 for s,e in rs)
    print(f"{len(rs)} ranges, {tot} bytes executed ({tot/131072*100:.1f}%)")
    per={}
    for s,e in rs:
        per.setdefault(s//8192,0)
        per[s//8192]+=e-s+1
    for b in range(16): print(f" bank{b:2}: {per.get(b,0):6} bytes ({per.get(b,0)/8192*100:.1f}%)")
