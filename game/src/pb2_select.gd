extends RefCounted
class_name Pb2Select

## $859D -- the screen a stage is picked on, as the cartridge draws it.
##
## The flow of it was done in Э3.10a and lives in `main.gd`; this is the
## picture, and `work/re/pb2_map.md` is the reading behind every number here.
##
## Three pieces and nothing else:
##
##   $88CE  lays the whole of both pages of names out of the stream numbered
##          eight, sets the two kilobyte-pairs the background is drawn from,
##          and $8A13 stamps a patch over every stage already finished.
##   $8838  puts the man in the middle and the sign above him, and takes the
##          scroll the stage stands at out of $8A04.
##   $878A  is the ride from one sign to the next: a hundred and twenty-eight
##          pictures, the ground moving sixty-four points and the sign thirty
##          two, and $8985 to let the player change his mind halfway.

## Two pages of names, side by side -- and then the first of them over again,
## because the console has only the two and shows them round and round: the
## fifth stage stands at $160 and the screen is $100 wide, so what is at the
## right of it is the first page a second time.
const WIDTH := 96
const PAGES := 2
const HEIGHT := 30

## $8881 -- `$87` := 3, so the picture is drawn in slices and the picture unit
## is handed a second place to stand in half way down.  Measured against the
## cartridge, line by line: above it the sky rides with $FD/$FF, below it the
## road stands at nought.
const SPLIT := 128
## $2001 -- and it leaves the leftmost eight points of the screen alone.
const CLIP_LEFT := 8

## $88CE -- what is handed to $C84C, and it is already doubled.
const SCREEN := 0x08
## $8881 -- the record $803E is given once the picture is shown.
const PALETTE := 3
## $88CE -- $42/$43: the background's two kilobytes each, number doubled.
const BG := [0x24, 0x25]
## $88CE -- $44/$45.  $46/$47 are not set at all and keep what the last area
## put there, so whoever builds this hands them over.
const SPR := [0x46, 0x47]

## $8874, $8879 -- the man stands in the middle and does not move.
const HERO_X := 0x80
const HERO_Y := 0xC8
## $885F, $8866 -- the sign is place one, and only its X comes from the record.
const SIGN_KIND := 0x50
const SIGN_Y := 0x18
## $886F -- run nought is the two pictures he shifts his feet between.
const STAND := 0x00
## $8777, $8739 -- turning about, and the picture he leaves on.
const TURN := 0x54
const PICKED := 0x53
const TURN_HOLD := 0x08           ## $877C
const WALK_BACK := 0x10           ## $89AC -- sixteen pictures, two points each

## $19 -- which of the screen's steps is running.
##
## $8881 is the step that dresses the screen, and it is not always over in the
## one picture: the patches $8A13 lays over the finished stages go through the
## queue the blanking empties, twenty rows a stamp, and two stamps fill it.
## With three or four the step runs a second picture -- measured against the
## cartridge for all sixteen ways the stages can stand -- and in that picture
## the man does not shift his feet.
const LAYING := 21
const STAMPS_AT_ONCE := 2
const PICK := 12
const RIDE := 13
## The ride does not hand straight back to the choosing: $C89A is INC $19, so
## between the two there is one picture of a step that does nothing at all --
## and the man does not shift his feet in it.
const OVER := 14
const TURNING := 15
const BACK := 16
## $87EF -- and then he walks back into the middle, and the ride goes on.
const WALK_IN := 17
const TAKEN := 18

## $89B6 -- the puff of dust he leaves where he changed his mind: place two,
## three pictures of five frames each, and then it is gone.
const DUST_SLOT := 2
const DUST_KIND := 0x55
const DUST_LAST := 0x58
const DUST_HOLD := 5
## $8874 -- and the middle he walks back to.
const MIDDLE := 0x80

## $48 -- the pad as the cartridge orders it.
const START := 0x10
const RIGHT := 0x01
const LEFT := 0x02

var map_image: Image
var palette := PackedByteArray()
var banks: Array = []             ## the four kilobytes of background
var spr_banks: Array = []         ## and the four of sprites
var slots: Array = []             ## the twenty-two places, for Pb2Sprites

var step_no := PICK               ## $19
var choice := 0                   ## $22
var fine := 0                     ## $88 -- the ride's own count, four a picture
var page := 0xA8                  ## $89 -- its low bit is which page is shown
var coarse := 0                   ## $FD
var coarse_page := 0              ## $FF -- again, the low bit
var facing_left := false          ## $042C bit six
var cleared := 0                  ## $5B
var owned := 0                    ## $56
var taken := -1                   ## the stage he settled on, once he has

var _anims: Array = []
var _records: Array = []
var _doc: Dictionary


## `spare` is $46/$47 as the last area left them, because the screen does not
## set them and the console does not forget them.
func _init(stage: int, cleared_: int, owned_: int, spare: Array) -> void:
	cleared = cleared_
	owned = owned_
	choice = stage
	_doc = Nes._load_json(Nes.DATA + "/pb2/screens.json")
	_anims = Nes._load_json(Nes.DATA + "/pb2/objects.json")["anims"]
	_records = _doc["stage_records"]
	banks = [BG[0] * 2, BG[0] * 2 + 1, BG[1] * 2, BG[1] * 2 + 1]
	spr_banks = [SPR[0], SPR[1], int(spare[0]), int(spare[1])]
	_paint()
	_place()
	var laid := 0
	for n in range(4):
		if (cleared & (1 << n)) != 0:
			laid += 1
	if laid > STAMPS_AT_ONCE:
		step_no = LAYING


## $88CE and $8A13 -- the picture, once.
func _paint() -> void:
	var name_ := []                                    # the two pages of names
	name_.resize(PAGES)
	for i in range(PAGES):
		var page_ := PackedByteArray()
		page_.resize(0x400)
		name_[i] = page_
	for s in _doc["screens"]:
		if int(s["x"]) != SCREEN:
			continue
		for b in s["blocks"]:
			var at: int = int(b["addr"])
			var which: int = 0 if at < 0x2400 else 1
			var o: int = at - (0x2000 + which * 0x400)
			var t: Array = b["tiles"]
			for i in range(t.size()):
				name_[which][o + i] = int(t[i])
	_stamp(name_)
	map_image = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	for col in range(WIDTH / 32):
		var p: PackedByteArray = name_[col % PAGES]
		for ty in range(HEIGHT):
			for tx in range(32):
				var at: int = p[0x3C0 + (ty / 4) * 8 + tx / 4]
				var quad: int = ((ty % 4) / 2) * 2 + ((tx % 4) / 2)
				map_image.set_pixel(col * 32 + tx, ty,
						Color8(p[ty * 32 + tx], (at >> (quad * 2)) & 3, 0, 255))
	palette = PackedByteArray(_doc["palettes"][PALETTE])


## $8A13 -- a patch of eight by sixteen over every stage already finished, and
## eight bytes of colour over the fifth once the first four are.
func _stamp(name_: Array) -> void:
	var p: Dictionary = _doc["stamp"]
	for n in range(4):
		if (cleared & (1 << n)) == 0:
			continue
		_blit(name_, int(p["tile_at"][n]), p["tiles"], 8, 0x20)
		_blit(name_, int(p["attr_at"][n]), p["attr"], 2, 0x08)
	if (cleared & 0x0F) == 0x0F:
		_blit(name_, int(p["attr_at"][4]), p["attr_last"], 2, 0x08)


## $8A7F and $8AAD -- so many bytes, then on by so much.
func _blit(name_: Array, at: int, src: Array, run: int, step: int) -> void:
	var i := 0
	while i < src.size():
		for k in range(run):
			var a: int = at + k
			var which: int = 0 if a < 0x2400 else 1
			name_[which][(a - (0x2000 + which * 0x400)) & 0x3FF] = int(src[i])
			i += 1
		at += step


## $8838 -- the man, the sign and where the ground stands for this stage.
func _place() -> void:
	slots = []
	for _n in range(Pb2Objects.SLOTS):
		var s := PackedByteArray()
		s.resize(Pb2Objects.FIELDS)
		slots.append(s)
	var rec: Array = _records[choice]
	coarse = int(rec[0])                               # $FD
	coarse_page = int(rec[1]) & 1                      # $FF
	# $8881 -- $89/$88 are put back to $A8/$00 whatever stage it is, so the
	# road below the line always starts on the first page and at nought.
	page = 0xA8
	fine = 0
	var hero: PackedByteArray = slots[0]
	hero[Pb2Objects.F_X] = HERO_X
	hero[Pb2Objects.F_Y] = HERO_Y
	_start(hero, STAND)
	var sign: PackedByteArray = slots[1]
	sign[Pb2Objects.F_KIND] = SIGN_KIND
	sign[Pb2Objects.F_X] = int(rec[2])
	sign[Pb2Objects.F_Y] = SIGN_Y


## $E2D5 ($C83A), for the one run this screen uses.
func _start(s: PackedByteArray, which: int) -> void:
	var run: Dictionary = _anims[which]
	s[Pb2Objects.F_ANIM] = which
	s[Pb2Objects.F_HOLD] = int(run["hold"])
	s[Pb2Objects.F_KIND] = int(run["first"])
	s[Pb2Objects.F_STEP] = 0


## $E30F ($C837).
func _tick(s: PackedByteArray) -> void:
	s[Pb2Objects.F_HOLD] = (s[Pb2Objects.F_HOLD] - 1) & 0xFF
	if s[Pb2Objects.F_HOLD] != 0:
		return
	var run: Dictionary = _anims[s[Pb2Objects.F_ANIM]]
	s[Pb2Objects.F_HOLD] = int(run["hold"])
	if s[Pb2Objects.F_STEP] == int(run["last"]):
		s[Pb2Objects.F_STEP] = 0
	else:
		s[Pb2Objects.F_STEP] += 1
	s[Pb2Objects.F_KIND] = (int(run["first"]) + s[Pb2Objects.F_STEP]) & 0xFF


## $8969 -- a stage is refused only when it is both finished and its suit
## already taken; one finished whose suit was missed is still open.
func may_pick(n: int) -> bool:
	var bit := 1 << n
	return (cleared & bit) == 0 or (owned & bit) == 0


## One picture of the screen.  Answers with the stage he settled on, or minus
## one while he is still choosing.
func step(held: int) -> int:
	match step_no:
		LAYING: step_no = PICK
		PICK: _pick(held)
		RIDE: _ride(held)
		OVER: step_no = PICK
		TURNING: _turning()
		BACK: _back()
		WALK_IN: _walk_in()
	_face()
	return taken


## $042C bit six, and the sign goes wherever the record left it.
func _face() -> void:
	var hero: PackedByteArray = slots[0]
	hero[Pb2Objects.F_BITS] = 0x40 if facing_left else 0x00


## $871C -- the pad while he stands.
func _pick(held: int) -> void:
	_tick(slots[0])
	if held & START:
		if not may_pick(choice):
			return
		step_no = TAKEN
		slots[0][Pb2Objects.F_KIND] = PICKED
		taken = choice
		return
	var last: int = 4 if (cleared & 0x0F) == 0x0F else 3
	if held & RIGHT:
		if facing_left:
			_turn()
		elif choice < last:
			choice += 1
			step_no = RIDE
	elif held & LEFT:
		if not facing_left:
			_turn()
		elif choice > 0:
			choice -= 1
			step_no = RIDE


## $8777 -- he turns on the spot before he walks the other way.
func _turn() -> void:
	slots[0][Pb2Objects.F_KIND] = TURN
	slots[0][Pb2Objects.F_HOLD] = TURN_HOLD
	step_no = TURNING


## $87A7 -- and when the turn is done he faces the other way and stands again.
func _turning() -> void:
	slots[0][Pb2Objects.F_HOLD] = (slots[0][Pb2Objects.F_HOLD] - 1) & 0xFF
	if slots[0][Pb2Objects.F_HOLD] != 0:
		return
	facing_left = not facing_left
	_start(slots[0], STAND)
	step_no = PICK


## $878A -- the ride, and $8985 to break it off.
func _ride(held: int) -> void:
	_tick(slots[0])
	if _changed_mind(held):
		return
	if facing_left:
		_ride_left()
	else:
		_ride_right()


## $8985 -- a push against the way he looks turns him round mid-ride and gives
## the choice back.
func _changed_mind(held: int) -> bool:
	var against := (held & RIGHT) != 0 and facing_left
	if (held & LEFT) != 0 and not facing_left:
		against = true
	if not against:
		return false
	choice += 1 if facing_left else -1
	var hero: PackedByteArray = slots[0]
	hero[Pb2Objects.F_KIND] = TURN
	hero[Pb2Objects.F_SELF] = WALK_BACK
	# $89B6 -- the dust is put where he stands and stays there while he walks
	# away from it.
	var dust: PackedByteArray = slots[DUST_SLOT]
	dust[Pb2Objects.F_KIND] = DUST_KIND
	dust[Pb2Objects.F_COUNT] = DUST_KIND
	dust[Pb2Objects.F_X] = hero[Pb2Objects.F_X]
	dust[Pb2Objects.F_Y] = hero[Pb2Objects.F_Y]
	dust[Pb2Objects.F_BITS] = hero[Pb2Objects.F_BITS]
	dust[Pb2Objects.F_SELF] = 0
	step_no = BACK
	return true


## $88F2 -- four points of ground a picture; the sign every sixteen; and the
## ride is over when the page has been turned twice.
func _ride_right() -> void:
	var was: int = fine
	fine = (fine + 4) & 0xFF
	if fine < was:
		page ^= 1
		if (page & 1) == 0:
			step_no = OVER                             # $C89A
	if (fine & 0x07) == 0:
		coarse = (coarse + 1) & 0xFF
		if coarse == 0:
			coarse_page ^= 1
	if (fine & 0x0F) == 0:
		var sign: PackedByteArray = slots[1]
		sign[Pb2Objects.F_X] = (sign[Pb2Objects.F_X] - 1) & 0xFF


## $8923 -- the same the other way, and it counts to $FC and $0C instead of
## nought because the four points are taken off before the look.
func _ride_left() -> void:
	fine = (fine - 4) & 0xFF
	if fine == 0xFC:
		page ^= 1
	elif fine == 0 and (page & 1) == 0:
		step_no = OVER                                 # $C89A
	if (fine & 0x07) == 0x04:
		coarse = (coarse - 1) & 0xFF
		if coarse == 0xFF:
			coarse_page ^= 1
	if (fine & 0x0F) == 0x0C:
		var sign: PackedByteArray = slots[1]
		sign[Pb2Objects.F_X] = (sign[Pb2Objects.F_X] + 1) & 0xFF


## $87C0 -- sixteen pictures of two points each the way he still looks, and
## then he faces about.
func _back() -> void:
	_dust()
	var hero: PackedByteArray = slots[0]
	hero[Pb2Objects.F_SELF] = (hero[Pb2Objects.F_SELF] - 1) & 0xFF
	if hero[Pb2Objects.F_SELF] != 0:
		var d: int = -2 if facing_left else 2
		hero[Pb2Objects.F_X] = (hero[Pb2Objects.F_X] + d) & 0xFF
		return
	facing_left = not facing_left
	_start(hero, STAND)
	step_no = WALK_IN                                  # $C89A -- INC $19


## $89DB -- the dust: five pictures a picture, three of them, and then the
## place is given up.
func _dust() -> void:
	var d: PackedByteArray = slots[DUST_SLOT]
	d[Pb2Objects.F_SELF] = (d[Pb2Objects.F_SELF] + 1) & 0xFF
	if d[Pb2Objects.F_SELF] != DUST_HOLD:
		return
	d[Pb2Objects.F_SELF] = 0
	d[Pb2Objects.F_KIND] = (d[Pb2Objects.F_KIND] + 1) & 0xFF
	if d[Pb2Objects.F_KIND] == DUST_LAST:
		d.fill(0)                                      # $C810


## $87EF -- and now that he faces the other way, the same two points a picture
## take him back into the middle, where the ride picks up again ($880A).
func _walk_in() -> void:
	var hero: PackedByteArray = slots[0]
	_tick(hero)
	var d: int = -2 if facing_left else 2
	hero[Pb2Objects.F_X] = (hero[Pb2Objects.F_X] + d) & 0xFF
	if hero[Pb2Objects.F_X] == MIDDLE:
		step_no = RIDE


## Where the picture stands above the line, in points: $FD and the page bit
## of $FF.  This is the sky, and it moves sixty-four points over a ride.
func scroll() -> Vector2i:
	return Vector2i(coarse_page * 256 + coarse, 0)


## And where it stands below the line: $88 four points a picture, on the page
## the low bit of $89 names.  Over a ride the road passes both pages -- five
## hundred and twelve points -- while the sky moves sixty-four.
func road() -> Vector2i:
	return Vector2i((page & 1) * 256 + fine, 0)
