extends SolLevel
class_name Pb2AsSol

## Э5.1 -- a Power Blade 2 area seen the way the Solbrain hero asks about it.
##
## The two games measure the world the same: a cell of sixteen by sixteen,
## asked about by a world pixel.  What differs is the answer.  Power Blade 2
## keeps two bits a cell and turns them into one of four bytes ($F5A9:
## nothing, ladder, wall, hurt), plus a terrain byte a cell ($ABA6) that says
## water, mud, a belt or a fall that kills.  Solbrain keeps five bits a
## metatile and the hero reads them shifted up by three ($D0FD).
##
## So the translation is not invented -- both sides are read here the way
## their own hero reads them:
##
## | Power Blade 2        | Solbrain code | what the Solbrain hero then does |
## |----------------------|---------------|----------------------------------|
## | class $80, a wall    | `$10`         | `>= $80`, solid                  |
## | terrain 4, water     | `$0D`         | `$9505` -> `_wet`                |
## | terrain 3, mud       | `$0D`         | the nearest thing he has         |
## | terrain $87, belt    | `$16`         | `$963D` -> `vx + 8`              |
## | terrain $88, belt    | `$17`         | `$963D` -> `vx - 8`              |
## | anything else        | `$00`         | nothing                          |
##
## Two of Power Blade 2's own classes have no Solbrain answer at all and are
## handed to the mode instead of being pretended at: a ladder (class $01),
## which the Solbrain hero cannot climb, and what hurts -- class $02 and
## terrain 2, the fall that kills.  `hurts_at` is what the mode asks.

## What is underneath, in the class the borrowed area keeps.
var src: Pb2Level
## PB3 uses continuous hero coordinates across the 16 padding rows of each page.
var continuous_vertical := false
## $29 and the view as they stand this frame, after $CED2 moved the line.
## The pair hands them over; -1 is "nobody said", and nothing is turned.
var live_line := -1
var view_pos := 0
## The bar over a sideways area: its map starts at line sixteen of the screen.
const VIEW_TOP := 16

## $10 -- a wall. Shifted up by three this is the $80 the hero tests.
const SOLID := 0x10
## $0D is water; $16/$17 are solid belts ($B0/$B8 after the native shift).
const PLAIN := 0x0C
const WATER := 0x0D
const BELT_RIGHT := 0x16
const BELT_LEFT := 0x17

## Sixteen bits that wrap at nought is how the Solbrain hero keeps his place,
## and a Power Blade 2 area is at most six screens each way -- a little over
## fifteen hundred pixels.  So a place this far along did not get there by
## walking: it came round the top, or round the left edge, and both of those
## are walls.
const WRAPPED := 0x800


func _init(area: Pb2Level) -> void:
	super(-1)
	src = area
	width_tiles = area.width_tiles
	height_tiles = area.height_tiles
	palette = area.palette
	banks = area.banks
	spr_banks = area.spr_banks
	# The Solbrain hero asks the level how far along the area he may go, and
	# he asks in sixteenths of a pixel.  Power Blade 2 keeps the same two ends
	# in pages of the camera, which are pixels.
	camera = {
		"x_min": 0,
		"x_end": (area.width_tiles * 8) << 4,
		"y_min": 0,
		"y_end": (area.height_tiles * 8) << 4,
	}
	start = Vector2i(area.start_x << 4, area.start_y << 4)


func map_y(y: int) -> int:
	return (y / 240) * 256 + posmod(y, 240) if continuous_vertical and src.vertical else y


func hero_y(y: int) -> int:
	return (y >> 8) * 240 + mini(y & 255, 239) if continuous_vertical and src.vertical else y


## $D0FD and $D010 -- what the probes read, in Solbrain's own five bits.
func collision_at(px: int, py: int) -> int:
	if src == null:
		return 0
	if px < 0 or py < 0:
		return SOLID
	py = map_y(py)
	# Outside the area is walled on three sides.  Power Blade 2 never has to
	# say so -- his own hero is held on the screen and the screen is held in
	# the area -- but the Solbrain hero jumps higher than a Power Blade area is
	# tall, and there has to be something over his head to stop him.
	if px >= WRAPPED or py >= WRAPPED or px >= width_tiles * 8:
		return SOLID
	# Under the floor is the one side that is open: in both games falling out
	# of the bottom is how a hero dies, not something a wall prevents.
	if py >= height_tiles * 8:
		return 0x00
	var wet := _line_says(py) == 0x04
	py = _asked_y(py)
	# $A194 -> $963D: belts must retain both solidity and their push bit.
	# Test terrain before the wall class, because both PB2 belts are solid.
	var terrain := src.terrain_at(px, py)
	match terrain:
		0x87:
			return BELT_RIGHT
		0x88:
			return BELT_LEFT
	if src.class_byte(px, py) == 0x80:
		return SOLID
	if wet or terrain == 0x04 or terrain == 0x03:
		return WATER
	return 0x00


## $AC1D -- kind four (p1.0): above the line the ceiling is turned about and
## moves against it; between the line and the hundred and twenty eighth line
## of the screen there is nothing.  Map line in, the map line PB2 asks out.
func _asked_y(py: int) -> int:
	if src.kind != 0x04 or src.vertical or live_line < 0:
		return py
	var sy := py + VIEW_TOP
	if sy < 0x10 or sy >= 0x80:
		return py
	if sy >= live_line:
		return 0x80 - VIEW_TOP
	return ((sy - live_line + 0x80) & 0xFF) - VIEW_TOP


## $B34A -- the areas with a line across them, where the map underneath does
## not matter: kind eight kills above it, kind six below it and kind ten is
## water down to $98.  Returns PB2's terrain there, or -1.  The line is a line
## of the screen, so a map line is first turned into one.
func _line_says(py: int) -> int:
	if live_line < 0 or src.kind not in [0x06, 0x08, 0x0A]:
		return -1
	var sy := py + VIEW_TOP
	if src.vertical:
		sy = py - view_pos
		if Pb2Level.map_row(view_pos, sy) != py:
			sy -= 16
	match src.kind:
		0x08:
			if live_line + 0x1F >= sy:
				return 0x02
		0x0A:
			if sy < 0x98 and sy >= live_line:
				return 0x04
		0x06:
			if sy - 4 >= live_line:
				return 0x02
	return -1


## $2A -- the metatile his feet are inside.  Power Blade 2 has no panels, and
## nought is what the hero reads as "no panel" ($9CAE), so nothing is named.
func raw_at(_px: int, _py: int) -> int:
	return -1


## What Solbrain has no class for: the fall that kills and what hurts to touch.
## The mode asks this after the hero's own step and wounds him itself, rather
## than bending a Solbrain class into meaning something it does not.
func hurts_at(px: int, py: int) -> bool:
	if src == null:
		return false
	var my := map_y(py)
	if _line_says(my) == 0x02:
		return true
	my = _asked_y(my)
	return src.class_byte(px, my) == 0x02 or src.terrain_at(px, my) == 0x02


## And the other one: a ladder, which the Solbrain hero cannot climb.  He walks
## past it as though it were air, which is what the table above already says;
## this is here so the mode can tell the two apart when it needs to.
func ladder_at(px: int, py: int) -> bool:
	if src == null:
		return false
	return src.class_byte(px, map_y(py)) == 0x01


## PB3: PB2's ladder top supports feet from above ($9ED2/$A003).
## It remains passable from below and from the sides; climbing uses Pb3Pair.
func ladder_floor(px: int, py: int, old_feet: int) -> int:
	var map_line := map_y(py)
	var top := map_line & ~15
	if src.class_byte(px, map_line) != 1 or src.class_byte(px, top - 1) == 1:
		return -1
	var line := hero_y(top)
	return line if old_feet <= line else -1
