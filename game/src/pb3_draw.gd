extends RefCounted
class_name Pb3Draw

## Э7.5 -- one picture of the PB3 mode: a level of one game with a hero of the
## other standing in it.
##
## Everything of the background is the level's own and there is only one of it:
## the map, its attributes, its colours and its four background banks come out
## of one level in one piece.  What is doubled is the sprites, because a sprite
## table is a table of its own console: the level's own game fills one -- the
## hero it keeps and everything the level has out -- and the guest of the level
## fills a second out of his own game's pictures, his own sheet of tiles, his
## own four sprite banks and his own game's colours.
##
## This class is only the laying out.  What is drawn with it is `main.gd`'s
## `_pb3_show`, and the two halves reach the shader as `oam`/`palette`/`banks`
## and `oam2`/`palette2`/`banks2`.
##
## Three things had to be decided rather than read, and each is named where it
## is done below: which of the two tables is in front, how the eight-to-a-line
## rule is counted, and where the guest's fourth sprite palette comes from.
## `work/re/pb3_draw.md` has all of it, with what was measured beside it.

const PB2 := Pb3Pair.PB2
const SOL := Pb3Pair.SOL

## Where the sprite half of a console palette starts: sixteen colours of
## background come before it.
const SPRITE_PAINT := 16
## How many bytes of the sprite half belong to the game rather than to the
## level.  Measured over all sixty three Power Blade areas and all twenty
## Solbrain stages: the first three sprite palettes are the same in every level
## of a game, and only the fourth is the level's own.
const OWN_PAINT := 12

## Where the pool of a Solbrain guest pretends the view stands while it is
## stepped, which is what Э5.7 puts there ($91C0's own numbers, but around him
## and not around the stage's hero).
const PRETEND_X := 0x80
const PRETEND_Y := 0x78

var two: Pb3Pair = null
## Who is a guest of the level, and below nought while there is none.  With one
## hero from each game there is exactly one, and he is always from the game the
## level did not come from.
var guest := -1
## Which game's sheet of tiles he is drawn out of.
var guest_sheet := ""

## The level's own table, in the four bytes a sprite the console keeps.
var oam := PackedByteArray()
## $8038 -- where in the table a Power Blade picture starts writing, further
## along every picture.
var rot := 0
## And the guest's own.
var guest_oam := PackedByteArray()
var guest_rot := 0
var guest_table: SolSprites.Table = null
## How many sprites of his table what he has thrown put there this picture,
## which is the one thing about him a stand cannot count from outside.
var guest_arms := 0
## Э7.5 -- with this on, what he has thrown is left out of his table.  Nobody
## playing ever turns it on: it is there so that a stand can take two
## photographs of one picture and show that the beams are in it, since nothing
## else of his moves when they are dropped.
var guest_arms_off := false
## Which suit a Power Blade guest has on, which is both three of his colours
## and the kilobyte his pictures come out of ($D290).
var guest_suit := 0

## The colours of each half.  Only the sprite half of the guest's is ever
## looked at; the background is the level's.
var palette := PackedByteArray()
var guest_palette := PackedByteArray()
## The eight banks of each: four of background and four of sprites.  A sprite
## never reads the background four -- every sprite tile in both games is an odd
## number, which in the tall-sprite mode means the other half of the tile
## memory -- so the guest's first four are the level's own and are there only
## so that nothing reads a bank that was never set.
var banks: Array = []
var guest_banks: Array = []

## The level of the guest's own game that his colours and his two spare sprite
## banks are read out of.  His own game has no level here -- there is no such
## record -- and every level of his game says the same thing about the first
## three sprite palettes and the first two sprite banks, so which level is
## asked cannot matter for what he himself is drawn out of.  Kept once, because
## raising a level to read thirty two bytes is not free.
static var _pb2_own: Pb2Level = null
static var _sol_own: SolLevel = null


static func pb2_own() -> Pb2Level:
	if _pb2_own == null:
		_pb2_own = Pb2Level.new(0, 0)
	return _pb2_own


static func sol_own() -> SolLevel:
	if _sol_own == null:
		_sol_own = SolLevel.new(0)
	return _sol_own


func _init(pair: Pb3Pair) -> void:
	two = pair
	Pb2Sprites.load_data()
	SolSprites.load_data()
	for i in range(two.who.size()):
		if i != two.host:
			guest = i
			break
	oam = PackedByteArray()
	oam.resize(Pb2Sprites.OAM)
	oam.fill(Pb2Sprites.HIDDEN)
	guest_oam = PackedByteArray()
	guest_oam.resize(Pb2Sprites.OAM)
	guest_oam.fill(Pb2Sprites.HIDDEN)
	if guest >= 0:
		guest_sheet = "pb2" if two.who[guest] == PB2 else "sol"
		if two.who[guest] == SOL:
			guest_table = SolSprites.Table.new()
			for i in range(4):
				guest_table.banks[i] = int(sol_own().spr_banks[i])
			# $C72D never wipes the first eight entries: that corner of the
			# table belongs to the strip, and the strip is not his.
			for i in range(0, SolSprites.FWD_START, 4):
				guest_table.oam[i] = SolSprites.HIDDEN
	palette = PackedByteArray(_level_palette())
	guest_palette = PackedByteArray(palette)
	after_step()


## The level's own thirty two colours, whichever game it came from.
func _level_palette() -> PackedByteArray:
	if two.game == PB2:
		return (two.pb2v as Pb2Level).palette
	return (two.solv as SolLevel).palette


## The guest's sprite colours: his own game's first three palettes, and the
## level's own fourth.
##
## The first three are his because his game says the same three in every one of
## its levels, so nothing is being chosen.  The fourth is the level's in both
## games, the level here is not his, and there is no fourth of his own to take:
## he is given the level's, which is what Э5.1 already does with everything
## else the level says to him.  What it costs is small and was counted: neither
## hero's own pictures ask for the fourth palette at all -- the Solbrain hero
## only while he is hurt, where $9407 puts $03 into his mark, and of the Power
## Blade hero's book only two pictures of a hundred and eight, neither of them
## one of his sixty two poses.
func _guest_colours() -> void:
	if guest < 0:
		return
	var own: PackedByteArray = (pb2_own().palette
			if two.who[guest] == PB2 else sol_own().palette)
	for i in range(OWN_PAINT):
		guest_palette[SPRITE_PAINT + i] = own[SPRITE_PAINT + i]


## $8080 -- a suit is three colours over sprite palette one.  The level's own
## hero wears his out of the status the level's own game keeps for him; a guest
## wears his out of his own, which is the one the shared bar does his wearing
## with (Э5.5).
func _wear(gear: Pb3Gear) -> void:
	guest_suit = 0
	if two.game == PB2 and two.host_status != null:
		_wear_into(palette, two.host_status)
	if guest < 0 or two.who[guest] != PB2 or gear == null:
		return
	var s: Pb2Status = gear.st[guest] as Pb2Status
	guest_suit = s.suit
	_wear_into(guest_palette, s)


func _wear_into(pal: PackedByteArray, s: Pb2Status) -> void:
	var c: Array = s.palette()
	# Sprite palette one: its colour nought is never drawn and is written all
	# the same, the way $8096 writes it.
	pal[SPRITE_PAINT + 4] = 0x0F                    # $8096
	for i in range(3):
		pal[SPRITE_PAINT + 5 + i] = int(c[i])


## Э7.5 -- the guest's half laid out again out of what is already decided.
##
## Nothing of his is stepped by it: the table is wiped and filled again from
## where he and his things already stand, so asking twice gives the same
## picture twice.  A stand asks, so that it can photograph one picture with
## `guest_arms_off` and without.
##
## Only a Solbrain guest can be asked: a Power Blade one is gathered the way
## $8038 gathers, which moves the place the gathering starts at every time, and
## asking twice would not be asking the same thing twice.
func lay_guest_again() -> void:
	if guest < 0 or two.who[guest] == PB2:
		return
	_guest_table()


## One picture's worth of both halves, laid out after the pair has stepped.
##
## The colours are gathered again every picture and not once: a level moves its
## own about while it runs -- water, a thing that has been hit -- and a suit
## worn down changes three of them.
func after_step(gear: Pb3Gear = null) -> void:
	_host_table()
	_guest_table()
	palette = PackedByteArray(_level_palette())
	guest_palette = PackedByteArray(palette)
	_guest_colours()
	_wear(gear)
	banks = _host_banks()
	guest_banks = _guest_banks()


## The level's own table.  In a Power Blade area it is gathered from the pool
## the way $8038 gathers it; in a Solbrain stage the order of the picture has
## already written it as it went ($91C0 and $CF26), and there is nothing left
## to do here.
func _host_table() -> void:
	if two.game != PB2:
		# The table of a Solbrain stage is the pair's own: the order of the
		# picture wrote it as it went, and there is nothing to gather.
		if two.host_table != null:
			oam = two.host_table.oam
		return
	if two.host_pb2 == null:
		return
	# $CF3B -- a picture the order held is a picture the table was not gathered
	# on either, so what stood there stands there still.
	if two.ended == Pb2Turn.HELD:
		return
	oam = Pb2Sprites.build(two.host_pb2.slots, rot, oam)
	rot = (rot + Pb2Sprites.ROTATE) & 0xFF


## And the guest's, laid out by his own game.
##
## A Power Blade guest is gathered out of his own pool, which is where $CF41
## puts his own row and `_arms_turn_pb2` moves what he has thrown: the places
## in it are already counted from the view the picture really has.
##
## A Solbrain guest has to be moved back onto the picture.  His pool is stepped
## with the view pretended to stand on him, so that nothing of his own is
## thrown out at the edge (Э5.7), and everything it lays out is measured from
## that pretended view.  Where he really stands is `screen_of`, which does the
## mending a sideways area and a downward one each need, so the view to lay him
## out from is the pretended one moved by the difference between the two.
##
## Three things of his are laid out, in his own game's order: himself, what he
## has thrown and his satellite.  The middle one is the odd one, because its
## drawing lives inside the behaviour that moved it and cannot be done again --
## what it drew is written down as it goes (`SolObjects.w_drew`) and laid out
## from here.
func _guest_table() -> void:
	if guest < 0:
		return
	if two.who[guest] == PB2:
		guest_oam = Pb2Sprites.build((two.things[guest] as Pb2Objects).slots,
				guest_rot, guest_oam)
		guest_rot = (guest_rot + Pb2Sprites.ROTATE) & 0xFF
		return
	var h: SolPlayer = two.sol[guest]
	var pool: SolObjects = two.guest_pool[guest]
	var s: Vector2i = two.screen_of(guest)
	var vx: int = PRETEND_X << 4
	var vy: int = PRETEND_Y << 4
	if pool != null:
		vx = pool.cam_x
		vy = pool.cam_y
	vx = (vx - ((s.x - PRETEND_X) << 4)) & 0xFFFF
	vy = (vy - ((s.y - PRETEND_Y) << 4)) & 0xFFFF
	SolSprites.reset(guest_table, pool.clock if pool != null else 0)
	SolSprites.hero(h, (h.x - vx) & 0xFFFF, (h.y - vy) & 0xFFFF, guest_table)
	guest_arms = 0
	if pool != null:
		# The order is his own game's: himself ($9159), then what he has
		# thrown ($B168), then his satellite ($9156).
		if not guest_arms_off:
			guest_arms = SolWeapon.draw_again(pool, guest_table, vx, vy)
		# $A6CD -- and his satellite, from the view the picture really has.
		SolSat.draw_again(pool, guest_table, vx, vy)
	guest_oam = guest_table.oam


## The level's own eight banks: the four of the background the level came in
## with, and the four of the sprites as its own game settles them -- his pose's
## own kilobyte and his suit's in a Power Blade area ($EF03, $D290), and
## whatever his own pictures have loaded in a Solbrain stage ($F48A).
func _host_banks() -> Array:
	if two.game == PB2:
		var lv: Pb2Level = two.pb2v as Pb2Level
		var pose := 0
		if two.host >= 0:
			pose = (two.pb2[two.host] as Pb2Player).pose
		elif two.spare_pb2 != null:
			pose = two.spare_pb2.pose
		var suit := 0
		if two.host_pb2 != null:
			suit = two.host_pb2.suit
		return lv.banks + Pb2Sprites.banks_for(lv, pose, suit)
	var sl: SolLevel = two.solv as SolLevel
	if two.host_table != null:
		return sl.banks + Array(two.host_table.banks)
	return sl.banks + sl.spr_banks


## And the guest's.  The first four are the level's own and no sprite reads
## them; the sprite four are his.
##
## A Power Blade guest's first two are his own -- the kilobyte his pose is
## drawn out of and his suit's -- and the other two are the ones the level of
## his own game that was asked came in with.  Nothing of his reads them: every
## kind his own places can hold, his sixty two poses and the eighteen pictures
## of what he throws, is drawn out of the first two kilobytes, and that was
## counted over the whole book.
##
## A Solbrain guest's four are whatever his own pictures have loaded into them
## this picture ($F48A puts each picture's own bank into the slot its mark
## names), over the four the level of his own game that was asked came in with.
func _guest_banks() -> Array:
	if guest < 0:
		return banks.duplicate()
	if two.who[guest] == PB2:
		var lv: Pb2Level = pb2_own()
		var pose: int = (two.pb2[guest] as Pb2Player).pose
		return banks.slice(0, 4) + Pb2Sprites.banks_for(lv, pose, guest_suit)
	return banks.slice(0, 4) + Array(guest_table.banks)
