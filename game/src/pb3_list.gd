extends RefCounted
class_name Pb3List

## Э5.6 -- the sixty three areas and the twenty stages in one list.
##
## A record is three numbers and nothing else: which game, which stage, which
## area.  That is all a level ever needed to be raised by -- `Pb2Level` takes
## a stage and an area, `SolLevel` takes a stage -- so the list is not a new
## kind of thing, only the two games' own indexes laid end to end.
##
## The order is the order each game plays itself in: Power Blade's seven
## stages and the areas inside each, then Solbrain's twenty.  Nothing is
## sorted or shuffled, because either would be a decision with nothing behind
## it.
##
## Where the two of them stand when a record comes up is the level's own
## start, both on it.  Neither game holds one hero out of the other's way --
## there is no such thing in either -- so two on one pixel is not a case
## anybody has to handle, and taking the level's own word for where a hero may
## stand is better than looking for a second place that the level never
## promised.
##
## `work/re/pb3_list.md`.

const PB2 := Pb3Pair.PB2
const SOL := Pb3Pair.SOL

## How many areas each stage of Power Blade 2 has, and how many stages
## Solbrain has.
const PB2_AREAS := [7, 8, 7, 7, 10, 14, 10]
const SOL_STAGES := 20

## Pad bits, the same in both games.
const A := 0x80
const B := 0x40
const LEFT := 0x02
const RIGHT := 0x01

## Where the cursor stands, and what is being played, if anything.
var at := 0
var two: Pb3Pair = null
var gear: Pb3Gear = null
var kinds: Array = []
var last_pad := 0
## Where the cursor stood when a level was entered, so that leaving comes back
## to it and not to the top.
var came_from := 0


static func records() -> Array:
	var out: Array = []
	for st in range(PB2_AREAS.size()):
		for ar in range(int(PB2_AREAS[st])):
			out.append([PB2, st, ar])
	for st in range(SOL_STAGES):
		out.append([SOL, st, 0])
	return out


static func say(rec: Array) -> String:
	return "%s%d.%d" % ["s" if int(rec[0]) == SOL else "p", int(rec[1]),
			int(rec[2])]


func _init(kinds_: Array) -> void:
	kinds = kinds_
	gear = Pb3Gear.new(kinds)


func playing() -> bool:
	return two != null


## One picture of the list itself.  Left and right walk it, A goes in.  Only
## the edge of a press counts, the way both games count it.
func step(pad: int) -> void:
	if playing():
		return
	var hit: int = pad & ~last_pad
	last_pad = pad
	var n: int = records().size()
	if (hit & RIGHT) != 0:
		at = (at + 1) % n
	elif (hit & LEFT) != 0:
		at = (at + n - 1) % n
	elif (hit & A) != 0:
		enter()


## Raise the record the cursor stands on, and put both of them on the level's
## own start.
func enter() -> bool:
	if playing():
		return false
	var rec: Array = records()[at]
	came_from = at
	two = Pb3Pair.new(int(rec[0]), int(rec[1]), int(rec[2]), kinds)
	var home: Vector2i = two.home()
	var spots: Array = []
	for _i in kinds:
		spots.append(home)
	two.begin(spots)
	return true


## And out again, back to the record it was entered from.
func leave() -> void:
	two = null
	at = came_from
	last_pad = 0
