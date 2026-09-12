extends RefCounted
class_name SolTest

## TEST MODE -- the maker's own menu, opened by sixteen buttons in a row on the
## title ($D226).  $D79F lays screen $19, $D7C2 walks a cursor of one sprite
## down nine lines, and START takes the line the cursor stands on.
##
## Seven of the nine lines are a stage and nothing else: a stub in the fixed
## bank puts a number into $55 and asks for it ($1D).  That is the only door
## in the game to the stages the boss rooms stand in.
##
## `work/extract/sol_test.py` says where each of the tables comes from.

static var _d: Dictionary = {}


static func load_data() -> void:
	if not _d.is_empty():
		return
	_d = Nes._load_json(Nes.DATA + "/sol/test.json")


## $D7A5 -- the screen the menu is drawn on.
static func screen() -> int:
	load_data()
	return int(_d["screen"])


## $D7F7 -- how far down the cursor stands on a line, and $D7FD -- how far
## along, which never changes.
static func cursor_y(line: int) -> int:
	load_data()
	return int(_d["cursor_y"][line])


static func cursor_x() -> int:
	load_data()
	return int(_d["cursor_x"])


static func cursor_tile() -> int:
	load_data()
	return int(_d["cursor_tile"])


static func lines() -> int:
	load_data()
	return int(len(_d["cursor_y"]))


## $D816 -- the mode a line leads to.
static func goes(line: int) -> int:
	load_data()
	return int(_d["goes"][line])


## $CA7D and $D930 -- the stage a stub asks for, or minus one if the mode is
## not one of the stubs.
static func stage_of(mode: int) -> int:
	load_data()
	var key := "%02X" % mode
	if not _d["stage_of"].has(key):
		return -1
	return int(_d["stage_of"][key])


## $D86B and $D90E -- the two tests, their screens and how far their numbers
## count.
static func bgm_screen() -> int:
	load_data()
	return int(_d["bgm_screen"])


static func bgm_n() -> int:
	load_data()
	return int(_d["bgm_n"])


static func sound_screen() -> int:
	load_data()
	return int(_d["sound_screen"])


static func sound_n() -> int:
	load_data()
	return int(_d["sound_n"])


## $D84F -- where $D847 writes the two digits of a test's number.
static func number_at() -> int:
	load_data()
	return int(_d["number_at"])


## $D7BA and $D87B -- the table all three screens of TEST MODE name: twenty of
## it for the menu and sixteen for the two tests.
static func table() -> int:
	return 0xD485


static func menu_n() -> int:
	load_data()
	return int(_d["menu_n"])


static func test_n() -> int:
	load_data()
	return int(_d["test_n"])
