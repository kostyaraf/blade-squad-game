extends RefCounted
class_name Pb3Pick

## Э5.3 -- the screen the two of them choose on.
##
## Neither cartridge has one, so there is nothing to copy and nothing to
## compare against.  What it does is therefore kept as small as it can be: it
## holds two choices and a "ready" each, and it answers three questions --
## whether the choosing is over, what was chosen, and what the screen looks
## like.  It knows nothing about levels, and `Pb3Pair` never learns a screen
## was shown at all.
##
## Nothing is drawn that is not in the data.  The letters are Solbrain's own,
## the ones its name screen writes with ($D58F, `SolOver.letter_tile`), and the
## four colours of each side are that game's own from its own screens.

const PB2 := Pb3Pair.PB2
const SOL := Pb3Pair.SOL

## The buttons, which are the same two bytes in both games.
const RIGHT := 0x01
const LEFT := 0x02
const A := 0x80
const B := 0x40

## The screen, in tiles.
const WIDE := 32
const TALL := 30

## Where each player's side of the screen starts, and how wide a side is.
const SIDE_X := [3, 18]
const SIDE_W := 11
## The line the name is written on, and the line under it the mark sits on.
const NAME_Y := 12
const MARK_Y := 15

## What each side is called, and which game it is.
const NAMES := ["POWER BLADE", "SOLBRAIN"]

## Per player: which game he chose, and whether he has said he is done.
var chose: Array[int] = [PB2, PB2]
var ready: Array[bool] = [false, false]
## The pad as it stood last picture, so that holding a button does not flip
## the choice over and over: only the edge counts, the way $8EC1 counts it.
var last_pad: Array[int] = [0, 0]


## The choosing is over when both have said so.
func done() -> bool:
	return ready[0] and ready[1]


## What was chosen, in the shape `Pb3Pair` takes it in.
func kinds() -> Array:
	return [chose[0], chose[1]]


## And in the shape the stands and the plan say it in.
func say() -> String:
	return "%s,%s" % [_word(chose[0]), _word(chose[1])]


static func _word(k: int) -> String:
	return "sol" if k == SOL else "pb2"


## Read it back, so that a walk can start from any arrangement.
func set_say(s: String) -> void:
	var two: PackedStringArray = s.split(",")
	for i in range(mini(2, two.size())):
		chose[i] = SOL if two[i] == "sol" else PB2
	ready[0] = false
	ready[1] = false
	last_pad[0] = 0
	last_pad[1] = 0


## One picture.  Left or right moves a choice across; A says he is done with
## it and B takes that back.  A pad that presses nothing does nothing at all,
## and so does a button that was already down.
func step(pads: Array) -> void:
	for i in range(2):
		var held: int = int(pads[i]) if i < pads.size() else 0
		var hit: int = held & ~last_pad[i]
		last_pad[i] = held
		if hit == 0:
			continue
		if (hit & (LEFT | RIGHT)) != 0:
			chose[i] = SOL if chose[i] == PB2 else PB2
			# Moving across is thinking again, so he is no longer done.
			ready[i] = false
		if (hit & A) != 0:
			ready[i] = true
		if (hit & B) != 0:
			ready[i] = false


## Everything the picker holds, as one word, so that a walk can tell one place
## from another.
func where() -> String:
	return "%s %d%d" % [say(), 1 if ready[0] else 0, 1 if ready[1] else 0]


## The screen, as the tiles it is made of and then the four colours of each
## side.  Nothing here is invented: the letters are the ones Solbrain's name
## screen writes with, and the colours are each game's own.
func picture() -> PackedByteArray:
	var out := PackedByteArray()
	out.resize(WIDE * TALL)
	out.fill(SolOver.letter_tile(SolOver.letter_blank()))
	for i in range(2):
		var x0: int = SIDE_X[i]
		_write(out, x0, NAME_Y, NAMES[chose[i]])
		# Whose side it is, and whether he has settled on it.
		_write(out, x0, NAME_Y - 3, "PLAYER %d" % (i + 1))
		_write(out, x0, MARK_Y, "READY" if ready[i] else "     ")
	for i in range(2):
		for c in _colours(chose[i]):
			out.append(c)
	return out


## Four colours a side, out of the game that side chose and nowhere else.
## Power Blade's are the four its own stage-select screen paints the
## background with (`data/pb2/screens.json`, the table $88CE reads); Solbrain
## keeps its colour tables by the address they stand at, and the four taken
## here are the first of the lowest of them ($8160), which is the first table
## the game ever writes for a screen of text.
static var _pb2_pal := PackedByteArray()
static var _sol_pal := PackedByteArray()

static func _colours(k: int) -> PackedByteArray:
	if k == SOL:
		if _sol_pal.is_empty():
			var d: Dictionary = Nes._load_json(Nes.DATA + "/sol/script.json")
			var pal: Dictionary = d["palettes"]
			var keys: Array = pal.keys()
			keys.sort()
			_sol_pal = PackedByteArray(pal[keys[0]]).slice(0, 4)
		return _sol_pal
	if _pb2_pal.is_empty():
		var d: Dictionary = Nes._load_json(Nes.DATA + "/pb2/screens.json")
		_pb2_pal = PackedByteArray(d["palettes"][Pb2Select.PALETTE]).slice(0, 4)
	return _pb2_pal


static func _write(out: PackedByteArray, x: int, y: int, s: String) -> void:
	for i in range(s.length()):
		var col: int = x + i
		if col < 0 or col >= WIDE or y < 0 or y >= TALL:
			continue
		var c: int = s.unicode_at(i)
		if c == 32:
			out[y * WIDE + col] = SolOver.letter_tile(SolOver.letter_blank())
			continue
		out[y * WIDE + col] = SolOver.letter_tile(c - 65)
