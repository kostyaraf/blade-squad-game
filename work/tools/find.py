import sys
sys.path.insert(0,'/Users/hropl/pr/mypr/PB3/work/tools')
from m6502 import Rom
rom=Rom(sys.argv[1])
pat=bytes.fromhex(sys.argv[2].replace(' ',''))
st=0; out=[]
while True:
    i=rom.prg.find(pat,st)
    if i<0: break
    out.append(i); st=i+1
for i in out:
    print(f"b{i//8192:2}:{i%8192:04X}  (prg ${i:05X})")
print(len(out),"hits")
