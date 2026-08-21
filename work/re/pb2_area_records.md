# Power Blade 2 — the fifth stage table: area records

`$E23F` maps bank pair 6/7, then walks a chain that the level-geometry tables
do NOT cover:

```
$E2BC[stage]        7 words, in bank 15          -> a word in bank pair 6/7
   -> word          the area-record pointer table
      -> [$9C]      one word per area
         -> record  14 bytes
```

`$9C` is the area index. The record is read byte by byte at `$E272`-`$E2B8`:

| off | dest | meaning |
|-----|------|---------|
| 0 | `$97` | scroll axis: **0 = horizontal, 1 = vertical** |
| 1 | `$AE` | area behaviour / music slot |
| 2 | `$73` | first nametable row (vertical) or column (horizontal) to fill |
| 3 | `$66` | starting camera screen |
| 4 | `$67` | starting camera sub-position |
| 5 | `$59` | camera limit, screen |
| 6 | `$5A` | camera limit, sub-position |
| 7 | `$42` | CHR R0 (2 KB at `$0000`), written as `value*2` |
| 8 | `$43` | CHR R1 (2 KB at `$0800`), written as `value*2` |
| 9 | `$46` | CHR R4 (1 KB at `$1800`) |
| 10 | `$47` | CHR R5 (1 KB at `$1C00`) |
| 11 | `$FC` | vertical scroll seed |
| 12 | `$016D` | palette set A |
| 13 | `$016E` | palette set B |

`$44`/`$45` (CHR R2/R3, the other half of the background pattern table) do not
come from here: `$EF03` reads `$EF3F[$0442]`, which is how the animated
background tiles are cycled.

The axis byte matches the screen height the geometry tables give: every area
with `$97 = 0` is made of 5-block-tall screens and every area with `$97 = 1`
is made of 8-block-tall ones.

Bank helper: `$ECA7` -> `$ECAB` masks the bank number with `#$0F`, which is
why the stock cartridge can only reach its first sixteen banks.
