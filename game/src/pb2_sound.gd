extends RefCounted
class_name Pb2Sound

## Power Blade 2's sound driver, bank twelve.
##
## Three doors, and the cartridge uses all three:
##
##     $8000   ask for a number (A); $00 is silence
##     $8003   one picture
##     $8006   ...
##
## `work/re/pb2_sound.md` says where each piece came from.

var apu: SndApu
var rom: PackedByteArray


func _init(a: SndApu) -> void:
	apu = a
	rom = SndRom.window("pb2")


## What the cartridge's own boot does before anything is asked: $8000 with
## A = 0.
func boot() -> void:
	ask(0)


## $8000 -- a number is asked for.
func ask(_n: int) -> void:
	pass


## $8003 -- one picture.
func tick() -> void:
	pass
