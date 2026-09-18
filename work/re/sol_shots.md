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
| `$BCA1` | `$90..$93 += the slot's own place` | `under_at` |
| `$B8E8` | `$BCA1` then the map there, with the offset already in `$90`/`$92` | `under_at` |
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
| `$BD69` | the width again, but half a screen left of the view and two to the right of it | `on_screen_wide` |
| `$B5A6` | `$07E0 += 4`, held at `$7F`, then `$BC77` and `$BCDF`; answers whether the slot is still there | `_gain_step` |
| `$B832` | `$07E0 += 2` and the ring's own step for it (`$C078` is `$8FF6`) | `_ring_step` |
| `$B822` | `$BCC3` over the ring's step along, then `$BC7A`, `$BD55`, `$BD69` | `_ring_move` |
| `$B6B1` | half the speed the other way about; the carry says whether four is left | `_bounce_off` |
| `$BC54` | the packed step: top nibble along, bottom nibble shifted up for down | `_nibble_step` |

**`$BCF7` is not a pair of early returns.**  `$BD64 BCS $BD4F` is a branch, and
`$BD4F`'s own `RTS` lands back inside `$BCFA`, so the width is still asked even
after the height has freed the slot.  `on_screen` therefore evaluates both.

## The behaviours, all forty eight of them

The flying table is forty eight entries wide and the burning-out one the same,
but the two lean on the same handful of routines: twenty three of the
burning-out entries are `$BD4F`, which simply lets the slot go, and most of the
rest point straight at the flying entry of the same number.  Read out of the
ROM they come to twenty six routines in all.

| index | address | what it is |
|---|---|---|
| `00`, `01` | `$BC17` | it waits its count out where it is and then becomes `$82` |
| `02` | `$BC2C` | the packed step of `$BC54`: the top nibble along, the bottom one down |
| `03` | `$B8A1` | a bubble: rises, wanders, and lives only while the map around it is still water |
| `04` | `$BB9E` | the same packed step, until the map it reaches is solid — then it breaks into four (`$BBE6` with `$EE`, `$F9`, `$07`, `$12`) and burns out |
| `05` | `$BB5B` | a thrown thing: keeps its step along, gains two a picture downwards, `$7F` when the byte would turn over |
| `06` | `$BA5C` | it crawls along the wall: four ways tried in an order of its own, the first open one taken |
| `07` | `$BA22` | one of a ring: it hangs where it is while slot **zero** is still on turn `$04` with under three pictures of its walk gone, and they all fly off together the moment that turn is over |
| `08`, `09` | `$B953` | the one that turns the world over — see below |
| `0A` | `$B8F5` | it counts `$07E0` down and is gone when the count runs out |
| `0B` | `$B918` | the plainest: both bytes are the step |
| `0C`, `26` | `$B896`, `$BC47` | `$B5A6` alone: four more downwards a picture, held at `$7F`, then the plain move |
| `0D`, `10`, `11` | `$B7F2`, `$B86F`, `$B87A` | `$B81F`: two further round the ring every picture, the step down out of the ring and the step along out of `$07D0` |
| `0E`, `0F`, `13`, `14`, `18`, `19` | `$B859`… | it sits still until its count is out and then takes up `$90`, `$91`, `$95`, `$96`, `$9A`, `$9B` |
| `12`, `15`, `16` | `$B788`, `$B7A9`, `$B7B4` | `$B7FD`: the same ring, lifted a tile and a half |
| `17`, `1A`, `1B` | `$B7BD`, `$B7DE`, `$B7E9` | `$B80E`: the same ring, dropped by the same |
| `1C` | `$B638` | a plain falling shot: half a tile a picture, gone the moment the map below is solid |
| `1D` | `$B760` | it sinks a sixteenth of a tile a picture, and goes in a puff where the map under it is solid |
| `1E` | `$B5C3` | the borer — see below |
| `1F` | `$B618` | a whole tile down a picture and nothing else |
| `20` | `$B740` | `$B5A6` until the map under it is solid, and then the puff |
| `21`, `22` | `$B721`, `$B70F` | along by `$07D0`, the view asked first |
| `23` | `$B65B` | the bouncing one: `$B6B1` halves its speed and turns it round, and under four it gives up |
| `24` | `$B6CB` | it waits its count out and then sinks by `$07D0` |
| `25` | `$B6F0` | the same wait, and then it travels along |
| `27` | `$B564` | the carried one: `$07D0` names a slot of the **object** pool and that slot's `$0610`/`$0620` are its step |
| `28` | `$B506` | thrown out sideways by the down byte laid on its side, and when the count is out that byte starts going two down a picture with a floor at `$80` |
| `29`, `2D` | `$B4CC`, `$B4A2` | along by `$07D0`, the move first |
| `2A`, `2B` | `$B4BC`, `$B4AF` | the plain move, as `$0B` |
| `2C` | `$BD0E` | it sinks and turns as it goes, one step of four every fourth picture, skipping the fourth |
| `2E` | `$B451` | along by `$07D0`, and half a tile upwards a picture where `$34` says the map drags |
| `2F` | `$B3E6` | let go from the top of the picture: it sinks, leans towards the hero while its count runs, and on the stage that scrolls down does not lean at all |

Of the burning-out table, `1D`, `20`, `23` and `2F` go to `$B752` — a `$BD`
left where the shot stood and the slot given up — and the rest are either
`$BD4F` or the flying routine of the same number.

### `$B953` — the one that turns the world over

While the map lets it through it sinks by `$07E0` and nothing more.  Where it
stops, and only while `$26` is nought or six, up becomes down: `$05CB` bit 7
turns, `$BA0A` turns the fall at `$05AD:$05AE` round with it — taking the
borrow `$B966`'s own `CMP #$05` left standing — and the three numbers a jump is
made of (`$05E8`, `$05E9`, `$05EA`) are rewritten to `$00`, `$04`, `$06`.  The
tile set asked for lands in `$0399:$039B` out of the table at `$B9EA`, and
`$0399` is read back next time to ask whether the world is already the other
way up.  Either way a `$87` is left where it stopped.

The four rolls at `$B987` under a `AND #$04` come out as bit 7 of the new flag
and nothing else, so it is the flag itself that picks the row of the table.

### `$B5C3` — the borer

It sinks `$60` a picture and breaks whatever it passes through, and it does the
breaking by hand: the high bytes of its place are written into slot **thirteen**
(`$BD` and `$DD`), that slot's `$061D` is cleared, and `$A93C` is called with
one list of one cell (`$BF43` = `00 00 80`).  Slot thirteen's own numbers are
trodden on to do it.  Where the map it has reached is solid it is gone and a
`$24` is left standing there.

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

## The shot against his own four slots

`$88F6`, reached by `$A51E` -> `$C033` -> `$D005` -> bank eight's `$8022`, once
a picture for each of `$0C`..`$0F`.  It lays the same `$0780` pool over one of
the hero's own slots instead of over him, which is how the satellite is shot
out of the air.  **Ported and accepted (Э4.17).**

The box is built by hand and is not the picture's: a square `$0101` across --
sixteen pixels and a sixteenth -- reaching from `$80` back of the slot's own
point.  `$65`..`$68` are set to one apiece and the four subtractions thread one
borrow, so it is one subtraction of four bytes and not two of two.

Two carries decide where its edges really fall, and both were settled on the
stand:

* the carry walking into `$88F6` comes straight out of the slot's own
  behaviour (`$A56A`; `$A516`..`$A51E` and the bank change under it touch
  nothing), and it is **clear** -- so the near edge sits at `$81` back, not
  `$80`;
* `$8930`'s `ROR A`, which asks whether this is the shot's picture, is itself
  what leaves the carry for `$895F`'s compares.  Reaching them at all means it
  came out clear, so a shot that answered that question reads the box one
  sixteenth further back again than one that skipped it.  `$895C` is three
  noughts and then the code, the same trick as `$CFF1`, so only behaviours
  `$00`..`$02` skip it.

What a hit costs, at `$89A7`:

* a slot whose behaviour has bit 7 -- already on its way out -- swallows the
  shot and loses nothing (`$8A13`);
* a picture that carries no meaning at all (`$8A19`'s first byte nought) is not
  touched, and the shot flies on;
* otherwise `$06E0` is put back to nought and `$06F0` loses one.  The last
  point takes the slot with it: `$0610` is cleared, and for the satellite
  (`$0C`) `$0620` becomes `$20`, the sound is `$0A` and `$0600` becomes `$FF`,
  while any other slot simply has `$0600` cleared.
* and a slot that is left with exactly nothing but is not the satellite
  answers nought, so the shot that finished it goes on flying (`$8A01` returns
  the life it wrote).

## What is still owed

Both are now closed:

* `$A6CD` — the drawing of those four slots — перенесён и принят (Э4.20);
* bank 6's entry `$79` (from `$A5BF` in bank 3) — перенесён и принят (Э4.21),
  стенд `work/extract/verify_sol_pair.py`.

Как вообще устроен вход в шестой банк: `LDA #NN / JMP $8081` (банк 2) кладёт
`$90:$91` = `$80NN` и идёт в `$C09E`, а тот включает шестой банк и делает
`JMP ($0090)`.  То есть **NN — это младший байт адреса, а не номер в таблице**:
в начале шестого банка стоит ряд `JMP`-ов, и `$79` — это `$8079`, то есть
`$859E`.

`$859E` заводит две «вещи» в пуле `$0780`: `$84A8` ищет свободное место,
положение берётся из `$A0,X`/`$B0,X`/`$C0,X`/`$D0,X` объекта, вид `$86` (он же
идёт и в `$07F0`), `$07E0` = `$AC`, а `$07D0` у первой ноль и у второй единица.
Место ищется снизу вверх, так что первой достаётся пятнадцатый слот, второй —
четырнадцатый; нет места под первую — второй не будет вовсе.

Зовут его два хода ума `$1B` (`$A53D`), и оба в тот миг, когда их ходьба
кончилась: ход `$14` (`$A5B2`, ходьба `$11`, `$80E0`) и ход `$16` (`$A598`,
ходьба `$18`, и сверх того нулевой бит часов `$0C`).  **Перенесён и принят
(Э4.21)** — `SolStage._859e`, стенд `work/extract/verify_sol_pair.py`, 0 из 66.

Три «ничьих» входа тоже нашлись в той же таблице: `$8085` -> `$8269`,
`$8088` -> `$8180`, `$808B` -> `$80D3`, то есть их зовут с `#$85`, `#$88` и
`#$8B`.

Про три входа `$8269`, `$8180` и `$80D3`, которые ни одно известное место не
зовёт, теперь ясно: **это вообще не повадки выстрелов**.  Все три ходят по
`$4D`/`$4E`/`$4F` — счётчикам режима, а не по слоту, — и пишут не в пул, а в
очередь записи `$0301` (`$8270`).  То есть это сценарий какого-то режима
(заставка), и искать их надо среди режимов, а не среди выстрелов.  `$86C8` —
хвост боссов — прочитан.

Both tables themselves are now read out of the ROM whole: the stand
`work/extract/verify_sol_shotkinds.py` pokes each of the forty eight behaviours
into a slot of its own, in both tables, and answers **0 of 96**.
