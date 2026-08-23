# Solbrain — the 29 object types: what each one is, and its Power Blade 2 stand-in

Purpose: the level converter currently spawns *Power Blade 2* enemies at
*Solbrain* coordinates.  This note says what every Solbrain object type actually
is, so that each Solbrain placement can be replaced by the PB2 type that behaves
and looks closest.

Companion notes: `sol_objects.md` (the 6-byte record), `sol_level_format.md` §7
(the placement chain), `pb2_spawns.md` (the PB2 side).

---

## 0. Correction to the working assumption

`$A493 / $A56A / $A587 / $A594` are **not** the enemy update loop — that is the
satellite / player-weapon loop described in `sol_weapons.md`.  The enemy loop is:

```
fixed bank
CE1D  LDX #$0B
CE1F  JSR $CE26 / DEX / BPL $CE1F / RTS      ; slots $0B..$00

CE26  LDA $0600,X / BEQ ret                  ; slot empty
      JSR $CE44                              ; off-screen cull, BMI ret
      INC $06E0,X                            ; hit/invuln timer
      JSR $CF26                              ; draw the metasprite
      LDA #$02 / JSR $C92C                   ; map PRG pair 2/3 at $8000
      JMP $8004                              ; -> bank 2 $819D
```

```
bank 2
819D  LDA $05C3 / BEQ $81A6 / CMP #$30 / BCC $81B6   ; global freeze
81A6  JSR $81B7                                      ; <- the AI dispatch
81A9  LDA $0650,X / BMI $81B6
81AE  JSR $C02A   ( = JMP $CF96, build the hitbox )
81B1  BEQ $81B6
81B3  JMP $C02D   ( = JMP $CFBA, resolve the overlap )
```

`$81B7` reads `$0650,X` (the **behaviour id**) and jumps through one of two
64-entry word tables:

* `$81EA` when bit 7 of `$0650` is clear (normal),
* `$827B` when bit 7 is set (dying / alternate form).

Behaviour `$3F` is a second-level dispatch on `$0690,X`, sub-table `$83A9`
(bit-7 twin: `$8359`, sub-table `$836A`).

Both tables in full are in §5.

---

## 1. Where a type's numbers come from

A placement record's byte 1 is the **type**.  `$AF20` (bank 8) computes
`$9D:$9E = $BDCA + type*9` and copies nine bytes into the slot:

```
AF56  LDY #$00
      ($9D),Y+0 -> $0650,X   behaviour id
            +1  -> $0660,X   metasprite id, low
            +2  -> $0670,X   metasprite id, high
            +3  -> $0610,X   +4 -> $0620,X   +5 -> $0630,X   +6 -> $0640,X
            +7  -> $0690,X   sub-behaviour index
            +8  -> $06F0,X   HP
AF8E  LDA $80 / CMP $A0,X / LDA $81 / SBC $B0,X / STA $0680,X   ; face the player
      $06D0,X = $06C0,X = $06A0,X = 0
```

The full template table (`$BDCA`, PRG bank 9) is reproduced in §4.

**Metasprite id -> graphics.**  `$F461` computes `record = ($8004 in bank 10) +
msid*4` = `$86FF + msid*4`.  Record layout: byte 0 = CHR bank, byte 1 =
attribute/palette, bytes 2-3 = pointer to a pointer to the tile list.  Byte 0 has
two special values:

* `$FF` — **the object is never drawn**.  `$CF26` also skips entirely when
  `$0660|$0670 == 0`.
* `$00` — **keep the stage's current CHR bank**, i.e. the object's graphics are
  stage-dependent.  (This is why forcing such a type into a foreign stage shows
  garbage tiles; see the method note in §7.)

The tile list is `count` followed by `count` two-byte `(dy, dx)` pairs (`$F4E2`
skips a rejected sprite with `INY / INY`, so entries are two bytes and the tile
id is the running counter).  All the pixel sizes in the table below were decoded
straight from those lists.

**Hitbox.**  `$CF96` derives the hitbox *from the metasprite* (`$8007` in bank 8,
i.e. `$814C`).  So an invisible object (`chr $FF`, or `$0660/$0670 == 0`) has
**no hitbox at all**: it cannot be shot and it cannot hurt the player.

**Solid / stand-on-able.**  There is **no per-type solidity flag anywhere.**  The
only per-behaviour byte table in the collision path is `$CFF1` (fixed bank, 20
entries, indexed by `$0650`):

```
$CFF1:  00 00 00 01 01 01 01 01 01 01 01 01 01 01 00 01 01 00 01 00
bhv:    00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 13
```

and it only gates *how often* the player-contact reaction is evaluated
(`$CFC9 LDA $CFF1,Y / BEQ ...`).  The two paths out of `$CFBA` are `$8004`->
`$869C` (player weapon hits the object) and `$800D`->`$83E2` (object hurts the
player); both work purely off the metasprite overlap mask in `$60`.  **No
Solbrain object is a platform you can stand on.**  Moving platforms in Solbrain
are level geometry, not objects (see `sol_level_format.md` §4.6).

**Hits to kill.**  `$06F0` is HP.  Observed damage per player shot is not
constant (tracks show HP going 8 -> 6 -> 1 and 6 -> 5 -> 2 -> 0), i.e. roughly
1-3 per hit depending on the weapon.  The "hits" column below is `HP` and a
rough shot count with the default gun.

---

## 2. The table

Confidence key: **proven** = seen at runtime with a screenshot / RAM trace;
**read** = disassembly only; **guessed** = inference.

Screenshots live in `work/re/shots/sol_types/`.  `Z_SS_TT.png` = Solbrain stage
`SS`, type `TT`, six labelled frames with a red crosshair on the object's exact
world position and the live `bhv / metasprite / HP` under each frame.
`Q_TT.png` = the same treatment for a Power Blade 2 type.
Sheets: `ALLN1.png` `ALLN2.png` `ALLN3.png` (Solbrain), `QA.png` `QB.png` (PB2).

| type | n | stages | what it is | bhv | handler | solid | dmg? | HP (~hits) | metasprite | size | PB2 | conf | shot |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `$17` | 145 | 1,3,4,7,10,15,16 | humanoid ground soldier — walks up, stops, fires a bullet | `$39` | `$8E86` | no | yes | 4 (~2) | `$0346-$034A` (stage CHR) | 25x24 px, 3x3 tiles, 5 spr | `$2C` | proven | `Z_01_17.png` |
| `$03` | 102 | 0,2,4,9,11,15,16 | flyer that hovers **above** the player and attacks downward | `$0D` | `$AA51` | no | yes | 4 (~2) | `$01B6,$01BC,$01C0,$01C2` (stage CHR) | 32x52 px, 4x6 tiles | `$13` | proven | `Z_00_03.png` |
| `$2D` | 79 | 0,4,6 | small ground enemy, walks and hops | `$18` | `$8802` (sub-table `$8819` on `$0690`) | no | yes | 2 (1-2) | `$01E8-$01F6` (stage CHR) | 21x32 px, 3x4 tiles, 4 spr | `$22` | proven | `Z_00_2D.png` |
| `$18` | 76 | 15,16 | humanoid ground soldier — walks and fires (shot id `$A2`) | `$3A` | `$8DEB` | no | yes | 4 (~2) | `$034C-$0350` (CHR `$79`) | 32x24 px, 4x3 tiles, 6-7 spr | `$2C` | proven | `Z_00_18.png` |
| `$16` | 67 | 1,9,10,15,16 | humanoid ground soldier — walks at you, melee, can leap (`$9D0A #$40`) | `$38` | `$8F8D` | no | yes | 6 (~3) | `$035E-$0362` (stage CHR) | 24x24 px, 3x3 tiles | `$2C` | proven | `Z_01_16.png` |
| `$02` | 60 | 0,3 | weak ground walker, turns at walls, dies in one hit | `$0B` | `$AFBA` | no | yes | 1 (1) | `$01A6...$01BA` (CHR `$71`) | 32x40 px, 4x5 tiles, 4-11 spr | `$17` | proven | `Z_00_02.png` |
| `$28` | 57 | 7,15,16 | slow ground enemy — steps once every 16 frames, attacks when adjacent | `$3F`/`$1C` | `$84BA` | no | yes | 8 (~4) | `$0382` (stage CHR) | 24x24 px, 3x3 tiles, 6 spr | `$22` | proven | `Z_00_28.png` |
| `$23` | 40 | 7,10,15,16 | **wall-mounted gun**, faces left, fires a 7-way spread | `$3F`/`$12` | `$8566` | no | yes | 2 (1) | `$0388` (stage CHR) | 16x8 px, 2x1 tiles, 2 spr | `$1D` | proven | `Z_00_23.png` |
| `$27` | 40 | 15,16 | **flame jet** in the floor — ignites when the player is within ~4 units | `$3F`/`$1A` | `$84D6` | no | yes | 2 (1) | `$0392-$03AA` (CHR `$79`) | 16x56 px at full height, 2x7 tiles | `$29` | proven | `Z_00_27.png` |
| `$06` | 39 | 0,4,11 | tall slow walking robot, retargets the player every 8 frames | `$12` | `$ADC5` | no | yes | 10 (~5) | `$01D0-$01D4` (CHR `$72`) | 18x56 px, 2x7 tiles, 8 spr | `$1E` | proven | `Z_00_06.png` |
| `$24` | 36 | 7,15,16 | stationary turret, fires one shot (id `$AC`) when it has line of sight | `$3F`/`$14` | `$8545` | no | yes | 2 (1) | `$03CA` (stage CHR) | 16x8 px, 2x1 tiles, 2 spr | `$1D` | proven | `Z_00_24.png` |
| `$19` | 34 | 7,11,15,16 | humanoid, throws a projectile (id `$A4`, sound `$13`) | `$3B` | `$8CC9` | no | yes | 4 (~2) | `$0356,$035A` (CHR `$7A`) | 24x40 px, 3x5 tiles | `$2C` | proven | `Z_00_19.png` |
| `$2C` | 30 | 1,2,9 | **big four-legged robot beast**, charges the player, ignores culling (`$0600` bit 6) | `$28` | `$8AA2` | no | yes | 6 (~3) | `$0364,$0366` (CHR `$7B`) | 40x40 px, 5x5 tiles, 11 spr | `$23` | proven | `Z_01_2C.png` |
| `$25` | 29 | 1,2 | **invisible falling-crusher trigger**: player within 3 -> drops, hits ground, sets `$05F7 = 7` (screen shake), spawns debris, re-arms after `$70` frames | `$3F`/`$16` | `$84FB` | no | no | 2 | `$0000` (never drawn) | none | `$07` | proven | `Z_01_25.png` |
| `$26` | 27 | 6 | stationary animated prop — the handler only sets an animation, never moves or shoots | `$3F`/`$18` | `$84EF` | no | yes | 2 (1) | `$03C8` (CHR `$7F`) | 24x24 px, 3x3 tiles, 6 spr | `$1D` | proven | `Z_06_26.png` |
| `$1E` | 24 | 15,16 | **invisible periodic spawner/dropper** — every few frames calls `$AAF1` (Y=`$EA`) with sound `$2F`, cycles `$0630` 7..0, then blanks its own metasprite | `$3F`/`$06` | `$8767` | no | no | 16 | `$0000` observed (`$03B4` in the template chain) | none | `$07` | proven | `Z_00_1E.png` |
| `$00` | 21 | 0 | **invisible inert marker** — handler is `RTS`, no hitbox, always placed at ground-32 | `$01` | `$B0CC` (`RTS`) | no | no | 4 (unused) | `$0190` = `FF 00 00 00` | none | `$02` (see note) | proven | `Z_00_00.png` |
| `$20` | 18 | 5 | small fixed **blower/vent facing right** — when the player is within 2 and on the correct side, writes `$05A8/$05A9 = +$0010` (a push impulse on the player) | `$3F`/`$0C` | `$85EA` | no | yes | 1 (1) | `$03BC-$03C4` (CHR `$7D`) | 16x16 px, 2x2 tiles, 2 spr | `$29` | proven | `Z_00_20.png` |
| `$13` | 16 | 4,6,10,15,16 | humanoid ground fighter with attack states (walk / leap / strike) | `$35` | `$902D` | no | yes | 6 (~3) | `$0338-$033E` (CHR `$78`) | 32x40 px, 4x5 tiles, 8-10 spr | `$23` | proven | `Z_04_13.png` |
| `$1D` | 16 | 5 | **big armoured ground robot**, multi-state (idle -> `$0690` = 2 or 4 depending on range/side) | `$3F`/`$00` | `$86A1` (-> `$86C9`, `$8729`) | no | yes | 6 (~3) | `$0368,$036A` (CHR `$7D`) | 33x40 px, 4x5 tiles, 9 spr | `$23` | proven | `Z_00_1D.png` |
| `$14` | 12 | 15,16 | **invisible inert marker** (same handler family as `$00`) | `$36` | `$B0CC` (`RTS`) | no | no | 8 (unused) | `$0190` = `FF 00 00 00` | none | `$02` (see note) | proven | `Z_00_14.png` |
| `$21` | 9 | 4 | small fixed **blower/vent facing left** — mirror of `$20` (`$05A8/$05A9 = -$0010`) | `$3F`/`$0E` | `$85EE` | no | yes | 4 (~2) | `$038C-$0390` (CHR `$7F`) | 24x40 px, 3x5 tiles, 8 spr | `$29` | proven | `Z_04_22.png` (twin) |
| `$29` | 9 | 5 | **top-of-screen bombardier** — pins itself to the camera (`LDA $33 / STA $D0,X`), every 64 frames drops a projectile (id `$AF`, Y velocity `$40`) | `$3F`/`$1E` | `$865C` | no | yes | 1 (1) | `$03C6` (CHR `$7D`) | 16x8 px, 2x1 tiles, 2 spr | `$12` | proven | `Z_00_29.png` |
| `$04` | 9 | 0 | stationary shooter, faces left, fires horizontally (id `$81`, vel `$22`/`$E2`, sound `$12`) every ~128 frames | `$0F` | `$ACB9` | no | yes | 2 (1) | `$01BE,$01C4-$01C8` (stage CHR) | 34x64 px sparse, 3-4 spr | `$1D` | proven | `Z_00_04.png` |
| `$1F` | 6 | 1,2 | ceiling object that falls under gravity (`$52/$53` + `$813F`, terminal check `CMP #$6B`); observed as an invisible ceiling spawner whose children are small cyan flyers | `$3F`/`$2C` | `$861C` | no | no | 1 | `$0000` observed | none | `$12` | read + partial runtime | `Z_01_25.png` (same room) |
| `$1B` | 6 | 15,16 | wide fixed-span patroller — X velocity flips ±4 between world X `$47` and `$4B` (high byte), drops a shot when on screen | `$3E` | `$8C40` | no | yes | 8 (~4) | `$0380` (CHR `$73`) | 48x24 px, 6x3 tiles, 10 spr | `$1E` | proven | `Z_00_1B.png` |
| `$01` | 3 | 0 | **invisible inert marker**, always directly above a `$07` | `$01` | `$B0CC` (`RTS`) | no | no | 4 (unused) | `$016E` = `FF 00 00 00` | none | `$02` (see note) | proven | `Z_00_01.png` |
| `$07` | 3 | 0 | **invisible screen-shake trigger** — when `$06E0 == 9` and `$05F7 == 0`, sets `$05F7 = 4`; `$CD81` reads `$05F7` and `$CE15,Y` -> `$05F8` scrolls the screen | `$13` | `$B0BB` | no | no | 4 (unused) | `$01E4` = `FF 00 00 00` | none | `$02` (see note) | proven | `Z_00_07.png` |
| `$22` | 3 | 4 | **wall-mounted gun facing right**, fires the same 7-way spread as `$23` | `$3F`/`$10` | `$856C` | no | yes | 4 (~2) | `$038C-$0390` (CHR `$7F`) | 24x40 px, 3x5 tiles, 8 spr | `$1D` | proven | `Z_04_22.png` |

Types not in the table are not used by any stage.  Stages 8, 12, 13, 14, 17, 18
and 19 place no objects at all.

### Note on the four invisible markers (`$00`, `$01`, `$07`, `$14`)

`$00`, `$01` and `$14` run `$B0CC`, which is a bare `RTS`, and their metasprite
records are `FF 00 00 00`, so they are never drawn, never collide, and never do
anything.  Their `$06F0` HP byte is dead.  `$07` is the same except its handler
fires the screen shake once.  They are level markers, not enemies.

**The converter should drop these four types rather than substitute anything.**
The dict below still gives them a value (PB2 `$02`, the permanent power-up
capsule) because it is the least destructive thing in the allowed set — `$02`
is gated by `sub_E523` on the collected-items bitmap and does not attack.  If a
`None` is acceptable in your pipeline, use `None` for `$00 $01 $07 $14`.

---

## 3. The eleven Power Blade 2 stand-ins

The allowed set is the types whose tiles live in the CHR banks the converted
areas map (R4 = `$19`, R5 = `$13`).  `pb2_spawns.md` §5.1 gives the handler
address, PRG bank, culling class and placement count for each, but says
"behaviour not individually identified" for all of them, so **I identified them
at runtime**: I patched every placement record of Power Blade 2 stage 0 to a
single type (byte 1 of each 4-byte record in every list reached from the stage-0
pointer table `$A14C` in PRG bank 7) and replayed area 0, sampling `$0400,X`
(type), `$0508,X`/`$04F2,X` (screen X), `$04C6,X`/`$04B0,X` (screen Y) and
`$0442,X` (sprite id) for slots 6..`$15`.

| PB2 type | handler | class | n | what it is at runtime | vertical motion |
|---|---|---|---|---|---|
| `$02` | `$83EA` | 0 | 16 | the permanent power-up capsule — an item, gated on the collected bitmap | none |
| `$07` | `$9FDE` | 2 | 8 | pair of blue capsules that **falls** | dY 112-255 |
| `$12` | `$8BED` | 0 | 12 | small white ghost / jellyfish **flyer**, drifts in X and Y | dY ~63 |
| `$13` | `$96AA` | 0 | 31 | white **saucer** that hovers at a fixed height and drops things | dY 0-1 |
| `$17` | `$9DA5` | 1 | 37 | very small pink ground **crawler**, the weakest filler enemy | dY 0 |
| `$1D` | `$8E9D` | 0 | 16 | pink spiked head, **fixed in place** | dY 0 |
| `$1E` | `$A650` | 0 | 8 | tall segmented vertical structure, **fixed** | dY 0 |
| `$22` | `$910D` | 0 | 13 | small pink mushroom head on the ground, **short hops** | dY ~21 |
| `$23` | `$91A2` | 5 | 22 | white/blue robot pod that **leaps** a long way vertically | dY 67-111 |
| `$29` | `$A7AD` | 7 | 12 | spiky floating starburst, **fixed** | dY 0 |
| `$2C` | `$A95C` | 0 | 43 | white/grey **humanoid soldier with a rifle** — walks and shoots | dY 0 |

Screenshots: `QA.png` (`$2C $17 $13 $12 $23 $1D`), `QB.png` (`$29 $1E $07 $02
$22`), and `Q_TT.png` per type.

---

## 4. The type template table `$BDCA` (PRG bank 9)

`type: bhv msLo msHi $0610 $0620 $0630 $0640 $0690 HP`

```
00  01 90 01 00 00 00 00 00 04     18  3A 00 00 00 00 00 00 00 04
01  01 6E 01 00 00 00 00 00 04     19  3B 00 00 00 00 00 00 00 04
02  0B 00 00 00 00 00 00 00 01     1A  3C 00 00 00 00 00 FF 00 03
03  0D B6 01 FF 00 00 00 00 04     1B  3E 00 00 00 00 00 00 00 08
04  0F 00 00 00 00 00 00 00 02     1C  10 00 00 00 00 00 00 00 08
05  11 00 00 00 00 00 00 00 02     1D  3F 00 00 00 00 00 00 00 06
06  12 00 00 00 00 00 00 00 0A     1E  3F 00 00 00 00 04 FF 06 10
07  13 E4 01 00 00 00 00 00 04     1F  3F 00 00 00 00 00 00 2C 01
08  5A 00 00 00 00 00 00 00 20     20  3F 00 00 00 00 00 00 0C 01
09  5E 00 00 00 00 00 00 03 20     21  3F 00 00 00 00 00 00 0E 04
0A  61 00 00 00 00 00 00 00 40     22  3F 00 00 00 00 00 00 10 04
0B  65 00 00 00 00 00 00 03 20     23  3F 00 00 00 00 00 00 12 02
0C  66 00 00 00 00 00 00 00 06     24  3F 00 00 00 00 00 00 14 02
0D  67 00 00 00 00 00 00 00 80     25  3F 00 00 00 00 00 00 16 02
0E  69 F4 02 00 00 00 00 00 50     26  3F C8 03 00 00 00 00 18 02
0F  6B D2 02 46 00 00 00 00 40     27  3F 00 00 00 00 00 00 1A 02
10  6D 00 00 FF 00 00 00 0A 40     28  3F 82 03 00 00 00 00 1C 08
11  6F 18 03 00 00 00 00 00 50     29  3F C6 03 00 00 00 10 1E 01
12  72 1C 03 2B 00 00 00 00 40     2A  3F 00 00 00 00 00 00 20 01
13  35 00 00 00 00 00 00 00 06     2B  3F 00 00 00 00 00 00 22 01
14  36 90 01 00 00 00 00 00 08     2C  28 00 00 00 00 00 00 00 06
15  37 6E 01 00 00 00 00 00 04     2D  18 00 00 00 00 00 00 00 02
16  38 00 00 00 00 00 00 00 06     2E  3F 00 00 00 00 00 00 2A 02
17  39 00 00 00 00 00 00 00 04
```

A `msLo/msHi` of `00 00` means the object starts invisible and gets its
metasprite from whatever animation its handler sets (`$9028` = channel A
`$06A0`, `$904B` = channel B `$06B0`).  Types `$08`-`$12` and `$2A`, `$2B`,
`$2E` are bosses / boss parts and are never placed by a level record.

---

## 5. The dispatch tables

`$81EA` (bank 2, 64 words, index = `$0650 & $3F`, bit 7 clear):

```
00 $B0CC  01 $B0CC  02 $B0CC  03 $B0DC  04 $B11D  05 $B225  06 $B255  07 $B26B
08 $B2AA  09 $B2AE  0A $B0EC  0B $AFBA  0C $AE7B  0D $AA51  0E $AC73  0F $ACB9
10 $8BBA  11 $ACB5  12 $ADC5  13 $B0BB  14 $B0CD  15 $AA41  16 $A7F0  17 $A836
18 $8802  19 $82FB  1A $A511  1B $A53D  1C $A3A8  1D $A3B1  1E $A10B  1F $A047
20 $A031  21 $9E12  22 $9D71  23 $9DAB  24 $9D41  25 $9B05  26 $9B05  27 $9B05
28 $8AA2  29 $9975  2A $99A2  2B $962E  2C $9683  2D $9DE7  2E $A82B  2F $915B
30 $923B  31 $9588  32 $921C  33 $9127  34 $90CA  35 $902D  36 $B0CC  37 $B0CC
38 $8F8D  39 $8E86  3A $8DEB  3B $8CC9  3C $8A33  3D $8CA8  3E $8C40  3F $8398
```

`$827B` (bit 7 set — the death / alternate-form table):

```
00 $A883  01 $A883  02 $A8ED  03 $B0DC  04 $A96C  05 $A96C  06 $B255  07 $B26B
08 $A9F6  09 $A9F6  0A $A96C  0B $AF63  0C $AF23  0D $AF2B  0E $AF23  0F $AF27
10 $8993  11 $AF27  12 $AF2F  13 $A904  14 $B0CD  15 $AA41  16 $A7F0  17 $A836
18 $897E  19 $82FB  1A $A43C  1B $A43C  1C $A987  1D $A3B1  1E $A484  1F $A047
20 $A031  21 $A406  22 $9D71  23 $9DAB  24 $9D41  25 $A3BC  26 $A3FB  27 $9B05
28 $8996  29 $9975  2A $A4A0  2B $962E  2C $A4BD  2D $A406  2E $A82B  2F $915B
30 $923B  31 $9588  32 $921C  33 $9127  34 $90CA  35 $899C  36 $A8B8  37 $A8D3
38 $8F72  39 $8F72  3A $8F72  3B $8F72  3C $8F7B  3D $8F1C  3E $8F7F  3F $8359
```

Behaviour `$3F` second level:

```
8398  LDA $0690,X / TAY / LDA $83A9,Y / STA $90 / LDA $83AA,Y / STA $91 / JMP ($90)

$83A9 (the index in $0690 is already doubled):
  00 -> $86A1   type $1D        14 -> $8566   type $23
  02 -> $86C9   ($1D state 1)   16 -> $8545   type $24
  04 -> $8729   ($1D state 2)   18 -> $84FB   type $25
  06 -> $8767   type $1E        1A -> $84EF   type $26
  08 -> $87AB                   1C -> $84D6   type $27
  0A -> $86A1                   1E -> $84BA   type $28
  0C -> $861C   type $1F        20 -> $849C
  0E -> $85EA   type $20        22 -> $84A0
  10 -> $85EE   type $21        24 -> $83EF
  12 -> $856C   type $22        26 -> $842F / 28 -> $8457 / 2A -> $83D7
                                2C -> $865C   type $29
```

(bit-7 twin: `$8359` with sub-table `$836A`.)

---

## 6. Handler disassembly

Common helpers, established first:

```
$8118  face the player                    $813F  add velocity $50-$53 to the position
$8173  test bit 6 of $0650                $8163/$8179  set a velocity
$80DA  LDA $06E0,X / CMP #$01             $80E0  LDA $06C0,X / CMP #$FF
$80E6  LDA $06D0,X / CMP #$02             $80F2  set $06E0 = $0F/$10 (flash)
$9028  set animation channel A ($06A0)    $904B  set animation channel B ($06B0)
$907B  allocate an enemy shot             $A1C2/$A1D7  write the shot's position
$AE30  distance to the player             $AE5E  distance, other metric
$ADBA  on-screen / line-of-sight check    $B0AA  move-and-test-terrain
$8066  apply gravity                      $8A6D  = JSR $8066 / JMP $813F
```

### `$B0CC` — behaviours `$00 $01 $02 $36 $37` (types `$00 $01 $14`)

```
B0CC  60       RTS
```

### `$B0BB` — behaviour `$13` (type `$07`, screen shake)

```
B0BB  LDA $06E0,X / CMP #$09 / BNE ret
      LDA $05F7 / BNE ret
      LDA #$04 / STA $05F7          ; $CD81 reads $05F7, $CE15,Y -> $05F8 = scroll offset
```

### `$AFBA` — behaviour `$0B` (type `$02`, weak walker)

```
AFBA  LDA $0620,X / CMP #$FF / BNE $AFC4 / JMP $B03B   ; $FF = the "dying" branch
AFC4  JSR $B0AA                      ; try to move; BMI = blocked
AFC7  BMI $AFD6
AFC9  LDA #$08 / STA $0690,X
AFCE  LDA #$FF / JSR $8163           ; walk speed, negative direction
AFD3  JMP $813F                      ; apply it
```

### `$AA51` — behaviour `$0D` (type `$03`, hoverer)

```
AA51  TXA / EOR $0C / AND #$03 / BNE $AA9D      ; act on one frame in four
AA58  SEC / LDA $B0,X / SBC $31 / CMP #$10
AA5F  BCS $AA68                                  ; too far from the camera
AA61  JSR $AE5E / LDA $95 / BMI $AA75            ; player is below -> attack
AA68  LDA $0610,X / BMI $AA9D
AA6D  LDA #$06 / JSR $99D9 / BNE $AA82
AA74  RTS
AA75  LDA #$06 / STA $0610,X
AA7A  JSR $99D9 / BNE $AA82 / JMP $BD9D
AA82  JSR $80E6 ...
```

### `$ACB9` — behaviour `$0F` (type `$04`, stationary shooter)

```
ACB9  LDA #$FF / STA $0680,X                ; always faces left
ACBE  TXA / EOR $0C / ROR A / BCC $ACC5 / RTS
ACC5  LDA $060C / BEQ $AD08                 ; a global "enemies may shoot" flag
ACCA  LDA $0C / AND #$7E / BNE $AD08        ; roughly every 128 frames
ACD0  JSR $ADBA / BMI $AD08                 ; must be on screen
ACD5  LDA $0680,X / ASL A
      LDA #$22 / BCC + / LDA #$E2           ; X velocity by facing
ACDF  STA $07D0,Y
ACE2  LDA #$08 / STA $07E0,Y
ACE7  LDA #$81 / JSR $907B                  ; shot id $81
ACEC  ... copy $A0/$B0/$C0+$80/$D0 into $0790/$07A0/$07B0/$07C0
AD04  LDA #$12 / STA $F1                    ; sound
```

### `$ADC5` — behaviour `$12` (type `$06`, tall walker)

```
ADC5  TXA / EOR $0C / ROR A / BCS $ADCC / RTS      ; every other frame
ADCC  AND #$07 / BNE $ADDF
ADD0  JSR $AE5E / CMP #$02 / BCS $ADDF
ADD7  JSR $AE30 / LDA $94 / JSR $AE27             ; retarget the player
ADDF  LDA $0C / AND #$02 / BNE $AE07
ADE5  JSR $8121 / LDA #$80 / STA $90 / INC $93
ADF0  JSR $B186 / JSR $C00C                       ; terrain probe
ADFA  BPL $AE19
ADFC  SEC / LDA $52 / SBC $9D / STA $52 / BCS + / DEC $53   ; climb/step up
```

### `$902D` — behaviour `$35` (type `$13`)

```
902D  LDA $06A0,X / BNE $8FF8          ; animation running -> the "acting" branch
9032  JSR $80DA / BNE $9041            ; just been hit?
9037  LDA $0650,X / AND #$40 / BNE $9041
903E  JMP $9026                        ; idle animation $58
9041  LDA $0690,X / BNE $9084
9046  JSR $9050 / LDA #$56 ...         ; enter the attack state

8FF8  JSR $9026 / JSR $80EC / BNE + / LDY #$29 / STY $F1     ; step sound
9004  CMP #$01 / BNE $901B
9008  JSR $8121 / LDA #$80 / STA $90 / INC $93
9011  JSR $B170 / BPL $901B
9016  LDA #$20 / JSR $9D0A            ; leap
901B  LDA $06A0,X / BNE + / STA $0690,X
9023  JMP $813F
```

### `$8F8D` — behaviour `$38` (type `$16`)

```
8F8D  LDA $06A0,X / BNE $8FD9
8F92  JSR $80DA / BNE $8F9C / LDA #$5D / JMP $9028     ; hit -> recoil animation
8F9C  TXA / EOR $0C / ROR A / BCC $8FA3 / RTS
8FA3  JSR $810D
8FD9  LDA #$5D / JSR $9028
8FDE  JSR $8118                    ; face the player
8FE1  JSR $9053
8FE4  JSR $AE24 / JSR $B0AA / JSR $AE24
8FED  TYA / BPL $8FF5
8FF0  LDA #$40 / JSR $9D0A         ; leap over the obstacle
```

### `$8E86` — behaviour `$39` (type `$17`, the most common enemy)

```
8E86  LDA $0690,X / ROR A / BCS $8E9F
8E8C  LDA #$5E / JSR $904B          ; walk animation
8E91  JSR $8118                     ; face the player
8E94  JSR $AE5E / CMP #$02 / BCC $8E9C / RTS    ; wait until within 2
8E9C  JMP $8EB3
8E9F  LDA #$5F / JSR $904B          ; fire animation
8EA4  JSR $80E6 / BNE $8EB3         ; only on animation frame 2
8EA9  JSR $ADBA / BMI $8EB3         ; only when on screen
8EAE  LDA #$A1 / JMP $8EBC          ; -> $907B, shot id $A1
8EB3  JSR $80E0 / BNE + / INC $0690,X
```

### `$8DEB` — behaviour `$3A` (type `$18`)

```
8DEB  LDA $0690,X / BEQ $8E31 / CMP #$02 / BCC $8E48 / BEQ $8DD7
8DF6  LDA #$62 / JSR $904B
8DFB  LDA $06C0,X / CMP #$01 / BNE $8E27
8E02  JSR $8FDE                     ; the same face-and-walk block as type $16
8E05  JSR $906C
8E08  LDA $06D0,X / ROR A / BCC $8E24
8E0E  JSR $ADBA / BMI $8E24
8E13  LDA #$A2 / JSR $907B          ; shot id $A2
8E18  JSR $8ECB / LDA #$90 / STA $92 / DEC $93
```

### `$8CC9` — behaviour `$3B` (type `$19`)

```
8CC9  LDA $0690,X / BEQ $8D2D / CMP #$02 / BCC $8D44 / BEQ $8D0B
8CD4  LDA #$66 / JSR $904B
8CD9  JSR $80E6 / BNE $8D24         ; animation frame 2
8CDE  JSR $ADBA / BMI $8D24
8CE3  LDA #$04 / STA $07E0,Y
8CE8  LDA #$A4 / JSR $907B          ; shot id $A4
8CED  LDA #$13 / STA $F1            ; sound
8CF1  JSR $8121 / DEC $93 / DEC $93 / LDA #$80 / STA $90
8CFC  LDA $0680,X / BMI + / DEC $91
8D03  LDA #$D0 / STA $07D0,Y / JMP $A1D7
```

### `$8C40` — behaviour `$3E` (type `$1B`)

```
8C40  LDA #$6A / JSR $904B
8C45  LDA $0640,X / ROR A / BCS $8C57
8C4B  LDA #$04 / STA $50            ; move right
8C4F  LDA $B0,X / CMP #$4B / BCS $8C63 / BCC $8C66
8C57  LDA #$FC / STA $50 / DEC $51  ; move left
8C5D  LDA $B0,X / CMP #$47 / BCS $8C66
8C63  INC $0640,X                   ; flip direction at the span ends
8C66  JSR $80EC / BEQ $8C7C / CMP #$01 / BEQ $8C7C
8C6F  LDA $50 / STA $0610,X / LDA $51 / STA $0620,X / JMP $813F
8C7C  JSR $ADBA / BMI $8C6F
8C81  TXA / STA $07D0,Y / LDA #$04 / STA $07E0,Y     ; drop a shot
```

### `$8802` — behaviour `$18` (type `$2D`)

```
8802  TXA / EOR $0C / ROR A / BCS $8809 / RTS   ; every other frame
8809  LDY $0690,X
880C  LDA $8819,Y / STA $90 / LDA $881A,Y / STA $91 / JMP ($90)
```

### `$8AA2` — behaviour `$28` (type `$2C`, the big beast)

```
8AA2  LDY #$40 / JSR $906E
8AA7  LDA $06A0,X / BNE $8A84
8AAC  JSR $8173 / BNE $8AC1          ; $0650 bit 6
8AB1  JSR $80DA / BNE $8AC1
8AB6  JSR $B21C / JSR $8118 / LDA #$7B / JMP $9028
8AC1  LDA #$7A / JSR $904B
8AC6  JSR $AE30 / CMP #$0E / BCC + / JSR $906C     ; charge when far away
8AD0  JSR $8AE1 ...

8A84  LDA #$7B / JSR $9028
8A89  LDA $06A0,X / BNE $8A9A
8A8E  LDA $0E / ROR A / LDA #$02 / BCC + / LDA #$05
8A97  STA $0690,X
8A9A  LDA #$40 / JSR $8179 / JMP $813F
```

### `$86A1` — `$3F`/`$00` (type `$1D`)

```
86A1  LDA #$6C / JSR $904B
86A6  JSR $AE5E / JSR $8118 / JSR $80E0 / BNE ret
86B1  LDA $91 / CMP #$08 / BCS ret            ; only when close
86B7  LDA $95 / BMI $86C3
86BB  LDA $93 / CMP #$02 / LDA #$02 / BCS +
86C3  LDA #$04
86C5  STA $0690,X                              ; -> state $86C9 or $8729
```

### `$8767` — `$3F`/`$06` (type `$1E`, invisible spawner)

```
8767  DEC $0640,X / BNE $8793
876C  TXA / EOR $0C / TAY / AND #$03 / BNE $878E
8774  LDA #$2F / STA $F1                      ; sound
8778  TYA / AND #$07 / BNE $878E
877D  LDY #$EA / JSR $AAF1                    ; <<< spawn a child
8782  DEC $0630,X / BNE $878E
8787  LDA #$07 / STA $0630,X / BNE $879A      ; recharge, 7 children per cycle
878E  INC $0640,X / BNE $879A
8793  LDA $0640,X / CMP #$30 / BCC $879D
879A  JMP $87A2
879D  LDA #$6F / JMP $904B                    ; visible animation
87A2  LDA #$00 / STA $0660,X / STA $0670,X    ; <<< blank itself = invisible
```

### `$861C` — `$3F`/`$2C` (type `$1F`, ceiling faller)

```
861C  LDA $0640,X / BEQ $864E
8621  LDA #$73 / JSR $904B
8626  LDA $0C / ROR A / BCC $865B
862B  AND #$03 / BNE + / JSR $802B
8632  JSR $8066                                ; gravity
8635  LDA $D0,X / CMP #$6B / BCS $8644         ; floor of the room
863B  LDA $53 / BPL $8644
863F  JSR $8133 / BEQ $864B
8644  LDA $53 / ASL A / ROR $53 / ROR $52      ; halve the fall speed
864B  JMP $813F
864E  LDA #$72 / JSR $904B / JSR $80E0 / BNE + / INC $0640,X
```

### `$85EA` / `$85EE` — `$3F`/`$0C` and `$3F`/`$0E` (types `$20` / `$21`, blowers)

```
85EA  LDA #$00 / BEQ $85F0        ; type $20: faces right
85EE  LDA #$FF                    ; type $21: faces left
85F0  STA $0680,X
85F3  LDA #$74 / JSR $904B
85F8  JSR $AE2D                   ; direction + distance to the player
85FB  LDA $93 / CMP #$02 / BCS ret          ; must be within 2
8601  LDA $94 / EOR $0680,X / BMI ret       ; player must be on the blown side
8608  LDA $0680,X / ASL A / LDY #$00
860E  LDA #$10 / BCS + / LDA #$F0 / DEY
8615  STA $05A8 / STY $05A9                 ; <<< signed push impulse on the player
```

### `$856C` / `$8566` — `$3F`/`$10` and `$3F`/`$12` (types `$22` / `$23`, spread guns)

```
8566  LDY #$76 / LDA #$FF / BNE $8570       ; type $23: faces left, animation $76
856C  LDY #$75 / LDA #$00                   ; type $22: faces right, animation $75
8570  STA $0680,X
8573  TYA / JSR $904B
8577  JSR $80E6 / BNE $857F / JMP $80F2     ; not on the firing frame -> flash timer
857F  CMP #$03 / BNE ret
8583  INC $0640,X / LDA $0640,X / ROR A / BCS $859F
858C  LDY #$00 / JSR $85AB   ; four shots on even cycles
      LDY #$01 / JSR $85AB
      LDY #$02 / JSR $85AB
      LDY #$03 / BNE $85AB
859F  LDY #$04 / JSR $85AB   ; three shots on odd cycles
      LDY #$05 / JSR $85AB
      LDY #$06
85AB  LDA $85BD,Y / STA $94 / LDA $85B8,Y / STA $95 / JMP $85C4
85C4  LDA #$2C / STA $F1     ; sound, then allocate the shot
```

### `$8545` — `$3F`/`$14` (type `$24`, single-shot turret)

```
8545  LDA #$77 / JSR $904B
854A  LDA $06D0,X / ROR A / BCS ret
8550  JSR $ADBA / BMI ret
8555  LDA #$AC / JSR $907B          ; shot id $AC
855A  STA $07D0,Y / LDA #$04 / STA $07E0,Y
8562  JMP $A1C2                     ; shot position = own position
```

### `$84FB` — `$3F`/`$16` (type `$25`, falling crusher)

```
84FB  LDA $0620,X / BNE $8514
84FE  JSR $AE30 / CMP #$03 / BCS $850E     ; player within 3 -> trigger
8507  LDA #$3C / STA $F1 / DEC $0620,X     ; $0620 goes $00 -> $FF
850E  LDA #$0F / STA $06E0,X / RTS
8514  BPL $853F
8516  JSR $B0AA / JSR $87CD / BPL $8538    ; has it hit the ground?
851E  LDA #$07 / STA $05F7                 ; <<< screen shake
8523  STA $C0,X / JSR $A937
8528  LDY #$BD / JSR $AAF1                 ; spawn debris
852D  LDA $33 / STA $D0,X                  ; snap back to the ceiling
8531  LDA #$70 / STA $0620,X               ; re-arm after $70 frames
8538  LDA #$40 / STA $52 / JMP $813F       ; otherwise keep falling
```

### `$84EF` — `$3F`/`$18` (type `$26`, animated prop)

```
84EF  TXA / EOR $0C / ROR A / BCS ret
84F5  LDA #$78 / JMP $904B
```

### `$84D6` — `$3F`/`$1A` (type `$27`, flame jet)

```
84D6  JSR $AE30 / CMP #$04 / BCC $84DE / RTS   ; dormant unless the player is near
84DE  TXA / EOR $0C / ROR A / BCC $84DD
84E4  JSR $8043 / EOR #$20 / STA $0610,X
84EC  JMP $8A6D          ; = JSR $8066 / JMP $813F  (grow the flame)
```

### `$84BA` — `$3F`/`$1C` (type `$28`)

```
84BA  LDA $0C / AND #$0F / BNE $84C6
84C0  INC $0610,X / JSR $8A6D              ; one step every 16 frames
84C6  JSR $AE30 / BNE $84D3
84CB  JSR $AE5E / BNE $84D3
84D0  JSR $80BF                            ; adjacent -> attack
84D3  JMP $813F
```

### `$865C` — `$3F`/`$2C` (type `$29`, top-of-screen bombardier)

```
865C  LDA $33 / STA $D0,X                  ; Y high = camera Y high (pin to the top)
8660  CLC / LDA $0E / AND #$0F / ADC $31 / STA $B0,X   ; X high = camera + jitter
8669  TXA / EOR $0C / AND #$3F / BNE ret   ; once every 64 frames
8670  PHA
8671  LDA $55 / CMP #$01 / BNE + / LDA $31 / CMP #$70 / BCS $8689
867D  LDA $55 / CMP #$02 / BNE $868D / LDA $33 / CMP #$90 / BCS $868D
8689  PLA / JMP $80B9                      ; suppressed in those camera regions
868D  JSR $ADBA / BMI ret
8692  LDA #$AF / JSR $907B / JSR $A1C2     ; shot id $AF at own position
869A  LDA #$40 / STA $07D0,Y               ; downward velocity
```

---

## 7. Method, and what to distrust

**Stage jumping.**  `-poke 0055=NN` and `-freeze 0055=NN` both break the game
(it either sticks on or bounces back to STAGE SELECT).  What works is a ROM
patch: `$D1B7` is redirected to a stub at `$FF50` (`A9 01 85 55 4C B9 F8`) that
forces `$55 = 1` so the STAGE SELECT screen appears, **and** `$DD58[0..5]` is
overwritten with the wanted stage id so any START on that screen launches it.
(`$DCBB LDX $4E / LDY $DD5E,X / LDA $DD58,Y / STA $55`; stock `$DD58` =
`0A 03 04 06 01 0F`, `$DD5E` = `00 04 01 02 04 03`.)  Every run below used that
patch, plus `-freeze 05C2=7F` to keep the player invulnerable.  `$55` was
verified to hold `01..0F` and the levels are visibly distinct.

**Type override.**  To see a type that only appears in a hard-to-reach stage, the
same patcher rewrites byte 1 of every 6-byte placement record of a stage to a
chosen type.  Since `$BDCA` is a global table, the behaviour is identical to the
real thing.  The *graphics* are only correct when the type's metasprite record
has an explicit CHR bank (byte 0 != `$00`).  Types `$03 $04 $2D $16 $17 $23 $24
$28` have byte 0 = `$00` and therefore borrow the host stage's CHR — for those,
the sizes and positions in `Z_00_*.png` are right but the tiles are garbage, so
they were re-shot in a stage that really uses them (`Z_01_16`, `Z_01_17`,
`Z_04_13`, `Z_04_22`, `Z_06_26`) or their size was taken from the decoded tile
list instead.

**Stages 5, 7 and 15 could not be walked into.**  Their objects are above or
below the start point and a plain walk-right script never reaches them; the
camera is clamped per room, so teleporting the player (`$80-$83`) does nothing
until the camera (`$30-$33`) is teleported too, and even then the spawn scan
`$AE7C` is gated by `$05EC`, `$36/$37` and `$05A2`, which the room state machine
at `$93B5`/`$ADD8` drives.  The type-override route was used instead; every type
in the table has runtime evidence from *some* stage.

**Tooling gotchas.**
* A file named `dis.py` anywhere on `sys.path` shadows the stdlib `dis`
  module and makes `import PIL` fail with
  `AttributeError: module 'dis' has no attribute 'COMPILER_FLAG_NAMES'`.  The
  one in the repo is now `work/tools/disasm.py`, so the trap is gone, but a
  scratch `dis.py` lays it again.
* `-watch` only prints when `-trace` is also given.  Use
  `-tracepc FFFE-FFFE` as a dummy so the trace file stays tiny.
* Only the **last** `-watch` flag is honoured; `-freeze` and `-poke` may be
  repeated (256 each).

**Least certain rows.**  `$1F` — the handler reads as "falls under gravity", but
in stage 1 it was observed as an invisible object pinned at the ceiling whose
children are small cyan flyers; both are consistent with a ceiling dropper, but
which sprite the *parent* ever shows is unresolved.  `$1B` patrols between fixed
world coordinates `$47` and `$4B`, so it is scripted to one specific room of
stage 15/16 and the "moving barge" reading is an interpretation, not a proof.
The `$05A8/$05A9` write in `$85EA`/`$85EE` is read as a push impulse on the
player from its shape (signed 16-bit, magnitude 16, sign follows facing); it was
not confirmed by watching the player move.

---

## 8. The mapping

```python
# Solbrain object type  ->  closest Power Blade 2 type.
# PB2 types restricted to those whose tiles are in the CHR banks the converted
# areas map (R4=$19, R5=$13).  See work/re/sol_enemy_types.md for the evidence.
SOL_TO_PB2 = {
    # --- ground soldiers -> PB2 $2C, the rifle-carrying humanoid ------------
    0x17: 0x2C,  # 145x. Walks up, stops, fires. PB2 $2C does exactly this.
    0x18: 0x2C,  #  76x. Walks and fires (shot $A2). Same role, keeps firing.
    0x16: 0x2C,  #  67x. Walks at you and melees; $2C is the same silhouette,
                 #       trades the club for a rifle. Closest humanoid available.
    0x19: 0x2C,  #  34x. Humanoid that throws a projectile (shot $A4).

    # --- flyers / hoverers ---------------------------------------------------
    0x03: 0x13,  # 102x. Hovers above the player and attacks downward.
                 #       PB2 $13 is the saucer that holds altitude and drops.
    0x29: 0x12,  #   9x. Pinned to the top of the screen, drops a shot every 64
                 #       frames. PB2 $12 is the only free-roaming flyer (dY~63).
    0x1F: 0x12,  #   6x. Ceiling object that falls / releases small flyers.
                 #       $12 keeps the "small thing coming down at you" read.

    # --- small ground fillers ------------------------------------------------
    0x02: 0x17,  #  60x. Dies in one hit; PB2 $17 is the weakest ground filler.
                 #       (Solbrain's is visually bigger, 32x40 vs ~8x8.)
    0x2D: 0x22,  #  79x. Small ground enemy that walks and hops; PB2 $22 hops
                 #       on the ground (dY~21) and is the same size class.
    0x28: 0x22,  #  57x. Slow ground enemy, one step per 16 frames, 24x24.
                 #       $22 is the closest slow ground creature.

    # --- heavy ground robots -> PB2 $23, the leaping robot pod ---------------
    0x2C: 0x23,  #  30x. 40x40 four-legged beast that charges and ignores
                 #       culling; $23 is the biggest, most mobile ground unit.
    0x13: 0x23,  #  16x. 32x40 humanoid fighter with a leap attack ($9D0A #$40).
    0x1D: 0x23,  #  16x. 33x40 armoured robot with idle/approach/attack states.

    # --- fixed guns and props -> PB2 $1D, the stationary spiked head ---------
    0x23: 0x1D,  #  40x. Wall gun firing a 7-way spread, 16x8, never moves.
    0x24: 0x1D,  #  36x. Stationary single-shot turret, 16x8.
    0x22: 0x1D,  #   3x. Mirror of $23 (faces right).
    0x26: 0x1D,  #  27x. Stationary animated prop; $1D also just sits there.
    0x04: 0x1D,  #   9x. Stationary horizontal shooter, never moves.

    # --- tall / wide fixed structures -> PB2 $1E ----------------------------
    0x06: 0x1E,  #  39x. 18x56 tall slow walker; $1E is the tall vertical piece
                 #       and is the only stand-in with that aspect ratio.
    0x1B: 0x1E,  #   6x. 48x24 patroller bolted to a 4-tile span of one room.

    # --- hazards that push or burn -> PB2 $29, the fixed spiky floater -------
    0x27: 0x29,  #  40x. Floor flame jet that ignites when you come close.
    0x20: 0x29,  #  18x. Fixed vent that pushes the player right ($05A8=+$10).
    0x21: 0x29,  #   9x. Same, pushing left.

    # --- things that fall -> PB2 $07, the falling capsule pair ---------------
    0x25: 0x07,  #  29x. Invisible trigger: drops a crusher, shakes the screen,
                 #       re-arms. PB2 $07 is the falling hazard (dY 112-255).
    0x1E: 0x07,  #  24x. Invisible spawner that emits 7 children per cycle;
                 #       $07 is the closest "something drops on you".

    # --- invisible inert markers: PREFER TO DROP THESE ENTIRELY -------------
    0x00: 0x02,  #  21x. Handler is RTS, metasprite record FF 00 00 00, no
                 #       hitbox. PB2 $02 (the gated power-up capsule) is the
                 #       least intrusive filler; better: skip the placement.
    0x01: 0x02,  #   3x. Same, always sits directly above an $07.
    0x14: 0x02,  #  12x. Same.
    0x07: 0x02,  #   3x. Invisible; its only effect is $05F7=4 (screen shake).
                 #       Nothing in PB2 does this; skip, or re-implement the
                 #       shake directly in the converted area script.
}
```
