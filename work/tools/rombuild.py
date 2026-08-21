"""PB3 ROM builder: composes a multicart image from the two original ROMs
plus newly assembled PB3 code, applying byte/asm patches along the way."""
import os, subprocess, tempfile, sys, json

TOOLS=os.path.dirname(os.path.abspath(__file__))
ROOT=os.path.dirname(os.path.dirname(TOOLS)) if False else os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROOT=os.path.dirname(TOOLS)          # .../work
PROJ=os.path.dirname(ROOT)           # project root
PB2 = os.path.join(PROJ,"Power Blade 2 (USA).nes")
SOL = os.path.join(PROJ,"Tokkyuu Shirei Solbrain (Japan).nes")

BANK=8192

def load(path):
    raw=open(path,'rb').read()
    assert raw[:4]==b'NES\x1a', path
    prg_n, chr_n = raw[4], raw[5]
    prg=raw[16:16+prg_n*16384]
    chrom=raw[16+prg_n*16384:][:chr_n*8192]
    return bytearray(prg), bytearray(chrom)

def ca65(source, org):
    """Assemble a snippet at a fixed origin; return raw bytes."""
    with tempfile.TemporaryDirectory() as td:
        s=os.path.join(td,"s.s"); o=os.path.join(td,"s.o"); b=os.path.join(td,"s.bin")
        cfg=os.path.join(td,"s.cfg")
        open(s,'w').write(".segment \"CODE\"\n"+source+"\n")
        open(cfg,'w').write(
            "MEMORY { RAM: start=$%04X, size=$%04X, type=ro, file=%%O, fill=yes, fillval=$FF; }\n"
            "SEGMENTS { CODE: load=RAM, type=ro; }\n" % (org, 0x10000-org))
        r=subprocess.run(["ca65","-o",o,s],capture_output=True,text=True)
        if r.returncode: raise RuntimeError("ca65: "+r.stderr+r.stdout)
        r=subprocess.run(["ld65","-C",cfg,"-o",b,o],capture_output=True,text=True)
        if r.returncode: raise RuntimeError("ld65: "+r.stderr+r.stdout)
        data=open(b,'rb').read()
    # strip the fill tail
    n=len(data)
    while n>0 and data[n-1]==0xFF: n-=1
    return data[:n]

class Image:
    """A mutable PRG/CHR image addressed as bank:offset."""
    def __init__(self, prg, chrom, name):
        self.prg=bytearray(prg); self.chr=bytearray(chrom); self.name=name
        self.claims={}   # (bank,off)->tag, to catch overlapping patches
    def nbanks(self): return len(self.prg)//BANK
    def put(self, bank, off, data, tag=""):
        base=bank*BANK+off
        assert off+len(data)<=BANK, f"{self.name} b{bank}:{off:04X} overruns bank"
        for i in range(len(data)):
            k=(bank,off+i)
            if k in self.claims and self.claims[k]!=tag:
                raise RuntimeError(f"patch overlap in {self.name} b{bank}:{off+i:04X} "
                                   f"({self.claims[k]} vs {tag})")
            self.claims[k]=tag
        self.prg[base:base+len(data)]=data
    def putasm(self, bank, off, org, source, tag=""):
        self.put(bank, off, ca65(source, org), tag)
    def get(self, bank, off, n): return bytes(self.prg[bank*BANK+off:bank*BANK+off+n])

def make_header(prg_bytes, chr_bytes, mapper, submapper=0, mirroring=0, nes2=True):
    h=bytearray(16)
    h[0:4]=b'NES\x1a'
    prg16=prg_bytes//16384; chr8=chr_bytes//8192
    h[4]=prg16 & 0xFF
    h[5]=chr8 & 0xFF
    h[6]=(mirroring&1) | ((mapper&0x0F)<<4)
    h[7]=((mapper>>4)&0x0F)<<4
    if nes2:
        h[7]|=0x08
        h[8]=((submapper&0x0F)<<4) | ((mapper>>8)&0x0F)
        h[9]=((chr8>>8)<<4) | ((prg16>>8)&0x0F)
        h[10]=0; h[11]=0; h[12]=0; h[13]=0; h[14]=0; h[15]=0
    return bytes(h)

def write_nes(path, header, prg, chrom):
    with open(path,'wb') as f:
        f.write(header); f.write(prg); f.write(chrom)
    print(f"wrote {path}: {len(header)+len(prg)+len(chrom)} bytes "
          f"(PRG {len(prg)//1024}K, CHR {len(chrom)//1024}K)")

if __name__=='__main__':
    p,c=load(PB2); print("PB2", len(p)//1024,"K PRG", len(c)//1024,"K CHR")
    p,c=load(SOL); print("SOL", len(p)//1024,"K PRG", len(c)//1024,"K CHR")
    print("ca65 smoke:", ca65("lda #$01\nsta $8000\nrts", 0xC000).hex())
