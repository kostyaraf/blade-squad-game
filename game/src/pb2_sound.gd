extends RefCounted
class_name Pb2Sound

## Power Blade 2's sound driver, bank twelve.
##
## Two doors of the three are the sound:
##
##     $8000 -> $8009   ask for a number in A; $00 silences everything
##     $8003 -> $842B   one picture
##
## (The third, $8006, leads to $BA42, which is a routine of the game that
## happens to share the bank and reads none of this.)
##
## It is not a routine that plays a tune.  It is a small interpreter: eight
## channels, each with a pointer into a stream of bytes in this same bank, and
## a picture of it is "count one off every channel's note, and when a note
## runs out, read the stream until the next one".  A byte under $C0 is a note,
## $C0..$CF is a rest, and $D0..$FF are commands -- thirty two of them through
## the table at $83EB, which set the octave, the envelope, the vibrato, call
## and return, loop and stop.
##
## The eight channels are two sets of four: 0..3 are the tune and 4..7 are the
## sounds on top of it, and each pair shares one of the console's four
## channels ($4000, $4004, $4008, $400C by $8485's `(X * 4) & $0F`).  Which of
## the two is heard is decided by nothing more than "is a sound playing here"
## ($8460), and which sound gets in at all is decided by priority: $80AC
## compares what is being asked for with what the channel already holds and
## leaves the channel alone if the new one is worth less.  That is the thing a
## recording of each tune could never reproduce, and it is why Э6 ports the
## driver instead (`work/re/sound.md`).
##
## Channel 3 is not a channel of the console at all: $85EB sends it to $8584,
## which reads a number out of $9095 and asks the driver for it.  It is a
## track of drums written as requests.
##
## The memory is kept flat -- a page of zero page and the page at $0700 --
## because the cartridge's own indices overlap and the overlap is used: $07A8,X
## and $07AA,X are two apart and X runs to seven, so channel four's envelope
## shape is channel nought's second envelope byte.  Named fields would quietly
## take that away.
##
## `work/re/pb2_sound.md` says where each piece came from.

# Zero page.  $B2..$BF are the driver's scratch, $C0..$C7 the flags of each
# channel, $C8..$CF what number each is playing, and $DC..$EB a shadow of
# $4000..$400F so that the picture writes only what changed ($848E).
const B2 := 0xB2                           ## $B2:$B3 -- into the header table
const B4 := 0xB4                           ## how many channels the header names
const B5 := 0xB5                           ## the priority asked for
const B8 := 0xB8                           ## the number asked for
const B9 := 0xB9                           ## which channel is being walked
const BA := 0xBA                           ## $BA:$BB -- into the stream
const BC := 0xBC                           ## $BC:$BD -- into a table
const BE := 0xBE                           ## scratch
const BF := 0xBF                           ## scratch
const FLAG := 0xC0                         ## $C0,X
const PLAYS := 0xC8                         ## $C8,X -- the number playing here
const SHADOW := 0xDC                        ## $DC,Y -- what $4000,Y holds

# The page at $0700, by the low byte of the cartridge's own address.
const PRIO := 0x00                          ## $0700,X
const SRC_L := 0x08                         ## $0708,X -- the stream
const SRC_H := 0x10                         ## $0710,X
const UNIT := 0x18                          ## $0718,X -- how long a unit is
const TONE := 0x20                          ## $0720,X -- volume and duty
const LEFT := 0x28                          ## $0728,X -- left of this note
const INTO := 0x30                          ## $0730,X -- how far into it
const PER_L := 0x38                         ## $0738,X -- the note's period
const PER_H := 0x40                         ## $0740,X
const OCT := 0x48                           ## $0748,X -- the octave
const OFF := 0x50                           ## $0750,X -- detune
const RET_L := 0x58                         ## $0758,X -- where a call returns
const RET_H := 0x60                         ## $0760,X
const LOOP_L := 0x68                        ## $0768,X -- where a loop starts
const LOOP_H := 0x70                        ## $0770,X
const ROUND := 0x78                         ## $0778,X -- times round the loop
const LIFT := 0x80                          ## $0780,X -- added to the period
const R0 := 0x88                            ## $0788,X -- the $4000 byte
const R1 := 0x90                            ## $0790,X -- the $4001 byte
const R2 := 0x98                            ## $0798,X -- the $4002 byte
const R3 := 0xA0                            ## $07A0,X -- the $4003 byte
const ENV := 0xA8                           ## $07A8,X -- the envelope's shape
const ENV_R := 0xAA                         ## $07AA,X -- how fast it moves
const ENV_H := 0xAC                         ## $07AC,X -- when it turns
const ENV_D := 0xAE                         ## $07AE,X -- and how fast it falls
const BEND := 0xB0                          ## $07B0,X -- into the bend table
const BEND_N := 0xB3                        ## $07B3,X -- left of this step
const BEND_L := 0xB8                        ## $07B8,X -- the bend table
const BEND_H := 0xBB                        ## $07BB,X
const QUIET := 0xBE                         ## $07BE
const DOWN := 0xBF                          ## $07BF -- taken off every volume
const SHAPE := 0xC0                         ## $07C0,X -- into the shape table
const SHAPE_N := 0xC2                       ## $07C2,X -- left of this step
const SHAPE_L := 0xC4                       ## $07C4,X -- the shape table
const SHAPE_H := 0xC6                       ## $07C6,X
const FALL := 0xC8                          ## $07C8,X -- the envelope's counter
const FELL := 0xCA                          ## $07CA,X -- how far it has fallen
const BEND_M := 0xCC                        ## $07CC,X -- the bend's loop mark
const VOL := 0xD0                           ## $07D0,X -- the volume decided
const BENT_L := 0xD2                        ## $07D2,X -- the bent period
const BENT_H := 0xD5                        ## $07D5,X
const FLOOR := 0xD8                         ## $07D8,X -- the quietest allowed
const SET := 0xDA                           ## $07DA -- which set of drums
const HUSH := 0xDB                          ## $07DB -- the game's own pause
const V_STEP := 0xE0                        ## $07E0,X -- vibrato
const V_LEFT := 0xE3                        ## $07E3,X
const V_RATE := 0xE8                        ## $07E8,X
const V_ACC_L := 0xEB                       ## $07EB,X
const V_MARK := 0xEE                        ## $07EE,X
const V_ACC_H := 0xF0                       ## $07F0,X
const V_ON := 0xF3                          ## $07F3,X
const SHAPE_M := 0xF6                       ## $07F6,X -- the shape's loop mark
const V_CUR_L := 0xF8                       ## $07F8,X
const V_CUR_H := 0xFB                       ## $07FB,X
const SOFT := 0xFE                          ## $07FE,X -- taken off the shape

var apu: SndApu
var rom: PackedByteArray
var zp := PackedByteArray()
var p7 := PackedByteArray()                 ## $0700, and the page after it
var paused := 0                             ## $4D -- the game's own pause flag
var _y := 0                                 ## the Y the walk keeps its place in


func _init(a: SndApu) -> void:
	apu = a
	rom = SndRom.window("pb2")
	zp.resize(0x100)
	# $07FE,X with X up to seven reaches $0805, so the page the cartridge
	# keeps this in is not the whole of it.
	p7.resize(0x200)


## The two banks, read at the cartridge's own addresses.
func _rd(a: int) -> int:
	return rom[(a - 0x8000) & 0x3FFF]


## ($BA),Y and its like: a pointer held in two cells of zero page.
func _thru(at: int, y: int) -> int:
	return _rd(((zp[at] | (zp[at + 1] << 8)) + y) & 0xFFFF)


func _w(a: int, v: int) -> void:
	apu.w(a, v & 0xFF)


## What the cartridge's own boot does before anything is asked.
func boot() -> void:
	ask(0)


## $8009 -- a number is asked for.
func ask(n: int) -> void:
	zp[B8] = n & 0xFF
	if zp[B8] == 0:
		_803E()
		for i in range(7, -1, -1):          # $8022
			_8129(i)
		p7[0xE6] = 0                        # $07E6
		p7[DOWN] = 0
		p7[QUIET] = 0
		p7[0x54] = 0                        # $0754
		p7[0x55] = 0                        # $0755
		return
	if zp[B8] < 0x4C:                       # $8013
		_807B()


## $803E -- everything quiet, and the shadow told so.
func _803E() -> void:
	for a in [0x4000, 0x4004, 0x400C]:
		_w(a, 0x30)
	zp[SHADOW] = 0x30
	zp[SHADOW + 4] = 0x30
	zp[SHADOW + 12] = 0x30
	_w(0x4008, 0x00)
	zp[SHADOW + 8] = 0x00
	_w(0x400A, 0xFF)
	zp[SHADOW + 10] = 0xFF
	_w(0x4001, 0x7F)
	_w(0x4005, 0x7F)
	zp[SHADOW + 1] = 0x7F
	zp[SHADOW + 5] = 0x7F
	_w(0x4003, 0xFF)
	_w(0x4007, 0xFF)
	_w(0x400B, 0xFF)
	zp[SHADOW + 3] = 0xFF
	zp[SHADOW + 7] = 0xFF
	zp[SHADOW + 11] = 0xFF


## $807B -- give the number's channels to it, as far as priority lets.
##
## $8AE9 holds a pointer for each of the $4B numbers.  Its first byte is the
## priority in the low six bits and, in the top two, one less than the number
## of channels that follow; each of those is a channel and a stream, unless
## bit three is set, which means a sample instead ($815B).
func _807B() -> void:
	var y := (zp[B8] << 1) & 0xFF
	zp[B2] = _rd(0x8AE9 + y)
	zp[B2 + 1] = _rd(0x8AEA + y)
	y = 0
	var head := _thru(B2, y)
	zp[B4] = (head >> 6) & 0x03             # $808D -- CLC and three ROLs
	zp[B5] = head & 0x3F
	while true:                             # $809B
		y += 1
		var a := _thru(B2, y)
		if (a & 0x08) != 0:
			y = _815B(y)
		else:
			var x := a & 0x07
			if zp[B5] >= p7[PRIO + x]:      # $80AC
				_8129(x)
				p7[PRIO + x] = zp[B5]
				zp[FLAG + x] = _thru(B2, y) & 0x80
				zp[PLAYS + x] = zp[B8]
				y += 1
				p7[SRC_L + x] = _thru(B2, y)
				y += 1
				p7[SRC_H + x] = _thru(B2, y)
				_80DC(x)
			else:
				y += 2                      # $80D8
		zp[B4] = (zp[B4] - 1) & 0xFF        # $80D3
		if zp[B4] >= 0x80:
			return


## $815B -- a sample: four bytes handed straight to the console.
func _815B(y: int) -> int:
	_w(0x4015, 0x0F)
	y += 1
	zp[BC] = _thru(B2, y)
	y += 1
	zp[BC + 1] = _thru(B2, y)
	for i in range(4):
		_w(0x4010 + i, _thru(BC, i))
	_w(0x4015, 0x1F)
	return y


## $80DC -- quiet the console channel this one shares, unless the sound on top
## of it is still playing ($80E5 reads $CC,X, which is $C8 of channel X + 4).
func _80DC(a: int) -> void:
	if a == 3:
		return
	if a < 4:
		if zp[0xCC + a] != 0:
			return
	a &= 0x03
	if a == 2:
		_w(0x400A, 0xFF)
		_w(0x400B, 0xFF)
		zp[SHADOW + 10] = 0xFF
		zp[SHADOW + 11] = 0xFF
		_w(0x4008, 0x00)
		_w(0x4009, 0x00)
		zp[SHADOW + 8] = 0x00
		zp[SHADOW + 9] = 0x00
		return
	var x := a << 2
	_w(0x4000 + x, 0x30)
	zp[SHADOW + x] = 0x30
	_w(0x4001 + x, 0x7F)
	zp[SHADOW + x + 1] = 0x7F
	_w(0x4002 + x, 0x00)
	zp[SHADOW + x + 2] = 0x00
	_w(0x4003 + x, 0xFF)
	zp[SHADOW + x + 3] = 0xFF


## $8129 -- a channel emptied out.
func _8129(x: int) -> void:
	if x < 3:
		p7[LIFT + x] = 0
		p7[OFF + x] = 0
		p7[V_ON + x] = 0
		p7[SOFT + x] = 0
	zp[PLAYS + x] = 0
	p7[PRIO + x] = 0
	zp[FLAG + x] = 0
	p7[INTO + x] = 0
	p7[ROUND + x] = 0
	p7[LEFT + x] = 1
	zp[FLAG + x] = zp[FLAG + x] & 0xFE
	p7[R1 + x] = 0x7F


## $842B -- one picture.
##
## Two passes.  The first walks all eight channels and lets each one count a
## picture off its note ($84FD); the second walks channels four to seven and
## writes the four console channels, taking each from the sound if a sound is
## playing there and from the tune if not ($8460).
func tick() -> void:
	_84EA()
	for x in range(8):                      # $8432
		zp[B9] = x
		var a := zp[PLAYS + x]
		if a == 0:
			continue
		if p7[HUSH] == 0 or a == 0x30 or a == 0x1F or a == 0x17:
			_84FD(x)
	for x in range(4, 8):                   # $8457
		zp[BE] = x
		zp[BF] = x & 0x03
		var ch := x
		var a := zp[PLAYS + ch]
		if a == 0:
			ch = zp[BF]
			a = zp[PLAYS + ch]
			if a == 0:
				continue
		if not (a == 0x30 or a == 0x1F or a == 0x17):
			if p7[HUSH] != 0:
				continue
		if (zp[FLAG + ch] & 0x02) != 0:     # $847B -- resting
			continue
		if ch == 3:                         # the drums write no registers
			continue
		var y := (ch << 2) & 0x0F
		if p7[R0 + ch] != zp[SHADOW + y]:   # $848B
			_w(0x4000 + y, p7[R0 + ch])
			zp[SHADOW + y] = p7[R0 + ch]
		if p7[R1 + ch] != zp[SHADOW + y + 1]:
			_w(0x4001 + y, p7[R1 + ch])
			zp[SHADOW + y + 1] = p7[R1 + ch]
		# $84A7 -- with bit nought set the low byte is written again at the
		# start of a note even when it has not changed, because $4003 is what
		# restarts the note and $4002 has to be under it.
		var force := (zp[FLAG + ch] & 0x01) != 0 and p7[INTO + ch] == 0
		if force or p7[R2 + ch] != zp[SHADOW + y + 2]:
			_w(0x4002 + y, p7[R2 + ch])
			zp[SHADOW + y + 2] = p7[R2 + ch]
		if p7[INTO + ch] != 0 and p7[R3 + ch] == zp[SHADOW + y + 3]:
			continue                        # $84D0
		_w(0x4003 + y, p7[R3 + ch])
		zp[SHADOW + y + 3] = p7[R3 + ch]


## $84EA -- the game's own pause.  $4D going from nought to anything silences
## the console once; three numbers go on playing through it ($843F).
func _84EA() -> void:
	var a := paused & 0xFF
	if a == p7[HUSH]:
		return
	p7[HUSH] = a
	if a != 0:
		_803E()


## $84FD -- one picture of one channel: a picture further into the note, one
## less of it left, and when none is left the stream says what comes next.
func _84FD(x: int) -> void:
	if p7[HUSH] != 0:
		var a := zp[PLAYS + x]
		if not (a == 0x30 or a == 0x1F or a == 0x17):
			return
	p7[INTO + x] = (p7[INTO + x] + 1) & 0xFF
	p7[LEFT + x] = (p7[LEFT + x] - 1) & 0xFF
	if p7[LEFT + x] != 0:
		_8537(x)
		return
	_walk(x, 0x851B)


## $8537 -- the note goes on: the envelope moves, the bend moves, the vibrato
## moves.  Only channels nought, one, two and their two sounds have any of it.
func _8537(x: int) -> void:
	if x != 2:
		if (x & 0x02) != 0:
			return
		if (zp[FLAG + x] & 0x80) != 0:      # a raw stream keeps its own bytes
			return
		_8966(x)                            # $8545
		p7[R0 + x] = _894F(x) | p7[VOL + x]
	if (zp[FLAG + x] & 0x04) != 0:          # $8551 -- sliding
		_8743(x)
		p7[R2 + x] = p7[BENT_L + x]
		p7[R3 + x] = p7[BENT_H + x] | 0xF8
	var v := p7[V_ON + x]                   # $8568
	if v != 0 and (v & 0x04) != 0:
		_8864(x)


## The walk of a channel's stream, from label to label as the cartridge jumps.
## Four places are jumped back to, so they are the labels; everything between
## them is straight.
func _walk(x: int, at: int) -> void:
	while at != 0:
		match at:
			0x851B:                         # the stream, from where it stopped
				zp[BA] = p7[SRC_L + x]
				zp[BA + 1] = p7[SRC_H + x]
				_y = 0
				at = 0x8527
			0x8527:                         # $8527 -- which of the two formats
				at = 0x86F5 if (zp[FLAG + x] & 0x80) != 0 else 0x852E
			0x852E:                         # $852E -- a note or a command
				var a := _thru(BA, _y)
				at = _818F(x, a) if a >= 0xD0 else _85B8(x)
			0x86F5:
				at = _86F5(x)
			_:
				at = 0


## $85B8 -- a note.  Its low nibble is how many units long it is, counted by
## adding the unit four times over by its bits; nought means "as before".
func _85B8(x: int) -> int:
	var a := 0
	while true:
		a = _thru(BA, _y) & 0x0F
		if a != 0:
			zp[BE] = a
			zp[BF] = p7[UNIT + x]
			a = 0
			for _i in range(4):             # $85C9
				var c := zp[BF] & 1
				zp[BF] = zp[BF] >> 1
				if c != 0:
					a = (a + zp[BE]) & 0xFF
				zp[BE] = (zp[BE] << 1) & 0xFF
			break
		a = (p7[UNIT + x] << 4) & 0xFF      # $85AF
		if a != 0:
			break
	p7[LEFT + x] = a                        # $85D7
	p7[INTO + x] = 0
	var b := _thru(BA, _y)
	if b >= 0xC0:
		return _8575(x)                     # $C0..$CF is a rest
	zp[FLAG + x] = zp[FLAG + x] & 0xFD
	if x == 3:
		return _8584(x)                     # the drums
	# $85EF -- the octave, twelve semitones at a time up to the fifth.
	var t := p7[OCT + x]
	a = 0
	while t != 5:
		a = (a + 0x0C) & 0xFF
		t = (t + 1) & 0xFF
		if a == 0:
			break
	zp[BE] = a                              # $85FF
	_8687(x)
	a = (_thru(BA, _y) & 0xF0) >> 3
	zp[BE] = (zp[BE] << 1) & 0xFF
	a = (a + zp[BE]) & 0xFF
	zp[BE] = _y
	var lo := _rd(0x8A41 + a) + p7[LIFT + x]
	p7[PER_L + x] = lo & 0xFF
	p7[PER_H + x] = (_rd(0x8A42 + a) + (1 if lo > 0xFF else 0)) & 0xFF
	_y = zp[BE]
	if x == 2:                              # $8681 -- the triangle has no
		return _8641(x, p7[TONE + x])       # volume of its own
	if (x & 0x02) != 0:
		return 0
	if (zp[FLAG + x] & 0x08) == 0:
		return _86A0(x)
	_87ED(x)
	return _8641(x, _894F(x) | p7[VOL + x])  # $863B


## $8641 -- the four bytes of the console channel made up, and the stream's
## place kept ($8671).
func _8641(x: int, r0: int) -> int:
	p7[R0 + x] = r0 & 0xFF
	var hi := 0
	if (zp[FLAG + x] & 0x04) != 0:          # sliding: the bend says the period
		_8734(x)
		p7[R2 + x] = p7[BENT_L + x]
		hi = p7[BENT_H + x]
	else:
		p7[R2 + x] = p7[PER_L + x]          # $8659
		hi = p7[PER_H + x]
	p7[R3 + x] = hi | 0xF8
	if (p7[V_ON + x] & 0x01) != 0:
		_8870(x)
	return _8671(x)


## $8671 -- the stream's place, one past the byte just read.
func _8671(x: int) -> int:
	_y += 1
	var at := (_y + (zp[BA] | (zp[BA + 1] << 8))) & 0xFFFF
	p7[SRC_L + x] = at & 0xFF
	p7[SRC_H + x] = (at >> 8) & 0xFF
	return 0


## $8575 -- a rest: the channel is marked resting and the console channel it
## shares is quieted, unless a sound is still on it.
func _8575(x: int) -> int:
	zp[FLAG + x] = zp[FLAG + x] | 0x02
	_80DC(x)
	return _8671(x)


## $8584 -- channel three's note is not a note: its top nibble picks a drum out
## of $9095, twelve to a set, and the driver is asked for that number.
func _8584(x: int) -> int:
	var a := _thru(BA, _y) >> 4
	var t := p7[SET]
	while true:
		t = (t - 1) & 0xFF
		if t >= 0x80:
			break
		a = (a + 0x0C) & 0xFF
		if a == 0:
			break
	zp[BE] = _y                             # $8595
	zp[B8] = _rd(0x9095 + a)
	if p7[0x55] == 0:                       # $0755 -- the drums shut off
		_807B()
	_y = zp[BE]
	return _8671(x)


## $8687 -- detune, four bits of it, up or down by bit seven.
func _8687(x: int) -> void:
	var a := p7[OFF + x]
	if a >= 0x80:
		a = (a & 0x0F) ^ 0xFF
		zp[BE] = (a + zp[BE]) & 0xFF
		zp[BE] = (zp[BE] + 1) & 0xFF
		return
	zp[BE] = ((a & 0x0F) + zp[BE]) & 0xFF


## $86A0 -- a note with no shape table of its own gets the driver's own
## envelope: the first of its three parts, which falls from the top by $07AA.
func _86A0(x: int) -> int:
	zp[FLAG + x] = (zp[FLAG + x] & 0xCF) | 0x10
	p7[FALL + x] = p7[ENV_R + x] & 0x0F
	var a := p7[ENV + x]
	if a >= 0x80:                           # $86DD
		zp[BE] = a >> 4
		a = (p7[ENV + x] & 0x0F) - zp[BE]
		if a < 0:
			a = 1
		p7[VOL + x] = a
		return _8641(x, _894F(x) | p7[VOL + x])
	var s := ((a << 4) & 0xFF) + a          # $86B5
	a = 0xF0 if s > 0xFF else s
	p7[VOL + x] = _86CE(x, a >> 4)
	return _8641(x, _894F(x) | p7[VOL + x])


## $86CE -- every volume is taken down by $07BF and never below $07D8,X.
func _86CE(x: int, a: int) -> int:
	var d := a - p7[DOWN]
	if d < 0 or d < p7[FLOOR + x]:
		return p7[FLOOR + x]
	return d


## $894F -- the duty and the volume, as the $4000 byte wants them.
func _894F(x: int) -> int:
	if p7[INTO + x] != 0:
		var a := p7[TONE + x] & 0x0F
		if a != 0:
			return (a << 4) & 0xFF
	return p7[TONE + x] & 0xF0


## $86F5 -- the other format: bytes handed to the console almost as they are.
## A top nibble of nought is a header ($83BE) and $F8 and up are commands.
func _86F5(x: int) -> int:
	var a := _thru(BA, _y)
	if (a & 0xF0) == 0:                     # $83BE
		p7[UNIT + x] = a
		_y += 1
		p7[TONE + x] = _thru(BA, _y)
		_y += 1
		_83D1(x)
		_y += 1
		return 0x86F5
	if a >= 0xF8:
		return _818F(x, a)
	p7[R0 + x] = (p7[TONE + x] & 0xF0) | (a >> 4)
	p7[R3 + x] = (a & 0x07) | 0xF8
	_y += 1
	p7[R2 + x] = _thru(BA, _y)
	p7[LEFT + x] = p7[UNIT + x]
	p7[INTO + x] = 0
	return _8671(x)


## $83D1 -- the sweep byte, and with bit seven the channel is told to write
## $4002 again at the start of every note.
func _83D1(x: int) -> void:
	var a := _thru(BA, _y)
	p7[R1 + x] = a
	if a >= 0x80:
		zp[FLAG + x] = zp[FLAG + x] | 0x01
		return
	zp[FLAG + x] = zp[FLAG + x] & 0xFE
	p7[R1 + x] = 0x7F


## $818F -- a command.  $D0..$DF carry the unit of length and what follows it;
## $E0..$FF are the thirty two of the table at $83EB.
func _818F(x: int, a: int) -> int:
	if a < 0xE0:
		return _81A9(x, a)
	var to := _rd(0x83EB + ((a - 0xE0) << 1))
	to |= _rd(0x83EC + ((a - 0xE0) << 1)) << 8
	var b := _thru(BA, _y)
	match to:
		0x81DE:                             # nothing but the byte itself
			_y += 1
			return 0x852E
		0x8211:                             # $E0..$E5 -- the octave
			p7[OCT + x] = b & 0x0F
			_y += 1
			return 0x852E
		0x8218:                             # $E8 -- the envelope's shape
			_y += 1
			p7[ENV + x] = _thru(BA, _y)
			zp[FLAG + x] = zp[FLAG + x] & 0xF7
			_y += 1
			return 0x852E
		0x8228:                             # $E9 -- how fast it moves
			_y += 1
			p7[ENV_R + x] = _thru(BA, _y) & 0x1F
			zp[FLAG + x] = zp[FLAG + x] & 0xF7
			_y += 1
			return 0x852E
		0x823A:                             # $EA -- when it turns, and its fall
			_y += 1
			p7[ENV_D + x] = _thru(BA, _y)
			_y += 1
			p7[ENV_H + x] = _thru(BA, _y)
			zp[FLAG + x] = zp[FLAG + x] & 0xF7
			_y += 1
			return 0x852E
		0x8250:                             # $EB -- the bend table, or none
			return _8250(x)
		0x828D:                             # $EC -- detune
			_y += 1
			p7[OFF + x] = _thru(BA, _y)
			_y += 1
			return 0x8527
		0x8297:                             # $EE -- added to every period
			_y += 1
			p7[LIFT + x] = _thru(BA, _y)
			_y += 1
			return 0x8527
		0x82A1:                             # $F0 -- the quietest allowed
			_y += 1
			if x < 2:
				p7[FLOOR + x] = _thru(BA, _y) & 0x0F
			_y += 1
			return 0x8527
		0x82B3:                             # $EF and $F1 -- which set of drums
			_y += 1
			p7[SET] = _thru(BA, _y)
			_y += 1
			return 0x852E
		0x82BD:                             # $F2 -- vibrato one way
			p7[V_ON + x] = 1
			return _82CA(x)
		0x82C5:                             # $F3 -- and the other
			p7[V_ON + x] = 3
			return _82CA(x)
		0x81E9:                             # $F4 -- a shape table of its own
			return _81E9(x)
		0x831D:                             # $F5 -- taken off the shape
			_y += 1
			p7[SOFT + x] = _thru(BA, _y)
			_y += 1
			return 0x852E
		0x8327:                             # $F8 -- the unit of length
			_y += 1
			p7[UNIT + x] = _thru(BA, _y)
			_y += 1
			return 0x8527
		0x8331:                             # $F9 -- volume and duty
			_y += 1
			p7[TONE + x] = _thru(BA, _y)
			_y += 1
			return 0x8527
		0x833B:                             # $FA -- the sweep byte
			_y += 1
			_83D1(x)
			_y += 1
			return 0x8527
		0x8343:                             # $FB -- a loop starts here
			_y += 1
			var at := (_y + (zp[BA] | (zp[BA + 1] << 8))) & 0xFFFF
			p7[LOOP_L + x] = at & 0xFF
			p7[LOOP_H + x] = (at >> 8) & 0xFF
			return 0x8527
		0x8355:                             # $FC -- back from a call
			zp[BA] = p7[RET_L + x]
			zp[BA + 1] = p7[RET_H + x]
			# No ,X: the cartridge clears the bit in channel nought's flags
			# whichever channel returns.  Nothing reads it.
			zp[FLAG] = zp[FLAG] & 0xBF
			_y = 0
			return 0x8527
		0x836A:                             # $FD -- a call
			_y += 1
			p7[SRC_L + x] = _thru(BA, _y)
			_y += 1
			p7[SRC_H + x] = _thru(BA, _y)
			zp[FLAG + x] = zp[FLAG + x] | 0x40
			_y += 1
			var back := (_y + (zp[BA] | (zp[BA + 1] << 8))) & 0xFFFF
			p7[RET_L + x] = back & 0xFF
			p7[RET_H + x] = (back >> 8) & 0xFF
			return 0x851B
		0x838F:                             # $FE -- round the loop again
			return _838F(x)
		0x83B6:                             # $FF -- the stream ends
			_8129(x)
			_80DC(x)
			return 0
	return 0


## $81A9 -- $D0..$DF: the unit of length, and after it the volume and, unless
## the channel is the triangle, either the driver's own envelope or a shape.
func _81A9(x: int, a: int) -> int:
	p7[UNIT + x] = a & 0x0F
	if x == 3:                              # $81E2 -- the drums take no more
		p7[SET] = 0
		_y += 1
		return 0x852E
	_y += 1
	p7[TONE + x] = _thru(BA, _y)
	if x == 2:                              # $81DE
		_y += 1
		return 0x852E
	_y += 1
	if _thru(BA, _y) == 0:
		return _81E9(x)
	p7[ENV + x] = _thru(BA, _y)
	zp[FLAG + x] = zp[FLAG + x] & 0xF7
	_y += 1
	p7[ENV_R + x] = _thru(BA, _y) & 0x1F
	_y += 1
	p7[ENV_D + x] = _thru(BA, _y)
	_y += 1
	p7[ENV_H + x] = _thru(BA, _y)
	_y += 1
	return 0x852E


## $81E9 -- a shape table out of $8DA7 instead of the driver's own envelope.
func _81E9(x: int) -> int:
	_y += 1
	var a := _thru(BA, _y)
	zp[BF] = _y
	var i := (a & 0x3F) << 1
	zp[BC] = _rd(0x8DA7 + i)
	p7[SHAPE_L + x] = zp[BC]
	zp[BC + 1] = _rd(0x8DA8 + i)
	p7[SHAPE_H + x] = zp[BC + 1]
	zp[FLAG + x] = zp[FLAG + x] | 0x08
	_y = zp[BF] + 1
	return 0x852E


## $8250 -- the bend table out of $8ECC; a nought turns bending off.
func _8250(x: int) -> int:
	_y += 1
	var a := _thru(BA, _y)
	if a == 0:                              # $8283
		zp[FLAG + x] = zp[FLAG + x] & 0xFB
		_y += 1
		return 0x852E
	zp[BE] = (a << 1) & 0xFF
	_y += 1
	p7[BEND_M + x] = _thru(BA, _y)
	zp[BF] = _y
	var i := zp[BE]
	zp[BC] = _rd(0x8ECC + i)
	p7[BEND_L + x] = zp[BC]
	zp[BC + 1] = _rd(0x8ECD + i)
	p7[BEND_H + x] = zp[BC + 1]
	p7[BEND + x] = 0
	zp[FLAG + x] = zp[FLAG + x] | 0x04
	_y = zp[BF] + 1
	return 0x852E


## $82CA -- vibrato: how fast and how long, and the two multiplied out into
## the sixteen bit step the note is moved by.
func _82CA(x: int) -> int:
	_y += 1
	var a := _thru(BA, _y)
	if a == 0:                              # $8305 -- off
		p7[V_ACC_H + x] = 0
		p7[V_ACC_L + x] = 0
		p7[V_ON + x] = 0
		p7[V_STEP + x] = 0
		p7[V_LEFT + x] = 0
		p7[V_RATE + x] = 0
		_y += 1
		return 0x852E
	p7[V_RATE + x] = a
	_y += 1
	p7[V_STEP + x] = _thru(BA, _y)
	_y += 1
	zp[BF] = _y
	p7[V_ACC_L + x] = 0
	p7[V_ACC_H + x] = 0
	var n := p7[V_STEP + x]
	if n == 0:
		n = 256
	for _i in range(n):                     # $82E9
		var s := p7[V_RATE + x] + p7[V_ACC_L + x]
		p7[V_ACC_L + x] = s & 0xFF
		if s > 0xFF:
			p7[V_ACC_H + x] = (p7[V_ACC_H + x] + 1) & 0xFF
	_y = zp[BF]
	return 0x852E


## $838F -- the loop: one more time round unless the count is up.
func _838F(x: int) -> int:
	_y += 1
	var a := _thru(BA, _y)
	if a < 0x80:
		p7[ROUND + x] = (p7[ROUND + x] + 1) & 0xFF
	if p7[ROUND + x] < _thru(BA, _y):       # $839C
		zp[BA] = p7[LOOP_L + x]
		zp[BA + 1] = p7[LOOP_H + x]
		_y = 0
		return 0x8527
	p7[ROUND + x] = 0
	_y += 1
	return 0x8527


## $8966 -- a picture of the volume.  Either a shape table walks itself
## ($8805) or the driver's own envelope moves through its three parts, which
## bits four and five of the flags keep the place in.
func _8966(x: int) -> void:
	if (zp[FLAG + x] & 0x08) != 0:
		_8805(x)
		return
	match zp[FLAG + x] & 0x30:
		0x10:
			_8983(x)
		0x20:
			_89E8(x)
		0x30:
			_8A0C(x)


## $87ED -- a shape table started again from its beginning.
func _87ED(x: int) -> void:
	if (zp[FLAG + x] & 0x08) == 0:
		return
	p7[SHAPE + x] = 0xFF
	p7[SHAPE_N + x] = 1
	p7[SHAPE_M + x] = 0
	p7[V_MARK + x] = 0
	_8805(x)


## $8805 -- one step of a shape table, when this step's count runs out.
func _8805(x: int) -> void:
	p7[SHAPE_N + x] = (p7[SHAPE_N + x] - 1) & 0xFF
	if p7[SHAPE_N + x] != 0:
		return
	p7[SHAPE + x] = (p7[SHAPE + x] + 1) & 0xFF
	_880D(x)


## $880D -- read the table until a step that is a volume.  $FB marks a place
## to come back to, $FE counts a return to it, $FF stops.
func _880D(x: int) -> void:
	while true:
		zp[BE] = _y
		zp[BC] = p7[SHAPE_L + x]
		zp[BC + 1] = p7[SHAPE_H + x]
		var i := p7[SHAPE + x]
		var a := _thru(BC, i)
		if a == 0xFB:                       # $8856
			_y = zp[BE]
			p7[SHAPE + x] = (p7[SHAPE + x] + 1) & 0xFF
			p7[SHAPE_M + x] = p7[SHAPE + x]
			continue
		if a == 0xFE:                       # $87C0
			i += 1
			var n := _thru(BC, i)
			if n < 0x80:
				p7[V_MARK + x] = (p7[V_MARK + x] + 1) & 0xFF
			if p7[V_MARK + x] < _thru(BC, i):
				p7[SHAPE + x] = p7[SHAPE_M + x]
			else:                           # $87DA
				p7[V_MARK + x] = 0
				p7[SHAPE + x] = (p7[SHAPE + x] + 2) & 0xFF
			_y = zp[BE]
			continue
		if a == 0xFF:                       # $8850
			_y = zp[BE]
			p7[SHAPE_N + x] = 0xFF
			return
		p7[SHAPE_N + x] = (a >> 4) & 0x0F
		p7[VOL + x] = a & 0x0F
		if p7[SOFT + x] != 0:               # $883A
			var v := p7[VOL + x] - p7[SOFT + x]
			p7[VOL + x] = 1 if v < 0 else v
		_y = zp[BE]
		return


## $8734 -- a bend started again from its beginning.
func _8734(x: int) -> void:
	p7[BEND + x] = 0xFF
	p7[BEND_M + x] = 0
	p7[BEND_N + x] = 1
	_8743(x)


## $8743 -- one step of a bend.  The top nibble is how far, under eight up and
## over eight down; the low nibble is how many pictures it holds for.
func _8743(x: int) -> void:
	p7[BEND_N + x] = (p7[BEND_N + x] - 1) & 0xFF
	if p7[BEND_N + x] != 0:
		return
	p7[BEND + x] = (p7[BEND + x] + 1) & 0xFF
	while true:                             # $874B
		var a := _87AC(x)
		zp[BF] = a
		if a == 0xFB:                       # $8797 -- a place to come back to
			p7[BEND + x] = (p7[BEND + x] + 1) & 0xFF
			p7[BEND_M + x] = p7[BEND + x]
			continue
		if a == 0xFE:                       # $87A3 -- and back to it
			p7[BEND + x] = p7[BEND_M + x]
			continue
		if a == 0xFF:                       # $877B -- held for ever
			p7[BEND_N + x] = 0xFF
			return
		p7[BEND_N + x] = a & 0x0F
		var d := zp[BF] >> 4
		if d >= 8:                          # $877F -- down
			var off := ((d ^ 0x0F) + 1) & 0xFF
			var s := p7[PER_L + x] - off
			p7[BENT_L + x] = s & 0xFF
			p7[BENT_H + x] = (p7[PER_H + x] - (1 if s < 0 else 0)) & 0xFF
			return
		var t := d + p7[PER_L + x]
		p7[BENT_L + x] = t & 0xFF
		p7[BENT_H + x] = (p7[PER_H + x] + (1 if t > 0xFF else 0)) & 0xFF
		return


## $87AC -- the byte the bend is standing on.
func _87AC(x: int) -> int:
	zp[BE] = _y
	zp[BC] = p7[BEND_L + x]
	zp[BC + 1] = p7[BEND_H + x]
	var a := _thru(BC, p7[BEND + x])
	_y = zp[BE]
	return a


## $8870 -- vibrato, from the note outwards; $8864 carries it on afterwards.
## $07F3 bit one says which way it starts and bit two that it has begun.
func _8870(x: int) -> void:
	zp[BE] = _y
	p7[V_LEFT + x] = (p7[V_STEP + x] + 1) & 0xFF
	p7[V_ON + x] = p7[V_ON + x] | 0x08
	if (p7[V_ON + x] & 0x02) == 0:
		_88D5(x)
		return
	if (p7[V_ON + x] & 0x04) != 0:
		_88AD(x)
		return
	var s := p7[PER_L + x] - p7[V_ACC_L + x]
	p7[V_CUR_L + x] = s & 0xFF
	p7[V_CUR_H + x] = (p7[PER_H + x] - p7[V_ACC_H + x]
					   - (1 if s < 0 else 0)) & 0xFF
	p7[V_ON + x] = p7[V_ON + x] | 0x04
	_88BF(x)


## $8864 -- the picture after: on up or on down, by whichever half it is in.
func _8864(x: int) -> void:
	zp[BE] = _y
	if (p7[V_ON + x] & 0x02) != 0:
		_88AD(x)
		return
	_88FA(x)


func _88AD(x: int) -> void:
	var s := p7[V_CUR_L + x] + p7[V_RATE + x]
	p7[V_CUR_L + x] = s & 0xFF
	p7[V_CUR_H + x] = (p7[V_CUR_H + x] + (1 if s > 0xFF else 0)) & 0xFF
	_88BF(x)


func _88BF(x: int) -> void:
	p7[R2 + x] = p7[V_CUR_L + x]
	p7[R3 + x] = p7[V_CUR_H + x] | 0xF8
	p7[V_LEFT + x] = (p7[V_LEFT + x] - 1) & 0xFF
	if p7[V_LEFT + x] == 0:
		_8922(x)
		return
	_y = zp[BE]


func _88D5(x: int) -> void:
	if (p7[V_ON + x] & 0x04) != 0:
		_88FA(x)
		return
	var s := p7[PER_L + x] + p7[V_ACC_L + x]
	p7[V_CUR_L + x] = s & 0xFF
	p7[V_CUR_H + x] = (p7[PER_H + x] + p7[V_ACC_H + x]
					   + (1 if s > 0xFF else 0)) & 0xFF
	p7[V_ON + x] = p7[V_ON + x] | 0x04
	_890C(x)


func _88FA(x: int) -> void:
	var s := p7[V_CUR_L + x] - p7[V_RATE + x]
	p7[V_CUR_L + x] = s & 0xFF
	p7[V_CUR_H + x] = (p7[V_CUR_H + x] - (1 if s < 0 else 0)) & 0xFF
	_890C(x)


func _890C(x: int) -> void:
	p7[R2 + x] = p7[V_CUR_L + x]
	p7[R3 + x] = p7[V_CUR_H + x] | 0xF8
	p7[V_LEFT + x] = (p7[V_LEFT + x] - 1) & 0xFF
	if p7[V_LEFT + x] == 0:
		_8922(x)
		return
	_y = zp[BE]


## $8922 -- the swing is over and the note is back where it started.
func _8922(x: int) -> void:
	p7[V_ON + x] = p7[V_ON + x] & 0xF3
	p7[V_LEFT + x] = 0
	p7[V_CUR_L + x] = 0
	p7[V_CUR_H + x] = 0
	_y = zp[BE]


## $8938 -- $BE divided by $BF; the answer back in $BE and the rest in $D0.
func _8938() -> void:
	var a := 0
	for _i in range(8):
		var c := (zp[BE] >> 7) & 1
		zp[BE] = (zp[BE] << 1) & 0xFF
		a = ((a << 1) | c) & 0xFF
		if a >= zp[BF]:
			a = (a - zp[BF]) & 0xFF
			zp[BE] = (zp[BE] + 1) & 0xFF
	zp[0xD0] = a


## $8983 -- the envelope's first part: down from the top, a slice at a time,
## until its counter reaches nought and the second part takes over.
func _8983(x: int) -> void:
	p7[FALL + x] = (p7[FALL + x] - 1) & 0xFF
	if p7[FALL + x] == 0:                   # $89CD
		zp[FLAG + x] = (zp[FLAG + x] & 0xCF) | 0x20
		p7[VOL + x] = _86CE(x, p7[ENV + x] & 0x0F)
		return
	zp[BE] = ((p7[ENV + x] & 0x70) << 1) & 0xFF
	zp[BF] = (p7[FALL + x] << 3) & 0xFF
	var a := 0
	for _i in range(3):                     # $899D
		var c := (zp[BE] >> 7) & 1
		zp[BE] = (zp[BE] << 1) & 0xFF
		if c != 0:
			a = (a + zp[BF]) & 0xFF
		zp[BF] = zp[BF] >> 1
	zp[BE] = a >> 1
	zp[BF] = p7[ENV_R + x]
	_8938()
	var e := p7[ENV + x]
	if e >= 0x80:                           # $89DD -- the other way about
		var d := (e & 0x0F) - zp[BE]
		p7[VOL + x] = _86CE(x, 1 if d < 0 else d)
		return
	var s := (e & 0x0F) + zp[BE]
	p7[VOL + x] = _86CE(x, 0x0F if s >= 0x10 else s)


## $89E8 -- the second part: held, until $8A2E says the note has gone on long
## enough, and then the third begins.
func _89E8(x: int) -> void:
	if _8A2E(x):
		zp[FLAG + x] = (zp[FLAG + x] & 0xCF) | 0x30
		p7[FELL + x] = 0
		p7[FALL + x] = p7[ENV_D + x]
	p7[VOL + x] = _86CE(x, p7[ENV + x] & 0x0F)


## $8A2E -- has it?  By how much of the note is left, or, with bit seven, by
## how far into it the channel has got.
func _8A2E(x: int) -> bool:
	var a := p7[ENV_H + x]
	if a < 0x80:
		return a >= p7[LEFT + x]
	return p7[INTO + x] >= (a & 0x7F)


## $8A0C -- the third part: down by one every $07AE pictures, and no further
## than silence.
func _8A0C(x: int) -> void:
	p7[FALL + x] = (p7[FALL + x] - 1) & 0xFF
	if p7[FALL + x] == 0:
		p7[FALL + x] = p7[ENV_D + x]
		p7[FELL + x] = (p7[FELL + x] + 1) & 0xFF
	var d := (p7[ENV + x] & 0x0F) - p7[FELL + x]
	p7[VOL + x] = _86CE(x, 0 if d < 0 else d)
