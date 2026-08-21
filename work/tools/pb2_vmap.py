import sys, os
sys.path.insert(0,'work/tools')
from pb2_levels import PB2Levels, SCREEN_W
from vram import NES_PAL, write_png, load_chr, Vram

S="/private/tmp/claude-501/-Users-hropl-pr-mypr-PB3/d10a86b4-c8f0-47fa-b136-38600eb1fc86/scratchpad/va"
rom="Power Blade 2 (USA).nes"
lv=PB2Levels(rom); chrom=load_chr(rom)

def render(tag, stg, ar, cam_start, cam_limit):
    v=Vram(f"{S}/x{tag}.vram")
    pal=list(v.scan[10]['pal']); banks=list(v.chr_scan[10])
    st=lv.stage(stg); st['attr']=st['collision']
    lst=st['areas'][ar]
    N=len(lst)
    IW=256; IH=N*240
    img=bytearray(IW*IH*3)
    for n,si in enumerate(lst):
        s=st['screens'][si]
        for br in range(s['h']):
            for bc in range(SCREEN_W):
                b=s['data'][br*SCREEN_W+bc]
                if b>=st['nblocks']: continue
                blk=st['blocks'][b]; att=st['attr'][b]
                for r in range(4):
                    for c in range(4):
                        t=blk[r*4+c]
                        q=(r//2)*2+(c//2); pl=(att>>(q*2))&3
                        bank=banks[((t>>6)&3)+4]
                        off=bank*1024+(t&0x3F)*16
                        tr=br*4+r
                        if tr>=30: continue
                        px0=(bc*4+c)*8; py0=n*240+tr*8
                        for y in range(8):
                            lo=chrom[off+y]; hi=chrom[off+8+y]
                            base=((py0+y)*IW+px0)*3
                            for x in range(8):
                                vv=((lo>>(7-x))&1)|(((hi>>(7-x))&1)<<1)
                                col=NES_PAL[pal[0] if vv==0 else pal[pl*4+vv]]
                                o=base+x*3
                                img[o]=(col>>16)&0xFF; img[o+1]=(col>>8)&0xFF; img[o+2]=col&0xFF
    out=f"{S}/eng_{tag}.png"
    write_png(out,img,IW,IH); print("wrote",out,"N=",N,"px rows used per screen=32 (data)")

if __name__=='__main__':
    for tag,stg,ar,cs,cl in [('s0a1',0,1,144,144),('s1a1',1,1,0,304),('s2a0',2,0,464,464),
                             ('s2a3',2,3,784,784),('s3a5',3,5,0,144),('s5a0',5,0,0,960)]:
        render(tag,stg,ar,cs,cl)
