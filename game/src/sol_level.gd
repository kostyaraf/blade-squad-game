extends RefCounted
class_name SolLevel

## One stage of Solbrain, unfolded into a map of tile numbers.
##
## Solbrain scrolls both ways, so a stage is a 16x16 grid of rooms, each room
## 256x256 px.  Unfolded that is 512x512 tiles, which is small enough to hold
## whole -- and holding it whole means the engine can ask what is at a world
## pixel without walking room, screen, block and metatile every time.

const ROOMS := 16
const ROOM_TILES := 32              # 256 px / 8

var stage: int
var width_tiles: int = ROOMS * ROOM_TILES
var height_tiles: int = ROOMS * ROOM_TILES
var map_image: Image
var palette: PackedByteArray
var banks: Array
var start: Vector2i                 # where the player comes in, in 1/16 px
var camera: Dictionary
var props: PackedByteArray          # per metatile: palette, alt flag, collision
var _metatile: PackedByteArray      # per 16x16 cell, the metatile it resolves to
var _data: Dictionary


func _init(stage_index: int) -> void:
	stage = stage_index
	_data = Nes._load_json("%s/sol/levels/stage%d.json" % [Nes.DATA, stage])
	palette = PackedByteArray(_data["palette"])
	var c: Array = _data["chr"]
	banks = [int(c[0]) & 0xFE, (int(c[0]) & 0xFE) + 1,
			 int(c[1]) & 0xFE, (int(c[1]) & 0xFE) + 1]
	start = Vector2i(int(_data["start"]["x"]), int(_data["start"]["y"]))
	camera = _data["camera"]
	props = PackedByteArray(_data["props"])
	_build()


func _build() -> void:
	var rooms: Array = _data["rooms"]
	var screens: Array = _data["screens"]
	var blocks: Array = _data["blocks"]
	var quads: Array = _data["quads"]
	var alt: Array = _data["alt"]

	var buf := PackedByteArray()
	buf.resize(width_tiles * height_tiles * 4)
	_metatile = PackedByteArray()
	_metatile.resize((width_tiles / 2) * (height_tiles / 2))

	for ry in range(ROOMS):
		var row: Array = rooms[ry]
		for rx in range(ROOMS):
			# Row 0 of every room map is padding whose bytes are not screen
			# numbers at all; the game never looks there.
			if row[rx] == null or int(row[rx]) >= screens.size():
				continue
			var scr: Array = screens[int(row[rx])]
			for br in range(8):                       # blocks down the room
				for bc in range(8):                   # blocks across
					var b: int = int(scr[br][bc])
					var blk: Array = blocks[b]
					for hx in range(2):
						for hy in range(2):
							var m: int = int(blk[hx * 2 + hy])
							var p: int = props[m]
							# A block that can be broken is solid until it is:
							# the engine marks every one of them present when
							# the stage is entered.
							if (p & 0x20) != 0:
								m = int(alt[m])
							var mx: int = rx * 16 + bc * 2 + hx
							var my: int = ry * 16 + br * 2 + hy
							_metatile[my * (width_tiles / 2) + mx] = m
							var q: Array = quads[m]
							var pal: int = props[m] >> 6
							for tx in range(2):
								for ty in range(2):
									var x: int = mx * 2 + tx
									var y: int = my * 2 + ty
									var o: int = (y * width_tiles + x) * 4
									buf[o] = int(q[tx * 2 + ty])
									buf[o + 1] = pal
									buf[o + 3] = 255
	map_image = Image.create_from_data(width_tiles, height_tiles, false,
			Image.FORMAT_RGBA8, buf)


## The metatile at a world pixel, or -1 outside the stage.
func metatile_at(px: int, py: int) -> int:
	var mx := px >> 4
	var my := py >> 4
	if mx < 0 or my < 0 or mx >= width_tiles / 2 or my >= height_tiles / 2:
		return -1
	return _metatile[my * (width_tiles / 2) + mx]


## The collision bits of the metatile at a world pixel.
func collision_at(px: int, py: int) -> int:
	var m := metatile_at(px, py)
	return 0 if m < 0 else props[m] & 0x1F
