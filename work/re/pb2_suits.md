# Power Blade 2 — the Power Suit system (fully decoded)

Proof: `work/build/pb2_allsuits.nes` grants `$56 = $0F` at stage entry and all
five player states (no suit + 4 suits) can then be equipped from the pause menu
in stage 1; screenshots `work/build/shots/suit_proof_[0-4]_1790.png`.

## 1. How many suits

**Five player states: `$9A = 0..4`.** `$9A = 0` is Nova unsuited; `$9A = 1..4`
are the four Power Suits. The count is pinned by three independent tables that
all have exactly five / four entries:

| table | bank | contents | meaning |
|---|---|---|---|
| `$D619` | 14 | `$D623 $D62C $D635 $D647 $D63E` | 5 HUD-icon tile sets, indexed `$9A*2` |
| `$D2B9` | 14 | `00 01 02 04 08` | ownership mask per `$9A`, index 0 is "always owned" |
| `$D326` | 14 | `03 04 04 06` | energy drain rate per suit, indexed `$9A-1` |

Palette groups `$3D..$41` (5) are the matching sprite palettes, see §6.

## 2. RAM map

| addr | role |
|---|---|
| **`$9A`** | **current suit index, 0-4.** Everything else keys off this. |
| **`$56`** | **ownership bitmask.** bit0 = suit 1 … bit3 = suits 4. bits 4-7 unused. |
| **`$A0`** | **suit energy bar**, 0-`$10`. Drains while `$9A != 0`. HUD "ENERGY". |
| **`$9E`** | **spare suit-energy tanks**, 0-8. Auto-consumed when `$A0` hits 0. HUD "E nn". |
| `$85`/`$86` | 16-bit fractional drain accumulator for `$A0` (reloaded to `$0600`). |
| `$AF` | suit index remembered when the pause menu opens, to detect a change. |
| `$4D` | 1 = pause/suit menu is open. |
| `$45` | MMC3 R3 shadow = 1 KB CHR bank at PPU `$1400`; `$11` unsuited, `$12` suited. |
| `$27` | game state: 3 = playing, 5 = player-HP refill, 6 = suit-energy refill, **7 = suit transformation**. |
| `$9D` | spare player-HP tanks, 0-8. HUD "P nn". *Not* suit related (see §8). |
| `$9F` | lives. `$049A` = player HP, 0-`$10`. |
| `$0446` | suit-4 orbiter object slot flag (see §7). |

All of `$56`, `$9A`, `$A0`, `$9E` sit inside the `$48..$EF` zero-page wipe that
`$C9E1` / `$C9E5` (bank 14) run when a game starts, and nothing writes them
again until the player finds pickups. That wipe is why a fresh game has no
suits at all.

## 3. Where suits are granted (pickup code)

Bank 7, `$B4CD` is the collectible dispatcher. The item subtype is
`$049A,X & $0F`:

| subtype | handler | effect |
|---|---|---|
| 0 | `$B503` | refill player HP → `$2F = 4`, `$27 = 5` |
| 1 | `$B51B` | refill suit energy → `$30 = 4`, `$27 = 6` |
| 2 | `$B532` | `$9D` +1 (cap 8) |
| 3 | `$B547` | `$9E` +1 (cap 8) |
| **4** | **`$B58A`** | **suit capsule** |
| 5 | `$B55C` | `$A2` +1 (cap 1) |
| 6 | `$B569` | `$55` +1 (cap 3) |
| 7 | `$B57C` | `$99` +1 (cap 2) |

```
B58A  LDY $53            ; stage number
B58C  LDA $B5CD,Y        ; $B5CD = 01 02 04 08 10 20 40 80
B58F  EOR $56
B591  STA $56            ; suit for this stage is now owned
B593  INC $058C,X  /  STA $0416,X = $80  /  STA $0442,X = 0
B5A0  LDA #$1F  /  JMP $C81C     ; jingle
```

So **suit N is found in stage N-1**: stages 0,1,2,3 carry suits 1,2,3,4. Bits
4-7 of `$56` can never be set by a real pickup because no suit index maps to
them.

The capsule object refuses to spawn if you already own it — bank 10, `$8418`:

```
8418  LDY $53  /  LDA $BE36,Y  /  AND $56  /  BNE $8439   ; owned -> JMP $C810 (despawn)
```

(`$BE36` in bank 11 is a duplicate of the `01 02 04 08 …` table; `$BE22` uses
it against `$5B`, the *stage-cleared* bitmask, which is a separate variable.)

Persistence: bank 0 `$9A3F` packs `$56` into password digits `$0688`/`$068A`
(2 bits each), and `$9D38` / `$9D5F` unpack them back into `$56`. Four bits,
four suits — the password format independently confirms the count.

## 4. The suit-change UI

There is **no separate suit-select screen**. Suit changing is the pause menu.

**Open** — bank 14 `$D0A6`, called every frame from `$CDBB`:

```
$27 == 7                             -> refuse (already transforming)
$79 == 0 and $53 == 5 and $9C == 0   -> refuse (stage 5 intro)
$4E | $1E != 0                       -> refuse (cutscene / already halted)
START newly pressed ($48 & $10, PB2's reversed pad order):
    $4D = 1             ; menu open
    $AF = $9A           ; remember the suit we came in with
    sound $17
    JMP $D69C           ; set bit7 of $042C..$0441 -> freeze every object
```

**Cycle** — bank 14 `$D259`, called every frame from `$CDCB`:

```
$27 == 3            required (playing)
($A0 | $9E) != 0    required — no suit energy, no menu
$56 != 0            required — owns at least one suit
UP   ($48 & $08) -> $D276   next owned suit
DOWN ($48 & $04) -> $D2A0   previous owned suit
```

Both directions walk the ring `0..4` and accept index Y only when
`$56 & $D2B9[Y] != 0`; index 0 has mask `$00` and is reached by the
"nothing matched" fallthrough at `$D28A`, so unsuited is always available.
On landing on Y:

```
D28C  STY $9A
D28E  $45 = $11 if $9A == 0 else $12      ; swap the player CHR bank
D298  LDA #$30 / JSR $ECE8                ; blip
D29D  JMP $D5C1                           ; redraw the HUD icon
```

**Confirm** — back in `$D0A6`, pressing START again with `$4D != 0`:

* `$9A == $AF` → just close: `$4D = 0`, `JMP $D6AC` (clear the freeze bits).
* otherwise `$D0FE`: `JSR $D768` (reset object slots 1-5), sound `$1F`,
  **`$27 = 7`**, `$0443 = $58`, `$0509 = $80`, `$04C7 = $78` — the "CHANGE"
  transformation. State 7 is handled at bank 15 `$F02B`: it waits for `$CD == 0`,
  restores `$46`, clears the transformation object fields, `$4D = 0`, `$27 = 3`,
  `JMP $D6AC`.

**How the icon draws** — bank 14 `$D5C1`, data block `$D613..$D64F`:

```
$D613  26 F1  27 11  27 31          ; three PPU addresses, $26F1/$2711/$2731
$D619  23 D6  2C D6  35 D6  47 D6  3E D6   ; 5 tile-set pointers, index $9A*2
$D623  50 51 52 60 61 62 70 71 72   ; suit 0 (unsuited)
$D62C  53 54 55 63 64 65 73 74 75   ; suit 1
$D635  56 57 58 66 67 68 76 77 78   ; suit 2
$D63E  59 5A 5B 69 6A 6B 79 7A 7B   ; suit 4   <- note the table order
$D647  5C 5D 5E 6C 6D 6E 7C 7D 7E   ; suit 3
```

`$D5C1` reads `$D619[$9A*2]` into `$08/$09` and emits three 3-tile VRAM-queue
rows at the three addresses — a 3×3 portrait in the HUD, bottom centre-right.
It is called from `$D030` (respawn), `$D29D` (menu cycle), `$D320` (suit ran
dry) and `$D67E` (HUD build, `$1B` step 3).

## 5. Energy: how a suit runs out

Bank 14 `$D2BE`, called every frame from `$CEFD`:

```
$27 == 6, or $58 != 0, or $9A == 0, or ($A0|$9E) == 0   -> return
$85:$86 -= $D326[$9A-1]        ; 3, 4, 4, 6 per frame for suits 1..4
on borrow: $85:$86 = $0600 (1536) and $A0 -= 1     ; ~512 frames per bar unit
if $A0 hit 0:
    if $9E != 0: $9E -= 1, redraw ($D4B6), $30 = $10, $27 = 6   ; burn a spare tank
    else       : $9A = 0, redraw energy ($D4D9), $45 = $11,
                 $D768, $D5C1, JMP $D8E4                        ; suit falls off
```

An unreferenced variant of the same idea sits in the unlabelled block at `$D688`
(`if $9A && $A0 && ($1C & 7) == 0 then DEC $A0 / JMP $D4D9`) — 20 bytes with no
call site found, presumably an earlier, faster drain that was replaced.

`$85:$86` is big-endian (`$85` high). 1536 / rate frames per bar unit, so a full
`$10` bar lasts 8192 frames (~136 s) in suit 1 and 4096 (~68 s) in suit 4.

HUD writers: `$D4ED` → player HP bar at `$26E8`; `$D4D9` → suit energy bar at
`$2708`; `$D4A7`/`$D4B6`/`$D4C5` → the three 2-digit counters `$9D`/`$9E`/`$9F`
at `$2736`/`$2739`/`$273C`.

## 6. CHR and palette per suit

**CHR.** `$45` is the MMC3 R3 shadow (`$EC11`/`$EC5C` push `$42..$47` into
R0..R5, so `$45` is the 1 KB bank at PPU `$1400-$17FF`). It is `$11` unsuited
and `$12` for *every* suit — CHR banks `$11` and `$12` differ in 189 of 1024
bytes, i.e. the suited body is a different tile set, but all four suits share it.

**Palette.** Bank 14 `$D8E4` is the only thing that distinguishes the four
suits visually:

```
D8E4  LDA $9A / CLC / ADC #$3D / LDX #$05 / JSR $ED30 / JMP $ED48
```

`$ED30` trampolines into bank pair 0/1 `$801E` → `$8080`, the palette loader:
group index → `($82F5[g], $837D[g])` → 3 colours copied to `$03E0 + 5*4`,
i.e. **sprite palette 1**.

| `$9A` | group | ROM | colours | look (verified in the screenshots) |
|---|---|---|---|---|
| 0 | `$3D` | `$84BC` | `0F 18 37` | unsuited Nova, olive/cream |
| 1 | `$3E` | `$84BF` | `0F 25 35` | pink / magenta |
| 2 | `$3F` | `$84C2` | `0F 27 38` | orange / gold |
| 3 | `$40` | `$84C8` | `0F 22 31` | pale blue / white |
| 4 | `$41` | `$84C5` | `0F 2B 3B` | green |

`$D8E4` is called from `$C8CA`, `$CECF`, `$D122` and `$D323`.

## 7. Player-behaviour tables the suit index selects into

The player update is bank 8 `$8E15` (bank pair 8/9 is swapped in for it).
`$9A` is not used as one big jump-table index — it gates individual behaviours:

| site | bank | test | behaviour |
|---|---|---|---|
| `$8FFF` | 8 | `$9A != 0` | animation set: `Y=2, X=1` instead of `0,0` → `$902A`/`$902C`/`$902E` metasprite tables |
| `$9FBD` | 9 | `$9A == 1` | suit 1: holding A (`$4A` bit7) suppresses the normal action — the hover/charge |
| `$9220`, `$92A3`, `$9343` | 8 | `$9A == 2` | suit 2 attack variants (`$0534`/`$054A` velocity caps) |
| `$A1D5`, `$A358`, `$A3C7` | 9 | `$9A == 2` | suit 2 projectile / knockback handling |
| `$B01F`, `$B174`, `$B482`, `$B494` | 9 | `$9A == 2` | suit 2 movement physics: `$B203` velocity constants `$8060` / `$4060` / `$00C0` |
| `$9363` | 8 | `$9A == 3` | suit 3 special, gated on `$0610` |
| `$A945` | 9 | `$9A == 4` | suit 4 orbiter: if `$0446 == 0` call `$AA86` to spawn it, else run object slots 4 and 5 through `$C810` |
| `$A291` | 9 | `$9A == 0` | unsuited-only branch to `$A37F` |
| `$9499` | 8 | `$9A != 0` | suited landing sound `$3A` |
| `$B017` | 1 | `LDX $9A` | table lookup in the shared bank-0/1 helper |

Bank 14 `$D7CF` (`LDA $E5B1,Y / AND $56`, `$E5B1 = 01 02 04 08 …`) uses
ownership for the stage-`$9C` bonus branch, not for the suit itself.

## 8. Correction to an earlier hypothesis

`$EE5D` (bank 15, the SELECT handler) is **not** the suit system. It requires
`$9D != 0` and `$049A != $10`, then `DEC $9D` / `$2F = $10` / `$27 = 5` /
`JSR $D4A7`: it spends one **player-HP** tank to refill the PLAYER bar. Its
`($96 | $95) != 0` guard is simply "score is non-zero", `$95`/`$96` being the
BCD score drawn at `$26C3`/`$26C5` by `$D489`. Suits are on START, not SELECT.
