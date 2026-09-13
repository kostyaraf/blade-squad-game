extends RefCounted
class_name SolEnd

## The end of the game: the bonus screen, the sun that comes up behind it, and
## the names the man walks in front of.
##
## `work/extract/sol_end.py` says where every one of these comes from and how
## the stream of names in bank six is read.  Nothing here decides anything:
## the modes of `sol_flow.gd` do, and this is only what they decide out of.

static var _d: Dictionary = {}


static func load_data() -> void:
	if not _d.is_empty():
		return
	_d = Nes._load_json(Nes.DATA + "/sol/end.json")


static func one(key: String) -> int:
	load_data()
	return int(_d[key])


## $E356 -- the four kilobytes both screens of the ending are drawn out of.
static func chr_pair() -> Array:
	load_data()
	return [int(_d["chr"][0]), int(_d["chr"][1])]


## $8AA4 and $8ABF -- one row of the sunrise: three colours into $0101..$0103
## and three into $0105..$0107.
static func sun(row: int) -> Array:
	load_data()
	return [_d["sun_a"][row], _d["sun_b"][row]]


## $8138 -- one row of the ramp that takes the names down, eight threes of it.
## $4D counts three at a time, which is the row's own place in the table.
static func ramp(row: int) -> Array:
	load_data()
	return _d["ramp"][row / 3]


## $E42F, $E463 and $E4A5 -- the three pictures the man is drawn from while he
## walks in, while he turns, and while he stands.
static func walk_pic(i: int) -> int:
	load_data()
	return int(_d["walk_pic"][i])


## $E44B and $E45A -- the two holds between his walk being over and the names
## going down.
static func hold(i: int) -> int:
	load_data()
	return int(_d["walk_hold"][i])


## $81E4 -- the three colours a beat names, and $81D1 -- the three that are
## always the same, whatever the beat says.
static func beat_pal(y: int) -> Array:
	load_data()
	return _d["beat_pal"][y]


static func beat_fixed() -> Array:
	load_data()
	return _d["beat_fixed"]


## $820E -- the stream itself, byte for byte, because $4E walks it a byte at a
## time and is judged against the cartridge.
static func stream() -> Array:
	load_data()
	return _d["stream"]


## $820E -- the beats of the ending, in the order the stream holds them.
static func beats() -> Array:
	load_data()
	return _d["beats"]


static func beat(i: int) -> Dictionary:
	load_data()
	var all: Array = _d["beats"]
	return all[i] if i < all.size() else all[all.size() - 1]


## $829F -- one of the twenty six lines, as the address it goes at and the
## tiles that go there.
static func line(i: int) -> Dictionary:
	load_data()
	var all: Array = _d["lines"]
	return all[i] if i < all.size() else {}


## $8963 -- the first of the six rows of twenty blanks that wipe a beat off.
static func erase_at() -> int:
	load_data()
	return int(_d["erase_at"][0])


## $E39D -- what the whole game paid, which is not the same as what was scored.
static func bonus(lives: int, sat: int, clean: bool) -> int:
	load_data()
	var out: int = lives * int(_d["pay_life"])
	if sat != 0:
		out += (((sat + int(_d["sat_turn"])) & 0x07)
				* int(_d["pay_sat"]))
		out += int(_d["pay_clear"])
	if clean:
		out += int(_d["pay_clean"])
	return out
