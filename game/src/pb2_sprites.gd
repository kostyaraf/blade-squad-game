extends RefCounted
class_name Pb2Sprites

## Bank 6, $8038 -- what the console is told to draw, once a picture.
##
## The twenty-two places are walked in order and each one that names a picture
## ($0442) and is not hidden ($042C bit seven) puts its little sprites into the
## table the console reads.  Where in that table it puts them moves on by $44
## every picture ($28), because the console draws only eight sprites on a line
## and takes the first eight it finds: shuffling them is what makes what is
## dropped change from picture to picture instead of always being the same
## thing.


## The pictures, as `work/extract/pb2_sprites.py` read them out of the
## cartridge: a list of [down, tile, colours, along] for each little sprite.
static var hero: Array = []
static var objects: Array = []
## $EF3F -- which kilobyte of tiles the hero's own picture wants, and the two
## the second kilobyte can be.
static var player_bank: PackedByteArray = PackedByteArray()
static var suit_bank: PackedByteArray = PackedByteArray()

const SPRITES := 64
const OAM := 256
## $8038: how far along the table each picture starts, further every frame.
const ROTATE := 0x44
## $804F: a sprite put down here is off the bottom of the screen and so is not
## drawn at all.
const HIDDEN := 0xF4
## $8127: the step from one sprite's four bytes to the next one's, which walks
## the whole table of sixty-four and comes back to where it began.
const STRIDE := 0xC4


static func load_data() -> void:
	if not hero.is_empty():
		return
	var j: Dictionary = Nes._load_json(Nes.DATA + "/pb2/sprites.json")
	hero = j["hero"]
	objects = j["objects"]
	player_bank = PackedByteArray(j["player_bank"])
	suit_bank = PackedByteArray(j["suit_bank"])


## $8038 -- one picture's worth of the table.
##
## `was` is what the table held before, because the cartridge writes over it
## and never wipes it: a sprite it does not touch keeps whatever it said last
## time, and only the byte that says how far down it is ($F4) is put right.
static func build(slots: Array, rot: int, was: PackedByteArray) -> PackedByteArray:
	load_data()
	var out := PackedByteArray(was)
	out.resize(OAM)
	var x: int = (rot + ROTATE) & 0xFF
	var left := SPRITES
	for n in range(slots.size()):
		var s: PackedByteArray = slots[n]
		var kind: int = s[Pb2Objects.F_KIND]
		if kind == 0:                                  # $8068 -- not drawn
			continue
		var bits: int = s[Pb2Objects.F_BITS]
		if bits & 0x80:                                # $806D -- hidden
			continue
		var pal: int = bits & 0x03                     # $8071
		var behind: int = bits & 0x20                  # $8077
		var oy: int = s[Pb2Objects.F_Y]
		var oyhi: int = s[Pb2Objects.F_YHI]
		var ox: int = s[Pb2Objects.F_X]
		var oxhi: int = s[Pb2Objects.F_XHI]
		# $808F -- the hero and his three throws are drawn out of one set of
		# pictures, everything else out of another.
		var book: Array = hero if n < Pb2Objects.FIRST_LIVE else objects
		var pic: Array = book[kind]
		for p in pic:
			var dy: int = int(p[0])
			var sign: int = 0xFF if dy < 0 else 0x00
			var v: int = (dy & 0xFF) + oy               # $80C2
			out[x] = v & 0xFF
			var hi: int = (sign + oyhi + (v >> 8)) & 0xFF
			out[(x + 1) & 0xFF] = int(p[1])
			# $80DC -- the thing's own two colour bits win when it has any,
			# then its "behind the level" bit is added, and then its "the
			# other way round" bit turns the picture's own about.
			var a: int = int(p[2])
			if pal != 0:
				a = (a & 0xFC) | pal
			a |= behind
			if bits & 0x40:
				a ^= 0x40
			out[(x + 2) & 0xFF] = a
			if hi != 0:                                 # $80F9
				out[x] = HIDDEN
				continue
			# $8102 -- facing the other way, the step along is turned about
			# and moved by the width of a sprite.
			var dx: int = int(p[3])
			var d: int = (-(dx + 8)) & 0xFF if (bits & 0x40) else (dx & 0xFF)
			sign = 0xFF if d >= 0x80 else 0x00
			v = d + ox                                  # $8118
			out[(x + 3) & 0xFF] = v & 0xFF
			if ((sign + oxhi + (v >> 8)) & 0xFF) != 0:  # $8121
				out[x] = HIDDEN
				continue
			left -= 1                                   # $8123
			if left == 0:
				return out
			x = (x + STRIDE) & 0xFF
	# $804B -- and everything the picture did not want is put out of sight.
	for _i in range(left):
		out[x] = HIDDEN
		x = (x + STRIDE) & 0xFF
	return out


## The four kilobytes of tiles the sprites come out of, $1000-$1FFF.
##
## The first is the hero's own and follows his picture ($EF03 reads $0442 of
## his place); a suit moves it six along, but only over his own pictures and
## not his machine's ($EF1B).  The second says whether he has a suit on at
## all ($D290, $D294).  The other two are the area's and do not move.
static func banks_for(level: Pb2Level, pose: int, suit: int) -> Array:
	load_data()
	var out: Array = level.spr_banks.duplicate()
	if pose < player_bank.size():
		var b: int = player_bank[pose]
		if suit != 0 and pose < 0x1F:
			b = (b + 6) & 0xFF
		out[0] = b
	out[1] = suit_bank[1 if suit != 0 else 0]
	return out
