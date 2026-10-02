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
## $96BC -- the four colours a shield walks $0112 through, and $96EA -- one
## byte a state, "no shimmer while this one runs".
static var shine: PackedByteArray = PackedByteArray()
static var shine_off: PackedByteArray = PackedByteArray()
## $9384 -- the three pictures a hero with no suit on is drawn out of.
static var bare: PackedByteArray = PackedByteArray()
static var pictures: Array = []

## $F4D0 -- past this many sprites the second end is not written at all.
const CROWDED := 0x3A
## $F5D5 and $F6D6 -- where each end starts again when it runs off its own.
const FWD_WRAP := 0x30
const BACK_WRAP := 0xFF
const BACK_FLOOR := 0x20
## $C742 -- below this the table belongs to the bar, and neither end goes there.
const FWD_START := 0x20
## $C74E -- the down byte Solbrain parks an unused sprite at.  Power Blade uses
## $F4 for the same thing; both are simply below the picture.
const HIDDEN := 0xF7


## What the drawing carries from one picture to the next: $6A..$6D and the
## four kilobytes of tiles the sprites come out of ($42..$45).
class Table:
	var count := 0                          # $6A
	var turn := 0                           # $6B
	var fwd := 0                            # $6C
	var back := 0                           # $6D
	var start := 0x20                       # $69 -- where the two ends begin
	var banks := PackedByteArray([0, 0, 0, 0])   # $42..$45
	var oam := PackedByteArray()            # $0200..$02FF

	func _init() -> void:
		oam.resize(256)
		# The eight the bar owns are below $C72D's parking, so nothing puts
		# them away: on the cartridge they are already out of sight when the
		# bar is not there, and here they have to be put there.
		for i in range(0, 256, 4):
			oam[i] = HIDDEN


static func load_data() -> void:
	if not pictures.is_empty():
		return
	var j: Dictionary = Nes._load_json(Nes.DATA + "/sol/hero.json")
	scripts = j["scripts"]
	hurt = j["hurt"]
	loop = PackedByteArray(j["loop"])
	shine = PackedByteArray(j["shine"])
	shine_off = PackedByteArray(j["shine_off"])
	bare = PackedByteArray(j["bare"])
	pictures = j["pictures"]


## What the hero's own code arrived at ($937A), laid out where the console can
## see it.  `x` and `y` are where he stands, in sixteenths, less where the view
## stands ($91C0).
static func hero(p: SolPlayer, x: int, y: int, t: Table) -> void:
	if p.draw_id < 0:
		return
	var before: PackedByteArray = t.oam.duplicate() if p.bridge_compact else PackedByteArray()
	_place(p.draw_id, p.draw_mark, x, y, t)
	if p.bridge_compact:
		# PB3-only slide: the existing crouch art is drawn at half height.
		# Bit 4 is unused by the NES renderer and marks only these parts.
		var feet: int = (y >> 4) + 16
		for n in range(0, 256, 4):
			if t.oam[n] >= 240 or t.oam[n] == before[n]:
				continue
			t.oam[n] = clampi(feet - (feet - int(t.oam[n]) + 1) / 2 - 1, 0, 239)
			t.oam[n + 2] |= 0x10


## $CF73 -- any picture at all, which is how an object puts itself in.
static func picture(id: int, mark: int, x: int, y: int, t: Table) -> void:
	_place(id, mark, x, y, t)


## $F6E6, which $F3F9 is the door to -- the same laying out, but handed whole
## pixels: the screens outside a stage do not go through the divider at $F43F
## because what they draw stands on the screen and not in a level.
static func plain(id: int, mark: int, x: int, y: int, t: Table) -> void:
	load_data()
	_put(id, mark, x, y, t)


## $F6E2 -- the same again, but laid out walking forwards whichever turn it
## is: $F761 is a shorter walk of its own that knows nothing of the two ends
## taking turns, and only the pointer of STAGE SELECT goes through it.
static func forward(id: int, mark: int, x: int, y: int, t: Table) -> void:
	load_data()
	if id >= pictures.size():
		return
	var e: Dictionary = pictures[id]
	var m: int = (mark ^ int(e["flags"])) & 0xFF     # $F717
	var bank: int = int(e["chr"])
	if (bank & 0x80) != 0:                           # $F725 -- not drawn
		return
	if bank != 0:                                    # $F728
		t.banks[(m >> 2) & 3] = bank
	var parts: Array = e["parts"]
	if parts.is_empty():
		return
	t.fwd = _walk(parts, m, (m & 0x40) != 0, (m & 0x80) != 0, x, y, t,
			t.fwd, true)


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


## $C72D -- the top of the frame: nothing of the last picture is kept, the
## count starts again, and where the two ends start walking from is moved on by
## $50 each frame so that the sprite the console drops is a different one every
## time.  `frame` is $00, which decides which end goes first.
static func reset(t: Table, frame: int) -> void:
	t.turn = frame & 0xFF
	t.count = 0
	var at: int = (t.start + 0x50) & 0xFF
	if at < FWD_START:
		at = (at + 0xE0) & 0xFF
	t.start = at
	t.fwd = at
	t.back = (at - 1) & 0xFF
	if t.back < FWD_START:
		t.back = BACK_WRAP
	for i in range(FWD_START, 0x100, 4):
		t.oam[i] = HIDDEN


## $E554 -- two sprites side by side, which is how both flat pools draw: no
## picture and no script behind them, only two tiles and where their middle is.
## The place is in sixteenths and half a sprite comes off both axes before the
## shift down to whole pixels; whatever will not fit in a byte after that is
## off the picture and is not drawn at all.
##
## How many sprites were laid is handed back, which is two or none.  Nothing of
## the cartridge asks -- both emitters there end in an RTS and say nothing --
## and only Э7.5 does, to count what a guest's thrown things put on a picture.
static func pair(t: Table, x: int, y: int, tile_l: int, tile_r: int,
		attr_l: int, attr_r: int) -> int:
	var px: int = ((x - 0x80) & 0xFFFF) >> 4
	var py: int = ((y - 0x80) & 0xFFFF) >> 4
	if px > 0xFF or py > 0xFF:
		return 0
	t.turn = (t.turn + 1) & 0xFF                     # $E58C
	if (t.turn & 1) != 0:
		var at: int = t.fwd
		_four(t, at, py, tile_l, attr_l, px)
		at = _fwd_on(at)
		_four(t, at, py, tile_r, attr_r, (px + 8) & 0xFF)
		t.fwd = _fwd_on(at)
		return 2
	if t.count >= CROWDED:                           # $E5DE
		return 0
	var at: int = t.back
	_four(t, (at - 3) & 0xFF, py, tile_l, attr_l, px)
	at = _back_on(at, BACK_FLOOR)                    # $E5FB
	_four(t, (at - 3) & 0xFF, py, tile_r, attr_r, (px + 8) & 0xFF)
	t.back = _back_on(at, BACK_FLOOR)
	return 2


## $EA0E -- one sprite, and half of one comes off instead of half of two.  How
## many were laid is handed back the same way: one or none.
static func one(t: Table, x: int, y: int, tile: int, attr: int) -> int:
	var px: int = ((x - 0x40) & 0xFFFF) >> 4
	var py: int = ((y - 0x40) & 0xFFFF) >> 4
	if px > 0xFF or py > 0xFF:
		return 0
	t.turn = (t.turn + 1) & 0xFF
	if (t.turn & 1) != 0:
		var at: int = t.fwd
		_four(t, at, py, tile, attr, px)
		t.fwd = _fwd_on(at)
		return 1
	if t.count >= CROWDED:
		return 0
	# $EA91 -- the single stops one row of four higher than the pair does.
	_four(t, (t.back - 3) & 0xFF, py, tile, attr, px)
	t.back = _back_on(t.back, FWD_WRAP)
	return 1


## The four bytes of one sprite: down, tile, colour, along.
static func _four(t: Table, at: int, py: int, tile: int, attr: int,
		px: int) -> void:
	t.oam[at & 0xFF] = py
	t.oam[(at + 1) & 0xFF] = tile
	t.oam[(at + 2) & 0xFF] = attr
	t.oam[(at + 3) & 0xFF] = px


static func _fwd_on(at: int) -> int:
	return FWD_WRAP if ((at + 4) & 0xFF) == 0 else (at + 4) & 0xFF


static func _back_on(at: int, floor_at: int) -> int:
	var v: int = (at - 4) & 0xFF
	return BACK_WRAP if v < floor_at else v


## $ECC8 -- what a number is pulled apart by to be shown.
const FIGURES := [100000, 10000, 1000, 100, 10, 1]


## $EC7C -- six figures out of one number, and $ECE7 -- the tile that shows
## each.  A number too big for six comes out as six nines.
static func figures(n: int) -> PackedByteArray:
	var out := PackedByteArray()
	out.resize(6)
	var left: int = n
	for i in range(6):
		var c := 0
		while left >= FIGURES[i]:
			left -= int(FIGURES[i])
			c += 1
		out[i] = c
	if out[0] >= 0x0A:                               # $ECB5
		for i in range(6):
			out[i] = 0x09
	for i in range(6):
		out[i] = (out[i] * 2 + 0x81) & 0xFF          # $ECE7
	return out


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
