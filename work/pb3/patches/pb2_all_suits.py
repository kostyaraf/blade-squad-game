"""Give Power Blade 2 every Power Suit from the first frame of stage 1.

PB2's suit system (see work/re/pb2_suits.md for the full map):

    $9A  current suit index, 0 = no suit, 1-4 = the four Power Suits
    $56  ownership bitmask, bit0..bit3 = suits 1..4
    $A0  suit energy bar (0-$10), drains while $9A != 0
    $9E  spare suit-energy tanks (0-8), auto-consumed when $A0 hits 0

The in-game pause menu at $D259 (bank 14) is the suit selector.  It refuses to
open unless

    $27 == 3          (playing)
    ($A0 | $9E) != 0  (there is suit energy to burn)
    $56 != 0          (at least one suit is owned)

and while it is open UP/DOWN walk the ring 0..4, skipping every index whose
$D2B9[i] mask is absent from $56.  So "all suits from the start" needs three
variables set, not one: ownership *and* fuel.

All three are cleared by the zero-page wipe at $C9E1/$C9E5 that runs when a game
starts, and nothing writes them again until the player finds the pickups, so the
grant has to happen after that wipe.  The hook is the last instruction of the
stage-entry state machine in bank 15:

    EFD2  INC $27          ; 2 -> 3, the stage is now live
    EFD4  JMP $D8F1        ; load the weapon-power table, then RTS

That `JMP $D8F1` runs exactly once per stage entry, after the zero-page wipe and
before the first gameplay frame.  Redirect it into the 20 free bytes at the tail
of bank 15 ($FFE0-$FFF3, zero padding between the last $FF-record table and the
NMI vector), grant the suits there, then call the original target and repaint the
two HUD widgets whose values just changed -- the stage-intro HUD build ($1B step
2, $D672) has already run by this point, so without the repaint the bar and the
counter would show 0 until something else happened to redraw them.

The whole thing is 20 bytes and fits the slack exactly:

    FFE0  A9 10     LDA #$10
    FFE2  85 A0     STA $A0        full suit-energy bar
    FFE4  4A        LSR A          -> $08, the HUD cap $B547 enforces
    FFE5  85 9E     STA $9E        full spare energy tanks
    FFE7  A9 0F     LDA #$0F
    FFE9  85 56     STA $56        suits 1-4 owned
    FFEB  20 F1 D8  JSR $D8F1      the tail this hook replaced
    FFEE  20 B6 D4  JSR $D4B6      repaint the spare-tank counter
    FFF1  4C D9 D4  JMP $D4D9      repaint the suit-energy bar, then RTS

Nothing else changes, and nothing else needs to: the drain in $D2BE, the pickup
handler at bank 7 $B58A, the password encoder at bank 0 $9A3F and the $9C bonus
check at $D7CF all keep reading the same $56 they always did -- it is simply
already full.  The one visible side effect is that the suit capsule object no
longer spawns (bank 10 $8418 despawns it when `$BE36[$53] & $56` is set), which
is the correct behaviour for a suit you already own; it carries no progression
flag ($5B, the stage-cleared mask, is set elsewhere at bank 11 $BE22).

Because the hook is stage entry rather than new-game init, the grant is also
re-applied on every stage and after every death, so the suits can never be lost.
"""
NAME = "pb2_all_suits"
GAME = "pb2"

BANK = 15

HOOK      = 0xEFD4 - 0xE000          # "JMP $D8F1" at the end of stage entry
HOOK_OLD  = b'\x4C\xF1\xD8'
NEW       = 0xFFE0 - 0xE000          # 20 free bytes before the vectors

SUITS_OWNED  = 0x0F                  # bits 0-3 -> suits 1,2,3,4
SUIT_ENERGY  = 0x10                  # full bar, same value a type-1 pickup gives
SPARE_TANKS  = 0x08                  # HUD maximum ($B547 cap); derived as $10 >> 1

GRANT = bytes([
    0xA9, SUIT_ENERGY,   # LDA #$10
    0x85, 0xA0,          # STA $A0    full suit-energy bar
    0x4A,                # LSR A      -> #$08
    0x85, 0x9E,          # STA $9E    full spare energy tanks
    0xA9, SUITS_OWNED,   # LDA #$0F
    0x85, 0x56,          # STA $56    every suit owned
    0x20, 0xF1, 0xD8,    # JSR $D8F1  the tail this hook replaced
    0x20, 0xB6, 0xD4,    # JSR $D4B6  repaint the spare-tank counter
    0x4C, 0xD9, 0xD4,    # JMP $D4D9  repaint the suit-energy bar, then RTS
])


def apply(ctx):
    assert ctx.get(BANK, HOOK, 3) == HOOK_OLD, \
        "PB2 stage-entry tail is not the JMP $D8F1 it was expected to be"
    assert ctx.get(BANK, NEW, len(GRANT)) == b'\x00' * len(GRANT), \
        "PB2 bank 15 tail slack is not free"

    ctx.put(BANK, NEW, GRANT)
    ctx.put(BANK, HOOK, bytes([0x4C, NEW & 0xFF, 0xE0 + (NEW >> 8)]))
