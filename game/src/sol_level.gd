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
var spr_banks: Array
var start: Vector2i                 # where the player comes in, in 1/16 px
var camera: Dictionary
var props: PackedByteArray          # per metatile: palette, alt flag, collision
var alt: PackedByteArray            # $18 -- what a whole one of it looks like
var present: PackedByteArray        # $0540 -- a bit a metatile, set while whole
## The two answers above worked out once for all 256 metatiles.  Asking what
## is at a place is the hottest thing the engine does, so it must not be
## three array reads and a pair of shifts deep.
var _shown: PackedByteArray
var _coll: PackedByteArray
var map_dirty := false              # the picture owes the shader a fresh copy
var room_group: PackedByteArray     # $9A -- per room, which object group it has
var object_groups: Dictionary       # $9C -- the group's list of records
var _metatile: PackedByteArray      # per 16x16 cell, the metatile the stage names
var _cells: Dictionary              # metatile -> the cells it sits in
var _buf: PackedByteArray           # the picture, kept so a broken one can be redrawn
var _quads: Array
var _data: Dictionary


func _init(stage_index: int) -> void:
	stage = stage_index
	# A stage below nought is no stage at all: it is how a view of somebody
	# else's level (`Pb2AsSol`) borrows this class without a file to load.
	if stage_index < 0:
		return
	_data = Nes._load_json("%s/sol/levels/stage%d.json" % [Nes.DATA, stage])
	palette = PackedByteArray(_data["palette"])
	var c: Array = _data["chr"]
	banks = [int(c[0]) & 0xFE, (int(c[0]) & 0xFE) + 1,
			 int(c[1]) & 0xFE, (int(c[1]) & 0xFE) + 1]
	# $42..$45 -- the four the sprites come out of.  A picture may swap one of
	# them for its own, so these are only what the stage is raised with.
	spr_banks = [int(c[2]), int(c[3]), int(c[4]), int(c[5])]
	start = Vector2i(int(_data["start"]["x"]), int(_data["start"]["y"]))
	camera = _data["camera"]
	props = PackedByteArray(_data["props"])
	# $AFAD -- a room names a group of objects, and the group is the list the
	# spawner walks.  $FF for a room that has none.
	room_group = PackedByteArray()
	room_group.resize(256)
	room_group.fill(0xFF)
	for k in _data["room_objects"]:
		room_group[int(k)] = int(_data["room_objects"][k])
	object_groups = _data["object_groups"]
	_build()


func _build() -> void:
	var rooms: Array = _data["rooms"]
	var screens: Array = _data["screens"]
	var blocks: Array = _data["blocks"]
	_quads = _data["quads"]
	var alt_in: Array = _data["alt"]
	alt = PackedByteArray()
	alt.resize(alt_in.size())
	for i in range(alt_in.size()):
		alt[i] = int(alt_in[i])
	# $A782 -- every metatile is marked whole when the stage is raised.
	present = PackedByteArray()
	present.resize(32)
	present.fill(0xFF)
	_cells = {}
	# A metatile is named by one byte, so the cartridge's own tables are 256
	# long; two stages were read out with more properties than that, and the
	# tail of them is never named by anything.  The tables are made as long as
	# the properties so the settling below does not walk off the end.
	_shown = PackedByteArray()
	_shown.resize(maxi(256, props.size()))
	_coll = PackedByteArray()
	_coll.resize(maxi(256, props.size()))
	_settle()

	_buf = PackedByteArray()
	_buf.resize(width_tiles * height_tiles * 4)
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
							var mx: int = rx * 16 + bc * 2 + hx
							var my: int = ry * 16 + br * 2 + hy
							var cell: int = my * (width_tiles / 2) + mx
							_metatile[cell] = m
							# A crate is four metatiles of its own, and the
							# whole one is kept in the alternate table; the
							# cells are remembered so that breaking it can
							# redraw every one of them.
							if (props[m] & 0x20) != 0:
								if not _cells.has(m):
									_cells[m] = []
								_cells[m].append(cell)
							_paint(mx, my, shown(m))
	map_image = Image.create_from_data(width_tiles, height_tiles, false,
			Image.FORMAT_RGBA8, _buf)


## One cell of the picture, four tiles of it.
func _paint(mx: int, my: int, m: int) -> void:
	var q: Array = _quads[m]
	var pal: int = props[m] >> 6
	for tx in range(2):
		for ty in range(2):
			var x: int = mx * 2 + tx
			var y: int = my * 2 + ty
			var o: int = (y * width_tiles + x) * 4
			_buf[o] = int(q[tx * 2 + ty])
			_buf[o + 1] = pal
			_buf[o + 3] = 255
			if map_image != null:
				map_image.set_pixel(x, y, Color8(_buf[o], pal, 0, 255))


## The two tables above, worked out from the mark as it now stands.
func _settle() -> void:
	for m in range(props.size()):
		var w: bool = (present[(m >> 3) & 0x1F] & (0x80 >> (m & 0x07))) != 0
		if (props[m] & 0x20) != 0:
			_shown[m] = alt[m] if w else m
			_coll[m] = props[_shown[m]] & 0x1F
		else:
			_shown[m] = m
			_coll[m] = (props[m] & 0x1F) if w else 0


## $D124 -- is this metatile still whole.
func whole(m: int) -> bool:
	return (present[(m >> 3) & 0x1F] & (0x80 >> (m & 0x07))) != 0


## $90FA -- what is actually shown where the stage names metatile `m`: the
## whole one while it stands, the one written down once it is broken.
func shown(m: int) -> int:
	return _shown[m]


## $BE36 -- one metatile is broken.  The mark is kept by metatile number, not
## by place, so every cell in the stage that names it goes at the same time --
## which is why a crate is given four numbers of its own.
func smash(m: int) -> void:
	if not whole(m):
		return
	present[(m >> 3) & 0x1F] &= ~(0x80 >> (m & 0x07)) & 0xFF
	_settle()
	if (props[m] & 0x20) == 0:
		return                          # only what it stops changes, not its face
	for cell in _cells.get(m, []):
		_paint(cell % (width_tiles / 2), cell / (width_tiles / 2), m)
	map_dirty = true


## $0540 written a byte at a time by the stage's script ($A58D, $9D6E, $9B99
## set whole marks back): every metatile whose mark changed is redrawn, as
## $BE36 does for the one it breaks.
func set_present(i: int, v: int) -> void:
	var was: int = present[i]
	if was == v:
		return
	present[i] = v
	_settle()
	for b in range(8):
		var mm: int = i * 8 + b
		if ((was ^ v) & (0x80 >> b)) == 0 or mm >= props.size():
			continue
		if (props[mm] & 0x20) == 0:
			continue
		for cell in _cells.get(mm, []):
			_paint(cell % (width_tiles / 2), cell / (width_tiles / 2), mm)
	map_dirty = true


## The metatile the stage names at a world pixel, whole or not, or -1 outside.
func raw_at(px: int, py: int) -> int:
	var mx := px >> 4
	var my := py >> 4
	if mx < 0 or my < 0 or mx >= width_tiles / 2 or my >= height_tiles / 2:
		return -1
	return _metatile[my * (width_tiles / 2) + mx]


## The metatile shown at a world pixel, or -1 outside the stage.
func metatile_at(px: int, py: int) -> int:
	var m := raw_at(px, py)
	return -1 if m < 0 else _shown[m]


## The collision bits of the metatile at a world pixel.  A broken one that has
## no second face still shows the same picture, but stops nothing at all
## ($911D), which the table above has already worked out.
func collision_at(px: int, py: int) -> int:
	var mx := px >> 4
	var my := py >> 4
	if mx < 0 or my < 0 or mx >= width_tiles / 2 or my >= height_tiles / 2:
		return 0
	return _coll[_metatile[my * (width_tiles / 2) + mx]]
