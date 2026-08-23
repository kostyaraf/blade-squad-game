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
	var x := 0                   ## $0508,X -- on the screen, along
	var y := 0                   ## $04C6,X -- on the screen, across
	var mark := 0               ## $0416,X -- set to eight at birth


var lvl: Pb2Level
var slots: Array = []
## $8A -- set as the area opens, so that the first scan fills the whole screen
## and not only its edge.  The first scan to reach the end of the list, or a
## record that is still ahead of the screen, puts it out.
var fill := 0


func _init(level: Pb2Level) -> void:
	lvl = level
	for i in range(SLOTS):
		slots.append(Slot.new())


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
	var s: Slot = slots[free]
	s.type = int(rec["type"])
	s.flags = int(rec["flags"])
	s.rec = rec_index
	s.mark = 0x08
	# $E4DB: down a level the record's own number is the height and the other
	# byte the width; along a level it is the other way about.
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
