# Solbrain sub-weapon ("satellite") specification

Target ROM: `Tokkyuu Shirei Solbrain (Japan).nes` — MMC3, 128 KB PRG, 128 KB CHR.
Vectors NMI `$FACF`, RESET `$F8F8`, IRQ `$C2E0`.

Everything below was derived from the ROM itself and verified in a headless emulator
(`work/tools/nesemu`). Where something could not be pinned down it says so explicitly
instead of guessing.

This document is written so the weapons can be re-implemented inside a *different*
engine. It therefore states the engine-side contracts (units, arrays, timings) before
the per-weapon data.

---

## 0. Units and conventions

* **Position is 12.4 fixed point.** A 16-bit coordinate holds `pixels * 16`.
  Verified: player at `$81:$80 = $1800`, camera at `$31:$30 = $1020`,
  `($1800-$1020)/16 = 126` = the player's on-screen X in pixels.
* **Velocity is a signed 8-bit value in the same 1/16-pixel units per frame.**
  So `$40` = +4.00 px/frame, `$33` = +3.19 px/frame, `$F0` = -1.00 px/frame.
* +X is right, +Y is **down**. The player/satellite origin is at the sprite's feet/centre.
* Angles are 6-bit (`0..$3F`, 64 steps = one turn) for the satellite orbit, and
  8-bit (`0..$FF`, 256 steps) for the projectile polar routine at `$8FF6`.
* "frame" = one NMI = 1/60 s.

## 1. Object model (verified, not assumed)

Solbrain uses **two** independent object pools.

### 1.1 Main pool — 16 slots, column-major, base + slot index

| array base | meaning |
|---|---|
| `$0600,X` | object type / active flag (0 = free). bit7 and bit6 are flags, bits0-5 = type |
| `$0610,X` | generic state byte (for the satellite: **orbit angle**, 0..$3F) |
| `$0620,X` .. `$0640,X` | per-behaviour scratch |
| `$0650,X` | **behaviour ID** — index into the jump table at `$A594` (bank 13) |
| `$0660,X` / `$0670,X` | current metasprite ID, lo / hi |
| `$0680,X` | facing (bit7 set = left) |
| `$0690,X` | per-behaviour scratch |
| `$06A0,X` | animation ID, channel A ("action") |
| `$06B0,X` | animation ID, channel B ("pose") |
| `$06C0,X` | frames left on the current animation frame |
| `$06D0,X` | index of the current animation frame |
| `$06E0,X` | invulnerability / hit timer |
| `$06F0,X` | **hit points** |
| `$00A0,X` / `$00B0,X` | X position lo / hi (12.4) |
| `$00C0,X` / `$00D0,X` | Y position lo / hi (12.4) |

Slot allocation is fixed:

| slot | owner |
|---|---|
| `0..$0B` (0-11) | enemies and enemy shots. Updated by the loop at `$CE1D` (`LDX #$0B`) |
| `$0C` (12) | **the satellite** (the sub-weapon unit) |
| `$0D` (13) | secondary player-weapon hitbox (unused by the 8 satellites; used by other code) |
| `$0E` (14) | player-weapon hitbox — used by weapon 7's slash |
| `$0F` (15) | the player's melee punch hitbox |

The player himself is a standalone object in zero page: `$80/$81` = X lo/hi,
`$82/$83` = Y lo/hi. Camera: `$30/$31` = X lo/hi, `$32/$33` = Y lo/hi.

### 1.2 Projectile pool — separate array at `$0700`

| array base | meaning |
|---|---|
| `$0700,X` | projectile type. **0 = free**; bit7 clear = spawn/impact state; bit7 set = flying |
| `$0710,X` / `$0720,X` | X position lo / hi (12.4) |
| `$0730,X` / `$0740,X` | Y position lo / hi (12.4) |
| `$0750,X` | X velocity (signed, 1/16 px/frame) — several handlers reuse it as a countdown |
| `$0760,X` | Y velocity (signed, 1/16 px/frame) |
| `$0770,X` | **penetration budget** (see §4) |

The per-frame update is `sub_B168` (bank 13, called from `$9153`), which walks
**X = 7 down to 0 — only 8 live slots**. Dispatch inside `sub_B18D`:

```
A = $0700,X
if A == 0            -> nothing
if A & $80           -> JMP (jumptable $B1A6 + 2*(A & $7F))     ; flying
else                 -> JMP (jumptable $B1E1 + 2*A)             ; spawning / dying
```

`$070C`, `$070D`, `$070E` are **not** projectile slots — they are the blink timers for
the three letter boxes in the HUD.

> **Quirk worth reproducing or fixing:** the spawn routine's per-type "start searching
> here" table (`$B152`) contains values up to `$0A`, i.e. it can allocate slots
> `$0708`-`$070A`, which `sub_B168` never steps. Objects written there are dead: they
> are never moved, never drawn, never freed, and they block the allocator until the
> next satellite is created (`$92E5` clears `$0700`-`$070A`). In practice each of
> weapons 3 and 5 wastes its first three emissions this way.

---

## 2. How a weapon is selected in-game

Solbrain uses the collect-three-Greek-letters scheme.

* Two pickup items exist: **α (alpha)** and **β (beta)**.
* `$05C4` = the three collected letters, **2 bits per slot**, 3 slots:
  bits 0-1 = slot 0 (first collected), bits 2-3 = slot 1, bits 4-5 = slot 2.
  A slot holds `0` = empty, `1` = α, `2` = β.
* Pickup code (PRG bank 8):
  * `$82B5` — α picked up: finds the lowest empty 2-bit slot and ORs in `1`
    (slot0→`$01`, slot1→`$04`, slot2→`$10`). If all three are full the item is ignored.
  * `$82F3` — β picked up: same, ORs in `2` (`$02` / `$08` / `$20`).
  * Both play sound `$10` and set the HUD blink timer `$070C+n = $20`.
* The HUD draws the three boxes at screen X = `$60, $78, $90` (96, 120, 144), Y = 16,
  from `$9264`-`$92B4` (bank 12). Per-letter tiles come from
  `$9331 = {$21,$23,$27}` (upper/left half) and `$9334 = {$21,$25,$29}` (lower/right
  half), indexed by the letter value 0/1/2; the empty box is tile `$21` drawn twice,
  attribute `$01` and `$41` (H-flipped).
* Each frame `$923B` compares `$05C4` against the 8-entry table at **`$9337`**.
  On a match it sets `$05C3 = $80`.
* `$92B5` decrements `$05C3` every frame. When it reaches exactly `$30`
  (**80 frames after the match**) the satellite is created at `$92CD`;
  the "COMPLETE" banner runs for the remaining `$30` = 48 frames.

### 2.1 The eight combinations

`$9337` (combo byte) → `$933F` (weapon ID), both indexed by the *weapon index* 0..7:

| index | `$05C4` | letters (slot0,1,2) | weapon ID written to `$060C` | behaviour handler (`$A594[index]`) |
|---|---|---|---|---|
| 0 | `$15` | α α α | 1 | `$A94D` |
| 1 | `$2A` | β β β | 2 | `$ACD4` |
| 2 | `$25` | α α β | 3 | `$A982` |
| 3 | `$29` | α β β | 4 | `$AA70` |
| 4 | `$1A` | β β α | 5 | `$AAAC` |
| 5 | `$16` | β α α | 6 | `$AC11` |
| 6 | `$19` | α β α | 7 | `$AC4A` |
| 7 | `$26` | β α β | 8 | `$A8DB` |

### 2.2 RAM variables that hold the selection

| address | meaning |
|---|---|
| **`$060C`** | **the currently selected weapon: 0 = none, 1..8 = weapon ID, `$FF` = dying** |
| **`$065C`** | the weapon *index* 0..7 — this is what actually dispatches the behaviour (`$0650,X` for X=`$0C`) |
| `$05C4` | the three collected letters (see above) |
| `$05C3` | satellite-creation countdown (`$80` → 0; spawn happens at `$30`) |
| `$05C2` | player invulnerability / cutscene lock (non-zero suppresses weapon logic) |
| `$061C` | satellite orbit angle, `$2B` if the player faces right, `$35` if left (set at `$9314`) |
| `$06FC` | satellite hit points, `$10` (16) at creation |

Creation code, `$9310`-`$932D` (bank 12):

```
$9310  LDA #$1E   STA $F1          ; sound
$9314  LDA $05B2  ASL A            ; player facing
$9318  LDA #$2B / #$35             ; start orbit angle right / left
$931E  STA $061C
$9321  LDA $933F,X  STX $065C  STA $060C
$932A  JSR $9347                   ; $06FC = $10, $06EC = $FF, clear satellite fields
```

### 2.3 Collecting the same combination twice → super mode

`$92EB`: if the newly completed combo equals the weapon you already carry, the satellite
is **not** re-created. Instead: `$06FC = $10`, sound `$1D`, `$05A2 = $0D` (player state
"super"), `$05AB = $7F`, `$05C4 = 0`.
State `$0D` is handled at `$97D4`: `$05AB` drops by 4 per frame, so the burst lasts
`$7F/4 ≈ 32 frames`, drawing an expanding flash around the player; then `$05C2 = $7F`
gives 127 frames of invulnerability and the state returns to 0.
*Verified in the emulator by completing combo `$15` twice.*

---

## 3. The satellite unit itself (common to all 8 weapons)

* Lives in object slot `$0C`. Type `$060C`, behaviour `$065C`.
* **Position**: `$AE25` sets the satellite's X/Y to the *player's* X/Y each frame, plus a
  vertical bob of 0..`$20` (0..2 px) taken from the 16-entry table at `$AE5F`
  (`00 08 10 18 18 20 20 20 20 20 20 20 18 18 10 08`) indexed by `($0C>>1)&$0F`.
  The visible offset from the player comes from the orbit angle `$0610,$0C` applied at
  draw time.
* **Aiming**: `$AD45` steers the orbit angle. Holding LEFT/RIGHT (`$06 & $03`) rotates
  the satellite around the player; the reachable arc is clamped by the table at
  `$ADEF = {$1B,$25,$1B,$25,$1B,$25,$BD,$E0}`. With no direction held the angle drifts
  back toward the resting angle every other frame (`$ADA5`, gated on `$0C` bit 0).
* **Facing**: `$0680,$0C` is copied from the player's facing `$05B2` every frame
  (`$AE50`). bit7 set = facing left.
* **Durability**: `$06FC` = 16 at creation. Contact with an enemy (bank 8, `$844E`)
  subtracts the enemy's power nibble (`$60 & $0F`, or 1 if that nibble is ≥ 8).
  At 0 the satellite is destroyed (`$0600,$0C = $FF`, `$0620,$0C = $20`).
* **Contact damage**: the satellite body itself damages enemies it touches
  (`$841D`, gated on `$06EC ≥ $0C`). Damage = the metasprite damage table (§4);
  measured as **1** for all eight satellite idle poses.
* **Lifetime**: unlimited. Verified by running 1700 frames of gameplay with weapon 1
  and no input — `$060C` was still 1 and `$06FC` still `$10`.
  The satellite is lost only by: player death (`$93B3`: `$060C = $FF`, `$062C = $20`),
  durability reaching 0, the super-mode merge (§2.3), or the `A`-held action at `$9CF5`.
* **Fire button**: **B**. Controller bits live in `$04` (pad 1 newly pressed) and
  `$06` (pad 1 held); bit7 = A, bit6 = B, bit5 = Select, bit4 = Start,
  bit3 = Up, bit2 = Down, bit1 = Left, bit0 = Right (poll routine `$C882`/`$C8A2`).
  Weapon handlers test `BIT $04 / BVS` (newly pressed) or `LDA $06 / AND #$40` (held).

### 3.1 Satellite animations

Animation scripts are 3 bytes per frame: `[duration, metasprite_lo, metasprite_hi]`,
terminated by a `00` duration. Pointer chain: `$9A` (0..3) selects one of four
animation-list pointers at `$801C` (bank 12); the satellite uses `$9A = 1` →
list at **`$BDB9` (bank 13)**; `$9B` = animation ID indexes that list.

| weapon | idle anim (`$06BC`) | idle metasprite | "in state 3" anim | firing anim |
|---|---|---|---|---|
| 1 | `$00` | `$02BC` | `$00` | `$01` (`$02BC`/`$02C0`/`$02BE`, 3 frames each) |
| 2 | `$04` | `$0134` | `$23` | `$05` / `$06` |
| 3 | `$07` | `$013C` | `$08` (`$013E`) | — (beam is a separate object) |
| 4 | `$09` | `$0140` | `$0A` (`$0142`) | — |
| 5 | `$0B` | `$0144` | `$0C` (`$0146`) | — |
| 6 | `$02` | `$0130` | `$03` (`$0132`) | — |
| 7 | `$11` | `$0150` | — | `$12` (`$0152`,`$0154`,`$0156`) / `$13` |
| 8 | `$0D` | `$02C2` | `$0E` (`$02C4`) | `$24` / `$25` |

("state 3" = `$05A2 == 3`, the player's crouch/ground-action state; several weapons
switch to an alternate pose and an alternate projectile in it.)

---

## 4. Damage and collision model

There are two different paths, and they behave differently.

### 4.1 Objects in the main pool (satellite `$0C`, slot `$0E`, punch `$0F`)

Tested by `$84CD` (bank 8). The object is treated as a **point**; the enemy's box
(`$61/$62` X, `$63/$64` Y, `$65/$66` width, `$67/$68` height, all 12.4) is first
**expanded by 8 px on every side** (`$84B0`: subtract `$0080` from the origin,
add `$0100` to the size).

Damage is a property of the object's **current metasprite**:

```
damage = PRG_bank_8 [ $8A19 + 2 * metasprite_id ]
```

Measured values:

| object | metasprite | damage |
|---|---|---|
| player punch | `$017C` | 1 (doubled to 2 while the `$05C8` power-up is active, `$858E`) |
| weapon 7 slash (slot `$0E`) | `$0176` | **2** |
| every satellite idle pose | see §3.1 | 1 |

Enemy HP is `$06F0,X`; `$85A7` subtracts the damage. `$06E0,X` must be ≥ 8 or the hit
is ignored (per-enemy hit cooldown).

### 4.2 Projectiles in the `$0700` pool

Tested by `$8726` (bank 8). The projectile is a **point**, tested against the enemy's
raw box (no 8-px expansion). It has **no width or height of its own** — the visual size
of the sprite is irrelevant to collision.

* **Damage is a flat 1 per hit for every projectile type** (`$87CA`: `LDA $06F0,X / SBC #$01`).
  Weapons differ in rate of fire and penetration, not in per-hit damage.
* **Penetration**: `$0770,X` is loaded at spawn from `$AFDC[type]`. On a hit the enemy's
  toughness nibble (`$60 & $0F`) is subtracted from it (`$8738`). If it would go to 0 or
  below, the projectile's bit7 is cleared (it enters its impact state) and `$0750,X = 0`.
  Otherwise the projectile survives and keeps flying — that is how piercing works.
* `$06E0,X ≥ 9` is required for the enemy to accept the hit.
* Which projectile slots are tested each frame is throttled per weapon by the table at
  `$8759` (bank 8), indexed by weapon index:
  `{0,0,2,0,2,1,1,0}` — 0 = all 8 slots every frame, 1 = alternating groups of 4,
  2 = alternating halves. Purely a CPU-budget measure.

---

## 5. Projectile spawn routine — `sub_AEBD` (bank 13)

Called with `A` = projectile type (bit 7 set = "flying"). Returns `Y` = the slot used.

1. `$98 = A & $7F`. Search for a free `$0700,Y` starting at `Y = $B152[$98]` and
   walking **down** to 0. If none is free, return.
2. `$0770,Y = $AFDC[$98]` (penetration).
3. Velocity: `$0750,Y = $AF84[$98]`, `$0760,Y = $AFB0[$98]`
   — but if `$05CB` has bit 7 set (the inverted / ceiling-walk mode) it uses the
   mirrored tables `$AF9A` / `$AFC6` instead.
4. Spawn offset relative to the **satellite** (`$00A0/$00B0/$00C0/$00D0` at X = `$0C`):
   * if the player state `$05A2 == 3`: X offset from `$AFF2`/`$B01E`, Y from `$B04A`/`$B076`
     (mirrored variants `$B008`/`$B034`, `$B060`/`$B08C`)
   * otherwise: X offset from `$B0A2`/`$B0CE`, Y from `$B0FA`/`$B126`
     (mirrored `$B0B8`/`$B0E4`, `$B110`/`$B13C`)
   * if the owner's facing `$0680,X` is negative, the X offset is negated.
5. `$0700,Y = A`, position = owner position + offset.

**Note the routine does *not* mirror the velocity for a left-facing player.**
Each weapon handler does that itself, right after the call, e.g.

```
$A8FD  LDA $0680,X   ; satellite facing
$A900  BPL +
$A902  SEC / LDA #$00 / SBC $0750,Y / STA $0750,Y     ; negate X velocity
```

Weapons 2, 4 and 8 negate `$0750` (X velocity); weapon 6 negates `$0760` (Y velocity);
weapons 1, 3 and 5 do not mirror at all because their motion is derived from the
satellite's orbit angle.

### 5.1 The per-type parameter tables (bank 13, 22 entries each, index = type & `$7F`)

```
type:        00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 13 14 15
$AF84 XVEL   33 40 43 77 40 00 40 40 74 48 53 30 00 00 00 00 00 00 00 50 50 33
$AF9A XVEL'  33 40 43 78 40 00 40 40 7C 48 53 30 00 00 00 00 00 00 00 50 50 33
$AFB0 YVEL   02 40 43 02 30 10 40 40 02 28 30 50 00 00 00 00 00 00 00 0D 0D 02
$AFC6 YVEL'  02 40 BC 02 C0 10 40 40 02 D8 CF 50 00 00 00 00 00 00 00 0D 0D 02
$AFDC PEN    01 01 01 7F 01 01 01 01 7F 01 01 01 01 01 01 01 01 01 01 10 10 01
$B0A2 XOFFlo 60 30 80 80 00 00 00 00 80 00 50 01 00 00 00 00 00 00 00 00 00 60
$B0CE XOFFhi 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
$B0FA YOFFlo 80 00 80 80 00 00 00 00 80 00 90 00 00 00 00 00 00 00 00 00 00 80
$B126 YOFFhi 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00 00 00 00 00 00 00 00
$B152 SLOT   00 0A 01 0A 00 03 0A 0A 0A 00 01 01 00 00 00 00 00 00 00 02 02 00
```

(`XVEL'`/`YVEL'` are the inverted-gravity variants; the "state 3" offset tables
`$AFF2`/`$B01E`/`$B04A`/`$B076` are listed in §6 per weapon where they differ.)

---

## 6. The eight weapons

Common to all of them:

* **Fire button = B.** No weapon has ammo, no weapon consumes energy.
  `$06FC` (satellite HP) is *not* touched by firing — verified by watching it across
  hundreds of shots. The only limits are the cooldowns and the slot counts below.
* **Per-hit damage of every `$0700` projectile is 1.** Weapons differ by fire rate,
  number of simultaneous shots, and penetration (`$0770`).
* **No gravity and no acceleration anywhere in the player-projectile system.**
  Verified by reading every handler: nothing ever adds a constant to `$0750`/`$0760`.
  The only speed changes are discrete table lookups, a per-frame re-roll (weapon 6
  phase 1), or sign flips on a bounce. Accel = 0 px/frame² for all types.
* **Universal off-screen kill: `$B595`.** Subtracts the camera; if either high-byte
  difference is ≥ `$10` the projectile is destroyed. Because positions are px×16, the
  high byte counts 16-px cells, so the live area is exactly `[camera, camera+256)` in
  both axes — a shot dies the frame it leaves the screen.
* **`$05CB` is the *vertical* orientation** (bit7 = gravity flipped; normal value `$20`),
  **not** the facing. The horizontal facing is `$05B2` (`$40` right, `$80` left, set at
  `$AD5C`), and that is what is copied to `$0680,X`. This is why the `$AF84`/`$AF9A`
  X-velocity tables are byte-identical while `$AFB0`/`$AFC6` differ only in the Y sign.
* **Player state `$05A2 == 3` = crouching** (verified: hold Down → `$05A2 = 3`;
  jump → `$05A2 = 1`). Several weapons fire a different projectile type when crouching.

Screenshots: `work/build/shots/sol_weapon_<n>.png`.
CHR: see `work/re/sol_weapon_tiles.md` / `.bin`.
Sprite palettes on Stage 1 (identical for all eight, colour 0 is transparent):
**palette 1 = `$0F,$0F,$21,$30`**, **palette 2 = `$0F,$06,$27,$38`**.
Satellite OAM attribute = `$05` facing right / `$45` facing left (palette 1, H-flip);
weapon 7's flame uses `$06` / `$46` (palette 2). The behind-background priority bit is
never set on any weapon sprite. Sprites are **8x16** (PPUCTRL `$A9`).

---

### Weapon 1 — "Orbit whip" (index 0, ID 1, combo `$15` = α α α)

| field | value |
|---|---|
| behaviour handler | `$A94D` (bank 13) |
| projectile type | `$95` → `$15`, handler `$B6E1` |
| slot used | projectile slot 0 only — **max 1 alive** |
| fire rate | on B **edge**; one at a time, so effectively one every 51+ frames (measured 60) |
| motion | not a free projectile: the position is **overwritten with the player's position every frame**, plus a rotating offset |
| angle | `$069C` starts `$10` (right) / `$30` (left), steps by `$064C` = ±4 per frame → **one revolution every 16 frames** |
| radius | polar table row `$9140`, max `$F0`, then doubled (`ASL`) → up to 480 units = **30 px reach** |
| velocity / accel | n/a (kinematic), 0 |
| lifetime | `$0750` = `$33` = **exactly 51 frames** (verified) |
| penetration `$0770` | `$01` |
| damage | 1 per hit |
| terrain | **none** — passes through everything |
| facing | yes: `$0680` picks the start angle and the rotation direction |
| sound | `$34` every 8 frames |
| satellite idle metasprite | `$02BC`, anim `$00`; firing anim `$01` cycles `$02BC`/`$02C0`/`$02BE`, 3 frames each |
| CHR | satellite bank 88 tiles `$40-$47`; projectile bank 88 tiles `$54-$57` (bin `0x0000`, `0x0080`) |
| palette | 1 and 2 alternating |

Because the X component is copied into **both** the X and the Y accumulator, the tip
travels along a 45° line whose length oscillates sinusoidally — that is the whip/arc look.

---

### Weapon 2 — "Grenade shot" (index 1, ID 2, combo `$2A` = β β β)

| field | value |
|---|---|
| behaviour handler | `$ACD4` |
| projectile type | **standing `$89` → `$09`**, **crouching `$84` → `$04`** (selected at `$ACEA` by `LDA $06A0,X; CMP #$06`), handler `$B3F1` for both |
| slot used | slot 0; `$AD0B` refuses to start the fire animation unless `$0700` is 0 → **max 1 alive** |
| fire rate | B edge; ~9 frames from press to spawn (animation-gated); blocked while a shot lives. Measured cadence 60 frames |
| velocity (standing, `$09`) | X `$48` = **+4.50 px/f**, Y `$28` = **+2.50 px/f** (flipped-gravity `$D8` = −2.50) |
| velocity (crouching, `$04`) | X `$40` = **+4.00 px/f**, Y `$30` = **+3.00 px/f** (flipped `$C0` = −4.00) |
| accel | 0 |
| lifetime | until it hits terrain or leaves the screen (~20 frames measured) |
| penetration `$0770` | `$01` |
| damage | 1 |
| terrain | **the only projectile that explodes on walls.** `$B3F1` tests the *current* position each frame, so it detonates one frame after entering a wall: it becomes an explosion object in slot `$0D` (`$B294`) and plays sound `$1B` |
| facing | yes — `$0680 < 0` negates `$0750` |
| satellite | idle anim `$04` (metasprite `$0134`), crouch anim `$23`; firing anims `$05` (standing) / `$06` (crouching) |
| CHR | satellite bank 89 `$40-$43`; bullet bank 89 `$54-$55`; 3-stage impact blast bank 89 `$56-$5F` (bin `0x00C0`, `0x0100`, `0x0120`) |
| palette | bullet 1, blast 2 |

---

### Weapon 3 — "Burst rifle" (index 2, ID 3, combo `$25` = α α β)

| field | value |
|---|---|
| behaviour handler | `$A982` |
| projectile type | **standing `$88` → `$08`**, **crouching `$83` → `$03`**, handler `$B42C` |
| slots used | 7 down to 0 — **max 8 alive** |
| fire rate | hold B → **8-shot burst, one every 2 frames**, then a 64-frame `$069D` cooldown. Full cycle **80-82 frames**. Verified: spawns at frames 1601, 1603 … 1615 |
| velocity | `$0750` is a **packed pair of signed nibbles**: high nibble = X px/frame, low nibble = Y px/frame (`$B449` unpacks with `AND #$F0` and `ASL`×4). Standing `$74` = **+7 px/f X, +4 px/f Y**; facing left `$94` = **−7, +4**. Crouching `$77` = **+7, +7**; flipped `$78` = +7, −8 |
| extra motion | `$B32C` adds `$062C/$063C` (X) and `$064C/$069C` (Y) every frame — these hold **the player's movement delta for that frame**, so the burst drifts with you instead of staying world-fixed |
| accel | 0 |
| lifetime | `$0760` = `$02` gives a 1-frame hover, then it never expires by time — it dies only off-screen (~16 frames measured) |
| penetration `$0770` | **`$7F` — effectively unlimited piercing.** This is the strongest weapon against tough enemies |
| damage | 1 per enemy per hit; pierces through a whole row |
| terrain | none |
| facing | `$AA5F` mirrors the X nibble with `EOR #$F0` then `+$10` |
| idle sparkle | when B is *not* held and the cooldown is clear, `$AA1B`/`$AA20` spawns a type `$88` and immediately clears bit 7, routing it to `$B20D` = one sprite frame then gone. That is a muzzle sparkle, not a shot |
| satellite | idle anim `$07` (metasprite `$013C`), crouch anim `$08` (`$013E`) |
| CHR | satellite bank 90 `$40-$43`; muzzle flash bank 90 `$56-$57`; shot bank 90 `$58-$5B` (bin `0x01C0`, `0x0200`, `0x0220`) |
| palette | 1. The shot flips with facing (`$01` → `$41`) |

---

### Weapon 4 — "Bouncer" (index 3, ID 4, combo `$29` = α β β)

| field | value |
|---|---|
| behaviour handler | `$AA70` |
| projectile type | **standing `$8A` → `$0A`**, **crouching `$82` → `$02`**, handler `$B36B` |
| slots used | 1 and 0 — **max 2 alive** |
| fire rate | B **edge** only; in practice limited by the 2-slot cap (measured ≤ 1 per 30 frames) |
| velocity (standing `$0A`) | X `$53` = **+5.19 px/f**, Y `$30` = **+3.00 px/f** (flipped `$CF` = −3.06) |
| velocity (crouching `$02`) | X `$43` = **+4.19 px/f**, Y `$43` = **+4.19 px/f** (flipped `$BC` = −4.25) |
| accel / gravity | **0 — there is no gravity.** It travels in a straight line until it hits something |
| terrain | **bounces.** `$B37C` probes the X step and the Y step independently; a solid hit negates `$0750` or `$0760` respectively and increments `$4D` |
| lifetime | every frame with `$4D != 0` advances the type one notch: `$0A → $0C → $0D → $0E → $0F → $10 → $11`, and `$B367` (type `$11`) frees the slot. That is **7 bounces maximum**. In practice it usually leaves the screen first (measured: one bounce at frame 1633, off-screen death at 1641) |
| penetration `$0770` | `$01` |
| damage | 1 |
| facing | yes — `$0680 < 0` negates `$0750` |
| satellite | idle anim `$09` (metasprite `$0140`), crouch anim `$0A` (`$0142`) |
| CHR | satellite bank 90 `$48-$4B`; projectile bank 90 `$50-$53` (bin `0x0260`, `0x02A0`) |
| palette | 1 and 2 alternating |

---

### Weapon 5 — "Charge fan" (index 4, ID 5, combo `$1A` = β β α)

| field | value |
|---|---|
| behaviour handler | `$AAAC`; state machine at `$AB79` |
| projectile type | `$81` → `$01`, handler `$B5C2` |
| slots used | nominally 11 (`$B152` start = `$0A`) but **effectively 8** because of the dead-slot bug (see §1.2) — the first 3 pellets after every weapon change are lost |
| state machine | 0 idle → 1 charging (`$069D` +1 every 8 frames, cap `$10`) → 2 full-charge hold (≤96 frames) → 3 discharge (`$069D` −1 every 8 frames) → 4 cooldown 64 frames → 0 |
| fire rate | **one pellet every 2 frames throughout states 1-3** (it auto-fires while charging) |
| direction | `$0750` is a **6-bit angle** (64 directions) fed to the polar routine `$8FF6`; the table at `$9060` is 16 rows × 16 cosine entries and `$90` selects the row, so radius = `$90 + $10` |
| aim | base angle `$0620,X` eases ±1 per frame toward `$04` (standing) or `$08` (crouching), plus a ±7-step triangle wobble from the 32-entry table at `$AB47` → a slowly sweeping cone |
| speed | pulsing: `(($0760 & $0C) << 2) + $50` → **5, 6, 7, 8 px/frame**, stepping down 1 px every 4 frames and resetting every 16 |
| accel | 0 (stepwise only) |
| lifetime | `$0760` = `$069D` = the charge level = **1 to 16 frames**. Short range at low charge, long at full charge |
| penetration `$0770` | `$01` |
| damage | 1 per pellet, but the rate is 30 pellets/second |
| terrain | none |
| facing | direction from `$0680`; `EOR #$3F` on the angle when `$05CB < 0` |
| satellite | idle anim `$0B` (metasprite `$0144`), crouch anim `$0C` (`$0146`) |
| CHR | satellite bank 91 `$40-$43`; point-blank strike bank 91 `$48-$49` (bin `0x02E0`, `0x0320`) |
| palette | 2 |

The strike sprite overlaps the satellite, so `sol_weapon_5.png` shows the flare at the
satellite rather than a separate travelling projectile — at 5-8 px/frame with a 1-16
frame life the pellets never get more than ~2 tiles away from the muzzle. Weapon 5 is a
point-blank weapon. Its screenshot was taken with **B held continuously** from frame
1580 (shot frame 1660), not with the tap pattern used for the other seven.

---

### Weapon 6 — "Napalm" (index 5, ID 6, combo `$16` = β α α)

Two-stage weapon.

| field | value |
|---|---|
| behaviour handler | `$AC11` |
| stage 1 type | `$85` → `$05`, handler `$B4B4` |
| stage 2 type | `$86` → `$06`, handler `$B4ED` |
| slots used | 3 down to 0 — **max 4 alive** |
| fire rate | **autofire while B is held, one every 8 frames** (verified) |
| stage 1 motion | **jittery scatter.** `$0750` is *not* a velocity — it is a 0→6 frame counter. The step is regenerated every frame from the free-running global counter `$0E`: X = `($0E & $78) | $40` → **4.0 … 7.5 px/f**; Y = `(X >> 1) + 8` → **2.5 … 4.0 px/f**. That randomness is why the spray looks noisy |
| stage 1 lifetime | 6-7 frames, then the type is rewritten to `$86` and `$0750` to `$86` = 134 |
| stage 2 motion | **crawls along the floor.** Probes 8 px "down" (which way is down is chosen by `$05CB`, so it works upside-down too); falls at **3 px/frame** when unsupported, otherwise walks **±1 px/frame** horizontally. On roughly half the frames it also probes ahead and, if blocked, reverses direction and pays 8 frames of life |
| stage 2 lifetime | `$0750` = `$86` = **134 frames maximum**, −8 per wall reversal; ~45 frames typical. Also dies off-screen |
| accel | 0 |
| penetration `$0770` | `$01` |
| damage | 1 |
| terrain | **the only weapon that follows the ground** — floor-hugging flame, falls off ledges, reverses at walls |
| facing | weapon 6 negates `$0760` (not `$0750`) for left; stage 1 then negates X when `$0760 < 0`; Y sign from `$05CB` |
| satellite | idle anim `$02` (metasprite `$0130`), crouch anim `$03` (`$0132`) |
| CHR | satellite bank 88 `$48-$4B`; projectile bank 88 `$54-$57` — **the identical four tiles as weapon 1**, differing only in palette and flip usage (bin `0x0340`, `0x0380`) |
| palette | 2 and 1 alternating |

---

### Weapon 7 — "Flamethrower / melee slash" (index 6, ID 7, combo `$19` = α β α)

**The only weapon with no projectile at all.** Confirmed by a watch on `$0700-$0707`
across a full test run: zero events.

| field | value |
|---|---|
| behaviour handler | `$AC4A`; hitbox spawner `$B871` / `$B881` |
| object used | **main-pool slot `$0E`**, not the projectile pool |
| fields written by `$B881` | `$060E = $1F` (type), `$061E = $0A`, `$065E = $0D` (behaviour), `$066E = $76` / `$067E = $01` (metasprite `$0176`), `$068E = $05B2` (facing), `$06EE = $FF` (i-frames), `$06FE = $1F` (HP) |
| lifetime | **it has none** — the hitbox is destroyed and re-created every frame that the swing animation is on its active sub-frame (`$06C0 == 1 && $06D0 == 2`). Measured ~9 active frames per swing, 5 frames from B press to first hitbox, ≥30 frames between swings |
| max alive | 1 |
| position | offset table `$B8F7`, index from `$B871`: standing (X = `$20`) → **±16 px horizontally, 8 px above** the satellite; crouching (X = `$28`) → **±16 px horizontally, 18 px below** |
| damage | **2** — the only weapon that does more than 1. From the metasprite damage table: `bank8[$8A19 + 2*$0176] = 2` |
| collision | uses the main-pool path, so the enemy box is **expanded by 8 px on each side plus 16 px of width and height** — a much more forgiving hitbox than any projectile |
| velocity / accel | none, it is a static box |
| terrain | none |
| facing | `$0680,$0E = $05B2`; the X offset gets +4 when facing left; `$05CB` flips the Y sign |
| satellite | idle anim `$11` (metasprite `$0150`); firing anims `$12` (`$0152`,`$0154`,`$0156`) and `$13` (`$015C`,`$0158`,`$015A`,`$015E`) |
| CHR | satellite idle bank 86 `$40-$45`, charge `$46-$49`, firing `$4A-$4F`; flame burst `$50-$57`; charge spark `$58-$59`; sustained flame `$5A-$5D` (bin `0x03C0` … `0x0560`) |
| palette | robot 1, flame 2. The flame flips with facing (`$06` → `$46`) |

Weapon 7 is also the only weapon that does **not** swap MMC3 R3 — bank 86 is the default
one already mapped during gameplay.

---

### Weapon 8 — "Boomerang" (index 7, ID 8, combo `$26` = β α β)

Two-stage: outbound, then homing return.

| field | value |
|---|---|
| behaviour handler | `$A8DB` |
| outbound type | `$93` → `$13`, handler `$B6A7` |
| return type | `$14`, handler `$B61B` |
| slots used | 2 down to 0 — **max 3 alive** |
| fire rate | animation-gated, ~6 frames from B press to spawn; measured cadence 30 frames |
| outbound velocity | `$0750` = ±`$50` = **±5.00 px/f X and ±5.00 px/f Y** (a pure diagonal); bit 0 of `$0750` picks up or down |
| outbound lifetime | `$0760` = `$0D` = **exactly 13 frames** (verified: spawn 1626, `$B6AF INC $0700,X` converts `$13`→`$14` at 1639), then it becomes the return type |
| return motion | **homing boomerang.** At conversion, `$B6B2-$B6C3` snaps the direction to one of four diagonals (`$08`, `$19`, or those XOR `$30`). `$B61B` then loops a 0..`$27` counter forever: on frames 0-14 it asks `$C051` → `$C12E` → bank-12 `$8E3C` for the angle from itself to the player and turns **±4/64 = ±22.5° per frame** toward him; on frames 15-39 it flies straight |
| return speed | by cycle counter: frames 0-4 → **4 px/f**, 5-10 → **3 px/f**, 11-39 → **6 px/f** |
| accel | 0 (stepwise) |
| return lifetime | **it never expires by time.** It dies only when its X-hi *and* Y-hi both equal the player's (i.e. within one 16-px cell) → sound `$31`, `$069C = 1`; or by leaving the screen. Measured ~23 frames to come back |
| penetration `$0770` | **`$10`** — 16 armour points of piercing, second only to weapon 3 |
| damage | 1 per hit, but it hits on the way out and on the way back and pierces |
| terrain | none |
| facing | `$0680 < 0` negates `$0750`; `$05CB < 0` sets bit 0 (forces up) |
| satellite | idle anim `$0D` (metasprite `$02C2`), crouch anim `$0E` (`$02C4`); firing anims `$24` / `$25` |
| CHR | satellite bank 91 `$50-$53`; projectile bank 91 `$5C-$5F` (bin `0x05A0`, `0x05E0`) |
| palette | 2 |

---

## 7. Summary table

| # | combo | name | type(s) | speed px/f | lifetime | max | cadence | pierce | dmg | terrain |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | ααα `$15` | orbit whip | `$15` | kinematic, 30 px reach, 1 rev/16 f | 51 f | 1 | ~60 f | 1 | 1 | none |
| 2 | βββ `$2A` | grenade shot | `$09` / `$04` | 4.50,2.50 / 4.00,3.00 | ~20 f | 1 | ~60 f | 1 | 1 | **explodes on walls** |
| 3 | ααβ `$25` | burst rifle | `$08` / `$03` | 7,4 / 7,7 | off-screen only | 8 | 8 shots @2 f, 80 f cycle | **$7F** | 1 | none |
| 4 | αββ `$29` | bouncer | `$0A` / `$02` | 5.19,3.00 / 4.19,4.19 | 7 bounces | 2 | B edge | 1 | 1 | **bounces** |
| 5 | ββα `$1A` | charge fan | `$01` | 5-8, pulsing | 1-16 f (= charge) | 8 | 1 per 2 f while charging | 1 | 1 | none |
| 6 | βαα `$16` | napalm | `$05` → `$06` | 4.0-7.5 scatter → 1.0 crawl | 6 f + ≤134 f | 4 | 1 per 8 f held | 1 | 1 | **floor-crawling** |
| 7 | αβα `$19` | slash | none (slot `$0E`) | static | ~9 f/swing | 1 | ≥30 f | — | **2** | none |
| 8 | βαβ `$26` | boomerang | `$13` → `$14` | 5,5 out; 3-6 homing | 13 f + until caught | 3 | ~30 f | `$10` | 1 | none |

---

## 8. How the proof screenshots were produced

Base savestate — Stage 1 gameplay, player standing, facing right:

```
./work/tools/nesemu "Tokkyuu Shirei Solbrain (Japan).nes" \
    -input work/tmp/boot.inp -frames 1500 -savestate work/tmp/play.st@1500
```

(`work/tmp/boot.inp` = START pulses, 6 frames on every 30 frames, from frame 200 to 1300.)

**Quirk: the game ignores controller input for ~15 frames after a state load.**
Never schedule input before absolute frame 1520.

Forcing weapon *n*: write the combo byte into `$05C4` and kick the creation countdown
`$05C3` to `$31`, so the satellite is created on the next frame:

```
./work/tools/nesemu "Tokkyuu Shirei Solbrain (Japan).nes" \
    -loadstate work/tmp/play.st \
    -poke 5C4=<combo>@1520 -poke 5C3=31@1520 \
    -input work/tmp/fire.inp -frames 1700 \
    -png work/build/shots/sol_weapon_<n>_ -shot <frame>
```

with `<combo>` = `15 2A 25 29 1A 16 19 26` for weapons 1..8 respectively.

`work/tmp/fire.inp` holds B in a repeating **4 frames on / 6 frames off** pattern
starting at frame 1580. A single 3-shot burst is *not* enough: weapons 5 and 6 run on
charge/burst timers and produce nothing from three taps.

Each shot frame was chosen per weapon from a `-vram` sweep so that the projectile is
actually on screen. The `-vram` dumps were re-rendered with `work/tools/vram.py` to read
the OAM tile numbers, attributes and the live palette, and to confirm which MMC3 R3 bank
was mapped on the sprite's own scanline.

Output: `work/build/shots/sol_weapon_1.png` … `sol_weapon_8.png`.

## 9. What is *not* fully characterised

1. **`$9CF1` — the "A held while carrying a satellite" action.** The code is clear
   (`LDA $06 / BPL` + valid `$060C` → `JSR $881A`, `JSR $9359`, `$05A2 = 4`,
   `$05AF = $80`, `$05AB = $10`, which discards the satellite), but it could not be
   triggered in the emulator — holding A always produced a normal jump. There is an
   additional entry condition that was not identified.
2. **Weapon 5's fan direction in world terms.** The angle arithmetic is decoded
   (targets `$04` standing / `$08` crouching on a 64-step circle) but the
   angle→screen-direction mapping was not confirmed visually.
3. **Weapon 2's and weapon 8's exact cooldowns.** They are driven by the animation
   system (`$8DA6`/`$8DEF`), not by a counter that was decoded. The 9-frame and 6-frame
   press-to-spawn delays were *measured*, not read from a table.
4. **Palette colours are Stage-1 values.** The weapons always use sprite palettes 1
   and 2, but a different stage may load different colours into `$3F14-$3F1B`.
5. **Projectile type `$12`** (`$B225`, a vertical laser column) exists in the dispatch
   table but is not spawned by any of the eight satellites; it was not analysed.

---

## 10. The pool walk itself — `$B168` (bank 13), and every entry of both tables

Added while the pool was ported to the engine (Э4.2).  Section 1.2 says what a
slot holds; this says what is done with it, entry by entry, and it is the part
the acceptance stand `work/extract/verify_sol_weapon.py` holds against the
cartridge.

### 10.1 Where in the picture it runs

`$CDD2 JSR $8007` is one call into bank 12, and bank 12's `$8007` is
`JMP $9150`, which is three lines:

```
9150  JSR $9159      ; the hero is drawn, and the bar with him
9153  JSR $B168      ; this pool is walked
9156  JMP $A489
```

So the pool runs **after the hero's own step and before either of the other two
pools** (`$CDDA` the shots, `$CDDD` the objects).  It runs every picture whether
a satellite exists or not — nothing about the walk is gated on one.

### 10.2 The shared helpers

| address | what it does |
|---|---|
| `$880F` (bank 12) | wipes the four scratch bytes `$90..$93` |
| `$B313` | the slot's two speeds, each spread over two bytes, into `$90:$91` and `$92:$93` |
| `$B2E2` | `$90:$91` is added to where it is, along |
| `$B2D0` | `$92:$93` is added to where it is, down |
| `$B2CD` | both |
| `$B2CA` | `$B313` and then `$B2CD` — the plain move |
| `$B2F4` | the other way about: where it is is added *to* the scratch, so the scratch becomes the place it is looking at |
| `$B32C` | where it is is moved by the satellite's own step (`$062C:$063C` along, `$064C:$069C` down) |
| `$B595` | sixteen cells out of the picture either way and the slot is given up; what is left in the scratch is where it stands on the screen |
| `$B5BC` | the slot is given up |
| `$C00C` → `$D032` | what the map has where the scratch points |

### 10.3 The flying table `$B1A6`

| type | handler | what it does |
|---|---|---|
| `00`, `15` | `$B6E1` | the ring round the satellite: it is put back on the satellite every picture and pushed out by twice the step the shared angle gives; the angle is `$069C`, wound on by the satellite's own rate `$064C`.  `$0750` counts its life down |
| `01` | `$B5C2` | it spins outwards: `$0750` is the angle, and how far it reaches comes from how much of `$0760` is left |
| `02`, `0A`, `0B` | `$B36B` | it bounces, and on the picture it bounces it becomes `$8C` |
| `03`, `07`, `08` | `$B42C` | it rides the satellite while `$0760` runs down, and once the count would run out it also moves by the step packed into the two halves of `$0750` |
| `04`, `09` | `$B3F1` | straight on until the map where it stands is solid, and then it becomes `$09`, the bang |
| `05` | `$B4B4` | it widens: five pictures of a step that is half noise (`$0E`), and then it becomes `$86` |
| `06` | `$B4ED` | it crawls along whatever it is on — falling while the map below is empty, sliding while it is solid, turning round when the way ahead is solid too.  Each turn costs eight of `$0750` |
| `0C`..`$11` | `$B353`..`$B367` | the same bounce as `02`, but becoming `$8D`, `$8E`, `$8F`, `$90`, `$91` and `$00` |
| `12` | `$B225` | the slash: one slot stands for a whole column of pictures drawn one above the other.  Only the first turn of its loop moves anything |
| `13` | `$B6A7` | thrown out on the step packed into `$0750`; when `$0760` runs out it becomes `$14` |
| `14` | `$B61B` | and comes back: four steps of the circle a picture towards the satellite, caught the moment the two stand in the same cell both ways |

### 10.4 The burning-out table `$B1E1`

Sixteen of the twenty two are `$B21F`, which simply writes nought over the slot.
The rest:

| type | handler | what it does |
|---|---|---|
| `03`, `07` | `$B20D` | the slot is given up where it stands, and the puff is drawn there for the one picture |
| `04`, `09` | `$B294` | the bang: slot thirteen of the object pool is made into the blast at this place, and the slot is given up |
| `12` | `$B225` | the same either way |
| `15` | `$B216` | the slot is given up and the satellite's walk is put back to its first step (`$8DCA` with X = `$0C`) |

### 10.5 Three slips worth keeping

They are all reproduced in the engine, because the acceptance is by comparison.

1. **`$B3BD` subtracts without setting the carry first.**  `$B37C` turns a step
   round when it runs into something: along at `$B398`, which does `SEC` first,
   and down at `$B3BD`, which does not.  The carry at that point is always clear
   — the way back out of `$D032` goes through `$C998`, whose last sum is "this
   bank plus one" and never carries — so the step down always comes back one
   too far.
2. **`$B73D` reads the wrong pair.**  `$B6E1` works out a step along in
   `$4C:$4D` and a step down in `$4E:$4F`, and then puts `$4C:$4D` into *both*
   `$90:$91` and `$92:$93`.  The ring therefore moves down by exactly as much as
   it moves along, whatever the angle said.
3. **`$8E99` doubles before it tests.**  The angle routine `$8E44` doubles both
   lengths until the longer fills the top nibble, but the doubling comes first
   and the test second — so a pair that was long enough already is doubled once
   too often and the answer comes back `$FF`, "cannot say".  `$B61B` leans on
   this: a boomerang whose satellite is far away is nudged by `$FF`, not by a
   real heading.

### 10.6 Above the top of the stage nothing is worth comparing

Row nought of every stage's room map is padding: the numbers in it are not
screen numbers at all, and the game never means to look there.  A slot that
climbs out of the stage upwards — above `$1000` — makes the cartridge read a
screen that does not exist and answer with whatever bytes happen to follow the
screens table.  That is the cartridge reading off the end of its own data, and
copying it would mean copying the layout of the ROM rather than a rule of the
game, so the stand `work/extract/verify_sol_weapon.py` drops a slot from the
comparison for good once it gets that high (`INSIDE`, with a page of margin
because a slot probes a little ahead of itself).

The only behaviours this ever touches are the two that bounce, `$B36B` and its
`$8D`/`$8E`/`$8F` kin, and only when they are seeded near the ceiling.

## 11. Getting into the pool — $AEBD and $AE8A (bank 13)

Nothing else puts anything in `$0700`.  All nine of the hero's firing routines
(`$A8F6`, `$A95E`, `$AA1B`, `$AA4D`, `$AA94`, `$AB30`, `$AB9A`, `$AC32`,
`$ACF5`) end in `JSR $AEBD`, with the kind of weapon in `A` and the slot of
whoever is throwing it in `X`.

### 11.1 Finding a slot

```
AEBD  STA $90            the kind, bit 7 and all
AEBF  AND #$7F
AEC1  STA $98            and without it, which is the row of every table
AEC3  TAY
AEC4  LDA $B152,Y        the slot to try first
AEC7  TAY
AEC8  TYA / PHA          keep it
AECA  LDA $0700,Y
AECD  BNE $AF3F          taken -- try the one below
...
AF3F  PLA / TAY / DEY / BPL $AEC8
AF44  RTS                nothing free, and nothing is thrown
```

So each kind of weapon has its *own* first slot, and the search only ever
counts downwards from there.  `$B152` reads

```
00 0A 01 0A 00 03 0A 0A 0A 00 01 01 00 00 00 00 00 00 00 02 02 00
```

— eleven of the twenty two kinds may only ever have slot nought, and the ones
that start at ten can have up to eleven of themselves at once.  (Only slots
nought to seven are ever walked, so the top three of those eleven are thrown
and then never move; see 10.1.)

### 11.2 Which numbers are read

`$05CB` bit 7 picks between two halves of every table, and `$05A2` -- how the
thrower is standing -- picks between two sets of starting offsets within each
half:

| `$05CB` bit 7 | `$05A2` | step along | step down | offset along | offset down |
|---|---|---|---|---|---|
| clear | `3` | `$AF84` | `$AFB0` | `$AFF2`:`$B01E` | `$B04A`:`$B076` |
| clear | else | `$AF84` | `$AFB0` | `$B0A2`:`$B0CE` | `$B0FA`:`$B126` |
| set | `3` | `$AF9A` | `$AFC6` | `$B008`:`$B034` | `$B060`:`$B08C` |
| set | else | `$AF9A` | `$AFC6` | `$B0B8`:`$B0E4` | `$B110`:`$B13C` |

and `$AFDC` gives how many things it may go through, the same either way.

The two halves differ only in the step down and in whether the offset down is
above or below: with the bit set, kinds `$02`, `$03`, `$08` and `$0A` get a
step down of `$BC`, `$C0`, `$D8`, `$CF` -- upwards -- and start a whole page
higher (`$FF` in the high byte).  That is the same weapon thrown up instead of
along.

### 11.3 Putting it in

```
AF25  LDA $0680,X        the thrower's facing
AF28  BPL $AF37
AF2A  SEC / 0 - $94:$95  facing left, so the offset along is turned round
AF37  PLA / TAY
AF39  JSR $AE8A
```

and `$AE8A` is simply the two sums and the four stores:

```
x = $A0:$B0,X + $94:$95   ->  $0710:$0720,Y
y = $C0:$D0,X + $96:$97   ->  $0730:$0740,Y
$0700,Y = $90   kind      $0770,Y = $93   how many it goes through
$0750,Y = $91   along     $0760,Y = $92   down
```

The offset down is *not* turned round; only the offset along is.

All twenty two rows are exported by `work/extract/sol_weapon.py` into
`game/data/sol/weapon.json`.

## 12. Спутник: четыре слота героя ($0C..$0F)

Разбор к этапу Э4.1. Порядок кадра ($CDB0) таков, что банк 12 `$8007` =
`JMP $9150` = `JSR $9159` (герой) + `JSR $B168` (пул `$0700`) + `JMP $A489`
(четыре собственных слота героя). То есть **пул `$0700` идёт раньше слотов
спутника**, а не наоборот.

Роли слотов:

| слот | кто |
|---|---|
| `$0C` | спутник |
| `$0D` | его вспышка (`SolObjects.BLAST`) |
| `$0E` | взмах седьмого оружия |
| `$0F` | кулак героя (`SolSat.LAST`) |

### 12.1 `$05B2` -- это байт целиком, а не флаг

Пишут его два места, `$9B6D` и `$AD5C`, и оба кладут туда прокрученную копию
удерживаемого направления: бит 7 -- смотрит влево, бит 6 -- зажат «вправо»,
бит 5 -- какой пришёл перенос. Читателей трое: `$AE1E` и `$B884` копируют
байт целиком в `face` слота, а `$AD48` достаёт из него бит 6, чтобы решить,
в какую сторону поворачивается спутник. Хранить только бит 7 нельзя.

### 12.2 Кулак: `$B81E` -> `$B862`

`$B83E` -- таблица на 36 байт по номеру анимации героя (`SolSprites.loop`):
бит 7 -- эта анимация никогда не бьёт; младший полубайт -- на каком шаге
бьёт; `(v & 0x70) >> 1` -- какой «замах» передаётся в `$B862`. Сам `$B862`
кладёт положение героя в `$90`/`$92` и рождает слот `$0F`; при замахе `>= $10`
слоту ставится `a = $14`.

### 12.3 `$A861`: удар в стену

`$A82C` (кулак) и `$A84D` (взмах) сходятся в `$A861`. Проверки `$87FA`
читаются наоборот от очевидного: `$A88E BEQ` -- «cool == $FF, значит
уменьшаем», `$A8B2 BNE` -- «cool != $FF, значит надеваем картинку». За
разбитую стену `$A8C6` добавляет пять к трёхбайтному счёту `$05FD..$05FF`.
Сам пролом (дыра в карте, бит `$0540`, обломки в пул) отложен в Э4.4 и
помечен через `missed_sat(0xB9)`.

### 12.4 `$B670`: бумеранг возвращается не туда, куда кажется

`$B61B` кладёт в `$90..$93` положение спутника, в `$94..$97` -- снаряда, и
`$8E44` считает `$94 - $90`, то есть «от спутника к снаряду». Но между этим
стоит `$B670 JSR $C051`, а `$C051` = `$C12E`:

```
C12E  STY $90 / LDA #$0C / JSR $C92C / LDY $90 / JSR $8004 / PHA / JSR $C998 / PLA / RTS
```

Первая же команда затирает `$90` -- младший байт x спутника -- регистром Y.
А Y к этому моменту -- это `#$C2` из `$B611`, пронесённый через `$B5FE` ->
`$C01B` -> `$E554`: ни одна из этих трёх не трогает Y. Значит угол берётся
не от того места, где спутник стоит, а от его старшего байта с `$C2` внизу.
Это ошибка картриджа, и она сохранена: без неё бумеранг на 32-м кадре
поворачивает в другую сторону.

Приёмка: `work/extract/verify_sol_sat.py`, три места x восемь оружий x шесть
сценариев = 144 сценария, 0 расхождений.

### 12.5 Буквы: `$923B` -> `$92B5` -> `$92CD`

`$05C4` -- три подобранные буквы, по паре бит на каждую. `$9337` -- восемь
комбинаций, которые игра знает, `$933F` -- какое оружие даёт каждая.

`$923B` стоит в самом хвосте `$9159` и делает три вещи:

* если `$05C2` или `$05C3` уже ненулевые -- сразу в `$92B5` (отсчёт);
* иначе ищет комбинацию сверху вниз и на совпадении ставит `$05C3 = $80`;
* рисует три окошка на полосе (`$9264`), и вот у каждого окошка свой таймер
  в `$070C`, `$070D`, `$070E` -- три байта пула `$0700`, до которых обход
  `$B168` никогда не доходит, потому что он ходит только по первым восьми.

`$92B5` уменьшает `$05C3` на единицу за кадр. Ровно на `$30` зовёт `$92CD`;
ниже `$30` не делает ничего (пул и так стоит: `$A56A`); выше -- рисует окошки
на тех кадрах, где бит 3 чист, отчего они и мигают.

Пока `$05C3` между 1 и `$2F`, герой **не ходит вовсе**: `$91AC` просто не
зовёт `$9477`. Но кадровый счётчик `$0C` и «что нажали заново» (`$C882`)
идут своим чередом, они не внутри `$9477`.

`$92CD` ищет комбинацию ещё раз и выдаёт:

* `$05C4 = 0`, `$060D = 0`, `$0700..$070A = 0`;
* если `$060C & $3F` уже равно тому же оружию (`$92F2`) -- второго спутника не
  даёт: `$06FC = $10`, `$05A2 = $0D`, `$05AB = $7F`, и тот, что есть, сгорает;
* иначе `$061C` = угол покоя по `$05B2`, `$065C` = номер комбинации,
  `$060C` = оружие, и `$9347` даёт шестнадцать очков жизни.

Состояние `$0D` (`$97D4`) -- само сгорание: `$05A3 = $20`, `$05AB` убывает по
четыре за кадр, а когда уже некуда -- `$B7AC` сбрасывает анимацию, `$05A2 = 0`,
`$05CE = 0` и `$05C2 = $7F` (столько кадров его не трогают).

Приёмка: `verify_sol_sat.py --letters` -- три места x восемь комбинаций x две
постановки (с уже готовым спутником и без) x три сценария.
