"""Pixel-exact comparison of two PNGs, used to prove a rebuilt frame matches
what the real hardware path drew."""
import zlib, struct, sys

def readpng(p):
    d = open(p, 'rb').read(); i = 8; w = h = None; idat = b''
    while i < len(d):
        ln = struct.unpack('>I', d[i:i+4])[0]; typ = d[i+4:i+8]
        if typ == b'IHDR': w, h = struct.unpack('>II', d[i+8:i+16])
        elif typ == b'IDAT': idat += d[i+8:i+8+ln]
        i += 12 + ln
    raw = zlib.decompress(idat); out = bytearray(); prev = bytearray(w*3); pos = 0
    for _ in range(h):
        f = raw[pos]; pos += 1
        line = bytearray(raw[pos:pos+w*3]); pos += w*3
        if f == 1:
            for x in range(3, len(line)): line[x] = (line[x] + line[x-3]) & 255
        elif f == 2:
            for x in range(len(line)): line[x] = (line[x] + prev[x]) & 255
        elif f == 3:
            for x in range(len(line)):
                a = line[x-3] if x >= 3 else 0
                line[x] = (line[x] + ((a + prev[x]) >> 1)) & 255
        elif f == 4:
            for x in range(len(line)):
                a = line[x-3] if x >= 3 else 0; b = prev[x]; c = prev[x-3] if x >= 3 else 0
                pa, pb, pc = abs(b-c), abs(a-c), abs(a+b-2*c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[x] = (line[x] + pr) & 255
        out += line; prev = line
    return w, h, bytes(out)

if __name__ == '__main__':
    w, h, a = readpng(sys.argv[1])
    w2, h2, b = readpng(sys.argv[2])
    assert (w, h) == (w2, h2), f"size mismatch {w}x{h} vs {w2}x{h2}"
    bad = [i//3 for i in range(0, len(a), 3) if a[i:i+3] != b[i:i+3]]
    print(f"{len(bad)} / {w*h} pixels differ ({100*len(bad)/(w*h):.2f}%)")
    if bad:
        rows = sorted({p//w for p in bad})
        cols = sorted({p%w for p in bad})
        print(f"  rows {rows[0]}..{rows[-1]} ({len(rows)} of {h})   cols {cols[0]}..{cols[-1]}")
    sys.exit(1 if bad else 0)
