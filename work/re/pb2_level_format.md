# Power Blade 2 — level format (fully decoded, proven)

Proof: stage 0, screen 2 decodes byte-for-byte onto CIRAM page 1 rows 0-19 of a
live capture (`/tmp/vB.bin`, frame 1900).

## Lookup chain

```
stage (0-6)
  -> bank pair   = $DFD8[stage] & $0F          (bank14)
  -> 4 pointers  via $DE31 / $DE3F / $DE4D / $DE5B, 7 words each, by stage.
     Each word is the ADDRESS of a word inside the level bank pair
     ($8000-$BFFF) -> two indirections.
```

| ptr | zero page | meaning |
|-----|-----------|---------|
| p1 | `$75/$76` | attribute byte per block (1 byte/block) |
| p2 | `$6C/$6D` | block definitions, 16 bytes each |
| p3 | `$02/$03` | area table: word per area -> list of screen indices |
| p4 | `$70/$71` | screen table: word per screen -> screen data |

Table lengths are self-describing: the pointer table runs until the first
address it points at.

## Data shapes

* **Block** = 32x32 px = 4x4 tiles, 16 bytes, **row major** (`byte[r*4+c]`).
* **Attribute** = one byte per block; the byte is written straight into the
  attribute table, so its 4 bit-pairs are the four 16x16 quadrants of the block.
* **Screen** = 8 blocks wide, **row major**. Height is 5 blocks (40 bytes,
  256x160, horizontally scrolling areas) or 8 blocks (64 bytes, 256x256,
  vertically scrolling areas). Size = gap to the next screen pointer.
* **Area** = an ordered list of screen indices. `$66` (camera screen counter)
  indexes it.

## Engine entry points (bank 14/15)

| addr | role |
|------|------|
| `$E0B9` | screen pick: `Y=$66`, `A=($02),Y`, `$70/$71 = ($08),Y*2` |
| `$DBDE` | row fill: PPUADDR `$2000 + $73*32`; screen`[($73>>2 &7)*8+bc]`; block bytes `($73&3)*4 .. +3`; 8 blocks -> 32 tiles |
| `$DB42` | column fill: screen index steps 8, block bytes `($73&3)+0,4,8,12`; limit 40 -> 5 block rows |
| `$DC73` | attribute fill: `A=($70),Y` block -> `A=($75),Y` attribute byte |
| `$DF85` | per-level tile hook, calls `$8006` in the level bank |

## Per-stage inventory

| stage | pair | attr | blocks | screens | areas |
|-------|------|------|--------|---------|-------|
| 0 | 2 | $801B | $80EC (209) | $8DFC (28) | $9384 (7) |
| 1 | 2 | $93AE | $9495 (231) | $A305 (27) | $A833 (8) |
| 2 | 2 | $A85E | $A94E (240) | $B84E (27) | $BDB4 (14) |
| 3 | 4 | $801E | $80E6 (200) | $8D66 (28) | $92D6 (7) |
| 4 | 4 | $92FF | $93E7 (232) | $A267 (27) | $A815 (10) |
| 5 | 4 | $A848 | $A93E (246) | $B89E (33) | $BE88 (30) |
| 6 | 0 | $B163 | $B1E2 (127) | $B9D2 (8)  | $BB22 (10) |

Tools: `work/tools/pb2_levels.py` (decoder), `work/tools/levelpng.py` (render).
