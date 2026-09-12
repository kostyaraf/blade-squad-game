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
## The console has two kilobytes of name map and four places to put them, so
## what the picture rides over is those two put up four times: sixty four tiles
## across and sixty down, and it comes back round at the far edge.
const WIDE_ALL := 64
const TALL_ALL := 60

var name := ""
var board := PackedByteArray()      # the console's own two kilobytes
var map_image: Image                # all four places, R = tile, G = palette
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


## The board wiped and a fresh list of screens laid on it.  A mode that picks
## one of several screens by hand needs this and not `lay`: two of them written
## one over the other leave the first one's tiles wherever the second writes
## nothing at all.
func relay(numbers: Array) -> void:
	board = PackedByteArray()
	board.resize(0x0800)
	for n in numbers:
		lay(int(n))
	build()


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


## One tile written where the console would write it, at a place given the way
## the picture unit is given it ($2000..$2FFF).  The board is two kilobytes and
## four places, so the write lands in one of the two pages and shows in the two
## places that page stands in.
func poke(addr: int, tile: int) -> void:
	var a: int = addr & 0x0FFF
	a = (a & 0x03FF) | (0x400 if (a & (0x400 if mirror else 0x800)) != 0
			else 0)
	if (a & 0x3FF) >= 0x3C0:
		board[a] = tile
		build()
		return
	board[a] = tile
	var page: int = a >> 10
	var y: int = (a & 0x3FF) / WIDE
	var x: int = (a & 0x3FF) % WIDE
	for j in range(2):
		for i in range(2):
			if (j if mirror == 0 else i) != page:
				continue
			var c := Color8(tile,
					int(map_image.get_pixel(i * WIDE + x, j * TALL + y).g8),
					0, 255)
			map_image.set_pixel(i * WIDE + x, j * TALL + y, c)


## All four places as one picture the shader can read: red the tile, green
## which of the four colour sets it is drawn in.  Which of the two pages stands
## in each place is the mirroring's business -- across, the two on top are the
## same page and the two below it the other; down, the two on the left are.
func build() -> void:
	var buf := PackedByteArray()
	buf.resize(WIDE_ALL * TALL_ALL * 4)
	for j in range(2):
		for i in range(2):
			var page: int = (j if mirror == 0 else i)
			_page(page, i * WIDE, j * TALL, buf)
	map_image = Image.create_from_data(WIDE_ALL, TALL_ALL, false,
			Image.FORMAT_RGBA8, buf)


func _page(n: int, at_x: int, at_y: int, buf: PackedByteArray) -> void:
	var base: int = n * 0x400
	for y in range(TALL):
		for x in range(WIDE):
			var tile: int = board[base + y * WIDE + x]
			# Sixty four bytes of colour a page, one for each four by four
			# block of cells, and two bits of it for each two by two.
			var att: int = board[base + 0x3C0 + (y >> 2) * 8 + (x >> 2)]
			var pal: int = (att >> (((y >> 1) & 1) * 4 + ((x >> 1) & 1) * 2)) & 3
			var o: int = ((at_y + y) * WIDE_ALL + at_x + x) * 4
			buf[o] = tile
			buf[o + 1] = pal
			buf[o + 3] = 255


## $C357 -- the pair of kilobytes that has nothing in it, which is what a row
## of words is drawn out of while it is meant to be unseen.
const BLANK := 0x62
## $C14F and $C178 -- where the beam is stopped: at the first the whole of the
## background's first pair goes blank, at the second the rest of it does, and
## at the third the first pair comes back.
const BLANK_LINES := [0, 151, 152, 160]


## The bands the blink puts in place of the screen's own.
func blank_banks() -> PackedInt32Array:
	var own: Array = bands[0][1]
	var out := PackedInt32Array()
	for b in own:
		out.append(int(b))
	out.append_array(PackedInt32Array([BLANK, BLANK + 1, int(own[2]),
			int(own[3])]))
	out.append_array(PackedInt32Array([BLANK, BLANK + 1, BLANK, BLANK + 1]))
	var back: Array = bands[min(1, bands.size() - 1)][1]
	out.append_array(PackedInt32Array([int(back[0]), int(back[1]), BLANK,
			BLANK + 1]))
	return out


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
