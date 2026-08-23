extends RefCounted
class_name Pb2Level

## One area of Power Blade 2, unfolded into a map of tile numbers.
##
## The cartridge kept the level folded four times over -- area, screen, block,
## tile -- because it had to.  We unfold it once when the area is entered and
## then never think about it again; what the engine needs to answer quickly is
## "what is at this world pixel", not "which screen was that".

const TILES_PER_SCREEN_X := 32

var stage: int
var area: int
var vertical: bool
var width_tiles: int
var height_tiles: int
var map_image: Image                # R = tile number, G = palette
var palette: PackedByteArray
var banks: Array                    # the four 1 KB CHR banks of the background
var bank_phases: Array              # the sets the animated half cycles through
var terrain: PackedByteArray        # what each tile number does underfoot
var terrain_class: PackedByteArray  # the two bits the physics actually reads
var class_bytes := PackedByteArray([0x00, 0x01, 0x80, 0x02])
var tiles: PackedByteArray          # tile number per 8x8 cell, row major
var spawns: Array
## $87 and $29: what sort of place this is, and the line its water or its
## drop begins at.  Most areas are ordinary and say nothing.
var kind: int
var line: int
## $66:$67 as the area is entered, and $59:$5A, past which the view does not
## go.  Bytes three to six of the area's record.
var cam_start_page: int
var cam_start_low: int
var cam_limit_page: int
var cam_limit_low: int
var _data: Dictionary


func _init(stage_index: int, area_index: int) -> void:
	stage = stage_index
	area = area_index
	_data = Nes._load_json("%s/pb2/levels/stage%d.json" % [Nes.DATA, stage])
	var a: Dictionary = _data["areas"][area]
	vertical = int(a["vertical"]) != 0
	palette = PackedByteArray(a["palette"])
	banks = (a["chr"] as Array).slice(0, 4)
	bank_phases = a["chr_bg_phases"]
	terrain = PackedByteArray(a["terrain"])
	terrain_class = PackedByteArray(a["terrain_class"])
	spawns = a["spawns"]
	kind = int(a.get("kind", 1))
	line = int(a.get("line", 0))
	cam_start_page = int(a["cam_screen"])
	cam_start_low = int(a["cam_sub"])
	cam_limit_page = int(a["cam_last"])
	cam_limit_low = int(a["cam_last_sub"])
	_build(a)


func _build(a: Dictionary) -> void:
	var screens: Array = a["screens"]
	var all_screens: Array = _data["screens"]
	var blocks: Array = _data["blocks"]
	var attrs: Array = _data["attributes"]

	# Every screen of an area is the same shape, so the area's size follows
	# from how many there are and which way it scrolls.
	var first: Dictionary = all_screens[int(screens[0])]
	var sh: int = int(first["h"]) * 4          # tiles tall
	if vertical:
		width_tiles = TILES_PER_SCREEN_X
		height_tiles = sh * screens.size()
	else:
		width_tiles = TILES_PER_SCREEN_X * screens.size()
		height_tiles = sh

	var buf := PackedByteArray()
	buf.resize(width_tiles * height_tiles * 4)
	for n in range(screens.size()):
		var sc: Dictionary = all_screens[int(screens[n])]
		var sblocks: Array = sc["blocks"]
		var ox: int = 0 if vertical else n * TILES_PER_SCREEN_X
		var oy: int = n * sh if vertical else 0
		for br in range(int(sc["h"])):
			for bc in range(8):
				var b: int = int(sblocks[br * 8 + bc])
				var blk: Array = blocks[b] if b < blocks.size() else []
				var at: int = int(attrs[b]) if b < attrs.size() else 0
				for r in range(4):
					for c in range(4):
						var t: int = int(blk[r * 4 + c]) if blk.size() == 16 else 0
						# One attribute byte covers the whole 32x32 block; its
						# four bit pairs are its four 16x16 quarters.
						var quad: int = (r / 2) * 2 + (c / 2)
						var pal: int = (at >> (quad * 2)) & 3
						var x: int = ox + bc * 4 + c
						var y: int = oy + br * 4 + r
						var o: int = (y * width_tiles + x) * 4
						buf[o] = t
						buf[o + 1] = pal
						buf[o + 3] = 255
	map_image = Image.create_from_data(width_tiles, height_tiles, false,
			Image.FORMAT_RGBA8, buf)
	tiles = PackedByteArray()
	tiles.resize(width_tiles * height_tiles)
	for i in range(width_tiles * height_tiles):
		tiles[i] = buf[i * 4]


## Which line of the map a line of the screen shows, when the view slides down.
##
## The console keeps the level in a ring of sixteen rows of cells and finds the
## row by adding the camera to the line, in eight bits ($F52C).  The sixteen
## lines that separate a screen of two hundred and forty from a page of two
## hundred and fifty six are skipped over as soon as the sum reaches them --
## both ways round the cartridge takes that jump it adds fifteen and a carry,
## so it is sixteen either way.
static func map_row(cam: int, sy: int) -> int:
	if (cam & 0xFF) + sy >= 0xF0:
		return cam + sy + 16
	return cam + sy


## What the ground does at this world pixel: solid, ladder, water, spikes...
func terrain_at(px: int, py: int) -> int:
	var tx := px >> 3
	var ty := py >> 3
	if tx < 0 or ty < 0 or tx >= width_tiles or ty >= height_tiles:
		return 0
	return terrain[tiles[ty * width_tiles + tx]]


## What the physics sees at this world pixel.
##
## The console keeps two bits per 16x16 cell and takes them from that cell's
## top left 8x8 tile, so a cell is as solid as its corner -- and the answer is
## one of only four bytes ($F5A9): nothing, ladder, wall, hurt.
func class_byte(px: int, py: int) -> int:
	var tx := (px >> 4) << 1
	var ty := (py >> 4) << 1
	# The cartridge keeps sixteen rows of cells whatever the area's height, and
	# the ones past its bottom were never filled in -- so there is nothing
	# there rather than a wall.
	if ty >= height_tiles:
		return 0x00
	if tx < 0 or ty < 0 or tx >= width_tiles:
		return 0x80
	return class_bytes[terrain_class[tiles[ty * width_tiles + tx]]]
