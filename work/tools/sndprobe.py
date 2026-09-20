"""Э6 -- the cartridge's own sound driver on a bare stand.

To compare a ported driver with the cartridge, both have to start from the
same place and be asked the same things.  Inside the running game the driver's
state is whatever the game has done to it, so instead the cartridge is booted
into a stand of its own: nothing running at all, the two banks the driver
needs mapped, and one call of the driver's per-picture entry per turn of a
small loop.  Requests are handed in by a table the loop walks.

Nothing of the driver, its data or its samples is touched.  What is
overwritten is the cartridge's own reset routine -- the bytes between where
the reset vector lands and the idle loop it ends in, which nothing else in the
cartridge refers to.  Solbrain's reset routine is not long enough, so there
the stand goes into the run of unused bytes at the end of the fixed bank and
the reset vector is pointed at it.

**Both banks.**  Neither driver is one bank: each game's wrapper maps the
driver at $8000 *and* the bank after it at $A000, where the music data lives
($ECAF for Power Blade 2, which sets $8000/$8001 twice with Y and Y+1; bank 14
for Solbrain, which sets R6 to 0 and R7 to 1).  A stand that maps only the
first gets the sounds that live beside the code and silence for everything
else.

What comes back is a tape: for every picture, every byte the driver wrote to
$4000..$4017, in order.  The picture is not the emulator's frame -- the stand
does not wait for a picture to be drawn, because the driver does not care --
but the turn of the loop, which the emulator reports by sampling its top.
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
PROJ = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import rombuild                                                  # noqa: E402

NESEMU = os.path.join(HERE, 'nesemu')
ROM = {
    'pb2': os.path.join(PROJ, 'Power Blade 2 (USA).nes'),
    'sol': os.path.join(PROJ, 'Tokkyuu Shirei Solbrain (Japan).nes'),
}

# $E5B9..$E63F is Power Blade 2's reset routine, and $E640 is the data after
# it; nothing in the cartridge refers into it.  $FF50..$FFDF is the run of
# $FF at the end of Solbrain's fixed bank.
BASE = {'pb2': 0xE5B9, 'sol': 0xFF50}
ROOM = {'pb2': 0xE640 - 0xE5B9, 'sol': 0xFFE0 - 0xFF50}
# The bank the driver's code is in; the bank after it holds the music data.
DRIVER = {'pb2': 12, 'sol': 0}
SLOTS = 4

_HEAD = """
    sei
    cld
    ldx #$FF
    txs
    lda #$00
    sta $2000
    sta $2001
    sta $E000
    tax
clr:
    sta $0000,x
    sta $0700,x
    inx
    bne clr
    lda #$06
    sta $8000
    lda #%(drv)d
    sta $8001
    lda #$07
    sta $8000
    lda #%(dat)d
    sta $8001
"""

# $8000 with the number in A is Power Blade 2's one door into the driver
# ($ECE8 is the game's own way in and does nothing else); $8003 is the
# picture.  Solbrain asks with two cells -- $F0 the tune, $F1 the sound --
# and its $8000 is both the picture and the reading of them.
_MAIN = {
    'pb2': _HEAD + """
    lda #$00
    jsr $8000
    lda #$00
    sta $10
    sta $11
    sta $12
    jmp %(loop)s
    nop
""",
    'sol': _HEAD + """
    lda #$00
    sta $10
    sta $11
    sta $12
    jmp %(loop)s
    nop
""",
}

_ASK = {
    'pb2': """
    lda %(num)s,x
    jsr $8000
""",
    'sol': """
    lda %(num)s,x
    ldy %(kind)s,x
    bne sfx
    sta $F0
    jmp tick
sfx:
    sta $F1
""",
}

_TICK = {'pb2': '    jsr $8003\n', 'sol': '    jsr $8000\n'}

_LOOP = """
    lda $11
    ldx $10
    cpx #%(slots)d
    bcs tick
    lda %(at_lo)s,x
    cmp $11
    bne tick
    lda %(at_hi)s,x
    cmp $12
    bne tick
    inc $10
""" + '%(ask)s' + """
tick:
""" + '%(tick)s' + """
    inc $11
    bne nz
    inc $12
nz:
    jmp %(loop)s
    nop
"""


def _sources(game, loop, table):
    w = {'drv': DRIVER[game], 'dat': DRIVER[game] + 1, 'loop': '$%04X' % loop,
         'slots': SLOTS, 'at_lo': '$%04X' % table,
         'at_hi': '$%04X' % (table + SLOTS),
         'kind': '$%04X' % (table + SLOTS * 2),
         'num': '$%04X' % (table + SLOTS * 3)}
    ask = _ASK[game] % w
    return _MAIN[game] % w, _LOOP % dict(w, ask=ask, tick=_TICK[game])


def build(game, path):
    """Write a stand ROM for `game` at `path`.  Returns (PRG file offset of
    the table of requests, the address of the top of the loop), so that a run
    can poke a request in without building the image again."""
    base = BASE[game]
    # Lengths do not depend on the addresses -- every operand is absolute --
    # so one pass with any addresses measures, and the second one is real.
    m0, l0 = _sources(game, base, base)
    n_main = len(rombuild.ca65(m0, base))
    n_loop = len(rombuild.ca65(l0, base + n_main))
    loop = base + n_main
    table = loop + n_loop
    # `rombuild.ca65` drops a tail of $FF, and a jump into the end of the
    # fixed bank ends in one; every snippet is closed with a byte that is not
    # $FF so that nothing of it is cut off.
    main_s, loop_s = _sources(game, loop, table)
    main = rombuild.ca65(main_s, base)
    body = rombuild.ca65(loop_s, loop)
    total = len(main) + len(body) + SLOTS * 4
    if total > ROOM[game]:
        raise RuntimeError('%s: the stand is %d bytes and there is room for %d'
                           % (game, total, ROOM[game]))
    prg, chrom = rombuild.load(ROM[game])
    last = (len(prg) // 8192 - 1) * 8192
    at = last + (base - 0xE000)
    prg[at:at + len(main)] = main
    prg[at + len(main):at + len(main) + len(body)] = body
    prg[at + len(main) + len(body):
        at + len(main) + len(body) + SLOTS * 4] = b'\xFF' * (SLOTS * 4)
    prg[last + 0x1FFC] = base & 0xFF
    prg[last + 0x1FFD] = base >> 8
    raw = open(ROM[game], 'rb').read()
    open(path, 'wb').write(raw[:16] + bytes(prg) + bytes(chrom))
    return last + (table - 0xE000), loop


def pokes(off, script):
    """`script` is a list of (picture, kind, number); kind is 0 for a tune and
    1 for a sound, and Power Blade 2 has one door and ignores it."""
    out = []
    for i, (at, kind, num) in enumerate(script):
        out += ['-rompoke', '%X=%X' % (off + i, at & 0xFF),
                '-rompoke', '%X=%X' % (off + SLOTS + i, (at >> 8) & 0xFF),
                '-rompoke', '%X=%X' % (off + SLOTS * 2 + i, kind),
                '-rompoke', '%X=%X' % (off + SLOTS * 3 + i, num)]
    return out


def tape(rom, off, loop, script, pictures, scratch, frames=None):
    """Run the stand and give back one list a picture: the writes the driver
    made on it, each (address, value), in order."""
    tr = os.path.join(scratch, 'tape.tr')
    cmd = [NESEMU, rom, '-frames', str(frames or (pictures // 8 + 8)),
           '-trace', tr, '-tracepc', 'FFFF-FFFF',
           '-sample', '%X=A' % loop, '-watch', '4000-4017']
    cmd += pokes(off, script)
    subprocess.run(cmd, capture_output=True, text=True, timeout=1200)
    out = []
    cur = None
    for line in open(tr):
        if line.startswith('SAMPLE'):
            if len(out) >= pictures:
                break
            cur = []
            out.append(cur)
        elif line.startswith('WATCH') and cur is not None:
            f = line.split(',')
            cur.append((int(f[3], 16), int(f[4], 16)))
    return out
