extends Control
class_name Pb3Board

## Э7.5 -- the two screens the PB3 mode needs that no cartridge ever had: the
## list a record is picked from, and the one line of writing the shared bar is
## said in while a record is played.
##
## Both are drawn with the port's own letters, for the same reason the asking
## screen is (Э7.2, `Pb3Menu`): a screen drawn in a cartridge's letters would
## be claiming to be one of its screens, and there is nothing to check it
## against.  The list is eighty three records of two games at once, which
## neither cartridge ever had to show; the bar is one bar for two heroes, which
## neither cartridge ever had to draw.
##
## Nothing is decided here.  Where the cursor stands and what it stands on is
## `Pb3List` (Э5.6); the numbers on the bar are `Pb3Gear`'s (Э5.5).  This is
## only the showing of them.

const PB2 := Pb3Pair.PB2
const SOL := Pb3Pair.SOL

## The console's own picture, which the whole build is stretched from.
const WIDE := 256
const TALL := 240

## How many records stand on the screen at once, and which of them the cursor
## keeps: the middle one, so that walking either way shows what is coming.
const SHOWN := 9
const MIDDLE := 4

var _rows: Array = []
var _strip: Label = null
var _hint: Label = null
var _name: Label = null


func _init() -> void:
	position = Vector2.ZERO
	size = Vector2(WIDE, TALL)
	var back := ColorRect.new()
	back.color = Color.BLACK
	back.position = Vector2.ZERO
	back.size = Vector2(WIDE, TALL)
	back.name = "back"
	add_child(back)
	_name = _label("POWER BLADE 3", 0, 26, 14)
	_name.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	for i in range(SHOWN):
		_rows.append(_label("", 0, 64 + i * 16, 9))
	_hint = _label("ARROWS   A PLAY   SELECT BACK", 0, 214, 8)
	_hint.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
	# The bar stands over the picture and is only there while one is played,
	# so it is made once and hidden until then.
	_strip = _label("", 0, 2, 8)
	_strip.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	_strip.visible = false


## One line of writing, across the whole picture and centred in it.
func _label(text: String, x: int, y: int, size_: int) -> Label:
	var l := Label.new()
	l.text = text
	l.position = Vector2(x, y)
	l.size = Vector2(WIDE, size_ + 6)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size_)
	add_child(l)
	return l


## What a record is called on the screen.  `Pb3List.say` says the same thing in
## four letters, which is what a stand reads; this is the same triple written
## out for somebody looking at it.
static func name_of(rec: Array) -> String:
	if int(rec[0]) == SOL:
		return "SOLBRAIN   STAGE %d" % [int(rec[1]) + 1]
	return "POWER BLADE 2   STAGE %d  AREA %d" % [int(rec[1]) + 1,
			int(rec[2]) + 1]


## The list, with the cursor where `Pb3List` has it.  The list comes back round
## at both ends, so the window round the cursor does too.
func show_list(at: int) -> void:
	_name.text = "CHOOSE LEVEL"
	_name.add_theme_font_size_override("font_size", 14)
	_hint.text = "ARROWS  X/ENTER PLAY  Z BACK"
	_hint.position.y = 214
	var recs: Array = Pb3List.records()
	var n: int = recs.size()
	for i in range(SHOWN):
		var k: int = ((at + i - MIDDLE) % n + n) % n
		var row: Label = _rows[i]
		row.visible = true
		row.text = ("> " if i == MIDDLE else "  ") + name_of(recs[k])
		row.add_theme_color_override("font_color",
				Color.WHITE if i == MIDDLE else Color(0.5, 0.5, 0.5))
	_hint.visible = true
	_name.visible = true
	_strip.visible = false
	(get_node("back") as ColorRect).visible = true


func show_setup(players: int, heroes: Array, at: int) -> void:
	show_list(0)
	_name.text = "POWER BLADE 3"
	var names := ["NOVA", "SOLBRAIN"]
	var lines: Array = ["PLAYERS: %d" % players,
			"PLAYER 1: " + names[int(heroes[0])],
			"PLAYER 2: " + (names[int(heroes[1])] if players == 2
			else "OFF"), "CHOOSE LEVEL"]
	for i in range(_rows.size()):
		var row: Label = _rows[i]
		row.visible = i < lines.size()
		if row.visible:
			row.text = ("> " if i == at else "  ") + str(lines[i])
			row.add_theme_color_override("font_color",
					Color.WHITE if i == at else Color(0.5, 0.5, 0.5))
	_hint.text = "ARROWS CHANGE  ENTER NEXT  Z BACK\nP1 ARROWS Z/X  P2 WASD ;/'\nDOWN + JUMP: SLIDE"
	_hint.position.y = 184


func show_message(text: String) -> void:
	if text != "":
		_name.text = text
		_name.add_theme_font_size_override("font_size", 9)


## And the one bar of a record being played: what the two of them are spending
## and what each of them is holding.  The level's own picture is behind it, so
## nothing but the one line is drawn.
func show_bar(gear: Pb3Gear) -> void:
	for row in _rows:
		(row as Label).visible = false
	_hint.visible = false
	_name.visible = false
	(get_node("back") as ColorRect).visible = false
	_strip.visible = true
	var say := "E %02d  T %d" % [gear.energy, gear.tanks]
	for i in range(gear.who.size()):
		if gear.who[i] == SOL:
			say += "   P%d GUN %d" % [i + 1, gear.gun[i]]
		else:
			var s: Pb2Status = gear.st[i] as Pb2Status
			say += "   P%d SUIT %d" % [i + 1, s.suit]
		if gear.menu_open(i):
			say += "*"
	_strip.text = say
