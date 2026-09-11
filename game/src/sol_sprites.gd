extends RefCounted
class_name SolSprites

## Solbrain's hero, put into the console's sprite table.
##
## $937A in bank 12 picks the picture and $F461 in the fixed bank lays it out.
## A picture is two lists walked side by side: one of down/along steps, one of
## tiles and colours.  The sprites are 8x16, so mirroring the picture top to
## bottom takes sixteen off every step down and mirroring it left to right
## eight off every step along.
##
## The table is written from both ends at once and which end alternates every
## picture ($6B).  That is not tidiness: the console draws only the first eight
## sprites it finds on a line, so shuffling which sprite sits where in the
## table is what makes the dropped one change from frame to frame instead of
## always being the same arm.


## What `work/extract/sol_sprites.py` read out of the cartridge.
static var scripts: Array = []
static var hurt: Array = []
static var loop: PackedByteArray = PackedByteArray()
static var pictures: Array = []

## $F4D0 -- past this many sprites the second end is not written at all.
const CROWDED := 0x3A
## $F5D5 and $F6D6 -- where each end starts again when it runs off its own.
const FWD_WRAP := 0x30
const BACK_WRAP := 0xFF
const BACK_FLOOR := 0x20


## What the drawing carries from one picture to the next: $6A..$6D and the
## four kilobytes of tiles the sprites come out of ($42..$45).
class Table:
	var count := 0                          # $6A
	var turn := 0                           # $6B
	var fwd := 0                            # $6C
	var back := 0                           # $6D
	var banks := PackedByteArray([0, 0, 0, 0])   # $42..$45
	var oam := PackedByteArray()            # $0200..$02FF

	func _init() -> void:
		oam.resize(256)


static func load_data() -> void:
	if not pictures.is_empty():
		return
	var j: Dictionary = Nes._load_json(Nes.DATA + "/sol/hero.json")
	scripts = j["scripts"]
	hurt = j["hurt"]
	loop = PackedByteArray(j["loop"])
	pictures = j["pictures"]


## What the hero's own code arrived at ($937A), laid out where the console can
## see it.  `x` and `y` are where he stands, in sixteenths, less where the view
## stands ($91C0).
static func hero(p: SolPlayer, x: int, y: int, t: Table) -> void:
	if p.draw_id < 0:
		return
	_place(p.draw_id, p.draw_mark, x, y, t)


## $F3DC -- the place is carried in sixteenths of a pixel and the console wants
## whole ones, so both are shifted four down before the picture is laid out.
static func _place(id: int, mark: int, x: int, y: int, t: Table) -> void:
	load_data()
	_put(id, mark, (x & 0xFFFF) >> 4, (y & 0xFFFF) >> 4, t)


## $F461 -- one picture into the table.
static func _put(id: int, mark: int, x: int, y: int, t: Table) -> void:
	if id >= pictures.size():
		return
	var e: Dictionary = pictures[id]
	var m: int = (mark ^ int(e["flags"])) & 0xFF     # $F47A
	var bank: int = int(e["chr"])
	if (bank & 0x80) != 0:                           # $F488 -- not drawn
		return
	if bank != 0:                                    # $F48A
		t.banks[(m >> 2) & 3] = bank
	var parts: Array = e["parts"]
	if parts.is_empty():
		return
	var hflip: bool = (m & 0x40) != 0                # $94
	var vflip: bool = (m & 0x80) != 0                # $95
	t.turn = (t.turn + 1) & 0xFF                     # $F4C1
	if (t.turn & 1) != 0:
		t.fwd = _walk(parts, m, hflip, vflip, x, y, t, t.fwd, true)
	elif t.count < CROWDED:                          # $F4D0
		t.back = _walk(parts, m, hflip, vflip, x, y, t, t.back, false)


## $F4E2 walking forwards, $F5E1 walking backwards.  The two ask the same two
## questions in the other order and write the four bytes at the other end of
## the table; a sprite either end throws out is thrown out by both.
static func _walk(parts: Array, m: int, hflip: bool, vflip: bool,
		x: int, y: int, t: Table, cur: int, forward: bool) -> int:
	var n := parts.size()
	for k in range(n):
		var p: Array = parts[k if forward else n - 1 - k]
		var dy: int = int(p[0]) & 0xFF
		var dx: int = int(p[1]) & 0xFF
		if vflip:
			dy = (0xF0 - dy) & 0xFF                  # $F4F4, less one sprite
		if hflip:
			dx = (0xF8 - dx) & 0xFF                  # $F563
		var py := _fit(dy, y & 0xFF, y >> 8)
		if py < 0:
			continue
		var px := _fit(dx, x & 0xFF, x >> 8)
		if px < 0:
			continue
		var at: int
		if forward:
			at = cur
			cur = FWD_WRAP if ((cur + 4) & 0xFF) == 0 else (cur + 4) & 0xFF
		else:
			at = (cur - 3) & 0xFF
			cur = (cur - 4) & 0xFF
			if cur < BACK_FLOOR:
				cur = BACK_WRAP
		t.oam[at] = py
		t.oam[(at + 1) & 0xFF] = int(p[2])
		t.oam[(at + 2) & 0xFF] = int(p[3]) ^ m
		t.oam[(at + 3) & 0xFF] = px
		t.count = (t.count + 1) & 0xFF               # $F5CE
	return cur


## $F4E2's own question, asked of one axis: where the little sprite lands, or
## -1 when it lands off the screen.  `hi` is the high byte the place kept after
## the divide by sixteen, so $0F means "just off the left, or just above".
static func _fit(d: int, base: int, hi: int) -> int:
	var v: int = (d + base) & 0xFF
	if hi == 0:
		if d < 0x80:
			return v if d + base <= 0xFF else -1
		return v if v < base else -1
	if hi == 0x0F:
		if base < 0x80 or d >= 0x80:
			return -1
		return v if d + base > 0xFF else -1
	# $F4EA -- anywhere else only a step back towards the screen counts.
	if base >= 0x80 or d < 0x80:
		return -1
	return v if v >= 0x80 else -1
