import sys
from PIL import Image
sys.path.insert(0,'/Users/hropl/pr/mypr/PB3/work/tools')
from m6502 import Rom
PAL=[(0,0,0),(85,85,85),(170,170,170),(255,255,255)]
def sheet(chr_bytes, cols=16):
    n=len(chr_bytes)//16
    rows=(n+cols-1)//cols
    img=Image.new('RGB',(cols*8,rows*8))
    px=img.load()
    for t in range(n):
        b=chr_bytes[t*16:t*16+16]
        tx=(t%cols)*8; ty=(t//cols)*8
        for y in range(8):
            lo=b[y]; hi=b[y+8]
            for x in range(8):
                c=((lo>>(7-x))&1)|(((hi>>(7-x))&1)<<1)
                px[tx+x,ty+y]=PAL[c]
    return img
if __name__=='__main__':
    rom=Rom(sys.argv[1]); out=sys.argv[2]
    # whole CHR as one tall sheet per 8K bank
    for i in range(len(rom.chr)//8192):
        sheet(rom.chr[i*8192:(i+1)*8192]).resize((16*8*2,32*8*2),Image.NEAREST).save(f"{out}_bank{i:02d}.png")
    print("ok", len(rom.chr)//8192)
