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


class Slot:
	var type := 0                ## $0400,X -- what it is; zero means empty
	var flags := 0               ## $049A,X -- record byte three
	var rec := 0                 ## $0484,X -- which record, one-based
	var x := 0                   ## $0508,X -- where on the screen, across it
	var xhi := 0                 ## $04F2,X -- and how many screens off the side
	var y := 0                   ## $04C6,X -- where on the screen, down it
	var yhi := 0                 ## $04B0,X -- and how many screens off the top
	var mark := 0               ## $0416,X -- set to eight at birth


var lvl: Pb2Level
var slots: Array = []
## $E5B1 -- which bit of `got` a collectable answers to.
var pickup_bit := PackedByteArray()
## $8212 and $820A -- which sweep a type belongs to and how far past the edge
## that sweep lets a thing get.  Read from data/pb2/objects.json.
var cull_class := PackedByteArray()
var cull_margin := PackedByteArray()
var cull_rules: Array = []

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
		slots.append(Slot.new())
	var f := FileAccess.open("res://data/pb2/objects.json", FileAccess.READ)
	var t: Dictionary = JSON.parse_string(f.get_as_text())
	# Every number that comes back from JSON is a float, and a float will not
	# even be compared with a word without complaint, so they are put back into
	# the shape the code below expects once, here.
	pickup_bit = PackedByteArray(t["pickup_bit"])
	cull_class = PackedByteArray(t["cull_class"])
	cull_margin = PackedByteArray(t["cull_margin"])
	for r in t["cull_rules"]:
		var rule := {}
		for k in ["horiz", "vert"]:
			rule[k] = r[k] if r[k] is String else int(r[k])
		cull_rules.append(rule)


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
		if slots[n].type == 0:
			free = n                     # $E50D -- the last free one wins
		elif slots[n].rec == rec_index:
			return                       # $E4AE -- it is out there already
	if free < 0:
		return                           # $E4BA -- no room; it is dropped
	# $E4BD and $E4C2 -- the two things that are not put out twice.
	if _gated(rec_index, rec):
		return
	var s: Slot = slots[free]
	s.type = int(rec["type"])
	s.flags = int(rec["flags"])
	s.rec = rec_index
	s.mark = 0x08
	# $E4DB: down a level the record's own number is the height and the other
	# byte the width; along a level it is the other way about.
	# $D6D4 wiped the whole record a moment ago, high bytes and all.
	s.xhi = 0
	s.yhi = 0
	if lvl.vertical:
		s.x = int(rec["across"])
		s.y = delta
	else:
		s.x = delta
		s.y = int(rec["across"])


## Something that is not the level's list has written a type here.  The engine
## has no minds for the things yet, so it is simply told; what matters to the
## scan is only whether the place is free.
##
## A thing that was already there and merely changed into something else keeps
## its record: it is still that record's thing, and the scan must go on passing
## it by.  Only an empty place that fills from somewhere else becomes a stranger,
## with no record at all, so that no record ever takes it for itself.
func take(n: int, what: int) -> void:
	var s: Slot = slots[n]
	if s.type == 0:
		s.rec = 0
	s.type = what


## $D6D4 -- everything about the slot goes, the record's number with it, so
## the same record will be made again if the view comes back over it.
func clear(n: int) -> void:
	slots[n] = Slot.new()


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
	for n in range(FIRST_LIVE, SLOTS):
		var s: Slot = slots[n]
		if s.type == 0:
			continue
		if lvl.vertical:
			var v := (((s.yhi << 8) | s.y) - dv) & 0xFFFF
			s.y = v & 0xFF
			s.yhi = v >> 8
		else:
			var v := (((s.xhi << 8) | s.x) - dv) & 0xFFFF
			s.x = v & 0xFF
			s.xhi = v >> 8


## $8134 -- who has gone far enough past the edge to be thrown away.  Runs once
## a step over every occupied place, before any of them gets a turn, and the
## places it frees are what lets the list go on putting things out.
##
## Returns the places it freed, in the order it walked them.
func cull() -> Array:
	var gone := []
	for n in range(FIRST_LIVE, SLOTS):
		var s: Slot = slots[n]
		if s.type == 0:
			continue
		if _cull_one(s):
			clear(n)
			gone.append(n)
	return gone


func _cull_one(s: Slot) -> bool:
	var rule: Dictionary = cull_rules[cull_class[s.type]]
	var h = rule["horiz"]
	if h is String:
		if h == "none":
			return false
		# $8172 -- the strictest of them: off the screen at all and it is gone.
		return s.xhi != 0 or s.yhi != 0
	return _off_side(s.xhi, s.x, h) or _off_down(s, rule["vert"])


## $81A4 -- the same shape for either pair.  A high byte of zero means the
## thing is on the screen and stays; otherwise the low byte says how far past
## the edge it has got, and the pair of margins says how far is too far.
func _off_side(hi: int, lo: int, pair: int) -> bool:
	if hi == 0:
		return false
	if hi >= 0x80:
		return lo < cull_margin[pair]          # $81AE
	return lo >= cull_margin[pair + 1]         # $81B7


func _off_down(s: Slot, rule) -> bool:
	if not (rule is String):
		return _off_side(s.yhi, s.y, rule)        # $81D6
	if rule == "drop":
		# $81BD -- below the screen it is gone at once; above it there are
		# thirty-two lines of grace.
		if s.yhi == 0:
			return false
		if s.yhi < 0x80:
			return true
		return s.y < 0xE0
	# $81EF -- as 'drop', and gone at $D0 even while it is still on the screen.
	if s.yhi == 0:
		return s.y >= 0xD0
	if s.yhi < 0x80:
		return true
	return s.y < 0xE0


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
