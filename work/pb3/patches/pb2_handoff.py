"""Let the PB3 hand-off contract survive Power Blade 2's reset.

PB2's reset clears all eight pages of RAM with one X = 0..255 loop at $E611:

    E611  LDX #$00
    E613  STA $00,X
    E615  STA $0100,X      <- this one
    E618  STA $0200,X
    ...
    E62A  INX
    E62B  BNE $E613

Changing the base of the page-1 store from $0100 to $0120 makes that one
instruction clear $0120-$021F instead of $0100-$01FF.  The $0200-$021F tail is
already cleared by the STA $0200,X on the next line, so the only bytes that
stop being zeroed are $0100-$011F.

That 32-byte window is the PB3 reserved area for Power Blade 2:

    $0100-$0103   the hand-off contract (magic, game, stage, players)
    $0104-$011F   28 bytes of RAM the shell can preload, e.g. a bank
                  trampoline that stays callable no matter what is mapped

Nothing in page 1 needs reset to zero it.  The only PB2 variables that live
there are $0110-$0113 (frame counters, incremented not read-before-write) and
$0116-$0118 / $011F, which the player update writes at the top of every frame
before anything reads them.

Verified safe: 3000 frames of PB2 gameplay produce zero writes to $0100-$0107
outside the reset clear itself, and the stack never goes below SP = $DE
(i.e. $01DE), 218 bytes clear of the contract.
"""
NAME = "pb2_handoff"
GAME = "pb2"

BANK   = 15
RESET_STA_P1_OPERAND = 0xE616 - 0xE000      # low byte of "STA $0100,X"
PRESERVE_BASE        = 0x20                 # -> "STA $0120,X"

def apply(ctx):
    # Make sure we are patching the instruction we think we are.
    assert ctx.get(BANK, RESET_STA_P1_OPERAND - 1, 3) == b'\x9D\x00\x01', \
        "PB2 reset page-1 clear is not where it was expected"
    ctx.put(BANK, RESET_STA_P1_OPERAND, bytes([PRESERVE_BASE]))
