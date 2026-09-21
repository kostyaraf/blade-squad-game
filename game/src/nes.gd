extends Node
class_name Nes

## The pieces every game on this engine shares: the console's colours, the tile
## sheets, and the way a palette is handed to the shader.
##
## Tiles are kept as colour indices, never as colours.  What a "1" looks like is
## decided by the palette in force at the moment it is drawn, which is how both
## games flash a hurt enemy, tint a suit and cycle water.

const DATA := "res://data"

static var _sheets := {}
static var nes_rgb: PackedColorArray = PackedColorArray()


static func _load_json(path: String) -> Variant:
	var text := FileAccess.get_file_as_string(path)
	assert(text != "", "cannot read " + path)
	return JSON.parse_string(text)


static func load_palette_table() -> void:
	if nes_rgb.size() == 64:
		return
	var j: Dictionary = _load_json(DATA + "/nes_palette.json")
	for h in j["rgb"]:
		nes_rgb.append(Color.html("#" + str(h)))


## The tile sheet of one game, as a texture the shader can index.
static func sheet(game: String) -> ImageTexture:
	if _sheets.has(game):
		return _sheets[game]
	# The sheet travels into a build as the file it is -- `importer="keep"` in
	# `tiles.png.import` -- so it is read as bytes and not as a resource.
	# `Image.load_from_file` would do the same, but it warns that it will not
	# work on export, and about the ordinary case it is right.
	#
	# The reading is done before the judging and not inside it: a release
	# build drops every `assert` and everything written inside one with it,
	# and the sheet would then never be read at all.  Nothing running out of
	# `game/` can see that -- which is what Э7.1's own stand is for.
	var img := Image.new()
	var raw := FileAccess.get_file_as_bytes(DATA + "/" + game + "/tiles.png")
	var err := img.load_png_from_buffer(raw)
	assert(err == OK, "no tile sheet for " + game)
	# The sheet is one byte per pixel; keep it that way so the shader can read
	# the colour index back out without a conversion losing it.
	img.convert(Image.FORMAT_R8)
	var tex := ImageTexture.create_from_image(img)
	_sheets[game] = tex
	return tex


## One of the console's sixty-four colours, for a thing drawn outside the
## picture -- a stand-in bar, and nothing the cartridge itself draws.
static func colour(n: int) -> Color:
	load_palette_table()
	return nes_rgb[n & 0x3F]


## A 32-entry console palette, as a 32x1 texture.
static func palette_texture(entries: PackedByteArray) -> ImageTexture:
	load_palette_table()
	var img := Image.create(32, 1, false, Image.FORMAT_RGBA8)
	for i in range(32):
		var c: int = entries[i] if i < entries.size() else 0x0F
		img.set_pixel(i, 0, nes_rgb[c & 0x3F])
	return ImageTexture.create_from_image(img)


static func update_palette(tex: ImageTexture, entries: PackedByteArray) -> void:
	load_palette_table()
	var img := Image.create(32, 1, false, Image.FORMAT_RGBA8)
	for i in range(32):
		var c: int = entries[i] if i < entries.size() else 0x0F
		img.set_pixel(i, 0, nes_rgb[c & 0x3F])
	tex.update(img)
