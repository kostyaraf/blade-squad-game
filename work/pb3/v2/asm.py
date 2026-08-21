"""A small 6502 assembler, enough for the patches PB3 needs.

Written because the ver1 build hand-counted branch offsets and paid for it more
than once.  Source is plain text, one instruction per line, labels end with a
colon; `.byte`/`.word` place data.  Two passes: the first sizes everything, the
second resolves labels.  Zero page is chosen automatically when the operand is
known on pass one and fits in a byte, so `lda $05a2` and `lda $35` both do the
right thing without the writer thinking about it.
"""
import re

# One entry per mnemonic: mode -> opcode.  Modes are the usual names; `acc` is
# the A-register form (`asl a`), `imp` takes no operand.
OPS = {
    'adc': {'imm':0x69,'zp':0x65,'zpx':0x75,'abs':0x6D,'absx':0x7D,'absy':0x79,'indx':0x61,'indy':0x71},
    'and': {'imm':0x29,'zp':0x25,'zpx':0x35,'abs':0x2D,'absx':0x3D,'absy':0x39,'indx':0x21,'indy':0x31},
    'asl': {'acc':0x0A,'zp':0x06,'zpx':0x16,'abs':0x0E,'absx':0x1E},
    'bit': {'zp':0x24,'abs':0x2C},
    'cmp': {'imm':0xC9,'zp':0xC5,'zpx':0xD5,'abs':0xCD,'absx':0xDD,'absy':0xD9,'indx':0xC1,'indy':0xD1},
    'cpx': {'imm':0xE0,'zp':0xE4,'abs':0xEC},
    'cpy': {'imm':0xC0,'zp':0xC4,'abs':0xCC},
    'dec': {'zp':0xC6,'zpx':0xD6,'abs':0xCE,'absx':0xDE},
    'eor': {'imm':0x49,'zp':0x45,'zpx':0x55,'abs':0x4D,'absx':0x5D,'absy':0x59,'indx':0x41,'indy':0x51},
    'inc': {'zp':0xE6,'zpx':0xF6,'abs':0xEE,'absx':0xFE},
    'jmp': {'abs':0x4C,'ind':0x6C},
    'jsr': {'abs':0x20},
    'lda': {'imm':0xA9,'zp':0xA5,'zpx':0xB5,'abs':0xAD,'absx':0xBD,'absy':0xB9,'indx':0xA1,'indy':0xB1},
    'ldx': {'imm':0xA2,'zp':0xA6,'zpy':0xB6,'abs':0xAE,'absy':0xBE},
    'ldy': {'imm':0xA0,'zp':0xA4,'zpx':0xB4,'abs':0xAC,'absx':0xBC},
    'lsr': {'acc':0x4A,'zp':0x46,'zpx':0x56,'abs':0x4E,'absx':0x5E},
    'ora': {'imm':0x09,'zp':0x05,'zpx':0x15,'abs':0x0D,'absx':0x1D,'absy':0x19,'indx':0x01,'indy':0x11},
    'rol': {'acc':0x2A,'zp':0x26,'zpx':0x36,'abs':0x2E,'absx':0x3E},
    'ror': {'acc':0x6A,'zp':0x66,'zpx':0x76,'abs':0x6E,'absx':0x7E},
    'sbc': {'imm':0xE9,'zp':0xE5,'zpx':0xF5,'abs':0xED,'absx':0xFD,'absy':0xF9,'indx':0xE1,'indy':0xF1},
    'sta': {'zp':0x85,'zpx':0x95,'abs':0x8D,'absx':0x9D,'absy':0x99,'indx':0x81,'indy':0x91},
    'stx': {'zp':0x86,'zpy':0x96,'abs':0x8E},
    'sty': {'zp':0x84,'zpx':0x94,'abs':0x8C},
}
IMPLIED = {'brk':0x00,'clc':0x18,'cld':0xD8,'cli':0x58,'clv':0xB8,'dex':0xCA,'dey':0x88,
           'inx':0xE8,'iny':0xC8,'nop':0xEA,'pha':0x48,'php':0x08,'pla':0x68,'plp':0x28,
           'rti':0x40,'rts':0x60,'sec':0x38,'sed':0xF8,'sei':0x78,'tax':0xAA,'tay':0xA8,
           'tsx':0xBA,'txa':0x8A,'txs':0x9A,'tya':0x98}
BRANCH = {'bcc':0x90,'bcs':0xB0,'beq':0xF0,'bmi':0x30,'bne':0xD0,'bpl':0x10,'bvc':0x50,'bvs':0x70}


class AsmError(Exception):
    pass


def _split(line):
    line = line.split(';')[0].rstrip()
    if not line.strip():
        return None, None, None
    lab = None
    m = re.match(r'^(\w+):\s*(.*)$', line.strip())
    if m:
        lab, line = m.group(1), m.group(2)
    line = line.strip()
    if not line:
        return lab, None, None
    parts = line.split(None, 1)
    return lab, parts[0].lower(), (parts[1].strip() if len(parts) > 1 else '')


class Asm:
    """Assemble `text` at `org`.  `syms` seeds the symbol table with names the
    caller already knows (engine entry points, RAM addresses)."""

    def __init__(self, org, syms=None):
        self.org = org
        self.syms = dict(syms or {})

    def _val(self, expr, pass2):
        expr = expr.strip()
        def sub(m):
            n = m.group(0)
            if re.match(r'^\$[0-9a-fA-F]+$', n):
                return str(int(n[1:], 16))
            if re.match(r'^\d+$', n):
                return n
            if n in self.syms:
                return str(self.syms[n])
            if not pass2:
                raise KeyError(n)
            raise AsmError('unknown symbol ' + n)
        try:
            e = re.sub(r'\$[0-9a-fA-F]+|\b[A-Za-z_]\w*\b|\b\d+\b', sub, expr)
        except KeyError:
            return None
        lo = e.startswith('<'); hi = e.startswith('>')
        if lo or hi:
            e = e[1:]
        v = eval(e, {'__builtins__': {}}, {})
        if lo:
            v &= 0xFF
        elif hi:
            v = (v >> 8) & 0xFF
        return v

    def _mode(self, op, arg, pass2):
        """Return (mode, value).  `value` may be None on pass one."""
        table = OPS[op]
        if arg == '' or arg.lower() == 'a':
            return ('acc', None)
        m = re.match(r'^#(.*)$', arg)
        if m:
            return ('imm', self._val(m.group(1), pass2))
        m = re.match(r'^\((.*),\s*[xX]\)$', arg)
        if m:
            return ('indx', self._val(m.group(1), pass2))
        m = re.match(r'^\((.*)\),\s*[yY]$', arg)
        if m:
            return ('indy', self._val(m.group(1), pass2))
        m = re.match(r'^\((.*)\)$', arg)
        if m:
            return ('ind', self._val(m.group(1), pass2))
        m = re.match(r'^(.*),\s*([xXyY])$', arg)
        if m:
            v = self._val(m.group(1), pass2)
            idx = m.group(2).lower()
            zp = ('zpx' if idx == 'x' else 'zpy')
            ab = ('absx' if idx == 'x' else 'absy')
            if v is not None and v < 0x100 and zp in table:
                return (zp, v)
            return (ab, v)
        v = self._val(arg, pass2)
        if v is not None and v < 0x100 and 'zp' in table:
            return ('zp', v)
        return ('abs', v)

    def assemble(self, text):
        # Sizes settle after a pass or two -- a forward label starts unknown,
        # so an operand can shrink from absolute to zero page once it is
        # known.  Keep laying it out until nothing moves, then check.
        out = bytearray()
        for p in (1, 1, 1, 2):
            out = bytearray()
            pc = self.org
            for ln, raw in enumerate(text.splitlines(), 1):
                lab, op, arg = _split(raw)
                if lab:
                    if p == 1:
                        self.syms[lab] = pc
                    elif self.syms.get(lab) != pc:
                        raise AsmError('label %s moved (line %d)' % (lab, ln))
                if op is None:
                    continue
                try:
                    b = self._enc(op, arg, pc, p == 2)
                except AsmError as e:
                    raise AsmError('line %d: %s: %s' % (ln, raw.strip(), e))
                out += b
                pc += len(b)
        self.size = len(out)
        self.end = self.org + len(out)
        return bytes(out)

    def _enc(self, op, arg, pc, pass2):
        if op == '.byte':
            return bytes((self._val(x, pass2) or 0) & 0xFF for x in arg.split(','))
        if op == '.word':
            b = bytearray()
            for x in arg.split(','):
                v = self._val(x, pass2) or 0
                b += bytes((v & 0xFF, (v >> 8) & 0xFF))
            return bytes(b)
        if op == '.res':
            return bytes(self._val(arg, pass2) or 0)
        if op in IMPLIED:
            return bytes((IMPLIED[op],))
        if op in BRANCH:
            t = self._val(arg, pass2)
            if t is None:
                return bytes((BRANCH[op], 0))
            d = t - (pc + 2)
            if pass2 and not -128 <= d <= 127:
                raise AsmError('branch out of range (%d)' % d)
            return bytes((BRANCH[op], d & 0xFF))
        if op not in OPS:
            raise AsmError('unknown mnemonic ' + op)
        mode, v = self._mode(op, arg, pass2)
        if mode not in OPS[op]:
            raise AsmError('%s does not take %s' % (op, mode))
        o = OPS[op][mode]
        if mode == 'acc':
            return bytes((o,))
        if v is None:
            v = 0
        if mode in ('imm', 'zp', 'zpx', 'zpy', 'indx', 'indy'):
            return bytes((o, v & 0xFF))
        return bytes((o, v & 0xFF, (v >> 8) & 0xFF))


def assemble(org, text, syms=None):
    a = Asm(org, syms)
    return a.assemble(text), a.syms
