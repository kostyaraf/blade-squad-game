"""Global byte-pattern scanners for a NES PRG image."""
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from m6502 import Rom

ROM="/Users/hropl/pr/mypr/PB3/Power Blade 2 (USA).nes"

# opcode -> (mnemonic, kind) for zero-page operand in byte 1
ZPOPS={
0xA5:('LDA','r'),0x85:('STA','w'),0xB5:('LDA,X','r'),0x95:('STA,X','w'),
0xA6:('LDX','r'),0x86:('STX','w'),0xB6:('LDX,Y','r'),0x96:('STX,Y','w'),
0xA4:('LDY','r'),0x84:('STY','w'),0xB4:('LDY,X','r'),0x94:('STY,X','w'),
0xE6:('INC','rw'),0xF6:('INC,X','rw'),0xC6:('DEC','rw'),0xD6:('DEC,X','rw'),
0x24:('BIT','r'),0x06:('ASL','rw'),0x16:('ASL,X','rw'),0x46:('LSR','rw'),0x56:('LSR,X','rw'),
0x26:('ROL','rw'),0x36:('ROL,X','rw'),0x66:('ROR','rw'),0x76:('ROR,X','rw'),
0x65:('ADC','r'),0x75:('ADC,X','r'),0xE5:('SBC','r'),0xF5:('SBC,X','r'),
0xC5:('CMP','r'),0xD5:('CMP,X','r'),0xE4:('CPX','r'),0xC4:('CPY','r'),
0x05:('ORA','r'),0x15:('ORA,X','r'),0x25:('AND','r'),0x35:('AND,X','r'),
0x45:('EOR','r'),0x55:('EOR,X','r'),
0xA1:('LDA(zp,X)','r'),0xB1:('LDA(zp),Y','r'),0x81:('STA(zp,X)','w'),0x91:('STA(zp),Y','w'),
0xC1:('CMP(zp,X)','r'),0xD1:('CMP(zp),Y','r'),0xE1:('SBC(zp,X)','r'),0xF1:('SBC(zp),Y','r'),
0x61:('ADC(zp,X)','r'),0x71:('ADC(zp),Y','r'),0x01:('ORA(zp,X)','r'),0x11:('ORA(zp),Y','r'),
0x21:('AND(zp,X)','r'),0x31:('AND(zp),Y','r'),0x41:('EOR(zp,X)','r'),0x51:('EOR(zp),Y','r'),
}
ABSOPS={
0xAD:('LDA','r'),0x8D:('STA','w'),0xBD:('LDA,X','r'),0x9D:('STA,X','w'),
0xB9:('LDA,Y','r'),0x99:('STA,Y','w'),0xAE:('LDX','r'),0x8E:('STX','w'),
0xBE:('LDX,Y','r'),0xAC:('LDY','r'),0x8C:('STY','w'),0xBC:('LDY,X','r'),
0xEE:('INC','rw'),0xFE:('INC,X','rw'),0xCE:('DEC','rw'),0xDE:('DEC,X','rw'),
0x2C:('BIT','r'),0x0E:('ASL','rw'),0x1E:('ASL,X','rw'),0x4E:('LSR','rw'),0x5E:('LSR,X','rw'),
0x2E:('ROL','rw'),0x3E:('ROL,X','rw'),0x6E:('ROR','rw'),0x7E:('ROR,X','rw'),
0x6D:('ADC','r'),0x7D:('ADC,X','r'),0x79:('ADC,Y','r'),
0xED:('SBC','r'),0xFD:('SBC,X','r'),0xF9:('SBC,Y','r'),
0xCD:('CMP','r'),0xDD:('CMP,X','r'),0xD9:('CMP,Y','r'),0xEC:('CPX','r'),0xCC:('CPY','r'),
0x0D:('ORA','r'),0x1D:('ORA,X','r'),0x19:('ORA,Y','r'),
0x2D:('AND','r'),0x3D:('AND,X','r'),0x39:('AND,Y','r'),
0x4D:('EOR','r'),0x5D:('EOR,X','r'),0x59:('EOR,Y','r'),
0x20:('JSR','j'),0x4C:('JMP','j'),0x6C:('JMP()','j'),
}
def scan_zp(prg, zp):
    hits=[]
    for i in range(len(prg)-1):
        op=prg[i]
        if op in ZPOPS and prg[i+1]==zp:
            hits.append((i,ZPOPS[op]))
    return hits
def scan_abs(prg, addr):
    lo=addr&0xFF; hi=addr>>8
    hits=[]
    for i in range(len(prg)-2):
        op=prg[i]
        if op in ABSOPS and prg[i+1]==lo and prg[i+2]==hi:
            hits.append((i,ABSOPS[op]))
    return hits
def loc(i): return f"b{i//8192:02d}:{i%8192:04X}"

if __name__=='__main__':
    rom=Rom(ROM)
    mode=sys.argv[1]
    if mode=='zp':
        for a in sys.argv[2:]:
            zp=int(a,16)
            h=scan_zp(rom.prg,zp)
            print(f"=== ${zp:02X}: {len(h)} candidate refs")
            for i,(mn,k) in h: print(f"  {loc(i)} {mn:<12}{k}")
    elif mode=='abs':
        for a in sys.argv[2:]:
            ad=int(a,16)
            h=scan_abs(rom.prg,ad)
            print(f"=== ${ad:04X}: {len(h)} candidate refs")
            for i,(mn,k) in h: print(f"  {loc(i)} {mn:<12}{k}")
    elif mode=='zpw':  # writes only, counts per bank
        for a in sys.argv[2:]:
            zp=int(a,16); h=[x for x in scan_zp(rom.prg,zp) if 'w' in x[1][1]]
            print(f"${zp:02X}: {len(h)} writes: "+' '.join(loc(i) for i,_ in h))
