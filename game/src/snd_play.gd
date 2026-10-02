extends RefCounted
class_name SndPlay

## Э6.3.1 -- the seat the sound sits in.
##
## Э6.1 ported the two drivers, Э6.2 built the chip they write into.  What is
## missing between them and a loudspeaker is three things, and they are all
## here: whose driver runs, how many cycles of the chip a picture is worth, and
## where the samples go.
##
## **Whose driver.**  One picture, one driver.  A single game runs its own; a
## pair (Э5) runs the driver of the game whose level is being played, the same
## choice as Э5.4 and Э5.8 -- the rhythm belongs to the level.  The guest's
## numbers mean nothing in the host's driver. PB3 runs a second instance
## for guest effects and mixes the two outputs.
##
## **How many cycles.**  An NTSC picture is 29780.5 cycles of the processor.
## The half is kept, not thrown away: three pictures are 89341 cycles and not
## 89340, and a tune that loses half a cycle a picture drifts.
##
## **Where the samples go.**  `AudioStreamGenerator` takes them at the chip's
## own rate, 1789773/40 Hz, so nothing is resampled on the way out.  The
## console's three filters -- two high passes at 90 Hz and 440 Hz and a low
## pass at 14 kHz -- are applied here and not in the chip, because the chip is
## compared with `nesemu` sample for sample and a filter inside it would have
## to be written twice and compared too.  Outside it proves nothing and spoils
## nothing.

const RATE := 1789773.0 / 40.0             ## 44744.325 Hz, the chip's own
const CYCLES := 29780.5                    ## one NTSC picture

var chip: SndChip
var apu: SndApu
var pb2: Pb2Sound = null                   ## whichever of the two is playing
var sol: SolSound = null
var game := ""
var _carry := 0.0                          ## the half cycle, kept over
var _pend := PackedFloat32Array()          ## samples made, not yet handed over

## The three filters of the console, each one pole.
var _hp90 := 0.0
var _hp440 := 0.0
var _lp := 0.0
var _k90 := 0.0
var _k440 := 0.0
var _klp := 0.0

## What the stand counts: samples made and samples dropped because nobody took
## them.  A player that swallows or doubles samples shows up here and nowhere
## else, so both are kept even when no one is listening.
var made := 0
var dropped := 0
var cycles := 0                            ## and how many cycles were run


func _init(g: String) -> void:
	game = g
	apu = SndApu.new()
	Pb2Sound.forget()
	SolSound.forget()
	if g == "pb2":
		pb2 = Pb2Sound.new(apu)
		pb2.boot()
	else:
		sol = SolSound.new(apu)
		sol.boot()
	chip = SndChip.new(SndRom.dmc(g))
	chip.reset()
	# The cartridge enables its voices in reset code outside the driver.
	for write in SndRom.boot(g):
		chip.write(int(write[0]), int(write[1]))
	for write in apu.writes:
		chip.write(int(write[0]), int(write[1]))
	apu.clear()
	var w := TAU / RATE
	_k90 = w * 90.0 / (w * 90.0 + 1.0)
	_k440 = w * 440.0 / (w * 440.0 + 1.0)
	_klp = w * 14000.0 / (w * 14000.0 + 1.0)


## $ECE8 for one game and $F0/$F1 for the other: ask for a tune or a sound.
## The number is the cartridge's own, and the two games do not share theirs,
## so a request only ever goes to the driver of the game that made it.
func ask(n: int) -> void:
	if pb2 != null:
		pb2.ask(n)
	else:
		sol.ask_tune(n)


## Solbrain alone: $F1, the sound a thing makes, which is not a tune.
func ask_sound(n: int) -> void:
	if sol != null:
		sol.ask_sound(n)


## The driver's own picture, and nothing else: the requests go in, in the
## order they were made, and then the driver runs.  What it writes is left
## standing in `apu` for whoever wants it.
##
## Kept apart from `step` because a stand that is judging requests wants the
## driver and not the chip -- synthesising a wave nobody listens to would cost
## it seven hundred samples a picture for nothing.
func drive() -> void:
	apu.clear()
	if pb2 != null:
		# In the order they were asked for, and all of them before the tick:
		# on the console the game asks from the main loop and the driver runs
		# from the interrupt handler, which comes after.
		for n in Pb2Sound.asked:
			pb2.ask(n)
		Pb2Sound.asked = []
		pb2.tick()
		return
	# Two cells, so the last word wins and nothing queues -- which is what two
	# bytes of zero page do.
	if SolSound.want_tune != 0:
		sol.ask_tune(SolSound.want_tune)
	if SolSound.want_noise != 0:
		sol.ask_sound(SolSound.want_noise)
	SolSound.forget()
	sol.tick()


## One picture: the driver runs, and what it wrote goes into the chip at the
## head of the picture -- the way the cartridge's own interrupt handler makes
## its writes -- and then the chip is run out to the end of the picture.
##
## The cartridge spreads those writes over some thousands of cycles inside the
## picture and this does not.  A register written a fiftieth of a millisecond
## early is not a thing anybody hears; a picture a cycle short is.
func step() -> void:
	# Direct ask() calls can write registers before the interrupt tick.
	var pending: Array = apu.writes.duplicate()
	drive()
	for w in pending + apu.writes:
		chip.write(int(w[0]), int(w[1]))
	apu.writes.clear()
	var want := CYCLES + _carry
	var n := int(want)
	_carry = want - float(n)
	# `reserve` sets the count back to nought and keeps the room, so the chip
	# writes over last picture's samples instead of growing for ever.
	chip.reserve(n / SndChip.SND_EVERY + 2)
	chip.run(n)
	cycles += n
	_drain()


## The samples the chip has just made, filtered and put by.  The chip holds
## them the way the emulator writes them out, s16le, and the filters want a
## number between -1 and 1.
func _drain() -> void:
	var wave := chip.out
	var i := 0
	while i < chip.out_n:
		var v := float(wave.decode_s16(i)) / 32768.0
		_hp90 += (v - _hp90) * _k90
		var a := v - _hp90
		_hp440 += (a - _hp440) * _k440
		var b := a - _hp440
		_lp += (b - _lp) * _klp
		_pend.append(_lp)
		made += 1
		i += 2


## Hand over what will fit.  Called once a monitor frame, not once a picture:
## the generator's buffer is what stands between the console's clock and the
## sound card's.
func pump(play: AudioStreamGeneratorPlayback) -> void:
	# No player at all is the same case as a player with no room: nobody is
	# taking them, and what has piled up goes by the rule below.
	var room: int = play.get_frames_available() if play != null else 0
	var n: int = mini(room, _pend.size())
	for i in range(n):
		var v := _pend[i]
		play.push_frame(Vector2(v, v))
	if n < _pend.size() and _pend.size() > int(RATE / 4.0):
		# A quarter of a second behind means nobody is taking them; the oldest
		# go, not the newest, so the sound stays with the picture.
		var keep := int(RATE / 8.0)
		dropped += _pend.size() - n - keep
		_pend = _pend.slice(_pend.size() - keep)
	else:
		_pend = _pend.slice(n)
