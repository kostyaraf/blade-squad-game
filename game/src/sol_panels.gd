extends RefCounted
class_name SolPanels

## The four panels of every stage -- what ducking on one buys.
##
## `work/extract/sol_panels.py` says where each of these comes from.  Nothing
## here decides anything: the ducking state in `sol_player.gd` does, and this
## is only what it decides out of.

static var _d: Dictionary = {}

## Which of the four a panel is.
const SHIELD := 0
const SUIT := 1
const TRY := 2
const GIFT := 3


static func load_data() -> void:
	if not _d.is_empty():
		return
	_d = Nes._load_json(Nes.DATA + "/sol/panels.json")


static func one(key: String) -> int:
	load_data()
	return int(_d[key])


## $9D6E -- the four tiles this stage's panels are made of.  Nought is no
## panel of that kind at all.
static func tiles(stage: int) -> Array:
	load_data()
	return _d["tiles"][stage]


## $9DEC -- what the fourth panel of this stage gives.
static func gift(stage: int) -> int:
	load_data()
	return int(_d["gift"][stage])


## $9DC5, $9E07 and $9E30 -- what one of the three costs.
static func cost(which: int) -> int:
	load_data()
	return int(_d["cost"][which])
