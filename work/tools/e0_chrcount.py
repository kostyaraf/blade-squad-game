import sys, hashlib
def load(p):
    d=open(p,'rb').read()
    hdr=16; prg=d[4]*16384; chr_=d[5]*8192
    return d[hdr:hdr+prg], d[hdr+prg:hdr+prg+chr_]
def tiles(c):
    return [c[i:i+16] for i in range(0,len(c),16)]
roms={
 'PB2':'Power Blade 2 (USA).nes',
 'SOL':'Tokkyuu Shirei Solbrain (Japan).nes',
}
sets={}
allt=set()
for k,p in roms.items():
    prg,chrd=load(p)
    t=tiles(chrd)
    blank=sum(1 for x in t if x==bytes(16))
    u=set(t)
    sets[k]=u
    allt|=u
    print(f"{k}: CHR {len(chrd)} bytes, {len(t)} tiles total, {len(u)} unique, {blank} all-zero tiles")
a,b=sets['PB2'],sets['SOL']
print("shared unique tiles:", len(a&b))
print("union unique tiles:", len(allt), "=", len(allt)*16, "bytes =", len(allt)*16/1024, "KB")
print("PB2 only:", len(a-b), " SOL only:", len(b-a))

print()
print("=== 1KB CHR bank dedup (MMC3 granularity) ===")
banks={}
for k,p in roms.items():
    prg,chrd=load(p)
    bs=[chrd[i:i+1024] for i in range(0,len(chrd),1024)]
    banks[k]=bs
    print(f"{k}: {len(bs)} 1KB banks, {len(set(bs))} unique")
u=set(banks['PB2'])|set(banks['SOL'])
print("union unique 1KB banks:", len(u), "=", len(u), "KB")
print("shared 1KB banks:", len(set(banks['PB2'])&set(banks['SOL'])))
print()
print("=== PRG 8KB bank dedup ===")
for k,p in roms.items():
    prg,chrd=load(p)
    bs=[prg[i:i+8192] for i in range(0,len(prg),8192)]
    print(f"{k}: {len(bs)} 8KB banks, {len(set(bs))} unique")
