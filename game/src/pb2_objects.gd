extends RefCounted
class_name Pb2Objects

## The table of live things and the scan that fills it -- $E3F3 in bank 15.
##
## The level's list says what stands where, sorted along the way the view
## travels.  Nothing is alive until the view uncovers it: once a step, and only
## in a step in which the view moved, the game walks the list and turns into an
## object every record that has just come over the edge of the screen.  Killing
## one does not use the record up -- back the view goes, and there it is again.

const SLOTS := 22
## $801A and $D36B: the sweep and the slide walk from here to the end.
const FIRST_LIVE := 0x06

## $E55E -- the four types the area gives out once each time it opens.
const ONCE_A_VISIT := [0x24, 0x3E, 0x40, 0x3A]
## $E499 and $E4B3: the records of a level may only be put in these.  The
## search runs upwards but keeps the last free one it saw, not the first, so
## they fill from the top down.
const FIRST_PLACED := 0x0E
const LAST_PLACED := 0x15
const END_OF_LIST := 0xFF

## The cartridge keeps a thing's twenty-nine bytes as twenty-nine tables of
## twenty-two, from $0400 to $0668: field f of place n lives at $0400 + 22*f + n.
## Here the same table is read the short way about -- twenty-two places of
## twenty-nine bytes -- so a place is one row and the field number is
## (address - $0400) / 22.
const FIELDS := 29
const F_TYPE := 0        ## $0400 -- what it is; zero means the place is free
const F_MARK := 1        ## $0416 -- a bitfield; eight at birth
const F_BITS := 2        ## $042C -- bit 6 is which way it looks
const F_KIND := 3        ## $0442 -- to the type's own taste: mostly the picture
const F_ANIM := 4        ## $0458 -- which run of pictures it is walking through
const F_STEP := 5        ## $046E -- and which step of that run it is on
const F_REC := 6         ## $0484 -- which record it came from, one-based
## $049A -- the record's third byte: health, and for a collectable
## which of the sixteen it is.  $FF means it cannot be killed.
const F_LIFE := 7
const F_YHI := 8         ## $04B0 -- how many screens off the top, signed
const F_Y := 9           ## $04C6 -- where down the screen
const F_YFR := 10        ## $04DC -- and the 1/256ths of a point
const F_XHI := 11        ## $04F2
const F_X := 12          ## $0508
const F_XFR := 13        ## $051E
const F_VY := 14         ## $0534 -- whole points a step, signed
const F_VYFR := 15       ## $054A -- and the 1/256ths
const F_VX := 16         ## $0560
const F_VXFR := 17       ## $0576
const F_STATE := 18      ## $058C -- which row of the table laid after JSR $C97E
const F_HOLD := 19       ## $05A2 -- frames left to hold the step of the run
const F_STUN := 20       ## $05B8 -- while it is not zero the turn is skipped
const F_SELF := 21       ## $05CE -- to the type's own taste; often its record byte
const F_COUNT := 22      ## $05E4 -- a count of frames the type keeps itself
const F_KEEP := 23       ## $05FA -- to the type's own taste
const F_KEEP2 := 24      ## $0610 -- and another
const F_PUSH := 25       ## $0626 -- which way a blow threw it; also, for the
                         ##          ones that circle, the whole of the angle
const F_ANG := 26        ## $063C -- and its 1/256ths
const F_REC_BYTE := 27   ## $0652 -- where a type keeps the record's own byte
                         ##          when the field it came in is wanted
const F_GROUND := 28     ## $0668 -- nought in the air, $81 standing, $82 in
                         ##          the water that has risen


var lvl: Pb2Level
## Twenty-two rows of twenty-nine bytes.
var slots: Array = []
## $E5B1 -- which bit of `got` a collectable answers to.
var pickup_bit := PackedByteArray()
## $8401 -- which picture it wears.
var pickup_pic := PackedByteArray()
## The runs of pictures, out of bank 6 by way of $802D.
var anims: Array = []

## $9D72 -- how long the one that shuttles walks before it turns.
var swing := PackedByteArray()
## $9EE1 and $9EE9 -- eight speeds for the one that circles, low byte and high.
var spin_lo := PackedByteArray()
var spin_hi := PackedByteArray()
## $F301 -- a quarter of a turn's worth of cosine, out of the fixed bank.
var trig := PackedByteArray()
## $FD31 -- the shift that sits a thing on the floor line of its own tile.
var snap := PackedByteArray()
## $F64F -- the same quarter turn as $F301, scaled to $20 for $F5BA.
var aim := PackedByteArray()
## $8212 and $820A -- which sweep a type belongs to and how far past the edge
## that sweep lets a thing get.  Read from data/pb2/objects.json.
var cull_class := PackedByteArray()
var cull_margin := PackedByteArray()
var cull_rules: Array = []

## $8080 -- the minds the engine has of its own.  A type that is not in here
## is still told what it did; a type that is drives itself and is compared.
const MINDS := {0x02: "_mind_02", 0x10: "_mind_10",
		0x12: "_mind_12", 0x17: "_mind_17", 0x19: "_mind_19",
		0x1D: "_mind_1d"}

## $0119 -- one up every frame; $FB81 halves it between the places.
var clock := 0
## $2A -- while it is set the level stands still.
var frozen := 0
## $66:$67 -- where the view stands; the minds read the map through it.
var cam := 0
## $94 -- how far the view moved this frame; a thing that holds an old place
## of its own has to move it back by the same, or its circle would ride along
## with the screen instead of standing in the world.
var slide := 0
## $2B:$2C -- the sixteen collectables taken for good.
var got := 0
## $0172, $0171 long -- what this visit of the area has given out.
var done: Array = []
## $8A -- set as the area opens, so that the first scan fills the whole screen
## and not only its edge.  The first scan to reach the end of the list, or a
## record that is still ahead of the screen, puts it out.
var fill := 0


func _init(level: Pb2Level) -> void:
	lvl = level
	for i in range(SLOTS):
		slots.append(empty_row())
	var f := FileAccess.open("res://data/pb2/objects.json", FileAccess.READ)
	var t: Dictionary = JSON.parse_string(f.get_as_text())
	# Every number that comes back from JSON is a float, and a float will not
	# even be compared with a word without complaint, so they are put back into
	# the shape the code below expects once, here.
	pickup_bit = PackedByteArray(t["pickup_bit"])
	pickup_pic = PackedByteArray(t["pickup_pic"])
	cull_class = PackedByteArray(t["cull_class"])
	cull_margin = PackedByteArray(t["cull_margin"])
	for r in t["cull_rules"]:
		var rule := {}
		for k in ["horiz", "vert"]:
			rule[k] = r[k] if r[k] is String else int(r[k])
		cull_rules.append(rule)
	for v in t["swing"]:
		swing.append(int(v))
	for v in t["spin_lo"]:
		spin_lo.append(int(v))
	for v in t["spin_hi"]:
		spin_hi.append(int(v))
	for v in t["trig"]:
		trig.append(int(v))
	for v in t["snap"]:
		snap.append(int(v))
	for v in t["aim"]:
		aim.append(int(v))
	for r in t["anims"]:
		var run := {"last": int(r["last"]), "hold": int(r["hold"]),
				"first": int(r["first"])}
		if r.has("steps"):
			var steps := []
			for v in r["steps"]:
				steps.append(int(v))
			run["steps"] = steps
		anims.append(run)


static func empty_row() -> PackedByteArray:
	var row := PackedByteArray()
	row.resize(FIELDS)
	return row


## $E3F3.  `pos` is $66:$67 as the step begins, before the view has moved, and
## `shift` is how far it moved in the step BEFORE this one: the scan runs at
## $CF0E and the view is driven at $CF11, so what it reads is last step's.
func scan(pos: int, shift: int) -> void:
	if shift == 0 and fill == 0:
		return
	var world := _world(pos)
	var edge := (world >> 4) & 0xFF
	var list: Array = lvl.spawns
	for i in range(list.size()):
		var rec: Dictionary = list[i]
		var along: int = int(rec["along"])
		if along == END_OF_LIST:
			break
		# $E44D: everything before the view's own column is behind us.
		if along < edge:
			continue
		var delta: int = (along << 4) - world
		if delta > 0xFF:
			break                        # $E472 -- still ahead; so is the rest
		if delta < 0:
			continue                     # $E474 -- behind
		if fill == 0:
			# $E47E: only what has just come over the edge, and which edge
			# depends on which way the view is going.
			if shift >= 0:
				if delta < 0xF8:
					continue
			elif delta >= 0x08:
				continue
		_place(i + 1, rec, delta)
	fill = 0


## $E497 -- find it a slot, unless it already has one.
func _place(rec_index: int, rec: Dictionary, delta: int) -> void:
	var free := -1
	for n in range(FIRST_PLACED, LAST_PLACED + 1):
		var s: PackedByteArray = slots[n]
		if s[F_TYPE] == 0:
			free = n                     # $E50D -- the last free one wins
		elif s[F_REC] == rec_index:
			return                       # $E4AE -- it is out there already
	if free < 0:
		return                           # $E4BA -- no room; it is dropped
	# $E4BD and $E4C2 -- the two things that are not put out twice.
	if _gated(rec_index, rec):
		return
	# $D6D4 wiped the whole record a moment ago, high bytes and all.
	var s: PackedByteArray = empty_row()
	slots[free] = s
	s[F_TYPE] = int(rec["type"])
	s[F_LIFE] = int(rec["flags"])
	s[F_REC] = rec_index
	s[F_MARK] = 0x08
	# $E4DB: down a level the record's own number is the height and the other
	# byte the width; along a level it is the other way about.
	if lvl.vertical:
		s[F_X] = int(rec["across"])
		s[F_Y] = delta
	else:
		s[F_X] = delta
		s[F_Y] = int(rec["across"])


## Something that is not the level's list has written a type here.  The engine
## has no minds for the things yet, so it is simply told; what matters to the
## scan is only whether the place is free.
##
## A thing that was already there and merely changed into something else keeps
## its record: it is still that record's thing, and the scan must go on passing
## it by.  Only an empty place that fills from somewhere else becomes a stranger,
## with no record at all, so that no record ever takes it for itself.
func take(n: int, what: int) -> void:
	var s: PackedByteArray = slots[n]
	if s[F_TYPE] == 0:
		s[F_REC] = 0
	s[F_TYPE] = what


## $D6D4 -- everything about the slot goes, the record's number with it, so
## the same record will be made again if the view comes back over it.
func clear(n: int) -> void:
	slots[n] = empty_row()


## $E3F7 and $E422 -- how far the view has travelled counted in pixels.  Down a
## level a screen is two hundred and forty lines, not two hundred and fifty six.
func _world(pos: int) -> int:
	if lvl.vertical:
		return (pos >> 8) * 240 + (pos & 0xFF)
	return pos


## $D34D -- the view slid by `dv`, so everything standing on the screen slid
## back by it.  Both bytes at once: the console does it as a sixteen-bit
## subtraction, the low byte with the borrow going into the high one, and the
## sign of the slide carried up through $00.
##
## Only the way the level runs is touched; across it nothing scrolls.
func shift(dv: int) -> void:
	slide = dv & 0xFF
	var hi := F_YHI if lvl.vertical else F_XHI
	var lo := F_Y if lvl.vertical else F_X
	for n in range(FIRST_LIVE, SLOTS):
		var s: PackedByteArray = slots[n]
		if s[F_TYPE] == 0:
			continue
		var v := (((s[hi] << 8) | s[lo]) - dv) & 0xFFFF
		s[lo] = v & 0xFF
		s[hi] = v >> 8


## $8000 -- every place gets its turn, in order, once a step.
##
## For one place the order is sweep, then stun, then mind: the sweep at $8134
## runs first, and a place it has taken gets no turn this step.  $2A freezes
## the level, and while it is set only the door and the thing at $03 move.
##
## Returns the places the sweep freed, in the order it walked them.
func turns() -> Array:
	clock = (clock + 1) & 0xFF
	var gone := []
	for n in range(FIRST_LIVE, SLOTS):
		var s: PackedByteArray = slots[n]
		if s[F_TYPE] == 0:
			continue
		if _cull_one(s):
			clear(n)                       # $8024 -> $8075 -> $D6D4
			gone.append(n)
			continue
		if not _may_move(s):
			continue
		var mind = MINDS.get(s[F_TYPE])
		if mind != null:
			call(mind, n, s)
	return gone


## $8026 and $8043 -- a stunned thing always counts its stun down, and most of
## them lose the turn as well.  The ones that do not are the big and the tough:
## the bosses, four kinds in the middle of the table, and anything with $20 of
## health or more.
func _may_move(s: PackedByteArray) -> bool:
	if s[F_STUN] != 0:
		s[F_STUN] -= 1
		if not _acts_stunned(s):
			return false
	if frozen == 0:
		return true
	return s[F_TYPE] == 0x03 or s[F_TYPE] == 0x04    # $802F


func _acts_stunned(s: PackedByteArray) -> bool:
	var t: int = s[F_TYPE]
	if t >= 0x4F or t == 0x38 or t == 0x10 or t == 0x13:
		return true
	if t < 0x38 and ((t >= 0x1D and t < 0x20) or (t >= 0x2C and t < 0x2F)):
		return true
	return s[F_LIFE] >= 0x20                          # $806B


## $8134 -- who has gone far enough past the edge to be thrown away.


func _cull_one(s: PackedByteArray) -> bool:
	var rule: Dictionary = cull_rules[cull_class[s[F_TYPE]]]
	var h = rule["horiz"]
	if h is String:
		if h == "none":
			return false
		# $8172 -- the strictest of them: off the screen at all and it is gone.
		return s[F_XHI] != 0 or s[F_YHI] != 0
	return _off_side(s[F_XHI], s[F_X], h) or _off_down(s, rule["vert"])


## $81A4 -- the same shape for either pair.  A high byte of zero means the
## thing is on the screen and stays; otherwise the low byte says how far past
## the edge it has got, and the pair of margins says how far is too far.
func _off_side(hi: int, lo: int, pair: int) -> bool:
	if hi == 0:
		return false
	if hi >= 0x80:
		return lo < cull_margin[pair]          # $81AE
	return lo >= cull_margin[pair + 1]         # $81B7


func _off_down(s: PackedByteArray, rule) -> bool:
	if not (rule is String):
		return _off_side(s[F_YHI], s[F_Y], rule)   # $81D6
	if rule == "drop":
		# $81BD -- below the screen it is gone at once; above it there are
		# thirty-two lines of grace.
		if s[F_YHI] == 0:
			return false
		if s[F_YHI] < 0x80:
			return true
		return s[F_Y] < 0xE0
	# $81EF -- as 'drop', and gone at $D0 even while it is still on the screen.
	if s[F_YHI] == 0:
		return s[F_Y] >= 0xD0
	if s[F_YHI] < 0x80:
		return true
	return s[F_Y] < 0xE0


## $E523 and $E559 -- may this record come out at all?
##
## Two kinds of thing are not put out again.  A collectable (type $02) that
## has been taken is gone for the whole game: sixteen bits in `got` remember
## which.  Four other types -- the door, the two lifts and the switch -- are
## given out once per visit to an area, and `done` is the list of the records
## that have already been.
##
## Both are asked after a free place has been found and before anything is
## written, so a blocked record leaves the place free for the next one.
func _gated(rec_index: int, rec: Dictionary) -> bool:
	var kind := int(rec["type"])
	if kind == 0x02:
		var f := int(rec["flags"])
		# $E530: the top nibble says which of the sixteen it is, and the
		# bottom bit which of the two bytes holds it.
		var bit: int = pickup_bit[(f >> 4) & 0x0F]
		var word: int = (got >> 8) if (f & 1) else (got & 0xFF)
		return (word & bit) != 0
	if kind in ONCE_A_VISIT:
		return done.has(rec_index)
	return false


# --- The common step ---------------------------------------------------
#
# A mind never adds place to speed itself: it sets a speed and calls one of
# these, all of which live in the fixed bank 15.  So the walk of every one of
# the ninety types is this handful of lines, ported once.  Discussed in
# work/re/pb2_object_move.md.


## $FA0B -- one step down.  Three bytes of place, two of speed, both signed;
## the sign of the whole-points byte is what reaches the third byte of place.
func step_down(s: PackedByteArray) -> void:
	var far := 0xFF if s[F_VY] >= 0x80 else 0x00
	var v: int = s[F_YFR] + s[F_VYFR]
	s[F_YFR] = v & 0xFF
	v = s[F_Y] + s[F_VY] + (v >> 8)
	s[F_Y] = v & 0xFF
	s[F_YHI] = (s[F_YHI] + far + (v >> 8)) & 0xFF


## $FA2F -- the same across.
func step_side(s: PackedByteArray) -> void:
	var far := 0xFF if s[F_VX] >= 0x80 else 0x00
	var v: int = s[F_XFR] + s[F_VXFR]
	s[F_XFR] = v & 0xFF
	v = s[F_X] + s[F_VX] + (v >> 8)
	s[F_X] = v & 0xFF
	s[F_XHI] = (s[F_XHI] + far + (v >> 8)) & 0xFF


## $FA08 -- both, and the order matters: across first.
func step_both(s: PackedByteArray) -> void:
	step_side(s)
	step_down(s)


## $FA55 -- shift down where it stands, without touching its speed.  `frac` is
## the 1/256ths, `whole` the points, signed.
func nudge_down(s: PackedByteArray, frac: int, whole: int) -> void:
	var far := 0xFF if whole >= 0x80 else 0x00
	var v: int = s[F_YFR] + frac
	s[F_YFR] = v & 0xFF
	v = s[F_Y] + whole + (v >> 8)
	s[F_Y] = v & 0xFF
	s[F_YHI] = (s[F_YHI] + far + (v >> 8)) & 0xFF


## $FA75 -- and across.
func nudge_side(s: PackedByteArray, frac: int, whole: int) -> void:
	var far := 0xFF if whole >= 0x80 else 0x00
	var v: int = s[F_XFR] + frac
	s[F_XFR] = v & 0xFF
	v = s[F_X] + whole + (v >> 8)
	s[F_X] = v & 0xFF
	s[F_XHI] = (s[F_XHI] + far + (v >> 8)) & 0xFF


## $F9BD and $F9B5 -- set a speed outright.  `whole` is the points a step,
## `frac` the 1/256ths.
func set_speed_down(s: PackedByteArray, whole: int, frac: int) -> void:
	s[F_VY] = whole & 0xFF
	s[F_VYFR] = frac & 0xFF


func set_speed_side(s: PackedByteArray, whole: int, frac: int) -> void:
	s[F_VX] = whole & 0xFF
	s[F_VXFR] = frac & 0xFF


## $FA93 -- add to the speed down as a fraction of a point.  This is weight:
## how much is the type's own business, but the shape is always this.
func add_speed_down(s: PackedByteArray, frac: int) -> void:
	var v: int = ((s[F_VY] << 8) | s[F_VYFR]) + frac
	s[F_VY] = (v >> 8) & 0xFF
	s[F_VYFR] = v & 0xFF


## $FAA3 -- the same across.
func add_speed_side(s: PackedByteArray, frac: int) -> void:
	var v: int = ((s[F_VX] << 8) | s[F_VXFR]) + frac
	s[F_VX] = (v >> 8) & 0xFF
	s[F_VXFR] = v & 0xFF


## $FAB3 and $FAC7 -- take away instead.
func sub_speed_down(s: PackedByteArray, frac: int) -> void:
	var v: int = (((s[F_VY] << 8) | s[F_VYFR]) - frac) & 0xFFFF
	s[F_VY] = v >> 8
	s[F_VYFR] = v & 0xFF


func sub_speed_side(s: PackedByteArray, frac: int) -> void:
	var v: int = (((s[F_VX] << 8) | s[F_VXFR]) - frac) & 0xFFFF
	s[F_VX] = v >> 8
	s[F_VXFR] = v & 0xFF


## $F99F and $F989 -- turn a speed round, all sixteen bits of it.
func flip_speed_down(s: PackedByteArray) -> void:
	var v: int = (-((s[F_VY] << 8) | s[F_VYFR])) & 0xFFFF
	s[F_VY] = v >> 8
	s[F_VYFR] = v & 0xFF


func flip_speed_side(s: PackedByteArray) -> void:
	var v: int = (-((s[F_VX] << 8) | s[F_VXFR])) & 0xFFFF
	s[F_VX] = v >> 8
	s[F_VXFR] = v & 0xFF


## $F980 -- look the other way.  $F97D is this and flip_speed_side together.
func turn(s: PackedByteArray) -> void:
	s[F_BITS] = s[F_BITS] ^ 0x40


## $F9DC -- is the hero to the left of it?  True when he is: the console
## returns this as the carry, set when the thing is the further along.
func hero_is_left(s: PackedByteArray) -> bool:
	if s[F_XHI] >= 0x80:
		return false
	if s[F_XHI] != 0:
		return true
	return s[F_X] >= slots[0][F_X]


## $F9C5 -- face him: bit 6 set means he is on the far side.
func face_hero(s: PackedByteArray) -> void:
	if hero_is_left(s):
		s[F_BITS] = s[F_BITS] & 0xBF
	else:
		s[F_BITS] = s[F_BITS] | 0x40


## $FB81 -- whose turn it is to look at the ground.  The count of frames is
## halved and the places share it out between them, so a thing sees the floor
## every other frame and never on the same frame as its neighbour.  Its walk
## and the way it falls off a ledge both hang on this, so it is kept.
func its_turn(n: int, clock: int) -> bool:
	return ((n ^ clock) & 1) == 0


## $F8A1 ($C8DF) -- put a new thing out beside this one, of the type in $24.
##
## The offsets are signed bytes, and a thing may not be born off the screen:
## if either of the two high bytes comes out other than zero the cartridge
## pulls the caller's own return address off the stack and gives up, so the
## mind that asked gets nothing more done that turn.  Here that is the -1.
##
## Only the eight places from six to thirteen can hold what a thing bears
## ($CB1B); the eight above them belong to the level's own list.
func make_child(s: PackedByteArray, side: int, down: int, what: int) -> int:
	var x: int = ((s[F_XHI] << 8) | s[F_X]) + _signed(side)
	if (x >> 8) & 0xFF:
		return -1
	var y: int = ((s[F_YHI] << 8) | s[F_Y]) + _signed(down)
	if (y >> 8) & 0xFF:
		return -1
	for n in range(FIRST_LIVE, FIRST_PLACED):
		var c: PackedByteArray = slots[n]
		if c[F_TYPE] != 0:
			continue
		c[F_TYPE] = what
		c[F_MARK] = 0x08
		c[F_X] = x & 0xFF
		c[F_Y] = y & 0xFF
		return n
	return -1


## $F9EE and $F9F7 -- set the sideways speed and then point it the right way.
## $F9EE turns to face the hero first; $F9F7 keeps whichever way it already
## looks.  Either way a thing that looks left walks left.
func set_speed_side_facing(s: PackedByteArray, whole: int, frac: int) -> void:
	set_speed_side(s, whole, frac)
	if s[F_BITS] & 0x40:
		flip_speed_side(s)


func set_speed_side_at_hero(s: PackedByteArray, whole: int, frac: int) -> void:
	set_speed_side(s, whole, frac)
	face_hero(s)
	if s[F_BITS] & 0x40:
		flip_speed_side(s)


## $FD98 -- some records ask for the thing to stand half a tile over from
## where the list put it: across in a level that scrolls sideways, down in one
## that scrolls up.
func nudge_eight(s: PackedByteArray, rec_byte: int) -> void:
	if not (rec_byte & 0x40):
		return
	if lvl.vertical:
		nudge_down(s, 0, 8)
	else:
		nudge_side(s, 0, 8)


# --- Round the circle ---
#
# $F245 answers where a point is, given how far round it has gone and how far
# out it is.  It is built out of $F274, which does one axis, and $F2E6, which
# multiplies a length by a point of the cosine table.  Nothing here is
# rounded the way a book would round it: the multiply adds the carry that
# fell out of reading the next bit of the table, so the answer is a point or
# two off from the true cosine, and that is the answer the cartridge gives.


## $F2E6 -- how much of `mag` is left after `i` sixty-fourths of a quarter
## turn.  The first two entries are never really read: the cartridge answers
## the whole length instead.
func _trig(i: int, mag: int) -> int:
	if i < 2:
		return mag
	var t: int = trig[i]
	var a := 0
	for _k in range(8):
		var carry: int = t & 1
		t >>= 1
		if carry == 1:
			var sum: int = a + mag + 1
			a = sum & 0xFF
			carry = sum >> 8
		a = ((carry << 7) | (a >> 1)) & 0xFF
	return a


## $F274 -- `mag` points along the angle `ang`, as a pair of signed bytes.
func _along(mag: int, ang: int) -> Array:
	if mag == 0:
		return [0, 0]
	if mag >= 0x80:
		mag = (-mag) & 0xFF
		ang = ang ^ 0x80
	var q: int = ang & 0x3F
	var i := 0
	var j := 0
	if q == 0:
		if ang & 0x40:
			i = 0x40
		else:
			j = 0x40
	elif ang & 0x40:
		i = (-q) & 0x3F
		j = q
	else:
		i = q
		j = (-q) & 0x3F
	var side: int = _trig(i, mag)
	var down: int = _trig(j, mag)
	if ang & 0x80:
		down = (-down) & 0xFF
	if ((ang + 0x40) & 0xFF) >= 0x80:
		side = (-side) & 0xFF
	return [side, down]


## $F245 ($C88B) -- two lengths at right angles make an ellipse, not a circle;
## the minds that use it hand one of the two as zero.  Answers [across, down].
func around(ang: int, out_side: int, out_down: int) -> Array:
	var a: Array = _along(out_side, ang)
	var b: Array = _along(out_down, (ang + 0x40) & 0xFF)
	return [(a[0] + b[0]) & 0xFF, (a[1] + b[1]) & 0xFF]


## $E2D5 ($C83A, wrapper $BEAD) -- start a run of pictures over.
func start_anim(s: PackedByteArray, which: int) -> void:
	s[F_ANIM] = which
	var run: Dictionary = anims[which]
	s[F_HOLD] = int(run["hold"])
	s[F_KIND] = int(run["first"])
	s[F_STEP] = 0


## $E30F ($C837) -- hold the step a frame longer, and when its frames are up
## go on to the next; at the end of the run it starts again.
func step_anim(s: PackedByteArray) -> int:
	s[F_HOLD] = (s[F_HOLD] - 1) & 0xFF
	if s[F_HOLD] != 0:
		return s[F_HOLD]
	return _next_step(s, s[F_ANIM])


## $E309 ($C88E) -- the same, except that the run to go on with is named
## rather than taken from the thing: $E309 walks into the middle of $E30F,
## past the load of $0458.  Finish this step, then carry on in that run.
func step_anim_into(s: PackedByteArray, which: int) -> int:
	s[F_HOLD] = (s[F_HOLD] - 1) & 0xFF
	if s[F_HOLD] != 0:
		return s[F_HOLD]
	return _next_step(s, which)


## Answers with the picture it settled on, because that is what the console
## leaves in A and what the minds that watch a swing through look at.
func _next_step(s: PackedByteArray, which: int) -> int:
	var run: Dictionary = anims[which]
	s[F_HOLD] = int(run["hold"])
	var last: int = int(run["last"])
	if s[F_STEP] == last:
		s[F_STEP] = 0
	else:
		s[F_STEP] += 1
	# $E374 -- a long record does not walk the pictures one after another; it
	# has a list of its own, and the step picks out of that.
	if run.has("steps"):
		var steps: Array = run["steps"]
		s[F_KIND] = (int(run["first"]) + int(steps[s[F_STEP]])) & 0xFF
	else:
		s[F_KIND] = (int(run["first"]) + s[F_STEP]) & 0xFF
	return s[F_KIND]


# --- What a thing sees under it ----------------------------------------


## $10 -- the lines at the head of a page the view never shows ($F438).
const VIEW_TOP := 0x10


## $F342 ($C888) -- what the ground is, this far along and this far down from
## the thing.  Both offsets are signed bytes; the answer is one of the four
## bytes of $F5A9 while the point is on the screen, and the ground's own kind
## once it is not -- the cartridge reads the two through different doors and
## does not make them agree, and neither do we.
func ground(s: PackedByteArray, side_off: int, down_off: int) -> int:
	var sx: int = (((s[F_XHI] << 8) | s[F_X]) + _signed(side_off)) & 0xFFFF
	var sy: int = (((s[F_YHI] << 8) | s[F_Y]) + _signed(down_off)) & 0xFFFF
	var xhi: int = sx >> 8
	var xlo: int = sx & 0xFF
	var yhi: int = sy >> 8
	var ylo: int = sy & 0xFF
	# $F36A -- across the level is one screen wide, and the question is never
	# let out past its edge: it is pulled back to the edge instead.  The screen
	# byte itself is left as it was, and the roads below still look at it, so a
	# point pulled back can still be a point off the screen.
	if lvl.vertical:
		if xhi != 0:
			xlo = 0x00 if xhi >= 0x80 else 0xFF
	elif yhi != 0:
		ylo = VIEW_TOP if yhi >= 0x80 else 0xAF
	else:
		ylo = clampi(ylo, VIEW_TOP, 0xAF)
	var off: bool = xhi != 0 or yhi != 0
	if lvl.kind == 7:
		# $F3CA -- everything below the hundred and forty fourth line of this
		# kind of area is wall, and past the screen a ground of kind three
		# counts as wall too.
		if off:
			var far: int = _ground_far(xhi, xlo, yhi, ylo)
			return 0x80 if far == 0x03 else far
		return _ground_near(xlo, ylo) if ylo < 0x90 else 0x80
	if lvl.kind == 4 or lvl.kind == 10:
		# $F40D and $F3E3 both bend the question around $29, which is not a
		# constant: it is the line the lava or the water has risen to, and the
		# engine does not keep it yet.  One area apiece uses these, and until
		# $29 is kept they are answered as any other area would be, which is
		# right everywhere the water is not.
		pass
	# $F3FC
	if off or ylo >= 0xB0:
		return _ground_far(xhi, xlo, yhi, ylo)
	return _ground_near(xlo, ylo)


## $F52C -- the cell under a point of the screen, as one of the four bytes.
## This is the same question the hero asks and the same answer he gets.
func _ground_near(sx: int, sy: int) -> int:
	if sy >= 0xE0:
		return 0x00
	if lvl.vertical:
		return lvl.class_byte(sx, Pb2Level.map_row(cam, sy))
	return lvl.class_byte(cam + sx, sy - VIEW_TOP)


## $F42C -- past the edge of the screen the cache holds nothing, so the map
## itself is read, and what comes back is the ground's own kind.
func _ground_far(xhi: int, xlo: int, yhi: int, ylo: int) -> int:
	if lvl.vertical:
		return lvl.terrain_at(xlo, _line(yhi, ylo))
	var far: int = (xhi << 8) | xlo
	if xhi >= 0x80:
		far -= 0x10000
	return lvl.terrain_at(cam + far, ylo - VIEW_TOP)


## $F45B and $F479 -- which line of the map a line below the view falls on,
## when the view may be more than a page away.  The console keeps the level in
## pages of two hundred and forty lines and reads it in pages of two hundred
## and fifty six, so sixteen lines are added for every page boundary crossed.
func _line(hi: int, lo: int) -> int:
	var far: int = (hi << 8) | lo
	if hi >= 0x80:
		far -= 0x10000
	var total: int = (cam >> 8) * 240 + (cam & 0xFF) + far
	var page: int = floori(float(total) / 240.0)
	return page * 256 + (total - page * 240)


## $FB88 ($C945) -- ask the ground, but only when it is this thing's turn;
## when it is not, the answer is that there is nothing there.
func ground_turn_clear(n: int, s: PackedByteArray, side: int,
		down: int) -> int:
	if not its_turn(n, clock):
		return 0x00
	return ground(s, side, down)


## $FB92 ($C948) -- the same, but out of turn the answer is a wall.
func ground_turn_wall(n: int, s: PackedByteArray, side: int,
		down: int) -> int:
	if not its_turn(n, clock):
		return 0x80
	return ground(s, side, down)


## $FBBA ($C94B through $BED7) -- is there a wall this far out to either side?
## The same question is put twice, once each way, and one wall is enough.
func walled_either(s: PackedByteArray, side: int, down: int) -> int:
	if ground(s, side, down) & 0x80:
		return 0x80
	if ground(s, (-_signed(side)) & 0xFF, down) & 0x80:
		return 0x80
	return 0x00


## $FBA6 ($C94E) and $FBB0 ($C951) -- the same, in turn only.
func walled_either_turn(n: int, s: PackedByteArray, side: int, down: int,
		out_of_turn: int) -> int:
	if not its_turn(n, clock):
		return out_of_turn
	return walled_either(s, side, down)


## A byte the cartridge reads as a signed offset.
static func _signed(b: int) -> int:
	return b - 0x100 if b >= 0x80 else b


## $CAF1 ($C870) -- how far the hero is above or below, as a plain length.
func hero_gap_down(s: PackedByteArray) -> int:
	var d: int = s[F_Y] - slots[0][F_Y]
	return d if d >= 0 else -d


## $FD1D and $FD20 -- sit the thing on the floor line of the tile it is in.
## Down a level the view's own place is counted in, because there the map
## slides under the thing instead of past it.
func snap_down(s: PackedByteArray) -> void:
	var y: int = s[F_Y]
	if lvl.vertical:
		y = (y + (cam & 0xFF)) & 0xFF
	nudge_down(s, 0, snap[y & 0x0F])


## $FD16 -- the same, reckoned from a place `off` below where it stands.
func snap_down_from(s: PackedByteArray, off: int) -> void:
	var y: int = (s[F_Y] + off) & 0xFF
	if lvl.vertical:
		y = (y + (cam & 0xFF)) & 0xFF
	nudge_down(s, 0, snap[y & 0x0F])


## $9C44 -- is it under the water that has risen?  Only kinds five and nine of
## an area have such water, and how high it stands lives in $29, which is not
## kept yet: one area apiece uses those kinds.  Until it is, the answer is no,
## which is the answer for every other area anyway.
func in_water(_s: PackedByteArray) -> bool:
	return false


## $9BD0 -- fall or stand.  A thing already standing is left standing: it is
## whatever knocked it off that clears the field, not this.
func ground_stand(s: PackedByteArray) -> void:
	if s[F_GROUND] == 0x81:
		if not in_water(s):
			return
	if ground(s, 0x00, 0x01) >= 0x80:
		snap_down(s)
		s[F_GROUND] = 0x81
	else:
		s[F_GROUND] = 0x00


## $9BA5 -- the same, and then drowning: a thing in the risen water with
## nothing under it at `deep` is taken away.  Nothing can be in that water
## until $29 is kept, so for now this is only the standing.
func ground_stand_deep(s: PackedByteArray, _deep: int) -> void:
	ground_stand(s)


## $FBF0 -- is there a wall the way it is looking?  The offset across is
## turned about when it looks the other way, and the ground is asked at two
## heights: one wall is enough.
func walled_ahead(s: PackedByteArray, side: int, first: int,
		second: int) -> int:
	var a: int = side
	if s[F_BITS] & 0x40:
		a = (-_signed(a)) & 0xFF
	if ground(s, a, first) >= 0x80:
		return 0x80
	if ground(s, a, second) >= 0x80:
		return 0x80
	return 0x00


## $FBD7, $FBDC and $FBE6 -- asked every frame, or only on the thing's own
## frame with a settled answer for the frames in between.  $FBDC answers "no
## wall" out of turn and $FBE6 answers "a wall".
func walled_ahead_turn(n: int, s: PackedByteArray, side: int, first: int,
		second: int, out_of_turn: int) -> int:
	if not its_turn(n, clock):
		return out_of_turn
	return walled_ahead(s, side, first, second)


## $FC16 -- $FBDC, and turn round where there is a wall.
func walled_ahead_turn_about(n: int, s: PackedByteArray, side: int,
		first: int, second: int) -> void:
	if walled_ahead_turn(n, s, side, first, second, 0x00) >= 0x80:
		turn(s)
		flip_speed_side(s)


## $F637 -- how much of a length is left after `i` sixty-fourths of a quarter
## turn, to sixteen bits.  The same missing CLC as $F2E6: read the note there.
func _aim16(i: int, mag: int) -> Array:
	var t: int = aim[i]
	var a := 0
	var f := 0
	for _k in range(8):
		var carry: int = t & 1
		t >>= 1
		if carry == 1:
			var sum: int = a + mag + 1
			a = sum & 0xFF
			carry = sum >> 8
		var out: int = a & 1
		a = ((carry << 7) | (a >> 1)) & 0xFF
		f = ((out << 7) | (f >> 1)) & 0xFF
	return [a, f]


## $F5BA -- point a speed of `mag` along the angle `ang`.  This is $F274 over
## again, but the answer goes straight into the speed and keeps its fraction.
## A length of nought stops the thing outright.
func set_speed_at(s: PackedByteArray, mag: int, ang: int) -> void:
	if mag == 0:
		s[F_VXFR] = 0
		s[F_VX] = 0
		s[F_VYFR] = 0
		s[F_VY] = 0
		return
	var m: int = (mag - 1) & 0xFF
	var q: int = ang & 0x3F
	var i := 0
	var j := 0
	if q == 0:
		if ang & 0x40:
			i = 0x40
		else:
			j = 0x40
	elif ang & 0x40:
		i = (-q) & 0x3F
		j = q
	else:
		i = q
		j = (-q) & 0x3F
	var side: Array = _aim16(i, m)
	s[F_VX] = side[0]
	s[F_VXFR] = side[1]
	var down: Array = _aim16(j, m)
	s[F_VY] = down[0]
	s[F_VYFR] = down[1]
	if ang & 0x80:
		flip_speed_down(s)
	if ((ang + 0x40) & 0xFF) >= 0x80:
		flip_speed_side(s)


## $F8D3 ($C8E5) -- put a new thing out beside this one and send it off at an
## angle.  As with $F8A1 neither the child nor the parent may be off the
## screen; the cartridge gives up on the whole turn where it is, and the -1
## here stands for that.
func make_child_aimed(s: PackedByteArray, side: int, down: int, what: int,
		mag: int, ang: int) -> int:
	var x: int = ((s[F_XHI] << 8) | s[F_X]) + _signed(side)
	if (x >> 8) & 0xFF:
		return -1
	var y: int = ((s[F_YHI] << 8) | s[F_Y]) + _signed(down)
	if (y >> 8) & 0xFF:
		return -1
	if s[F_XHI] != 0 or s[F_YHI] != 0:                 # $F913
		return -1
	for n in range(FIRST_LIVE, FIRST_PLACED):
		var c: PackedByteArray = slots[n]
		if c[F_TYPE] != 0:
			continue
		c[F_TYPE] = what
		c[F_X] = x & 0xFF
		c[F_Y] = y & 0xFF
		c[F_MARK] = 0x08
		set_speed_at(c, mag, ang)
		return n
	return -1


# --- The minds ---------------------------------------------------------


## $83EA -- a collectable.  It does nothing at all: on its first turn it says
## what it is (the mark $40, which is what makes the hero pick it up rather
## than be hurt by it) and picks its picture out of the record's own byte, and
## from then on its state is one and it returns at once.
func _mind_02(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] != 0:
		return
	s[F_MARK] = 0x40                       # $C9A8 -> $FD82
	s[F_KIND] = pickup_pic[s[F_LIFE] & 0x0F]
	s[F_STATE] += 1                        # $C966 -> $FCEE


## $9DA5 -- the one that walks to and fro and drops something behind it.
func _mind_17(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _wake_17(s)
		1: _walk_17(n, s)
		2: _wait_17(s)


## $9DAE -- it keeps the record's byte for itself, because the field it came
## in is wanted for the one hit that kills it.  The byte says two things: the
## bottom bit which of two pictures it wears and how far down it drops what it
## drops, and the top bit whether it walks a point a frame or half of one.
func _wake_17(s: PackedByteArray) -> void:
	s[F_SELF] = s[F_LIFE]
	s[F_LIFE] = 0x01                       # $BE5A
	s[F_MARK] = 0x01
	s[F_KIND] = 0x12 if s[F_SELF] & 1 else 0x1A
	if s[F_SELF] & 0x80:
		set_speed_side(s, 0x00, 0x80)      # $BEB3 with 80 00
		s[F_COUNT] = 0x30
	else:
		set_speed_side(s, 0x01, 0x00)      # $BEB3 with 00 01
		s[F_COUNT] = 0x18
	s[F_STATE] += 1


## $9DE3 -- walk until the count runs out, then drop one behind.  Behind is
## against the way it is going, sixteen points off, and what it drops is told
## whose it is: the new thing keeps the place of its parent in the same field.
func _walk_17(n: int, s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		step_side(s)
		return
	s[F_COUNT] = 0x40
	var side: int = 0x10 if s[F_VX] & 0x80 else 0xF0
	var down: int = 0x04 if s[F_SELF] & 1 else 0xFF
	var born: int = make_child(s, side, down, 0x18)
	if born >= 0:
		slots[born][F_SELF] = n
	s[F_STATE] += 1


## $9E17 -- stand still while the count runs out, then turn round and walk
## again.  It is the way it moves that turns, not the way it looks.
func _wait_17(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	s[F_COUNT] = 0x60 if s[F_SELF] & 0x80 else 0x30
	flip_speed_side(s)
	s[F_STATE] -= 1



## $8BED -- the one that swims up and down while it drifts across.
func _mind_12(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		set_speed_down(s, 0x00, 0x00)              # $BEB9 with 00 00
		set_speed_side_at_hero(s, 0xFE, 0x80)      # $BEBF with 80 FE
		start_anim(s, 3)
		s[F_LIFE] = 0x01                           # $BE5A
		s[F_MARK] = 0x01
		s[F_STATE] += 1
		return
	# $8C09 -- $FA05: the picture goes on and it moves both ways.
	step_anim(s)
	step_both(s)
	if s[F_COUNT] == 0:
		add_speed_down(s, 0x40)
		# Only the whole points are looked at going down, so it turns round
		# the moment it reaches four, whatever the fraction.
		if s[F_VY] == 0x04:
			s[F_COUNT] = 1
	else:
		sub_speed_down(s, 0x40)
		# Going up it waits for four exactly, fraction and all.
		if s[F_VY] == 0xFC and s[F_VYFR] == 0:
			s[F_COUNT] = 0


## $9D1F -- the one that shuttles to and fro on a count of its own.
func _mind_19(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		var rec: int = s[F_LIFE]
		s[F_REC_BYTE] = rec
		nudge_eight(s, rec)                        # $FD98
		s[F_MARK] = 0x20                           # $FD7E
		s[F_STATE] += 1                            # $FCEE
		s[F_KIND] = 0x20                           # $BE6E
		_wind_19(s)
		var frac: int = 0x80 if rec & 0x04 else 0x00
		if rec & 0x80:
			set_speed_side(s, 0xFF, frac)
		else:
			set_speed_down(s, 0xFF, frac)
		return
	# $9D53 -- walk, and when the count is out turn both ways round at once.
	step_both(s)
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] != 0:
		return
	_wind_19(s)
	flip_speed_side(s)
	flip_speed_down(s)


## $9D65 -- how many frames the next leg lasts.
func _wind_19(s: PackedByteArray) -> void:
	s[F_SELF] = swing[s[F_REC_BYTE] & 0x0F]


## $9E2F -- the one that circles a place it remembers.
func _mind_10(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		# The place it stands at is the middle of the circle from now on.
		s[F_SELF] = s[F_X]
		s[F_COUNT] = s[F_XHI]
		s[F_KEEP] = s[F_Y]
		s[F_KEEP2] = s[F_YHI]
		s[F_REC_BYTE] = s[F_LIFE]
		s[F_MARK] = 0x20                           # $FD7E
		s[F_KIND] = 0x1D                           # $BE6E
		s[F_STATE] += 1                            # $FCEE
		return
	# $9E5C -- hold the middle still in the world while the view moves.
	var far: int = 0xFF if slide >= 0x80 else 0x00
	if lvl.vertical:
		var v: int = (((s[F_KEEP2] << 8) | s[F_KEEP]) - slide - far * 0x100) \
				& 0xFFFF
		s[F_KEEP] = v & 0xFF
		s[F_KEEP2] = v >> 8
	else:
		var v: int = (((s[F_COUNT] << 8) | s[F_SELF]) - slide - far * 0x100) \
				& 0xFFFF
		s[F_SELF] = v & 0xFF
		s[F_COUNT] = v >> 8
	# How far out, by the top bit of the record; how fast, by the low three.
	var out: int = 0xD0 if s[F_REC_BYTE] >= 0x80 else 0xE0
	var which: int = s[F_REC_BYTE] & 0x07
	var ang: int = ((s[F_PUSH] << 8) | s[F_ANG]) \
			+ ((spin_hi[which] << 8) | spin_lo[which])
	s[F_ANG] = ang & 0xFF
	s[F_PUSH] = (ang >> 8) & 0xFF
	var off: Array = around(s[F_PUSH], 0x00, out)
	var x: int = (((s[F_COUNT] << 8) | s[F_SELF])
			+ _signed(off[0])) & 0xFFFF
	s[F_X] = x & 0xFF
	s[F_XHI] = x >> 8
	var y: int = (((s[F_KEEP2] << 8) | s[F_KEEP])
			+ _signed(off[1])) & 0xFFFF
	s[F_Y] = y & 0xFF
	s[F_YHI] = y >> 8


## $8E9D -- the one that walks the floor and stops to shoot.  Whatever it is
## doing, it falls first.
func _mind_1d(n: int, s: PackedByteArray) -> void:
	ground_stand_deep(s, 0xF2)                         # $9BA5 with $F2
	match s[F_STATE]:
		0: _wake_1d(s)
		1: _walk_1d(n, s)
		2: _raise_1d(s)
		3: _fire_1d(s)
		4: _lower_1d(s)
		5: _stuck_1d(n, s)


## $8EB1
func _wake_1d(s: PackedByteArray) -> void:
	s[F_MARK] = 0x20                                   # $FD7E
	s[F_KIND] = 0x31                                   # $BE6E
	s[F_LIFE] = 0x02                                   # $BE63
	s[F_COUNT] = 0x30                                  # $BE7C
	s[F_STATE] += 1


## $8EC3 -- walk.  Far above or below him it takes its time; level with him it
## hurries, and counts down to the moment it stops and shoots.
func _walk_1d(n: int, s: PackedByteArray) -> void:
	if hero_gap_down(s) >= 0x10:
		set_speed_side_facing(s, 0xFF, 0x80)           # $BEC5 with 80 FF
	else:
		s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
		if s[F_COUNT] == 0:
			# $8F04 -- turn to him and start the swing.
			face_hero(s)
			start_anim(s, 4)
			s[F_STATE] += 1
			return
		set_speed_side_facing(s, 0xFE, 0x00)           # $BEC5 with 00 FE
	# $BF06 with F6 F1 FF -- a wall ten points ahead, at two heights.
	if walled_ahead_turn(n, s, 0xF6, 0xFF, 0xF1, 0x00) >= 0x80:
		_stop_1d(s)
		return
	# And the ledge: eight ahead and four down.  Out of its own turn the
	# answer is a floor, so it walks two frames for every one it looks.
	var ahead: int = 0x08 if s[F_BITS] & 0x40 else 0xF8
	if ground_turn_wall(n, s, ahead, 0x04) >= 0x80 or in_water(s):
		step_both(s)
		return
	_stop_1d(s)


## $8EFD -- there is nowhere to walk: stand a moment, then turn.
func _stop_1d(s: PackedByteArray) -> void:
	s[F_KEEP] = 0x04                                   # $BE83
	s[F_STATE] = 5                                     # $FD0A


## $8F0E -- the swing goes up; at the top of it the arm is out and it can hurt.
func _raise_1d(s: PackedByteArray) -> void:
	if step_anim(s) != 0x33:
		return
	s[F_COUNT] = 0x18                                  # $BE7C
	s[F_MARK] = 0x01                                   # $FD76
	s[F_STATE] += 1


## $8F20 -- hold the arm out, and at the end of it let two go at once.
func _fire_1d(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	_shoot_1d(s, 0xF8, 0xF8, 0xA0)
	s[F_STATE] += 1


## $8F63 -- two shots, one after the other, and the angle of each is turned
## about when it is looking the other way.
func _shoot_1d(s: PackedByteArray, down: int, side: int, ang: int) -> void:
	var a: int = ang
	if s[F_BITS] & 0x40:
		a = a ^ 0x40
	_shoot_one_1d(s, down, side, a)
	a = 0x00 if s[F_BITS] & 0x40 else 0x80
	_shoot_one_1d(s, down, side, a)


## $8F7C
func _shoot_one_1d(s: PackedByteArray, down: int, side: int,
		ang: int) -> void:
	var across: int = side
	if s[F_BITS] & 0x40:
		across = ((-_signed(across)) + 1) & 0xFF
	make_child_aimed(s, across, down, 0x14, 0x0C, ang)


## $8F36 -- the arm comes down and it walks again.
func _lower_1d(s: PackedByteArray) -> void:
	if step_anim(s) != 0x31:
		return
	s[F_MARK] = 0x20                                   # $FD7E
	s[F_COUNT] = 0x30                                  # $BE7C
	s[F_STATE] = 1                                     # $FCFA


## $8F48 -- stood against a wall or a drop.  Turn, and if that way is walled
## too, turn back and try again in two frames.
func _stuck_1d(n: int, s: PackedByteArray) -> void:
	s[F_KEEP] = (s[F_KEEP] - 1) & 0xFF
	if s[F_KEEP] != 0:
		return
	turn(s)
	flip_speed_side(s)                                 # $F97D
	# $BF00 -- this one is asked every frame, not every other.
	if walled_ahead(s, 0xF6, 0xFF, 0xF1) < 0x80:
		s[F_STATE] = 1                                 # $FCFA
		return
	turn(s)
	flip_speed_side(s)
	s[F_KEEP] = 0x02                                   # $BE83
