extends RefCounted
class_name SolOver

## The counts GAME OVER and BEST 5 write over their screens, and the name plate
## that says which stage the game was left in.
##
## Neither count is a tile the screen holds.  $EC7C turns three bytes into six
## digits by taking a hundred thousand away, then ten thousand, and so on, and
## $ECF5 adds $30 to each; $D9F1 then hands the six to the writer bank four
## keeps at $9607 as a little script -- an address and six bytes.  Here the six
## go straight into the screen, which is the same thing a picture later.
##
## `work/extract/sol_over.py` says where each of the tables comes from.

static var _d: Dictionary = {}


static func load_data() -> void:
	if not _d.is_empty():
		return
	_d = Nes._load_json(Nes.DATA + "/sol/over.json")


## $EC7C and $ECF5 -- one count as six tiles, the highest first.  Nine hundred
## and ninety nine thousand nine hundred and ninety nine is as far as it goes:
## anything above comes out as six nines.
static func digits(n: int) -> Array:
	load_data()
	var base: int = int(_d["digit"])
	if n >= 1000000:
		return [base + 9, base + 9, base + 9, base + 9, base + 9, base + 9]
	var out := []
	for step in [100000, 10000, 1000, 100, 10, 1]:
		var k: int = n / step
		n -= k * step
		out.append(base + k)
	return out


## $D9F1 -- six digits written into the screen, left to right.
static func write(host, addr: int, n: int) -> void:
	var six := digits(n)
	for i in range(6):
		host.flow_poke(addr + i, int(six[i]))


## $D728 -- a name of three letters, which are tiles already and not digits.
static func write_name(host, addr: int, name: Array) -> void:
	for i in range(3):
		host.flow_poke(addr + i, int(name[i]))


## $E237 -- the screens the plate of a stage is made of: the ground it is laid
## on, and then the plate itself out of $E223 by way of $E248.
static func plate(stage: int) -> Array:
	load_data()
	var of: Array = _d["plate_of"]
	var which: int = int(of[stage]) if stage < of.size() else 0
	return [int(_d["ground"]), int(_d["plate"][which])]


static func over_score_at() -> int:
	load_data()
	return int(_d["over_score"])


static func over_best_at() -> int:
	load_data()
	return int(_d["over_best"])


static func best_at() -> Array:
	load_data()
	return _d["best_at"]


static func name_at() -> Array:
	load_data()
	return _d["name_at"]


## $E545/$E54A and $E536/$E53B/$E540 -- what the reset puts in the five lines.
static func first_scores() -> Array:
	load_data()
	var out := []
	for n in _d["scores"]:
		out.append(int(n))
	return out


static func first_names() -> Array:
	load_data()
	var out := []
	for one in _d["names"]:
		out.append([int(one[0]), int(one[1]), int(one[2])])
	return out


## $D4E2 -- the screen laid over BEST 5 while a name is typed: one of five, by
## which of the lines the new count landed on.
static func name_screen(line: int) -> int:
	load_data()
	return int(_d["name_screen"]) + line


## $D60B -- where the cursor stands beside a line, and $D5EC -- how far along
## it stands for the letter being typed.
static func mark_y(line: int) -> int:
	load_data()
	return int(_d["mark_y"][line])


static func mark_x(letter: int) -> int:
	load_data()
	return (int(_d["mark_x"]) + letter * int(_d["mark_step"])) & 0xFF


static func mark_tile() -> int:
	load_data()
	return int(_d["mark_tile"])


## $D619 -- the two banks the letters are drawn out of, turned over every
## fourth picture.
static func blink_at(i: int) -> Array:
	load_data()
	return [int(_d["blink"][0][i]), int(_d["blink"][1][i])]


## $D69F -- how many lines each of the eight bands of the name screen is.
static func split() -> Array:
	load_data()
	return _d["split"]


## $D58F -- the place of a letter turned into the tile it is drawn as, and
## $D5CD -- into the byte it is kept as.  The last of the thirty one is blank.
static func letter_tile(place: int) -> int:
	load_data()
	var n: int = int(_d["letter_base"])
	if place == int(_d["letter_blank"]):
		return n + 0x3E
	return n + place


static func letter_byte(place: int) -> int:
	load_data()
	var one: int = (int(_d["letter_base"]) + place) & 0xFF
	return int(_d["blank_tile"]) if one == 0x5F else one


static func letter_n() -> int:
	load_data()
	return int(_d["letter_n"])


static func letter_blank() -> int:
	load_data()
	return int(_d["letter_blank"])


## $D54E -- a letter read back out of a name, turned into its place.
static func letter_place(one: int) -> int:
	load_data()
	if one == int(_d["blank_tile"]):
		return int(_d["letter_blank"])
	return (one - int(_d["letter_base"])) & 0xFF
