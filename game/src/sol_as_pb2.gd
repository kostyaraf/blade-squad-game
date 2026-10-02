extends Pb2Level
class_name SolAsPb2

## Э5.1 -- a Solbrain stage seen the way the Power Blade 2 hero asks about it.
## The other half of `Pb2AsSol`, and the same table read backwards.
##
## | Solbrain code   | Power Blade 2   | what the Power Blade hero then does |
## |-----------------|-----------------|-------------------------------------|
## | `>= $10`, solid | class $80       | a wall                              |
## | `$0D`, water    | terrain 4       | `$ABA6` -> he wades and swims       |
## | `$0E`, belt     | terrain $87     | `$B47C` -> carried right            |
## | `$0F`, belt     | terrain $88     | carried left                        |
## | anything else   | class $00       | nothing                             |
##
## The magnitudes agree of their own accord, which is the reason the belts can
## be crossed over at all: Solbrain pushes eight sixteenths of a pixel
## ($9648), Power Blade a hundred and twenty eight two-hundred-fifty-sixths --
## both half a pixel a picture.
##
## Solbrain stages do not scroll the way Power Blade 2's vertical areas do, and
## none of them has the line across the screen that `$B34A` reads, so both are
## simply said not to be here.

var src: SolLevel

## Where the window into the stage stands, in pixels down from its top.
##
## The Power Blade hero keeps his own place on the screen, not in the level:
## sideways the view is added in for him ($F57E reads `cam + sx`), but
## downwards there is nothing to add, because an area of his own game that
## scrolls sideways is exactly one screen tall.  A Solbrain stage is sixteen
## screens tall, so the window has to be said out loud.  The mode moves this
## in step with the view and puts the same step into the hero's `shift_y`.
var cam_y := 0


func _init(stage: SolLevel) -> void:
	super(-1, -1)
	src = stage
	vertical = false
	kind = 1                            # $87 -- an ordinary place
	line = 0
	width_tiles = stage.width_tiles
	height_tiles = stage.height_tiles
	palette = stage.palette
	banks = stage.banks
	spr_banks = stage.spr_banks
	start_x = stage.start.x >> 4
	start_y = stage.start.y >> 4
	start_face = 0
	cam_start_page = int(stage.camera["x_min"]) >> 12
	cam_start_low = 0
	cam_limit_page = int(stage.camera["x_end"]) >> 12
	cam_limit_low = 0
	auto = 0
	auto_wait = 0


## $F5A9 -- the four bytes the physics knows.  Solbrain has nothing that is a
## ladder and nothing that hurts to stand on, so only two of the four are ever
## answered here.
func class_byte(px: int, py: int) -> int:
	if src == null:
		return 0x00
	if py + cam_y >= height_tiles * 8:
		return 0x00
	if px < 0 or py + cam_y < 0 or px >= width_tiles * 8:
		return 0x80
	return 0x80 if src.collision_at(px, py + cam_y) >= Pb2AsSol.SOLID else 0x00


## $ABA6 -- what the ground is made of underfoot.
func terrain_at(px: int, py: int) -> int:
	if src == null:
		return 0x00
	var c: int = src.collision_at(px, py + cam_y)
	if c >= Pb2AsSol.SOLID or (c & 0x0C) != 0x0C:
		return 0x00
	match c & 0x03:
		0x01:
			return 0x04                 # water
		0x02:
			return 0x87                 # carried right
		0x03:
			return 0x88                 # carried left
	return 0x00
