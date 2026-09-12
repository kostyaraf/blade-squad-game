extends RefCounted
class_name SolScreen

## A screen of Solbrain that is not a stage: the title, the tale, the picking
## of a stage, GAME OVER, and the rest.
##
## A stage's background is built out of the level data; a screen is not.  A
## screen is a little stream of commands that $9607 in bank four walks straight
## into the console's name map, and most of them write a few dozen tiles and no
## more -- the words GAME OVER over a board the mode has already wiped, the
## five lines of BEST 5.  `data/sol/screens.json` holds those writes as the
## cartridge makes them; `data/sol/scenes.json` holds what a screen needs
## besides them -- which screens go together, the thirty two colours, the
## background banks line by line, and how the two name maps are mirrored.
##
## `work/re/sol_screens.md` is the whole account.

const WIDE := 32
const TALL := 30

var name := ""
var board := PackedByteArray()      # the console's own two kilobytes
var map_image: Image                # the first page, R = tile, G = palette
var map_image_b: Image              # and the second
var palette := PackedByteArray()
var banks := [0, 0, 0, 0]
var spr_banks := [0, 0, 0, 0]
var bands := []                     # [[first line, [four banks]], ...]
var mirror := 1                     # 0 across, 1 down
var scroll := Vector2i.ZERO

static var _screens: Dictionary
static var _scenes: Dictionary


static func _data() -> void:
	if _screens.is_empty():
		_screens = JSON.parse_string(FileAccess.get_file_as_string(
				"res://data/sol/screens.json"))
		_scenes = JSON.parse_string(FileAccess.get_file_as_string(
				"res://data/sol/scenes.json"))["scenes"]


## Every scene there is, by name.
static func names() -> Array:
	_data()
	return _scenes.keys()


## One scene, built the way the cartridge builds it: a wiped board, then every
## screen of it laid on in turn.
static func make(scene_name: String) -> SolScreen:
	_data()
	assert(_scenes.has(scene_name), "no scene " + scene_name)
	var cfg: Dictionary = _scenes[scene_name]
	var s := SolScreen.new()
	s.name = scene_name
	s.mirror = int(cfg["mirror"])
	s.board.resize(0x0800)
	for n in cfg["screens"]:
		s.lay(int(n))
	s.palette = PackedByteArray()
	for c in cfg["palette"]:
		s.palette.append(int(c))
	s.bands = []
	for one in cfg["bands"]:
		var four := []
		for b in one[1]:
			four.append(int(b))
		s.bands.append([int(one[0]), four])
	s.banks = s.bands[0][1]
	# The four the sprites come out of are the other half of what the dump
	# holds; nothing here draws a sprite yet, but the shader is handed eight.
	s.spr_banks = []
	for i in range(4, 8):
		s.spr_banks.append(int(cfg["chr"][i]))
	s.scroll = Vector2i(int(cfg["scroll"][0]), int(cfg["scroll"][1]))
	s.build()
	return s


## One screen's writes, on whatever already stands on the board.
##
## The console has two kilobytes of name map and four places to put it, so
## which of the two a write lands in is the mirroring's business: across, the
## first two places are the same memory; down, the first and the third are.
func lay(n: int) -> void:
	var at: int = int(_screens["screens"][n])
	var one: Dictionary = _screens["streams"]["%04X" % at]
	for w in one["writes"]:
		var addr: int = int(w[0])
		var step: int = int(w[1])
		for b in w[2]:
			var a: int = addr & 0x0FFF
			a = (a & 0x03FF) | (0x400 if (a & (0x400 if mirror else 0x800)) != 0
					else 0)
			board[a] = int(b)
			addr += step


## The two pages as pictures the shader can read: red the tile, green which of
## the four colour sets it is drawn in.
func build() -> void:
	map_image = _page(0)
	map_image_b = _page(1)


func _page(n: int) -> Image:
	var buf := PackedByteArray()
	buf.resize(WIDE * TALL * 4)
	var base: int = n * 0x400
	for y in range(TALL):
		for x in range(WIDE):
			var tile: int = board[base + y * WIDE + x]
			# Sixty four bytes of colour a page, one for each four by four
			# block of cells, and two bits of it for each two by two.
			var att: int = board[base + 0x3C0 + (y >> 2) * 8 + (x >> 2)]
			var pal: int = (att >> (((y >> 1) & 1) * 4 + ((x >> 1) & 1) * 2)) & 3
			var o: int = (y * WIDE + x) * 4
			buf[o] = tile
			buf[o + 1] = pal
			buf[o + 3] = 255
	return Image.create_from_data(WIDE, TALL, false, Image.FORMAT_RGBA8, buf)


## The bands as the shader wants them: four first lines and four times four
## banks, with a band that is not there put out of reach.
func band_lines() -> PackedInt32Array:
	var out := PackedInt32Array([0, 255, 255, 255])
	for i in range(min(4, bands.size())):
		out[i] = int(bands[i][0])
	return out


func band_banks() -> PackedInt32Array:
	var out := PackedInt32Array()
	for i in range(4):
		var four: Array = bands[min(i, bands.size() - 1)][1]
		for b in four:
			out.append(int(b))
	return out
