extends RefCounted
class_name SolFade

## The thirty two colours in force, and how Solbrain gets to them.
##
## Nothing in the game writes the console's colours straight.  A mode names a
## table of thirty two ($E9B1, which is nothing but `$20:$21 = the table`) and
## asks for a walk ($F86D -- `$26` says what kind and `$27` which of the eight
## palettes are in it), and bank ten walks it a picture at a time: $F806 counts
## the pictures off, $8520 moves each palette's own level in $05BA..$05C1 by
## one, and $8608 writes the thirty two bytes out again at that level.
##
## A level runs from minus eight to seven.  A colour of the table is split into
## its hue -- the low nibble -- and one of four shades the cartridge wrote it
## at; $86C5 turns that pair into a brightness from nought to seven, the level
## is added and the sum clamped, and $8645 turns the hue and the sum back into
## one of the console's own sixty four colours.  At minus eight every colour
## comes out black, which is how a screen is brought up out of nothing, and at
## plus eight every colour comes out white, which is the flash the change goes
## off in.
##
## $26 is not a tune.  `work/re/sol_screens.md` says which mode names which
## table and asks for which walk.

## $F86D -- the kinds of walk.  The high half is a walk of no pictures at all:
## the table is written out once at the level it stands at, and $FE writes it
## without the backdrop.
const OFF := 0x00
const DOWN := 0x01          # every level to minus eight -- out to black
const UP := 0x02            # every level to plus eight -- out to white
const HOME := 0x05          # every level back to nought -- the table as it is
const ONCE := 0xFF

## $05BA -- how far a level may go either way.
const DARK := -8
const BRIGHT := 8

static var bright: PackedByteArray = PackedByteArray()
static var colours: PackedByteArray = PackedByteArray()
static var tables: Dictionary = {}

var level := PackedInt32Array([0, 0, 0, 0, 0, 0, 0, 0])   # $05BA..$05C1
var kind := 0               # $26
var mask := 0               # $27
var pace := 8               # $28 -- pictures between one step and the next
var count := 8              # $25
var plain := 0              # $96 -- below nought the backdrop is left alone
var table := PackedByteArray()          # what $20:$21 points at
var out := PackedByteArray()            # $0100..$011F, what the console shows


func _init() -> void:
	load_data()
	table.resize(32)
	out.resize(32)


static func load_data() -> void:
	if not bright.is_empty():
		return
	var j: Dictionary = Nes._load_json(Nes.DATA + "/sol/fade.json")
	bright = PackedByteArray(j["bright"])
	colours = PackedByteArray(j["colours"])
	tables = j["tables"]


## $E9B1 -- the table the walk is towards, by the address it stands at in bank
## ten.
func name_table(at: int) -> void:
	load_data()
	var key := "%04X" % at
	assert(tables.has(key), "no palette at $%04X" % at)
	table = PackedByteArray()
	for b in tables[key]:
		table.append(int(b))


## $F86D -- ask for a walk.
func ask(what: int, which: int) -> void:
	kind = what
	mask = which


## $DCE5, $DD02 and $DD22 -- a walk asked for over whatever is already asked
## for: the palettes named are added to the ones already walking instead of
## replacing them.
func ask_more(what: int, which: int) -> void:
	mask |= which
	kind = what


## $F861 and $F865 -- how many pictures one step of a walk takes.
func at_pace(n: int) -> void:
	pace = n
	count = n


## $C5B0, which $C5C9 goes through -- the thirty two written black outright.
## It is not a walk and it does not touch the levels: what is on the screen is
## black until the walk that follows writes the table out again.
func blank() -> void:
	for i in range(32):
		out[i] = 0x0F


## $F84F -- every level to the bottom and the table written out there, which
## is a screen of black.
func dark() -> void:
	for i in range(8):
		level[i] = DARK
	ask(ONCE, ONCE)
	run()


## $F83D, which $C6E9 goes through -- every level back to nought and the table
## written out there.  It is the pace of eight as well.
func full() -> void:
	for i in range(8):
		level[i] = 0
	at_pace(8)
	ask(ONCE, ONCE)
	run()


## $C6E9 -- a table named and so many of its bytes put straight into the
## thirty two.  $F861 sets the pace to eight, $F83D puts every level back to
## nought and writes out the table that was standing, and only then are the
## first `n` bytes of the new one copied raw over that.  So a mode that names
## fewer than thirty two does not leave the rest as they looked: it leaves
## them as the table before it, written out through the walk -- which for a
## screen that copied its own raw is not the same thing at all.
##
## $C711 then writes the new table's first byte into every fourth of the
## thirty two, which is the backdrop the console shows behind everything.
func take(at: int, n: int) -> void:
	for i in range(8):
		level[i] = 0                      # $F83D
	at_pace(8)                            # $F861
	ask(ONCE, ONCE)
	run()                                 # $F812 -- the table that was standing
	name_table(at)                        # $C6FC -- $20:$21 on the new one
	for i in range(n):                    # $C709
		out[i] = table[i]
	for i in range(0, 32, 4):             # $C716 -- the loop leaves Y at $FF
		out[i] = table[0]                 # and the INY makes it nought again


## $F806 -- one picture, which $CA9A calls.  A walk only steps every `pace`
## pictures; between them nothing happens at all.
func tick() -> void:
	if kind == 0:
		mask = 0
		return
	count = (count - 1) & 0xFF
	if count != 0:
		return
	count = pace
	run()


## $8520 -- one step of the walk, and then the whole table written out.
func run() -> void:
	if mask == 0:
		kind = 0
		return
	plain = 0
	var a := kind
	if a == 0:
		return
	if a >= 0x80:
		if a == 0xFE:
			plain = -1
		kind = 0
		mask = 0
	elif a == 1:
		_walk(-1, false)
	elif a == 2:
		_walk(1, false)
	elif a == 3:
		plain = -1
		_walk(-1, false)
	elif a == 4:
		plain = -1
		_walk(1, false)
	elif a == 5:
		_walk(0, true)
	else:
		plain = -1
		_walk(0, true)
	_write()


## $8545, $8575 and $85A9 -- the same walk three ways over the eight levels,
## and the mask is left holding only those that have not arrived.  `by` is
## which way each level moves; `home` moves it towards nought instead.
func _walk(by: int, home: bool) -> void:
	var m := 0
	for x in range(8):
		if ((mask >> x) & 1) == 0:
			continue
		var v: int = level[x]
		var keep := true
		if home:
			if v == 0:
				keep = false
			else:
				v += (1 if v < 0 else -1)
				keep = v != 0
		elif by < 0:
			v -= 1
			# $8584 -- one below the bottom is where the walk down stops.
			keep = v >= DARK
		else:
			v += 1
			keep = v != BRIGHT
		level[x] = v
		if keep:
			m |= 1 << x
	mask = m


## $85CD -- the thirty two written out at the level each of the eight palettes
## has reached, and then, when the walk owns the backdrop, the backdrop copied
## into every fourth byte the way the console wires it.
func _write() -> void:
	for y in range(32):
		if (y & 3) == 0 and plain < 0:
			continue                      # $863A
		out[y] = _one(table[y], level[y >> 2])
	if plain == 0:
		for y in range(4, 0x20, 4):       # $85EB
			out[y] = out[0]


## $8608 -- one colour at one level.
static func _one(c: int, at: int) -> int:
	var hue: int = c & 0x0F
	var shade: int = (c >> 4) & 0x03
	var b: int = (int(bright[hue * 4 + shade]) + at) & 0xFF
	if b >= 0x80:
		b = 0                             # $8627
	elif b >= 8:
		b = 7                             # $862F
	return int(colours[hue * 8 + b])
