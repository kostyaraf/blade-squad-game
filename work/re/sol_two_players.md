# Tokkyuu Shirei Solbrain — adding a genuine simultaneous second player

Companion to `work/re/pb2_two_players.md`; same questions, same format, so the two
engines can be compared number for number. Measurements B and C of
`docs/ver2_spec.md` §2.1.

**Short answer:** in Solbrain a second player is **cheap** — much cheaper than in
Power Blade 2. A working probe (two independently pad-controlled characters on
screen) is **131 bytes of new 6502 code and one patched `JSR`**, built by
`work/tools/e0/probe_sol.py` into `work/build/probe_sol.nes`. See §7–§8.

Method note: everything below is measured on a full linear sweep of all 16 PRG
banks plus a recursive-descent CFG plus live traces, not on hand-made `.asm`
files. Tools: `work/tools/e0/sol_scan.py` (71 139 decoded memory-operand
instructions), `work/tools/e0/sol_cfg.py` (13 905 addresses proven to be code),
`work/tools/e0/sol_report.py`, `work/tools/e0/dis.py`. Two columns are reported
everywhere: **conf** = instruction address is in the proven-code set (lower
bound), **lin** = instruction is on a self-synchronising linear-sweep alignment
(upper bound, includes data misdecoded as code).

---

## 1. Per-frame call chain down to the player update

Bank 14 is fixed at `$C000`, bank 15 at `$E000`. Gameplay frame, bank 14:

| addr | call | what |
|---|---|---|
| `$CD90` | `JSR $C882` | read both controllers |
| `$CD93` | `JSR $C72D` | — |
| `$CD99` | `JSR $C946` | — |
| `$CD9C` | `JSR $F1EA` | camera X |
| `$CD9F` | `JSR $F24B` | camera Y |
| `$CDA2/$CDA5` | `JSR $EC44/$EC2B` | — |
| `$CDAB` | `JSR $EA9C` | — |
| `$CDB3` | `JSR $8016` → b8 `$93B5` | room id / scroll script |
| `$CDBB` | `JSR $8019` → b8 `$AE69` | object spawning |
| `$CDBE` | `JSR $8010` → b8 `$80DE` | — |
| **`$CDD2`** | **`JSR $8007` → b12 `$9150`** | **player** |
| `$CDDA` | `JSR $800A` → b2 `$B2E9` | — |
| `$CDDD` | `JSR $CE1D` | enemy loop, `LDX #$0B` down to 0 |
| `$CDE0` | `JSR $F806` | — |

And bank 12 `$9150` is three instructions:

```
12:9150  20 59 91  JSR $9159     ; the player
12:9153  20 68 B1  JSR $B168     ; the player's projectiles
12:9156  4C 89 A4  JMP $A489     ; the satellite
```

`$9159` is called **from exactly one place in the whole ROM**. That single call
site is the hook the probe uses.

Inside `$9159` the interesting part is the frame prologue `12:$9477`: it zeroes
`$05B6-$05B9` and `$50-$53`, `INC $05A3`, `$05CE += 4`, masks `$06`/`$04`, then

```
12:94D2  JSR $94FA   ; terrain probe
12:94D5  JSR $9689   ; state dispatch
12:94D8  JSR $9AA5   ; speed/acceleration
12:94DB..94F9        ; position += displacement  (see §5)
```

State dispatch `12:$9689` is `LDA $05A2 / ASL / TAX / LDA $96C0,X → $90 /
LDA $96C1,X → $91 / JMP ($0090)`; the table at `$96C0` has 21 entries
(`$00→$9ED3` ground, `$01→$A005` jump, … `$12→$9729` warp-in descent,
`$13→$9751` warp-in landing, `$14→$9783`).

---

## 2. Sprite (OAM) output

**The composer is completely player-agnostic.** Entries `15:$F3DC / $F3E5 /
$F3F0 / $F3F9` (reached through bank-14 trampolines `$C003/$C006/$C009/$C00C`).

* `15:$F43F` converts a 12.4 world position held in `$90-$93` to screen pixels.
  The caller puts *any* position there — nothing in the composer knows about
  "the player".
* `15:$F461` looks up the metasprite record.
* Sprite budget: `15:$F4D0 LDA $6A / CMP #$3A / BCS $F4E1` — **58 of the 64
  hardware sprites**; above that the object is silently dropped.
* `15:$F5B8-$F5CB` writes `$0200,X … $0203,X`, `INC $6A`, X += 4 with wraparound
  to `$30`. Cursors `$6C`/`$6D` alternate on the parity of `$6B` (flicker).

**Measured headroom with two players drawn** (probe ROM, stage 1 opening room):
`$6A` = 19…26. That is 32…39 sprites of headroom. Крупные комнаты не
проверялись — **НЕ ПРОВЕРЕНО** for crowded rooms/bosses.

---

## 3. Input

Bank 14, `$C8A2`:

```
$C8A4  STA $4016 (1) / STA $4016 (0)      strobe
$C8AC..$C8F3   LDA $4016  x8   D0 -> ROL $90 , D1 -> ROL $92
$C8F4..        LDA $4017  x8   D0 -> ROL $91
```

Then `$C882` post-processes:

```
$92 = $92 | $90                 ; pad 1 held  (D0 or D1 of $4016)
$04 = ($92 EOR $06) AND $92     ; pad 1 newly pressed
$06 = $92                       ; pad 1 held
$05 = ($91 EOR $07) AND $91     ; pad 2 newly pressed
$07 = $91                       ; pad 2 held
```

Bit layout (same for both): b7 A, b6 B, b5 Select, b4 Start, b3 Up, b2 Down,
b1 Left, b0 Right.

* **Port 2 is fully read every frame and the result is thrown away.** In the
  proven-code set `$05` and `$07` have **no readers at all** outside `$C882`
  itself: the three candidate hits (`12:906C ASL $05`, `14:CC9D STA $05`,
  `15:E1C4 CMP $05`) all disassemble as misaligned data when the surrounding
  bytes are decoded correctly. Exactly the same situation as Power Blade 2.
* Consequence: the probe does not have to touch the controller code at all —
  pad-2 state is already sitting in `$05`/`$07` waiting to be used.

---

## 4. Complete player context

Established by (a) stack-scoped trace analysis of everything reached from
`12:$9150`, (b) a read-before-write analysis of two consecutive player passes in
the probe, (c) the probe itself: with exactly this set swapped, two players run
independently; with `$35` left out, they fight over one velocity (§8).

### 4a. The block `$05A2-$05CE` (45 bytes) — the player object

The player is **not** a slot of any object array. It is one contiguous
private block. Semantics of the fields that were identified:

| addr | meaning |
|---|---|
| `$05A2` | state index, 0…`$14`, dispatched through `$96C0` |
| `$05A3` | per-frame counter (`INC`, saturating at `$FF`) |
| `$05A4` | animation delay; `$FF` = animation finished/frozen |
| `$05A5` | airborne flag (0 = on ground) |
| `$05A6`,`$05A7` | hurt-box / damage state (read by `2:8457`, `8:8133`) |
| `$05A8`,`$05A9` | movement flags (written by `2:8615/8618`) |
| `$05AB` | state sub-timer (`DEC` in states `$12/$13/$0C`) |
| `$05AC` | counter (`8:9BD7 INC $05AC`) |
| `$05AD`,`$05AE` | 16-bit accumulator (`9:A73F/A747`) |
| `$05AF` | action lock; **non-zero blocks the warp-in→ground transition** at `12:$9741` |
| `$05B2` | facing (bit 7), set at `12:$9B6D` |
| `$05B4` | animation frame index |
| `$05B5` | current animation id (compared at `13:$B7BA`) |
| `$05B6`,`$05B7` | X displacement for this frame (signed 16-bit) |
| `$05B8`,`$05B9` | Y displacement for this frame (signed 16-bit) |
| `$05BA`-`$05C1` | **the only indexed sub-array in the block** — 8 entries, `$05BA,X`, weapon/energy counters (`10:$854D/$8554/$855B/$85B1/$85C0/$85D5`, cleared by `15:$F841`) |
| `$05C2` | suit/weapon mode (26 bare reads; gates lots of behaviour) |
| `$05C3`,`$05C4` | НЕ ПРОВЕРЕНО (`$05C3` read by camera Y `15:$F251`) |
| `$05C5`,`$05C6`,`$05C7` | HUD/timer-ish, also read by `15:$E2AB/$E2CE/$E2D3` and `14:$CDEA` — **shared-looking, see risks** |
| `$05C8`-`$05CD` | НЕ ПРОВЕРЕНО (counters; `$05CB` has 25 bare accesses across b8/b9/b12/b13/b14) |
| `$05CE` | step/animation accumulator, `+= 4` each frame, clamps to `$FC` |
| `$05AA`,`$05B0`,`$05B1`,`$05B3`,`$05C0` | no confirmed accesses — padding or unused |

### 4b. Zero page

| addr | meaning | in the swap set? |
|---|---|---|
| `$80`,`$81` | player world X, 12.4 fixed point (lo,hi) | **yes** |
| `$82`,`$83` | player world Y, 12.4 | **yes** |
| `$35` | horizontal speed, signed, clamped to ±`$16` at `12:$9C60` | **yes** — this is the one player variable that lives outside the `$05A2` block, and it is the reason the first probe attempt failed (§8) |
| `$04`,`$06` | pad-1 pressed/held | **yes** (exchanged with `$05`/`$07`) |
| `$30`-`$33` | camera X/Y (12.4) | no — genuinely shared |
| `$38`-`$3F` | camera clamps from the area header | no — shared |
| `$0C` | sound request bits | no — shared |
| `$50`-`$53`, `$90`-`$97`, `$9A`,`$9B`, `$9E`,`$9F` | scratch, fully recomputed inside every player pass | no — harmless |
| `$6A`-`$6D` | OAM cursors / sprite count | no — shared, must stay shared |
| `$12`-`$15`, `$47`, `$55`, `$70` | frame/stage/bank globals | no |

Verified empirically: a read-before-write scan of both player passes in the probe
lists exactly `$04 $06 $0C $12 $13 $14 $15 $30 $31 $32 $33 $35 $47 $55 $6A $6B
$6C $6D $70 $80 $81 $82 $83` (plus `$3A/$3B` in one pass only, i.e. scratch).
Everything else the player code touches in zero page it writes before reading.

### 4c. Must NOT be swapped

Camera `$30-$33`/`$38-$3F`, OAM cursors `$6A-$6D`, sound `$0C`, stage `$55`, the
enemy pool `$0600-$06FF` and `$00A0/$00B0/$00C0/$00D0,X`, the projectile pool
`$0700-$0777`, the satellite (object slot `$0C`), and the punch hitbox (object
slot `$0F`).

---

## 5. Fixed vs. indexed addressing — the key number

Counts over the whole 128 KB PRG, per field, `bare` = absolute/zero-page without
an index register, `idx` = `,X`/`,Y`.

### 5a. The player block `$05A2-$05CE`

| | conf bare | conf idx | lin bare | lin idx |
|---|---|---|---|---|
| **all 45 bytes, total** | **434** | **8** | **687** | **17** |
| — of which writes | 167 | 5 | | |
| — of which reads | 275 | 3 | | |

**All 8 confirmed indexed accesses are the `$05BA,X` weapon sub-array
(`10:$854D/$8554/$855B/$85B1/$85C0/$85D5`, `15:$F841`) plus one level-init clear
loop `15:$F8C5 STA $05C2,X`.** Every other access in the ROM — all 434 of them —
is absolute.

Per-field, by bank (conf bare / conf idx):

| field | conf bare | conf idx | banks |
|---|---|---|---|
| `$05A2` | 40 | 0 | b2:1 b8:1 b9:2 b12:21 b13:15 |
| `$05A3` | 25 | 0 | b3:1 b8:4 b9:1 b12:14 b13:3 b14:2 |
| `$05A4` | 12 | 0 | b2:1 b12:5 b13:6 |
| `$05A5` | 11 | 0 | b12:5 b13:6 |
| `$05A6` | 7 | 0 | b2:1 b8:2 b12:3 b13:1 |
| `$05A7` | 5 | 0 | b2:1 b8:2 b12:1 b13:1 |
| `$05A8` | 7 | 0 | b2:1 b12:4 b13:2 |
| `$05A9` | 9 | 0 | b2:1 b12:6 b13:2 |
| `$05AB` | 4 | 0 | b12:4 |
| `$05AC` | 9 | 0 | b8:2 b12:1 b13:6 |
| `$05AD` | 12 | 0 | b9:2 b12:2 b13:8 |
| `$05AE` | 13 | 0 | b9:2 b12:2 b13:9 |
| `$05AF` | 7 | 0 | b2:1 b12:6 |
| `$05B2` | 21 | 0 | b8:5 b12:8 b13:8 |
| `$05B4` | 9 | 0 | b12:2 b13:7 |
| `$05B5` | 4 | 0 | b2:1 b13:3 |
| `$05B6` | 22 | 0 | b12:7 b13:12 b14:1 b15:2 |
| `$05B7` | 23 | 0 | b12:5 b13:13 b14:1 b15:4 |
| `$05B8` | 30 | 0 | b12:7 b13:18 b14:4 b15:1 |
| `$05B9` | 20 | 0 | b12:4 b13:12 b14:2 b15:2 |
| `$05BA` | 0 | **7** | b10:6 b15:1 |
| `$05C2` | 26 | 1 | b3:1 b8:6 b12:13 b13:6 b15:1 |
| `$05C3` | 8 | 0 | b2:1 b3:1 b12:4 b13:1 b15:1 |
| `$05C4` | 2 | 0 | b12:2 |
| `$05C5` | 23 | 0 | b8:4 b12:13 b13:1 b14:2 b15:3 |
| `$05C6` | 7 | 0 | b3:2 b12:2 b14:2 b15:1 |
| `$05C7` | 5 | 0 | b3:1 b12:2 b14:1 b15:1 |
| `$05C8` | 8 | 0 | b8:2 b12:5 b13:1 |
| `$05C9` | 7 | 0 | b12:3 b13:4 |
| `$05CA` | 3 | 0 | b9:1 b12:2 |
| `$05CB` | 25 | 0 | b8:3 b9:1 b12:5 b13:14 b14:2 |
| `$05CC` | 3 | 0 | b8:1 b12:2 |
| `$05CD` | 9 | 0 | b3:1 b8:1 b9:2 b12:5 |
| `$05CE` | 18 | 0 | b12:18 |

### 5b. Position and speed in zero page

| field | conf bare | conf idx | lin bare | lin idx | banks (conf) |
|---|---|---|---|---|---|
| `$80` | 28 | 1 | 94 | 10 | b2:3 b3:3 b8:1 b9:2 b12:4 b13:11 b14:3 b15:2 |
| `$81` | 32 | 0 | 103 | 1 | b2:3 b3:3 b8:2 b9:2 b12:7 b13:11 b14:2 b15:2 |
| `$82` | 25 | 0 | 98 | 21 | b2:3 b3:2 b8:3 b9:1 b12:4 b13:9 b14:1 b15:2 |
| `$83` | 30 | 0 | 76 | 9 | b2:3 b3:2 b8:3 b9:1 b12:7 b13:11 b14:1 b15:2 |
| `$35` | 35 | 0 | 72 | 77 | b8:2 b12:28 b13:5 |

The `lin idx` column for `$80-$83`/`$35` is noise: those zero-page cells are also
generic scratch (`($90),Y` pointers, `$80,X` loops in unrelated code), and the
linear sweep cannot tell the uses apart. `conf idx` = 1, and that single hit
(`3:A908 NOP $80,X`) is a misdecode.

### 5c. The decisive fact

**The player's world position is written by exactly 4 instructions in the whole
proven-code set**, all inside one routine:

```
12:94DB  CLC
12:94DC  LDA $05B6 / ADC $80 / STA $80
12:94E3  LDA $05B7 / ADC $81 / STA $81
12:94EB  LDA $05B8 / ADC $82 / STA $82
12:94F3  LDA $05B9 / ADC $83 / STA $83
```

(plus 4 more at level entry, `15:$E710/$E715/$E721/$E726`, seen live in traces).
Everything else in the engine only *reads* `$80-$83`. That, plus the fact that
the player's whole mutable state is one 45-byte block + 5 zero-page bytes, is why
the swap trick works here and does not work in Power Blade 2.

**Comparison with Power Blade 2** (`pb2_two_players.md` §4b/§5): there the player
is **slot 0 of a 22-slot object array with 29 parallel field tables**
(`$0400,$0416,…,$0668`, stride `$16`). Its fields are written absolutely too, but
those same bytes are also the array that every enemy lives in, so a swap has to
move 29 bytes at stride 22 *and* the free-slot allocator has to be taught to skip
the second player's slot, *and* every enemy AI pass would double-step. In
Solbrain the player shares nothing with the object pool at all.

---

## 6. Where the rest of the engine hardcodes "the player"

Confirmed-code accesses to player state from banks **other than 12/13** (the
player's own pair):

```
total sites                                   152
grouped into contiguous code clusters          39
by bank:  b2:21  b3:17  b8:42  b9:17  b10:6  b14:24  b15:25
```

For comparison, inside the player's own banks 12/13 there are **406** such
accesses — those all move for free with the context swap.

Of the 39 outside clusters, **15 read the player's *position*** `$80-$83`, i.e.
they are the genuine "compare something against the player" sites:

| site | what it is |
|---|---|
| `2:8043-804F` | copies player `$80-$83` → `$90-$93` and object slot X → `$94-$97`, then `JMP $C051` (overlap test) — the generic player-vs-object collision helper |
| `2:8418-8452` | same for object slot 7 (`$AAFA`); `2:8446` also copies player position *into* an object slot |
| `2:8457` | object-hurts-player: builds the player's hitbox from `$05A6/$05A7` |
| `3:A569` | enemy uses player `$81` |
| `3:AB5B-AB5F` | enemy AI: facing/targeting on player X |
| `3:AC9B-AC9F` | enemy AI: facing/targeting on player Y |
| `3:AE32-AE66` | enemy AI: full 16-bit `SBC $80/$81/$82/$83` distance |
| `8:80FC-812E` | spawn/placement maths against the player position |
| `8:9D4A-9D5A` | scroll script: tests player Y/X against room thresholds |
| `9:A805-A817` | reads all four position bytes |
| `9:AF8E-AF92` | newly spawned object faces the player |
| `14:CC66-CC85` | player position → `$90-$93` helper; projectile-0-vs-player |
| `14:CD61` | `EOR $80` |
| `15:F328-F342` | **camera X dead-zone** (`SBC $80/$81`, `LDA $80/$81`) |
| `15:F3BB-F3D0` | **camera Y dead-zone** (`CMP $82`, `SBC $83`) |
| `3:A908` | misdecode, not real |

### The camera is much friendlier than PB2's

`15:$F1EA` (X) and `15:$F24B` (Y) do **not** read the player's absolute position.
They read the flag `$05D8` and add the player's *displacement* `$05B6/$05B7` /
`$05B8/$05B9` to `$30/$31` / `$32/$33`, then clamp to `$38-$3B` / `$3C-$3F`
(area-header limits). `$05D8` is produced by `$F2C8`/`$F352`, and only those two
routines (4 clusters, `$F328/$F33C/$F3BB/$F3CC`) compare the player's absolute
position against a dead-zone.

So making the camera follow two players is a change in **two routines**, not in
scattered `LDA $0508` sites as in Power Blade 2.

### What would have to change for a full co-op mode

* **Player code (banks 12/13, 406 accesses): zero edits.** The context swap
  covers all of it. Proven by the probe.
* **Camera (2 clusters, `15:$F2C8`/`$F352`): rewrite the dead-zone test to use a
  midpoint / bounding box of the two players.** ~40–60 bytes of new code.
* **Enemy-vs-player (11 clusters in b2/b3/b8/b9/b14): each has to be run against
  both players, or alternated.** These are choke points, not scattered writes:
  `2:$8043` and `14:$CC66` are *helpers* that load the player position into
  `$90-$93` — patching those two to take a "which player" byte covers most of the
  enemy side, because the enemy AI routines in b3/b9 call through them. The 4
  direct `SBC $80` sites in `3:$AE32` and the facing tests in `3:$AB5B`/`3:$AC9B`
  need individual handling (pick the nearer player).
* **Damage to P2 (`2:$8457`)**: currently the object-hurts-player test is called
  once per frame from the enemy loop `14:$CE1D`, i.e. only ever against whoever
  is in the live context — with the probe's swap that is P1. Making P2
  damageable means calling that helper a second time with the contexts swapped.
* **The punch hitbox is a single object slot (`$0F`) and the satellite is a
  single object slot (`$0C`).** Two players punching simultaneously would fight
  over slot `$0F`. Two more slots have to be carved out of the 16-slot pool
  (slots 0–`$0B` are enemies, `$0C` satellite, `$0D`/`$0E` weapon hitboxes,
  `$0F` punch), or the pool has to grow.
* **HUD**: `$05C5/$05C6/$05C7` sit inside the swapped block but are read by the
  status-bar code in b14/b15, so the bar would show whichever context is live.
  Either move them out of the swap or draw two bars. **НЕ ПРОВЕРЕНО** which of
  those three bytes is really per-player.

---

## 7. The probe

`work/tools/e0/probe_sol.py` → `work/build/probe_sol.nes` (не коммичено).

### Where the code goes

* **ROM**: bank 15 `$FF50-$FFDF` — **144 bytes of `$FF` padding in the
  always-mapped fixed bank**, right before the `"     FC SOLBRAIN"` signature at
  `$FFE0` and the vectors. Verified that no confirmed-code reference points into
  it. The probe uses 131 of those bytes (`$FF50-$FFD2`).
* **RAM**: `$01A6-$01E8` — 67 bytes never written in a 2600-frame run (the sound
  driver's data ends at `$01A5`, the stack bottoms out at `$01E9`). The probe
  uses `$01A6-$01D8`.
* **The only original byte changed** is `12:$9150`, `20 59 91` (`JSR $9159`) →
  `20 50 FF` (`JSR $FF50`).

### The code

```
HOOK  $FF50   JSR $9159            ; player 1, on the live context
              LDA $01D8            ; FLAG = "shadow initialised"
              BNE ready
              JSR INIT
              LDA $01D8
              BEQ done
      ready:  JSR SWAP
              JSR $9159            ; player 2, on the swapped-in context
              JMP SWAP             ; swap back; its RTS returns to $9153

INIT  $FF6A   LDA $05A2            ; only snapshot once P1 is in ground state $00
              BNE ret
              LDX #$2C : LDA $05A2,X / STA $01A6,X / DEX / BPL     ; 45 bytes
              LDX #$03 : LDA $80,X  / STA $01D3,X / DEX / BPL      ; position
              CLC / LDA #4 / ADC $01D4 / STA $01D4                 ; P2 spawns +64 px
              LDA $35 / STA $01D7                                  ; speed
              LDA #1 / STA $01D8
      ret:    RTS

SWAP  $FF98   exchange $05A2-$05CE <-> $01A6-$01D2
              exchange $80-$83     <-> $01D3-$01D6
              exchange $04/$06     <-> $05/$07        (pad 1 <-> pad 2)
              exchange $35         <-> $01D7
              RTS
```

### Result: it works

Input script `1980 LEFT,2RIGHT` (pad 1 holds Left, pad 2 holds Right; note that
`nesemu` input scripts separate buttons with **commas**, not spaces):

| frame | P1 X | P2 X | sprites `$6A` |
|---|---|---|---|
| 2000 | 363.38 | 468.62 | 22 |
| 2050 | 294.62 | 537.38 | 19 |
| 2100 | 271.25 | 606.12 | 19 |
| 2150 | 271.25 (wall) | 631.75 (wall) | 19 |

Independent control confirmed in isolation too:

| input | P1 X | P2 X |
|---|---|---|
| none | 384.00 | 448.00 |
| `2RIGHT` | 384.00 | **631.75** |
| `2LEFT` | 384.00 | **272.00** |
| `LEFT` | **271.25** | 448.00 |

Jumping is independent as well (`A,2A` at frame 1985 → both enter state `$01`
and both Y values fall from 400.00 to 331.88 independently).

Screenshots (both characters visible, controlled by different pads):

* `docs/e0/sol_probe_2p_frame1979.png` — both standing at spawn, 64 px apart
* `docs/e0/sol_probe_2p_frame2015.png` — P1 walked left, P2 walked right
* `docs/e0/sol_probe_2p_frame2050.png` — further apart

### What the probe does NOT do

* P2 is a clone of P1 (same sprites, same suit) — no second character.
* Enemies only ever see P1 (the enemy loop runs once, outside the hook), so P2
  cannot be hit and cannot hit. **Deduced from §6, not separately traced.**
* Only P1's projectiles work correctly: `$9153 JSR $B168` runs once, outside the
  hook. Firing from P2 spawns into the same pool with P2's position at spawn
  time, but the pool update happens on the live (P1) context. **НЕ ПРОВЕРЕНО** in
  detail.
* The punch hitbox (object slot `$0F`) is single, shared.
* The camera follows P1 only; P2 can walk off screen.
* HUD shows P1.
* Death/respawn was not tested with two players. When the stage restarts, the
  shadow region is zeroed and `FLAG` is cleared, so the probe re-initialises
  itself on the next frame P1 is in state `$00` — that is by luck, not by design.
  **НЕ ПРОВЕРЕНО** whether P2 dying does anything sane.

### Remaining work to a real co-op mode (estimate)

| item | size |
|---|---|
| second context stored properly (work RAM `$6000-$7FFF`, not the stack page) | trivial |
| camera on both players (`15:$F2C8`, `15:$F352`) | ~60 bytes, 2 routines |
| enemies see both players (patch the 2 helpers `2:$8043`, `14:$CC66`, + ~5 direct sites in b3/b9) | ~150 bytes, 7 sites |
| damage to P2 (second call of `2:$8457` under swap) | ~30 bytes |
| second punch/weapon hitbox slot + second satellite | pool restructuring, 2 slots |
| projectile pool per-owner (it is already `$0700,X` indexed and slot-agnostic) | small |
| menu, second HUD, death/respawn rules | ordinary work |

That is a few hundred bytes of new code and roughly **10–15 patch sites**, all in
known routines.

---

## 8. Two mistakes the probe made, and what they prove

Both are worth recording because they are the measurement.

1. **First version snapshotted P2's context too early.** The hook fires from the
   moment the level loads, while P1 is still in the warp-in descent (`$05A2 =
   $12`). P2 therefore inherited a warp-in state, landed, and then got stuck
   forever because the transition `$12 → $13` at `12:$9741` requires `$05AF == 0`
   and P2's `$05AF` was `$12`. Fix: gate `INIT` on `$05A2 == 0`.
   *This is evidence in favour of Solbrain:* the failure was one state variable,
   diagnosable from a single RAM dump, not a structural conflict.
2. **`$35` was outside the swap set.** With the block-only swap both players
   still shared one horizontal speed, so P2 pressed Right and P1 drifted. The
   trace showed pass B doing `INC $35` and pass A reading it back on the next
   frame. Adding 1 byte to the swap fixed it completely.
   *That is the whole list:* **the player's cross-frame state is 45 + 4 + 1 = 50
   bytes**, nothing else.

---

## 9. Verdict

**Cost of a second player in Solbrain: CHEAP.** In `pb2_two_players.md`'s terms:

| | Power Blade 2 | Solbrain |
|---|---|---|
| player representation | slot 0 of a 22-slot × 29-field object array | one private 45-byte block + 5 zero-page bytes |
| player-field accesses, absolute vs indexed | all writes absolute (`STA $0400`), array shared with enemies | 434 absolute / 8 indexed; the 8 are a private sub-array |
| sites where the player position is written | scattered across the player pair | **4 instructions, one routine** (`12:$94DB`) |
| call sites of the player update | `JMP $8E15` wrap point, bank 8 `$8000` | **one** `JSR $9159` at `12:$9150` |
| "player = slot 0" hard reads outside the player's own code | dozens across most banks (22/22/6/15/29 raw hits in pair0/pair6/pair10/b14/b15), full enumeration never completed | **152 accesses in 39 clusters; only 15 clusters read the position** |
| camera | hardcodes slot 0 (`b14 $D3B8` reads bare `$0508`/`$04C6`) | reads the player's *displacement*; only 2 routines compare absolute position |
| enemy AI double-stepping if you re-run the pass | yes — one pass over 22 slots including the player | **no** — the player is not in the enemy pool at all |
| free ROM in a fixed bank | — | 144 bytes at `15:$FF50`, plus 60 bytes of unreferenced area records |
| free RAM | — | 67 bytes at `$01A6-$01E8` (probe uses 51) |
| **working two-player probe** | — | **yes: 131 bytes + 1 patched `JSR`** |

Sites that would have to be fixed for a *proper* co-op mode: **~10–15**, all
identified above (2 camera, ~7 enemy-side, 1 damage, 2 hitbox-slot, HUD). In
Power Blade 2 the equivalent list was never even fully enumerable.

**For criterion B/C of `docs/ver2_spec.md` §2.1 this is a clear win for
Solbrain**, and it points the same way as the level-format argument in §2.2.
