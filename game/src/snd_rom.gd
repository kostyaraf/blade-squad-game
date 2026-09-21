extends RefCounted
class_name SndRom

## The two banks a sound driver reads, at the addresses it reads them by.
##
## A driver is an interpreter: about two kilobytes of code walking six
## kilobytes of tables that sit in the same two banks.  The tables are the
## tunes.  Copying them out by hand would mean writing several thousand
## numbers down twice, so instead the window the driver reads -- $8000..$BFFF,
## with the two banks the game's wrapper always maps there -- is exported
## whole by `work/extract/sound.py` and read here at the cartridge's own
## addresses.  `$8AE9,Y` in the port is `$8AE9,Y` in the cartridge.
##
##     Power Blade 2   banks 12 and 13  ($ECAF sets R6 to Y and R7 to Y+1)
##     Solbrain        banks 0 and 1    (bank fourteen's boot sets R6, R7)

const BASE := 0x8000
const TOP := 0xC000

static var _rom := {}
static var _dmc := {}


## The window of `game`, read once and kept.
static func window(game: String) -> PackedByteArray:
	if _rom.has(game):
		return _rom[game]
	var f := FileAccess.open("res://data/%s/sound.json" % game, FileAccess.READ)
	assert(f != null, "no sound.json for %s -- run work/extract/sound.py" % game)
	var d: Dictionary = JSON.parse_string(f.get_as_text())
	var out := PackedByteArray()
	out.resize(TOP - BASE)
	var rom: Array = d["rom"]
	for i in range(rom.size()):
		out[i] = int(rom[i])
	_rom[game] = out
	var dmc := PackedByteArray()
	var raw: Array = d.get("dmc", [])
	dmc.resize(raw.size())
	for i in range(raw.size()):
		dmc[i] = int(raw[i])
	_dmc[game] = dmc
	return out


## The bank the mapper fixes at $C000, which is where a DMC sample is fetched
## from.  Power Blade 2 keeps its two drums here; Solbrain has none.
static func dmc(game: String) -> PackedByteArray:
	if not _dmc.has(game):
		window(game)
	return _dmc[game]
