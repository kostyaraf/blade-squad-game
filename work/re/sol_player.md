# Tokkyuu Shirei Solbrain — the hero, frame by frame

Э4.1. What the hero is made of and what he does with a frame, read out of bank
12 and measured on the running cartridge with `work/tools/sol_probe.py`.

Every number below was checked two ways: read in the disassembly
(`python3 work/tools/sol_pair.py 12`) and watched in RAM while the game played
(`-watch`, `-ramdump`). Where the two disagreed the measurement wins and the
disagreement is written down.

---

## 1. Where he lives

Power Blade 2 keeps the hero in slot 0 of one big table of things. Solbrain
does not: the hero is his own block of memory and his own code, and the pool of
other things (`$0600-$06FF`) does not contain him at all.

| where | what |
|---|---|
| `$80 $81` | x, low byte first |
| `$82 $83` | y, low byte first |
| `$05A2` | state — which of 21 handlers runs this frame |
| `$05A3` | how many frames he has been in it (stops at `$FF`) |
| `$05A5` | non-zero while he is under the game's control rather than the player's |
| `$05A8 $05A9` | a push from outside: conveyor, wind, a hit |
| `$05AC` | how many frames the jump has been held |
| `$05AD $05AE` | this frame's vertical speed before it is applied |
| `$05B2` | which way he faces: `$60` right, `$A0` left (bit 7 = left) |
| `$05B6 $05B7` | horizontal speed for this frame, signed, 16 bit |
| `$05B8 $05B9` | vertical speed for this frame, signed, 16 bit |
| `$05C2` | non-zero while he is hurt and cannot be steered |
| `$05C5` | which suit / which powers are on |
| `$05C9` | bit 7: the jump button has already been used for this jump |
| `$05CB` | bit 7: he is upside down (the gravity-flipped rooms) |
| `$05CD` | ground kind: `$00` normal, `$18` slippery, `$30` ice |
| `$05E8` | how hard this jump pushes |
| `$05E9` | how hard gravity pulls — **4** on foot |
| `$05EA` | how many frames a held jump keeps rising — **6** |
| `$35` | running speed, one signed byte, sixteenths of a pixel |
| `$04` | buttons pressed this frame (bit 7 A, bit 6 B) |
| `$06` | buttons held (bit 0 right, 1 left, 2 down, 3 up, 4 start, 5 select, 6 B, 7 A) |
| `$30 $31` / `$32 $33` | where the view is, same scale as his own place |
| `$55` | which stage |

Both his place and his speed are counted in **sixteenths of a pixel**: `$80:$81`
divided by 16 is the pixel column, and a speed of 22 is 1.375 pixels a frame.
Nothing here is fractional in the floating sense; it is all whole numbers and
must stay whole numbers in the rebuild.

## 2. The frame

`$9150` is the gameplay frame. It calls `$9159`, which draws him and, at
`$91B5`, calls **`$9477` — the hero's own frame**:

```
9477   $05B6..$05B9 <- 0        speed starts at nothing every frame
9485   $50..$53     <- 0        the scratch the run code builds speed in
948D   $05A3++                  frames in this state, stopping at $FF
9495   $05CE += 4               stopping at $FC
94A5   some of the pad is taken away ($06, $04) -- see below
94D2   JSR $94FA                what he is standing in: water, ice, a current
94D5   JSR $9689                up and down
94D8   JSR $9AA5                left and right
94DB   $80:$81 += $05B6:$05B7   and only now does he move
94EA   $82:$83 += $05B8:$05B9
```

The order matters and the rebuild keeps it: **decide the whole of the speed
first, move once at the end.** A collision that happens in the middle of the
frame trims the speed; it never moves him itself.

### The pad — `$94A5`

Read it in the order the cartridge does, because the first line is the
surprising one:

```
94A5   $05C2 set (hurt)      -> nothing is taken away at all
94AA   $05C5 zero (no suit)  -> $06 <- 0, $04 <- 0
94AF   $05C9 bit 6 set       -> $06 &= ($3F if $05A3 > $20 else $33), $04 <- 0
94C1   $05A3 < $20           -> $06 <- 0, $04 <- 0
                             -> otherwise the pad reaches him whole
```

Being hurt **hands the pad back**, it does not take it away; what stops him
while he is reeling is `$9AA5`, not the mask.

The mask writes the trimmed value **back into `$06`**, and `$C882` works out
what is newly pressed by comparing the pad against `$06` as it stood last
frame. So a button held down through a mask reads as *newly pressed* on the
frame the mask lifts: a jump held through being hurt is a second jump the
moment he has control again. The rebuild keeps `$06` itself rather than being
handed "pressed" from outside.

### What he is standing in — `$94FA`

`$A172` looks up the metatile his own middle is inside, `$05CA` remembers it
from last frame, and four of the classes mean something:

| `and #$18` | what | routine |
|---|---|---|
| `$00` | ordinary ground and air | `$9522` -> `$9541` |
| `$08` | water | `$95AD` |
| `$10` | a current | `$9565` |
| `$18` | `$05CB \|= $20` and nothing else | `$9515` |

`$9541` is the plain world: gravity 4, six frames of hold, `$05E8 <- $B8`.
`$95AD` is water: gravity 1, `$20` frames of hold, `$05E8 <- $E0`, so a jump
under water is slow and long. Coming out of the water (`$9522`, and only on the
frame the class changes) either halves what he had, going up, or gives him
`-36` of rise if he had held the button at least `$10` frames.

`$05CD`, the kind of ground, is not his to keep: the level's own frame routine
clears it (`$AAA9` in bank 9) before he runs, and water and ice write it back
while he is still in them. Ice therefore stops being slippery on the frame he
steps off it. A stage with neither never writes the byte at all.

## 3. Left and right — `$9AA5`

```
9B4C   A = $06 AND $9C4B,X AND 3          X = $05A2, the state
9B53   nothing held      -> $9B8A, slow down
9B55   ROR ROR ROR                        right -> $60, left -> $A0
9B59   turned round?     -> $35 >>= 1 arithmetically (half the speed)
9B6D   $05B2 <- the new facing
9B70   left:  $35 -= 2      right: $35 += 2      (one less on slippery ground)
9C60   clamp to +-$16
```

- **Top speed `$16` = 22** sixteenths, 1.375 pixels a frame.
- **Speeding up: 2 a frame**, or 1 when `$05CD` is not zero.
- **Turning while running halves the speed**, and only on normal ground
  (`$05CD = 0`) and only outside state 1.
- `$9C4B,X` says which states may be steered at all. Indexed by the state:

  | states | mask | steerable |
  |---|---|---|
  | 0, 1, 7-15 | `$CF` | yes |
  | 2-6, 16 | `$CC` | no |
  | 17-20 | `$C0` | no |

Letting go: `$9B8A` takes `$9C03,X` off the speed, with `X = $05CD + $05A2`,
and zeroes it if that would cross zero. Three tables of 24 bytes, picked by the
ground:

| `$05CD` | table | standing | in the air |
|---|---|---|---|
| `$00` normal | `$9C03` | 4 | 1 |
| `$18` slippery | `$9C1B` | 1 | 0 |
| `$30` ice | `$9C33` | 0 | 1 |

From `$16` that is 22, 18, 14, 10, 6, 2, 0 — six frames to stop on foot, which
is what the cartridge does.

Finally `$A122` turns the one byte `$35` into the 16-bit `$05B6:$05B7` (sign
extended), adds the outside push `$05A8:$05A9`, and hands the result to the wall
check — `$A3E5` going right, `$A355` going left.

## 4. Up and down — `$9689`

`$9689` is a jump table: `$05A2 * 2` indexes **`$96C0`, 21 pointers**, and the
handler for the state runs. `$96EA` is a flag per state, one byte each.

| state | handler | flag | what it is |
|---|---|---|---|
| `$00` | `$9ED3` | 0 | on the ground (standing or running) |
| `$01` | `$A005` | 0 | in the air |
| `$02` | `$9EA1` | 0 | landing |
| `$03` | `$9C7D` | 0 | crouching |
| `$04` | `$98CF` | 0 | holding the wire while it winds him in |
| `$05` | `$9938` | 0 | the wire thrown and still going out |
| `$06` | `$99A8` | 0 | climbing the wire |
| `$07` | `$99FB` | 0 | at the top of it, where the view carries him |
| `$08` | `$98A8` | 0 | standing in a door |
| `$09` | `$9896` | 0 | coming down into one |
| `$0A` | `$986A` | 0 | stepping out of one |
| `$0B` | `$9886` | 0 | the same, and this one always springs |
| `$0C` | `$978A` | 0 | dying |
| `$0D` | `$97D4` | 1 | the doubled weapon burning off |
| `$0E` | `$97A7` | 0 | dead, and the game handed on |
| `$0F` | `$9816` | 1 | the picture a hit ends on |
| `$10` | `$982E` | 1 | being carried |
| `$11` | `$96FF` | 1 | waiting for what the satellite threw to burn out |
| `$12` | `$9729` | 0 | leaving a stage |
| `$13` | `$9751` | 0 | the picture the ride into one ends on |
| `$14` | `$9783` | 0 | nothing at all but a bit of `$0C` |

All twenty one are read and ported.  The stand is
`work/extract/verify_sol_states.py`: on a settled picture `$05A2` is written by
hand and both sides are let run, and the sixteen numbers of the hero and the
eighteen of each of his own four slots must agree picture by picture.

### The wire, `$04` to `$07`

The four of them are one mechanism.  Slot `$0C` of the object pool is the
satellite, and the wire is what it throws; every one of the four reads
`$060C` first and drops straight back to ducking (`$98C9`) when it is empty or
marked `$FF`.  `$99FB` is the exception: with the slot gone it falls instead.

* `$05` throws it.  While its head is still going out (`$06CC` is not `$FF`)
  the head flickers between two pictures, `$62` and `$64`, on the parity of
  `$0C`.  The head reaching the end and A still held goes to `$06`.
* `$06` climbs it.  `$8806` on animation `$12` reaching its last step goes
  to `$07`.
* `$07` is the top.  It pulls him after the satellite a pixel a picture while
  the satellite is above a line one tile down from the top of the view -- or
  fourteen tiles down, with the world the other way up.
* `$04` is the wire attached and winding in.  Every whole turn of the
  satellite (`$061C & $3F` at `$30`, or `$10` upside down) costs him `$10` of
  fuel, and running under `$30` of it drops him back to `$05`.

B lets go of it from any of them, through `$9A7C`: the satellite is told to
reel itself in (`$065C` bit 7), his fuel is put back to `$60`, and he is thrown
`$20` of speed the way he is **not** facing.  From `$06` and `$07` letting go is
a whole jump (`$A2F3`) and not the weakened one `$A2BE` gives.

### Being hit, `$9159`

`$9159` runs before `$9477`, so before anything else of his picture, and only
while `$05C2` is not nought.  Most of it is the aura it draws, but two things
are not drawing: it wipes `$05CE`, which is how hard he has been working the
fire button, and every thirty second picture (`$0C & $1F`) a step of the hurt
wears off -- `$05C2` of two first putting him into state `$0F`, and `$05C2` of
one doing nothing at all but asking for a noise.

Measured: pressing DOWN on the ground goes 0 -> 3 and letting go goes
back; pressing A goes 0 -> 1, landing goes 1 -> 2 and after eight frames 2 -> 0.

### The jump

`$A2B5`/`$A2BE` starts it, and starts it again on every frame the button is
still held:

```
A2BE   A = $05E8                 how hard this jump pushes
A2C1   if A >= $B8: A -= $5B     and every push after the first is weaker
A2C7   $05E8 <- A
A2CA   $05AD <- A ;  $05AE <- $FF      upward speed = A - 256
A2D2   $05C9 bit 7 set
A2D7   $05A2 <- 1
```

`$05E8` is **`$E0`** when he leaves the ground -- state 2 writes it as it hands
back to state 0 (`$9ECD`) -- and `$5B` is **6**. So the pushes of one jump run
`$DA $D4 $CE $C8 $C2 $BC $B6`, that is -38, -44, -50, -56, -62, -68, -74, and
stop weakening once the byte is under `$B8`. It is not one impulse held for a
while; it is seven of them, each a little stronger than the last, and letting go
early stops the series where it stands. That is the whole of the tall jump and
the short jump.

`$A0BB` then pulls him down every frame while he is in the air:

```
A0BB   $05AD:$05AE += $05E9      gravity, 4 on foot
A0CB   if $05CB bit 7 (upside down) the sign is turned round instead
A0FA   $05B8:$05B9 += $05AD:$05AE
A10C   falling and past $0060 -> $05B8:$05B9 clamped to $0060
```

- **Gravity: 4 sixteenths a frame**, a quarter of a pixel a frame each frame.
- **Terminal fall: `$0060` = 6 pixels a frame.** Measured: a drop reaches it on
  the 24th frame and holds it.
- **`$05EA` = 6** is how many times the push may be repeated. `$A005` counts
  them in `$05AC`; letting A go writes `$FF` there and the count can never start
  again for that jump.

The order inside one airborne frame is: push again if it is still owed, then
gravity on to `$05AD:$05AE`, then `$05B8:$05B9` takes that value, then the move.
On the frame he actually leaves the ground the push is set but gravity does not
run, so that frame he does not move vertically at all. Measured: pressing A at
rest leaves y at 400.00 for one frame and then goes -2.5 px.

### On the ground

State 0 adds `$20` to the downward speed every frame (`$9EE9`) before the ground
check `$A1B3` runs. That is the small constant push that keeps him on a floor
and makes him walk down a step instead of stepping off it.

`$A1B3` asks what is at **(x, y + 16 px)** -- `$93` is the *high* byte of y, so
`INC $93` is a whole sixteen pixels, not one sixteenth. Upside down (`$05CB`
bit 7) it goes the other way. The point goes to **`$C00C` -> `$D032` -> `$D09C`**
in the fixed bank, the shared "what is at this world point" routine written up in
`work/re/sol_level_format.md`, which answers with the metatile's property byte
shifted left three places. So of the answer:

| bit of the answer | bit of `props` | what it is |
|---|---|---|
| 7 | 4 | solid |
| 6 | 3 | hurts -- `$A1A1` sends it to `$9FA5`, which sets `$05C2` |
| 5 | 2 | a second kind, handled by `$963D` |

`$A194` sorts them: exactly `$60` (bits 3 and 2, not solid) is nothing at all;
bit 3 otherwise is damage; `$A0` (solid and bit 2) is the second kind.

## 5. Where he touches the world

His place is **not his feet**: it is sixteen pixels above them. Standing on the
floor of stage one, whose first solid row begins at `y = 416`, he rests at
`y = 400`.

Three points, and only three:

| probe | point | routine |
|---|---|---|
| the floor | `(x, y + 16 px)` | `$A1B3` -> `$C00C` |
| the floor he is falling onto | `(x + vx, y + vy + 16 px)` | `$A1D6` -> `$C00C` |
| the ceiling he is rising into | `(x + vx, y + vy - 16 px)` | `$A253` -> `$C00C` |
| a wall on the right | `(x + 8 px, y + 14 px)` then `(.., y - 6 px - 1)` | `$A411` -> `$C00F` |
| a wall on the left | `(x - 8 px, y - 6 px)` then `(.., y + 14 px)` | `$A381` -> `$C00F` |

`$C00F` (`$D010`) is the same lookup as `$C00C` with this frame's horizontal
speed added to the point first, so a wall is tested where he is about to be and
not where he is. Two things about that add are worth writing down, because
neither is visible in the routine that asks for it:

* **It adds in place.** `$A411` and `$A381` work the point out once, into
  `$90:$91`, and then call `$C00F` twice, changing only the height between the
  two. `$D018` adds the move to `$90:$91` and stores it back, so the second
  point is a whole move further across than the first. A hero going fast meets
  a wall a frame earlier with his upper half than with his lower.
* **It carries `$70` with it.** `$D012` compares the kind of map against `$3C`
  and the add at `$D018` has no `CLC` of its own, so on a map numbered above
  `$3C` every one of these probes lands one sixteenth of a pixel further along.
  Stage 10 is such a map (`$70 = $57`); most are not. Measured, not guessed:
  the same wall stops him one frame apart in the two cases.

Where the move would put him inside something, the move is cut back so he lands
exactly on the surface: going down (`$A221`) the move loses however far into the
metatile he would have gone, going up (`$A29E`) it gains what is left of it.

The two sides are not mirror images, and that is the cartridge and not a slip in
the reading: `$A41F` is `ADC #$E0` where `$A390` is `SBC #$60`. Written as a
16-bit offset the right-hand one would have wanted `$FFE0`; the high byte is
`ADC #$00`, so it really does add 224 and the point lands fourteen pixels below
him instead of two above. The right-hand side's *upper* point is a sixteenth
higher again (`$A430` subtracts with the borrow `$C00F` left behind). It is all
ported as it stands.

A wall that hurts hurts on touch (`$A3B0`, `$A43F` -> `$9FA5`); unlike the
ground under him, a wall never pushes and never slips.

The two sides are not mirror images, and that is the cartridge and not a slip in
the reading: `$A41F` is `ADC #$E0` where `$A390` is `SBC #$60`. Written as a
16-bit offset the right-hand one would have wanted `$FFE0`; the high byte is
`ADC #$00`, so it really does add 224 and the point lands fourteen pixels below
him instead of two above. It is ported as it stands.

Hitting a wall (`$A3FF`, `$A36F`) zeroes `$35` -- but only when he is facing
that way -- and always zeroes `$05B6:$05B7`, so the frame's move is cancelled
outright. Measured: running right along the floor of stage one he comes to rest
at **x = 631.75**, and the first solid column there begins at 640.

## 6. What is still open

* `$05C5` and what each suit changes.

  **The suitless branch is ported and accepted (Э4.14)**; what each of the
  eight steps of the suit changes is still open.  `$937F` looks at `$05C5`;
  anything
  other than nought goes to `$93CE`, the suited drawing.  With nought:

  ```
  9384  $05A3 < 6                     -> Y = $BA   ; the ordinary states
  938D  $05A2 == 1 and $05AF == 0     -> Y = $C0   ; hit, and free to move
  939D  $05A2 != 0                    -> Y = $BE
  93A2  $05A3 != $FF                  -> Y = $BE
        otherwise -- state $FF, $05A2 nought -- he is finished off here:
  93A9  $05AB = $FF, $05A2 = $0C, $F8 = $0C
  93B3  and if $060C is not nought: $060C = $FF, $062C = $20
        -> Y = $BE
  93C4  A = Y + (bit 7 of $05B2)      ; which way he faces
  93CB  JMP $9472                     ; and that is the group drawn
  ```
* `$9689`'s first half (`$05C8`, `$0112`) — the shimmer of the shield.
  **Ported and accepted (Э4.14).**  Read:

  ```
  9689  $05C8 == 0                 -> nothing
  968E  $96EA[$05A2 & $3F] != 0    -> nothing
  9699  $05FA != 0                 -> nothing
  969E  $0112 = $96BC[($0C >> 1) & 3]
  ```

  `$96BC` = `15 24 05 24`, and `$0112` is the third colour of the sprites'
  first set, so with a shield up that colour walks `$15 $24 $05 $24` every
  other picture and the suit shimmers.  `$96EA` is one byte a state, twenty
  one of them; nought everywhere except states `$0D`, `$0F`, `$10` and `$11`,
  which put the shimmer out.  The second half of `$9689` is the state's own
  handler, taken from the table at `$96C0` (two bytes a state).
* What the states hand on to but do not do themselves, all of it Э4.5's: which
  screen comes next (`$02`, `$2E`, `$97CD`), the stage's own bookkeeping that
  `$9751` reads out of `$0757` and `$07F0`, and the noises (`$F0`, `$F1`,
  `$43`).

All twenty one state handlers, `$9159` and `$9A7C` are read and ported.

## 6b. Э4.14 -- no suit on, and the shimmer

Two pieces of `$937A` and `$9689` that were read here long ago and left
unported are now in the engine, with `work/extract/verify_sol_bare.py` behind
them: 88 pokings (two stages x twenty one states x two cases, plus the two
corners the states alone do not reach), 0 differ.  The drawing itself is
`verify_sol_oam.py`, which now plays every one of its scripts twice -- the
second time with the suit taken off on picture twenty -- 0 of 276.

What the suitless branch does beside choosing a picture: on the picture his
count stops (`$05A3` = `$FF`) in state nought he is finished off for good --
`$05AB` = `$FF`, `$05A2` = `$0C`, `$F8` = `$0C`, and the satellite, if he has
one, is sent away (`$060C` = `$FF`, `$062C` = `$20`).  The three pictures
(`$BA`, `$BE`, `$C0`) and the two little tables of the shimmer (`$96BC`,
`$96EA`) are exported into `hero.json` by `work/extract/sol_sprites.py`.

`$0112` is the flow's own table of colours, and a stand that runs one stage
alone has no flow; so the pool keeps a copy of the byte (`z0112`) and writes
through to the flow when there is one.

## 6c. Э4.15 -- the recovery panels

Ducking on the right tile buys something back.  `$9CA0` is the whole of it, and
it runs out of the crouch, once a picture, while nothing is due to be drawn
(`$36`/`$37`).  The tile it reads is `$2A`, the metatile the floor probe left
behind (`$D0FD STY $2A`), taken `AND #$FE` and dropped if nought.

Each stage names four tiles of its own, four bytes at `$9D6E`:

| index | what it buys | routine | price |
|-------|--------------|---------|-------|
| 0 | the shield, `$05C8` = 3 | `$9DBE` | `$0A` |
| 1 | the suit filled, `$05C5` to 8 | `$9CC3` -> `$9E00` | `$1E` |
| 2 | one more try, `$071C` | `$9E30` | `$C8` |
| 3 | whichever of the three `$9DEC[$55]` names | `$9DDF` | that one's |

What a panel is paid with is not the score but the bonus he has not been
counted yet, `$05C6:$05C7`.  `$9E55` asks whether `($05C6:$05C7 - $56)` still
reaches the price; `$9E4F` adds the price to `$56`; and `$CDE3`, every picture
with `$56` not nought, takes one off both.  So a panel is paid for slowly,
a point a picture, and the count on the screen walks down as it is paid.

The suit is the only one that takes its time: a step of it goes on every odd
picture (`$9E17`, `$0C` rolled right), the price is charged only when the
eighth step lands, and `$8825` holds `$05A3` at `$20` all the while so the
crouch does not run out.  A suit filled halfway and walked away from costs
nothing at all.  While any of them is working `$9E48` holds DOWN down for him
(`$06 |= $04`), so letting go of the button mid-way changes nothing.

A panel that has given what it had is used up, `$9E6D`: `$BA15` is asked to
break the two places under his feet (`$81 & $FE` and `$81 | $01`, both one row
down), and then `$8C95` hatches thing `$2D` between them -- the upward-counting
hatch, slots nought to eleven, out of the second table (`$8D14`).

`$BA15` is the panels' own "may this give way": it refuses while a row or a
column is due, takes anything whose properties reach `$0C` in the low nibble or
have either of the bottom two bits, and -- unlike `$B9CD` -- breaks a place
that is already broken.

Of the four, only two have anywhere to stand in the twenty stages: the shield
on stage five (tile `$44`, seven places) and stage six (tile `$38`, four), and
the suit on stage thirteen (tile `$1E`, fifty eight).  The try panel of stage
thirteen (tile `$42`) is walled in on every one of its 480 places, but that
stage is the one that is all water and `$A26E` takes the ceiling away there, so
he can be set down inside the wall and stand on it after all.  The fourth panel
names a tile no stage lays.

Two debts of the hero came out of standing him in those places, both now paid:

* `$A26E` -- `$70` = `$3C`, the stage that is all water, has no ceiling at all.
  The probe gives its own `$3C` back, which is neither a block nor anything to
  react to.  `$70` is the hero's byte as much as the pool's, and the stand now
  hands it to him every picture.
* `$A336`/`$A3C0` against `$A355`/`$A3E5` -- the wall the *drag* puts to what is
  left of the move takes the speed away whichever way he looks; only the wall
  the move itself meets asks which way he faces first.

The tables are exported by `work/extract/sol_panels.py` into
`game/data/sol/panels.json`, and the acceptance is
`work/extract/verify_sol_panels.py`: every standable place of every panel, each
entered three ways -- with the money, a point short of it, and with the thing
already full -- held against the cartridge picture by picture on the sixteen
slots, the thirty two bytes of the broken mark, the hero's sixteen numbers and
the seven a panel pays with and into.  0 of 24.

## 6a. Acceptance

`work/extract/verify_sol_states.py` — on a settled picture (frame 40) `$05A2`
is written by hand with each of the twenty one states in turn and both sides
are let run for ninety pictures.  Compared are the hero's sixteen numbers
(place, speed, state, the two of the little script, the picture, which way he
looks, his clock and his fuel) and the eighteen of each of his own four slots
`$0C..$0F`.  Where a state hands the game on the comparison stops on the
picture `$02` changes, because past that the cartridge is not playing the same
thing at all.

Measured: **0 of 189** — the twenty one states over nine stages.

### The strip, `$91DD` (Э4.11)

Everything the player is told while a stage plays stands in the bottom left
corner, and all of it is sprites: the mark of the suit (`$05C5` plus two out of
the picture list, blinking below the third suit) and five figures of what is
still to be paid (`$05C6:$05C7` through `$EC7C`/`$ECE7`).  Nothing on the strip
is background.

The mark goes in through `$C009`, which is `$F3F0` -> `$F6E2`: **whole pixels
and the forward walk**, not the divider `$CF73` (`$F3DC` -> `$F43F`) that every
object goes through.  The port had it through the divider, so the mark stood at
one across and twelve down instead of sixteen and two hundred — in the corner
of the sky instead of on the strip.

`work/extract/verify_sol_strip.py`: the cartridge is stopped at `$91DD` and at
`$923B` (the instruction after the strip), the engine is handed the first
record and must hand back the second — the whole table, the four cursors and
the four tile books.  Eight walks, one per suit, and inside each the sum owed
is stood at nought, at one of each figure, at the rollover and past what five
figures hold.  **0 из 8.**

## 7. How to measure any of it again

```python
import sys; sys.path.insert(0, 'work/tools')
import sol_probe as P
st = P.make_state('/tmp/x/lvl.state', frame=2320)      # stage 1, hero in hand
rows = P.watched(st, [(2320, 'RIGHT'), (2360, '-')], 2320, 2400,
                 [0x35, 0x80, 0x81, 0x05B2])
P.sweep(P.SCRATCH)
```

Any stage but the first is reached without playing the ones before it: write
the stage into `$55` and `$1D` into `$02` (the mode that raises the stage named
in `$55`, `$D930`). `P.warp` does that and hands back a savestate standing in
it, with any pokes baked in, so the state is a clean frame boundary:

```python
lvl = P.make_state(scratch + '/lvl.state', frame=2320)
st = P.warp(scratch + '/s11.state', 11, lvl,
            pokes=((0x80, 0x10, P.WARP_IN - 60), (0x81, 0x1A, P.WARP_IN - 60)))
```

A state made that way is whole: the first frame played from it is `WARP_IN + 1`.
The first stage's own state is taken in the *middle* of frame 2320, so resuming
it replays the rest of that frame and the first button belongs to 2320 itself.

`P.run` gives every write frame by frame, `P.ram` the whole 2 KB at one frame,
and `P.watched` the two together — the standing value carried forward through
the frames nobody wrote. Frame numbers are **absolute**, counted from the reset,
not from the savestate. Everything the emulator writes goes under `P.SCRATCH`
and `P.sweep` throws it away; leave nothing behind.
