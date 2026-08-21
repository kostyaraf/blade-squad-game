"""6502 disassembler with NES MMC3 bank awareness."""
import struct, json, sys, os

# (mnemonic, addressing mode, length)
IMP,ACC,IMM,ZP,ZPX,ZPY,ABS,ABX,ABY,IND,IZX,IZY,REL = range(13)
MODELEN={IMP:1,ACC:1,IMM:2,ZP:2,ZPX:2,ZPY:2,ABS:3,ABX:3,ABY:3,IND:3,IZX:2,IZY:2,REL:2}

T=[None]*256
def d(op,mn,md): T[op]=(mn,md)
for op,mn,md in [
(0x00,'BRK',IMM),(0x01,'ORA',IZX),(0x05,'ORA',ZP),(0x06,'ASL',ZP),(0x08,'PHP',IMP),(0x09,'ORA',IMM),
(0x0A,'ASL',ACC),(0x0D,'ORA',ABS),(0x0E,'ASL',ABS),(0x10,'BPL',REL),(0x11,'ORA',IZY),(0x15,'ORA',ZPX),
(0x16,'ASL',ZPX),(0x18,'CLC',IMP),(0x19,'ORA',ABY),(0x1D,'ORA',ABX),(0x1E,'ASL',ABX),(0x20,'JSR',ABS),
(0x21,'AND',IZX),(0x24,'BIT',ZP),(0x25,'AND',ZP),(0x26,'ROL',ZP),(0x28,'PLP',IMP),(0x29,'AND',IMM),
(0x2A,'ROL',ACC),(0x2C,'BIT',ABS),(0x2D,'AND',ABS),(0x2E,'ROL',ABS),(0x30,'BMI',REL),(0x31,'AND',IZY),
(0x35,'AND',ZPX),(0x36,'ROL',ZPX),(0x38,'SEC',IMP),(0x39,'AND',ABY),(0x3D,'AND',ABX),(0x3E,'ROL',ABX),
(0x40,'RTI',IMP),(0x41,'EOR',IZX),(0x45,'EOR',ZP),(0x46,'LSR',ZP),(0x48,'PHA',IMP),(0x49,'EOR',IMM),
(0x4A,'LSR',ACC),(0x4C,'JMP',ABS),(0x4D,'EOR',ABS),(0x4E,'LSR',ABS),(0x50,'BVC',REL),(0x51,'EOR',IZY),
(0x55,'EOR',ZPX),(0x56,'LSR',ZPX),(0x58,'CLI',IMP),(0x59,'EOR',ABY),(0x5D,'EOR',ABX),(0x5E,'LSR',ABX),
(0x60,'RTS',IMP),(0x61,'ADC',IZX),(0x65,'ADC',ZP),(0x66,'ROR',ZP),(0x68,'PLA',IMP),(0x69,'ADC',IMM),
(0x6A,'ROR',ACC),(0x6C,'JMP',IND),(0x6D,'ADC',ABS),(0x6E,'ROR',ABS),(0x70,'BVS',REL),(0x71,'ADC',IZY),
(0x75,'ADC',ZPX),(0x76,'ROR',ZPX),(0x78,'SEI',IMP),(0x79,'ADC',ABY),(0x7D,'ADC',ABX),(0x7E,'ROR',ABX),
(0x81,'STA',IZX),(0x84,'STY',ZP),(0x85,'STA',ZP),(0x86,'STX',ZP),(0x88,'DEY',IMP),(0x8A,'TXA',IMP),
(0x8C,'STY',ABS),(0x8D,'STA',ABS),(0x8E,'STX',ABS),(0x90,'BCC',REL),(0x91,'STA',IZY),(0x94,'STY',ZPX),
(0x95,'STA',ZPX),(0x96,'STX',ZPY),(0x98,'TYA',IMP),(0x99,'STA',ABY),(0x9A,'TXS',IMP),(0x9D,'STA',ABX),
(0xA0,'LDY',IMM),(0xA1,'LDA',IZX),(0xA2,'LDX',IMM),(0xA4,'LDY',ZP),(0xA5,'LDA',ZP),(0xA6,'LDX',ZP),
(0xA8,'TAY',IMP),(0xA9,'LDA',IMM),(0xAA,'TAX',IMP),(0xAC,'LDY',ABS),(0xAD,'LDA',ABS),(0xAE,'LDX',ABS),
(0xB0,'BCS',REL),(0xB1,'LDA',IZY),(0xB4,'LDY',ZPX),(0xB5,'LDA',ZPX),(0xB6,'LDX',ZPY),(0xB8,'CLV',IMP),
(0xB9,'LDA',ABY),(0xBA,'TSX',IMP),(0xBC,'LDY',ABX),(0xBD,'LDA',ABX),(0xBE,'LDX',ABY),(0xC0,'CPY',IMM),
(0xC1,'CMP',IZX),(0xC4,'CPY',ZP),(0xC5,'CMP',ZP),(0xC6,'DEC',ZP),(0xC8,'INY',IMP),(0xC9,'CMP',IMM),
(0xCA,'DEX',IMP),(0xCC,'CPY',ABS),(0xCD,'CMP',ABS),(0xCE,'DEC',ABS),(0xD0,'BNE',REL),(0xD1,'CMP',IZY),
(0xD5,'CMP',ZPX),(0xD6,'DEC',ZPX),(0xD8,'CLD',IMP),(0xD9,'CMP',ABY),(0xDD,'CMP',ABX),(0xDE,'DEC',ABX),
(0xE0,'CPX',IMM),(0xE1,'SBC',IZX),(0xE4,'CPX',ZP),(0xE5,'SBC',ZP),(0xE6,'INC',ZP),(0xE8,'INX',IMP),
(0xE9,'SBC',IMM),(0xEA,'NOP',IMP),(0xEC,'CPX',ABS),(0xED,'SBC',ABS),(0xEE,'INC',ABS),(0xF0,'BEQ',REL),
(0xF1,'SBC',IZY),(0xF5,'SBC',ZPX),(0xF6,'INC',ZPX),(0xF8,'SED',IMP),(0xF9,'SBC',ABY),(0xFD,'SBC',ABX),
(0xFE,'INC',ABX),
# unofficial
(0x03,'SLO',IZX),(0x07,'SLO',ZP),(0x0F,'SLO',ABS),(0x13,'SLO',IZY),(0x17,'SLO',ZPX),(0x1B,'SLO',ABY),(0x1F,'SLO',ABX),
(0x23,'RLA',IZX),(0x27,'RLA',ZP),(0x2F,'RLA',ABS),(0x33,'RLA',IZY),(0x37,'RLA',ZPX),(0x3B,'RLA',ABY),(0x3F,'RLA',ABX),
(0x43,'SRE',IZX),(0x47,'SRE',ZP),(0x4F,'SRE',ABS),(0x53,'SRE',IZY),(0x57,'SRE',ZPX),(0x5B,'SRE',ABY),(0x5F,'SRE',ABX),
(0x63,'RRA',IZX),(0x67,'RRA',ZP),(0x6F,'RRA',ABS),(0x73,'RRA',IZY),(0x77,'RRA',ZPX),(0x7B,'RRA',ABY),(0x7F,'RRA',ABX),
(0x83,'SAX',IZX),(0x87,'SAX',ZP),(0x8F,'SAX',ABS),(0x97,'SAX',ZPY),
(0xA3,'LAX',IZX),(0xA7,'LAX',ZP),(0xAF,'LAX',ABS),(0xB3,'LAX',IZY),(0xB7,'LAX',ZPY),(0xBF,'LAX',ABY),
(0xC3,'DCP',IZX),(0xC7,'DCP',ZP),(0xCF,'DCP',ABS),(0xD3,'DCP',IZY),(0xD7,'DCP',ZPX),(0xDB,'DCP',ABY),(0xDF,'DCP',ABX),
(0xE3,'ISC',IZX),(0xE7,'ISC',ZP),(0xEF,'ISC',ABS),(0xF3,'ISC',IZY),(0xF7,'ISC',ZPX),(0xFB,'ISC',ABY),(0xFF,'ISC',ABX),
(0x0B,'ANC',IMM),(0x2B,'ANC',IMM),(0x4B,'ALR',IMM),(0x6B,'ARR',IMM),(0xCB,'AXS',IMM),(0xEB,'SBC',IMM),
(0x1A,'NOP',IMP),(0x3A,'NOP',IMP),(0x5A,'NOP',IMP),(0x7A,'NOP',IMP),(0xDA,'NOP',IMP),(0xFA,'NOP',IMP),
(0x80,'NOP',IMM),(0x82,'NOP',IMM),(0x89,'NOP',IMM),(0xC2,'NOP',IMM),(0xE2,'NOP',IMM),
(0x04,'NOP',ZP),(0x44,'NOP',ZP),(0x64,'NOP',ZP),
(0x14,'NOP',ZPX),(0x34,'NOP',ZPX),(0x54,'NOP',ZPX),(0x74,'NOP',ZPX),(0xD4,'NOP',ZPX),(0xF4,'NOP',ZPX),
(0x0C,'NOP',ABS),(0x1C,'NOP',ABX),(0x3C,'NOP',ABX),(0x5C,'NOP',ABX),(0x7C,'NOP',ABX),(0xDC,'NOP',ABX),(0xFC,'NOP',ABX),
]:
    d(op,mn,md)

BRANCHES={'BPL','BMI','BVC','BVS','BCC','BCS','BNE','BEQ'}
TERMINAL={'RTS','RTI','JMP','BRK'}

def fmt(op,mn,md,operand,addr):
    if md==IMP: return mn
    if md==ACC: return mn+' A'
    if md==IMM: return f"{mn} #${operand:02X}"
    if md==ZP:  return f"{mn} ${operand:02X}"
    if md==ZPX: return f"{mn} ${operand:02X},X"
    if md==ZPY: return f"{mn} ${operand:02X},Y"
    if md==ABS: return f"{mn} ${operand:04X}"
    if md==ABX: return f"{mn} ${operand:04X},X"
    if md==ABY: return f"{mn} ${operand:04X},Y"
    if md==IND: return f"{mn} (${operand:04X})"
    if md==IZX: return f"{mn} (${operand:02X},X)"
    if md==IZY: return f"{mn} (${operand:02X}),Y"
    if md==REL:
        t=(addr+2+((operand^0x80)-0x80))&0xFFFF
        return f"{mn} ${t:04X}"
    return mn

def decode(data, off, addr):
    """returns (length, text, mnemonic, mode, operand, target_or_None)"""
    op=data[off]
    e=T[op]
    if e is None:
        return 1, f".byte ${op:02X}   ; invalid", None, None, None, None
    mn,md=e
    ln=MODELEN[md]
    if off+ln>len(data):
        return 1, f".byte ${op:02X}", None,None,None,None
    if ln==1: operand=None
    elif ln==2: operand=data[off+1]
    else: operand=data[off+1]|(data[off+2]<<8)
    tgt=None
    if md==REL: tgt=(addr+2+((operand^0x80)-0x80))&0xFFFF
    elif md==ABS and mn in ('JMP','JSR'): tgt=operand
    return ln, fmt(op,mn,md,operand,addr), mn, md, operand, tgt

class Rom:
    def __init__(self, path):
        raw=open(path,'rb').read()
        assert raw[:4]==b'NES\x1a'
        self.prg_n=raw[4]; self.chr_n=raw[5]
        self.prg=raw[16:16+self.prg_n*16384]
        self.chr=raw[16+self.prg_n*16384:][:self.chr_n*8192]
        self.header=raw[:16]
        self.nbanks=len(self.prg)//8192
    def bank(self,i): return self.prg[i*8192:(i+1)*8192]
    def vectors(self):
        b=self.bank(self.nbanks-1)
        return dict(nmi=b[0x1FFA]|b[0x1FFB]<<8, reset=b[0x1FFC]|b[0x1FFD]<<8, irq=b[0x1FFE]|b[0x1FFF]<<8)

def disasm_bank(rom, bank, base, entries=None, linear=True):
    data=rom.bank(bank)
    out=[]
    off=0
    while off<len(data):
        ln,txt,*_ = decode(data,off,base+off)
        raw=' '.join(f'{b:02X}' for b in data[off:off+ln])
        out.append((base+off, bank*8192+off, raw, txt))
        off+=ln
    return out

if __name__=='__main__':
    r=Rom(sys.argv[1])
    print(f"banks={r.nbanks} chr={len(r.chr)} vectors={ {k:hex(v) for k,v in r.vectors().items()} }")
