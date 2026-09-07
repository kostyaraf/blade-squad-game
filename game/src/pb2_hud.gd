extends RefCounted
class_name Pb2Hud

## The status bar of Power Blade 2, and the queue everything in it goes through.
##
## The game never writes to video memory where it pleases.  It fills a queue at
## $0300 as it thinks, and the blanking between two pictures empties the queue
## into the screen ($CC41).  So the whole of the bar is one list of records and
## one routine that plays them back, and both are here.
##
## A record is [mode][low byte of the address][high byte][content], and mode
## nought ends the queue.  `work/re/pb2_hud.md` is the reading behind all of it.

## $CC3C -- what each mode adds to $2000; mode two steps a row down between two
## writes instead of a column along.  Read from the cartridge with the rest.
var cfg: Dictionary

## $0300 -- the queue.  The cartridge keeps it in one page and lets the index
## wrap, so it is one page here too.
var queue := PackedByteArray()
## $1F -- where the next byte goes.
var head := 0
## The screen itself: two kilobytes, which the four name tables fold into.
## $A000 on the cartridge says how they fold -- 0 side by side, 1 one above
## the other, 2 and 3 all four the same.
var screen := PackedByteArray()
var mirror := 1
## $3F00.. -- the colours.  The picture unit keeps them apart from the screen,
## and so must this, or a colour written at $3F00 would land in the fourth
## name table.
var palette := PackedByteArray()
## Which colours the queue has touched.
var painted := {}
## Which cells of the screen the queue has touched.  Nothing in the game
## reads it: it is for the stand that judges the emptying against the picture
## unit's own memory.
var touched := {}
## $FF -- what the game holds in $2000.  Only the two bits the mode does not
## own are kept from it.
var ctrl := 0

## $1B -- which of the four turns of the schedule comes next.
var part := 0

# What the bar reads.  Every one of them is a byte of the game's own memory,
# and whoever owns that byte lends it here.
var boss := 0             ## $79 -- a boss's room, where the stage is a word
var stage := 0            ## $53
var area := 0             ## $9C
var score_hi := 0         ## $95
var score_lo := 0         ## $96
var health_tanks := 0     ## $9D
var suit_tanks := 0       ## $9E
var lives := 0            ## $9F
var health := 0           ## $049A -- his own, out of the table of things
var fuel := 0             ## $A0 -- what is left of the suit
var charge := 0           ## $54 -- how far the blade is raised
var boss_life := 0        ## $04A9
var suit := 0             ## $9A


func _init() -> void:
	var f := FileAccess.open("res://data/pb2/hud.json", FileAccess.READ)
	cfg = JSON.parse_string(f.get_as_text())
	queue.resize(0x100)
	screen.resize(0x800)
	palette.resize(0x20)


# --- the four doors on to the queue -----------------------------------

## $CD0B -- one byte, and the place for the next one moves along.
func push(b: int) -> void:
	queue[head] = b & 0xFF
	head = (head + 1) & 0xFF


## $CD18 -- the head of a record whose writes step a column along.
func start_right() -> void:
	push(0x01)


## $CD1C -- and one whose writes step a row down.
func start_down() -> void:
	push(0x02)


## $CD09 -- the end of a record.
func end_record() -> void:
	push(0xFF)


## The address of a record, low byte first, as $CD0B is given it.
func _address(addr: int) -> void:
	push(addr & 0xFF)
	push((addr >> 8) & 0xFF)


# --- the pieces -------------------------------------------------------

## $D40A -- a number of two figures.  The byte is kept two figures to the byte
## (one to each half), and a figure is the tile $20 above its own value.
func number(addr: int, value: int) -> void:
	start_right()
	_address(addr)
	var base: int = int(cfg["digit_base"])
	push(((value & 0xF0) >> 4) + base)
	push((value & 0x0F) + base)
	end_record()


## $CCBC -- a ready-made strip out of the cartridge's own list.  A strip is an
## address and then letters until $FE; $FD inside one means the letters stop
## and another address follows.
func strip(n: int) -> void:
	start_right()
	var s: Array = cfg["strips"][cfg["strip_index"][n]]
	var i := 0
	while i < s.size():
		var b: int = int(s[i])
		i += 1
		if b == 0xFE:
			end_record()
			return
		if b == 0xFD:
			end_record()
			start_right()
			continue
		push(b)
	end_record()


## $D4FF and the three like it -- a bar of eight tiles.  The weight of one tile
## comes off the count for every whole tile, and what is left over picks a part
## tile out of a little table of the bar's own.
func _bar(addr: int, count: int, weight: int, full: int, rest: Array) -> void:
	start_right()
	_address(addr)
	var left := count
	for _i in range(8):
		var v: int = left - weight
		if v >= 0:
			left = v
			push(full)
			continue
		var b: int = int(rest[left])
		left = 0
		# $D511 -- a nought in the table is no tile at all, and the whole tile
		# is put out instead.  None of the four tables has one.
		push(full if b == 0 else b)
	end_record()


## $D4ED -- his health.
func health_bar() -> void:
	var b: Dictionary = cfg["bars"]["health"]
	_bar(int(b["addr"]), health, int(b["weight"]), int(b["full"]), b["rest"])


## $D4D9 -- what is left of the suit.
func suit_bar() -> void:
	var b: Dictionary = cfg["bars"]["suit"]
	_bar(int(b["addr"]), fuel, int(b["weight"]), int(b["full"]), b["rest"])


## $D58D -- how far the blade has been raised.
func charge_bar() -> void:
	var b: Dictionary = cfg["bars"]["charge"]
	_bar(int(b["addr"]), charge, int(b["weight"]), int(b["full"]), b["rest"])


## $D522 -- the boss's, which is two bars in one: under the split it is drawn
## with the first set of tiles, and from the split up the split is taken off
## the count and the second set used.  Eight tiles then show four times eight
## in two colours.
func boss_bar() -> void:
	var b: Dictionary = cfg["bars"]["boss"]
	var split: int = int(b["split"])
	var n: int = boss_life
	var k := 0
	if n > split:
		n -= split
		k = 1
	_bar(int(b["addr"]), n, int(b["weight"]),
			int(b["full"][k]), b["rest"][k])


## $D431 -- the stage and the area, or, in a boss's room, a word in their place.
func stage_area() -> void:
	# $D47B -- with a boss on the screen the left of the bar says ENEMY
	# instead of the stage, and his meter is drawn after it, from its own
	# door at $D522.
	if boss != 0:
		strip(3)
		return
	strip(2)
	var num: Dictionary = cfg["numbers"]
	number(int(num["stage"]["addr"]), (stage + 1) & 0xFF)
	# $D45B -- the area is counted plainly and shown as two figures, so a low
	# half that has run past nine is carried by hand.
	var a: int = (area + 1) & 0xFF
	var carry: Array = cfg["area_carry"]
	if (a & 0x0F) >= int(carry[0]):
		a = (a + int(carry[1])) & 0xFF
	number(int(num["area"]["addr"]), a)
	number(int(num["stage_tile"]["addr"]), int(cfg["stage_tile"][stage]))


## $D489 -- the score, which is two bytes of figures.
func score() -> void:
	var num: Dictionary = cfg["numbers"]
	number(int(num["score_hi"]["addr"]), score_hi)
	number(int(num["score_lo"]["addr"]), score_lo)


## $D4A7, $D4B6 and $D4C5 -- the three down the right hand side.
func spares() -> void:
	var num: Dictionary = cfg["numbers"]
	number(int(num["right_1"]["addr"]), health_tanks)
	number(int(num["right_2"]["addr"]), suit_tanks)
	number(int(num["right_3"]["addr"]), lives)


## $D5C1 -- the little picture of the suit he wears: three rows of three tiles,
## each row a record of its own.  The list of pictures has its third and fourth
## the other way round from the tiles.
func face() -> void:
	var tiles: Array = cfg["faces"][cfg["face_index"][suit]]
	var rows: Array = cfg["face_rows"]
	for r in range(3):
		start_right()
		_address(int(rows[r]))
		for c in range(3):
			push(int(tiles[r * 3 + c]))
		end_record()


## $D650 -- the schedule.  Four turns, one to a picture, counted by $1B; the
## last of them puts the count back and lets the level's own count move on.
## True when the last has been taken.
func schedule() -> bool:
	match part:
		0:
			stage_area()                               # $D65D
			score()
			part += 1
		1:
			spares()                                   # $D666
			part += 1
		2:
			health_bar()                               # $D672
			suit_bar()
			part += 1
		_:
			charge_bar()                               # $D67B
			face()
			part = 0
			return true
	return false


# --- the blanking, which empties it -----------------------------------

## $CC41 -- the queue is played into the screen and given up.  Nothing here
## decides anything: what the records say is what the screen is given.
func flush() -> void:
	push(0x00)                                         # $CC43
	var y := 0
	while true:
		var mode: int = queue[y & 0xFF]
		if mode == 0:
			break
		var step: int = 32 if int(cfg["fill_bits"][mode]) & 0x04 else 1
		y = (y + 1) & 0xFF
		var addr: int = (queue[(y + 1) & 0xFF] << 8) | queue[y]
		y = (y + 2) & 0xFF
		if mode == 3:
			# $CC93 -- so many of the one tile.
			var n: int = queue[y]
			y = (y + 1) & 0xFF
			var b: int = queue[y]
			y = (y + 1) & 0xFF
			for _i in range(256 if n == 0 else n):
				_poke(addr, b)
				addr += step
		elif mode < 3:
			# $CC82 -- tile after tile until $FF.  An $FF with a byte of five
			# or more behind it is a tile like any other, and the reading goes
			# on: that is how an $FF reaches the screen at all.
			while true:
				var b: int = queue[y]
				y = (y + 1) & 0xFF
				if b != 0xFF:
					_poke(addr, b)
					addr += step
					continue
				if queue[y] < 0x05:
					break
				_poke(addr, 0xFF)
				addr += step
		else:
			# $CCA3 -- so many tiles, one after another.
			var n: int = queue[y]
			y = (y + 1) & 0xFF
			for _i in range(256 if n == 0 else n):
				_poke(addr, queue[y])
				y = (y + 1) & 0xFF
				addr += step
	# $CC70 -- and the queue is empty again.
	queue[0] = 0
	head = 0


## One tile into the screen.  The console keeps four name tables of a thousand
## and twenty four bytes and wraps the address into them.
func _poke(addr: int, b: int) -> void:
	var a: int = addr & 0x3FFF
	if a >= 0x3F00:
		# The colours mirror every four: $3F10 is $3F00 over again.
		var i: int = a & 0x1F
		if (i & 0x13) == 0x10:
			i &= 0x0F
		palette[i] = b & 0x3F
		painted[i] = true
		return
	var i: int = _fold(a)
	screen[i] = b & 0xFF
	touched[i] = true


## Where a name table address really lands in the two kilobytes.
func _fold(a: int) -> int:
	var v: int = a & 0x0FFF
	match mirror:
		0: return ((v >> 1) & 0x400) | (v & 0x3FF)
		2: return v & 0x3FF
		3: return 0x400 | (v & 0x3FF)
	return v & 0x7FF


# --- and the eight rows the picture unit is told to show --------------

## The bar as a map the shader can read: one pixel a cell, red the tile and
## green which of the four palettes it is drawn in.
##
## The interrupt ($E640) hands the bottom of the screen to $2680 with the
## scroll at nought, so the eight rows below the level are the eight rows of
## the name table that begin there, and their colours are the four squares of
## its own attribute table.
func bar_image() -> Image:
	var img := Image.create(32, 8, false, Image.FORMAT_RGBA8)
	var base: int = int(cfg["split"]["addr"])
	# $23C0 of whichever name table it is: the last sixty-four bytes.
	var attr: int = (base & 0x2C00) | 0x3C0
	var top: int = (base & 0x3FF) >> 5
	for row in range(8):
		for col in range(32):
			var r: int = top + row
			var tile: int = screen[_fold(base + row * 32 + col)]
			var b: int = screen[_fold(attr + (r >> 2) * 8 + (col >> 2))]
			var pal: int = (b >> (((r & 2) << 1) | (col & 2))) & 3
			img.set_pixel(col, row, Color8(tile, pal, 0, 255))
	return img


## The four thousand-byte banks the bar is drawn out of.  The interrupt hands
## the cartridge's tile switch six numbers: the first two are two thousand
## bytes each and the rest one, and which half of the tile memory the
## background comes out of is the fifth bit of what it puts in $2000.
func bar_banks() -> Array:
	var r: Array = cfg["split"]["banks"]
	var low := [int(r[0]) & 0xFE, (int(r[0]) & 0xFE) + 1,
			int(r[1]) & 0xFE, (int(r[1]) & 0xFE) + 1]
	var high := [int(r[2]), int(r[3]), int(r[4]), int(r[5])]
	return high if (int(cfg["split"]["ctrl"]) & 0x10) != 0 else low
