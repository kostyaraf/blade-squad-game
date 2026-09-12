# Solbrain — the shot pool at `$0780`

The second pool.  The objects at `$0600` are the things that walk about; this
one holds what they (and the hero's own breath) throw.  Sixteen slots, walked
by `$B2E9` of bank 3 **before** the objects are walked — `$CDDA` comes before
`$CDDD` in the frame.

## One slot

| page | meaning |
|---|---|
| `$0780` | behaviour.  Bit 7 set = still flying; clear = burning out |
| `$0790:$07A0` | x, 16 units per pixel, little endian |
| `$07B0:$07C0` | y, the same |
| `$07D0` | the behaviour's first byte (usually the step along, or a count) |
| `$07E0` | the behaviour's second byte (usually the step down) |
| `$07F0` | how much it still has to give |

`$0780 == 0` means the slot is free.

## The frame

```
$B2E9  a ride under way ($05C3 in 1..$2F) holds the whole pool still
       for X = 15 down to 0: if $0780,X != 0 -> $B304
$B304  bit 7 set -> the flying table $B317 (48 entries)
       bit 7 clear -> $B377 -> the burning-out table $B386 (47 entries)
```

Both tables are indexed by the low seven bits.  The burning-out table sends
twenty-three of them straight to `$BD4F`, which simply frees the slot.

### The flying table `$B317`

```
00=BC17 01=BC17 02=BC2C 03=B8A1 04=BB9E 05=BB5B 06=BA5C 07=BA22
08=B953 09=B953 0A=B8F5 0B=B918 0C=B896 0D=B7F2 0E=B859 0F=B864
10=B86F 11=B87A 12=B788 13=B793 14=B79E 15=B7A9 16=B7B4 17=B7BD
18=B7C8 19=B7D3 1A=B7DE 1B=B7E9 1C=B638 1D=B760 1E=B5C3 1F=B618
20=B740 21=B721 22=B70F 23=B65B 24=B6CB 25=B6F0 26=BC47 27=B564
28=B506 29=B4CC 2A=B4BC 2B=B4AF 2C=BD0E 2D=B4A2 2E=B451 2F=B3E6
```

### The burning-out table `$B386`

```
00=BD4F 01=BD4F 02=BD4F 03=B8A1 04=BB7B 05=BD4F 06=BD4F 07=BD4F
08=BD4F 09=B953 0A=B8F5 0B=BD4F 0C=BD4F 0D=B7F2 0E=B859 0F=B864
10=B86F 11=B87A 12=B788 13=B793 14=B79E 15=B7A9 16=B7B4 17=B7BD
18=B7C8 19=B7D3 1A=B7DE 1B=B7E9 1C=BD4F 1D=B752 1E=B5C3 1F=B618
20=B752 21=BD4F 22=BD4F 23=B752 24=BD4F 25=BD4F 26=BD4F 27=BD4F
28=BD4F 29=BD4F 2A=BD4F 2B=BD4F 2C=BD4F 2D=BD4F 2E=BD4F
```

## The helpers every behaviour leans on

| address | what it does | ported as |
|---|---|---|
| `$8121` (bank 2) | `$90..$93 = 0` | inline |
| `$BC8F` | x += `$90:$91` | `move_x` |
| `$BC7D` | y += `$92:$93` | `move_y` |
| `$BC7A` | both | `move` |
| `$BCC3` | spread `$07D0` into `$90:$91` | `along` |
| `$BCD1` | spread `$07E0` into `$92:$93` | `down` |
| `$BCC0` | both | `_spread` |
| `$BC77` | `$BCC0` then `$BC7A` | `drift` |
| `$BCA1` | `$90..$93 += the slot's own place` | inside `under` |
| `$BCFA` | kill when the width past the view reaches `$10` pages | `on_screen_x` |
| `$BD55` | the same for the height | `on_screen_y` |
| `$BCF7` | height then width | `on_screen` |
| `$BCDF` | the same, but a shot above the view is let through | `on_screen_up` |
| `$BD4F` | `$0780,X = 0` | `gone` |
| `$B93E` | the slot's place into `$90..$93` | inside `puff` |
| `$B8E5` | what the map holds where the shot is (`$D032`) | `under` |
| `$B752` | a puff object where it stood, then the slot is given up | `puff` |
| `$ADBA` (bank 2) | the last free slot, `$FF` when there is none | `free_slot` |
| `$907B` (bank 2) | `$0780,Y = A; $07F0,Y = 1` | `put` |
| `$A1C2` | the new shot starts where the thing is | `place_at` |
| `$A1D7` | ...plus an offset, with the caller's carry | `place` |
| `$8FF6` (bank 12) | an angle byte into `$90:$91` and `$92:$93` | `SolObjects.aim` |

**`$BCF7` is not a pair of early returns.**  `$BD64 BCS $BD4F` is a branch, and
`$BD4F`'s own `RTS` lands back inside `$BCFA`, so the width is still asked even
after the height has freed the slot.  `on_screen` therefore evaluates both.

## The behaviours read so far

| index | address | what it is |
|---|---|---|
| `00`, `01` | `$BC17` | it waits its count out where it is and then becomes `$82` |
| `02` | `$BC2C` | the packed step of `$BC54`: the top nibble along, the bottom one down |
| `03` | `$B8A1` | a bubble: rises, wanders, and lives only while the map around it is still water |
| `04` | `$BB9E` | the same packed step, until the map it reaches is solid — then it breaks into four (`$BBE6` with `$EE`, `$F9`, `$07`, `$12`) and burns out |
| `05` | `$BB5B` | a thrown thing: keeps its step along, gains two a picture downwards, `$7F` when the byte would turn over |
| `07` | `$BA22` | one of a ring: it hangs where it is while slot **zero** is still on turn `$04` with under three pictures of its walk gone, and they all fly off together the moment that turn is over |
| `0A` | `$B8F5` | it counts `$07E0` down and is gone when the count runs out |
| `0B` | `$B918` | the plainest: both bytes are the step |
| `1C` | `$B638` | a plain falling shot: half a tile a picture, gone the moment the map below is solid |
| `2F` | `$B3E6` | let go from the top of the picture: it sinks, leans towards the hero while its count runs, and on the stage that scrolls down does not lean at all |

Of the burning-out table, `04` (`$BB7B`) and `0A` (`$B8F5`) count down the same
way, and `03` is the bubble again.

Everything else is counted, not guessed: `SolObjects.missed_shot` records the
index and the stand prints `shot behaviours not read yet: <index> x<count>`.

## Where shots come from

| address | what it lets go |
|---|---|
| `$A7B0` (bank 9) | the hero's breath under water — behaviour `$03`, `$07F0 = 3`, `$07E0 = $E0`, one every fourth picture |
| `$9905` (bank ?) | the walking shooter's bullet — behaviour `$9C`, on the one picture of its walk where `$06D0 == 1` |
| `$8670` (bank 2) | the one riding the top of the picture drops behaviour `$AF` with `$07D0 = $40` |
| bank 6, through `$8081` | see below |

## Bank six

Bank 6 holds the behaviours that did not fit beside the others, and it is never
in the window when a mind wants one.  The mind loads the low byte of the entry
into A and jumps to `$8081` in bank 2, which puts `$80<A>` into `$90:$91` and
hands it to `$C081`; the fixed bank swaps banks 6 and 7 in and jumps through the
pointer.  Every entry is a `JMP` in the little table at the top of bank 6, so
what the mind names is one of ten routines.  Bank 6 keeps its own copies of the
two pool helpers, `$84A8` (free slot) and `$84B3` (take it), which do exactly
what `$ADBA` and `$907B` do.

There are seven call sites in all:

| mind | A | entry | what it lets go |
|---|---|---|---|
| `$9C0F` (bank 2, turn 1 of `$9B05`) | `$82` | `$84BC` | one `$0A`, half a page to the side it faces and one page up |
| the same, one picture later | `$91` | `$84CA` | one `$8B` from the same place |
| `$A2AF` (bank 3, `$A2A7`) | `$07` | `$862C` | a whole ring of sixteen `$87`, laid out from the four tables at `$866F`..`$869B`; the carry runs on from one to the next |
| `$A6FB` (bank 3, turns 2/7/12 of `$A53D`) | `$7C` | `$8553` | one `$84`, a page to the side and two pages up |
| `$9237` (bank 2, `$91EE`) | `$8E` | `$8094` | nothing of either pool: three bytes into `$011D`..`$011F`, which is where the picture is drawn from |
| `$9666` (bank 2, `$962E`) | `$7F` | `$84FF` | every other picture, one `$03` along the top of the thing — how far along is taken from the noise, and so is its second byte |
| `$99FC` (bank 2, `$99E1`) | `$0A` | `$85DC` | three `$8C` at once, at the three speeds `$10`, `$20`, `$30`, each half a page below the thing |

`SolStage.call_at` is the ported `$8081`; an entry that has not been read is
counted as `stage<NN>` beside the behaviours that have not been read.

## The shot against the hero

`$8866`, called from `$CDCC`, before the hero takes his own step.  It is gated
on `$54 != 0` and `$05A3 >= $70`.  Each live slot is laid over the box that
`$CDBE` built, the four compares threading one carry through as `SBC`s, and a
slot that lands calls `$88F0 -> $8354` with one — the same blow an object
gives.  The slot then loses one from `$07F0`, or stops flying if that was its
last.

Because all of this happens at `$CDCC` and the hero's own step is `$CDD2`, a
hit lands **one picture before** his own clock counts it.  That is what the
knock-back in `$9AA5` (`CMP #$01` on `$05A3`) leans on, and getting the order
wrong was what kept the last object script failing.

## What is still owed

* the remaining 44 flying behaviours and 23 burning-out ones, as the stands ask
  for them;
* `$88F6` / `$8918` — a shot against an object, not the hero;
* the hero's own pool at `$0700` (`$869C`), which is a separate sixteen slots;
* bank 6's entry `$79` (from `$A5BF` in bank 3), and the four entries `$86C8`,
  `$8269`, `$8180`, `$80D3` that no known call site names.
