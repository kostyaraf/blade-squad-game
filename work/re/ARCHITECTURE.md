# PB3 — architecture (working draft)

## Key measured facts

* Power Blade 2 (USA) and Tokkyuu Shirei Solbrain (Japan) share **<0.1% of PRG** and
  **~1% of CHR**. They are two independent Natsume engines, not one codebase with
  swapped assets. Any plan that assumed shared level data is dead.
* Both are MMC3 (mapper 4), 128K PRG + 128K CHR, **PRG mode 0**:
  bank 14 fixed at `$C000`, bank 15 fixed at `$E000` — a 16K fixed core each.
* Both ROMs are packed: PB2 has 597 bytes of tail padding total, Solbrain 16 bytes.
  There is no room for new code inside the original 128K. The ROM must grow.
* Both games **already poll controller 2 every frame**.
  * PB2 `$EBB0`: `$48`/`$49` = pad1/pad2 newly-pressed, `$4A`/`$4B` = pad1/pad2 held.
  * Solbrain reads `$4016` x8 and `$4017` x8 at `$C8A4`.

## Consequence: dual-engine cartridge

Plain mapper 4 cannot host two MMC3 games, because `$E000-$FFFF` is hardwired to the
physically last 8K bank of the whole image, and each engine needs its own.
So PB3 is built on a **multicart MMC3 mapper** where the fixed banks are
*block-relative*. Each game gets its own block and keeps running unmodified
MMC3 code inside it.

## PRG layout (512K, two 256K blocks)

| block position | contents |
|---|---|
| 0 – 13  | original game banks 0–13, **bank numbers unchanged** |
| 14 – 29 | **128K of new PB3 code/data** |
| 30      | original bank 14 → lands at `$C000` (block's second-to-last) |
| 31      | original bank 15 → lands at `$E000` (block's last) |

Block 0 = Power Blade 2, block 1 = Solbrain.

This works because of a measured property of PB2's banking:
`$ECA7`/`$ECAB` is the PRG switch helper — it does `TYA / AND #$0F / TAY`,
then sets MMC3 R6 = Y and R7 = Y+1, i.e. `$8000`/`$A000` always get an
adjacent bank pair. Every call site passes Y ∈ {$30,$32,$34,$36,$38,$3A,$3C},
so after the mask the game only ever selects pairs **0/1 … 12/13**.
Banks 14 and 15 are never mapped into the switchable windows, so moving them to
positions 30/31 is invisible to the original code, and positions 14–29 are free.
(The same must be verified for Solbrain before committing.)

New PB3 code cannot use the original helper (its `AND #$0F` caps it at bank 15),
so it writes MMC3 `$8000`/`$8001` directly with bank numbers 14–29.

## Zero page shadows already identified (PB2)

* `$42`,`$43` — 2K CHR bank numbers for R0,R1 (written doubled via `ASL`)
* `$44`–`$47` — 1K CHR bank numbers for R2–R5
* `$3F` — current PRG bank pair, `$40`/`$41` — saved pair for call/restore
* `$A1`,`$A4` — shadow of the last `$8000` bank-select value

## Open items

* Confirm the mapper (blocked on the mapper research agent): needs block-relative
  fixed banks, configurable 256K block size, >=512K PRG, and support in Mesen /
  FCEUX / Nestopia / RetroArch / EverDrive.
* Trampoline for switching blocks at runtime: the write that changes the block also
  changes what is mapped at `$E000` under the running code, so identical trampoline
  code must exist at the same address in both blocks' last bank.

---

## Mapper decision: iNES 45 (GA23C MMC3 multicart)

Verified behaviour (NESdev wiki + Mesen/Mesen2 `MMC3_45.h`):

* Four outer registers are written **sequentially to even $6000**; the 5th write wraps to
  register 0. They overlay WRAM regardless of MMC3's WRAM enable bits.
* PRG: `page = (mmc3_page & (0x3F ^ (reg3 & 0x3F))) | reg1`
* CHR: `page = (mmc3_page & (0xFF >> (0x0F - (reg2 & 0x0F)))) | reg0 | ((reg2 & 0xF0) << 4)`
* Because the mask is applied to the MMC3 page **before** the OR, the MMC3 fixed banks
  (`-1` and `-2`) become **block-relative** — exactly what a two-engine cartridge needs.
* `reg3` bit 6 = lock. We must leave it 0: Mesen unmaps $6000-$7FFF once locked and never
  implements the $6001 unlock, so locking would make returning to the menu impossible.
* Mesen reset state: all regs 0 except `reg2 = 0x0F`, write index 0. With `reg1 = 0` and a
  PRG-AND of `0x3F`, **the machine powers on executing the last 8K bank of the first 512K**,
  i.e. physical bank 63.

Safety check for putting mapper registers over $6000-$7FFF: neither game has PRG-RAM in its
header, and an instrumented 3000-frame run of each (title → cutscene → stage 1 gameplay)
recorded **zero** CPU writes anywhere in $6000-$7FFF. Static hits in that range are data
bytes mis-decoded by a raw byte scan, not real stores.

For a 256K block: `reg3 = $A0` (PRG-AND 256K, unlocked), PRG-AND mask `$1F`,
so MMC3 `-1` → block position 31 → `$E000`, and `-2` → position 30 → `$C000`.
For a 128K CHR block: `reg2` low nibble `$E`, CHR-AND mask `$7F`.

## Final PRG/CHR layout — 1 MB PRG, 512 K CHR, four 256 K blocks

| physical banks | block | contents |
|---|---|---|
| 0 – 31   | A | Power Blade 2 |
| 32 – 63  | B | **PB3 shell** — boots here, because bank 63 is the power-on `$E000` |
| 64 – 95  | C | Solbrain |
| 96 – 127 | D | spare / shared new content |

Inside a game block: positions 0–13 = original banks 0–13 (numbers unchanged),
14–29 = new code, 30–31 = original banks 14–15 so they land at `$C000`/`$E000`.

Block B is entirely ours, so the boot bank needs no surgery on either original — this is why
the image is 1 MB rather than 512 K. Power Blade 2's bank 15 has only 24 bytes of slack, far
too little for a boot stub.

Outer-register values per block: `reg1` (PRG-OR) = 0 / 32 / 64 / 96, `reg3` = `$A0`,
`reg0` (CHR-OR) = 0 / 128 / 0 / 128, `reg2` = `$0E` / `$0E` / `$1E` / `$1E`.

## Block switching at runtime

Writing the outer registers changes what is mapped at `$E000` under the running code, so the
switch must not run from ROM. The shell copies a ~24-byte routine into RAM and `JMP`s to it:
disable interrupts, four writes to `$6000`, then `JMP ($FFFC)` to take the target block's own
reset vector. RAM is unaffected by banking, so this is safe regardless of block sizes.

Each engine's reset path is patched to check a magic value in RAM: if the shell set it, run
the game's real reset; the flag also carries the chosen stage and player count.

## Прежде чем сверять — прочесть сценарии

Безголовый Godot на сценарии, который он не может разобрать, **не падает**:
он пишет жалобу и садится ждать окна, которого не будет. Сверка при этом
молчит все свои пятнадцать минут (`ENGINE_WAIT = 900`) и кончается ничем, а
ошибка при этом — одна строчка. Один заход перед сверкой стоит секунду:

    /Applications/Godot_mono.app/Contents/MacOS/Godot --path game --headless \
        --script res://../work/tools/gdcheck.gd

Выход не ноль — значит какой-то из `game/src/*.gd` не читается, и жалоба
напечатана рядом.

## Здоровье и оглушение: поблажек больше нет

Была пора, когда приёмка **называла** движку здоровье вещи (`$049A`) и её
счётчик пропущенных ходов (`$05B8`), если они изменились не в ту сторону: бить
вещи движок ещё не умел, и снять здоровье могло только то, чего в нём не было.

С Э3.2e обе поблажки убраны. Касание перенесено целиком
(`work/re/pb2_contact.md`), и приёмка гоняет его сама, ровно там, где оно стоит
в кадре картриджа:

```
передать строку героя  ($CEFD -- его собственный шаг)
things.contact()       ($CF08)
things.shift(...)      ($CF14)
судить остальные места (снимок снят здесь)
things.turns()         ($CF1C)
```

Строку героя передают **до** касания, а не вместе со всеми: снимок таблицы
снимают после `$D34D`, то есть герой в нём уже сделал свой шаг и уже прошёл
через сорок кадров неуязвимости. Поэтому `things.hero_told` велит обходу не
считать эти кадры второй раз.
