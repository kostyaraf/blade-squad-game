extends RefCounted
class_name SolSound

## Solbrain's sound driver, banks nought and one.
##
## One door, $8000, which is both the picture and the reading of the two cells
## the rest of the cartridge asks through: $F0 is a tune and $F1 is a sound.
## Three numbers are not numbers at all but orders, and they leave through the
## bank beside it ($8006 -> $BE98 quiet the sounds, $800F -> $BE64 the tune,
## $8016 -> $BEB7 everything).
##
## It is an interpreter of seven voices, each a block of forty bytes:
##
##     $03D0  $03F8  $0420  $0448   the tune's four
##     $0470  $0498  $04C0           and three for the sounds on top
##
## Which of the console's channels a voice writes is $EA & $0F ($8CAC), so
## $03D0 and $0470 are both the first square, $03F8 and $0498 the second.
## Neither is given the channel: the tune's two ask through $8CEA, which
## refuses while the sound's block beside it is taken.  The other five write
## straight through.  That is the thing a recording of each tune could never
## reproduce, and it is why Э6 ports the driver (`work/re/sound.md`).
##
## Which voices a tune or a sound wants is the first byte of its header, a bit
## a voice from the top, and the bit left over at the bottom says "do not move
## me" ($8D78).  The second byte is what it is worth; a voice is taken only
## from something worth no more ($8D8E).
##
## The memory is kept flat -- zero page and the pages the blocks live in --
## because the cartridge's own offsets alias: on the drum voice $11 and $12
## are not the envelope's counters but where its pattern is ($8B4C), and the
## two echo rings sit in the same page as the blocks, right after them.
##
## `work/re/sol_sound.md` says where each piece came from.

# Zero page.
const E0 := 0xE0                            ## $E0:$E1 -- the voice's block
const E2 := 0xE2                            ## $E2:$E3 -- into the stream
const E4 := 0xE4                            ## $E4:$E5 -- a table, or a vector
const E8 := 0xE8                            ## how far into a header
const E9 := 0xE9                            ## how far into the stream
const EA := 0xEA                            ## which voice is being walked
const EB := 0xEB                            ## the byte just read
const EC := 0xEC                            ## scratch
const ED := 0xED                            ## scratch
const F0 := 0xF0                            ## the tune asked for
const F1 := 0xF1                            ## the sound asked for
const F3 := 0xF3                            ## the header's voices, being shifted
const F4 := 0xF4                            ## what it is worth
const F5 := 0xF5                            ## and whether it may be moved
const F6 := 0xF6                            ## the game asks for a pause
const F7 := 0xF7                            ## and it is paused
const F8 := 0xF8                            ## the game asks for a fade
const F9 := 0xF9                            ## pictures left of this step of it
const FA := 0xFA                            ## and how much is taken off
const FB := 0xFB                            ## the tune's first square is free again
const FC := 0xFC                            ## and its second
const FD := 0xFD                            ## $EF counts here and nothing reads it
const FE := 0xFE                            ## the drum is struck again

# A block, by the cartridge's own offset from it.
const PRIO := 0x00                          ## nought while the voice is free
const SRC_L := 0x01                         ## the stream
const SRC_H := 0x02
const KIND := 0x03                          ## two is a stream of effects ($8229)
const TONE := 0x04                          ## the $4000 byte the stream asked for
const OUT := 0x05                           ## and the one actually written
const HARD := 0x06                          ## $FF writes $4003 even unchanged
const SWEEP := 0x07                         ## the $4001 byte
const OCT := 0x08                           ## the octave
const OFF := 0x09                           ## detune, added to the period
const PER_L := 0x0A                         ## the period,
const PER_H := 0x0B                         ## with $C0 on its top byte
const SLOW := 0x0C                          ## the attack counts pictures ($8B01)
const UNIT := 0x0D                          ## how long one unit of a note is
const LEFT := 0x0E                          ## left of this note
const ENV_L := 0x0F                         ## where the envelope is ($8517)
const ENV_H := 0x10
const STEPS := 0x11                         ## steps left of this leg of it,
const EVERY := 0x12                         ## and pictures left of this step
const ATT := 0x13                           ## $FB's four: the attack,
const DEC := 0x14                           ## the fall,
const HOLD := 0x15                          ## when the release starts,
const REL := 0x16                           ## and the release
const V_WAIT := 0x17                        ## $F9's three: the wait before the
const V_RATE := 0x18                        ## vibrato, how often it turns,
const V_DEEP := 0x19                        ## and how far
const V_LEFT := 0x1A                        ## the wait, counting down
const V_NEXT := 0x1B                        ## pictures until it turns
const V_SIDE := 0x1C                        ## and which way it is leaning
const L1 := 0x1D                            ## $F0's loop: times round,
const L1_L := 0x1E                          ## and where it starts
const L1_H := 0x1F
const L2 := 0x20                            ## $F3's loop, inside it
const L2_L := 0x21
const L2_H := 0x22
const RET_L := 0x23                         ## where $F5 comes back to
const RET_H := 0x24
const ENVON := 0x25                         ## $FB sets this and $FC clears it
const FRESH := 0x26                         ## just taken: the first picture is skipped
const ECHO := 0x27                          ## how far back the echo reaches

# And the same bytes under the names the drum voice gives them ($8B4C).
const DRUM_L := 0x11                        ## where its pattern is
const DRUM_H := 0x12
const BEAT := 0x13                          ## how long one beat of it is
const BEAT_N := 0x14                        ## and what is left of this one

## $8106 and the six blocks unrolled after it, with the $EA each is walked as.
const BLOCK := [0x03D0, 0x03F8, 0x0420, 0x0448, 0x0470, 0x0498, 0x04C0]
## $04E8 and $0510 -- the last forty notes of each square, for the echo.
const RING := {0x00: 0x04E8, 0x04: 0x0510}

var apu: SndApu
var rom: PackedByteArray
var zp := PackedByteArray()
var ram := PackedByteArray()                ## $0000..$07FF, blocks and rings


func _init(a: SndApu) -> void:
	apu = a
	rom = SndRom.window("sol")
	zp.resize(0x100)
	ram.resize(0x800)


## The two banks, read at the cartridge's own addresses.
func _rd(a: int) -> int:
	return rom[(a - 0x8000) & 0x3FFF]


## A byte wherever it is: the blocks are in memory and the streams are not.
func _peek(a: int) -> int:
	if a < 0x0800:
		return ram[a]
	return _rd(a)


## A pointer held in two cells of zero page.
func _ptr(at: int) -> int:
	return zp[at] | (zp[at + 1] << 8)


## ($E0),Y -- a byte of the voice being walked.
func _bk(off: int) -> int:
	return ram[(_ptr(E0) + off) & 0x7FF]


func _sbk(off: int, v: int) -> void:
	ram[(_ptr(E0) + off) & 0x7FF] = v & 0xFF


## ($E2),Y -- a byte of the stream, Y being one byte like the cartridge's.
func _at(y: int) -> int:
	return _peek((_ptr(E2) + (y & 0xFF)) & 0xFFFF)


## $82B0 and its like: the next byte of the stream.
func _next() -> int:
	var v := _at(zp[E9])
	zp[E9] = (zp[E9] + 1) & 0xFF
	return v


func _w(a: int, v: int) -> void:
	apu.w(a, v & 0xFF)


## The cartridge's boot leaves the page as the console found it, and the
## driver asks for nothing until the game does.
func boot() -> void:
	pass


## $F0 and $F1 as the console has them.
##
## On the cartridge these are two bytes of zero page, and whoever wants a
## noise writes one of them: a mind three banks away, a shot, the satellite,
## the screen between stages.  Nothing hands the driver over to any of them
## and nothing has to -- zero page is where they all already are.
##
## Here they are static for the same reason: `SolMinds` holds a pool and
## nothing else, `SolShots` holds nothing at all, and there is one console.
## Whoever writes last wins, the way a byte does, and the driver takes them
## once a picture and leaves nought behind (`SndPlay.step`).
static var want_tune := 0                   ## $F0
static var want_noise := 0                  ## $F1


## Put both back to nought, which is what a console coming up does.  A stand
## runs one game after another in the one process, and a noise asked for at
## the end of the last must not be heard at the start of the next.
static func forget() -> void:
	want_tune = 0
	want_noise = 0


## $F0 -- ask for a tune.
func ask_tune(n: int) -> void:
	zp[F0] = n & 0xFF


## $F1 -- ask for a sound.
func ask_sound(n: int) -> void:
	zp[F1] = n & 0xFF


## $8000 -- one picture.
func tick() -> void:
	if zp[F1] == 0x22:
		_BE98()
		return
	if zp[F0] == 0x0F:
		_BE64()
		return
	if zp[F0] == 0x10:
		_BEB7()
		return
	if zp[F0] != 0:
		_8D06(zp[F0])
	elif zp[F1] != 0:
		_8D2C(zp[F1])
	_802D()


## $802D -- the pause, which is the whole console turned off and one voice
## left running to make the noise that says so.
func _802D() -> void:
	if zp[F6] != 0:
		if zp[F7] == 0:
			zp[F7] = 0xFF                   # $8038
			for x in range(0x0F, -1, -1):
				_w(0x4000 + x, 0x00)
			_w(0x4015, 0x0F)
			_w(0x4000, 0x30)
			_w(0x4004, 0x30)
			_w(0x400C, 0x30)
			_w(0x4001, 0x88)
			_w(0x4005, 0x88)
			zp[F1] = 0x01                   ## and the pause is sound one
		_8106(4)                            # $81B3
		return
	if zp[F7] != 0:
		zp[F7] = 0x00                       # $806C
		ram[0x0470] = 0
		ram[0x0471] = 0
		ram[0x0472] = 0
		if ram[0x03D0] != 0:
			_8257()
		else:
			_w(0x4000, 0x30)
			_w(0x4001, 0x88)
			_w(0x4002, 0x00)
			_w(0x4003, 0x00)
		if ram[0x03F8] != 0:
			_8270()
		else:
			_w(0x4004, 0x30)
			_w(0x4005, 0x88)
			_w(0x4006, 0x00)
			_w(0x4007, 0x00)
	_80B3()


## $8257 -- give the first square back what the tune had in it.
func _8257() -> void:
	_w(0x4000, ram[0x03D5])
	_w(0x4001, ram[0x03D7])
	_w(0x4002, ram[0x03DA])
	_w(0x4003, ram[0x03DB])


## $8270 -- and the second.
func _8270() -> void:
	_w(0x4004, ram[0x03FD])
	_w(0x4005, ram[0x03FF])
	_w(0x4006, ram[0x0402])
	_w(0x4007, ram[0x0403])


## $80B3 -- the fade: every $18 pictures one more is taken off every volume
## ($8363), and after eight the tune is let go of.
func _80B3() -> void:
	if zp[F8] != 0:
		if zp[F9] != 0:
			zp[F9] = (zp[F9] - 1) & 0xFF
		else:
			zp[F9] = 0x18
			zp[FA] = (zp[FA] + 1) & 0xFF
			if zp[FA] == 0x06:
				ram[0x0420] = 0
				_w(0x4008, 0x00)
				_w(0x400A, 0x00)
				_w(0x400B, 0x00)
			elif zp[FA] == 0x08:
				ram[0x03D0] = 0
				ram[0x03F8] = 0
				ram[0x0448] = 0
				ram[0x0470] = 0
				ram[0x0498] = 0
				ram[0x04C0] = 0
				zp[F8] = 0
				zp[F9] = 0
				zp[FA] = 0
				_w(0x4000, 0x30)
				_w(0x4004, 0x30)
				_w(0x400C, 0x30)
	_8106(0)


## $8106 -- the seven blocks, which the cartridge writes out one after another.
## $81D9 sits between the fifth and the sixth, so a paused picture, which
## comes in at $81B3, walks the fifth and stops.
func _8106(first: int) -> void:
	for i in range(first, BLOCK.size()):
		if i == 5 and zp[F6] != 0:          # $81D9
			return
		zp[E0] = BLOCK[i] & 0xFF
		zp[E0 + 1] = BLOCK[i] >> 8
		zp[EA] = i * 4
		if _bk(PRIO) == 0:
			continue
		if (_bk(FRESH) & 0x01) != 0:
			_sbk(FRESH, _bk(FRESH) & 0xFE)
			continue
		if i == 0 and zp[FB] != 0:          # $8128
			zp[FB] = 0
			_8257()
		elif i == 1 and zp[FC] != 0:        # $8159
			zp[FC] = 0
			_8270()
		_8229()


## $8229 -- one picture of one voice.
func _8229() -> void:
	if _bk(KIND) == 0x02:
		_86C5()
		return
	var left := (_bk(LEFT) - 1) & 0xFF
	_sbk(LEFT, left)
	if left == 0:
		_8289()
		return
	if zp[EA] == 0x18:
		_8B6F()
		return
	if _bk(ENVON) != 0:
		_8517()
	_865D()
	_87F8()


## $8289 -- the note ran out, so read the stream until the next one.
func _8289() -> void:
	zp[E2] = _bk(SRC_L)
	zp[E2 + 1] = _bk(SRC_H)
	zp[E9] = 0
	_walk(0x8298)


## $86C5 -- and the same for a stream of effects.
func _86C5() -> void:
	var left := (_bk(LEFT) - 1) & 0xFF
	_sbk(LEFT, left)
	if left != 0:
		return
	zp[E2] = _bk(SRC_L)
	zp[E2 + 1] = _bk(SRC_H)
	zp[E9] = 0
	_walk(0x86E0)


## $8298 and $86E0 -- the two walks, which are one because either can turn
## into the other in the middle of itself ($82AD and $86F3).
func _walk(at: int) -> void:
	while at != 0:
		match at:
			0x8298:
				if _bk(PRIO) == 0:
					return
				if _bk(KIND) == 0x02:
					_sbk(PER_H, 0)
					at = 0x86F6
				else:
					at = 0x82B0
			0x82B0:
				zp[EB] = _next()
				if zp[EB] == 0xEF:
					zp[FD] = (zp[FD] + 1) & 0xFF
					continue
				var top := zp[EB] & 0xF0
				if top == 0xF0:
					_884D()
					at = 0x8298
				elif top == 0xE0:
					_8861()
					at = 0x8298
				elif top == 0xD0:
					_sbk(OCT, zp[EB] & 0x0F)
					at = 0x8298
				else:
					_82E8()
					return
			0x86E0:
				if _bk(PRIO) == 0:
					return
				if _bk(KIND) != 0:
					at = 0x86F6
				else:
					_sbk(PER_H, 0)
					at = 0x82B0
			0x86F6:
				zp[EB] = _next()
				if zp[EB] == 0xE0:
					_8ABA()
					return
				var top2 := zp[EB] & 0xF0
				if top2 == 0xF0:
					_884D()
					at = 0x86E0
				elif top2 == 0xE0:
					_8861()
					at = 0x86E0
				else:
					_871B()
					return
			_:
				at = 0


## $82E8 -- a rest or a note; either way the stream has got as far as it goes
## this picture.
func _82E8() -> void:
	if (zp[EB] & 0xF0) == 0xC0:
		if zp[EA] == 0x08:
			_w(0x4008, 0x00)
			_8319()
		elif zp[EA] == 0x18:
			if ram[0x0448] == 0:
				_w(0x400C, 0x30)
		else:
			var t := _bk(TONE) & 0xF0     # $830D
			_sbk(OUT, t)
			_8CA6(t)
			_8319()
	_832E()


## $8319 -- nothing is sounding, so the envelope has nothing to do.
func _8319() -> void:
	_sbk(ENV_L, 0x2D)
	_sbk(ENV_H, 0x83)
	_sbk(PER_H, 0)


## $832E -- how long the note is, how loud, and then what it is.
func _832E() -> void:
	_87B6()
	# The length is the unit added to itself once more than the low nibble
	# says, carry and all ($833C).
	var a := 0
	var c := 0
	for _i in range((zp[EB] & 0x0F) + 1):
		var t := a + _bk(UNIT) + c
		a = t & 0xFF
		c = t >> 8
	_sbk(LEFT, a)
	if (zp[EB] & 0xF0) == 0xC0:
		return
	if zp[EA] == 0x18:
		_8B4C()
		return
	var hi := _bk(TONE) & 0xF0              # $8356
	zp[EC] = hi
	var lo := (_bk(TONE) & 0x0F) - zp[FA]
	var v := hi if lo < 0 else (lo | hi)
	_sbk(OUT, v)
	_8CA6(v)
	if _bk(ENVON) != 0:
		_8395()
	_83D1()
	_83EC()


## $83D1 -- the vibrato starts again from its wait.
func _83D1() -> void:
	if _bk(V_DEEP) == 0:
		return
	_sbk(V_LEFT, _bk(V_WAIT))
	_sbk(V_NEXT, _bk(V_RATE))
	_sbk(V_SIDE, 0)


## $83EC -- the note itself: the octave and the top nibble find it in $8457,
## and the two squares remember it for the echo.
func _83EC() -> void:
	zp[EC] = zp[EB] & 0xF0
	var x := ((_bk(OCT) << 1) + zp[EC]) & 0xFF
	if RING.has(zp[EA]):
		if zp[EA] == 0x00:
			_87CB()
		else:
			_87E5()
		ram[RING[zp[EA]]] = x
	_8412(x)


## $8412 -- the period out of $8457, detuned, written.
func _8412(x: int) -> void:
	var s := _rd(0x8457 + x) + _bk(OFF)
	zp[EC] = s & 0xFF
	zp[ED] = (_rd(0x8457 + x + 1) + (s >> 8)) & 0xFF
	_sbk(PER_L, zp[EC])
	_8CC8(zp[EC])
	var top := (zp[ED] | 0xC0) & 0xFF
	# $4003 starts the note over, so the triangle and a voice told to be hard
	# about it write always and the rest only when it changed.
	if zp[EA] != 0x08 and _bk(HARD) == 0 and top == _bk(PER_H):
		return
	_sbk(PER_H, top)
	_8CD9(top)


## $87B6 -- the stream keeps where it got to.
func _87B6() -> void:
	var s := _bk(SRC_L) + zp[E9]
	_sbk(SRC_L, s & 0xFF)
	_sbk(SRC_H, (_bk(SRC_H) + (s >> 8)) & 0xFF)
	zp[E9] = 0


## $87CB and $87E5 -- the ring shifts along by one, and $83EC writes the new
## note into the hole it leaves.
func _87CB() -> void:
	for y in range(0x26, -1, -1):
		ram[0x04E9 + y] = ram[0x04E8 + y]


func _87E5() -> void:
	for y in range(0x26, -1, -1):
		ram[0x0511 + y] = ram[0x0510 + y]


## $87F8 -- the echo: a quiet copy of what this square played $27 notes ago,
## sounded whenever the square itself has fallen silent.
func _87F8() -> void:
	if not RING.has(zp[EA]):
		return
	if zp[EA] == 0x00:
		_87CB()
	else:
		_87E5()
	if _bk(ECHO) == 0:
		return
	if (_bk(OUT) & 0x0F) != 0:
		return
	_8CA6(_bk(OUT) | 0x02)
	_8412(ram[RING[zp[EA]] + _bk(ECHO)])


## $865D -- the vibrato, which leans the period one way and then the other.
func _865D() -> void:
	if _bk(V_DEEP) == 0:
		return
	if _bk(V_LEFT) != 0:
		_sbk(V_LEFT, (_bk(V_LEFT) - 1) & 0xFF)
		return
	var n := (_bk(V_NEXT) - 1) & 0xFF
	_sbk(V_NEXT, n)
	if n != 0:
		return
	zp[EC] = _bk(V_DEEP)
	_sbk(V_NEXT, _bk(V_RATE))
	var side := (_bk(V_SIDE) + 1) & 0x01
	_sbk(V_SIDE, side)
	var t := 0
	var top := 0
	if side == 0:
		t = _bk(PER_L) + zp[EC]             # $8694
		top = (_bk(PER_H) + (t >> 8)) & 0xFF
	else:
		t = _bk(PER_L) - zp[EC]             # $86B2
		top = (_bk(PER_H) - (1 if t < 0 else 0)) & 0xFF
	_sbk(PER_L, t & 0xFF)
	zp[ED] = t & 0xFF
	if top != _bk(PER_H):                   # $86A4
		_sbk(PER_H, top)
		_8CD9(top)
	_8CC8(zp[ED])


## $8517 -- whichever leg of the envelope this voice is on.
func _8517() -> void:
	match _bk(ENV_L) | (_bk(ENV_H) << 8):
		0x8525: _8525()
		0x85AF: _85AF()
		0x85F2: _85F2()
		0x8621: _8621()
		_: pass                             ## $832D and $865C are both an RTS


## $85E9 -- is what is left of the note down to where the release starts?
func _85E9() -> int:
	return _bk(HOLD) - _bk(LEFT)


## $8525 -- the attack, which climbs a step a picture unless $E6 said to take
## its time ($856B).
func _8525() -> void:
	if _85E9() >= 0:
		_85FA()
		return
	if _bk(SLOW) != 0:
		_856B()
		return
	var hi := _bk(OUT) & 0xF0               # $8536
	zp[EC] = hi
	var a := ((_bk(OUT) & 0x0F) + _bk(EVERY)) & 0xFF
	if a >= 0x0F:
		a = 0x0F
	a = (a + hi) & 0xFF
	_sbk(OUT, a)
	_8CA6(a)
	var s := (_bk(STEPS) - 1) & 0xFF
	_sbk(STEPS, s)
	if s == 0:
		_83AD()


## $856B -- the slow attack: one step every $13's low nibble pictures.
func _856B() -> void:
	var e := (_bk(EVERY) - 1) & 0xFF
	_sbk(EVERY, e)
	if e != 0:
		return
	var hi := _bk(OUT) & 0xF0               # $8577
	zp[EC] = hi
	var a := ((_bk(OUT) & 0x0F) + 1) & 0xFF
	if a >= 0x0F:
		a = 0x0F
	a = (a + hi) & 0xFF
	_sbk(OUT, a)
	_8CA6(a)
	var s := (_bk(STEPS) - 1) & 0xFF
	if s == 0:
		_83AD()
		return
	_sbk(STEPS, s)
	_sbk(EVERY, _bk(ATT) & 0x0F)


## $85AF -- the fall from the attack to what is held.
func _85AF() -> void:
	if _85E9() >= 0:
		_85FA()
		return
	var hi := _bk(OUT) & 0xF0
	zp[EC] = hi
	var a := (_bk(OUT) & 0x0F) - _bk(EVERY)
	if a <= 0:
		a = 0x01
	a = (a | hi) & 0xFF
	_sbk(OUT, a)
	_8CA6(a)
	var s := (_bk(STEPS) - 1) & 0xFF
	_sbk(STEPS, s)
	if s == 0:
		_83C5()


## $85F2 -- what is held, until there is little enough of the note left.
func _85F2() -> void:
	if _85E9() >= 0:
		_85FA()


## $85FA -- and then the release.
func _85FA() -> void:
	if zp[EA] == 0x08:
		_w(0x4008, 0x00)
		_sbk(ENV_L, 0x5C)                   # $8651
		_sbk(ENV_H, 0x86)
		return
	_8795()
	_8386(_bk(REL) & 0xF0, _bk(REL))
	_sbk(ENV_L, 0x21)
	_sbk(ENV_H, 0x86)


## $8621 -- one step of it.
func _8621() -> void:
	var e := (_bk(EVERY) - 1) & 0xFF
	_sbk(EVERY, e)
	if e != 0:
		return
	var s := (_bk(STEPS) - 1) & 0xFF
	if s == 0:
		var v := _bk(OUT) & 0xF0            # $8646
		_sbk(OUT, v)
		_8CA6(v)
		_sbk(ENV_L, 0x5C)
		_sbk(ENV_H, 0x86)
		return
	_sbk(STEPS, s)
	_8795()
	_sbk(EVERY, _bk(REL) & 0x0F)


## $8795 -- one quieter, and never all the way to nothing.
func _8795() -> void:
	var hi := _bk(OUT) & 0xF0
	zp[EC] = hi
	var lo := _bk(OUT) & 0x0F
	var a := 0
	if lo != 0:
		a = (lo - 1) & 0xFF
		_sbk(OUT, a)
		if a == 0:
			a = 0x01
	a = (a | hi) & 0xFF
	_sbk(OUT, a)
	_8CA6(a)


## $8386 -- a byte of the envelope is two numbers: how many steps and how long
## each one lasts.
func _8386(a: int, x: int) -> void:
	_sbk(STEPS, (a & 0xF0) >> 4)
	_sbk(EVERY, x & 0x0F)


## $8395, $83AD, $83C5 -- where the envelope starts, and where each leg of it
## hands over to the next.
func _8395() -> void:
	if (_bk(ATT) & 0xF0) != 0:
		_8386(_bk(ATT) & 0xF0, _bk(ATT))
		_sbk(ENV_L, 0x25)
		_sbk(ENV_H, 0x85)
		return
	_83AD()


func _83AD() -> void:
	if (_bk(DEC) & 0xF0) != 0:
		_8386(_bk(DEC) & 0xF0, _bk(DEC))
		_sbk(ENV_L, 0xAF)
		_sbk(ENV_H, 0x85)
		return
	_83C5()


func _83C5() -> void:
	_sbk(ENV_L, 0xF2)
	_sbk(ENV_H, 0x85)


## $871B -- a step of a stream of effects: either a period handed over whole,
## or, with nothing in the top nibble, a noise.
func _871B() -> void:
	_sbk(LEFT, _bk(UNIT))
	if (zp[EB] & 0xF0) != 0:
		_sbk(PER_L, _next())
		_87B6()
		var v := (((zp[EB] & 0xF0) >> 4) + 2 + _bk(TONE)) & 0xFF
		_sbk(OUT, v)
		_8CA6(v)
		_8CC8(_bk(PER_L))
		var top := (zp[EB] & 0x0F) | 0xC0
		if _bk(HARD) == 0 and top == _bk(PER_H):
			return
		_sbk(PER_H, top)
		_8CD9(top)
		return
	_87B6()                                 # $8772
	if zp[F8] == 0:
		_w(0x400C, zp[EB] | 0x30)
		return
	var d := (zp[EB] - zp[FA]) & 0xFF
	if d != 0:
		_w(0x400C, d | 0x30)
		return
	_w(0x400C, 0x30)                        # $878A -- faded out, so let go
	ram[0x0448] = 0


## $8ABA -- $E0 in a stream of effects: be quiet for so many pictures.
func _8ABA() -> void:
	_sbk(LEFT, _next())
	_87B6()
	if zp[EA] == 0x08:
		_w(0x4008, 0x00)
	else:
		_8CA6(0x30)


## $884D and $8861 -- the two tables of commands, read out of the cartridge.
func _884D() -> void:
	var x := (zp[EB] & 0x0F) << 1
	_op(_rd(0x8875 + x) | (_rd(0x8876 + x) << 8))


func _8861() -> void:
	var x := (zp[EB] & 0x0F) << 1
	_op(_rd(0x8895 + x) | (_rd(0x8896 + x) << 8))


## Every one of them, by the address the table gives.
func _op(at: int) -> void:
	match at:
		0x88B5:                             ## $F0 -- the outer loop starts
			_sbk(L1, _next())
			var s := _bk(SRC_L) + zp[E9]
			_sbk(L1_L, s & 0xFF)
			_sbk(L1_H, (_bk(SRC_H) + (s >> 8)) & 0xFF)
		0x88D5:                             ## $F1 -- and goes round
			var n := (_bk(L1) - 1) & 0xFF
			if n == 0:
				return
			_sbk(L1, n)
			zp[E9] = 0
			_sbk(SRC_L, _bk(L1_L))
			zp[E2] = _bk(L1_L)
			_sbk(SRC_H, _bk(L1_H))
			zp[E2 + 1] = _bk(L1_H)
		0x88FA:                             ## $F2 -- go there instead
			var lo := _at(zp[E9])
			var hi := _at(zp[E9] + 1)
			_sbk(SRC_H, hi)
			zp[E2 + 1] = hi
			_sbk(SRC_L, lo)
			zp[E2] = lo
			zp[E9] = 0
		0x8913:                             ## $F3 -- the inner loop starts
			_sbk(L2, _next())
			var s2 := _bk(SRC_L) + zp[E9]
			_sbk(L2_L, s2 & 0xFF)
			_sbk(L2_H, (_bk(SRC_H) + (s2 >> 8)) & 0xFF)
		0x8933:                             ## $F4 -- and goes round
			var n2 := (_bk(L2) - 1) & 0xFF
			if n2 == 0:
				return
			_sbk(L2, n2)
			zp[E9] = 0
			_sbk(SRC_L, _bk(L2_L))
			zp[E2] = _bk(L2_L)
			_sbk(SRC_H, _bk(L2_H))
			zp[E2 + 1] = _bk(L2_H)
		0x8958:                             ## $F5 -- call
			var y := zp[E9]
			var clo := _at(y)
			var chi := _at(y + 1)
			zp[E9] = (y + 2) & 0xFF
			var r := _bk(SRC_L) + zp[E9]
			_sbk(RET_L, r & 0xFF)
			_sbk(RET_H, (_bk(SRC_H) + (r >> 8)) & 0xFF)
			_sbk(SRC_H, chi)
			zp[E2 + 1] = chi
			_sbk(SRC_L, clo)
			zp[E2] = clo
			zp[E9] = 0
		0x898B:                             ## $F6 -- and come back
			var rhi := _bk(RET_H)
			_sbk(SRC_H, rhi)
			zp[E2 + 1] = rhi
			var rlo := _bk(RET_L)
			_sbk(SRC_L, rlo)
			zp[E2] = rlo
			zp[E9] = 0
		0x89A4:                             ## $F7 -- the sweep
			_sbk(SWEEP, _next())
			_8CB7(_bk(SWEEP))
			if _bk(SWEEP) == 0x88:
				_sbk(PER_H, 0)
				_sbk(HARD, 0x00)
			else:
				_sbk(HARD, 0xFF)
		0x89C9:                             ## $F8 -- detune
			_sbk(OFF, _next())
		0x89D4:                             ## $F9 -- the vibrato
			var y2 := zp[E9]
			var a2 := _at(y2)
			zp[ED] = _at(y2 + 1)
			zp[E9] = (y2 + 2) & 0xFF
			_sbk(V_WAIT, a2)
			_sbk(V_RATE, (zp[ED] & 0xF0) >> 4)
			_sbk(V_DEEP, zp[ED] & 0x0F)
		0x89F9:                             ## $FA -- volume and duty
			_sbk(TONE, _next())
		0x8A04:                             ## $FB -- the envelope's four
			var y3 := zp[E9]
			var b0 := _at(y3)
			var b1 := _at(y3 + 1)
			var b2 := _at(y3 + 2)
			var b3 := _at(y3 + 3)
			zp[E9] = (y3 + 4) & 0xFF
			_sbk(REL, b3)
			_sbk(HOLD, b2)
			_sbk(DEC, b1)
			_sbk(ATT, b0)
			_sbk(ENVON, 0xFF)
		0x8A2E:                             ## $FC -- and off again
			_sbk(ENVON, 0x00)
		0x8A35:                             ## $FD -- the unit of a note
			_sbk(UNIT, _next())
		0x8A40:                             ## $FE -- which kind of stream this is
			_sbk(KIND, _next())
		0x8A4B:                             ## $FF -- the end
			_8A4B()
		0x8ABA:                             ## $E0 -- a rest of so many pictures
			_8ABA()
		0x8AD8:                             ## $E1 -- the unit of a note
			_sbk(UNIT, _next())
		0x8AE3:                             ## $E2 -- the noise, handed over whole
			var p := _next()
			_sbk(PER_L, p)
			_w(0x400E, p)
			_w(0x400F, 0xC0)
		0x8AF6:                             ## $E3 -- volume and duty
			_sbk(TONE, _next())
		0x8B01:                             ## $E6 -- the attack takes its time
			_sbk(SLOW, 0xFF)
		0x8B08:                             ## $E7 -- and stops doing so
			_sbk(SLOW, 0x00)
		0x8B0F:                             ## $E8 -- how far back the echo reaches
			_sbk(ECHO, _next())
		0x8B1A:                             ## $E9 -- no echo
			_sbk(ECHO, 0x00)
		0x8B21:                             ## $EA -- the volume, without envelope
			_sbk(ENVON, 0x00)
			_8B27()
		0x8B3C:                             ## $EB -- the volume, with it
			_sbk(ENVON, 0xFF)
			_8B27()
		0x8B45:                             ## $EC -- the envelope, on
			_sbk(ENVON, 0xFF)
		_: pass                             ## $8B4B -- $E4, $E5, $ED, $EE, $EF


## $8B27 -- the low nibble of the volume, the duty left as it was.
func _8B27() -> void:
	zp[EB] = _next() & 0x0F
	_sbk(TONE, (_bk(TONE) & 0xF0) | zp[EB])


## $8A4B -- the stream ends: the voice is free and the channel is put back the
## way $8AA2 says it should be found.
func _8A4B() -> void:
	_sbk(PRIO, 0x00)
	if zp[EA] == 0x18:
		if ram[0x0448] == 0:
			_w(0x400C, 0x30)
		return
	if zp[EA] == 0x10:
		zp[FB] = 0xFF
	elif zp[EA] == 0x14:
		zp[FC] = 0xFF
	if zp[EA] == 0x0C:
		zp[FE] = 0xFF
	var y := zp[EA] & 0x1F
	_8CA6(_rd(0x8AA2 + y))
	_8CB7(_rd(0x8AA2 + y + 1))
	_8CC8(_rd(0x8AA2 + y + 2))
	_8CD9(_rd(0x8AA2 + y + 3))


## $8B4C -- the drum voice's note is not a note but a pattern out of $8C16.
func _8B4C() -> void:
	if ram[0x0448] != 0:
		return
	var x := (zp[EB] & 0xF0) >> 3
	_sbk(DRUM_L, _rd(0x8C16 + x))
	zp[E4] = _rd(0x8C16 + x)
	_sbk(DRUM_H, _rd(0x8C16 + x + 1))
	zp[E4 + 1] = _rd(0x8C16 + x + 1)
	_8BA6(true)


## $8B6F -- one picture of it.
func _8B6F() -> void:
	if ram[0x0448] != 0:
		return
	if zp[FE] != 0:
		zp[FE] = 0
		_w(0x400E, _bk(PER_L))
		_w(0x400F, 0xC0)
	var n := (_bk(BEAT_N) - 1) & 0xFF
	if n != 0:
		_sbk(BEAT_N, n)
		return
	zp[E4] = _bk(DRUM_L)
	zp[E4 + 1] = _bk(DRUM_H)
	if zp[E4 + 1] == 0:
		return
	_8BA6(true)


## $8BA6 -- the pattern, read until it strikes.
func _8BA6(restart: bool) -> void:
	if restart:
		zp[E9] = 0
	while true:
		zp[EB] = _peek((_ptr(E4) + zp[E9]) & 0xFFFF)
		zp[E9] = (zp[E9] + 1) & 0xFF
		if zp[EB] == 0xFF:
			_w(0x400C, 0x30)
			_w(0x400E, 0x00)
			_w(0x400F, 0x00)
			_sbk(DRUM_L, 0)
			_sbk(DRUM_H, 0)
			return
		var top := zp[EB] & 0xF0
		if top == 0x00:
			_sbk(BEAT_N, _bk(BEAT))
			_w(0x400C, zp[EB] | 0x30)
			var s := _bk(DRUM_L) + zp[E9]
			_sbk(DRUM_L, s & 0xFF)
			_sbk(DRUM_H, (_bk(DRUM_H) + (s >> 8)) & 0xFF)
			return
		if top == 0xE0:
			_sbk(BEAT, zp[EB] & 0x0F)
		elif top == 0xD0:
			_sbk(PER_L, zp[EB] & 0x0F)
			_w(0x400E, zp[EB] & 0x0F)
			_w(0x400F, 0xC0)


## $8CEA -- the tune's two squares ask before they write, and are refused
## while the sound's block beside them is taken.
func _8CEA(v: int) -> bool:
	zp[EC] = v & 0xFF
	if zp[EA] == 0x00:
		return ram[0x0470] != 0
	if zp[EA] == 0x04:
		return ram[0x0498] != 0
	return false


## $8CA6, $8CB7, $8CC8, $8CD9 -- the four registers of whichever channel
## $EA & $0F names.
func _8CA6(v: int) -> void:
	if not _8CEA(v):
		_w(0x4000 + (zp[EA] & 0x0F), zp[EC])


func _8CB7(v: int) -> void:
	if not _8CEA(v):
		_w(0x4001 + (zp[EA] & 0x0F), zp[EC])


func _8CC8(v: int) -> void:
	if not _8CEA(v):
		_w(0x4002 + (zp[EA] & 0x0F), zp[EC])


func _8CD9(v: int) -> void:
	if not _8CEA(v):
		_w(0x4003 + (zp[EA] & 0x0F), zp[EC])


## $8D06 -- a tune is asked for.  $9EC6 holds a header for each one.
func _8D06(n: int) -> void:
	var x := ((n - 1) << 1) & 0xFF
	zp[F0] = 0
	zp[F8] = 0
	zp[F9] = 0
	zp[FD] = 0
	zp[FA] = 0
	zp[E2] = _rd(0x9EC6 + x)
	zp[E2 + 1] = _rd(0x9EC6 + x + 1)
	_8D40()


## $8D2C -- and a sound, out of $8E41.
func _8D2C(n: int) -> void:
	var x := ((n - 1) << 1) & 0xFF
	zp[F1] = 0
	zp[E2] = _rd(0x8E41 + x)
	zp[E2 + 1] = _rd(0x8E41 + x + 1)
	_8D40()


## $8D40 -- the header: a bit a voice from the top, then what it is worth,
## then a stream for every bit that was set.
func _8D40() -> void:
	zp[F3] = _at(0)
	zp[F5] = _at(0) & 0x01
	zp[F4] = _at(1)
	zp[E8] = 2
	zp[EA] = 0
	zp[E0] = 0xD0
	zp[E0 + 1] = 0x03
	while true:
		var t := zp[F3] << 1
		zp[F3] = t & 0xFF
		if (t & 0x100) != 0:
			# $8D73 -- the first of the sound's squares is taken, so the
			# stream goes to the second instead.  The add that moves the
			# block along carries whatever the shift just left behind.
			if zp[EA] == 0x10 and ram[0x0470] != 0 and zp[F5] == 0:
				var c := (zp[F3] >> 7) & 0x01
				zp[F3] = (zp[F3] << 1) & 0xFF
				zp[EA] = 0x14
				var p := _ptr(E0) + 0x28 + c
				zp[E0] = p & 0xFF
				zp[E0 + 1] = (p >> 8) & 0xFF
			if _bk(PRIO) <= zp[F4]:         # $8D8E
				_8D98()
			else:
				zp[E8] = (zp[E8] + 2) & 0xFF
		zp[EA] = (zp[EA] + 4) & 0xFF        # $8E0D
		if zp[EA] == 0x1C:
			return
		var q := _ptr(E0) + 0x28
		zp[E0] = q & 0xFF
		zp[E0 + 1] = (q >> 8) & 0xFF


## $8D98 -- the voice is taken: everything of it forgotten, the channel set
## back to what $8E29 says it starts as, and the stream hung on it.
func _8D98() -> void:
	for y in range(0x27, -1, -1):
		_sbk(y, 0)
	_sbk(LEFT, 0x01)
	_sbk(SWEEP, 0x88)
	_sbk(PER_H, 0xFF)
	if zp[EA] == 0x18:
		if ram[0x0448] == 0:
			_w(0x400C, 0x30)
			_w(0x400E, 0x00)
			_w(0x400F, 0x00)
	else:
		var y2 := zp[EA]                    # $8DCE
		_8CA6(_rd(0x8E29 + y2))
		if _rd(0x8E29 + y2 + 1) != 0xFF:
			_8CB7(_rd(0x8E29 + y2 + 1))
		_8CC8(_rd(0x8E29 + y2 + 2))
		_8CD9(_rd(0x8E29 + y2 + 3))
	_sbk(PRIO, zp[F4])                      # $8DEE
	var lo := _at(zp[E8])
	var hi := _at(zp[E8] + 1)
	zp[E8] = (zp[E8] + 2) & 0xFF
	_sbk(SRC_H, hi)
	_sbk(SRC_L, lo)
	_sbk(FRESH, 0x01)


## $BE64 -- $0F: let the tune go, and leave the sounds alone.
func _BE64() -> void:
	zp[F0] = 0
	ram[0x03D0] = 0
	ram[0x03F8] = 0
	ram[0x0420] = 0
	ram[0x04C0] = 0
	zp[F5] = 0
	_w(0x4008, 0x00)
	if ram[0x0470] == 0:
		_w(0x4000, 0x30)
	if ram[0x0498] == 0:
		_w(0x4004, 0x30)
	if ram[0x0448] == 0:
		_w(0x400C, 0x30)


## $BE98 -- $22 in the other cell: let the sounds go.
func _BE98() -> void:
	zp[F1] = 0
	ram[0x0448] = 0
	ram[0x0470] = 0
	ram[0x0498] = 0
	_w(0x400C, 0x30)
	_w(0x4000, 0x30)
	_w(0x4004, 0x30)
	zp[FB] = 0x30
	zp[FC] = 0x30
	zp[FE] = 0x30


## $BEB7 -- $10: everything.
func _BEB7() -> void:
	zp[F0] = 0
	zp[F1] = 0
	ram[0x03D0] = 0
	ram[0x03F8] = 0
	ram[0x0420] = 0
	ram[0x0448] = 0
	ram[0x0470] = 0
	ram[0x0498] = 0
	ram[0x04C0] = 0
	zp[FB] = 0
	zp[FC] = 0
	zp[F5] = 0
	zp[F9] = 0
	_w(0x4008, 0x00)
	_w(0x4000, 0x30)
	_w(0x4004, 0x30)
	_w(0x400C, 0x30)
