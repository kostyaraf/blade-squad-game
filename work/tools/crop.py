import sys, zlib, struct
def readpng(p):
    d=open(p,'rb').read(); pos=8; w=h=0; idat=b''; pal=None
    while pos<len(d):
        ln=struct.unpack('>I',d[pos:pos+4])[0]; typ=d[pos+4:pos+8]; data=d[pos+8:pos+8+ln]
        if typ==b'IHDR': w,h,bd,ct=struct.unpack('>IIBB',data[:10])
        elif typ==b'PLTE': pal=data
        elif typ==b'IDAT': idat+=data
        pos+=12+ln
    raw=zlib.decompress(idat)
    bpp=3 if pal is None else 1
    stride=w*bpp
    out=bytearray(); prev=bytearray(stride)
    i=0
    for y in range(h):
        f=raw[i]; i+=1; line=bytearray(raw[i:i+stride]); i+=stride
        for x in range(stride):
            a=line[x-bpp] if x>=bpp else 0; b=prev[x]; c=prev[x-bpp] if x>=bpp else 0
            if f==1: line[x]=(line[x]+a)&255
            elif f==2: line[x]=(line[x]+b)&255
            elif f==3: line[x]=(line[x]+((a+b)>>1))&255
            elif f==4:
                p=a+b-c; pa=abs(p-a); pb=abs(p-b); pc=abs(p-c)
                pr=a if (pa<=pb and pa<=pc) else (b if pb<=pc else c)
                line[x]=(line[x]+pr)&255
        out+=line; prev=line
    px=[]
    for y in range(h):
        row=[]
        for x in range(w):
            if pal: v=out[y*stride+x]; row.append((pal[v*3],pal[v*3+1],pal[v*3+2]))
            else: o=y*stride+x*3; row.append((out[o],out[o+1],out[o+2]))
        px.append(row)
    return w,h,px
def writepng(p,px):
    h=len(px); w=len(px[0]); raw=b''
    for row in px: raw+=b'\x00'+bytes(b for c in row for b in c)
    def ch(t,d): 
        c=struct.pack('>I',len(d))+t+d; return c+struct.pack('>I',zlib.crc32(t+d)&0xffffffff)
    open(p,'wb').write(b'\x89PNG\r\n\x1a\n'+ch(b'IHDR',struct.pack('>IIBBBBB',w,h,8,2,0,0,0))+ch(b'IDAT',zlib.compress(raw))+ch(b'IEND',b''))
if __name__=='__main__':
    src,dst,x0,y0,cw,chh,z=sys.argv[1],sys.argv[2],*[int(v) for v in sys.argv[3:8]]
    w,h,px=readpng(src)
    out=[]
    for y in range(y0,min(y0+chh,h)):
        row=[]
        for x in range(x0,min(x0+cw,w)):
            for _ in range(z): row.append(px[y][x])
        for _ in range(z): out.append(row)
    writepng(dst,out)
