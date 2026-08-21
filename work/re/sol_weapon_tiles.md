# Solbrain satellite sub-weapons — sprite tile manifest

Companion to `/Users/hropl/pr/mypr/PB3/work/re/sol_weapon_tiles.bin`
(1632 bytes = 102 tiles, 16 bytes/tile, standard NES 2bpp planar, copied verbatim
from the CHR of `Tokkyuu Shirei Solbrain (Japan).nes`).

Source ROM: mapper 4 (MMC3), PRG 128 KB, CHR 128 KB (= 128 physical 1 KB CHR banks).
CHR data begins at file offset `0x20010` (16-byte iNES header + 128 KB PRG).

## How the sprites are addressed

* PPUCTRL during gameplay is `$A9`: **8x16 sprites** (bit 5) and background pattern
  table 1 (bit 4). In 8x16 mode the OAM tile byte `T` selects pattern table `T & 1`
  and the tile pair `T & 0xFE` / `(T & 0xFE) + 1` (top / bottom half).
  Every satellite and weapon sprite uses an **odd** tile byte, i.e. **pattern table 1**
  (`$1000-$1FFF`).
* MMC3 with CHR A12 inversion **off**: `$0000-$07FF` = R0 (2 KB), `$0800-$0FFF` = R1 (2 KB),
  `$1000-$13FF` = R2, `$1400-$17FF` = R3, `$1800-$1BFF` = R4, `$1C00-$1FFF` = R5 (1 KB each).
* **Every weapon tile in this manifest lies in tile range `$40-$5F` of pattern table 1**,
  i.e. PPU address `$1400-$15FF`, which is inside the `$1400-$17FF` window mapped by
  **MMC3 register R3**. So "CHR bank number" below = the value written to R3. R3 has 1 KB
  granularity, so the register value *is* the physical 1 KB bank index (0..127).
* Offset of tile `t` (`$40 <= t <= $7F`) inside its 1 KB bank: `t*16 - 0x400`.
  ROM CHR offset = `bank*0x400 + (t*16 - 0x400)`; file offset = that + `0x20010`.
* R3 was sampled per-scanline (`Vram.chr_scan[y]`) at the scanline each sprite is drawn on;
  it is constant over the whole visible area for these sprites. R2 (`$1000-$13FF`, tiles
  `$00-$3F`) is the one the game swaps every few frames — that is the *player*, not the satellite.

## Sprite palettes

The whole of Stage 1 uses one static sprite palette set (verified: only one distinct
sprite-palette state across scanlines 60-200 in every dump). Values read from
`Vram.scan[110]['pal']` at the moment each weapon was on screen — **identical for all 8**:

| palette | OAM attr bits 0-1 | 4 NES colour indices ($3F1x) |
|---|---|---|
| 0 | `%00` | `0F 01 28 30`  (black / blue / gold / white) — player body |
| 1 | `%01` | `0F 0F 21 30`  (black / black / light blue / white) |
| 2 | `%10` | `0F 06 27 38`  (black / dark red / orange / pale yellow) |
| 3 | `%11` | `0F 08 27 37`  (black / brown / orange / tan) — unused by weapons |

Entry 0 of a sprite palette is never drawn (colour 0 = transparent), so the effective
3 colours are: **palette 1 = `0F, 21, 30`**, **palette 2 = `06, 27, 38`**.

Attribute bytes seen: bit0-1 = palette, bit6 = H-flip, bit7 = V-flip. Bit 5 (behind-background
priority) is **never set** on any weapon sprite. The stray bit 2 in `$05` / `$06` is an
unused OAM bit and has no effect — `$05` means palette 1, `$06` means palette 2.

## Horizontal flip when the player faces left

**The satellite robot is H-flipped when the player faces left**: its attribute byte goes
`$05` -> `$45` (and `$06` -> `$46` for weapon 7's flame). Verified by re-running every
weapon with LEFT held.

Projectiles split into two groups:

* **Direction-carrying**: W3 shot (`$01` -> `$41`) and W7 flame (`$06` -> `$46`) flip with facing.
* **Mirror-symmetric**: W1, W2, W4, W5, W6, W8 projectiles are already drawn as a tile plus
  its own mirrored copy, so their attribute pattern is identical in both directions.

## Byte map of `sol_weapon_tiles.bin`

| weapon | group | bin offsets | 1 KB CHR bank (MMC3 R3) | pattern-table-1 tiles | ROM CHR offset | .nes file offset |
|---|---|---|---|---|---|---|
| 1 | satellite | `0x0000-0x007F` (8) | 88 | `$40-$47` | `0x16000-0x1607F` | `0x36010` |
| 1 | projectile | `0x0080-0x00BF` (4) | 88 | `$54-$57` | `0x16140-0x1617F` | `0x36150` |
| 2 | satellite | `0x00C0-0x00FF` (4) | 89 | `$40-$43` | `0x16400-0x1643F` | `0x36410` |
| 2 | bullet | `0x0100-0x011F` (2) | 89 | `$54-$55` | `0x16540-0x1655F` | `0x36550` |
| 2 | impact blast | `0x0120-0x01BF` (10) | 89 | `$56-$5F` | `0x16560-0x165FF` | `0x36570` |
| 3 | satellite | `0x01C0-0x01FF` (4) | 90 | `$40-$43` | `0x16800-0x1683F` | `0x36810` |
| 3 | muzzle flash | `0x0200-0x021F` (2) | 90 | `$56-$57` | `0x16960-0x1697F` | `0x36970` |
| 3 | shot | `0x0220-0x025F` (4) | 90 | `$58-$5B` | `0x16980-0x169BF` | `0x36990` |
| 4 | satellite | `0x0260-0x029F` (4) | 90 | `$48-$4B` | `0x16880-0x168BF` | `0x36890` |
| 4 | projectile | `0x02A0-0x02DF` (4) | 90 | `$50-$53` | `0x16900-0x1693F` | `0x36910` |
| 5 | satellite | `0x02E0-0x031F` (4) | 91 | `$40-$43` | `0x16C00-0x16C3F` | `0x36C10` |
| 5 | strike | `0x0320-0x033F` (2) | 91 | `$48-$49` | `0x16C80-0x16C9F` | `0x36C90` |
| 6 | satellite | `0x0340-0x037F` (4) | 88 | `$48-$4B` | `0x16080-0x160BF` | `0x36090` |
| 6 | projectile | `0x0380-0x03BF` (4) | 88 | `$54-$57` | `0x16140-0x1617F` | `0x36150` |
| 7 | satellite idle | `0x03C0-0x041F` (6) | 86 | `$40-$45` | `0x15800-0x1585F` | `0x35810` |
| 7 | satellite charge | `0x0420-0x045F` (4) | 86 | `$46-$49` | `0x15860-0x1589F` | `0x35870` |
| 7 | satellite firing | `0x0460-0x04BF` (6) | 86 | `$4A-$4F` | `0x158A0-0x158FF` | `0x358B0` |
| 7 | flame burst | `0x04C0-0x053F` (8) | 86 | `$50-$57` | `0x15900-0x1597F` | `0x35910` |
| 7 | charge spark | `0x0540-0x055F` (2) | 86 | `$58-$59` | `0x15980-0x1599F` | `0x35990` |
| 7 | flame (sustain) | `0x0560-0x059F` (4) | 86 | `$5A-$5D` | `0x159A0-0x159DF` | `0x359B0` |
| 8 | satellite | `0x05A0-0x05DF` (4) | 91 | `$50-$53` | `0x16D00-0x16D3F` | `0x36D10` |
| 8 | projectile | `0x05E0-0x061F` (4) | 91 | `$5C-$5F` | `0x16DC0-0x16DFF` | `0x36DD0` |
| — | shared spawn orb | `0x0620-0x065F` (4) | 93 | `$5A-$5D` | `0x175A0-0x175DF` | `0x375B0` |

Tiles are stored in ascending tile index inside each group; group order in the file is
weapon 1..8, then the shared spawn orb. **Weapon 1 and weapon 6 share the identical
projectile art** (bank 88, tiles `$54-$57`) — the same four tiles appear twice in the .bin
so that each weapon's block is self-contained; they differ only in palette and flip usage.

Completeness was checked mechanically: across ~1,700 per-frame VRAM dumps (right-facing,
left-facing and long tapping runs for all 8 weapons) **no sprite tile was ever drawn from a
weapon's own CHR bank that is not in this .bin**. The .bin was also used to re-render each
weapon's on-screen sprite composite from scratch; the result matches the emulator output.

---

# Per-weapon detail

Coordinates below are OAM `(x, y)` (screen y is `y+1`). "sprite `$NN`" = OAM tile byte,
which covers pattern tiles `$NN-1` and `$NN`.

## Weapon 1 — combo `$05C4 = $15` — spinning orb / boomerang
Screenshot: `work/build/shots/sol_weapon_1.png` (frame 1646)

* **Satellite** — 2 sprites side by side, 16x16, attr `$05` (palette 1), `$45` facing left.
  * left half animates, right half is always sprite `$43`.
  * animation order (3 frames per step, 9-frame loop): `$45` -> `$41` -> `$47` -> repeat.
* **Projectile** — 16x16 built from one 8x16 sprite plus its own H-mirror:
  left `(x, y)` attr `$01`, right `(x+8, y)` attr `$41`.
  * animates every single frame, 2-step loop:
    sprite `$55` attr `$01`/`$41` (**palette 1**) <-> sprite `$57` attr `$02`/`$42` (**palette 2**).
  * flies a closed loop (returns to the satellite), one projectile at a time in `$0700`,
    type byte `$95`.

## Weapon 2 — combo `$2A` — bullet with expanding shock ring
Screenshot: `work/build/shots/sol_weapon_2.png` (frame 1636)

* **Satellite** — sprites `$41` (left) + `$43` (right), attr `$05` (palette 1), `$45` facing left.
  **No animation** — static the whole time.
* **Bullet** — a *single* 8x16 sprite `$55`, attr `$01`, palette 1.
  Animation is the H-flip bit toggling every 4 frames: `$01` (4f) -> `$41` (4f) -> repeat.
  Projectile type `$89`.
* **Impact blast** (when the bullet expires, type flips to `$09`) — palette 2 throughout,
  built entirely from flipped copies of a few tiles. 3 stages:
  1. ~4 frames, 16x32: sprite `$57` at `(x,y)` `$06`, `(x+8,y)` `$46`, `(x,y+16)` `$86`, `(x+8,y+16)` `$C6`.
  2. ~4 frames, 32x32: columns `$59 $5B $5B $59` at `x, x+8, x+16, x+24`,
     top row attrs `$06 $06 $46 $46`, bottom row (`y+16`) `$86 $86 $C6 $C6`.
  3. ~5 frames, 32x32: same layout with `$5D $5F $5F $5D`.

## Weapon 3 — combo `$25` — rapid-fire beam stream
Screenshot: `work/build/shots/sol_weapon_3.png` (frame 1596)

* **Satellite** — sprites `$41` + `$43`, attr `$05`, `$45` facing left. No animation.
* **Muzzle flash** at the satellite, redrawn on every shot (every 2 frames):
  sprite `$57` attr `$01` at `(x,y)` and sprite `$57` attr `$C1` (H+V flip) at `(x+8,y)` — 16x16, palette 1.
* **Shot** — 16x16 from two *different* sprites: `$59` at `(x,y)` + `$5B` at `(x+8,y)`,
  attr `$01`, palette 1. **No animation** over the shot's lifetime — it is a static tile pair.
  Facing left: both become attr `$41`.
* Fills all 8 slots of the `$0700` array at once (type `$88`) — this is why it draws as a
  continuous diagonal beam.

## Weapon 4 — combo `$29` — twin spark shots
Screenshot: `work/build/shots/sol_weapon_4.png` (frame 1658)

* **Satellite** — sprites `$49` + `$4B`, attr `$05`, `$45` facing left. No animation.
* **Projectile** — 16x16 from one 8x16 sprite plus a 180deg-rotated copy:
  left `(x,y)` attr `$01`/`$02`, right `(x+8,y)` attr `$C1`/`$C2` (H+V flip).
  * animation, 2 frames per step, 4-frame loop:
    sprite `$51` attr `$01`/`$C1` (**palette 1**) <-> sprite `$53` attr `$02`/`$C2` (**palette 2**).
  * projectile type `$8A`, changes to `$8C` when it turns/rises.

## Weapon 5 — combo `$1A` — point-blank strike
Screenshot: `work/build/shots/sol_weapon_5.png` (frame 1680)

* **Satellite** — sprites `$41` + `$43`, attr `$05`, `$45` facing left. No animation.
* **Strike** — 16x16 from one 8x16 sprite plus its H-mirror:
  sprite `$49` attr `$02` at `(x,y)` and attr `$42` at `(x+8,y)`, **palette 2**.
  * "animation" is a 1-frame-on / 1-frame-off blink for the duration of the burst.
  * it is drawn ~4 px right and ~4 px below the satellite, i.e. **overlapping the satellite**;
    this weapon has no travelling projectile, so the screenshot shows the satellite in its
    attack pose with the orange flare on it (compare with the plain white satellite in
    `sol_weapon_1.png`). Projectile type `$81`; it fires in automatic bursts with a cooldown
    rather than one shot per button press.

## Weapon 6 — combo `$16` — rising orbs
Screenshot: `work/build/shots/sol_weapon_6.png` (frame 1670)

* **Satellite** — sprites `$49` + `$4B`, attr `$05`, `$45` facing left. No animation.
* **Projectile** — 16x16 from one 8x16 sprite plus a 180deg-rotated copy:
  left `(x,y)`, right `(x+8,y)` with H+V flip.
  * animation, 2 frames per step, 4-frame loop:
    sprite `$55` attr `$02`/`$C2` (**palette 2**) <-> sprite `$57` attr `$01`/`$C1` (**palette 1**).
  * type `$85` while travelling outward, `$86` after it turns upward.
  * **These are the same four CHR tiles as weapon 1's projectile** (bank 88, `$54-$57`);
    only the palette/flip usage differs.

## Weapon 7 — combo `$19` — flamethrower (no `$0700` projectile at all)
Screenshot: `work/build/shots/sol_weapon_7.png` (frame 1686)

This weapon never writes the `$0700` projectile array; the flame is drawn directly as
extra sprites belonging to the satellite object. Its CHR bank (86) is the bank R3 already
holds when no satellite is active, so weapon 7 does not swap banks.

Full state sequence (all satellite sprites attr `$05` / `$45` facing left,
all flame sprites attr `$06` / `$46` facing left, **palette 2**):

1. **idle** — 3 sprites, 24x16: `$41`, `$43`, `$45` at `x`, `x+8`, `x+16`.
2. **charge** (4 frames) — satellite becomes `$47`, `$49` (16x16) and a spark sprite `$59`
   appears at `x-8`.
3. **burst** (2 frames) — satellite becomes `$4B`, `$4D`, `$4F` (24x16); a 16x32 flame head
   appears: `$51` `(x+24, y-16)`, `$53` `(x+32, y-16)`, `$55` `(x+24, y)`, `$57` `(x+32, y)`.
4. **sustain** (~11 frames) — satellite stays `$4B`/`$4D`/`$4F`; flame shrinks to 16x16:
   `$5B` `(x+24, y)`, `$5D` `(x+32, y)`.
5. back to **idle**.

## Weapon 8 — combo `$26` — homing fireball
Screenshot: `work/build/shots/sol_weapon_8.png` (frame 1680)

* **Satellite** — sprites `$51` + `$53`, attr `$05`, `$45` facing left. No animation.
* **Projectile** — 16x16 from one 8x16 sprite plus a 180deg-rotated copy:
  left `(x,y)` attr `$02`, right `(x+8,y)` attr `$C2`, **palette 2** for both frames.
  * animation, 4 frames per step, 8-frame loop: sprite `$5F` <-> sprite `$5D`.
  * type `$93` while flying straight, `$94` once it starts homing/curving.

## Shared — satellite spawn orb (not weapon-specific)
Bank 93, tiles `$5A-$5D`, bin `0x0620-0x065F`.
Played for ~20 frames while the satellite materialises next to the player (roughly absolute
frames 1545-1568 after the recipe savestate). 16x16, sprite `$5B` then `$5D`, attr `$05` at
`(x,y)` and `$C5` at `(x+8,y)`, palette 1. Identical for all 8 weapons (verified on 1 and 7),
so it is stored once at the end of the file rather than per weapon.

---

# What could not be pinned down

* **Nothing was left unidentified at tile level.** Every sprite tile drawn from a weapon's own
  CHR bank in any of the captured runs is in the .bin.
* **Palettes are Stage-1 values only.** All capture was done from the supplied Stage-1
  savestate. The satellite/weapon sprites are drawn with palette 1 and palette 2 whatever
  those happen to hold; other stages may load different colours into `$3F14-$3F1B`, so treat
  the RGB values above as "Stage 1", not as a property of the weapon.
* **Firing cadence.** Weapon 5 and weapon 6 do not fire on every B press; they run on an
  internal cooldown/burst timer and weapon 5 appears to auto-fire. The screenshots were taken
  with a repeating 4-on/6-off B tap (`work/tmp/gfx/tap.inp`) which makes all 8 fire reliably.
* **Weapon 2's blast and its bullet never coexist on screen** (the bullet leaves the screen
  before it detonates), so `sol_weapon_2.png` shows the bullet in flight; the 3-stage blast
  is best seen at frames 1613-1619 / 1652-1658 of the same run.

# Reproduction

```
cd /Users/hropl/pr/mypr/PB3
# tap.inp: "1500 -" then, from 1580 every 10 frames, 4 frames of B
./work/tools/nesemu "Tokkyuu Shirei Solbrain (Japan).nes" -loadstate work/tmp/play.st \
  -input work/tmp/gfx/tap.inp -frames 1710 -poke 5C4=<COMBO>@1520 -poke 5C3=31@1520 \
  -png work/tmp/gfx/png/wN -shot <FRAME> -vram work/tmp/gfx/vT/wN_<FRAME>.vram@<FRAME>
```
combos: W1 `$15`, W2 `$2A`, W3 `$25`, W4 `$29`, W5 `$1A`, W6 `$16`, W7 `$19`, W8 `$26`.
Extraction script: `work/tmp/gfx/extract.py`. Analysis helpers: `work/tmp/gfx/an3.py`,
`rep.py`, `rep2.py`, `complete.py`, `verify.py`.
