extends RefCounted
class_name SolTale

## $8037 and $803A in bank four -- the words of the tale, typed one at a time.
##
## The screen of mode $5D arrives with no words on it.  What puts them there is
## a little stream at $80F9 that $8068 walks a record at a time: every eighth
## picture, or every picture while a button is held, one record is taken and
## one byte handed to the queue at $0300 for the picture unit to take.  When
## the stream runs out $57 is set, and that is what ends the mode -- so how
## long the tale stands is how long the typing takes and nothing else.
##
## A byte that is not nought is a tile, written where the place stands, and the
## place then walks on by one.  A nought opens a record and the byte after it
## says which: nought again is the end of the stream, two asks for a tune, and
## one gives a new place -- two bytes of it -- and the first tile of the line.

static var _cfg: Dictionary

## $5C:$5D -- how far into the stream the typing has got.
var at := 0
## $5F:$5E -- where in the console's name map the next tile goes.
var addr := 0x2000
## $57 -- set once the stream has run out.
var done := false
## $F8 -- the record that asks for a tune leaves it here.
var noise := 0


static func _data() -> void:
	if _cfg.is_empty():
		_cfg = JSON.parse_string(FileAccess.get_file_as_string(
				"res://data/sol/tale.json"))


static func bytes() -> Array:
	_data()
	return _cfg["bytes"]


static func every() -> int:
	_data()
	return int(_cfg["every"])


## $8055 -- the stream taken from the top.
func rewind() -> void:
	_data()
	at = 0
	addr = 0x2000
	done = false
	noise = 0


## $8068 -- one picture of the typing.  `host` is handed each tile as it is
## written; `clock` is $0C and `held` what the pad has down.
func step(clock: int, held: int, host) -> void:
	if done:
		return
	if held == 0 and (clock & (every() - 1)) != 0:
		return                                    # $806C
	var s: Array = bytes()
	while true:
		var b: int = int(s[at])
		if b != 0:                                # $80BA -- a tile
			host.flow_poke(addr, b)
			at += 1
			addr = (addr + 1) & 0xFFFF
			return
		var cmd: int = int(s[at + 1])
		if cmd == 0:                              # $8080 -- the end
			done = true
			return
		at += 2                                   # $8085
		if cmd == 2:                              # $8090 -- a tune
			noise = 0xFF
			continue
		# $8096 -- a new place, and the first tile of the line with it.
		addr = (int(s[at]) << 8) | int(s[at + 1])
		at += 2
		host.flow_poke(addr, int(s[at]))
		at += 1
		addr = (addr + 1) & 0xFFFF
		return
