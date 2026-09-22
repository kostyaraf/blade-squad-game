extends Control
class_name Pb3Menu

## Э7.2 -- the screen the port opens on, and the one screen here that no
## cartridge ever had.
##
## Each cartridge was its own console's whole world and never had to ask which
## game was wanted; this build holds three, so something must. That makes this
## screen the port's own, and it is drawn with the port's own letters rather
## than with the cartridge's: a screen drawn in a cartridge's letters would be
## claiming to be one of its screens, and there is nothing to check it against.
##
## The pad is read the way both games read it -- `Pad`, eight buttons, what is
## held and what has just gone down -- so that the way in feels like the way
## on.

## Which game, and what it is called on the screen.
##
## Three, which is the whole of the plan: the two cartridges and the mode that
## is this port's own.  The third row waited for Э7.5, because until the PB3
## mode was drawn it would have offered something that cannot be shown -- every
## `pb3` way into `main.gd` put out text and nothing else.
const WAYS := [
	["pb2", "POWER BLADE 2"],
	["sol", "SOLBRAIN"],
	["pb3", "POWER BLADE 3"],
]

## The console's own picture, which the whole build is stretched from.
const WIDE := 256
const TALL := 240

## Sent once, with the key of the game he settled on.
signal picked(which: String)

## Which row the caret stands on.
var at := 0

var _rows: Array = []
var _taken := false


func _init() -> void:
	# The picture is always 256x240 and the whole window is stretched from it
	# ("viewport" in the project), so the screen is laid out in those numbers
	# and not in anchors.
	position = Vector2.ZERO
	size = Vector2(WIDE, TALL)
	var back := ColorRect.new()
	back.color = Color.BLACK
	back.position = Vector2.ZERO
	back.size = Vector2(WIDE, TALL)
	add_child(back)
	var title := _label("PB3", 0, 48, 16)
	title.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	for i in range(WAYS.size()):
		_rows.append(_label(" " + str(WAYS[i][1]), 0, 110 + i * 22, 10))
	_label("ARROWS AND START", 0, 206, 8).add_theme_color_override(
			"font_color", Color(0.45, 0.45, 0.45))
	_mark()


## One line of writing, across the whole picture and centred in it.
func _label(text: String, x: int, y: int, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.position = Vector2(x, y)
	l.size = Vector2(WIDE, size + 6)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	add_child(l)
	return l


## The caret, which is a letter and not a sprite: there is no table here.
func _mark() -> void:
	for i in range(_rows.size()):
		var row: Label = _rows[i]
		row.text = ("> " if i == at else "  ") + str(WAYS[i][1])
		row.add_theme_color_override("font_color",
				Color.WHITE if i == at else Color(0.5, 0.5, 0.5))


## One picture of the screen. `pad` is player one, already polled.
func step(pad: Pad) -> void:
	if _taken:
		return
	var down: int = pad.pressed
	if (down & Pad.DOWN) != 0 and at < WAYS.size() - 1:
		at += 1
		_mark()
	elif (down & Pad.UP) != 0 and at > 0:
		at -= 1
		_mark()
	elif (down & (Pad.START | Pad.A)) != 0:
		_taken = true
		picked.emit(str(WAYS[at][0]))
