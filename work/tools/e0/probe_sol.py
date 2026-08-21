#!/usr/bin/env python3
"""E0 probe: give Tokkyuu Shirei Solbrain a second, pad-2 controlled player.

Method (documented in work/re/sol_two_players.md):
  * the whole player context is the contiguous block $05A2-$05CE plus the
    zero-page position $80-$83 plus the pad mirrors $04/$06;
  * bank 12 $9150 calls the player update $9159 exactly once per frame;
  * so: call it twice, exchanging that context with a shadow copy in unused
    RAM ($01A6-$01D8) in between, and exchanging $04/$06 with $05/$07 so the
    second pass reads controller 2.
  * new code lives in the 144 unused $FF bytes at bank 15 $FF50-$FFDF, which
    is the always-mapped fixed bank.
No original code is removed; the only overwritten byte range is $9150-$9152
(a JSR target) and the padding at $FF50.
"""
import sys

SRC = sys.argv[1] if len(sys.argv) > 1 else "Tokkyuu Shirei Solbrain (Japan).nes"
DST = sys.argv[2] if len(sys.argv) > 2 else "work/build/probe_sol.nes"
NUDGE = int(sys.argv[3]) if len(sys.argv) > 3 else 4      # P2 spawn offset, 16-px units

rom = bytearray(open(SRC,'rb').read())
HDR = 16
def off(bank, cpu):
    base = 0xC000 if bank==14 else (0xE000 if bank==15 else (0x8000 if bank%2==0 else 0xA000))
    return HDR + bank*0x2000 + (cpu-base)

SH   = 0x01A6      # shadow of $05A2-$05CE  (45 bytes -> $01A6-$01D2)
SH2  = 0x01D3      # shadow of $80-$83      (4 bytes  -> $01D3-$01D6)
SH3  = 0x01D7      # shadow of $35 (horizontal speed - the one player
                   # variable that lives outside the $05A2 block)
FLAG = 0x01D8      # "shadow initialised"

def w(v): return [v & 0xFF, v >> 8]

code = []
HOOK, INIT, SWAP = 0xFF50, 0xFF6A, 0xFF98
# ---- HOOK  $FF50 ----  replaces the single "JSR $9159" at bank12 $9150
code += [0x20]+w(0x9159)            # JSR $9159      player 1 update
code += [0xAD]+w(FLAG)              # LDA FLAG
code += [0xD0, 0x08]                # BNE ready
code += [0x20]+w(INIT)              # JSR INIT       (only snapshots once P1 is idle)
code += [0xAD]+w(FLAG)              # LDA FLAG
code += [0xF0, 0x09]                # BEQ done
code += [0x20]+w(SWAP)              # ready: JSR SWAP
code += [0x20]+w(0x9159)            # JSR $9159      player 2 update
code += [0x4C]+w(SWAP)              # JMP SWAP       (swap back; its RTS returns)
code += [0x60]                      # done: RTS
assert HOOK+len(code) == INIT, hex(HOOK+len(code))
# ---- INIT  $FF6A ----
code += [0xAD]+w(0x05A2)            # LDA $05A2
code += [0xD0, 0x28]                # BNE ret    -- wait until P1 is in ground state $00,
                                    #               otherwise P2 inherits a warp-in state
                                    #               it can never leave ($05AF stays non-zero)
code += [0xA2, 0x2C]                # LDX #$2C
code += [0xBD]+w(0x05A2)            # LDA $05A2,X
code += [0x9D]+w(SH)                # STA SH,X
code += [0xCA, 0x10, 0xF7]          # DEX / BPL
code += [0xA2, 0x03]                # LDX #$03
code += [0xB5, 0x80]                # LDA $80,X
code += [0x9D]+w(SH2)               # STA SH2,X
code += [0xCA, 0x10, 0xF8]          # DEX / BPL
code += [0x18, 0xA9, NUDGE]         # CLC / LDA #NUDGE
code += [0x6D]+w(SH2+1)             # ADC SH2+1        (P2 spawns NUDGE*16 px right of P1)
code += [0x8D]+w(SH2+1)             # STA SH2+1
code += [0xA5, 0x35]                # LDA $35
code += [0x8D]+w(SH3)               # STA SH3
code += [0xA9, 0x01, 0x8D]+w(FLAG)  # LDA #1 / STA FLAG
code += [0x60]                      # ret: RTS
assert HOOK+len(code) == SWAP, hex(HOOK+len(code))
# ---- SWAP  $FF93 ----
code += [0xA2, 0x2C]                # LDX #$2C
code += [0xBD]+w(0x05A2)            # LDA $05A2,X
code += [0xBC]+w(SH)                # LDY SH,X
code += [0x9D]+w(SH)                # STA SH,X
code += [0x98]                      # TYA
code += [0x9D]+w(0x05A2)            # STA $05A2,X
code += [0xCA, 0x10, 0xF0]          # DEX / BPL
code += [0xA2, 0x03]                # LDX #$03
code += [0xB5, 0x80]                # LDA $80,X
code += [0xBC]+w(SH2)               # LDY SH2,X
code += [0x9D]+w(SH2)               # STA SH2,X
code += [0x98]                      # TYA
code += [0x95, 0x80]                # STA $80,X
code += [0xCA, 0x10, 0xF2]          # DEX / BPL
code += [0xA2, 0x02]                # LDX #$02      swap pad mirrors $04/$06 <-> $05/$07
code += [0xB5, 0x04]                # LDA $04,X
code += [0xB4, 0x05]                # LDY $05,X
code += [0x95, 0x05]                # STA $05,X
code += [0x94, 0x04]                # STY $04,X
code += [0xCA, 0xCA, 0x10, 0xF4]    # DEX / DEX / BPL
code += [0xA5, 0x35]                # LDA $35       swap horizontal speed
code += [0xAC]+w(SH3)               # LDY SH3
code += [0x8D]+w(SH3)               # STA SH3
code += [0x84, 0x35]                # STY $35
code += [0x60]                      # RTS
end = 0xFF50 + len(code)
assert end <= 0xFFE0, hex(end)

o = off(15, 0xFF50)
assert all(b == 0xFF for b in rom[o:o+len(code)]), "target padding is not free"
rom[o:o+len(code)] = bytes(code)

p = off(12, 0x9150)
assert bytes(rom[p:p+3]) == bytes([0x20,0x59,0x91]), rom[p:p+3].hex()
rom[p:p+3] = bytes([0x20, 0x50, 0xFF])              # JSR $FF50

open(DST,'wb').write(bytes(rom))
print(f"wrote {DST}: {len(code)} bytes of new code at bank15 $FF50-${end-1:04X}, "
      f"hook at bank12 $9150")
