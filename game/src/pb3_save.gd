extends RefCounted
class_name Pb3Save

## Э7.3 -- what the port remembers between one running and the next.
##
## Neither cartridge had a battery: everything either game knew it knew until
## the console was switched off, and the stage select screen came up with its
## stamps as it had been left only because the console had not been off. So
## this is the port's own, like the menu, and what it keeps is exactly what
## each game itself carries from one stage to the next -- no more, because
## anything more would be a decision the game never made:
##
## * Power Blade 2: `$5B` which stages are finished and `$56` which suits he
##   has found. Those two are the whole of what `$8838` reads when it lays the
##   stage select screen out;
## * Solbrain: `$2D` which stages are done with, and the table of best scores
##   with its names, which the cartridge kept in memory and lost on the
##   switch.
##
## One file, and it is only ever touched by a run that came through the menu:
## a stand drives `main.gd` by its arguments and must never read or write
## anything that outlives it.

const PATH := "user://progress.json"


## What was kept, or nothing at all if there is no file or it is not readable.
static func read() -> Dictionary:
	if not FileAccess.file_exists(PATH):
		return {}
	var text := FileAccess.get_file_as_string(PATH)
	if text == "":
		return {}
	var got: Variant = JSON.parse_string(text)
	return got if got is Dictionary else {}


## And kept again. A file that will not open is not worth stopping the game
## for: the game goes on and the next stage tries again.
static func write(what: Dictionary) -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(what))

## JSON knows one kind of number and gives every one of them back as a real
## number.  Every number either cartridge keeps is whole -- a score is a row of
## digits and a name is a row of tile numbers -- so what comes out of the file
## is made whole again before the game is handed it; otherwise the game would
## be drawing 300.0 where the cartridge draws 300.
static func whole(what: Variant) -> Variant:
	if what is Array:
		var out := []
		for x in what:
			out.append(whole(x))
		return out
	if what is Dictionary:
		var by := {}
		for k in what:
			by[k] = whole(what[k])
		return by
	if what is float:
		return int(what)
	return what
