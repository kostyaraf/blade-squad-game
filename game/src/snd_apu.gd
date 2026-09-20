extends RefCounted
class_name SndApu

## Where a sound driver's writes go.
##
## Neither cartridge makes a sound itself: both drivers do one thing, which is
## to write bytes into the console's sound registers, $4000..$4017, and the
## console makes the sound.  So the whole of a driver's behaviour is the
## order and the timing of those writes, and that is what this holds.
##
## It is the seam between Э6.1 and Э6.2.  Э6.1 puts the two ported drivers on
## one side of it and proves, picture by picture, that what they write is what
## the cartridge wrote (`work/extract/verify_sound.py`).  Э6.2 puts five
## channels on the other side and makes a sound out of it.  Until then nothing
## listens, and the drivers do not care: the cartridge's do not either.
##
## `regs` is what the console would hold -- the last byte written to each
## register -- and `writes` is the order they arrived in, which matters,
## because writing $4003 is what restarts a note and writing $4000 is not.

const LO := 0x4000
const N := 0x18                            ## $4000..$4017

var regs := PackedByteArray()
var writes: Array = []                     ## [[addr, value], ...]


func _init() -> void:
	regs.resize(N)


## One write, as the driver's `STA $40xx` would do it.
func w(addr: int, val: int) -> void:
	regs[addr - LO] = val & 0xFF
	writes.append([addr, val & 0xFF])


## What the console keeps there now.  $4015 is the only register either driver
## ever reads back, and both read their own last write, not the console's
## counters, because neither ever waits on a length counter.
func r(addr: int) -> int:
	return regs[addr - LO]


## Start of a picture: the tape of the last one is done with.
func clear() -> void:
	writes.clear()
