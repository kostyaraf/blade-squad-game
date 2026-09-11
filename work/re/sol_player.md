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
94A5   if hurt or in a cutscene, some buttons are taken away ($06, $04)
94D2   JSR $94FA                buttons: weapons, the wire, the special moves
94D5   JSR $9689                up and down
94D8   JSR $9AA5                left and right
94DB   $80:$81 += $05B6:$05B7   and only now does he move
94EA   $82:$83 += $05B8:$05B9
```

The order matters and the rebuild keeps it: **decide the whole of the speed
first, move once at the end.** A collision that happens in the middle of the
frame trims the speed; it never moves him itself.

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
| `$04` | `$98CF` | 0 | |
| `$05` | `$9938` | 0 | |
| `$06` | `$99A8` | 0 | |
| `$07` | `$99FB` | 0 | |
| `$08` | `$98A8` | 0 | |
| `$09` | `$9896` | 0 | |
| `$0A` | `$986A` | 0 | |
| `$0B` | `$9886` | 0 | |
| `$0C` | `$978A` | 0 | |
| `$0D` | `$97D4` | 1 | |
| `$0E` | `$97A7` | 0 | |
| `$0F` | `$9816` | 1 | |
| `$10` | `$982E` | 1 | |
| `$11` | `$96FF` | 1 | |
| `$12` | `$9729` | 0 | |
| `$13` | `$9751` | 0 | |
| `$14` | `$9783` | 0 | |

Measured so far: pressing DOWN on the ground goes 0 -> 3 and letting go goes
back; pressing A goes 0 -> 1, landing goes 1 -> 2 and after eight frames 2 -> 0.
The rest are named as they are pinned down.

### The jump

`$A2B5`/`$A2BE` starts it:

```
A2BE   A = $05E8                 how hard this jump pushes
A2C1   if A >= $B8: A -= $5B     a long jump is cut back
A2CA   $05AD <- A ;  $05AE <- $FF      i.e. speed = -(256 - A)
A2D2   $05C9 bit 7 set
A2D7   $05A2 <- 1
```

`$05E8` is `$B2` for the ordinary jump, so the first push is **-78**, which is
4.875 pixels a frame upward. `$9B18` sets it to `$F0` or `$D0` by `$05E9`, and
`$9B39` to `$F8`, for the other kinds of jump.

`$A0BB` then pulls him down every frame while he is in the air:

```
A0BB   $05AD:$05AE += $05E9      gravity, 4 on foot
A0CB   if $05CB bit 7 (upside down) the sign is turned round instead
A0FA   $05B8:$05B9 += $05AD:$05AE
A10C   falling and past $0060 -> clamped to $0060
```

- **Gravity: 4 sixteenths a frame**, a quarter of a pixel a frame each frame.
- **Terminal fall: `$0060` = 6 pixels a frame.** Measured: a drop reaches it on
  the 24th frame and holds it.
- **A held keeps the rise going for `$05EA` = 6 frames.** `$A005` counts them in
  `$05AC` and calls the launch again each time, so the speed is put back to -78
  before gravity takes its 4. Letting A go writes `$FF` into `$05AC` and the
  count can never start again for that jump.

So a tapped jump and a held jump differ by exactly the length of that window,
and the whole arc is a straight line in speed:

| frames held | rise lasts | height |
|---|---|---|
| 1-2 | 2 frames at -74 | 49.8 px |
| 6 or more | 6 frames at -74 | 68.2 px |

Both are measured, not computed.

### On the ground

State 0 adds `$20` to the downward speed every frame (`$9EE9`) before the ground
check `$A1B3` runs. That is the small constant push that keeps him on a floor
and makes him walk down a step instead of stepping off it.

`$A1B3` asks what is one sixteenth below his feet (`$93 = $83 + 1`, or `- 1`
when `$05CB` says he is upside down) and hands `$90..$93` to **`$C00C`** in the
fixed bank, which is the shared "what is at this point" routine. The answer
comes back in A; `$A194` sorts it: `$60` is open, bit 6 set is one thing, `$A0`
is another.

## 5. What is still open

* The 17 unnamed states, and which button or event reaches each.
* `$C00C` itself: the shape of the collision answer, and the hero's box.
* The wire, the wall cling and the wall jump — `$94FA` and `$A172`.
* `$05C5` and what each suit changes.
* `$9689`'s first half (`$05C8`, `$0112`) — the afterimage trail.

## 6. How to measure any of it again

```python
import sys; sys.path.insert(0, 'work/tools')
import sol_probe as P
st = P.make_state('/tmp/x/lvl.state', frame=2320)      # stage 1, hero in hand
rows = P.watched(st, [(2320, 'RIGHT'), (2360, '-')], 2320, 2400,
                 [0x35, 0x80, 0x81, 0x05B2])
P.sweep(P.SCRATCH)
```

`P.run` gives every write frame by frame, `P.ram` the whole 2 KB at one frame,
and `P.watched` the two together — the standing value carried forward through
the frames nobody wrote. Frame numbers are **absolute**, counted from the reset,
not from the savestate. Everything the emulator writes goes under `P.SCRATCH`
and `P.sweep` throws it away; leave nothing behind.
