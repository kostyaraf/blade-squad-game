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
const F_KIND := 3        ## $0442 -- to the type's own taste
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
const F_STUN := 20       ## $05B8 -- while it is not zero the turn is skipped
const F_PUSH := 25       ## $0626 -- which way a blow threw it


var lvl: Pb2Level
## Twenty-two rows of twenty-nine bytes.
var slots: Array = []
## $E5B1 -- which bit of `got` a collectable answers to.
var pickup_bit := PackedByteArray()
## $8401 -- which picture it wears.
var pickup_pic := PackedByteArray()
## $8212 and $820A -- which sweep a type belongs to and how far past the edge
## that sweep lets a thing get.  Read from data/pb2/objects.json.
var cull_class := PackedByteArray()
var cull_margin := PackedByteArray()
var cull_rules: Array = []

## $8080 -- the minds the engine has of its own.  A type that is not in here
## is still told what it did; a type that is drives itself and is compared.
const MINDS := {0x02: "_mind_02"}

## $0119 -- one up every frame; $FB81 halves it between the places.
var clock := 0
## $2A -- while it is set the level stands still.
var frozen := 0
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
