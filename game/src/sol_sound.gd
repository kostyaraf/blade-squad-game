extends RefCounted
class_name SolSound

## Solbrain's sound driver, bank nought.
##
## One door, $8000, which is both the picture and the reading of the two cells
## the rest of the cartridge asks through: $F0 is a tune and $F1 is a sound.
##
## `work/re/sol_sound.md` says where each piece came from.

var apu: SndApu
var rom: PackedByteArray


func _init(a: SndApu) -> void:
	apu = a
	rom = SndRom.window("sol")


## Nothing: the cartridge's boot clears the page and calls $8000 a picture at
## a time like any other.
func boot() -> void:
	pass


## $F0 -- ask for a tune.
func ask_tune(_n: int) -> void:
	pass


## $F1 -- ask for a sound.
func ask_sound(_n: int) -> void:
	pass


## $8000 -- one picture.
func tick() -> void:
	pass
