"""Measure how many PRG bytes each game spends on level geometry data."""
import sys, os
sys.path.insert(0,'/Users/hropl/pr/mypr/PB3/work/tools')
from pb2_levels import PB2Levels, NSTAGES

lv=PB2Levels('/Users/hropl/pr/mypr/PB3/Power Blade 2 (USA).nes')
spans={}
print("=== Power Blade 2: level geometry extents per stage ===")
for s in range(NSTAGES):
    st=lv.stage(s)
    lo=min(st['p_coll'],st['p_block'],st['p_scr'],st['p_area'])
    end=lv._region_end(s,st['p_area'])
    hi=end
    print(f" stage {s}: pair {st['pair']}  ${lo:04X}-${hi:04X}  = {hi-lo:5d} bytes"
          f"  (blocks {st['nblocks']}, screens {len(st['screens'])}, areas {len(st['areas'])})")
    spans.setdefault(st['pair'],[]).append((lo,hi))
print()
tot=0
for pair,rs in sorted(spans.items()):
    lo=min(a for a,b in rs); hi=max(b for a,b in rs)
    n=hi-lo
    tot+=n
    print(f" pair {pair} (banks {pair},{pair+1}): ${lo:04X}-${hi:04X} = {n} bytes "
          f"({n/8192:.2f} of an 8K bank)")
print(f" PB2 level geometry total: {tot} bytes = {tot/8192:.2f} 8K banks = {tot/1024:.1f} KB")

print()
print("=== Solbrain: level geometry extents ===")
import sol_levels as SL
r=SL.Rom('/Users/hropl/pr/mypr/PB3/Tokkyuu Shirei Solbrain (Japan).nes')
byp={}
tsets={}
for s in range(SL.N_STAGES):
    st=SL.Stage(r,s)
    ptrs=(st.p_quads,st.p_blocks,st.p_screens,st.p_roommap,st.p_props,st.p_alt)
    lo=min(ptrs)
    key=(st.bank_pair,st.tileset_index)
    tsets.setdefault(key,[]).append(s)
    byp.setdefault(st.bank_pair,set()).update(ptrs)
    print(f" stage {s:2d}: pair {st.bank_pair} tileset#{st.tileset_index:3d} "
          f"quads=${st.p_quads:04X} blocks=${st.p_blocks:04X} screens=${st.p_screens:04X}"
          f"({st.n_screens}) roommap=${st.p_roommap:04X}({st.roommap_len}) "
          f"props=${st.p_props:04X} alt=${st.p_alt:04X} mt={st.n_metatiles}")
print()
print(" distinct (pair,tileset) sets:",len(tsets))
for k,v in sorted(tsets.items()): print(f"   pair {k[0]} tileset {k[1]:3d} <- stages {v}")
print()
for p,ps in sorted(byp.items()):
    lo=min(ps); hi=0xC000
    print(f" pair {p} (banks {p},{p+1}): lowest level pointer ${lo:04X}, region to $C000 = {hi-lo} bytes")
