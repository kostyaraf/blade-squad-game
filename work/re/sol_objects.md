# Solbrain — the object (enemy / item) list, corrected

`work/re/sol_level_format.md` §7 describes the lookup chain correctly.  This
note corrects the meaning of the six record bytes and of the group table, which
the field names in `work/tools/sol_levels.py` still get wrong.

## The group table is a prefix table

Every group's `+2/+3` list pointer in a stage points at the **same** list.  What
differs is `+0`, the count.  Stage 0, `$AFFD`:

| group | count | list |
|---|---|---|
| 0 | 2 | `$B03D` |
| 1 | 6 | `$B03D` |
| 2 | 9 | `$B03D` |

and the room table names the groups in the order the player walks the level.
So a room does not have its "own" objects: entering a room raises the number of
records of one flat, X-sorted list that are live.  The `$0560` bitmap is what
stops an object that is already dead from coming back.

## Record layout (6 bytes)

| off | meaning |
|---|---|
| 0 | bits 5-0 = **spawn id**, the index into the `$0560` already-spawned bitmap; bits 7-6 = **facing / direction gate** (`$AEDF AND #$C0`) |
| 1 | **object type** |
| 2,3 | X, 16 units per pixel, little endian |
| 4,5 | Y, 16 units per pixel, little endian |

`sol_levels.py` calls byte 0 `kind` and byte 1 `param`; byte 1 is the type.
The spawn ids run 1..N in list order, which is why they look sequential.

Example, stage 0 `$B03D`:

```
01 02 00 27 00 19   id 1  face 0  type $02  x 624  y 400
02 02 00 2D 00 19   id 2  face 0  type $02  x 720  y 400
43 02 00 30 00 19   id 3  face 1  type $02  x 768  y 400
04 00 00 35 00 17   id 4  face 0  type $00  x 848  y 368
```

## Object types actually used

Counted over all 20 stages (byte 1):

```
00:21  01:3   02:60  03:102 04:9   06:39  07:3   13:16  14:12  16:67
17:145 18:76  19:34  1B:6   1D:16  1E:24  1F:6   20:18  21:9   22:3
23:40  24:36  25:29  26:27  27:40  28:57  29:9   2C:30  2D:79
```

29 distinct types.  Per stage:

| stage | types |
|---|---|
| 0 | 00 01 02 03 04 06 07 2D |
| 1 | 16 17 1F 25 2C |
| 2 | 03 1F 25 2C |
| 3 | 02 17 |
| 4 | 03 06 13 17 21 22 2D |
| 5 | 1D 20 29 |
| 6 | 13 26 2D |
| 7 | 17 19 23 24 28 |
| 9 | 03 16 2C |
| 10 | 13 16 17 23 |
| 11 | 03 06 19 |
| 15,16 | 03 13 14 16 17 18 19 1B 1E 23 24 27 28 |

Stages 8, 12, 13, 14, 17, 18 and 19 have no scripted objects at all.

## Destructible scenery is *not* in this list

It is the metatile `alt` mechanism of §4.6: a destructible block's normal
metatile is **non-solid** and its `alt` is **solid**, and `$E77E` sets the whole
`$0540` bitmap on entry, so the solid `alt` is what the player meets.  Breaking
the block clears its bit and the non-solid base shows through.  One 32x32 crate
is four consecutive metatile numbers, e.g. stage 0 `$46..$49 -> $12 $13 $10 $11`
(`props $21 -> $D0`, i.e. not solid -> solid), so each crate can be broken on
its own.
