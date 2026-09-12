extends RefCounted
class_name SolScript

## Э4.5 -- the stage's own script, $93B5 in bank eight.
##
## Every picture that is played, $CDB3 maps banks eight and nine and calls it.
## It is the only part of Solbrain that knows where in the stage the player has
## got to, and it is what makes a stage more than a room full of walking
## things: it widens and narrows the view's bounds as he goes, turns over the
## books of tiles the background is drawn out of, lets the bosses out, and at
## the end of a stage writes the number of the next one into $55.
##
## Three layers of table stand between the picture and the code that runs:
##
##   * the room.  The high byte of the view across, plus eight and divided by
##     sixteen, is the column; the high byte down, plus eight and masked, the
##     row; and column plus row is the room.  When it is not the room of the
##     last picture the step counter $7F is put back to nought, so a script
##     always begins at its first step when the room is entered;
##   * the stage.  $93E8 holds a dispatcher for each of the twenty, and they
##     are shared -- stages 0 and 8 use one, 15, 16 and 19 another;
##   * the routine.  The dispatcher looks the room up in its own room table and
##     jumps through its own list of routines.
##
## A routine that is a script of several steps jumps once more, through a table
## of its own indexed by $7F -- or, for the last stage's closing scene, by $58.
##
## The tables are exported by `work/extract/sol_script.py`; the routines are
## code and are ported by hand below, named by the address the cartridge keeps
## each one at.  What each does to memory is written against the address that
## does it, so the listing and this file can be read side by side.
##
## The script is written against a flat two kilobytes of the console's own
## memory rather than against the engine's own objects, because a third of what
## it touches -- the background's owed rows, the scrolled-in pieces of the last
## stage's closing scene, the numbers the screen shows -- has no home in the
## engine at all.  The host writes in what it keeps elsewhere before the step
## and reads back out what the script changed, and the acceptance stand hands
## the whole two kilobytes straight over from the cartridge.


static var data: Dictionary = {}
static var types: Array = []

## The console's memory, $0000..$07FF.
var m := PackedByteArray()
## The carry, where a routine leans on what the last one left.
var cf := 0
## What the jump through a table left in X.  Two routines read the pool with
## it ($A8EB, and $A905 behind it), so the doubled index is kept.
var xr := 0
## Set when an index runs off the end of its own table.  The cartridge has no
## such guard -- it jumps to whatever the bytes past the table happen to spell
## -- so a picture that sets this is one no acceptance can be asked about.
var wild := false
## Set when a routine asks for a colour table or a map record the export has
## never seen.  Nothing in the cartridge does, so a picture that sets this is
## one the stand should not be asked about.
var owed := false
## Every routine this picture went through, so that an acceptance can say how
## much of the script it has actually seen run.
var trail := PackedInt32Array()

## $BDCA -- the nine bytes of every kind of thing, in bank nine.
const TEMPLATES := 0xBDCA


func _init() -> void:
	m.resize(0x0800)
	load_data()


static func load_data() -> void:
	if not data.is_empty():
		return
	data = Nes._load_json(Nes.DATA + "/sol/script.json")
	types = Nes._load_json(Nes.DATA + "/sol/objects.json")["types"]


func g(a: int) -> int:
	return m[a]


func p(a: int, v: int) -> void:
	m[a] = v & 0xFF


func w(lo: int, hi: int) -> int:
	return m[lo] | m[hi] << 8


# ------------------------------------------------------------------ the top


## $93B5 -- one picture of the stage's own script.
func step() -> void:
	cf = 0
	var col: int = ((g(0x31) + 0x08) & 0xFF) >> 4          # $93B6
	var room: int = (((g(0x33) + 0x08) & 0xF0) + col) & 0xFF
	if room != g(0x05EB):                                  # $93CB
		p(0x05EB, room)
		p(0x7F, 0)
	var d: Dictionary = data["dispatch"][int(data["stages"][g(0x55)])]
	var rooms: Array = d["rooms"]
	if room >= rooms.size():
		wild = true
		return
	var which: int = int(rooms[room])
	var routines: Array = d["routines"]
	if which >= routines.size():
		wild = true
		return
	xr = (which * 2) & 0xFF
	_call(int(routines[which]))


## The second level: a script of several steps, picked by one of its own
## counters.  $7F for all but the last stage's closing scene, which uses $58.
func _second(name: String, by: int) -> void:
	var t: Array = data["tables"][name]
	var k: int = g(by)
	cf = (k >> 7) & 1                                      # the ASL before TAX
	if k >= t.size():
		wild = true
		return
	xr = (k * 2) & 0xFF
	_call(int(t[k]))


# --------------------------------------------------------------- the console


func _adc(a: int, v: int) -> int:
	var t: int = a + v + cf
	cf = 1 if t > 0xFF else 0
	return t & 0xFF


func _sbc(a: int, v: int) -> int:
	var t: int = a - v - (1 - cf)
	cf = 0 if t < 0 else 1
	return t & 0xFF


func _cmp(a: int, v: int) -> void:
	cf = 1 if a >= v else 0


# ---------------------------------------------------------------- the shared


## $8040 -- forget where the last thing was put.
func _clear_at() -> void:
	p(0x90, 0)
	p(0x91, 0)
	p(0x92, 0)
	p(0x93, 0)


## $804B -- what the screen still owes, and what is to be done when it is paid.
func _owe(a: int, y: int) -> void:
	p(0x26, a)
	p(0x27, y)


## $8050 -- the high half of where the hero stands, half a screen along.
func _hero_col() -> int:
	_adc(g(0x80), 0x80)
	return _adc(g(0x81), 0x00)


## $C045, $C048, $C04B, $C060..$C06F -- all of them only ask for a tune.
func _tune(a: int, y: int) -> void:
	p(0x20, a)
	p(0x21, y)


## $9E34 -- how far the first slot stands from the hero, and which side of him
## it is on ($05B2).
func _gap_to_hero() -> void:
	p(0x90, _sbc(g(0xA0), g(0x80)))
	var hi: int = _sbc(g(0xB0), g(0x81))
	p(0x91, hi)
	p(0x05B2, hi)
	if hi < 0x80:
		return
	p(0x90, _sbc(0x00, g(0x90)))
	p(0x91, _sbc(0x00, g(0x91)))


## $9E52, $9E5D, $9E68 -- empty the three pools, as far as each is the stage's.
func _wipe_pool() -> void:
	for i in range(0x0C):
		p(0x0600 + i, 0)


func _wipe_shots() -> void:
	for i in range(0x10):
		p(0x0780 + i, 0)


func _wipe_weapons() -> void:
	for i in range(0x0B):
		p(0x0700 + i, 0)


## $9E73 -- hold the hero still: while he is in a suit he is given the longest
## wait there is, and either way the buttons he is handed are taken away.
func _hold_hero() -> void:
	if g(0x05C5) != 0:
		p(0x05A3, 0x1F)
	p(0x06, 0)
	p(0x04, 0)


## $AF20 -- put a thing of a kind into slot X, at $90..$93, with its nine
## bytes taken from the template table $BDCA.
func _put(x: int, id: int) -> void:
	p(0x0600 + x, id)
	p(0x00A0 + x, g(0x90))
	p(0x00B0 + x, g(0x91))
	p(0x00C0 + x, g(0x92))
	p(0x00D0 + x, g(0x93))
	var t: Dictionary = types[g(0x9D)]
	# $AF33..$AF54 -- the nine bytes are read through $9D:$9E, and the pointer
	# is left standing there afterwards.
	var ptr: int = (TEMPLATES + 9 * g(0x9D)) & 0xFFFF
	p(0x9D, ptr & 0xFF)
	p(0x9E, ptr >> 8)
	p(0x0650 + x, int(t["mind"]))
	p(0x0660 + x, int(t["pic_lo"]))
	p(0x0670 + x, int(t["pic_hi"]))
	p(0x0610 + x, int(t["a"]))
	p(0x0620 + x, int(t["b"]))
	p(0x0630 + x, int(t["c"]))
	p(0x0640 + x, int(t["d"]))
	p(0x0690 + x, int(t["kind"]))
	p(0x06F0 + x, int(t["life"]))
	# $AF8E -- which way it looks is which side of it the hero is on.
	_cmp(g(0x80), g(0x00A0 + x))
	p(0x0680 + x, _sbc(g(0x81), g(0x00B0 + x)))
	p(0x06D0 + x, 0)
	p(0x06C0 + x, 0)
	p(0x06A0 + x, 0)
	p(0x06B0 + x, 0)
	p(0x06E0 + x, 0xFF)


## $A46C -- the last free slot of the twelve, emptied out and given a boss's
## own numbers, or -1 when the pool is full.
func _free() -> int:
	var x := 0x0B
	while x >= 0 and g(0x0600 + x) != 0:
		x -= 1
	if x < 0:
		return -1
	p(0x00A0 + x, 0)
	p(0x00C0 + x, 0)
	p(0x00B0 + x, g(0x91))
	p(0x00D0 + x, g(0x93))
	p(0x0600 + x, 0xFF)
	p(0x06F0 + x, 0xFF)
	p(0x0650 + x, 0x96)
	p(0x0640 + x, 0x04)
	for a in [0x0610, 0x0620, 0x0630, 0x06D0, 0x06C0, 0x06A0, 0x06B0,
			0x0660, 0x0670]:
		p(a + x, 0)
	return x


## $A722 -- what a beaten stage leaves behind: the ground is forgotten and the
## three numbers the ending leans on are written in.
func _a722() -> void:
	p(0x05CD, 0)
	p(0x05E8, 0xB8)
	p(0x05E9, 0x04)
	p(0x05EA, 0x06)


## $A737 -- turn the speed round when the side has changed.
func _a737(a: int) -> int:
	if ((a ^ g(0x05CB)) & 0x80) == 0:
		return a
	p(0x05AD, _sbc(0x00, g(0x05AD)))
	p(0x05AE, _sbc(0x00, g(0x05AE)))
	return a


## $9BC8 -- the hero has walked into a beaten boss's room: the meter is turned
## over once and the ending's numbers are written in.
func _9bc8() -> void:
	if g(0x05A2) == 0x01 and g(0x05AC) == g(0x05EA):
		p(0x05AC, (g(0x05AC) + 1) & 0xFF)
		p(0x05CB, _a737(g(0x05CB) ^ 0x80))
	_a722()


## $A701, $9CAA and $AD70 -- the same, with the stage marked beaten first.
func _beaten() -> void:
	p(0x5B, 0x06)
	_9bc8()


# --------------------------------------------- the two ends every routine has


## $AAA9 -- and the ground is forgotten first.
func _xAAA9() -> void:
	p(0x05CD, 0)
	_xAAAE()


## $AAAE -- the book of tiles the background is drawn out of is turned over
## every four pictures, which is what makes water move and lights blink.
func _xAAAE() -> void:
	p(0x41, int(data["chr_a"][(g(0x0C) >> 2) & 3]))


## $AE58 -- the same, out of the other four books.
func _xAE58() -> void:
	p(0x41, int(data["chr_b"][(g(0x0C) >> 2) & 3]))


# ------------------------------------------------- stages 0 and 8 ($9410)


## $AABF, $AAD4, $AAE9, $AAFE, $AB13 -- five rooms of the first stage, each
## opening the view a little further the moment it reaches the room's edge.
func _xAABF() -> void:
	if g(0x31) == 0x50:
		p(0x39, 0x50)
		p(0x3F, 0x31)
		p(0x38, 0)
		p(0x3E, 0)
	_xAAAE()


func _xAAD4() -> void:
	if g(0x33) == 0x20:
		p(0x3D, 0x20)
		p(0x3B, 0x90)
		p(0x38, 0)
		p(0x3E, 0)
	_xAAAE()


func _xAAE9() -> void:
	if g(0x31) == 0x80:
		p(0x39, 0x80)
		p(0x3F, 0x51)
		p(0x38, 0)
		p(0x3E, 0)
	_xAAAE()


func _xAAFE() -> void:
	if g(0x33) == 0x40:
		p(0x3D, 0x40)
		p(0x3B, 0xD0)
		p(0x38, 0)
		p(0x3E, 0)
	_xAAAE()


func _xAB13() -> void:
	if g(0x31) == 0xC0:
		p(0x39, 0xC0)
		p(0x3F, 0x81)
		p(0x38, 0)
		p(0x3E, 0)
	_xAAAE()


## $AB28 -- the boss's room of the first stage, four steps long.
func _xAB28() -> void:
	_second("AB39", 0x7F)


## $AD94 -- and the last room of the eighth, two steps.
func _xAD94() -> void:
	_second("ADA5", 0x7F)


## $AB41 -- step one of a boss's room everywhere it is used: he must be in a
## suit, standing in the right column and low enough, and not already busy.
func _xAB41() -> void:
	if g(0x05C5) != 0 and _hero_col() == 0xCB and g(0x83) >= 0x79 \
			and g(0x05A2) == 0 and _xAB6A() != 0:
		p(0xF0, 0x0F)
		p(0xF1, 0x05)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAAAE()


## $AB6A -- shutting the room: the three pools are emptied, the first thing of
## the boss's own list is queued, the view is pinned where it stands and the
## screen is told to scroll on by itself.  Nought when the room is refused.
func _xAB6A() -> int:
	if g(0x05C3) != 0:
		return 0
	var v: int = g(0x05A6) & 0xFE
	if v != 0x64 and v != 0xDA and v != 0x68:
		return 0
	_wipe_pool()
	_wipe_shots()
	_wipe_weapons()
	p(0x0561, 0x01)
	p(0x0560, 0x00)
	p(0x90, _sbc(g(0x80), g(0x30)))
	_xABD2(_sbc(g(0x81), g(0x31)))
	p(0x90, _sbc(g(0x82), g(0x32)))
	var a: int = _xABD2(_sbc(g(0x83), g(0x33)))
	a = _adc(a, 0x10)
	p(0x75, a)
	p(0x0200, a)
	p(0x7D, 0x36)
	p(0x7B, 0x00)
	p(0x73, 0x03)
	p(0x74, 0x03)
	p(0x72, 0x18)
	p(0x3C, g(0x32))
	p(0x3D, g(0x33))
	return g(0x33)


## $ABD2 -- the pair $90 and A, shifted four down; the four bits of A that come
## out the bottom are what is wanted.
func _xABD2(a: int) -> int:
	for _i in range(4):
		var bit: int = a & 1
		a >>= 1
		p(0x90, (g(0x90) >> 1) | (bit << 7))
	cf = 0
	return g(0x90)


## $ABE2 -- step two: the boss's own list is let out, one thing every fourth
## picture, into the $0700 pool.
func _xABE2() -> void:
	var v: int = _xACE5()
	if (v & 0x07) == 0:
		if g(0x05BE) < 0x02:
			p(0x05BE, (g(0x05BE) + 1) & 0xFF)
			p(0x05BF, g(0x05BE))
			p(0x26, 0xFF)
			p(0x27, 0xFF)
	_hold_hero()
	p(0x0561, (g(0x0561) - 1) & 0xFF)
	if g(0x0561) != 0:
		_xAAAE()
		return
	p(0x0561, (g(0x0561) + 1) & 0xFF)
	var x := 0x07
	while x >= 0 and g(0x0700 + x) != 0:
		x -= 1
	if x < 0:
		_xAAAE()
		return
	var y: int = int(data["spawn_order"][g(0x0560)])
	if y >= 0x80:                                          # $AC1C, the $FF end
		p(0x05A2, 0x11)
		if g(0x060C) != 0:
			p(0x060C, g(0x060C) | 0x80)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
		_xAAAE()
		return
	p(0x0560, (g(0x0560) + 1) & 0xFF)
	p(0x0561, 0x04)
	p(0x0700 + x, 0x92)
	p(0x0770 + x, 0x92)
	p(0x0750 + x, int(data["spawn_speed"][y]))
	p(0x0760 + x, int(data["spawn_mind"][y]))
	p(0x0730 + x, int(data["spawn_mind"][y]))
	cf = 0
	p(0x0740 + x, _adc(g(0x83), 0x01))
	p(0x0710 + x, int(data["spawn_at"][y * 2]))
	cf = 0
	p(0x0720 + x, _adc(g(0x81) & 0xFE, int(data["spawn_at"][y * 2 + 1])))
	_xAAAE()


## $AC96 -- step three: the boss's own list is walked until nothing of it is
## left, and then the screen is asked to be paid off.
func _xAC96() -> void:
	_xACE5()
	_hold_hero()
	if (g(0x05A6) | g(0x05A7)) == 0:
		p(0x26, 0x01)
		p(0x27, 0xFF)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAAAE()


## $ACB1 -- what a beaten boss leaves: the thing that was watching is let go
## and the game is put into $40, the walk out of the room.
func _xACB1(a: int) -> void:
	p(0x7D, a)
	var v: int = g(0x060C)
	if v != 0 and v != 0xFF and g(0x06FC) != 0:
		p(0x060C, v & 0x3F)
	p(0x02, 0x40)


## $ACCE -- step four of the first stage's boss: the eighth stage is named.
func _xACCE() -> void:
	p(0x0C, g(0x0C) | 0x10)
	_hold_hero()
	if g(0x26) == 0:
		_xACB1(0)
		p(0x55, 0x08)
	_xAAAE()


## $ACE5 -- while a boss's room is being shut the clock is held on.
func _xACE5() -> int:
	p(0x0C, g(0x0C) | 0x08)
	return g(0x0C)


## $ADA9 -- the last room of the eighth stage: the thing that carries him off.
func _xADA9() -> void:
	if g(0x05A2) == 0:
		p(0x9D, 0x08)
		_clear_at()
		p(0x91, 0xDC)
		p(0x93, 0x10)
		_put(0x00, 0x41)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAAAE()


## $ADC9 -- and then the walk out of the stage.
func _xADC9() -> void:
	_x9355()
	_xAAAE()


## $9355 -- the walk out of a stage, four steps kept in $05FA: wait for the
## first slot to be empty, hold him still, count the burst down, and ask for
## the picking of the next stage.
## $9365 -- `JSR $8025` with the list of places written into the code right
## behind it.  $8025 pops the return address into $29:$2A, which is the last
## byte of the JSR and so one before the list, picks the word at twice the
## index out of it into $2B:$2C, and jumps through that.  All four bytes are
## left standing, so the port leaves them standing too.
const INLINE_9355 := 0x9367
const INLINE_9355_TO := [0x9370, 0x9371, 0x9385, 0x9398]


func _x9355() -> void:
	if g(0x0600) != 0:
		return
	if g(0x05FA) == 0:
		p(0x05FA, (g(0x05FA) + 1) & 0xFF)
	p(0x29, INLINE_9355 & 0xFF)
	p(0x2A, INLINE_9355 >> 8)
	var i: int = g(0x05FA)
	if i >= INLINE_9355_TO.size():
		wild = true
		return
	var to: int = INLINE_9355_TO[i]
	p(0x2B, to & 0xFF)
	p(0x2C, to >> 8)
	match to:
		0x9370: pass                                       # only an RTS
		0x9371: _x9371()
		0x9385: _x9385()
		0x9398: _x9398()


func _x9371() -> void:
	var v: int = g(0x05A2)
	if v == 0 or v == 0x08:
		p(0x05AB, 0)
		p(0x05FA, (g(0x05FA) + 1) & 0xFF)
	_hold_hero()


func _x9385() -> void:
	p(0x05AB, (g(0x05AB) - 1) & 0xFF)
	if g(0x05AB) == 0:
		p(0x26, 0x01)
		p(0x27, 0xFF)
		p(0x05FA, (g(0x05FA) + 1) & 0xFF)
	_hold_hero()


func _x9398() -> void:
	if g(0x26) == 0:
		p(0x060C, 0)
		p(0x05C2, 0)
		p(0xF0, 0x10)
		p(0x02, 0x24 if g(0x0D) != 0 else 0x1B)
	_hold_hero()


# --------------------------------------- stage 13 ($9488) and 1, 2 ($94A2)


## $A89A -- the last room of the fourteenth stage, two steps.
func _xA89A() -> void:
	_second("A8AB", 0x7F)


## $A8AF -- the thing that carries him off, and the scroll that takes him to it.
func _xA8AF() -> void:
	if g(0x05A2) == 0:
		p(0x9D, 0x0A)
		_clear_at()
		p(0x91, 0x5C)
		p(0x93, 0xE4)
		_put(0x00, 0x41)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
		p(0x7D, 0x3C)
		p(0x76, 0x20)
		p(0x72, 0x20)
		p(0x77, 0x00)
		p(0x7B, 0x03)
		p(0x75, 0xE0)
	_xAAAE()


## $A8E5 -- and then the walk out, with the scroll still being held.
func _xA8E5() -> void:
	_x9355()
	_xAA46()


## $A94B -- the room above it: once the view is at the top the floor is let
## down to $50 and the carrying map is stopped.
func _xA94B() -> void:
	_x9355()
	if g(0x33) == 0x10 and (g(0x32) & 0xE0) == 0:
		p(0x32, 0)
		p(0x3F, 0x50)
		p(0x34, 0)
	_xAAAE()


## $A835 -- the second stage's climb: past the seventh column the view opens
## and, while he is not busy and has climbed clear of it, it is walked up.
func _xA835() -> void:
	_cmp(g(0x31), 0x70)
	if cf == 0:
		_xAAAE()
		return
	p(0x39, g(0x31))
	p(0x3F, 0x51)
	p(0x38, 0)
	p(0x3C, 0)
	if g(0x05A2) == 0x01:
		_xAAAE()
		return
	cf = 1
	var d: int = _sbc(g(0x83), g(0x33))
	if cf == 0:
		_xAAAE()
		return
	_cmp(d, 0x08)
	if cf == 0:
		_xAAAE()
		return
	cf = 0
	p(0x32, _adc(g(0x32), 0x10))
	if cf != 0:
		p(0x33, (g(0x33) + 1) & 0xFF)
	_xAAAE()


func _xA867() -> void:
	if g(0x33) == 0x40:
		p(0x3D, 0x40)
		p(0x3B, 0xF0)
		p(0x38, 0)
		p(0x3E, 0)
	_xAAAE()


## $A87C -- the end of the second stage: the third is named.
func _xA87C() -> void:
	if g(0x05C5) != 0 and g(0x81) >= 0xEE:
		p(0x02, 0x35)
		p(0x26, 0x03)
		p(0x27, 0xCF)
		p(0x55, 0x02)
	_xAAAE()


## $A8EB -- the room the second stage's boss waits in: the view is pinned, the
## boss is put in if the slot the dispatcher left is not already holding one,
## and the scroll that carries him is started.
func _xA8EB() -> void:
	if g(0x31) != 0x30 or g(0x31) == g(0x39):
		_xAA46()
		return
	p(0x39, 0x30)
	p(0x3D, 0x40)
	p(0x38, 0)
	p(0x3C, 0)
	p(0x57, 0)
	p(0x58, 0)
	var here := false
	if g(0x0600 + xr) != 0 and (g(0x0650 + xr) & 0x3F) == 0x3F:
		here = true
	if not here:
		p(0x9D, 0x1C)
		_clear_at()
		p(0x91, 0x38)
		p(0x93, 0xEE)
		_put(0x00, 0x41)
	if g(0x7D) == 0x3C:
		_xAA46()
		return
	p(0x76, 0x20)
	p(0x72, 0x20)
	p(0x77, 0x00)
	p(0x7B, 0x03)
	p(0x75, 0xE0)
	p(0x7D, 0x3C)
	_xAAAE()


## $AA46 -- the scroll that carries him along the top of the second stage.
func _xAA46() -> void:
	p(0x09, g(0x09) & 0xFD)
	p(0x74, 0)
	if g(0x70) == 0x3C:
		_cmp(g(0x75), 0xA1)
		if cf == 0:
			p(0x34, 0x08)
		else:
			var bit: int = g(0x0C) & 1                     # $AA64, the ROR out
			if bit != 0:
				p(0x74, 0xFF)
	_xAAAE()


## $A9C6 -- the second stage's boss itself, four turns kept in $57.
func _xA9C6() -> void:
	if g(0x33) != 0x40 or (g(0x32) & 0xE0) != 0:
		_xAAAE()
		return
	p(0x32, 0)
	p(0x3F, 0x50)
	p(0x34, 0)
	var t: int = g(0x57)
	if t == 0:
		p(0x58, (g(0x58) + 1) & 0xFF)
		if g(0x58) >= 0x80:
			p(0x58, 0)
			p(0x57, (g(0x57) + 1) & 0xFF)
	elif t < 0x02:
		if (g(0x0C) & 0x03) == 0:
			p(0x74, 0xFF)
			if g(0x75) == 0x60:
				p(0x57, (g(0x57) + 1) & 0xFF)
	elif t == 0x02:
		p(0x58, (g(0x58) + 1) & 0xFF)
		if g(0x58) >= 0x80:
			p(0x58, 0)
			p(0x57, (g(0x57) + 1) & 0xFF)
	elif t < 0x04:
		if g(0x75) >= 0xA0:
			p(0x72, 0)
		if (g(0x0C) & 0x03) == 0:
			p(0x74, 0x01)
			if g(0x75) == 0xE0:
				p(0x7D, 0)
				p(0x0600, 0)
				p(0x3B, 0x60)
				p(0x57, (g(0x57) + 1) & 0xFF)
	_xAAAE()


## $A967 -- the third stage's boss room, four steps.
func _xA967() -> void:
	_second("A978", 0x7F)


func _xA98C() -> void:
	if g(0x05C5) != 0 and _hero_col() == 0x5B and g(0x83) == 0x48 \
			and g(0x05A2) == 0 and _xAB6A() != 0:
		p(0xF0, 0x0F)
		p(0xF1, 0x05)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAAAE()


func _xA980() -> void:
	_xABE2()


func _xA986() -> void:
	_xAC96()


func _xA9B5() -> void:
	_hold_hero()
	if g(0x26) == 0:
		_xACB1(0)
		p(0x55, 0x0D)
	_xAAAE()


# ------------------------ stages 3, 9, 18 ($94C4) and 10, 11, 14 ($94DE)


## $A252 -- the end of the fourth stage.
func _xA252() -> void:
	if g(0x05C5) != 0 and g(0x81) >= 0x7E:
		p(0x02, 0x35)
		_owe(0x03, 0xCF)
		p(0x55, 0x09)
	_xAE58()


## $A13F -- a pair of things that must both be beaten, seven steps.
func _xA13F() -> void:
	_second("A150", 0x7F)


func _xA169() -> void:
	if g(0x05A2) == 0:
		p(0x9D, 0x0B)
		_clear_at()
		p(0x91, 0x9B)
		p(0x93, 0x40)
		_put(0x00, 0x41)
		p(0x9D, 0x0B)
		_clear_at()
		p(0x91, 0x94)
		p(0x93, 0x40)
		_put(0x01, 0x41)
		p(0x0611, 0xFF)
		p(0x58, 0x01)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


func _xA1A8() -> void:
	if (g(0x0C) & 1) != 0:
		p(0x58, (g(0x58) + 1) & 0xFF)
	if g(0x58) == 0:
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


func _xA1B8() -> void:
	var live := false
	if g(0x0600) != 0 and g(0x0650) < 0x80 and g(0x0690) < 0x80:
		live = true
	elif g(0x0601) != 0 and g(0x0651) < 0x80 and g(0x0691) < 0x80:
		live = true
	if not live:
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


func _xA1DB() -> void:
	# $A1DB -- a slot that is in the pool, alive, of the right kind and turned
	# the right way holds the step where it is; anything else lets it on.
	var stop := false
	var on := false
	if g(0x0600) != 0 and g(0x0650) < 0x80:
		if (g(0x0690) & 0x7F) != 0x08 or g(0x06C0) < 0x80:
			stop = true
	if not stop:
		if g(0x0601) == 0 or g(0x0651) >= 0x80:
			on = true
		elif (g(0x0691) & 0x7F) != 0x08 or g(0x06C1) < 0x80:
			stop = true
		else:
			p(0xF1, 0x38)                                  # $A20B
			on = true
	if on:
		p(0x7F, (g(0x7F) + 1) & 0xFF)
		p(0x0690, (g(0x0690) + 1) & 0xFF)
		p(0x0691, (g(0x0691) + 1) & 0xFF)
	_xAE58()


func _xA21A() -> void:
	var on := true
	if g(0x0600) != 0:
		p(0x58, (g(0x58) + 1) & 0xFF)
		if g(0x58) < 0x40:
			on = false
		else:
			p(0xF1, 0x38)
	if on:
		p(0x58, 0)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
		p(0x0690, (g(0x0690) + 1) & 0xFF)
	_xAE58()


func _xA237() -> void:
	var on := true
	if g(0x0601) != 0:
		p(0x58, (g(0x58) + 1) & 0xFF)
		if g(0x58) < 0x20:
			on = false
		else:
			p(0xF1, 0x38)
	if on:
		p(0x7F, 0x01)
		p(0x0691, (g(0x0691) + 1) & 0xFF)
	_xAE58()


func _xA15E() -> void:
	if g(0x0601) == 0:
		_x9355()
	_xAE58()


## $A26F -- the boss room of the tenth stage, four steps.
func _xA26F() -> void:
	_second("A280", 0x7F)


func _xA294() -> void:
	if g(0x05C5) != 0 and _hero_col() == 0x8D and g(0x83) == 0x46 \
			and g(0x05A2) == 0 and _xAB6A() != 0:
		p(0xF0, 0x0F)
		p(0xF1, 0x05)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


func _xA288() -> void:
	_xABE2()
	_xAE58()


func _xA28E() -> void:
	_xAC96()
	_xAE58()


func _xA2BD() -> void:
	_hold_hero()
	if g(0x26) == 0:
		_xACB1(0)
		p(0x55, 0x12)
	_xAE58()


func _xA0DA() -> void:
	if g(0x33) == 0x60:
		p(0x3D, 0x60)
		p(0x3B, 0x80)
		p(0x3C, 0)
		p(0x3A, 0)
	_xAE58()


## $A0EF and $A0FC -- the two rooms whose own piece of the background is drawn
## from a different place in the tile sheet.
func _xA0EF() -> void:
	p(0x010A, 0x11)
	p(0x010B, 0x33)
	_xAE58()


func _xA0FC() -> void:
	p(0x010A, 0x00)
	p(0x010B, 0x20)
	_xAE58()


func _xA109() -> void:
	if g(0x33) == 0x40:
		p(0x3D, 0x40)
		p(0x3B, 0x90)
		p(0x38, 0)
		p(0x3E, 0)
	_xAE58()


## $A11E -- the end of the eleventh stage.
func _xA11E() -> void:
	if g(0x05C5) != 0 and g(0x81) >= 0x8E:
		p(0x7D, 0)
		p(0x02, 0x35)
		_owe(0x03, 0xCF)
		p(0x55, 0x0B)
	_xAE58()


## $A2CE -- the room that lets the way out down, four steps.
func _xA2CE() -> void:
	_second("A2DF", 0x7F)


func _xA2E7() -> void:
	if g(0x05A2) < 0x12:
		p(0x58, 0x40)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


func _xA2F7() -> void:
	p(0x58, (g(0x58) - 1) & 0xFF)
	if g(0x58) == 0:
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	if g(0x58) >= 0x20 and (g(0x58) & 0x03) == 0:
		p(0xF1, 0x3A)
	_xAE58()


func _xA30E() -> void:
	p(0x9D, 0x0E)
	_clear_at()
	p(0x91, 0x3E)
	p(0x93, 0x34)
	_put(0x00, 0x41)                                       # $A315 -- TAX of nought
	p(0xF1, 0x38)
	p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xA329()


func _xA329() -> void:
	_x9355()
	_xAE58()


## $AE2E -- the room below, which turns over the last book of tiles as well.
func _xAE2E() -> void:
	if (g(0x31) & 0x0F) == 0:
		p(0x45, 0x73)
	_xAE38()


## $AE38 -- the place the carrying map sets him down, two steps.
func _xAE38() -> void:
	_second("AE49", 0x7F)


func _xAE4D() -> void:
	p(0x75, 0x68)
	p(0x7D, 0x57)
	p(0x7F, (g(0x7F) + 1) & 0xFF)


## $ADCF -- the boss room of the fifteenth stage, four steps.
func _xADCF() -> void:
	_second("ADE0", 0x7F)


func _xADF4() -> void:
	if g(0x05C5) != 0 and _hero_col() == 0x7D and g(0x83) == 0x65 \
			and g(0x05A2) == 0 and _xAB6A() != 0:
		p(0xF0, 0x0F)
		p(0xF1, 0x05)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


func _xADE8() -> void:
	_xABE2()
	_xAE58()


func _xADEE() -> void:
	_xAC96()
	_xAE58()


func _xAE1D() -> void:
	_hold_hero()
	if g(0x26) == 0:
		_xACB1(0)
		p(0x55, 0x0E)
	_xAE58()


# ----------------------------- stages 4, 5, 17 ($9464) and 6, 7, 12 ($9504)


func _xA32F() -> void:
	if g(0x31) == 0x60:
		p(0x39, 0x60)
		p(0x3D, 0x10)
		p(0x38, 0)
		p(0x3C, 0)
	_xAAA9()


## $A344 -- the long drop: while he is still above it the view is walked up a
## sixteenth of a screen a picture and the floor is held close under him.
func _xA344() -> void:
	if g(0x83) >= 0x18:
		p(0x3F, 0x31)
		_xAAA9()
		return
	if g(0x33) >= 0x10:
		cf = 1
		p(0x32, _sbc(g(0x32), 0x10))
		if cf == 0:
			p(0x33, (g(0x33) - 1) & 0xFF)
	p(0x3F, 0x1F)
	p(0x3B, 0xA0 if g(0x81) >= 0x67 else 0x70)
	_xAAA9()


func _xA373() -> void:
	if g(0x31) == 0x90:
		p(0x39, 0x90)
		p(0x3F, 0x41)
		p(0x38, 0)
		p(0x3E, 0)
	_xAAA9()


func _xA388() -> void:
	if g(0x83) < 0x39:
		if g(0x81) >= 0x98:
			_xAAA9()
			return
		p(0x3D, 0x10)
		p(0x3B, 0xA0)
	else:
		if g(0x81) < 0x98:
			_xAAA9()
			return
		p(0x44, 0x70)
		p(0x3D, 0x31)
		p(0x3B, 0xB0)
	_xAAA9()


## $A3AF -- the end of the fifth stage.
func _xA3AF() -> void:
	if g(0x05C5) != 0 and g(0x81) >= 0xAF:
		p(0x02, 0x35)
		p(0x26, 0x03)
		p(0x27, 0xCF)
		p(0x55, 0x05)
	_xAAA9()


## $A7B0 -- his breath under water, and the bubbles it leaves.  $58 is how much
## of it is left: out of the water it comes back two a picture and in it, once
## he has been under long enough, it goes down one and a bubble is let out of
## the $0780 pool every fourth picture.
func _xA7B0() -> void:
	var v: int = g(0x05CA) & 0x78
	_cmp(v, 0x60)
	var wet := false
	if cf != 0:
		if (v & 0x18) != 0:
			_cmp(v & 0x18, 0x10)
			if cf == 0:
				wet = true
	if not wet:
		var t: int = _adc(g(0x58), 0x02)                   # $A7C1
		p(0x58, 0xFF if cf != 0 else t)
		_xAAA9()
		return
	if g(0x05A3) >= 0x1F:                                  # $A7CE
		var was: int = g(0x58)
		if was == 0:
			_xAAA9()
			return
		p(0x58, (was - 1) & 0xFF)
		if was < 0xC0:
			_xAAA9()
			return
	if (g(0x0C) & 0x03) != 0 or g(0x05A2) >= 0x11:         # $A7DF, $A7E5
		_xAAA9()
		return
	var y := 0x0F
	while y >= 0 and g(0x0780 + y) != 0:
		y -= 1
	if y < 0:
		_xAAA9()
		return
	p(0x0780 + y, 0x03)
	p(0x07F0 + y, 0x03)
	p(0x07E0 + y, 0xE0)
	cf = 0
	p(0x90, _sbc(g(0x80), 0x80))
	p(0x91, _sbc(g(0x81), 0x00))
	p(0x07B0 + y, g(0x82))
	cf = 0
	p(0x07C0 + y, _adc(g(0x83), 0x01))
	cf = 0
	p(0x0790 + y, _adc(((g(0x0C) & 0x0C) << 4) & 0xFF, g(0x90)))
	p(0x07A0 + y, _adc(g(0x91), 0x00))
	_xAAA9()


## $AA6E -- the last room of the fifth stage, two steps.
func _xAA6E() -> void:
	_second("AA7F", 0x7F)


func _xAA83() -> void:
	if g(0x05A2) == 0:
		p(0x9D, 0x0F)
		_clear_at()
		p(0x91, 0xC8)
		p(0x93, 0x5E)
		_put(0x00, 0x41)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAAAE()


func _xAAA3() -> void:
	_x9355()
	_xA7B0()


## $A74F -- the boss room of the eighteenth stage, four steps.
func _xA74F() -> void:
	_second("A760", 0x7F)


func _xA774() -> void:
	if g(0x05C5) != 0:
		var col: int = _adc(_hero_col(), 0x00)             # $A77C
		if col == 0x85 and g(0x83) == 0x68 and g(0x05A2) == 0 \
				and _xAB6A() != 0:
			p(0xF0, 0x0F)
			p(0xF1, 0x05)
			p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xA7B0()


func _xA768() -> void:
	_xABE2()
	_xA7B0()


func _xA76E() -> void:
	_xAC96()
	_xA7B0()


func _xA79F() -> void:
	_hold_hero()
	if g(0x26) == 0:
		_xACB1(0)
		p(0x55, 0x11)
	_xA7B0()


## $A3CD -- the end of the seventh stage.
func _xA3CD() -> void:
	if g(0x05C5) != 0 and g(0x81) >= 0xCE:
		p(0x02, 0x35)
		p(0x26, 0x03)
		p(0x27, 0xCF)
		p(0x55, 0x07)
	_xAE58()


func _xA3EB() -> void:
	var y := 0x30
	var a := 0x71
	_cmp(g(0x83), 0x48)
	if cf == 0:
		_cmp(g(0x81), 0x28)
		if cf != 0:
			p(0x57, 0)
			y = 0x40
			a = 0x51
	p(0x3F, a)
	p(0x3B, y)
	_xAAAE()


func _xA40A() -> void:
	if g(0x83) == 0x5A:
		_xA58D()
		return
	if g(0x31) == 0x30:
		p(0x39, 0x30)
		p(0x3B, 0x40)
		p(0x3F, 0x70)
	_xA616()


## $A426, $A598, $A5D7, $A616 and $A63C -- the five rooms of the boss of the
## seventh stage, each one a script of its own and each refusing to run once
## $57 has counted past it.
func _xA426() -> void:
	if g(0x57) >= 0x01:
		_xA58A()
		return
	_second("A440", 0x7F)


func _xA598() -> void:
	_cmp(g(0x31), 0x60)
	if cf != 0:
		p(0x39, g(0x31))
		p(0x3F, 0x60)
	if g(0x57) >= 0x02:
		_xA58A()
		return
	_second("A5BE", 0x7F)


func _xA5D7() -> void:
	if g(0x33) == 0x49:
		_xA58D()
		return
	if g(0x83) >= 0x58 and g(0x81) < 0x68:
		p(0x3D, 0x50)
	if g(0x57) >= 0x03:
		_xA58A()
		return
	_second("A60A", 0x7F)


func _xA616() -> void:
	if g(0x57) >= 0x04:
		_xA58A()
		return
	_second("A630", 0x7F)


func _xA63C() -> void:
	if g(0x57) >= 0x05:
		_xA58A()
		return
	_second("A656", 0x7F)


## $A456 -- step one of each of the five: once he stands in the right column
## the boss is let in and the screen is asked to be paid off.
func _xA456(a: int) -> void:
	if a == g(0x81):
		var x: int = _free()
		if x >= 0:
			p(0x26, 0x03)
			p(0x27, 0x04)
			p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAAAE()


func _xA44C() -> void:
	p(0x91, 0x3C)
	p(0x93, 0x48)
	_xA456(0x3E)


func _xA5CA() -> void:
	p(0x91, 0x60)
	p(0x93, 0x44)
	_xA456(0x62)


func _xA662() -> void:
	p(0x91, 0x63)
	p(0x93, 0x58)
	_xA456(0x61)


func _xA66F() -> void:
	p(0x91, 0x3F)
	p(0x93, 0x54)
	_xA456(0x3D)


func _xA6E7() -> void:
	p(0x3B, 0x90)
	p(0x91, 0x3C)
	p(0x93, 0x68)
	_xA456(0x3E)


## $A4B5 -- step two: nothing but holding him still while the screen is paid.
func _xA4B5() -> void:
	_hold_hero()
	_xAAAE()


## $A4BB -- step three: the view is walked a sixteenth of a screen a picture
## until the boss's column is under him.
func _xA4BB() -> void:
	_hold_hero()
	if g(0x26) != 0:
		_xAAAE()
		return
	cf = 0
	var want: int = _adc(g(0x31), 0x08)
	if want == g(0x81):
		p(0x7F, (g(0x7F) + 1) & 0xFF)
		_xAAAE()
		return
	_cmp(want, g(0x81))
	if cf == 0:
		cf = 0
		p(0x30, _adc(g(0x30), 0x10))
		if cf != 0:
			p(0x31, (g(0x31) + 1) & 0xFF)
	else:
		cf = 1
		p(0x30, _sbc(g(0x30), 0x10))
		if cf == 0:
			p(0x31, (g(0x31) - 1) & 0xFF)
	_xAAAE()


## $A551 -- step four: the boss proper is put in, its tune asked for, and the
## meter turned over.
func _xA551() -> void:
	_hold_hero()
	var x: int = _free()
	if x < 0:
		_xAAAE()
		return
	p(0x0650 + x, 0x97)
	p(0x26, 0x06)
	p(0x27, 0x04)
	p(0x7F, (g(0x7F) + 1) & 0xFF)
	p(0x05AC, (g(0x05AC) + 1) & 0xFF)
	p(0x05CB, _a737(g(0x05CB) ^ 0x80))
	_a722()
	_xAAAE()


func _xA4EE() -> void:
	p(0x91, 0x63)
	p(0x93, 0x47)
	p(0x3B, 0x70)
	_tune(0x60, 0x81)
	_xA551()


func _xA500() -> void:
	p(0x91, 0x3F)
	p(0x93, 0x4B)
	p(0x3B, 0x70)
	_tune(0x80, 0x81)
	_xA551()


func _xA512() -> void:
	p(0x39, 0x2C)
	p(0x91, 0x60)
	p(0x93, 0x5B)
	_tune(0x80, 0x81)
	_xA551()


func _xA524() -> void:
	p(0x39, 0x20)
	p(0x91, 0x3C)
	p(0x93, 0x57)
	_tune(0x60, 0x81)
	_xA551()


func _xA536() -> void:
	p(0x91, 0x3F)
	p(0x93, 0x6B)
	p(0x3D, 0x60)
	p(0x3B, 0x90)
	_tune(0xA0, 0x81)
	p(0x05CB, g(0x05CB) ^ 0x80)
	_xA551()


## $A57C -- step five: the room is done with, and the next of the five may run.
func _xA57C() -> void:
	_hold_hero()
	if g(0x26) == 0:
		p(0x57, (g(0x57) + 1) & 0xFF)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAAAE()


func _xA58A() -> void:
	_xAAAE()


## $A58D -- the two pieces of background the room's own door is drawn from.
func _xA58D() -> void:
	p(0x0549, 0xFF)
	p(0x054A, 0xFF)
	_xAAAE()


## $A67C -- the last room of the seventh stage, four steps.
func _xA67C() -> void:
	_second("A68D", 0x7F)


func _xA6A1() -> void:
	if g(0x05C5) != 0 and _hero_col() == 0x8D and g(0x83) == 0x6A \
			and g(0x05A2) == 0 and _xAB6A() != 0:
		p(0xF0, 0x0F)
		p(0xF1, 0x05)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xA6FB()


func _xA695() -> void:
	_xABE2()
	_xA6FB()


func _xA69B() -> void:
	_xAC96()
	_xA6FB()


func _xA6CA() -> void:
	_hold_hero()
	if g(0x26) == 0:
		_xACB1(0)
		p(0x55, 0x0C)
		p(0x75, 0xE0)
		p(0x72, 0x02)
		p(0x73, 0x02)
		p(0x74, 0x02)
	_xA6FB()


func _xA6F8() -> void:
	_xA58D()
	_xA6FB()


## $A6FB -- and the room is marked beaten every picture it is stood in.
func _xA6FB() -> void:
	_beaten()
	_xAAAE()


## $ACEC -- the twelfth stage's own last room, two steps.
func _xACEC() -> void:
	_second("ACFD", 0x7F)


func _xAD01() -> void:
	if g(0x05A2) != 0:
		_xAAAE()
		return
	_c05a()                                                # $AD06
	p(0x73, 0x01)
	p(0x77, 0x00)
	p(0x75, 0x40)
	p(0x0200, 0xBD)
	p(0x0203, 0xE0)
	p(0x0201, 0x81)
	p(0x0202, 0x21)
	p(0x9D, 0x09)
	_clear_at()
	p(0x91, 0xB8)
	p(0x93, 0x5E)
	_put(0x00, 0x41)
	p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAAAE()


func _xAD44() -> void:
	if g(0x05FA) == 0:
		if g(0x05C8) != 0:
			p(0x03A2, int(data["wait_pic"][(g(0x0C) >> 1) & 0x03]))
		else:
			p(0x03A2, 0x28)
	if g(0x0399) == 0x05:
		_beaten()
	_xADC9()


# --------------------------- stages 15, 16 and 19 ($9432): the tower and the end


## $99A5 -- everything in the pool that stands above the view is told to go.
func _99a5() -> void:
	for x in range(0x0B, -1, -1):
		if g(0x0600 + x) == 0:
			continue
		if g(0x00D0 + x) >= g(0x33):
			continue
		p(0x0650 + x, g(0x0650 + x) | 0x80)


## $9D6E -- three pieces of the tower's own background are turned on.
func _9d6e() -> void:
	p(0x38, 0)
	p(0x3E, 0)
	p(0x054E, g(0x054E) | 0x39)
	p(0x054F, g(0x054F) | 0x80)


func _x99BE() -> void:
	_xAE58()


func _x992F() -> void:
	if g(0x31) == 0x60:
		p(0x39, 0x60)
		p(0x3F, 0x80)
		p(0x38, 0)
		p(0x3E, 0)
	_xAE58()


func _x9944() -> void:
	if g(0x45) != 0x73 and g(0x33) == 0x60:
		_99a5()
		p(0x45, 0x73)
	_xAE58()


func _x995A() -> void:
	if g(0x33) == 0x70:
		p(0x3D, 0x70)
		p(0x39, 0x30)
		p(0x38, 0)
		p(0x3E, 0)
	_xAE58()


func _x996F() -> void:
	if (g(0x30) & 0xC0) == 0 and g(0x31) == 0x10:
		p(0x3B, 0x20)
		p(0x3F, 0xA0)
		p(0x38, 0)
		p(0x3E, 0)
	_xAE58()


func _x998C() -> void:
	if g(0x33) == 0x90 and g(0x33) != g(0x3D):
		p(0x3D, 0x90)
		p(0x3B, 0x60)
		_9d6e()
		_99a5()
	_xAE58()


## $99C1 -- the first of the three rooms at the top of the tower, nine steps.
func _x99C1() -> void:
	_second("99D2", 0x7F)


func _x9A17() -> void:
	if g(0x39) != 0x10 and (g(0x30) & 0xC0) == 0 and g(0x31) == 0x30:
		p(0x3B, 0x40)
		p(0x38, 0)
		_wipe_pool()
		_wipe_shots()
		p(0x91, 0x3F)
		p(0x93, 0x76)
		var x: int = _free()
		if x >= 0:
			p(0x0640 + x, 0x06)
			p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


func _x9A0A() -> void:
	_xAE58()


func _x99E4() -> void:
	p(0x9D, 0x08)
	_clear_at()
	p(0x91, 0x3C)
	p(0x93, 0x70)
	_put(0x00, 0x41)
	p(0x44, 0x75)
	_tune(0x80, 0x84)                                      # $C066
	_owe(0x06, 0xFF)
	p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


func _x9A0D() -> void:
	if g(0x0600) == 0:
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAAAE()


func _x9A4E() -> void:
	p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


func _x9A53() -> void:
	_tune(0xE0, 0x83)                                      # $C06F
	_owe(0x06, 0xFF)
	p(0x91, 0x30)
	p(0x93, 0x7B)
	var x: int = _free()
	if x >= 0:
		p(0x0650 + x, 0xAE)
		p(0x0640 + x, 0x06)
		p(0x39, 0x10)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


## $9A7D -- the view is walked back to the left until he is within seven
## columns of its edge.
func _x9A7D() -> void:
	cf = 1
	var d: int = _sbc(g(0x81), g(0x31))
	if cf == 0:
		_x9A9A()
		return
	_cmp(d, 0x07)
	if cf != 0:
		p(0x44, 0x70)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
		_x9A9A()
		return
	p(0x30, _sbc(g(0x30), 0x3F))
	if cf == 0:
		p(0x31, (g(0x31) - 1) & 0xFF)
	_x9A9A()


func _x9A9A() -> void:
	_hold_hero()
	_xAE58()


func _x9A9D() -> void:
	_xAE58()


## $9AA0 -- the second room at the top, eight steps.
func _x9AA0() -> void:
	_second("9AB1", 0x7F)


func _x9AC1() -> void:
	cf = 1
	var d: int = _sbc(g(0x81), g(0x31))
	if cf == 0:
		_x9ADE()
		return
	_cmp(d, 0x09)
	if cf == 0:
		p(0x44, 0x70)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
		_x9ADE()
		return
	p(0x30, _adc(g(0x30), 0x3F))
	if cf != 0:
		p(0x31, (g(0x31) + 1) & 0xFF)
	_x9ADE()


func _x9ADE() -> void:
	_hold_hero()
	_x9B1D()


func _x9AE4() -> void:
	if g(0x3B) == 0x90:
		_x9B1D()
		return
	if g(0x31) == 0x50:
		p(0x39, 0x50)
		p(0x38, 0)
		_wipe_pool()
		_wipe_shots()
		p(0x91, 0x50)
		p(0x93, 0x96)
		var x: int = _free()
		if x >= 0:
			p(0x0640 + x, 0x06)
			_tune(0xA0, 0x84)                              # $C069
			_owe(0x06, 0xFF)
			p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


func _x9B1A() -> void:
	_xAE58()


func _x9B1D() -> void:
	_9bc8()
	p(0x3B, 0x90)
	_xAE58()


func _x9B27() -> void:
	p(0x75, 0xBD)
	p(0x9D, 0x10)
	_clear_at()
	p(0x91, 0x58)
	p(0x93, 0x90)
	_put(0x00, 0x41)
	p(0x0680, g(0x0680) ^ 0xFF)
	p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


func _x9B4E() -> void:
	if g(0x0600) == 0:
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


func _x9B58() -> void:
	p(0x7F, (g(0x7F) + 1) & 0xFF)
	_tune(0x00, 0x84)                                      # $C060
	_owe(0x06, 0xFF)
	_xAE58()


func _x9B67() -> void:
	_wipe_pool()
	_wipe_shots()
	p(0x91, 0x5F)
	p(0x93, 0x9B)
	var x: int = _free()
	if x >= 0:
		p(0x0650 + x, 0x97)
		p(0x0640 + x, 0x06)
		p(0x09, g(0x09) | 0x20)
		_tune(0x00, 0x84)                                  # $C060
		_owe(0x06, 0xFF)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


## $9B99 -- the sixteenth stage is left behind and the seventeenth named.
func _x9B99() -> void:
	if g(0x31) == 0xB0 and g(0x39) != 0xB0:
		p(0x39, 0xB0)
		p(0x38, 0)
		p(0x55, 0x10)
		_c05d()                                            # $9BAD
		p(0x40, 0x3C)
		p(0x054D, 0xFF)
		p(0x054E, 0xFF)
		p(0x054F, 0xFF)
		p(0x0546, 0xFF)
	_xAE58()


func _x9BC5() -> void:
	_xAE58()
	_9bc8()


## $9BE8 -- the third room at the top, eight steps.
func _x9BE8() -> void:
	_second("9BF9", 0x7F)


func _x9C09() -> void:
	cf = 1
	var d: int = _sbc(g(0x81), g(0x31))
	if cf == 0:
		_x9C22()
		return
	_cmp(d, 0x09)
	if cf == 0:
		p(0x7F, (g(0x7F) + 1) & 0xFF)
		_x9C22()
		return
	p(0x30, _adc(g(0x30), 0x3F))
	if cf != 0:
		p(0x31, (g(0x31) + 1) & 0xFF)
	_x9C22()


func _x9C22() -> void:
	_hold_hero()
	_x9C6C()


func _x9C28() -> void:
	if g(0x3B) == 0xD0:
		_x9C6C()
		return
	_beaten()                                              # $9CAA
	p(0x45, 0x60)
	p(0x44, 0x6B)
	if g(0x31) == 0xA0:
		p(0x39, 0xA0)
		p(0x38, 0)
		_wipe_pool()
		_wipe_shots()
		p(0x91, 0xA0)
		p(0x93, 0x66)
		var x: int = _free()
		if x >= 0:
			p(0x0640 + x, 0x06)
			_tune(0xC0, 0x84)                              # $C06C
			_owe(0x06, 0xFF)
			p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


func _x9C69() -> void:
	_xAE58()


func _x9C6C() -> void:
	p(0x3B, 0xD0)
	_xAE58()


func _x9C73() -> void:
	_beaten()                                              # $9CAA
	_c05a()                                                # $9C76
	p(0x0399, 0x05)
	p(0x9D, 0x09)
	_clear_at()
	p(0x91, 0xA8)
	p(0x93, 0x5E)
	_put(0x00, 0x41)
	p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


func _x9C99() -> void:
	if g(0x0399) == 0x05:
		_beaten()                                          # $9CAA
	p(0x7D, 0)
	_x9A0D()


func _x9CCE() -> void:
	p(0x7F, (g(0x7F) + 1) & 0xFF)
	_tune(0x20, 0x84)                                      # $C063
	_owe(0x06, 0xFF)
	p(0x05CB, g(0x05CB) & 0x7F)
	_xAE58()


func _x9CE5() -> void:
	_wipe_pool()
	_wipe_shots()
	p(0x91, 0xAF)
	p(0x93, 0x6B)
	var x: int = _free()
	if x >= 0:
		p(0x0650 + x, 0x97)
		p(0x0640 + x, 0x06)
		p(0x09, g(0x09) & 0xDF)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
		p(0x55, 0x10)
		for i in range(0x40):
			p(0x0560 + i, 0x01)
		p(0x44, 0x70)
		p(0x45, 0x7A)
	_xAE58()


func _x9D23() -> void:
	_9bc8()
	if g(0x31) == 0x80 and g(0x39) != 0x80:
		p(0x39, 0x80)
		p(0x3D, 0x60)
		p(0x38, 0)
		p(0x3E, 0)
		p(0x44, 0x70)
	_xAE58()


## $9D43 -- the ledge the tower's own door sits on: the view is pulled a row
## lower and the door's background turned on once he has walked past it.
func _x9D43() -> void:
	_9bc8()
	var y := 0x90
	var a := 0xA0
	var out := false
	_cmp(g(0x83), 0x67)
	if g(0x83) == 0x67:
		_cmp(g(0x82), 0x80)
		if cf != 0:
			out = true
	elif cf != 0:
		out = true
	if not out:
		_cmp(g(0x81), 0x87)
		if cf != 0:
			_9d6e()
			y = 0xB0
			a = 0x70
	p(0x3F, a)
	p(0x3B, y)
	_xAE58()


func _x9D85() -> void:
	if g(0x31) == 0xC0:
		p(0x39, 0xC0)
		p(0x3D, 0x10)
		p(0x38, 0)
		p(0x3C, 0)
	_xAE58()


## $9D9A -- the boss room of the nineteenth stage, four steps.
func _x9D9A() -> void:
	_second("9DAB", 0x7F)


func _x9DB3() -> void:
	_xABE2()
	_xAE58()


func _x9DB9() -> void:
	_xAC96()
	_xAE58()


func _x9DBF() -> void:
	if g(0x05C5) != 0 and _hero_col() == 0xCB and g(0x83) == 0x16 \
			and g(0x05A2) == 0 and _xAB6A() != 0:
		p(0xF0, 0x0F)
		p(0xF1, 0x05)
		p(0x7F, (g(0x7F) + 1) & 0xFF)
	_xAE58()


func _x9DE8() -> void:
	_hold_hero()
	if g(0x26) == 0:
		_xACB1(0)
		p(0x55, 0x13)
	_xAE58()


## $9DF9 -- the ending, twenty-one steps, and the step is $58, not $7F.
func _x9DF9() -> void:
	_second("9E0A", 0x58)


# ------------------------------------ the ending, twenty-one steps kept in $58


## $9E7D -- the tail of holding him still: the buttons alone, without the wait.
func _9e7d() -> void:
	p(0x06, 0)
	p(0x04, 0)


## $A008 -- while the ending runs the lamp is knocked every eighth picture and
## the light over the scene is walked through four shades.
func _a008() -> void:
	if (g(0x0E) & 0x03) != 0:
		return
	if (g(0x0E) & 0x07) == 0:
		p(0xF1, 0x3C)
	cf = 0
	p(0x05F7, _adc((g(0x0E) >> 3) & 0x03, 0x04))


## $A026 -- what the last few steps all do first: he is held, the numbers the
## ending leans on are written, and he is lifted if he has fallen too low.
func _a026() -> void:
	_hold_hero()
	p(0x06, 0x80)
	p(0x04, 0x80)
	p(0x05EA, 0x0C)
	p(0x05AD, 0x40)
	p(0x05AE, 0xFF)
	p(0x05C9, 0x80)
	p(0x05A2, 0x01)
	p(0x05AC, 0x01)
	_cmp(g(0x83), 0x21)
	if cf != 0:
		return
	p(0x83, 0x10)
	p(0x05A3, 0x20)


func _xA05B() -> void:
	if g(0x05A2) == 0:
		p(0x9D, 0x11)
		_clear_at()
		p(0x91, 0x37)
		p(0x93, 0x2A)
		_put(0x00, 0x41)
		p(0x9D, 0x12)
		_clear_at()
		p(0x91, 0x37)
		p(0x93, 0x2A)
		_put(0x0B, 0x41)
		p(0x58, (g(0x58) + 1) & 0xFF)
	_xAE58()


func _xA091() -> void:
	if g(0x81) >= 0x2C:
		p(0x58, (g(0x58) + 1) & 0xFF)
	else:
		p(0x04, 0)
		p(0x06, 0x01)
	_xAE58()


func _xA0A6() -> void:
	_9e7d()
	cf = 0
	p(0x30, _adc(g(0x30), 0x10))
	if cf != 0:
		p(0x31, (g(0x31) + 1) & 0xFF)
	if g(0x31) == 0x2A:
		p(0x58, (g(0x58) + 1) & 0xFF)
	_xAE58()


func _xA0BF() -> void:
	if (g(0x0650) & 0x3F) != 0x2F:
		p(0x58, (g(0x58) + 1) & 0xFF)
	_9e7d()
	_xAE58()


func _xA0D0() -> void:
	# $A0D3 -- the BPL skips the step on, so it is taken when the thing is
	# still minding itself; the step is only made once it has been told to go.
	if g(0x0650) >= 0x80:
		p(0x58, (g(0x58) + 1) & 0xFF)
	_xAE58()


func _x9E84() -> void:
	p(0xF8, 0xFF)
	p(0x57, 0x70)
	p(0x58, (g(0x58) + 1) & 0xFF)
	p(0x0690, 0x0F)
	_gap_to_hero()
	_hold_hero()
	_xAE58()


func _x9E9C() -> void:
	if g(0x0690) >= 0x11:
		p(0x57, (g(0x57) - 1) & 0xFF)
		if g(0x57) == 0:
			p(0x58, (g(0x58) + 1) & 0xFF)
			p(0x0690, (g(0x0690) + 1) & 0xFF)
	_gap_to_hero()
	_hold_hero()
	_xAE58()


## $9EB5 -- the two of them walk towards one another until they stand less than
## a screen and a half apart.
func _x9EB5() -> void:
	_hold_hero()
	_gap_to_hero()
	p(0x06, 0x02 if g(0x05B2) >= 0x80 else 0x01)
	if g(0x91) < 0x02 and g(0x90) < 0x80:
		p(0x58, (g(0x58) + 1) & 0xFF)
		p(0x0690, (g(0x0690) + 1) & 0xFF)
		p(0x57, 0x10)
		p(0x04, 0x40)
	_xAE58()


func _x9EE1() -> void:
	_hold_hero()
	p(0x57, (g(0x57) - 1) & 0xFF)
	if g(0x57) == 0:
		p(0x58, (g(0x58) + 1) & 0xFF)
		p(0x57, 0x10)
		p(0x04, 0x40)
	_gap_to_hero()
	_xAE58()


func _x9EF8() -> void:
	_hold_hero()
	p(0x57, (g(0x57) - 1) & 0xFF)
	if g(0x57) == 0:
		p(0x58, (g(0x58) + 1) & 0xFF)
		p(0x57, 0x10)
		p(0x04, 0x40)
		p(0x05CE, 0x02)
	_gap_to_hero()
	_xAE58()


func _x9F14() -> void:
	_hold_hero()
	p(0x57, (g(0x57) - 1) & 0xFF)
	if g(0x57) == 0:
		p(0x58, (g(0x58) + 1) & 0xFF)
	_gap_to_hero()
	_xAE58()


func _x9F23() -> void:
	p(0x0690, 0x14)
	p(0x58, (g(0x58) + 1) & 0xFF)
	_gap_to_hero()
	_hold_hero()
	_xAE58()


func _x9F33() -> void:
	cf = 1
	var d: int = _sbc(g(0x00D0), g(0x33))
	_cmp(d, 0x10)
	if cf != 0:
		p(0x57, 0)
		p(0x58, (g(0x58) + 1) & 0xFF)
		p(0x0690, (g(0x0690) + 1) & 0xFF)
	_gap_to_hero()
	_hold_hero()
	_xAE58()


func _x9F4E() -> void:
	p(0x57, (g(0x57) - 1) & 0xFF)
	if g(0x57) == 0:
		p(0x57, 0)
		p(0x0690, (g(0x0690) + 1) & 0xFF)
		p(0x58, (g(0x58) + 1) & 0xFF)
	_gap_to_hero()
	_hold_hero()
	_xAE58()


func _x9F64() -> void:
	p(0x57, (g(0x57) - 1) & 0xFF)
	if g(0x57) == 0:
		p(0x57, 0xC0)
		p(0x58, (g(0x58) + 1) & 0xFF)
	_hold_hero()
	_xAE58()


func _x9F74() -> void:
	if (g(0x0C) & 0x01) == 0:
		p(0x57, (g(0x57) - 1) & 0xFF)
		if g(0x57) == 0:
			p(0x57, 0)
			p(0x0690, (g(0x0690) + 1) & 0xFF)
			p(0x58, (g(0x58) + 1) & 0xFF)
	if (g(0x0C) & 0xA0) == 0:
		_a008()
	_hold_hero()
	_xAE58()


func _x9F95() -> void:
	if (g(0x0C) & 0x01) != 0:
		p(0x57, (g(0x57) - 1) & 0xFF)
		if g(0x57) == 0:
			p(0x57, 0x18)
			p(0x58, (g(0x58) + 1) & 0xFF)
	_a008()
	_hold_hero()
	_xAE58()


func _x9FAD() -> void:
	_hold_hero()
	p(0x06, 0x04)
	p(0x57, (g(0x57) - 1) & 0xFF)
	if g(0x57) == 0:
		p(0xF1, 0x3D)
		p(0x58, (g(0x58) + 1) & 0xFF)
	_a008()
	_xAE58()


func _x9FC4() -> void:
	_a026()
	if cf == 0:
		p(0x57, 0x20)
		p(0x58, (g(0x58) + 1) & 0xFF)
	_a008()
	_xAE58()


func _x9FD5() -> void:
	_a026()
	p(0x57, (g(0x57) - 1) & 0xFF)
	if g(0x57) == 0:
		p(0x28, 0x1E)
		p(0x25, 0x1E)
		_owe(0x01, 0xFF)
		p(0x58, (g(0x58) + 1) & 0xFF)
	_a008()
	_hold_hero()
	_xAE58()


func _x9FF4() -> void:
	if g(0x26) == 0:
		p(0x02, 0x4C)
	_a026()
	_a008()
	_hold_hero()
	_xAE58()


## Every routine the three layers of table can land on -- $93B5's own
## `JMP ($0090)`, and the second level's.  The address is left in $90:$91 the
## way the cartridge leaves it, because the jump is made through those two.
func _call(addr: int) -> void:
	p(0x90, addr & 0xFF)
	p(0x91, addr >> 8)
	trail.append(addr)
	match addr:
		0x992F: _x992F()
		0x9944: _x9944()
		0x995A: _x995A()
		0x996F: _x996F()
		0x998C: _x998C()
		0x99BE: _x99BE()
		0x99C1: _x99C1()
		0x99E4: _x99E4()
		0x9A0A: _x9A0A()
		0x9A0D: _x9A0D()
		0x9A17: _x9A17()
		0x9A4E: _x9A4E()
		0x9A53: _x9A53()
		0x9A7D: _x9A7D()
		0x9A9A: _x9A9A()
		0x9A9D: _x9A9D()
		0x9AA0: _x9AA0()
		0x9AC1: _x9AC1()
		0x9AE4: _x9AE4()
		0x9B1A: _x9B1A()
		0x9B1D: _x9B1D()
		0x9B27: _x9B27()
		0x9B4E: _x9B4E()
		0x9B58: _x9B58()
		0x9B67: _x9B67()
		0x9B99: _x9B99()
		0x9BC5: _x9BC5()
		0x9BE8: _x9BE8()
		0x9C09: _x9C09()
		0x9C28: _x9C28()
		0x9C69: _x9C69()
		0x9C6C: _x9C6C()
		0x9C73: _x9C73()
		0x9C99: _x9C99()
		0x9CCE: _x9CCE()
		0x9CE5: _x9CE5()
		0x9D23: _x9D23()
		0x9D43: _x9D43()
		0x9D85: _x9D85()
		0x9D9A: _x9D9A()
		0x9DB3: _x9DB3()
		0x9DB9: _x9DB9()
		0x9DBF: _x9DBF()
		0x9DE8: _x9DE8()
		0x9DF9: _x9DF9()
		0x9E84: _x9E84()
		0x9E9C: _x9E9C()
		0x9EB5: _x9EB5()
		0x9EE1: _x9EE1()
		0x9EF8: _x9EF8()
		0x9F14: _x9F14()
		0x9F23: _x9F23()
		0x9F33: _x9F33()
		0x9F4E: _x9F4E()
		0x9F64: _x9F64()
		0x9F74: _x9F74()
		0x9F95: _x9F95()
		0x9FAD: _x9FAD()
		0x9FC4: _x9FC4()
		0x9FD5: _x9FD5()
		0x9FF4: _x9FF4()
		0xA05B: _xA05B()
		0xA091: _xA091()
		0xA0A6: _xA0A6()
		0xA0BF: _xA0BF()
		0xA0D0: _xA0D0()
		0xA0DA: _xA0DA()
		0xA0EF: _xA0EF()
		0xA0FC: _xA0FC()
		0xA109: _xA109()
		0xA11E: _xA11E()
		0xA13F: _xA13F()
		0xA15E: _xA15E()
		0xA169: _xA169()
		0xA1A8: _xA1A8()
		0xA1B8: _xA1B8()
		0xA1DB: _xA1DB()
		0xA21A: _xA21A()
		0xA237: _xA237()
		0xA252: _xA252()
		0xA26F: _xA26F()
		0xA288: _xA288()
		0xA28E: _xA28E()
		0xA294: _xA294()
		0xA2BD: _xA2BD()
		0xA2CE: _xA2CE()
		0xA2E7: _xA2E7()
		0xA2F7: _xA2F7()
		0xA30E: _xA30E()
		0xA329: _xA329()
		0xA32F: _xA32F()
		0xA344: _xA344()
		0xA373: _xA373()
		0xA388: _xA388()
		0xA3AF: _xA3AF()
		0xA3CD: _xA3CD()
		0xA3EB: _xA3EB()
		0xA40A: _xA40A()
		0xA426: _xA426()
		0xA44C: _xA44C()
		0xA4B5: _xA4B5()
		0xA4BB: _xA4BB()
		0xA4EE: _xA4EE()
		0xA500: _xA500()
		0xA512: _xA512()
		0xA524: _xA524()
		0xA536: _xA536()
		0xA57C: _xA57C()
		0xA58A: _xA58A()
		0xA58D: _xA58D()
		0xA598: _xA598()
		0xA5CA: _xA5CA()
		0xA5D7: _xA5D7()
		0xA616: _xA616()
		0xA63C: _xA63C()
		0xA662: _xA662()
		0xA66F: _xA66F()
		0xA67C: _xA67C()
		0xA695: _xA695()
		0xA69B: _xA69B()
		0xA6A1: _xA6A1()
		0xA6CA: _xA6CA()
		0xA6E7: _xA6E7()
		0xA6F8: _xA6F8()
		0xA6FB: _xA6FB()
		0xA74F: _xA74F()
		0xA768: _xA768()
		0xA76E: _xA76E()
		0xA774: _xA774()
		0xA79F: _xA79F()
		0xA7B0: _xA7B0()
		0xA835: _xA835()
		0xA867: _xA867()
		0xA87C: _xA87C()
		0xA89A: _xA89A()
		0xA8AF: _xA8AF()
		0xA8E5: _xA8E5()
		0xA8EB: _xA8EB()
		0xA94B: _xA94B()
		0xA967: _xA967()
		0xA980: _xA980()
		0xA986: _xA986()
		0xA98C: _xA98C()
		0xA9B5: _xA9B5()
		0xA9C6: _xA9C6()
		0xAA46: _xAA46()
		0xAA6E: _xAA6E()
		0xAA83: _xAA83()
		0xAAA3: _xAAA3()
		0xAAA9: _xAAA9()
		0xAAAE: _xAAAE()
		0xAABF: _xAABF()
		0xAAD4: _xAAD4()
		0xAAE9: _xAAE9()
		0xAAFE: _xAAFE()
		0xAB13: _xAB13()
		0xAB28: _xAB28()
		0xAB41: _xAB41()
		0xABE2: _xABE2()
		0xAC96: _xAC96()
		0xACCE: _xACCE()
		0xACEC: _xACEC()
		0xAD01: _xAD01()
		0xAD44: _xAD44()
		0xAD94: _xAD94()
		0xADA9: _xADA9()
		0xADC9: _xADC9()
		0xADCF: _xADCF()
		0xADE8: _xADE8()
		0xADEE: _xADEE()
		0xADF4: _xADF4()
		0xAE1D: _xAE1D()
		0xAE2E: _xAE2E()
		0xAE38: _xAE38()
		0xAE4D: _xAE4D()
		0xAE58: _xAE58()


## $F81E, reached as $C05A -- thirty two bytes of colour, from wherever $20:$21
## stands, into the shadow at $0390; and $20:$21 is left pointing at the shadow
## itself.  The colours are in bank ten, which $C92A maps and $C998 puts back;
## $C992 reads $8000 on the way, and inside the script that is the top byte of
## bank eight, so $46 is left holding that.
func _c05a() -> void:
	p(0x46, int(data["bank_top"]))
	var at: int = g(0x20) | g(0x21) << 8
	if at < 0x0800:
		# The pointer already stands in the shadow, which is where $F81E leaves
		# it; copying it onto itself changes nothing.
		for i in range(31, -1, -1):
			p(0x0390 + i, g(at + i))
	else:
		var key := "%04X" % at
		var pal: Dictionary = data["palettes"]
		if not pal.has(key):
			# No acceptance can be asked about a colour table the export has
			# never seen, so the picture is marked instead of guessed at.
			owed = true
			return
		var v: Array = pal[key]
		for i in range(31, -1, -1):
			p(0x0390 + i, int(v[i]))
	p(0x20, 0x90)
	p(0x21, 0x03)


## $E626, reached as $C05D -- the map record of the stage named in $55.  The
## stage picks a bank and a pointer, the byte the pointer stands at picks a
## record of twelve bytes, and those go into $10..$15, $1E, $1F and $16..$19.
## $7C is left holding the stage.
func _c05d() -> void:
	p(0x46, int(data["bank_top"]))
	var st: int = g(0x55)
	var areas: Array = data["areas"]
	if st >= areas.size():
		owed = true
		return
	var one: Dictionary = areas[st]
	var ptr: int = int(one["ptr"])
	p(0x90, ptr & 0xFF)
	p(0x91, ptr >> 8)
	var rec: Array = one["rec"]
	# $E647..$E681 -- the order is the record's, not the memory's: six bytes
	# into $10..$15, then two into $1E and $1F, then four into $16..$19.
	for i in range(6):
		p(0x10 + i, int(rec[i]))
	p(0x1E, int(rec[6]))
	p(0x1F, int(rec[7]))
	for i in range(4):
		p(0x16 + i, int(rec[8 + i]))
	p(0x7C, st)


## ---------------------------------------------------------------------------
## The live build.
##
## The script is written against the flat two kilobytes, and the engine keeps
## the same things in objects of its own.  These two walk between them: `pack`
## writes into the shadow what the engine owns, `unpack` reads back out what
## the script changed.  Everything the script touches that the engine has no
## home for -- the rows of background still owed, the tune stubs, the closing
## scene's own counters -- simply stays in the shadow from one picture to the
## next, which is exactly where the cartridge keeps it.


## One row is an address, which of the engine's things holds it, the name it
## goes by there, and how many bytes it takes.  Every row is walked both ways.
const LINKS := [
	[0x0002, "flow", "mode", 1],
	[0x0004, "pool", "pad_new", 1],
	[0x0006, "pool", "six", 1],
	[0x000C, "pool", "clock", 1],
	[0x000D, "flow", "z0d", 1],
	[0x000E, "pool", "noise", 1],
	[0x0026, "pool", "z26", 1],
	[0x0030, "view", "x", 2],
	[0x0032, "view", "y", 2],
	[0x0034, "view", "fall", 1],
	[0x0038, "view", "x_min", 2],
	[0x003A, "view", "x_end", 2],
	[0x003C, "view", "y_min", 2],
	[0x003E, "view", "y_end", 2],
	[0x0055, "pool", "stage", 1],
	[0x0057, "flow", "z57", 1],
	[0x0058, "pool", "z58", 1],
	[0x005B, "hero", "step_down", 1],
	[0x0070, "view", "map_kind", 1],
	[0x0075, "pool", "z75", 1],
	[0x007F, "pool", "z7f", 1],
	[0x0080, "hero", "x", 2],
	[0x0082, "hero", "y", 2],
	[0x0090, "pool", "z90", 2],
	[0x0092, "pool", "z92", 2],
	[0x009D, "pool", "z9d", 1],
	[0x00F0, "flow", "noise", 1],
	[0x00F8, "pool", "zf8", 1],
	[0x0399, "pool", "z399", 1],
	[0x05A2, "hero", "state", 1],
	[0x05A3, "hero", "timer", 1],
	[0x05A6, "hero", "pic_lo", 1],
	[0x05A7, "hero", "pic_hi", 1],
	[0x05AB, "hero", "burst", 1],
	[0x05AC, "hero", "hold", 1],
	[0x05AD, "hero", "rise", 2],
	[0x05B2, "hero", "face", 1],
	[0x05C2, "hero", "hurt", 1],
	[0x05C3, "view", "hold", 1],
	[0x05C5, "hero", "suit", 1],
	[0x05C8, "hero", "shield", 1],
	[0x05C9, "hero", "jump_flags", 1],
	[0x05CA, "hero", "seen", 1],
	[0x05CB, "hero", "flags", 1],
	[0x05CD, "hero", "ground", 1],
	[0x05CE, "hero", "anim", 1],
	[0x05E8, "hero", "jump", 1],
	[0x05E9, "hero", "gravity", 1],
	[0x05EA, "hero", "hold_max", 1],
	[0x05EB, "pool", "room", 1],
	[0x05F7, "pool", "wants", 1],
	[0x05FA, "pool", "z5fa", 1],
]

## The pool's own pages: an address, the name of the list, and whether the list
## is bytes or whole places kept as two.  Sixteen of each, one per slot.
const PAGES := [
	[0x0600, "id", 1], [0x0610, "a", 1], [0x0620, "b", 1], [0x0630, "c", 1],
	[0x0640, "d", 1], [0x0650, "mind", 1], [0x0660, "pic_lo", 1],
	[0x0670, "pic_hi", 1], [0x0680, "face", 1], [0x0690, "kind", 1],
	[0x06A0, "anim_a", 1], [0x06B0, "anim_b", 1], [0x06C0, "left", 1],
	[0x06D0, "frame", 1], [0x06E0, "cool", 1], [0x06F0, "life", 1],
	[0x0700, "w_kind", 1], [0x0750, "w_vx", 1], [0x0760, "w_vy", 1],
	[0x0770, "w_pen", 1], [0x0780, "s_kind", 1], [0x07D0, "s_a", 1],
	[0x07E0, "s_b", 1], [0x07F0, "s_life", 1],
]

## The places, which are two bytes a page apart: the low page, the name, and
## the high page follows it.
const PLACES := [
	[0x00A0, "x"], [0x00C0, "y"],
	[0x0710, "w_x"], [0x0730, "w_y"],
	[0x0790, "s_x"], [0x07B0, "s_y"],
]


func _who(pool, hero, view, flow) -> Dictionary:
	return {"pool": pool, "hero": hero, "view": view, "flow": flow}


## What the engine holds, into the shadow.
func pack(pool, hero, view, table, flow) -> void:
	var who := _who(pool, hero, view, flow)
	for r in LINKS:
		var o = who[r[1]]
		if o == null:
			continue
		var v: int = int(o.get(r[2]))
		p(r[0], v & 0xFF)
		if r[3] == 2:
			p(r[0] + 1, (v >> 8) & 0xFF)
	for r in PAGES:
		var list = pool.get(r[1])
		for s in range(list.size()):
			p(r[0] + s, int(list[s]) & 0xFF)
	for r in PLACES:
		var list = pool.get(r[1])
		for s in range(list.size()):
			var v: int = int(list[s])
			p(r[0] + s, v & 0xFF)
			p(r[0] + 0x10 + s, (v >> 8) & 0xFF)
	for s in range(pool.mark.size()):
		p(0x0560 + s, int(pool.mark[s]) & 0xFF)
	if table != null:
		for i in range(0x100):
			p(0x0200 + i, int(table.oam[i]))


## And back out again.
func unpack(pool, hero, view, table, flow) -> void:
	var who := _who(pool, hero, view, flow)
	for r in LINKS:
		var o = who[r[1]]
		if o == null:
			continue
		var v: int = g(r[0])
		if r[3] == 2:
			v |= g(r[0] + 1) << 8
		o.set(r[2], v)
	for r in PAGES:
		var list = pool.get(r[1])
		for s in range(list.size()):
			list[s] = g(r[0] + s)
	for r in PLACES:
		var list = pool.get(r[1])
		for s in range(list.size()):
			list[s] = g(r[0] + s) | g(r[0] + 0x10 + s) << 8
	for s in range(pool.mark.size()):
		pool.mark[s] = g(0x0560 + s)
	if table != null:
		for i in range(0x100):
			table.oam[i] = g(0x0200 + i)
	# The three that more than one thing holds a copy of.  $55 is the stage,
	# which the script writes when a stage is done; $05C3 the wait for a
	# satellite; $0C the picture count the hero reads as well as the pool.
	pool.stage = g(0x55)
	if flow != null:
		flow.stage = g(0x55)
	if hero != null:
		# $05AD:$05AE is a speed and so has a sign; the shadow keeps it as the
		# two bytes the cartridge does.
		hero.rise = _s16(g(0x05AD) | g(0x05AE) << 8)
		# $38:$39 and $3A:$3B are how far along the area may be walked, and both
		# the view and the hero read them.  Widening them is half of what a
		# script does, so his copy is put back in step with the view's.
		hero.x_min = g(0x38) | g(0x39) << 8
		hero.x_end = g(0x3A) | g(0x3B) << 8
		hero.stage = g(0x55)
		hero.clock = g(0x0C)
		hero.map_kind = g(0x70)
	pool.born_wait = g(0x05C3)
	pool.hero_x = g(0x80) | g(0x81) << 8
	pool.hero_y = g(0x82) | g(0x83) << 8
	pool.cam_x = g(0x30) | g(0x31) << 8
	pool.cam_y = g(0x32) | g(0x33) << 8
	pool.z34 = g(0x34)


## $CDB3 in one call: the shadow is filled, the script runs, and what it
## changed is put back.
func run(pool, hero, view, table, flow) -> void:
	cf = 0
	wild = false
	owed = false
	trail.clear()
	pack(pool, hero, view, table, flow)
	step()
	unpack(pool, hero, view, table, flow)


## Two bytes with a sign, which is how every speed is kept.
static func _s16(v: int) -> int:
	v &= 0xFFFF
	return v - 0x10000 if v >= 0x8000 else v
