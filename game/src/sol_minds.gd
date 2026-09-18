extends RefCounted
class_name SolMinds

## What Solbrain's objects do once they are in a slot.
##
## Every slot carries a behaviour number in $0650.  Bank 2's $819D turns that
## into one of sixty four addresses -- one table for a thing that is alive
## ($81EA), another for one that has been finished off ($827B) -- and jumps.
## The behaviours themselves are spread across banks 2 and 3 and are ported
## here one for one, under the addresses they had.
##
## What is not here yet is written down in `work/re/sol_minds.md`: a behaviour
## that has not been read is simply skipped, and the pool counts it so that the
## acceptance can say which ones are still missing.

## $8FF6's own doing: these ride in the pool, not here, because a behaviour
## hands them to the next one.


## $819D -- one slot, one frame.
static func run(o: SolObjects, s: int) -> void:
	# $819D -- a ride under way holds the whole slot still: neither its own
	# turn nor anything it might touch.
	if o.born_wait != 0 and o.born_wait < 0x30:
		return
	_body(o, s)
	# $81A9 -- a thing that has been finished off touches nobody.
	if (o.mind[s] & 0x80) != 0:
		return
	if o.touch_box(s):                      # $C02A
		o.touch(s)                          # $C02D


## $81B7 -- the step before the jump: no movement owed, and a thing that was
## just hit sits the frame out unless its behaviour says otherwise.
static func _body(o: SolObjects, s: int) -> void:
	o.z50 = 0                               # $812C
	o.z52 = 0                               # $8133
	var m: int = o.mind[s]
	if (m & 0x80) != 0:
		_dead(o, s, m & 0x3F)               # $826A
		return
	if (m & 0x40) == 0 and (o.id[s] & 0x40) == 0 and o.cool[s] < 0x08:
		return                              # $81CF -- still flinching
	_live(o, s, m & 0x3F)


## $81EA -- the table for a thing that is alive.
static func _live(o: SolObjects, s: int, m: int) -> void:
	o.y_reg = (m << 1) & 0x7E               # $81DC TAY
	match m:
		0x00, 0x01, 0x02, 0x36, 0x37:
			pass                            # $B0CC -- nothing at all
		0x15:
			_aa41(o, s)
		0x16:
			_a7f0(o, s)
		0x17:
			_a836(o, s)
		0x2E:
			_a82b(o, s)
		0x1E:
			_a10b(o, s)
		0x1B:
			_a53d(o, s)
		0x04:
			_b11d(o, s, 0x01)               # $B11D
		0x05:
			_b11d(o, s, 0x02)               # $B225
		0x1C:
			_a3a8(o, s)
		0x1D:
			_a3b1(o, s)
		0x18:
			_8802(o, s)
		0x0D:
			_aa51(o, s)
		0x12:
			_adc5(o, s)
		0x39:
			_8e86(o, s)
		0x0E:
			_ac73(o, s)
		0x21, 0x2D:
			# $9DE7 is $9E12 word for word -- the same preamble and the same
			# sixteen-word table.  What tells them apart is read out of $0650
			# inside the turns themselves ($9E92, $9EFC).
			_9e12(o, s)
		0x24:
			_9d41(o, s)
		0x25, 0x26, 0x27:
			_9b05(o, s)
		0x2A:
			_99a2(o, s)
		0x2B:
			_962e(o, s)
		0x2C:
			_9683(o, s)
		0x2F:
			_915b(o, s)
		0x30:
			_923b(o, s)
		0x22:
			_9d71(o, s)
		0x23:
			_9dab(o, s)
		0x0B:
			_afba(o, s)
		0x13:
			_b0bb(o, s)
		0x28:
			_8aa2(o, s)
		0x38:
			_8f8d(o, s)
		0x34:
			_90ca(o, s)
		0x33:
			_9127(o, s)
		0x03:
			_b0dc(o, s)
		0x06:
			_b255(o, s)
		0x07:
			_b26b(o, s)
		0x08:
			_b2aa(o, s, 0x44)               # $B2AA
		0x09:
			_b2aa(o, s, 0x46)               # $B2AE
		0x0A:
			_b0ec(o, s)
		0x10:
			_8bba(o, s)
		0x14:
			_b0cd(o, s)
		0x1F:
			_a047(o, s)
		0x20:
			_a031(o, s)
		0x3A:
			_8deb(o, s)
		0x3D:
			_8ca8(o, s)
		0x3E:
			_8c40(o, s)
		0x35:
			_902d(o, s)
		0x3C:
			_8a33(o, s)
		0x19:
			_82fb(o, s)
		0x29:
			_9975(o, s)
		0x31:
			_9588(o, s)
		0x32:
			SolStage.chain(o, s)            # $921C -> $C07E -> $86C8
		0x0F:
			_acb5(o, s, 0xFF)              # $ACB9
		0x11:
			_acb5(o, s, 0x00)              # $ACB5
		0x1A:
			_a511(o, s)
		0x3B:
			_8cc9(o, s)
		0x0C:
			_ae7b(o, s)
		0x3F:
			_pickup(o, s)
		_:
			o.missed(m, false)


## $827B -- and for one that is finished.  Twenty three of the sixty four
## entries are the same word as the live table's; the rest are their own, and
## the ones that look alike are the easiest to get wrong -- $1E, $1B and $18
## all point somewhere else once bit 7 is on.
static func _dead(o: SolObjects, s: int, m: int) -> void:
	o.y_reg = (m << 1) & 0x7E               # $826D TAY
	match m:
		0x00, 0x01:
			_a883(o, s)                     # $A883
		0x02:
			_a8ed(o, s)                     # $A8ED
		0x04, 0x05, 0x0A:
			_a96c(o, s)                     # $A96C
		0x08, 0x09:
			_a9f6(o, s)                     # $A9F6
		0x13:
			_a904(o, s)                     # $A904
		0x15:
			_aa41(o, s)                     # $AA41
		0x16:
			_a7f0(o, s)                     # $A7F0
		0x17:
			_a836(o, s)                     # $A836
		0x2E:
			_a82b(o, s)                     # $A82B
		0x36:
			_a8b8(o, s)                     # $A8B8
		0x37:
			_a8d3(o, s)                     # $A8D3
		0x0B:
			_af63(o, s)                     # $AF63
		0x0C, 0x0E:
			_af31(o, s, 0x00)               # $AF23
		0x0F, 0x11:
			_af31(o, s, 0x0A)               # $AF27
		0x0D:
			_af31(o, s, 0x14)               # $AF2B
		0x12:
			_af31(o, s, 0x32)               # $AF2F
		0x18:
			_897e(o, s)                     # $897E
		0x1A, 0x1B:
			_a43c(o, s)                     # $A43C
		0x1C:
			_a989(o, s, 0x00)               # $A987
		0x1D:
			_a3b1(o, s)                     # $A3B1, the same as the live one
		0x1E:
			_a484(o, s)                     # $A484
		0x21, 0x2D:
			_a406(o, s)                     # $A406
		0x22:
			_9d71(o, s)                     # $9D71, the same as the live one
		0x23:
			_9dab(o, s)                     # $9DAB, the same
		0x24:
			_9d41(o, s)                     # $9D41, the same
		0x25:
			_a3bc(o, s)                     # $A3BC
		0x26:
			_a3fb(o)                        # $A3FB
		0x27:
			_9b05(o, s)                     # $9B05, the same
		0x2A:
			_a4a0(o, s)                     # $A4A0
		0x2B:
			_962e(o, s)                     # $962E, the same
		0x2C:
			_a4bd(o, s)                     # $A4BD
		0x2F:
			_915b(o, s)                     # $915B, the same
		0x30:
			_923b(o, s)                     # $923B, the same
		0x38, 0x39, 0x3A, 0x3B:
			_8f85(o, s, 0x14)               # $8F72
		0x3C:
			_8f85(o, s, 0x0A)               # $8F7B
		0x3E:
			_8f85(o, s, 0x64)               # $8F7F
		0x10:
			_8993(o, s)
		0x3D:
			_8f1c(o, s)
		0x34:
			_90ca(o, s)
		0x33:
			_9127(o, s)
		0x28:
			_8996(o, s)
		0x35:
			_899c(o, s)
		0x03:
			_b0dc(o, s)
		0x06:
			_b255(o, s)
		0x07:
			_b26b(o, s)
		0x14:
			_b0cd(o, s)
		0x1F:
			_a047(o, s)
		0x20:
			_a031(o, s)
		0x19:
			_82fb(o, s)
		0x29:
			_9975(o, s)
		0x31:
			_9588(o, s)
		0x32:
			SolStage.chain(o, s)            # $921C -> $C07E -> $86C8
		0x3F:
			_pickup_dead(o, s)
		_:
			o.missed(m, true)


# -------------------------------------------------- the thing that is dropped

## $B11D and $B225 -- [$04] and [$05] what is left behind to be picked up.  On
## its first picture it is thrown up; after that it falls, bounces off what it
## lands on, and is counted down until it goes.
static func _b11d(o: SolObjects, s: int, pic: int) -> void:
	if o.kind[s] == 0:
		o.kind[s] = (o.kind[s] + 1) & 0xFF  # $B122
		# $816F -> $8163 -- $C0 into the fall with both high bytes taken down,
		# which is a throw upwards.
		o.c[s] = 0xC0
		o.d[s] = 0xFF
		o.b[s] = 0xFF
		return
	_b134(o, s)                             # $B128
	o.anim_second(s, pic, 3)                # $8985, the third book of walks
	_b239(o, s)                             # $B130


## $B134 -- one picture of the fall, and what it lands on.
static func _b134(o: SolObjects, s: int) -> void:
	_b1b5(o, s)
	o.fall(s, 0x02)                         # $B2BB
	o.move_facing(s)                        # $813A


## $B1B5 -- what stops it: going up it is what is over its head, coming down it
## is what is under its feet, and off the floor it comes back up at three
## quarters of the speed it arrived with.
static func _b1b5(o: SolObjects, s: int) -> void:
	o.z90 = 0                               # $8121
	o.z92 = 0x0080
	if o.d[s] >= 0x80:
		if o.probe_above(s, 0x0080) < 0x80:
			return                          # $B210
		o.y[s] = (o.y[s] & 0xFF00) | 0x80   # $B214
		o.b[s] = 0x80
		o.c[s] = 0                          # $B21C
		o.d[s] = 0
		return
	if o.probe_behind(s, 0, 0x0080) < 0x80:
		return                              # $B1C4
	o.y[s] = (o.y[s] & 0xFF00) | 0x80       # $B1C8
	o.b[s] = 0x80
	# $B1CD -- the speed is halved, a quarter of it is added back, and what is
	# left is turned round: it comes off at three quarters.
	var v: int = ((o.d[s] << 8 | o.c[s]) >> 1) & 0xFFFF
	var q: int = (v >> 1) & 0xFFFF
	o.carry = 0
	var lo: int = o._adc(q & 0xFF, v & 0xFF)
	var hi: int = o._adc((q >> 8) & 0xFF, (v >> 8) & 0xFF)
	o.carry = 1
	o.c[s] = o._sbc(0, lo)
	o.d[s] = o._sbc(0, hi)


## $B239 -- it is counted down; at nothing the slot goes, over $40 it is left
## alone, and under that it is made to blink.
static func _b239(o: SolObjects, s: int) -> void:
	o.a[s] = (o.a[s] - 1) & 0xFF
	if o.a[s] != 0:
		o.carry = 1 if o.a[s] >= 0x40 else 0
		if o.carry != 0:
			return                          # $B245
	else:
		o.id[s] = 0                         # $80B9
	if (o.clock & 0x02) == 0:               # $B249
		o.cool[s] = 0x0F


# ------------------------------------------------------- the one that carries

## $9F5A -- how fast it is sent off, by how far away the hero was.
const THROW := [0x02, 0x04, 0x08, 0x0C, 0x11, 0x15, 0x19, 0x1D,
		0x22, 0x26, 0x2A, 0x2E, 0x33, 0x37, 0x3B, 0x3F]

## $9F13 -- and the eight heights it may stop the lift at.
const RUNGS := [0xA1, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7]


## $9FFA -- put where $75 says, then a whole page higher.
static func _9ffa(o: SolObjects, s: int) -> void:
	_9dbb(o, s)
	o.y[s] = (o.y[s] & 0x00FF) | ((((o.y[s] >> 8) - 1) & 0xFF) << 8)


## $9E12 -- sixteen turns of one part, told apart by $0690.
static func _9e12(o: SolObjects, s: int) -> void:
	# $8010 gets here through `ASL A`, and the index is never as much as $80,
	# so the carry a turn is handed is always down.
	o.carry = 0
	match o.kind[s] & 0x7F:                 # $8010 doubles it and keeps a byte
		0x00, 0x02, 0x0E:
			_9fb3(o, s, 0x24)               # $9FB1
		0x01, 0x03, 0x05:
			_9f6a(o, s)
		0x04:
			if (o.noise & 0x7E) != 0:
				_9fb3(o, s, 0x24)           # $9FA4 -- not yet
				return
			_9ffa(o, s)
			o.kind[s] = 0x06
			o.move(s)
		0x06, 0x0C:
			_9fb3(o, s, 0x2B)               # $9F98
		0x07:
			_9f1b(o, s)
		0x08, 0x0A:
			_9e78(o, s)
		0x09:
			_9ec0(o, s)
		0x0B:
			_9eaf(o, s)
		0x0D:
			_9e52(o, s)
		0x0F:
			_9e3d(o, s)


## $9FB3 -- the plain turn: walk a picture, step on when it runs out, sit where
## $75 says and face the hero.
static func _9fb3(o: SolObjects, s: int, n: int) -> void:
	o.anim_second(s, n)
	if o.left[s] == 0xFF:
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	_9ffa(o, s)
	o.face_hero(s)                          # $8118
	o.move(s)


## $9F6A -- the turn that lets one out to the side it is looking away from.
static func _9f6a(o: SolObjects, s: int) -> void:
	_9ffa(o, s)
	o.anim_second(s, 0x26)
	if o.frame[s] == 0x03:                  # $80EC
		if (o.face[s] & 0x80) != 0:
			o.hatch_right(s, 0xAB)
		else:
			o.hatch_left(s, 0xAB)
	if o.left[s] == 0xFF:
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.move(s)


## $9F34 -- the throw: how far the hero was decides how fast, and which side he
## is on decides which way.
static func _9f34(o: SolObjects, s: int) -> void:
	var i: int = (o.z90 >> 8) & 0xFF
	if i >= 0x10:
		i = 0x0F
	o.a[s] = THROW[i]
	if o.z94 < 0x80:
		o.carry = 1
		o.a[s] = o._sbc(0, o.a[s])
	o.z58 = 0
	_8163(o, s, 0x80)


## $9F1B -- the wind-up, and on the last picture of it the throw is worked out.
static func _9f1b(o: SolObjects, s: int) -> void:
	_9ffa(o, s)
	o.anim_second(s, 0x28)
	if o.left[s] == 0xFF:
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.move(s)
	if o.left[s] != 0xFF:
		return
	o.far_x(s)                              # $AE30
	_9f34(o, s)


## $9E78 -- it is in the air: the step along it was given, the fall, and the
## landing when it is back down at $75's height.
static func _9e78(o: SolObjects, s: int) -> void:
	o.z58 = (o.z58 + 1) & 0xFF
	o.z50 = o.a[s] | (0xFF00 if o.a[s] >= 0x80 else 0)
	o.fall(s, 0x04)                         # $B2BB
	if o.d[s] < 0x80 and _a000(o, s):
		if (o.mind[s] & 0x3F) == 0x2D:
			pass                            # $05F7 -- the door, not the pool
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.anim_second(s, 0x27)
	o.move(s)


## $A000 in bank 3 -- is it back down at the height $75 keeps, a page up?
static func _a000(o: SolObjects, s: int) -> bool:
	var lo: int = (o.z75 << 4) & 0xFF
	var hi: int = ((o.z75 >> 4) & 0x0F) - 1
	o.carry = 0
	lo = o._adc(o.cam_y & 0xFF, lo)
	hi = o._adc((o.cam_y >> 8) & 0xFF, hi & 0xFF)
	o.carry = 1
	o._sbc(o.y[s] & 0xFF, lo)
	o._sbc((o.y[s] >> 8) & 0xFF, hi)
	return o.carry != 0


## $9EFC -- the lift is told which rung to stop at, unless this is the door.
static func _9efc(o: SolObjects, s: int) -> void:
	if (o.mind[s] & 0x3F) != 0x2D:
		o.z75 = RUNGS[o.left[s] & 0x07]
	o.move(s)


## $9EC0 -- the catch: near enough and it goes back to waiting, otherwise it
## works out the next throw from where the hero is now.
static func _9ec0(o: SolObjects, s: int) -> void:
	_9ffa(o, s)
	o.anim_second(s, 0x28)
	if o.left[s] != 0xFF:
		_9efc(o, s)
		return
	if o.far_x(s) < 0x04:
		o.kind[s] = 0x0B
		return
	var v := 0
	o.carry = 1                             # $9ECF left it up
	if (o.six & 0x03) != 0:
		v = 0xFC if (o.hero_face & 0x80) != 0 else 0x04
		o.carry = 0
	o._adc(v, (o.hero_x >> 8) & 0xFF)       # $9EE8 -- only the borrow it leaves
	o.face_hero(s)                          # $8118
	_9f34(o, s)
	o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.move(s)


## $9EAF -- the same wait, but it only ever steps on.
static func _9eaf(o: SolObjects, s: int) -> void:
	_9ffa(o, s)
	o.anim_second(s, 0x28)
	if o.left[s] == 0xFF:
		o.kind[s] = (o.kind[s] + 1) & 0xFF
		return
	_9efc(o, s)


## $9E52 -- it opens, and two more come out, one each side.
static func _9e52(o: SolObjects, s: int) -> void:
	_9ffa(o, s)
	o.anim_second(s, 0x25)
	if o.frame[s] == 0x02:                  # $80E6
		o.hatch_right(s, 0x90)
		o.hatch_left(s, 0x99)
	if o.left[s] == 0xFF:
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.move(s)


## $9E3D -- and the toss-up over which turn comes next.
static func _9e3d(o: SolObjects, s: int) -> void:
	_9ffa(o, s)
	o.kind[s] = 0x00 if (o.noise & 0x03) != 0 else 0x07
	o.move(s)


## $9D41 -- what the carrier has hold of: it takes slot 0's facing the first
## time round, then rides on the speed it was given, mirrored to its facing.
static func _9d41(o: SolObjects, s: int) -> void:
	_9ffa(o, s)
	if o.kind[s] == 0:
		o.kind[s] = 0xFF
		o.face[s] = o.face[0]               # $9D4C -- slot 0's, not its own
		o.pic_hi[s] = 0x02
		o.pic_lo[s] = 0x92
	o.z50 = o.a[s] | o.b[s] << 8
	if o.face[s] < 0x80:
		o.carry = 1                         # $8181
		var lo: int = o._sbc(0, o.z50 & 0xFF)
		var hi: int = o._sbc(0, (o.z50 >> 8) & 0xFF)
		o.z50 = lo | hi << 8
	o.move(s)


# ------------------------------------------------------------- the gate

## $915B -- seven turns of the way out of a stage.  Nothing here moves; what it
## does is set the screen's own business going and count the slot on.
static func _915b(o: SolObjects, s: int) -> void:
	# $8010 gets here through `ASL A`, and the index is never as much as $80,
	# so the carry a turn is handed is always down.
	o.carry = 0
	match o.kind[s] & 0x7F:
		0x00:
			o.face_hero(s)                  # $8118
			o.anim_second(s, 0x49)          # $904B
			if o.z58 != 0x03 or o.left[s] != 0xFF:
				return
			o.z26 = 0x04                    # $A3FF -> $80A9
			o.a[s] = 0xE0
			o.kind[s] = (o.kind[s] + 1) & 0xFF
			o.kind[0x0B] = (o.kind[0x0B] + 1) & 0xFF
		0x01:
			o.carry = 1
			var v: int = o._sbc(o.a[s], 0x04)
			o.a[s] = v
			if o.carry != 0:
				return
			o.a[s] = o._adc(v, 0x04)
			if o.z26 != 0:
				return
			o.z26 = 0x06                    # $80A9, after $80AE's own pair
			o.id[0x0B] = 0
			o.kind[s] = (o.kind[s] + 1) & 0xFF
		0x02:
			o.anim_second(s, 0x4E)
			if o.z26 == 0:
				o.kind[s] = (o.kind[s] + 1) & 0xFF
		0x03:
			o.anim_second(s, 0x4A)
			if o.left[s] != 0xFF:
				return
			o.a[s] = 0x20
			o.z26 = 0xFF
			o.kind[s] = (o.kind[s] + 1) & 0xFF
		0x04:
			o.kind[s] = (o.kind[s] + 1) & 0xFF
			o.z26 = 0x06
		0x05:
			o.a[s] = (o.a[s] - 1) & 0xFF
			if o.a[s] == 0:
				o.kind[s] = (o.kind[s] + 1) & 0xFF
		0x06:
			o.anim_second(s, 0x4D)
			if o.left[s] != 0xFF or o.z58 < 0x03:
				return
			o.mind[s] = (o.mind[s] + 1) & 0xFF
			o.kind[s] = 0                   # $80B3



# ------------------------------------------------------------- the big one

## $9462 -- which turn the big one takes next, four to a row of the picked row.
const NEXT := [0x0A, 0x0A, 0x0A, 0x07, 0x0A, 0x0A, 0x07, 0x03,
		0x0A, 0x07, 0x07, 0x03, 0x07, 0x03, 0x03, 0x03]

## $923B -- the big one at the end of a stage: two and twenty turns, of which
## the first fifteen are the fight and the rest the walking on afterwards.
static func _923b(o: SolObjects, s: int) -> void:
	# $921F only picks a colour, so the fight's own turns lose nothing by it.
	# $8010 gets here through `ASL A`, and the index is never as much as $80,
	# so the carry a turn is handed is always down.
	o.carry = 0
	match o.kind[s] & 0x7F:
		0x00, 0x0D:
			_93b9(o, s)
		0x01:
			_9397(o, s)
		0x02:
			_9413(o, s)
		0x03:
			_9472(o, s)
		0x04:
			_948a(o, s)
		0x05:
			_94b8(o, s)
		0x06:
			_94f2(o, s)
		0x07:
			_950c(o, s)
		0x08:
			_9523(o, s)
		0x09:
			_954b(o, s)
		0x0A:
			_95a2(o, s)
		0x0B:
			_95b9(o, s)
		0x0C:
			_95dc(o, s)
		0x0E:
			o.kind[s] = 0                   # $962B
		0x0F:
			_92b5(o, s)
		0x10:
			_92e9(o, s)
		0x11:
			_9379(o, s)
		0x12:
			pass                            # $9394 -- colour only
		0x13:
			_935c(o, s)
		0x14:
			_934a(o, s)
		0x15:
			_932b(o, s)


## $938B -- the tail every walking turn shares: one picture of the walk, the
## step, and the look at whether the walk has run out.
static func _938b(o: SolObjects, s: int, n: int) -> void:
	o.anim_second(s, n)
	o.move(s)


## $93CF -- what a hit does while the big one is standing about.
static func _93cf(o: SolObjects, s: int) -> void:
	if (o.mind[s] & 0x40) != 0:
		return
	if o.cool[s] != 0x01:                   # $80DA
		return
	o.a[s] = o.face[s]
	o.anim_first(s, 0x48)                   # $9028


## $93E7 -- and the hurt walk it falls into, which carries it backwards.
static func _93e7(o: SolObjects, s: int) -> void:
	o.anim_first(s, 0x48)
	o.carry = 1
	o._sbc(o.cool[s], 0x09)
	var n: int = 0x40 if o.carry == 0 else 0x10
	var r: int = o.step_and_look(s, n)
	if o.anim_a[s] == 0:
		o.left[s] = 0xFF if (r & 0x80) != 0 else 0x04
		o.cool[s] = 0x02
	o.move(s)


## $93B9 -- turns 0 and 13: stand, look at the hero, and wait for the walk.
static func _93b9(o: SolObjects, s: int) -> void:
	if o.anim_a[s] != 0:
		_93e7(o, s)
		return
	o.face_hero(s)                          # $8118
	o.anim_second(s, 0x3E)
	if o.left[s] == 0xFF:
		o.kind[s] = (o.kind[s] + 1) & 0xFF
		return
	_93cf(o, s)


## $9397 -- turn 1: walk at the hero until he is within seven pictures.
static func _9397(o: SolObjects, s: int) -> void:
	if o.far_x(s) < 0x07:
		o.kind[s] = (o.kind[s] + 1) & 0xFF
		return
	o.face[s] = o.z94
	o.a[s] = o.z94 ^ 0xFF
	o.step_and_look(s, 0x10)
	o.anim_second(s, 0x3F)
	o.move(s)


## $9413 -- turn 2: the one that picks what comes next.  The roll is weighted
## by how much is left in it, by which suit the hero is wearing and by the two
## stirred bytes, and the answer is a turn number out of $9462.
static func _9413(o: SolObjects, s: int) -> void:
	if o.anim_a[s] != 0:
		_93e7(o, s)
		return
	o.face_hero(s)
	o.anim_second(s, 0x3E)
	if o.left[s] != 0xFF:
		_93cf(o, s)
		return
	o.face_hero(s)
	var row := 0x0C
	var v: int = o.six & 0x03
	if v != 0:
		# Three turns to the right of a two bit number, the carry $AE30 left
		# riding in: what comes out is bit 7 of the pair and bit 5 of that.
		var w: int = (((v >> 1) & 1) << 7) | ((v & 1) << 6) | (o.carry << 5)
		if ((w ^ o.z94) & 0x80) != 0:
			row = 0x08
	if row == 0x0C and o.life[s] >= 0x08 and o.hero_state != 0x07:
		row = 0x04 if o.hero_state == 0x03 else 0x00
	o.kind[s] = NEXT[(row + (o.noise & 0x03)) & 0x0F]


## $9472 -- turn 3: face the hero, then wind up.
static func _9472(o: SolObjects, s: int) -> void:
	o.a[s] = o.face_hero(s) ^ 0xFF
	o.anim_second(s, 0x40)
	if o.left[s] != 0xFF:
		return
	o.c[s] = 0x78                           # $8163
	o.d[s] = 0xFF
	o.b[s] = 0xFF
	o.kind[s] = (o.kind[s] + 1) & 0xFF


## $948A -- turn 4: the leap.  On the way up it works out how far it will be
## thrown, and leaves that in the second slot for the turn after.
static func _948a(o: SolObjects, s: int) -> void:
	o.fall(s, 0x04)
	o.face_hero(s)
	if (o.d[s] & 0x80) == 0:
		var i: int = (o.z90 >> 8) & 0xFF
		if i >= 0x10:
			i = 0x0F
		o.a[1] = (THROW[i] << 2) & 0xFF
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.step_and_look(s, 0x10)
	o.anim_second(s, 0x41)
	o.move(s)


## $94B8 -- turn 5: the landing.  The ground stops it, two lots of rubble are
## let out either side, and the hero is shaken.
static func _94b8(o: SolObjects, s: int) -> void:
	o.fall(s, 0x1C)
	o.z90 = 0
	if (o.probe_behind(s, 0, 0x0100) & 0x80) != 0:
		o.z52 = 0                           # $8133
		o.y[s] = o.y[s] & 0xFF00
		o.a[s] = 0
		o.hatch_right(s, 0x24)              # $AA9E
		o.hatch_left(s, 0x24)               # $AAA9
		o.wants = 0x07
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.step_and_look(s, o.a[1])
	o.anim_second(s, 0x42)
	o.move(s)


## $94F2 -- turn 6: it stands in the smoke while the background is redrawn,
## and goes back to the start of the fight when the walk runs out.
static func _94f2(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x44)
	if _9505(o, s) == 0:
		return
	if o.left[s] != 0xFF:
		return
	o.kind[s] = 0                           # $962B


## $9505 -- one background rewrite, put off while a row or a column of it is
## already owed.  $0610 counts how many of them have been paid.
static func _9505(o: SolObjects, s: int) -> int:
	if o.a[s] == 0x01:
		return 0xFF
	if o.col_due != 0 or o.row_due != 0:    # $BF0B
		return 0
	o.a[s] = (o.a[s] + 1) & 0xFF
	return 0xFF if o.a[s] == 0x01 else 0


## $950C -- turn 7: face the hero and wind up for the charge.
static func _950c(o: SolObjects, s: int) -> void:
	o.a[s] = o.face_hero(s) ^ 0xFF
	o.anim_second(s, 0x45)
	if o.left[s] == 0xFF:
		o.kind[s] = (o.kind[s] + 1) & 0xFF


## $9523 -- turn 8: the charge, which runs until the hero is the other side.
static func _9523(o: SolObjects, s: int) -> void:
	o.far_x(s)
	if ((o.z94 ^ o.a[s]) & 0x80) == 0:
		o.a[1] = 0x70
		o.kind[s] = (o.kind[s] + 1) & 0xFF
		return
	o.step_and_look(s, 0x80)
	if (o.kind[s] & 0x80) != 0:
		o.a[1] = 0x70
		o.kind[s] = (o.kind[s] + 1) & 0xFF
		return
	o.anim_second(s, 0x46)
	_9574(o, s)
	o.move(s)


## $954B -- turn 9: the charge running down, four a picture.
static func _954b(o: SolObjects, s: int) -> void:
	o.carry = 1
	var v: int = o._sbc(o.a[1], 0x04)
	if o.carry == 0:
		o.kind[s] = 0                       # $962B
		v = 0
	o.a[1] = v
	o.step_and_look(s, v)
	if o.a[1] < 0x50:
		o.face_hero(s)
		o.anim_second(s, 0x47)
		o.move(s)
		return
	_9574(o, s)
	o.move(s)


## $9574 -- every fourth picture the charge leaves something behind it.
static func _9574(o: SolObjects, s: int) -> void:
	if (o.clock & 0x03) != 0:
		return
	var f: int = -1
	for i in range(0x0B, -1, -1):           # $A056
		if o.id[i] == 0:
			f = i
			break
	if f < 0:
		return
	o.x[f] = o.x[0]
	o.y[f] = o.y[0]
	o.cool[s] = 0xFF                        # $80D4, and on this slot
	o.id[f] = 0xFF
	o.mind[f] = 0xA0
	o.life[f] = 0xA0
	o.pic_lo[f] = o.pic_lo[0]
	o.pic_hi[f] = o.pic_hi[0]
	o.face[f] = o.face[0]
	o.a[f] = 0x20
	o.frame[f] = 0
	o.left[f] = 0
	o.anim_a[f] = 0
	o.anim_b[f] = 0
	o.a[f] = 0x07
	o.mind[f] = 0x31


## $95A2 -- turn 10: the wind up for the last trick.
static func _95a2(o: SolObjects, s: int) -> void:
	o.face_hero(s)
	o.anim_second(s, 0x4A)
	if o.left[s] != 0xFF:
		return
	o.b[s] = 0x20
	o.kind[s] = (o.kind[s] + 1) & 0xFF


## $95B9 -- turn 11: the trick itself, thirty two pictures of flashing and
## then the shower of shots that $95E7 lets out.
static func _95b9(o: SolObjects, s: int) -> void:
	o.face_hero(s)
	o.b[s] = (o.b[s] - 1) & 0xFF
	if o.b[s] != 0:
		o.cool[s] = 0x01 if (o.clock & 0x02) != 0 else 0x03
		return
	SolShots.shower(o, s)                   # $95E7
	o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.cool[s] = 0xFF                        # $80D4


## $95DC -- turn 12: it draws breath, then the fight begins again.
static func _95dc(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x43)
	if o.left[s] == 0xFF:
		o.kind[s] = 0                       # $962B


## $927E -- while it is dying, every eighth picture a puff of smoke somewhere
## about it, placed by the stirred byte.
static func _927e(o: SolObjects, s: int) -> void:
	if (o.clock & 0x07) != 0:
		return
	var t := [0x00, 0xFF, 0x00, 0x01]       # $92B1
	var yh: int = o._adc(t[o.noise & 0x03], (o.y[s] >> 8) & 0xFF)
	# $929D -- the second index is picked out of the stirred byte by two RORs,
	# and a ROR both reads and writes the carry.  What the second sum is handed
	# is therefore bit one of that byte, not the carry the first sum made.
	o.carry = (o.noise >> 1) & 0x01
	var xh: int = o._adc(t[(o.noise >> 2) & 0x03], (o.x[s] >> 8) & 0xFF)
	o.hatch(xh << 8, yh << 8, 0x7E)         # $AAC2


## $92B5 -- turn 15: the death.  It is pinned to one spot, the screen is told
## what to do, and the mind loses its own top bits.
static func _92b5(o: SolObjects, s: int) -> void:
	o.face_hero(s)
	o.y[s] = 0x2A2A
	_938b(o, s, 0x59)
	if o.left[s] == 0x80:
		o.z26 = 0x04                        # $A3FF
		return
	o.carry = 1 if o.left[s] == 0xFF else 0
	if o.left[s] == 0xFF:
		o.life[s] = 0xE0
		o.mind[s] = o.mind[s] & 0x3F
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	_927e(o, s)


## $92E9 -- turn 16: the same, and the points are paid out at the end of it.
static func _92e9(o: SolObjects, s: int) -> void:
	_938b(o, s, 0x5A)
	if o.left[s] == 0x10:
		o.z26 = 0x06
		return
	o.carry = 1 if o.left[s] == 0xFF else 0
	if o.left[s] == 0xFF:
		o.score += 0x19 * 6
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	_927e(o, s)


## $9379 -- turn 17: walking off, looking where it is going.
static func _9379(o: SolObjects, s: int) -> void:
	o.a[s] = o.face[s]
	if o.frame[s] == 0x02:                  # $80E6
		o.step_and_look(s, 0x10)
	_938b(o, s, 0x52)


## $935C -- turn 19: standing about until it is hit.
static func _935c(o: SolObjects, s: int) -> void:
	o.c[s] = 0xC0                           # $816F
	o.d[s] = 0xFF
	o.b[s] = 0xFF
	if o.anim_a[s] == 0 and o.cool[s] != 0x01:
		_938b(o, s, 0x55)
		return
	o.cool[s] = 0x53
	o.life[s] = 0x53
	o.anim_first(s, 0x53)                   # $9028


## $934A -- turn 20: it is falling, slowly, the way it faces.
static func _934a(o: SolObjects, s: int) -> void:
	o.step_along(s, 0x10)                   # $8179
	o.fall(s, 0x02)
	_938b(o, s, 0x54)


## $932B -- turn 21: it is not drawn at all any more, and every eighth picture
## it leaves something where it stands.
static func _932b(o: SolObjects, s: int) -> void:
	o.pic_lo[s] = 0                         # $87A2
	o.pic_hi[s] = 0
	if (o.clock & 0x07) != 0:
		return
	o.hatch_here(s, 0xC6)                   # $AAF1


# --------------------------------------------------------------- the walker

## $9961 -- a hit one drops into the hurt walk and says so; anything else is
## left as it was.
static func _9961(o: SolObjects, s: int) -> int:
	# $80DA is a CMP, and the borrow it leaves is what $AE30 goes on to use.
	o.carry = 1 if o.cool[s] >= 0x01 else 0
	if o.cool[s] != 0x01:
		return o.cool[s]
	if (o.mind[s] & 0x40) != 0:             # $8173
		return 0x40
	o.anim_first(s, 0x3C)                   # $9028
	return 0


## $9954 -- the walk, with a noise on the picture it starts over.
static func _9954(o: SolObjects, s: int, n: int) -> void:
	o.anim_second(s, n)


## $9905 -- the shot: near enough, hurt enough and on the right picture it
## lets one fly.
static func _9905(o: SolObjects, s: int) -> void:
	if _9961(o, s) == 0:
		return
	if o.far_x(s) >= 0x04 or o.cool[s] < 0x40:
		_9954(o, s, 0x37)
		return
	if o.frame[s] == 0x01:                  # $991D -- one picture of the walk
		var i: int = SolShots.free_slot(o)  # $9924
		if i >= 0:
			SolShots.put(o, i, 0x9C)        # $992D -> $907B
			# $9936 -- which way it goes is the top bit of the thing's own
			# first byte, and that same bit is left in the carry, which is
			# what $A1D7 then adds the place with.
			var c: int = (o.a[s] >> 7) & 1
			SolShots.place(o, s, i, 0xFF60 if c == 1 else 0x00A0, 0x0160, c)
	o.anim_second(s, 0x39)                  # $994F


## $9789 -- the count between shots; $ADBA has no slot to give, so the rest of
## it never runs.
static func _9789(o: SolObjects, s: int) -> void:
	if o.d[s] == 0:
		return
	o.b[s] = (o.b[s] - 1) & 0xFF
	if o.b[s] != 0:
		return
	o.b[s] = o._adc(o.noise & 0x0F, 0x18)
	o.d[s] = (o.d[s] - 1) & 0xFF            # $979C
	# $979F -- and one of the things it has left goes out: the topmost free
	# slot, behaviour $9D with one to give, at the slot's own place a whole
	# picture higher.  The add at $A1D7 takes the carry the $18 above left,
	# and that one never carries.
	var i: int = SolShots.free_slot(o)      # $ADBA
	if i < 0:
		return                              # $97A2
	SolShots.put(o, i, 0x9D)                # $907B
	SolShots.place(o, s, i, 0x0000, 0xFF00, o.carry)


## $98F2 -- a rise is cut short when the slot is nearly at the top of the view.
static func _98f2(o: SolObjects, s: int, n: int) -> void:
	if ((o.z52 >> 8) & 0xFF) < 0x80:
		return
	o.carry = 1
	var d: int = o._sbc((o.y[s] >> 8) & 0xFF, (o.cam_y >> 8) & 0xFF)
	o.carry = 1
	o._sbc(d, n)
	if o.carry == 0:
		o.z52 = 0                           # $8133


## $98E0 -- every fourth picture the heading is turned one notch and the step
## down takes it up.
static func _98e0(o: SolObjects, s: int) -> void:
	if (o.clock & 0x03) == 0:
		o.c[s] = (o.c[s] + 1) & 0xFF
		_a293(o, s, 0x00)
	_98f2(o, s, 0x04)


## $98D0 -- it turns about: the step along is set to one, the way it is not
## already going.
static func _98d0(o: SolObjects, s: int) -> void:
	o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.a[s] = 0x00 if o.a[s] >= 0x80 else 0xFF


## $9840 -- the step along is turned round.
static func _9840(o: SolObjects, s: int) -> void:
	o.carry = 1
	o.a[s] = o._sbc(0, o.a[s])


## $981C -- being hit: it is held still for the picture and put back facing
## the way it was.
static func _981c(o: SolObjects, s: int) -> void:
	o.anim_first(s, 0x3C)                   # $9028
	_9840(o, s)
	o.step_and_look(s, 0x40)
	_9840(o, s)
	if o.anim_a[s] == 0:
		o.a[s] = 0x00 if o.face[s] < 0x80 else 0xFF
	o.move(s)


## $98AC -- one picture of the walk, with the turn about when it runs into
## something.
static func _98ac(o: SolObjects, s: int, v: int) -> void:
	o.a[s] = v
	var n: int = v
	if n >= 0x80:
		o.carry = 0
		n = o._adc(n ^ 0xFF, 0x01)
	if o.step_and_look(s, n) >= 0x80:
		_98d0(o, s)
	if _9961(o, s) == 0:
		return
	_9954(o, s, 0x38)
	_98e0(o, s)
	o.move(s)


## $97D0 -- it backs away, a touch faster every picture down to $E8, and when
## it is far enough to the left of the view it steps on.
static func _97d0(o: SolObjects, s: int) -> void:
	o.carry = 1
	var v: int = o._sbc(o.a[s], 0x01)
	o.carry = 1
	o._sbc(v, 0xE8)
	if o.carry == 0:
		v = 0xE8
	o.a[s] = v
	o.face[s] = v
	o.carry = 0
	var n: int = o._adc(v ^ 0xFF, 0x01)
	o.step_and_look(s, n)
	o.carry = 1
	o._sbc(o.x[s] & 0xFF, o.cam_x & 0xFF)
	var d: int = o._sbc((o.x[s] >> 8) & 0xFF, (o.cam_x >> 8) & 0xFF)
	var on := o.carry == 0
	if not on:
		o.carry = 1
		o._sbc(d, 0x07)
		on = o.carry == 0
	if on:
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	_98e0(o, s)
	o.move(s)


## $984A -- and the other way about: it comes on, up to $18 a picture.
static func _984a(o: SolObjects, s: int) -> void:
	o.carry = 0
	var v: int = o._adc(o.a[s], 0x01)
	o.carry = 1
	o._sbc(v, 0x18)
	if o.carry != 0:
		v = 0x18
	o.a[s] = v
	o.face[s] = v
	o.step_and_look(s, v)
	o.carry = 1
	o._sbc(o.x[s] & 0xFF, o.cam_x & 0xFF)
	var d: int = o._sbc((o.x[s] >> 8) & 0xFF, (o.cam_x >> 8) & 0xFF)
	var on := o.carry == 0
	if not on:
		o.carry = 1
		o._sbc(d, 0x09)
		on = o.carry != 0
	if on:
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	_98e0(o, s)
	o.move(s)


## $9652 -- what it drops when it has come all the way down.
static func _9652(o: SolObjects, s: int) -> void:
	o.hatch((o.x[s] >> 8) << 8, 0x6200, 0x36)


## $96FC -- the descent: it lets one out every picture and slows as it nears
## the height it is making for.
static func _96fc(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x4F)
	o.hatch_here(s, 0xD8)                   # $AAF1
	o.a[s] = o.face[s] ^ 0xFF
	o.carry = 0
	var v: int = o._adc(o.d[s], 0x01)
	o.carry = 1
	o._sbc(v, 0x41)
	if o.carry != 0:
		v = 0x40
	o.d[s] = v
	o.step_and_look(s, v)
	o.carry = 1
	var w: int = o._sbc(0, o.d[s])
	o.carry = 1
	o._sbc(w, 0xD0)
	if o.carry != 0:
		w = ((w >> 1) | 0x80) & 0xFF        # $972D -- twice, with the borrow up
		w = ((w >> 1) | 0x80) & 0xFF
	o.z52 = (w | 0xFF00) & 0xFFFF           # $9731 with $9733's DEC $53
	_98f2(o, s, 0x03)
	if ((o.z52 >> 8) & 0xFF) == 0:
		_9652(o, s)
		o.face[s] = o.face[s] ^ 0xFF        # $AE24
		o.c[s] = 0x08
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.move(s)


## $962E -- the one that sinks: its own count is its step down, and it leaves
## something behind at one height and halves its count at another.
static func _962e(o: SolObjects, s: int) -> void:
	# $966B -- one off the count, and the count is the step.
	o.carry = 1
	o.a[s] = o._sbc(o.a[s], 0x01)
	o.b[s] = o._sbc(o.b[s], 0x00)
	o.z52 = o.a[s] | o.b[s] << 8
	o.move(s)                               # $813F
	if ((o.y[s] >> 8) & 0xFF) == 0x61:
		o.hatch(o.x[s] & 0xFF00, 0x6200, 0x36)          # $9652 -> $AAC2
	if (o.b[s] & 0x80) != 0 and ((o.y[s] >> 8) & 0xFF) < 0x64:
		o.b[s] = o.b[s] >> 1                # $9645
		o.mind[s] = (o.mind[s] + 1) & 0xFF  # $964C
	SolStage.call_at(o, s, 0x7F)            # $964F -> $9666


## $9683 -- twenty two turns, told apart by $0690.
static func _9683(o: SolObjects, s: int) -> void:
	# $8010 gets here through `ASL A`, and the index is never as much as $80,
	# so the carry a turn is handed is always down.
	o.carry = 0
	match o.kind[s] & 0x7F:
		0x00, 0x04, 0x0C:
			if o.anim_a[s] != 0:
				_981c(o, s)
				return
			_9905(o, s)
			_97d0(o, s)
		0x01, 0x05, 0x0D:
			_9879(o, s)
		0x02, 0x06:
			if o.anim_a[s] != 0:
				_981c(o, s)
				return
			_9905(o, s)
			_984a(o, s)
		0x03, 0x07:
			_9894(o, s)
		0x08:
			o.b[s] = 0x07
			o.d[s] = 0x03
			o.kind[s] = (o.kind[s] + 1) & 0xFF
			if (o.noise & 0x02) != 0:
				o.carry = 0
				o.kind[s] = o._adc(o.kind[s], 0x03)
		0x09:
			if o.anim_a[s] != 0:
				_981c(o, s)
				return
			if _9961(o, s) == 0:
				return
			_9954(o, s, 0x37)
			_9789(o, s)
			_97d0(o, s)
		0x0A:
			_9789(o, s)
			_9879(o, s)
		0x0B:
			o.carry = 0
			o.kind[s] = o._adc(o.kind[s], 0x05)
		0x0E:
			if o.anim_a[s] != 0:
				_981c(o, s)
				return
			_9954(o, s, 0x37)
			_9789(o, s)
			_984a(o, s)
		0x0F:
			_9789(o, s)
			_9894(o, s)
		0x10:
			o.anim_second(s, 0x3A)
			if ((o.y[s] >> 8) & 0xFF) >= 0x6B:
				o.kind[s] = (o.kind[s] + 1) & 0xFF
				return
			o.z52 = 0x18
			o.move(s)
		0x11:
			o.anim_second(s, 0x3B)
			if o.left[s] == 0xFF:
				o.d[s] = 0x20
				o.kind[s] = (o.kind[s] + 1) & 0xFF
		0x12:
			o.anim_second(s, 0x50)
			o.d[s] = (o.d[s] - 1) & 0xFF
			if o.d[s] == 0:
				o.d[s] = (o.d[s] + 1) & 0xFF
				o.kind[s] = (o.kind[s] + 1) & 0xFF
		0x13:
			_96fc(o, s)
		0x14:
			o.anim_second(s, 0x51)
			if o.left[s] == 0xFF:
				o.kind[s] = (o.kind[s] + 1) & 0xFF
			_98e0(o, s)
			o.move(s)
		0x15:
			o.kind[s] = 0                   # $80B3


## $9879 -- the walk on, one notch every fourth picture.
static func _9879(o: SolObjects, s: int) -> void:
	if o.anim_a[s] != 0:
		_981c(o, s)
		return
	o.carry = 1
	o._sbc(o.clock & 0x03, 0x03)            # $987E -- only for the borrow
	var v: int = o._adc(o.a[s], 0x00)
	if v >= 0x80:
		_98ac(o, s, v)
		return
	_98d0(o, s)                             # and the count is not kept


## $9894 -- and the walk back.
static func _9894(o: SolObjects, s: int) -> void:
	if o.anim_a[s] != 0:
		_981c(o, s)
		return
	o.carry = 1
	o._sbc(o.clock & 0x03, 0x01)
	var v: int = o._sbc(o.a[s], 0x00)
	if v < 0x80:
		_98ac(o, s, v)
		return
	_98d0(o, s)


# ---------------------------------------------------------- the one that runs

## $9CDD -- the step, and what the step runs into.  A hit one takes the hero's
## side afresh; one that is still flinching only carries on as it was.
static func _9cdd(o: SolObjects, s: int, n: int) -> void:
	if o.cool[s] >= 0x08 or (o.mind[s] & 0x40) != 0:
		if n != 0:                          # $9D00
			o.step_and_look(s, n)
		return
	if o.cool[s] == 0x01:                   # $80DA
		o.far_x(s)
		o.a[s] = o.z94
	o.step_and_look(s, 0x40)


## $9C50 -- the tail every turn but two comes back through: the stage's own
## script can take it away, and being hit puts it on the floor.
static func _9c50(o: SolObjects, s: int) -> void:
	if o.z7f == 0x03:
		o.kind[s] = 0x06
		return
	if o.cool[s] == 0x01:
		o.kind[s] = 0x05
		_898a(o, s)
	_9cdd(o, s, 0x00)                       # $9C69
	o.move(s)


## $9B05 -- thirteen turns, told apart by the low seven bits of $0690; the top
## one is raised by $9D0A when it walks into something.
static func _9b05(o: SolObjects, s: int) -> void:
	match o.kind[s] & 0x7F:
		0x00:
			o.anim_second(s, 0x2C)
			if o.left[s] == 0xFF:
				if o.far_x(s) >= 0x03:
					o.kind[s] = (o.kind[s] + 1) & 0xFF
				o.kind[s] = (o.kind[s] + 1) & 0xFF
			_9c50(o, s)
		0x01:
			o.anim_second(s, 0x2F)
			# $9C14 -- on two pictures of the walk it lets something out of
			# itself, and bank six is the one that knows what.
			if o.frame[s] == 0x01:
				_9c50(o, s)
				SolStage.call_at(o, s, 0x82)    # $9C2E
			elif o.frame[s] == 0x02:
				_9c50(o, s)
				SolStage.call_at(o, s, 0x91)
			else:
				if o.left[s] == 0xFF:
					o.kind[s] = (o.kind[s] + 1) & 0xFF
				_9c50(o, s)
		0x02:
			o.far_x(s)
			o.carry = 1
			var v: int = o._sbc(0, o.z94)
			o.face[s] = v
			o.a[s] = v
			_8163(o, s, 0x80)
			o.kind[s] = (o.kind[s] + 1) & 0xFF
			_9c50(o, s)
		0x03:
			_9c9c(o, s)
		0x04:
			o.kind[s] = o.kind[s] & 0x80    # $9C06
		0x05:
			o.anim_first(s, 0x30)           # $9028
			if o.anim_a[s] == 0:
				o.kind[s] = 0x04
			_9cdd(o, s, 0x00)
			o.move(s)
		0x06:
			_9b3c(o, s)
		0x07:
			_9b61(o, s)
		0x08:
			o.face_hero(s)                  # $8118
			o.face[s] = o.face[s] ^ 0xFF    # $AE24
			o.anim_second(s, 0x2E)
		0x09:
			if ((o.y[s] >> 8) & 0xFF) == 0x3F:
				o.kind[s] = (o.kind[s] + 1) & 0xFF
			o.anim_second(s, 0x2D)
			o.z52 = (o.z52 - 0x0100) & 0xFFFF
			o.move(s)
		0x0A:
			o.anim_reset(s)                 # $BD9D, and it leaves nothing in A
			o.pic_lo[s] = 0
			o.pic_hi[s] = 0
			o.x[s] = o.hero_x
		0x0B:
			_9bcf(o, s)
		0x0C:
			o.anim_second(s, 0x2E)
			if o.left[s] == 0xFF:
				o.kind[s] = 0x04
			_9c50(o, s)


## $9C9C -- it falls, and the ground turns it round and stands it up.
static func _9c9c(o: SolObjects, s: int) -> void:
	o.fall(s, 0x04)                         # $B2BB
	if o.d[s] < 0x80:
		o.z90 = 0                           # $9CA6 -- $B0AE takes $90 as it is
		if o.probe_behind(s, 0x0000, 0x0100) >= 0x80:
			o.far_x(s)
			o.face[s] = o.z94 ^ 0xFF
			o.z52 = 0                       # $8133
			o.y[s] = o.y[s] & 0xFF00
			if o.z7f == 0x02:
				o.kind[s] = 0x05
			o.kind[s] = (o.kind[s] + 1) & 0xFF
	_9cdd(o, s, 0x10)
	o.anim_second(s, 0x2D)
	o.move(s)


## $9B3C -- taken off the stage: it is put back where the slot says and turned
## round, and the top bit of $0690 is dropped on the way out.
static func _9b3c(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x68)
	if o.left[s] == 0xFF:
		# $9B43 -- the slot number turned twice to the right through the
		# borrow $80E0 left up, which is why the top two bits are not the
		# slot's at all.
		var c0: int = o.carry
		var c1: int = s & 0x01
		var v: int = ((c1 << 7) | (c0 << 6) | (s >> 2)) & 0xFF
		o.a[s] = v
		o.face[s] = v ^ 0xFF
		_8163(o, s, 0x80)
		o.kind[s] = ((o.kind[s] & 0x7F) + 1) & 0xFF
	_9cdd(o, s, 0x00)
	o.move(s)


## $9B61 -- thrown: it falls until the ground, and the landing counts one off
## the turn it is on.
static func _9b61(o: SolObjects, s: int) -> void:
	o.fall(s, 0x06)
	var down := true
	if o.d[s] < 0x80:
		o.z90 = 0
		if o.probe_behind(s, 0x0000, 0x0100) >= 0x80:
			o.z52 = 0                       # $8133
			o.y[s] = o.y[s] & 0xFF00
			_9cdd(o, s, 0x40)
			# $9B85 -- the branch skips the write when bit 7 is clear, so it
			# is the one already finished off that is sent back to $89.
			if o.kind[s] >= 0x80:
				o.kind[s] = 0x89
			o.kind[s] = (o.kind[s] - 1) & 0xFF
			down = false
	if down:
		_9cdd(o, s, 0x40)
	o.anim_second(s, 0x2D)
	o.move(s)


## $9BCF -- the same landing, but it comes up facing the hero.
static func _9bcf(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x2D)
	if o.probe_behind(s, o.z90 & 0xFF, 0x0100) >= 0x80:
		o.far_x(s)
		o.face[s] = o.z94 ^ 0xFF
		o.z52 = 0
		o.y[s] = o.y[s] & 0xFF00
		o.kind[s] = (o.kind[s] + 1) & 0xFF
		return
	o.z52 = 0x0100                          # $9BF0
	o.move(s)


# ------------------------------------------------------------ the swimmer

## $99A2 -- thirteen turns, told apart by $0690.  $921F only paints, so the
## pool never sees it.
static func _99a2(o: SolObjects, s: int) -> void:
	# $8010 gets here through `ASL A`, and the index is never as much as $80,
	# so the carry a turn is handed is always down.
	o.carry = 0
	match o.kind[s] & 0x7F:
		0x00:
			_9a64(o, s, 0x35, 0x40)
		0x01, 0x07, 0x09:
			_9ac6(o, s)
		0x02:
			_a6d8(o, s, 0x10)               # $A6D6
			if o.far_y(s) != 0:
				o.kind[s] = (o.kind[s] + 1) & 0xFF
			else:
				o.kind[s] = 0x08
		0x03:
			_9a7c(o, s, 0x3D)
		0x04:
			_9ae7(o, s)
		0x05:
			_9a7c(o, s, 0x35)               # $9A8D
		0x06:
			if (o.noise & 0x01) != 0:
				o.kind[s] = 0x08            # $9ABD, and then one more
			o.kind[s] = (o.kind[s] + 1) & 0xFF
		0x08:
			_9a64(o, s, 0x33, 0x40)         # $99E1, without the facing
		0x0A:
			o.kind[s] = (o.kind[s] + 1) & 0xFF
		0x0B:
			_9a09(o, s)
		0x0C:
			_9a42(o, s)


## $9A64 / $99E1 -- walk a picture and, when it runs out, take a new count and
## step on.  $9A64 takes the hero's side first, $99E1 does not.
static func _9a64(o: SolObjects, s: int, n: int, count: int) -> void:
	if n != 0x33:
		o.far_x(s)                          # $AE30
		o.a[s] = o.z94
	o.anim_second(s, n)
	if n == 0x33 and o.frame[s] == 0x02:
		SolStage.call_at(o, s, 0x0A)        # $99EB -> $99FC
	if o.left[s] != 0xFF:
		return
	o.a[s] = count
	o.kind[s] = (o.kind[s] + 1) & 0xFF


## $9A7C / $9A8D -- the same, but what it steps on to is a wait of $10.
static func _9a7c(o: SolObjects, s: int, n: int) -> void:
	o.far_x(s)
	o.a[s] = o.z94
	o.anim_second(s, n)
	if o.left[s] != 0xFF:
		return
	o.b[s] = 0xFF                           # $9A9C -- what $80E0 left in A
	o.a[s] = 0x10
	o.kind[s] = (o.kind[s] + 1) & 0xFF


## $9AA8 -- the picture it wears while it is being hit.
static func _9aa8(o: SolObjects, s: int) -> void:
	o.anim_first(s, 0x36)                   # $9028
	if o.anim_a[s] == 0:
		o.cool[s] = 0x02


## $9AC6 -- the wait: it counts down, and being hit puts it into $9AA8.
static func _9ac6(o: SolObjects, s: int) -> void:
	if o.anim_a[s] != 0:
		_9aa8(o, s)
		return
	o.a[s] = (o.a[s] - 1) & 0xFF
	if o.a[s] == 0:
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.anim_second(s, 0x31)
	if o.cool[s] == 0x01:                   # $80DA
		o.anim_first(s, 0x36)               # $9AE1


## $9AE7 -- it rises towards the hero at a steady $10 a picture.
static func _9ae7(o: SolObjects, s: int) -> void:
	_a6d8(o, s, 0x10)
	if o.far_y(s) != 0:
		pass
	else:
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.z52 = 0x10
	if o.z95 < 0x80:
		o.flip_down()                       # $818F
	o.anim_second(s, 0x32)
	o.move(s)


## $9A09 -- it turns about when the walk runs out.
static func _9a09(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x34)
	if o.left[s] != 0xFF:
		return
	o.face[s] = o.face[s] ^ 0xFF
	o.kind[s] = (o.kind[s] + 1) & 0xFF


## $9A42 -- it walks ahead until something stops it, and then it is set down on
## a whole two pages along and starts over.
static func _9a42(o: SolObjects, s: int) -> void:
	var r: int = _a6d8(o, s, 0xA0)
	o.move(s)                               # $813F either way
	if r < 0x80:
		return
	o._adc(o.x[s] & 0xFF, 0x80)             # $9A53 -- only for the carry
	o.kind[s] = 0                           # $80B3, and it loses A doing it
	var hi: int = o._adc(0, (o.x[s] >> 8) & 0xFF) & 0xFE
	o.x[s] = hi << 8


## $AC73 -- it drops: the fall gets a touch quicker every eighth picture until
## it is going $20 a picture, and once it is past the hero it turns into
## behaviour $0C and stops.  What $AED9 draws is not the pool's business.
static func _ac73(o: SolObjects, s: int) -> void:
	var v: int = o.a[s]
	o.carry = 1
	o._sbc(v, 0x20)                         # $AC7B -- and the borrow is read on
	if o.carry == 0:                        # twice, here and at $AC99
		v = o._adc(v, o.b[s])
		o.a[s] = v
		if (o.clock & 0x07) == 0:
			o.carry = 1
			o._sbc(o.b[s], 0x02)
			if o.carry == 0:
				o.b[s] = (o.b[s] + 1) & 0xFF
	o.z52 = v
	if o.carry != 0:
		o.carry = 1
		o._sbc(o.hero_y & 0xFF, o.y[s] & 0xFF)
		o._sbc((o.hero_y >> 8) & 0xFF, (o.y[s] >> 8) & 0xFF)
		if o.carry == 0:
			o.mind[s] = 0x0C
			o.a[s] = 0
			o.b[s] = 0
	o.move(s)                               # $813F


## $9DBB -- a lift does not choose its own height: it is put wherever $75 says,
## sixteen picture-lines to the step, plus whatever the map is dragging down.
static func _9dbb(o: SolObjects, s: int) -> void:
	var lo: int = (o.z75 << 4) & 0xFF
	var hi: int = (o.z75 >> 4) & 0x0F
	o.carry = 0
	lo = o._adc(lo, o.z34 & 0xFF)
	if o.carry != 0:
		hi = (hi + 1) & 0xFF
	o.carry = 0
	var yl: int = o._adc(o.cam_y & 0xFF, lo)
	var yh: int = o._adc((o.cam_y >> 8) & 0xFF, hi)
	o.y[s] = yl | yh << 8


## $9D71 -- the lift proper: it looks right, sits at $75, walks its picture, and
## every time the walk moves on it lets out one of template $A2 and takes that
## one's speed for its own.
static func _9d71(o: SolObjects, s: int) -> void:
	o.face[s] = 0
	_9dbb(o, s)
	o.anim_second(s, 0x22)
	if o.pic_lo[s] | o.pic_hi[s] == 0 and o.frame[s] != o.c[s]:
		o.c[s] = o.frame[s]
		o.hatch_here(s, 0xA2)
		o.z50 = o.a[s] | o.b[s] << 8
	if o.left[s] == 0xFF:
		o.id[s] = 0                         # $80B9
	o.move(s)                               # $813F


## $9DAB -- the same lift without the hatching.
static func _9dab(o: SolObjects, s: int) -> void:
	_9dbb(o, s)
	o.anim_second(s, 0x23)
	if o.left[s] == 0xFF:
		o.id[s] = 0
	o.move(s)


# ---------------------------------------------------------------- the endings

## $AF31 -- the thing bursts: it is pushed a little the way it is not looking,
## walks the burst, and when that is over it is worth something and goes.
static func _af31(o: SolObjects, s: int, score: int) -> void:
	if o.cool[s] <= 1:
		o.face_hero(s)                      # $8118
		o.face[s] = o.face[s] ^ 0xFF        # $AE24
	# $AF14 -- a step of $20 away from where it looks.
	o.z50 = 0x20
	if (o.face[s] & 0x80) == 0:
		o.carry = 1
		var lo: int = o._sbc(0, o.z50 & 0xFF)
		var hi: int = o._sbc(0, (o.z50 >> 8) & 0xFF)
		o.z50 = lo | hi << 8
	o.move(s)
	o.anim_second(s, 0x04)
	if o.left[s] == 0xFF:                   # $80E0
		_a989(o, s, score)


## $A9AB -- and on the way out it may leave something to pick up.  Only a thing
## that was not being held on to, whose behaviour is at least eight, that is
## within five pages of the hero along, and that has room above it.  What is
## dropped is the plain one, or the better one once the thing was worth $32 or
## more and the stirred byte says so.
static func _a9ab(o: SolObjects, s: int, score: int) -> void:
	if (o.mind[s] & 0x40) != 0:
		return                              # $8173, $A9AE
	if (o.mind[s] & 0x3F) < 0x08:
		return                              # $A9B7
	if o.far_x(s) >= 0x05:
		return                              # $A9BE
	o.z90 = 0                               # $8121
	o.z92 = 0
	if o.probe_above(s, 0) >= 0x80:
		return                              # $A9C6
	var tpl := 0x12                         # $A9CC
	if score >= 0x32:
		# $A9D2 -- the ROR hands on bit nought of the stirred byte.
		if (o.noise & 0x01) != 0:
			tpl = 0x1B                      # $A9D5
	o.hatch_here(s, tpl)                    # $AAF1


## $A989 -- the slot is given up: the spawn id loses one of its lives and the
## slot goes back to nothing.  What it was worth is added to the score.
static func _a989(o: SolObjects, s: int, score: int) -> void:
	var free := true
	if (o.id[s] & 0xC0) != 0:
		pass                                # $A98F -- kept by its behaviour
	elif (o.id[s] & 0x3F) >= 0x20:
		pass                                # $A998 -- not one of the stage's own
	else:
		var n: int = o.mark[o.id[s] & 0x3F]
		if (n & 0x80) == 0:
			free = false                    # $A99D -- it was never out; keep it
		else:
			n = n & 0x7F
			# $A9A1 -- the take away leaves its own carry, and $AE30 just below
			# reads it without setting one of its own.
			o.carry = 1 if n >= 1 else 0
			o.mark[o.id[s] & 0x3F] = 0 if n == 0 else n - 1
			_a9ab(o, s, score)
	if free:
		o.id[s] = 0                         # $80B9
	o.score += score


# ------------------------------------------------------ what breaks the stage
#
# $BF3D..$BF69 -- a burst is a list of cells, counted from the one the slot
# stands in, and the $80 at the end closes it.  A crate is four cells, so most
# of the lists are four pairs.

const BURST_HIGH := [0xFF, 0xFD, 0xFF, 0xFE, 0x00, 0xFD, 0x00, 0xFE, 0x80]   # $BF46
const BURST_HERE := [0xFF, 0xFF, 0xFF, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x80]   # $BF4F
const BURST_LOW := [0xFF, 0x01, 0x00, 0x02, 0xFF, 0x02, 0x00, 0x01, 0x80]    # $BF58
const BURST_UNDER := [0xFF, 0x02, 0x00, 0x01, 0x80]                          # $BF5C
const BURST_FAR := [0xFF, 0x03, 0xFF, 0xFC, 0x00, 0x03, 0x00, 0xFC, 0x80]    # $BF61

const BURST_THREE := [BURST_HIGH, BURST_HERE, BURST_LOW]                     # $A896
const BURST_FOUR := [BURST_HIGH, BURST_HERE, BURST_LOW, BURST_FAR]           # $A8CB
const BURST_TWO := [BURST_HERE, BURST_UNDER]                                 # $A900
const BURST_ONE := [BURST_HERE]                                              # $A924


## $A931 -- a word from it every fourth picture.  Sound is not kept, so this
## is only where it would be said.
static func _a931(_o: SolObjects) -> void:
	pass                                    # $A937


## $A93C -- one step of a burst.  $0610 counts which of the lists has already
## been let off; at the last of them the burst is over and it answers $FF.  A
## picture the background already owes a row or a column lets nothing off at
## all, and the count is left where it was -- so a burst stretches out over
## however many pictures it needs.
static func _a93c(o: SolObjects, s: int, lists: Array) -> int:
	if o.a[s] == lists.size():
		return 0xFF                         # $A966
	if o.smash_list(s, lists[o.a[s]]) == 0:
		return 0                            # $A969
	o.a[s] = (o.a[s] + 1) & 0xFF            # $A95C
	return 0xFF if o.a[s] == lists.size() else 0


## $A8A7 -- what every one of them does first: it cannot be hurt while it goes
## off, it walks the third book of pictures, and the answer is whether it has
## got as far as its eighth.
static func _a8a7(o: SolObjects, s: int) -> bool:
	_a931(o)
	o.cool[s] = 0xFF                        # $80D4
	o.anim_second(s, 0x00, 3)               # $8985
	# $A8B2 -- the compare leaves its own carry behind it.
	o.carry = 1 if o.frame[s] >= 0x08 else 0
	return o.frame[s] >= 0x08


## $A89C and $A926 -- and when the walk has run out, what it was worth.
static func _a89c(o: SolObjects, s: int, score: int) -> void:
	if o.left[s] != 0xFF:
		return                              # $80E0
	_a989(o, s, score)


## $A883 -- [$00 and $01 finished] three lists, and a hundred for it.
static func _a883(o: SolObjects, s: int) -> void:
	if not _a8a7(o, s):
		return                              # $A886
	if _a93c(o, s, BURST_THREE) == 0:
		return                              # $A88B
	_a89c(o, s, 0x64)


## $A8B8 -- [$36 finished] four lists, and fifty.
static func _a8b8(o: SolObjects, s: int) -> void:
	if not _a8a7(o, s):
		return                              # $A8BB
	if _a93c(o, s, BURST_FOUR) == 0:
		return                              # $A8C0
	_a89c(o, s, 0x32)


## $A8D3 -- [$37 finished] the same three lists as $A883, but what it leaves
## behind when it is over is a thing of its own.
static func _a8d3(o: SolObjects, s: int) -> void:
	if not _a8a7(o, s):
		return                              # $A8D6
	if _a93c(o, s, BURST_THREE) == 0:
		return                              # $A8DB
	if o.left[s] != 0xFF:
		return                              # $80E0
	o.hatch_here(s, 0xE1)                   # $A8E2
	_a989(o, s, 0x32)


## $A8ED -- [$02 finished] two lists, and a hundred.
static func _a8ed(o: SolObjects, s: int) -> void:
	if not _a8a7(o, s):
		return                              # $A8F0
	if _a93c(o, s, BURST_TWO) == 0:
		return                              # $A8F5
	_a89c(o, s, 0x64)


## $A904 -- [$13 finished] one list only.
static func _a904(o: SolObjects, s: int) -> void:
	if not _a8a7(o, s):
		return                              # $A914
	if _a93c(o, s, BURST_ONE) == 0:
		return                              # $A919
	_a89c(o, s, 0x32)


## $A871 -- the cell the slot itself stands in is broken through.
static func _a871(o: SolObjects, s: int) -> int:
	return o.smash((o.x[s] >> 8) & 0xFF, (o.y[s] >> 8) & 0xFF)


## $A980 -- the low byte of the fall is set and its high byte taken one down,
## which carries the slot upward at that speed.
static func _a980(o: SolObjects, s: int, v: int) -> void:
	o.z52 = v | ((((o.z52 >> 8) - 1) & 0xFF) << 8)
	o.move(s)                               # $813F


## $A836 -- [$17] the one that bores upward.  It is carried up a picture at a
## time and breaks through every new row of cells it reaches; when it has been
## through as many rows as it was given, it is done with.  A picture where the
## background already owes a row or a column is sat out entirely -- it neither
## breaks nor moves.
static func _a836(o: SolObjects, s: int) -> void:
	o.z52 = 0x00C0 | ((((o.z52 >> 8) - 1) & 0xFF) << 8)
	if o.z26 != 0:
		o.z52 = 0                           # $8133
		return
	if ((o.y[s] >> 8) & 0xFF) == o.b[s]:
		o.move(s)                           # $A86E -- still in the same row
		return
	if o.row_due != 0 or o.col_due != 0:
		o.z52 = 0                           # $A84B
		return
	if _a871(o, s) == 0:
		o.b[s] = (o.y[s] >> 8) & 0xFF       # $A869
		o.move(s)
		return
	o.c[s] = (o.c[s] + 1) & 0xFF            # $A852
	if o.c[s] != o.d[s]:
		o.b[s] = (o.y[s] >> 8) & 0xFF
		o.move(s)
		return
	_a989(o, s, 0x00)                       # $A861
	o.z52 = 0


## $A7F0 -- [$16] and the one that bores downward.  The same, save that it is
## carried the other way and that finishing it tells the stage to move on.
static func _a7f0(o: SolObjects, s: int) -> void:
	o.z52 = (o.z52 & 0xFF00) | 0x40
	if o.z26 != 0:
		o.z52 = 0                           # $A820
		return
	if ((o.y[s] >> 8) & 0xFF) == o.b[s]:
		o.move(s)                           # $A828
		return
	if o.row_due != 0 or o.col_due != 0:
		o.z52 = 0
		return
	if _a871(o, s) == 0:
		o.b[s] = (o.y[s] >> 8) & 0xFF       # $A823
		o.move(s)
		return
	o.c[s] = (o.c[s] + 1) & 0xFF            # $A80A
	if o.c[s] != o.d[s]:
		o.b[s] = (o.y[s] >> 8) & 0xFF
		o.move(s)
		return
	_a989(o, s, 0x00)                       # $A819
	o.z7f = (o.z7f + 1) & 0xFF              # $A81E
	o.z52 = 0


## $A82B -- [$2E] the borer above, and when its slot has gone the stage is
## told to move on.
static func _a82b(o: SolObjects, s: int) -> void:
	_a836(o, s)
	if o.id[s] == 0:
		o.z7f = (o.z7f + 1) & 0xFF          # $A833


## $AA41 -- [$15] it walks one picture and then it is over.
static func _aa41(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x0B, 3)               # $8985
	if o.left[s] == 0xFF:
		_a989(o, s, 0x00)                   # $80E0


## $A96C -- [$04, $05 and $0A finished] it walks one picture and is carried
## up; the slot goes when the walk is over, and at once if the hero is being
## left alone.
static func _a96c(o: SolObjects, s: int) -> void:
	if o.hero_hurt != 0:
		o.id[s] = 0                         # $A97B
		return
	o.anim_second(s, 0x09, 3)               # $8985
	if o.left[s] == 0xFF:
		o.id[s] = 0                         # $80E0
		return
	_a980(o, s, 0xC0)                       # $A97E


## $A9F6 -- [$08 and $09 finished] a letter on its way to the bar.  While it
## is still being thrown ($0610 nought) it simply goes, leaving a spark and
## ten behind it.  After that it is drawn up to two rows under the top of the
## view and then carried leftward until it is seven cells in, where what it
## carries is written into the three the bar shows.
static func _a9f6(o: SolObjects, s: int) -> void:
	if o.a[s] == 0:
		o.hatch_here(s, 0x1B)               # $A9FB
		o.id[s] = 0                         # $80B9
		o.score += 0x0A                     # $A9E1
		return
	o.carry = 1
	var d: int = o._sbc((o.y[s] >> 8) & 0xFF, (o.cam_y >> 8) & 0xFF)
	if o.carry != 0 and d >= 0x03:
		_a980(o, s, 0x80)                   # $AA12
		return
	o.carry = 0                             # $AA17
	o.y[s] = (o._adc((o.cam_y >> 8) & 0xFF, 0x02) << 8) & 0xFFFF
	o.carry = 1                             # $AA22
	var e: int = o._sbc((o.x[s] >> 8) & 0xFF, (o.cam_x >> 8) & 0xFF)
	if e >= 0x07:
		if e < 0x0A:
			o.letters = o.b[s]              # $AA2F
			o.id[s] = 0
			return
		o.z50 = (o.z50 - 0x100) & 0xFFFF    # $AA38
	o.z50 = (o.z50 & 0xFF00) | 0x80         # $AA3A
	o.move(s)


# ------------------------------------------------------------- the behaviours

## $AFBA -- the one that walks the floor: it falls when there is nothing under
## it, turns at a wall, and turns again at the edge of what it is standing on.
static func _afba(o: SolObjects, s: int) -> void:
	if o.b[s] == 0xFF:
		_b03b(o, s)
		return
	if o.probe_behind(s, 0x0080, 0x0100) < 0x80:
		# $AFC9 -- nothing under it, so from here it is falling.
		o.kind[s] = 0x08
		o.c[s] = 0xFF
		o.d[s] = 0xFF
		o.b[s] = 0xFF
		o.move(s)
		return
	_ground(o, s)


## $AFD6 -- it is standing on something: it is lifted to the surface, and then
## it either walks on, stops at a wall or hops over what is in the way.
static func _ground(o: SolObjects, s: int) -> void:
	_lift(o, s)
	if o.kind[s] >= 0x02:                   # $AFE1
		# $AFE8 -- it is getting back up.  $99D9 hands back what is left of
		# the walk, and it is that, not the turn, that both compares read: the
		# turn is only over when the walk has run out, and on the one picture
		# eight are left it turns to face the hero first.
		o.anim_second(s, 0x02)              # $AFEA
		if o.left[s] != 0xFF:               # $AFED
			if o.left[s] != 0x08:           # $AFEF
				o.move(s)                   # $AFFC
				return
			o.face_hero(s)                  # $8118
			o.face[s] = o.face[s] ^ 0xFF    # $AE24
		o.kind[s] = 0                       # $80B3
		o.move(s)
		return
	o.anim_second(s, 0x00)
	# $B004 -- one step along, and the same offset is what it looks ahead with.
	o.step_facing(s, 0x10)
	if o.probe_ahead(s, 0x0080, 0x0040) < 0x80:
		o.kind[s] = 0                   # $B02C -- the way is clear
		o.move(s)
		return
	o.z50 = 0
	o.step_facing(s, 0x18)
	if o.probe_ahead(s, 0x0080, -0x0080) >= 0x80:
		o.face[s] = o.face[s] ^ 0xFF    # $B029 -- a wall; it turns round
		o.kind[s] = 0
		o.move(s)
		return
	o.z50 = 0
	if o.kind[s] == 0:
		# $B032 -- only a step up: it gathers itself and hops.
		o.kind[s] = 1
		o.c[s] = 0xD0
		o.d[s] = 0xFF
		o.b[s] = 0xFF
		o.move(s)
		return
	o.face[s] = o.face[s] ^ 0xFF
	o.kind[s] = 0
	o.move(s)


## $AFD6 / $B07B -- the slot is lifted to the top of what it landed on.
static func _lift(o: SolObjects, s: int) -> void:
	o.carry = 1
	var lo: int = o._sbc(o.z52 & 0xFF, o.z9d)
	var hi: int = o._sbc((o.z52 >> 8) & 0xFF, 0)
	o.z52 = lo | hi << 8


## $B03B -- and the same one while it is off the ground.
static func _b03b(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x01)
	o.fall(s, 0x02)                     # $B2BB
	if (o.d[s] & 0x80) == 0:
		# $B076 -- on the way down, and what it lands on stops it dead.
		if o.probe_behind(s, 0x0080, 0x0100) >= 0x80:
			_lift(o, s)
			o.c[s] = 0
			o.d[s] = 0
			o.b[s] = 0x80               # $815A
			o.move(s)
			return
	else:
		# $B04A -- on the way up, and a ceiling takes the rest of the rise.
		if o.probe_above(s, 0x0100) >= 0x80:
			o.c[s] = 0
			o.d[s] = 0
			o.b[s] = 0x80
	# $B05A -- either way it still looks where it is going.
	if o.kind[s] >= 0x02:
		o.move(s)
		return
	o.step_facing(s, 0x10)
	if o.probe_ahead(s, 0x0080, 0x0040) < 0x80:
		o.kind[s] = 0                   # $B070
	else:
		o.z50 = 0                       # $B06A
	o.move(s)


## $A10B -- the one that hangs from the top of the picture and swings at the
## hero.  $A0AB only shifts its colours, so nothing of it is kept here.
static func _a10b(o: SolObjects, s: int) -> void:
	var pull := o.far_x(s) >= 0x18
	if not pull:
		pull = o.far_y(s) >= 0x18
	if pull:
		o.carry = 1                                 # $A11C
		var yh: int = o._sbc((o.cam_y >> 8) & 0xFF, 0x01)
		var xh: int = o._adc((o.cam_x >> 8) & 0xFF, 0x08)
		o.y[s] = (o.y[s] & 0x00FF) | yh << 8
		o.x[s] = (o.x[s] & 0x00FF) | xh << 8
	if o.anim_a[s] != 0:
		_a167(o, s)
		return
	match o.kind[s]:
		0x00:
			_a2db(o, s)
		0x01:
			_a262(o, s)
		0x02:
			_a1f4(o, s)
		0x03:
			_a13d(o, s)
		0x04:
			_a2a7(o, s)
		_:
			o.missed(0x1E, false)


## $A1AD -- while anything else is still in the pool this one does nothing at
## all: the cartridge throws away two returns to get out of the way.
static func _busy(o: SolObjects) -> bool:
	for i in range(0x0B, 0, -1):
		if o.id[i] != 0:
			return true
	return false


## $A052 -- every eighth picture it leaves a piece of itself behind.
static func _a052(o: SolObjects, s: int) -> void:
	if (o.clock & 0x07) != 0:
		return
	var f := -1
	for i in range(0x0B, -1, -1):
		if o.id[i] == 0:
			f = i
			break
	if f < 0:
		return
	o.x[f] = o.x[0]
	o.y[f] = o.y[0]
	o.cool[s] = 0xFF                                # $80D4, on itself
	o.id[f] = 0xFF
	o.mind[f] = 0xA0
	o.life[f] = 0xA0
	o.pic_lo[f] = o.pic_lo[0]
	o.pic_hi[f] = o.pic_hi[0]
	o.face[f] = o.face[0]
	o.a[f] = 0x20
	o.frame[f] = 0
	o.left[f] = 0
	o.anim_a[f] = 0
	o.anim_b[f] = 0


## $A2DB -- hanging and swinging: the heading is turned toward a point above
## the hero, and two more headings shake the thing about it.
static func _a2db(o: SolObjects, s: int) -> void:
	var settle := (o.clock & 0x01) != 0 and (o.noise & 0x7E) == 0
	if settle:
		o.carry = 1
		var dx: int = o._sbc((o.x[0] >> 8) & 0xFF, (o.cam_x >> 8) & 0xFF)
		dx = o._sbc(dx, 0x02)
		o.carry = 1
		o._sbc(dx, 0x0C)                            # $A2ED -- and it leaves the
		settle = o.carry == 0                       # borrow for the height
		if settle:
			var dy: int = o._sbc((o.y[0] >> 8) & 0xFF, (o.cam_y >> 8) & 0xFF)
			dy = o._sbc(dy, 0x02)
			o.carry = 1
			o._sbc(dy, 0x0C)
			settle = o.carry == 0
	if settle:
		var v: int = o.noise if o.hero_suit != 0 else 0
		o.kind[s] = 0x02 if (v & 0x01) != 0 else 0x01
	_a052(o, s)
	var was: int = o.face[s]
	o.face_hero(s)
	if ((was ^ o.z94) & 0x80) != 0:
		o.d[s] = 0x05
	if (o.mind[s] & 0x40) == 0 and o.cool[s] == 0x01:
		o.face_hero(s)
		o.carry = 1                                 # $80DA left it up
		o.b[s] = o._adc(o.b[s], 0x10)
		o.anim_first(s, 0x1F)
		return
	if (o.clock & 0x07) == 0:
		var ty: int = (o.hero_y - 0x0100) & 0xFFFF
		if (o.hero_flags & 0x80) != 0:
			ty = (ty + 0x0200) & 0xFFFF
		o.turn_step(s, o.angle_to(s, o.hero_x, ty))
		o.heading(o.a[s], 0x00)
	if (o.clock & 0x07) == 0:
		o.b[s] = (o.b[s] + 2) & 0xFF        # $A36B -- twice, not once
	o.spin(o.b[s], 0x10)                            # $A371
	o.carry = 0
	var lo: int = o._adc(o.z50 & 0xFF, o.z90 & 0xFF)
	var hi: int = o._adc((o.z50 >> 8) & 0xFF, (o.z90 >> 8) & 0xFF)
	o.z50 = lo | hi << 8
	if (o.clock & 0x03) == 0:
		o.c[s] = (o.c[s] + 1) & 0xFF
	_a293(o, s, 0x00)
	if o.d[s] != 0:
		o.d[s] = (o.d[s] - 1) & 0xFF
		o.anim_second(s, 0x21)
	else:
		o.anim_second(s, 0x1C)
	o.move(s)


## $A293 -- one more heading, added to the step down rather than replacing it.
static func _a293(o: SolObjects, s: int, speed: int) -> void:
	o.spin(o.c[s], speed)
	o.carry = 0
	var lo: int = o._adc(o.z52 & 0xFF, o.z92 & 0xFF)
	var hi: int = o._adc((o.z52 >> 8) & 0xFF, (o.z92 >> 8) & 0xFF)
	o.z52 = lo | hi << 8


## $A262 -- winding up for the drop.
static func _a262(o: SolObjects, s: int) -> void:
	_a052(o, s)
	o.anim_second(s, 0x21)
	if o.left[s] == 0xFF:
		o.kind[s] = 0x04
		return
	if (o.clock & 0x03) == 0:
		o.c[s] = (o.c[s] + 2) & 0xFF
	_a293(o, s, 0x10)
	o.move(s)


## $A1F4 -- the drop itself.
static func _a1f4(o: SolObjects, s: int) -> void:
	if (o.clock & 0x03) == 0:
		o.c[s] = (o.c[s] + 1) & 0xFF
	_a293(o, s, 0x00)
	o.move(s)
	if _busy(o):
		return
	o.anim_second(s, 0x1E)
	# $A218 -- and only on the third step of that walk.
	if o.frame[s] != 0x02:                          # $80E6
		if o.left[s] == 0xFF:                       # $A24C
			o.kind[s] = 0                           # $A2D4
		return
	# $A21D -- and on step two it lets one go, which way round taken from the
	# hero's own byte and from the side it faces.
	var i: int = SolShots.free_slot(o)
	if i >= 0:
		o.s_b[i] = 0x40 if (o.hero_flags & 0x80) != 0 else 0xC0
		o.z90 = 0                                   # $A22F
		o.z92 = 0
		var c: int = (o.face[s] >> 7) & 1           # $A235
		SolShots.place(o, s, i, 0x0100 if c == 1 else 0xFF00, 0xFF80, c)
		SolShots.put(o, i, 0x88)                    # $A247
		return
	if o.left[s] == 0xFF:
		o.kind[s] = 0                               # $A2D4

## $A13D -- and once it is low enough it is gone.
static func _a13d(o: SolObjects, s: int) -> void:
	o.carry = 1
	var dy: int = o._sbc((o.y[s] >> 8) & 0xFF, (o.cam_y >> 8) & 0xFF)
	if o.carry != 0 and dy == 0x08:
		o.kind[s] = 0
		return
	o.carry = 1
	o._sbc(dy, 0x04)
	o.pic_lo[0] = 0x66 if o.carry != 0 else 0x6E
	o.pic_hi[0] = 0x02
	o.z52 = 0x20
	o.move(s)
	o.anim_second(s, 0x1C)


## $A2A7 -- the pause at the top before it comes down again.
static func _a2a7(o: SolObjects, s: int) -> void:
	if _busy(o):
		return
	o.anim_second(s, 0x1D)
	# $A2AF -- one picture of the wind-up, and only while the walk has just
	# that much of itself left, lets a whole ring of them go.
	if o.frame[s] == 0x01 and o.left[s] == 0x20:
		SolStage.call_at(o, s, 0x07)                # $A2C1 -> $A1BD
	if o.frame[s] == 0x03:
		return
	if o.left[s] == 0xFF:
		o.kind[s] = 0                               # $A2D4


## $A167 -- what it does while it is being hit.
static func _a167(o: SolObjects, s: int) -> void:
	_a052(o, s)
	o.anim_first(s, 0x1F)
	if o.anim_a[s] == 0:
		o.carry = 1
		var d: int = o._sbc((o.x[s] >> 8) & 0xFF, (o.cam_x >> 8) & 0xFF)
		if o.carry == 0:
			o.carry = 0                             # $A183 -- off to the left
			o.x[s] = (o.x[s] & 0x00FF) \
					| o._adc(0x11, (o.cam_x >> 8) & 0xFF) << 8
		else:
			o.carry = 1
			o._sbc(d, 0x11)
			if o.carry != 0:
				o.x[s] = (o.x[s] & 0x00FF) \
						| o._adc(0xFF, (o.cam_x >> 8) & 0xFF) << 8
	if o.left[s] >= 0x10:
		o.carry = 1
		o._sbc(o.left[s], 0x1C)
		var n: int = 0x20 if o.carry == 0 else 0x40
		if (o.face[s] & 0x80) == 0:
			o.z50 = n
		else:
			o.z50 = (0x100 - n) | 0xFF00
	o.move(s)


## $A53D -- the long one: thirty-two turns, read off $0690, that carry a thing
## through gathering itself, jumping, falling and landing again.
static func _a53d(o: SolObjects, s: int) -> void:
	# $921F only lights the slot up while its life is low; nothing of the slot
	# itself moves, so there is nothing here to keep.
	match o.kind[s]:
		0x00, 0x05, 0x0A, 0x1F:
			o.face_hero(s)
			_a7e7(o, s, 0x14)
		0x01, 0x06, 0x0B:
			_a727(o, s)
		0x02, 0x07, 0x0C:
			o.anim_second(s, 0x10)
			if o.frame[s] == 0x04:
				SolStage.call_at(o, s, 0x7C)    # $A70B
				return
			if o.left[s] == 0xFF:
				o.kind[s] = (o.kind[s] + 1) & 0xFF
		0x03, 0x08:
			o.anim_second(s, 0x14)
			if o.left[s] == 0xFF:
				_8163(o, s, 0xD0)               # $8161
				o.kind[s] = (o.kind[s] + 1) & 0xFF
		0x04:
			_a5fb(o, s)
		0x09:
			_a624(o, s)
		0x0D:
			o.kind[s] = 0x0F
		0x0E:
			_a7c9(o, s)
		0x0F:
			_a7e7(o, s, 0x16)
		0x10:
			o.anim_second(s, 0x14)
			if o.left[s] == 0xFF:
				_8163(o, s, 0xF0)
				o.kind[s] = (o.kind[s] + 1) & 0xFF
		0x11:
			_a681(o, s)
		0x12, 0x1B:
			_8163(o, s, 0x74)                   # $A7C0
			_a7e7(o, s, 0x17)
		0x13, 0x1C:
			_a6ab(o, s)
		0x14:
			_a5c6(o, s, 0x11)                   # $A5B2
			# $A5B7 -- $80E0 asks whether the walk has just run out, and that
			# is what lets the pair go.
			if o.left[s] == 0xFF:
				SolStage.call_at(o, s, 0x79)    # $A5BA
		0x15, 0x17:
			_a7e7(o, s, 0x12)
		0x16:
			_a5c6(o, s, 0x18)                   # $A598
			if o.kind[s] != 0x17:
				return                          # $A5A2
			# $A5A6 -- the ROR hands over bit nought of the clock: one picture
			# in two lets the pair go, the other steps the turn on.
			if (o.clock & 0x01) != 0:
				SolStage.call_at(o, s, 0x79)    # $A5A9
			else:
				o.kind[s] = 0x19                # $A5AC
		0x18:
			_a5c6(o, s, 0x18)
		0x19, 0x1E:
			_a653(o, s)
		0x1A:
			o.kind[s] = 0                       # $A6D3
		0x1D:
			o.anim_second(s, 0x1B)
			if o.left[s] == 0xFF:
				_815a(o, s)
				o.kind[s] = (o.kind[s] + 1) & 0xFF
		0x20:
			o.kind[s] = 0x02                    # $A716
		_:
			o.missed(0x1B, false)


## $A7E7 -- play a walk and step on to the next turn when it has run out.
static func _a7e7(o: SolObjects, s: int, n: int) -> void:
	o.anim_second(s, n)
	if o.left[s] == 0xFF:
		o.kind[s] = (o.kind[s] + 1) & 0xFF


## $A5C6 -- the same, but the slot is stopped dead as it steps on.
static func _a5c6(o: SolObjects, s: int, n: int) -> void:
	o.anim_second(s, n)
	if o.left[s] != 0xFF:
		return
	_815a(o, s)
	o.kind[s] = (o.kind[s] + 1) & 0xFF


## $815A -- stopped, and told to hold still.
static func _815a(o: SolObjects, s: int) -> void:
	o.c[s] = 0
	o.d[s] = 0
	o.b[s] = 0x80


## $A6D6 / $A6D8 -- a step along of `n`, and what lies that way; something in
## the way takes the step back off again.  Answers what was found.
static func _a6d8(o: SolObjects, s: int, n: int) -> int:
	o.step_facing(s, n)
	var r: int = o.probe_fwd(s, 0x0080, 0x0040)
	if r >= 0x80:
		o.z50 = 0
	return r


## $A5FB -- falling, and landing on whatever is under it.
static func _a5fb(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x0F)
	o.fall(s, 0x02)
	_a6d8(o, s, 0x10)
	if (o.d[s] & 0x80) == 0 and o.probe_behind(s, 0x0080, 0x0100) >= 0x80:
		o.z52 = 0
		o.y[s] = o.y[s] & 0xFF00
		_8163(o, s, 0xC0)                       # $816F
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.move(s)


## $A624 -- the same fall, but it looks behind itself rather than ahead.
static func _a624(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x0F)
	o.fall(s, 0x02)
	o.face[s] = (o.face[s] ^ 0xFF) & 0xFF
	_a6d8(o, s, 0x10)
	o.face[s] = (o.face[s] ^ 0xFF) & 0xFF
	if (o.d[s] & 0x80) == 0 and o.probe_behind(s, 0x0080, 0x0100) >= 0x80:
		o.z52 = 0
		o.y[s] = o.y[s] & 0xFF00
		_8163(o, s, 0xD0)                       # $8161
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.move(s)


## $A653 -- and the same again, faster, and without setting a new speed.
static func _a653(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x0F)
	o.fall(s, 0x02)
	o.face[s] = (o.face[s] ^ 0xFF) & 0xFF
	_a6d8(o, s, 0x20)
	o.face[s] = (o.face[s] ^ 0xFF) & 0xFF
	if (o.d[s] & 0x80) == 0 and o.probe_behind(s, 0x0080, 0x0100) >= 0x80:
		o.z52 = 0
		o.y[s] = o.y[s] & 0xFF00
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.move(s)


## $A681 -- the long fall, which lands on turn fourteen rather than the next.
static func _a681(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x0F)
	o.fall(s, 0x02)
	_a6d8(o, s, 0x28)
	if (o.d[s] & 0x80) == 0 and o.probe_behind(s, 0x0080, 0x0100) >= 0x80:
		o.z52 = 0
		o.y[s] = o.y[s] & 0xFF00
		o.kind[s] = 0x0E
	o.move(s)


## $A6AB -- the drop that ends when the picture has caught up, not when the
## ground has.
static func _a6ab(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x0F)
	o.fall(s, 0x05)
	if (o.d[s] & 0x80) == 0:
		o.carry = 0
		var v: int = o._adc((o.cam_y >> 8) & 0xFF, 0x03)
		o.carry = 1
		o._sbc(v, (o.y[s] >> 8) & 0xFF)
		if o.carry == 0:
			v = o._adc(v, 0x01)
			o.carry = 1
			o._sbc(v, (o.y[s] >> 8) & 0xFF)
			if o.carry != 0:
				o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.move(s)


## $A7C9 -- a look ahead settles whether it goes on or gives up.
static func _a7c9(o: SolObjects, s: int) -> void:
	var r: int = _a6d8(o, s, 0x10)
	if r < 0x80:
		_a7e7(o, s, 0x1A)
		return
	o.kind[s] = 0x1B if (o.noise & 0x03) == 0 else 0x12


## $A727 -- the middle of the long one: it is hit, it rears up, and once it is
## up it lets something out of itself.
static func _a727(o: SolObjects, s: int) -> void:
	if o.anim_a[s] != 0:
		_a750(o, s)
		return
	o.anim_second(s, 0x0E)
	if o.left[s] == 0xFF:
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.face_hero(s)
	if (o.mind[s] & 0x40) == 0 and o.cool[s] == 0x01:
		o.anim_first(s, 0x13)
		return
	o.a[s] = o.life[s]


## $A750 -- and what it does while it is up.
static func _a750(o: SolObjects, s: int) -> void:
	o.anim_first(s, 0x13)
	if o.anim_a[s] == 0:
		o.anim_second(s, 0x0E)
		o.left[s] = 0x08
		return
	var f: int = o.frame[s]
	if f == 0x01:
		o.carry = 1
		var d: int = o._sbc(o.a[s], o.life[s])
		var r: int = _a6d8(o, s, 0x12 if d < 0x02 else 0x20)
		if r >= 0x80:
			if o.far_x(s) < 0x05 and (o.noise & 0x01) != 0:
				o.kind[s] = 0x1B
			else:
				o.kind[s] = 0x12
		o.move(s)
		return
	if f == 0x04 and o.left[s] == 0x01:
		o.hatch_here(s, 0x6C if (o.face[s] & 0x80) != 0 else 0x75)


## $8802 -- the leaper.  Every other picture it takes one of eight turns, read
## off $0690, and the turns run into one another rather than round a loop.
static func _8802(o: SolObjects, s: int) -> void:
	if ((s ^ o.clock) & 0x01) == 0:
		return
	match o.kind[s]:
		0x00:
			if _898a(o, s) < 0x05:
				o.kind[s] = 0x08
				return
			_888f(o, s)
		0x02:
			o.step_facing(s, 0x0C)
			if o.probe_ahead(s, 0x0080, 0x0040) >= 0x80:
				o.z50 = 0                       # $8943 -- something in the way
			else:
				o.z50 = 0
				o.step_facing(s, 0x0C)
				if o.probe_ahead(s, 0x0080, -0x0080) >= 0x80:
					o.z50 = 0
			_8946(o, s)
		0x04:
			o.anim_second(s, 0x0F, 3)
			if o.left[s] == 0xFF:
				o.kind[s] = 0
		0x06:
			_8946(o, s)
		0x08:
			var far: int = o.far_x(s)
			if far < 0x04:
				o.kind[s] = 0x0C
				return
			if far >= 0x08:
				o.kind[s] = 0
			o.anim_second(s, 0x0E, 3)
			_898a(o, s)
			if o.frame[s] == 0x02:
				_8894(o, s)
		0x0A:
			o.face_hero(s)
			if ((o.z90 >> 8) & 0xFF) < 0x06:
				_888f(o, s)
				return
			o.face[s] = (o.face[s] ^ 0xFF) & 0xFF
			o.kind[s] = 0
		0x0C, 0x0E:
			_8829(o, s)
		_:
			o.missed(0x18, false)


## $8829 / $882D -- standing still and looking: near enough and it gathers
## itself, far enough and it gives up.
static func _8829(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x13 if o.kind[s] == 0x0E else 0x12, 3)
	var far: int = _898a(o, s)
	if far >= 0x05:
		o.kind[s] = 0
		return
	if far < 0x03 and o.kind[s] != 0x0E:
		o.kind[s] = 0x0A
		return
	# $8848 -- and on step two it lets one go.  It turns itself round for the
	# length of the spawn, because $8ECB reads the side it faces, and turns
	# straight back again.
	if o.frame[s] != 0x02:                  # $80E6
		return
	var i: int = SolShots.free_slot(o)
	if i < 0:
		return
	o.face[s] = (o.face[s] ^ 0xFF) & 0xFF   # $AE24
	SolShots.put(o, i, 0xAD)                # $8855
	var c: int = SolShots.face_step(o, s, i)        # $8ECB
	o.z90 = 0                               # $885D -- and then $8121 wipes it
	o.z92 = 0
	SolShots.place(o, s, i, 0x0000, 0xFFC0, c)
	o.face[s] = (o.face[s] ^ 0xFF) & 0xFF   # $8869


## $898A -- look at the hero and then turn the other way, and answer how far
## off he is.
static func _898a(o: SolObjects, s: int) -> int:
	o.face_hero(s)
	o.face[s] = (o.face[s] ^ 0xFF) & 0xFF
	return (o.z90 >> 8) & 0xFF


## $888F -- the gather before the leap.
static func _888f(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x0D, 3)
	_8894(o, s)


## $8894 -- and what it stands on decides whether the leap happens at all.
static func _8894(o: SolObjects, s: int) -> void:
	var solid := _87cd(o, s, o.probe_behind(s, 0x0080, 0x0100)) >= 0x80
	if not solid:
		solid = _87cd(o, s, o.probe_behind(s, 0x0000, 0x0100)) >= 0x80
		if not solid:
			o.kind[s] = 0x06
			_8163(o, s, 0xFF)
			return
	o.z52 = 0                                   # $8133
	o.y[s] = (o.y[s] & 0xFF00) | 0x10
	o.step_facing(s, 0x20)
	if o.probe_ahead(s, 0x0080, 0x0040) < 0x80:
		o.move(s)
		return
	o.z50 = 0
	o.step_facing(s, 0x20)
	if o.probe_ahead(s, 0x0080, -0x0080) < 0x80:
		o.kind[s] = 0x02
		_8163(o, s, 0xB0)
		o.move(s)
		return
	if o.kind[s] == 0x0A:
		o.anim_reset(s)
		o.kind[s] = 0x0E
	o.z50 = 0
	o.move(s)


## $8946 -- in the air: it falls, and what it meets decides where it lands.
static func _8946(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x10, 3)
	o.fall(s, 0x04)
	if (o.d[s] & 0x80) != 0:
		if _87cd(o, s, o.probe_above(s, 0x0080)) >= 0x80:
			o.c[s] = 0                          # $815A
			o.d[s] = 0
			o.b[s] = 0x80
	else:
		if _87cd(o, s, o.probe_behind(s, 0x0080, 0x0100)) >= 0x80:
			o.z52 = 0                           # $8133
			o.y[s] = (o.y[s] & 0xFF00) | 0x10
			o.kind[s] = 0x04
	o.move(s)


## $8163 -- the three speed bytes at once.
static func _8163(o: SolObjects, s: int, n: int) -> void:
	o.c[s] = n
	o.d[s] = 0xFF
	o.b[s] = 0xFF


## $87CD -- what the probe found is kept in $0610, and a particular change of
## ground lets something out.  Answers the probe either way.
static func _87cd(o: SolObjects, s: int, r: int) -> int:
	var was: int = o.a[s]
	o.a[s] = r
	if r < 0x80 and was != r and (was & 0x78) >= 0x60:
		var m: int = was & 0x18
		if (m == 0 or m >= 0x10) and o.stage != 0x09:
			o.hatch(o.x[s], (o.y[s] & 0xFF00), 0x36)
	return o.a[s]


## $8E86 -- the one that winds itself up: it looks at the hero while its number
## is even, and while it is odd it plays the second half and stops.
static func _8e86(o: SolObjects, s: int) -> void:
	if (o.kind[s] & 0x01) == 0:
		o.anim_second(s, 0x5E)
		o.face_hero(s)
		if o.far_y(s) >= 0x02:
			return
	else:
		o.anim_second(s, 0x5F)
		# $8EA4 -- and only on the third step of that walk.
		if o.frame[s] != 0x02:                  # $80E6
			if o.left[s] != 0xFF:               # $80E0
				return
			o.kind[s] = (o.kind[s] + 1) & 0xFF
			return
		# $8EA9 -- and while there is room it lets one go and does nothing
		# else; only when the pool is full does the walk step on.
		var i: int = SolShots.free_slot(o)
		if i >= 0:
			SolShots.put(o, i, 0xA1)            # $8EBC
			var c: int = SolShots.face_step(o, s, i)    # $8ECB
			SolShots.place(o, s, i, o.z90, 0xFF80, c)
			return
	if o.left[s] != 0xFF:                       # $80E0
		return
	o.kind[s] = (o.kind[s] + 1) & 0xFF


## $AA51 -- the one that hatches.  Every fourth picture it looks whether the
## hero is above it and near enough, plays its one walk, and on two of the
## steps of that walk it lets something out of itself.
static func _aa51(o: SolObjects, s: int) -> void:
	if ((s ^ o.clock) & 0x03) != 0:
		return
	o.carry = 1
	var dx: int = o._sbc((o.x[s] >> 8) & 0xFF, (o.cam_x >> 8) & 0xFF)
	var up := false
	if dx < 0x10:
		o.far_y(s)
		up = (o.z95 & 0x80) != 0
	if up:
		o.a[s] = 0x06
		o.anim_second(s, 0x06)
		if o.left[s] == 0xFF:
			o.anim_reset(s)
			return
	else:
		if (o.a[s] & 0x80) != 0:
			return
		o.anim_second(s, 0x06)
		if o.left[s] == 0xFF:
			return
	var f: int = o.frame[s]                     # $80E6
	if f == 0x02:
		return                                  # $AA87 -- only a noise
	if f == 0x05 or (f == 0x07 and o.stage != 0):
		o.hatch_here(s, 0x00)


## $ADC5 -- the walker that turns round at a ledge.  Every other picture it
## either looks down in front of itself or takes a step, never both.
static func _adc5(o: SolObjects, s: int) -> void:
	var t: int = (s ^ o.clock) & 0xFF
	if (t & 0x01) == 0:
		return
	if ((t >> 1) & 0x07) == 0:
		if o.far_y(s) < 0x02:
			o.far_x(s)
			o.face[s] = (o.z94 ^ 0xFF) & 0xFF   # $AE27
	var flip := false
	if (o.clock & 0x02) == 0:
		if o.probe_at(s, 0x0080, 0x0100) < 0x80:
			flip = true                         # $ADFA -- nothing to stand on
		else:
			o.carry = 1                         # $ADFC -- and up onto it
			var lo: int = o._sbc(o.z52 & 0xFF, o.z9d)
			var hi: int = (o.z52 >> 8) & 0xFF
			if o.carry == 0:
				hi = (hi - 1) & 0xFF
			o.z52 = lo | hi << 8
	else:
		o.step_facing(s, 0x08)
		if o.probe_ahead(s, 0x0080, 0x0040) >= 0x80:
			o.z50 = 0                           # $812C -- a wall in the way
			flip = true
	if flip:
		o.face[s] = (o.face[s] ^ 0xFF) & 0xFF   # $AE24
	o.move(s)
	o.anim_second(s, 0x0D)


## $8AA2 -- the flyer.  It never leaves the picture while the hero is near, it
## drifts on its own pair of speed bytes, and once it is hit it falls away.
static func _8aa2(o: SolObjects, s: int) -> void:
	o.id[s] = (o.id[s] & 0xBF) | 0x40           # $906E -- stay put for now
	if o.anim_a[s] != 0:
		_8a84(o, s)
		return
	if (o.mind[s] & 0x40) == 0 and o.cool[s] == 0x01:
		o.c[s] = 0                              # $B21C
		o.d[s] = 0
		o.face_hero(s)
		o.anim_first(s, 0x7B)
		return
	o.anim_second(s, 0x7A)
	if o.far_x(s) >= 0x0E:
		o.id[s] = o.id[s] & 0xBF                # $906C -- far enough to let go
	_8ae1(o, s)
	o.carry = 1                                 # $8AD3 -- the map's own drag
	var lo: int = o._sbc(o.z52 & 0xFF, o.z34)
	var hi: int = (o.z52 >> 8) & 0xFF
	if o.carry == 0:
		hi = (hi - 1) & 0xFF
	o.z52 = lo | hi << 8
	o.move(s)


## $8A84 -- the same one after a knock: it drops, and which way it drops is
## settled once by the hash of the memory.
static func _8a84(o: SolObjects, s: int) -> void:
	o.anim_first(s, 0x7B)
	if o.anim_a[s] == 0:
		o.kind[s] = 0x05 if (o.noise & 1) != 0 else 0x02
	o.step_along(s, 0x40)
	o.move(s)


## $8AE1 -- which of the flyer's six turns it is taking, read off $0690.
static func _8ae1(o: SolObjects, s: int) -> void:
	match o.kind[s]:
		0x00, 0x03:
			_8b20(o, s)
		0x01, 0x04:
			_89d6(o, s)
		0x02:
			_8af5(o, s, 0x10)
		0x05:
			_8af5(o, s, 0xF0)
		0x06:
			o.kind[s] = 0                       # $80B3
		_:
			o.missed(0x28, false)


## $8B20 -- the drift: it looks the hero's way, keeps a steady climb, and only
## once he is properly below does it settle into the next turn.
static func _8b20(o: SolObjects, s: int) -> void:
	_8b4d(o, s)
	o.z52 = (o.z52 & 0xFF00) | 0x08
	o.far_y(s)
	if (o.z95 & 0x80) == 0:
		o.flip_down()                           # $818F
	if (o.z95 & 0x80) == 0:
		return
	if ((o.z92 >> 8) & 0xFF) != 0x01:
		return
	o.carry = 1
	var v: int = o._sbc((o.at_x[s] >> 8) & 0xFF, 0x01)
	if v >= 0x0E:
		return
	o.b[s] = 0x80
	o.kind[s] = (o.kind[s] + 1) & 0xFF


## $89D6 -- the run: a counter winds down, and while it does the thing is
## pushed sideways a little every other picture.
static func _89d6(o: SolObjects, s: int) -> void:
	o.face_hero(s)
	o.b[s] = (o.b[s] - 1) & 0xFF
	if o.b[s] == 0:
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	if o.b[s] == 0x40:
		# $89E8 -- it lets a puff of smoke go and gathers its own speed at the
		# same moment; with the pool full it only moves.
		var i: int = SolShots.free_slot(o)
		if i < 0:
			o.move(s)                                   # $8A26
			return
		SolShots.put(o, i, 0xAE)                        # $89ED
		var c: int = SolShots.face_step(o, s, i)        # $8ECB
		SolShots.place(o, s, i, o.z90, 0x0100, c)       # $89F5
		if (o.face[s] & 0x80) == 0:                     # $89FA
			o.c[s] = 0x20
			o.d[s] = 0x00
		else:
			o.c[s] = 0xE0
			o.d[s] = 0xFF
	o.nudge(s, 0xFE if (o.d[s] & 0x80) == 0 else 0x02)   # $8B95
	o.speed_to_step(s)
	if (o.clock & 1) == 0:
		o.move(s)
		return
	o.a[s] = ((o.a[s] & 0xFE) + 2) & 0xFF        # $8A19, the carry is still up
	o.step_of(s)                                # $8066
	o.z50 = 0                                   # $812C
	o.move(s)


## $8AF5 / $8AF9 -- the turn away, up or down, until the hero is far enough
## below for the next turn to begin.
static func _8af5(o: SolObjects, s: int, n: int) -> void:
	o.z52 = (o.z52 & 0xFF00) | n
	if n >= 0x80:
		o.z52 = (o.z52 & 0x00FF) | 0xFF00
	_8b4d(o, s)
	o.face_hero(s)
	var v: int = o.far_y(s)
	if v >= 0x03:
		o.b[s] = v
		o.kind[s] = (o.kind[s] + 1) & 0xFF
	o.z50 = 0                                   # $812C
	o.move(s)


## $8B4D -- the pair of speed bytes is cleared and then leaned one way or the
## other depending on which side of the thing the hero stands.
static func _8b4d(o: SolObjects, s: int) -> void:
	o.b[s] = 0
	_8b55(o, s)


## $8B55 -- the same without the clearing, and it answers with the carry: up
## where it turned away early, down where it took the step.  What follows it
## reads the map with that carry still in hand.
static func _8b55(o: SolObjects, s: int) -> void:
	o.face_hero(s)
	if ((o.face[s] ^ o.d[s]) & 0x80) != 0:
		if (o.b[s] & 0x01) != 0:
			o.carry = 1                     # $8B64
			return
		o.nudge(s, 0x01 if (o.d[s] & 0x80) == 0 else 0xFF)
	else:
		if (o.b[s] & 0x02) != 0:
			o.carry = 1                     # $8B7A
			return
		if o.z94 >= 0x02:
			o.nudge(s, 0xFE if (o.d[s] & 0x80) == 0 else 0x02)
	o.speed_to_step(s)
	o.carry = 0                             # $8B88


## $8F8D -- the one that keeps its back to the hero: it takes its heading from
## the other side of its own facing and shuffles along the floor.
static func _8f8d(o: SolObjects, s: int) -> void:
	if o.anim_a[s] != 0:
		_8fd9(o, s)
		return
	if o.cool[s] == 0x01:
		o.anim_first(s, 0x5D)           # $9028 -- the moment it is hit
		return
	if ((s ^ o.clock) & 1) != 0:
		return
	o.a[s] = (o.face_hero_far(s) ^ 0xFF) & 0xFF     # $810D, $9053
	o.hold_on(s)
	if o.probe_behind(s, 0x0080, 0x0100) < 0x80:
		o.anim_second(s, 0x5C)          # $8FD4 -- nothing under it
		return
	var turned: int = (o.face[s] ^ o.hero_face) & 0xFF
	var r := o.step_and_look(s, 0x20 if (turned & 0x80) != 0 else 0x10)
	if r >= 0x80:
		o.anim_second(s, 0x5C)
		return
	o.anim_second(s, 0x08 if (turned & 0x80) != 0 else 0x5B)
	o.move(s)


## $8FD9 -- and the same one once it has been knocked about.
static func _8fd9(o: SolObjects, s: int) -> void:
	o.anim_first(s, 0x5D)
	o.face_hero(s)                      # $8118
	o.a[s] = o.face[s]                  # $9053
	o.hold_on(s)
	o.face[s] = o.face[s] ^ 0xFF
	var r := o.probe_behind(s, 0x0080, 0x0100)
	o.face[s] = o.face[s] ^ 0xFF
	if r >= 0x80:
		o.step_and_look(s, 0x40)
	o.move(s)


## $B0BB -- the thing that asks the hero to do something when it is hit.
static func _b0bb(o: SolObjects, s: int) -> void:
	if o.cool[s] == 0x09 and o.wants == 0:
		o.wants = 4


# ----------------------------------------------------------------- the pickups

## $8398 -- behaviour $3F is a family: which one runs is $0690.
static func _pickup(o: SolObjects, s: int) -> void:
	o.y_reg = o.kind[s]                     # $839B TAY
	match o.kind[s]:
		0x00, 0x0A: _k86a1(o, s)
		0x02: _k86c9(o, s)
		0x04: _k8729(o, s)
		0x06: _8767(o, s)
		0x08: _87ab(o, s)
		0x0C: _k861c(o, s)
		0x0E: _k85ea(o, s, 0x00)
		0x10: _k85ea(o, s, 0xFF)
		0x12: _k856c(o, s, 0x75, 0x00)
		0x14: _k856c(o, s, 0x76, 0xFF)
		0x16: _k8545(o, s)
		0x18: _k84fb(o, s)
		0x1A: _84ef(o, s)
		0x1C: _k84d6(o, s)
		0x1E: _k84ba(o, s)
		0x20: _849c(o, s, 0x00)
		0x22: _849c(o, s, 0xFF)
		0x26: _842f(o, s)
		0x2A: _83d7(o, s)
		0x24: _83ef(o, s)
		0x28: _8457(o, s)
		0x2C: _k865c(o, s)
		_: o.missed(0x3F, false)


## $8359 -- and the same family once it has been finished off.
static func _pickup_dead(o: SolObjects, s: int) -> void:
	o.y_reg = o.kind[s]                     # $835C TAY
	match o.kind[s]:
		0x00, 0x02, 0x04, 0x0E, 0x10: _af31(o, s, 0x32)     # $8F83
		0x06: _8767(o, s)
		0x08: _87ab(o, s)
		0x0A: _8f68(o, s)                   # $8F68
		0x0C: _af31(o, s, 0x0A)             # $8F7B
		0x12, 0x14: _af31(o, s, 0x14)       # $8F72
		0x16: _k8545(o, s)
		0x18: _8f68(o, s)                   # $8F65 -- a noise, then $8F68
		0x1A, 0x2C: _a989(o, s, 0x00)       # $8F76
		0x1C: _8ee6(o, s)
		0x1E: _k84aa(o, s)
		0x24: _83ef(o, s)
		0x28: _8457(o, s)
		0x20: _849c(o, s, 0x00)
		0x22: _849c(o, s, 0xFF)
		0x26: _842f(o, s)
		0x2A: _83d7(o, s)
		_: o.missed(0x3F, true)


## $87A2 -- the picture is dropped, so nothing of it is drawn.
static func _87a2(o: SolObjects, s: int) -> void:
	o.pic_lo[s] = 0
	o.pic_hi[s] = 0


## $8767 -- [kind $06] it burns down: $0640 counts, and while it is running the
## walk is shown; at nothing it throws a spark off every eighth picture and the
## count is put back up, so it sits at the end and keeps sparking.
static func _8767(o: SolObjects, s: int) -> void:
	o.d[s] = (o.d[s] - 1) & 0xFF            # $8767
	if o.d[s] != 0:
		# $8796 -- the CMP's own carry; under $30 the walk is still shown.
		o.carry = 1 if o.d[s] >= 0x30 else 0
		if o.carry == 0:
			o.anim_second(s, 0x6F)          # $879D
		else:
			_87a2(o, s)
		return
	var t: int = (s ^ o.clock) & 0xFF       # $876C
	if (t & 0x03) != 0:
		o.d[s] = (o.d[s] + 1) & 0xFF        # $878E
		_87a2(o, s)
		return
	if (t & 0x07) != 0:                     # $8779, a noise first
		o.d[s] = (o.d[s] + 1) & 0xFF
		_87a2(o, s)
		return
	o.hatch_here(s, 0xEA)                   # $877D
	o.c[s] = (o.c[s] - 1) & 0xFF
	if o.c[s] != 0:
		o.d[s] = (o.d[s] + 1) & 0xFF
		_87a2(o, s)
		return
	o.c[s] = 0x07                           # $8787 -- and $0640 is left at nought
	_87a2(o, s)


## $87AB -- [kind $08] it walks its picture, and once that is over it is given
## up; either way it is carried up and to the left.
static func _87ab(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x70)                  # $904B
	if o.frame[s] == 0x01:
		return                              # $87B7
	if o.left[s] == 0xFF:                   # $80E0
		o.id[s] = 0                         # $80B9
	# $87C0 -- $C0 along with the high byte taken one down, and $40 across.
	o.z50 = 0x00C0 | ((((o.z50 >> 8) - 1) & 0xFF) << 8)
	o.z52 = (o.z52 & 0xFF00) | 0x40
	o.move(s)                               # $813F


## $84EF -- [kind $1A] the walk is shown only every other picture.
static func _84ef(o: SolObjects, s: int) -> void:
	if ((s ^ o.clock) & 0x01) != 0:
		return                              # $84F3
	o.anim_second(s, 0x78)


## $849C and $84A0 -- [kinds $20 and $22] it is turned one way or the other and
## walks the one picture.
static func _849c(o: SolObjects, s: int, f: int) -> void:
	o.face[s] = f                           # $84A2
	o.anim_second(s, 0x79)                  # $904B


## $842F -- [kind $26] the four bytes it keeps are the step it is carried by.
static func _842f(o: SolObjects, s: int) -> void:
	o.z50 = o.a[s] | o.b[s] << 8            # $842F
	o.z52 = o.c[s] | o.d[s] << 8
	o.move(s)                               # $813F


## $83D7 -- [kind $2A] every so many pictures it throws one off, but only while
## it is near enough along or on the hero's own side.
static func _83d7(o: SolObjects, s: int) -> void:
	if (s ^ o.clock) != 0:
		return                              # $83DA
	o.far_x(s)
	if ((o.z90 >> 8) & 0xFF) >= 0x05 and o.z94 >= 0x80:
		return                              # $83E7
	o.hatch_here(s, 0xF3)                   # $83E9


## $8F68 -- what is left of it is put down and the slot is given up.
static func _8f68(o: SolObjects, s: int) -> void:
	o.hatch_here(s, 0xBD)                   # $AAF1
	_a989(o, s, 0x00)


## $84AA -- the last frames of the one that chased.
static func _k84aa(o: SolObjects, s: int) -> void:
	o.cool[s] = 0x02
	o.d[s] = (o.d[s] - 1) & 0xFF
	if o.d[s] == 0:
		_a989(o, s, 0x00)


## $84BA -- it circles, and finishes itself the moment it is on the hero.
static func _k84ba(o: SolObjects, s: int) -> void:
	if (o.clock & 0x0F) == 0:
		o.a[s] = (o.a[s] + 1) & 0xFF
		o.step_of(s)                        # $8A6D
		o.move(s)
	if o.far_x(s) == 0 and o.far_y(s) == 0:
		o.finish(s)                         # $80BF
	o.move(s)                               # $813F, a second time


## $84D6 -- every other frame it turns to run away from the hero.
static func _k84d6(o: SolObjects, s: int) -> void:
	if o.far_x(s) >= 0x04:
		return
	if ((s ^ o.clock) & 1) == 0:
		return
	o.a[s] = (o.angle_to_hero(s) ^ 0x20) & 0xFF
	o.step_of(s)
	o.move(s)


## $84FB -- the one that waits for the hero and then goes off.
static func _k84fb(o: SolObjects, s: int) -> void:
	if o.b[s] == 0:
		if o.far_x(s) < 0x03:
			o.b[s] = 0xFF                   # $850B -- one down from nothing
		o.cool[s] = 0x0F
		return
	if (o.b[s] & 0x80) == 0:
		o.b[s] = (o.b[s] - 1) & 0xFF
		o.cool[s] = 0x0F
		return
	# $8516 -- from here it is rising, and the ceiling is what stops it.
	if _87cd(o, s, o.probe_behind(s, 0x0080, 0x0100)) < 0x80:
		o.z52 = (o.z52 & 0xFF00) | 0x40             # $8538
		o.move(s)
		return
	# $851E -- the door is opened, and it is put back at the top of the view
	# with something of its own let out where it stood.
	o.y[s] = (o.y[s] & 0xFF00) | 0x07               # $8523, $05F7 = 7 with it
	# $8525 -- the noise ($F1 = $3F) is not modelled.
	o.hatch_here(s, 0xBD)                           # $AAF1
	o.y[s] = (o.y[s] & 0x00FF) \
			| (((o.cam_y >> 8) & 0xFF) << 8)        # $852D
	o.b[s] = 0x70                                   # $8533
	o.cool[s] = 0x0F                                # $850E


## $8545 -- it flickers and now and then lets something go.
static func _k8545(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x77)


## $85B8 -- the fan, one table read at two offsets: the step down out of
## $85B8 itself and the step along five bytes further on, out of $85BD.
const FAN := [0x00, 0xE4, 0xE4, 0x00, 0xEF, 0xE0, 0xF0, 0x10, 0x20, 0xE4,
		0x00, 0x1B]


## $85AB -- one of the fan.
static func _85ab(o: SolObjects, s: int, y: int) -> void:
	o.z94 = FAN[y + 5]                      # $85BD,Y
	o.z95 = FAN[y]                          # $85B8,Y
	_85c4(o, s)


## $856C / $8566 -- the one that faces a way and fires a spread.
static func _k856c(o: SolObjects, s: int, anim: int, way: int) -> void:
	o.face[s] = way
	o.anim_second(s, anim)
	if o.frame[s] == 0x02:                  # $8577
		o.cool[s] = 0x0F + (o.clock & 1)    # $80F2
		return
	if o.frame[s] != 0x03:                  # $857F
		return
	# $8583 -- every other time it is the four of the fan that go sideways,
	# and the rest of the time the three that go up.
	o.d[s] = (o.d[s] + 1) & 0xFF
	for k in ([4, 5, 6] if (o.d[s] & 1) != 0 else [0, 1, 2, 3]):
		_85ab(o, s, k)


## $85EA / $85EE -- the blower: near enough, and the hero is pushed along.
static func _k85ea(o: SolObjects, s: int, way: int) -> void:
	o.face[s] = way
	o.anim_second(s, 0x74)
	o.far_y(s)                              # $AE2D falls into $AE30
	o.far_x(s)
	if ((o.z92 >> 8) & 0xFF) >= 0x02:
		return
	if ((o.z94 ^ o.face[s]) & 0x80) != 0:
		return
	if (o.face[s] & 0x80) != 0:
		o.push = 0x0010                     # $860E
	else:
		o.push = -0x0010                    # $8612


## $861C -- it drifts toward the hero and sinks slowly.
static func _k861c(o: SolObjects, s: int) -> void:
	if o.d[s] == 0:
		o.anim_second(s, 0x72)
		if o.left[s] == 0xFF:
			o.d[s] = (o.d[s] + 1) & 0xFF
		return
	o.anim_second(s, 0x73)
	if (o.clock & 1) == 0:
		return
	if ((o.clock >> 1) & 0x03) == 0:
		o.turn_toward_hero(s)               # $802B
	o.step_of(s)                            # $8066
	var falling := true
	if ((o.y[s] >> 8) & 0xFF) < 0x6B and (o.z52 & 0x8000) != 0:
		o.z52 = 0
		falling = false
	if falling:
		# $8644 -- half the step down, sign and all.
		var v: int = o.z52 & 0xFFFF
		v = (v >> 1) | (v & 0x8000)
		o.z52 = v
	o.move(s)


## $865C -- the one that rides the top of the picture and is thrown away when
## the stage has scrolled past it.
static func _k865c(o: SolObjects, s: int) -> void:
	o.y[s] = (o.y[s] & 0xFF) | ((o.cam_y >> 8) & 0xFF) << 8
	o.carry = 0
	var hi: int = o._adc(o.noise & 0x0F, (o.cam_x >> 8) & 0xFF)
	o.x[s] = (o.x[s] & 0xFF) | hi << 8
	if ((s ^ o.clock) & 0x3F) != 0:
		return
	# $8670 -- and then it drops one, unless the stage has already scrolled
	# past the part of itself these belong to.
	var drop := true
	if o.level.stage == 1:
		if ((o.cam_x >> 8) & 0xFF) >= 0x70:
			drop = false                    # $8689
	elif o.level.stage == 2:
		if ((o.cam_y >> 8) & 0xFF) < 0x90:
			drop = false
	if not drop:
		o.id[s] = 0                         # $80B9
		return
	var i: int = SolShots.free_slot(o)      # $868D
	if i < 0:
		return
	SolShots.put(o, i, 0xAF)                # $8692 -> $907B
	SolShots.place_at(o, i, s)              # $A1C2
	o.s_a[i] = 0x40                         # $869A


## $86A1 -- it hangs there until the hero is close, then picks which way to go.
static func _k86a1(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x6C)
	o.far_y(s)
	o.face_hero(s)
	if o.left[s] != 0xFF:
		return
	if ((o.z90 >> 8) & 0xFF) >= 0x08:
		return
	if (o.z95 & 0x80) != 0:
		o.kind[s] = 0x04
	elif ((o.z92 >> 8) & 0xFF) >= 0x02:
		o.kind[s] = 0x02
	else:
		o.kind[s] = 0x04


## $8721 -- the four of the spread, one table read at two offsets: the step
## along out of $8721 itself and the step down four bytes further on.
const SPREAD := [0x1E, 0x1A, 0x13, 0x09, 0xF6, 0xED, 0xE6, 0xE2]


## $86EA -- one of the spread.  The step along is turned round for the side it
## faces, and whatever that take-away left is the carry the placing goes on
## with.
static func _86ea(o: SolObjects, s: int, y: int) -> void:
	var i: int = SolShots.free_slot(o)      # $86F4
	if i < 0:
		return
	# $86F9 -- the noise ($F1 = $2C) is not modelled.
	SolShots.put(o, i, 0xAA)                # $86FD -> $907B
	o.carry = (o.face[s] >> 7) & 1          # $870A ASL
	var v: int = SPREAD[y]                  # $870B
	if o.carry == 0:
		v = o._adc(v ^ 0xFF, 0x01)          # $870F and $8711
	o.s_a[i] = v                            # $8713
	o.s_b[i] = SPREAD[y + 4]                # $8716
	SolShots.place(o, s, i, 0x0000, 0xFF00, o.carry)    # $871B -> $A1D7


## $86C9 -- the spread: on the third step of its walk it lets four go at once.
static func _k86c9(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x6D)
	if o.frame[s] == 0x02:                  # $86CE
		for y in range(4):                  # $86D3
			_86ea(o, s, y)
	_pickup_tail(o, s)


## $8729 -- and the single shot, a page to the side it faces and half a page up.
static func _k8729(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x6E)
	if o.frame[s] == 0x02:                  # $872E
		var i: int = SolShots.free_slot(o)  # $8733
		if i >= 0:
			# $8738 -- the noise ($F1 = $28) is not modelled.
			SolShots.put(o, i, 0xA9)        # $873C -> $907B
			# $874E is an INC the other side takes back at $8754, so the page
			# along is only added where it looks right.
			var c: int = (o.face[s] >> 7) & 1       # $874D ASL
			o.s_a[i] = 0x10 if c == 1 else 0xF0     # $8750 and $8756
			SolShots.place(o, s, i, 0x0100 if c == 1 else 0x0000,
					0xFF80, c)              # $875B -> $A1D7
	_pickup_tail(o, s)


## $875E -- when the walk is over the family goes back to its first kind.
static func _pickup_tail(o: SolObjects, s: int) -> void:
	if o.left[s] == 0xFF:
		o.kind[s] = 0


# ------------------------------------------------ the second table, $827B

# $808A and $808E fill sixteen bytes of page one with $0F or $30.  Page one is
# where the drawing keeps what it is about to hand over, and nothing any stand
# compares is in it, so neither of them is kept here.

## The endings are told apart by a run of CMP/BEQ, and a CMP leaves its own
## carry behind -- which the smoke at $927E then adds in.  So the chain is
## walked the way the cartridge walks it, one comparison at a time.
static func _is(o: SolObjects, a: int, want: int) -> bool:
	o.carry = 1 if a >= want else 0
	return a == want


## $A427 -- one picture of dying.  The walk is stepped; when it runs out the
## thing is worth a thousand and the slot goes.  Answers which step of the walk
## it is on, or nothing at all once the slot has gone.
static func _a427(o: SolObjects, s: int, pic: int) -> int:
	o.anim_second(s, pic)                   # $99D9
	if o.left[s] != 0xFF:
		# $80E0 is a CMP against $FF, so the carry it leaves is down whenever
		# the walk is still running, and the next thing to add reads it.
		o.carry = 0
		return o.frame[s]
	o.carry = 1
	# $A4FA -- a thousand.  The three score bytes are added without the decimal
	# flag, so this is a plain sum and not a BCD one, and the carry out of the
	# middle byte is the one $80B9 hands on.
	var was: int = o.score & 0xFFFF
	o.score += 1000
	o.carry = 1 if was + 1000 > 0xFFFF else 0
	o.id[s] = 0                             # $80B9
	return 0


## $8351 -- the eight ways the last of something flies.
const SPARKS := [0xD2, 0x00, 0x2D, 0x40, 0x2D, 0x00, 0xD2, 0xC0]

## $8317 -- it comes apart: a slot of its own for each of the eight, each with
## its own step and the mind $99.  $8319 is the same with fewer of them.
static func _8319(o: SolObjects, s: int, n: int) -> void:
	while n >= 0:
		var f: int = o.hatch_here(s, 0x09)  # $AAF1
		if f == 0xFF:
			return                          # $8320 -- no slot to be had
		o.c[f] = SPARKS[n]                  # $832B
		if SPARKS[n] >= 0x80:
			o.d[f] = (o.d[f] - 1) & 0xFF
		var k: int = (n + 6) & 0x07         # $8333
		o.a[f] = SPARKS[k]
		if SPARKS[k] >= 0x80:
			o.b[f] = (o.b[f] - 1) & 0xFF
		o.mind[f] = 0x99                    # $8345
		n -= 1


## $A452 and $A458 -- the whole pool is wiped and then it comes apart.  $809E
## clears slots one to eleven; slot nought is left where it is.
static func _a458(o: SolObjects, s: int) -> void:
	for i in range(1, 0x0C):
		o.id[i] = 0                         # $809E
	_8319(o, s, 7)                          # $8317


## $A475 -- the stage is asked to end.  Stages fifteen and sixteen end on their
## own, so on those nothing is asked for.
static func _a475(o: SolObjects) -> void:
	if _is(o, o.stage, 0x0F) or _is(o, o.stage, 0x10):
		return
	o.zf8 = 0x0F                            # $A481


## $A4D9 -- everything in the pool of shots is wiped, a puff of smoke is left,
## and the screen's colours are shifted ($A0AB, which nothing here keeps).
static func _a4d9(o: SolObjects, s: int) -> void:
	for i in range(SolObjects.SHOTS):
		o.s_kind[i] = 0                     # $A4DD
	_927e(o, s)


## $A4E9 -- while the first slot is still within twelve of the top of the view
## the thing is pushed down a little.  The height read is $D0 itself and not
## $D0,X, so it is slot nought's whoever is dying.
static func _a4e9(o: SolObjects, s: int) -> void:
	o.carry = 1
	var d: int = o._sbc((o.y[0] >> 8) & 0xFF, (o.cam_y >> 8) & 0xFF)
	o.carry = 1 if d >= 0x0C else 0         # $A4EE -- the CMP's own carry
	if o.carry != 0:
		return                              # $A4F9
	# $A4F2 -- only the low byte of the step down is written, so the high byte
	# is whatever the last mind left there.
	o.z52 = (o.z52 & 0xFF00) | 0x04
	o.move(s)                               # $813F


## $A3FF -- the screen is told to do its own ending.
static func _a3ff(o: SolObjects) -> void:
	o.z26 = 0x04                            # $80A9


## $A3BC -- [$25] the pair: while the one beside it is still there it only
## smokes and counts down; once it is gone this one dies for both.
static func _a3bc(o: SolObjects, s: int) -> void:
	var other: int = s ^ 0x01               # $A3BF
	if o.id[other] != 0 and not _is(o, o.mind[other] & 0x3F, 0x19):
		o.anim_first(s, 0x30)               # $A3D1
		o.a[s] = (o.a[s] - 1) & 0xFF
		if o.a[s] == 0:
			o.id[s] = 0                     # $A3E1
			return
		_927e(o, s)                         # $A3DB
		return
	var r: int = _a427(o, s, 0x7D)          # $A3E5
	if _is(o, r, 0x01):
		pass                                # $A46D -- a noise, and nothing more
	elif _is(o, r, 0x02):
		_927e(o, s)                         # $A46A
	elif _is(o, r, 0x03):
		_a3fb(o)                            # $A3FB
	elif _is(o, r, 0x05):
		_a458(o, s)                         # $A452


## $A3FB -- [$26] the stage's own script is moved on and the screen is told to
## end.
static func _a3fb(o: SolObjects) -> void:
	o.z7f = 0x06                            # $A3FD
	_a3ff(o)


## $A406 -- [$21] and [$2D] the one that is carried: the hero is held still for
## a while, it is put where $75 says, and then it dies.
static func _a406(o: SolObjects, s: int) -> void:
	o.hero_timer = 0x1F                     # $A408
	_9ffa(o, s)
	o.move(s)                               # $813F
	var r: int = _a427(o, s, 0x7C)
	if _is(o, r, 0x01):
		pass                                # $A46D
	elif _is(o, r, 0x03):
		_927e(o, s)                         # $A46A
	elif _is(o, r, 0x04):
		_a3ff(o)                            # $A3FF
	elif _is(o, r, 0x06):
		_a458(o, s)                         # $A458


## $A43C -- [$1A] and [$1B]
static func _a43c(o: SolObjects, s: int) -> void:
	var r: int = _a427(o, s, 0x15)
	if _is(o, r, 0x01):
		_a475(o)                            # $A472
	elif _is(o, r, 0x03):
		_927e(o, s)                         # $A46A
	elif _is(o, r, 0x04):
		_a3ff(o)
	elif _is(o, r, 0x06):
		_a458(o, s)


## $A484 -- [$1E]
static func _a484(o: SolObjects, s: int) -> void:
	_a4e9(o, s)
	var r: int = _a427(o, s, 0x7E)
	if _is(o, r, 0x01):
		_a475(o)
	elif _is(o, r, 0x02):
		_a4d9(o, s)                         # $A4D9
	elif _is(o, r, 0x06):
		_a458(o, s)
	elif _is(o, r, 0x04):
		_a3ff(o)


## $A4A0 -- [$2A]
static func _a4a0(o: SolObjects, s: int) -> void:
	var r: int = _a427(o, s, 0x7F)
	if _is(o, r, 0x01):
		_a475(o)
	elif _is(o, r, 0x02):
		_927e(o, s)
	elif _is(o, r, 0x03):
		_a3ff(o)                            # $A4B6 -- a noise first
	elif _is(o, r, 0x05):
		_a458(o, s)


## $A4BD -- [$2C]
static func _a4bd(o: SolObjects, s: int) -> void:
	_a4e9(o, s)
	var r: int = _a427(o, s, 0x0B)
	if _is(o, r, 0x01):
		_a475(o)
	elif _is(o, r, 0x02):
		_927e(o, s)
	elif _is(o, r, 0x06):
		_a458(o, s)
	elif _is(o, r, 0x04):
		_a3ff(o)


## $AF67 -- it is thrown back off its feet and falls, and while $0610 is still
## nothing it walks a picture of its own; once that is over it counts on and
## the second walk carries it to the end.
static func _af67(o: SolObjects, s: int, pic: int, set: int) -> void:
	# $80DA is another CMP, against one, and the carry it leaves is read by the
	# fall that follows.
	o.carry = 1 if o.cool[s] >= 1 else 0
	if o.cool[s] <= 1:
		o.face_hero(s)                      # $8118
		o.face[s] = o.face[s] ^ 0xFF        # $AE24
		o.cool[s] = 0xD0
		o.c[s] = 0xD0                       # $8163
		o.d[s] = 0xFF
		o.b[s] = 0xFF
	o.fall(s, 0x02)                         # $B2BB
	# $AF14 -- the step along is $20, and only its low byte is written.
	o.z50 = (o.z50 & 0xFF00) | 0x20
	if o.face[s] < 0x80:
		o.carry = 1                         # $8181
		var lo: int = o._sbc(0, o.z50 & 0xFF)
		var hi: int = o._sbc(0, (o.z50 >> 8) & 0xFF)
		o.z50 = lo | hi << 8
	o.move(s)                               # $813F
	if o.a[s] == 0:
		o.anim_second(s, pic, set)          # $AFAE
		if o.left[s] == 0xFF:
			o.a[s] = (o.a[s] + 1) & 0xFF
		return
	o.anim_second(s, 0x04)                  # $AF8D
	if o.left[s] == 0xFF:                   # $AFA0
		_a989(o, s, 0x0A)


## $A3A8 -- [$1C] it is only counted down, and at nothing it is given up.
static func _a3a8(o: SolObjects, s: int) -> void:
	o.kind[s] = (o.kind[s] - 1) & 0xFF      # $A3A8
	if o.kind[s] == 0:
		_a989(o, s, 0x00)                   # $A987


## $A3B1 -- [$1D] a puff of smoke: it walks its own picture once and goes.
static func _a3b1(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x04)                  # $99D9
	if o.left[s] == 0xFF:                   # $80E0
		o.carry = 1
		_a989(o, s, 0x00)                   # $A987
		return
	o.carry = 0


## $AF63 -- [$0B]
static func _af63(o: SolObjects, s: int) -> void:
	_af67(o, s, 0x03, 0x04)


## $897E -- [$18]
static func _897e(o: SolObjects, s: int) -> void:
	_af67(o, s, 0x11, 0x03)


## $8F85 -- [$38] to [$3E] the plain endings: the slot stops being held on to
## and then it bursts, each for its own score.
static func _8f85(o: SolObjects, s: int, score: int) -> void:
	o.id[s] = o.id[s] & 0xBF                # $906C
	_af31(o, s, score)

# ------------------------------------------- three endings that sink and go

## $8C1B -- pinned to the height the lift keeps.  $75 holds that height; twelve
## bits of it, counted from the top of the view, is where the thing is put, and
## $52 takes the lift's own fall so that it goes down with the floor rather
## than through it.  The sum takes the carry whatever jumped here left: nought
## from either dispatch ($81D9 and $826C both shift a byte whose top bit is
## already off), but $8BF7 can arrive with it up, so it is asked for.  The four
## shifts that follow leave none of their own, because $90 starts empty.
static func _8c1b(o: SolObjects, s: int, cin := 0) -> void:
	var v: int = ((o.z75 + 0x18 + cin) & 0xFF) << 4     # $8C21
	o.carry = 0                                         # $8C2C leaves none
	var lo: int = o._adc(v & 0xFF, o.cam_y & 0xFF)      # $8C2F
	var hi: int = o._adc((v >> 8) & 0xFF, (o.cam_y >> 8) & 0xFF)
	o.y[s] = lo | hi << 8
	o.z52 = (o.z52 & 0xFF00) | (o.z34 & 0xFF)           # $8C39
	o.move(s)                                           # $813F


## $8993 -- [$10 dead] it is carried down with the lift it was riding, and only
## then does it go off.
static func _8993(o: SolObjects, s: int) -> void:
	_8c1b(o, s)
	_8996(o, s)


## $8996 -- [$28 dead] the same ending without the lift: it sinks at eight a
## picture of its own.
static func _8996(o: SolObjects, s: int) -> void:
	o.z52 = 0x08                                        # $8998
	_89a1(o, s)


## $899C -- [$35 dead] and the same again, standing still and wearing the
## seventh picture set.
static func _899c(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x07)                              # $904B
	_89a1(o, s)


## $89A1 -- the ending all three share.  For the first $50 pictures it goes on
## sinking and smokes every eighth; then it waits; and on the hundredth it
## comes apart into three, lets go of whatever held it and is given up.
static func _89a1(o: SolObjects, s: int) -> void:
	o.a[s] = (o.a[s] + 1) & 0xFF                        # $89A1
	if o.a[s] < 0x50:                                   # $89A9
		o.move(s)                                       # $89C9
		_927e(o, s)                                     # $89CC
		return
	if o.a[s] < 0x64:
		return                                          # $89AD
	_8319(o, s, 2)                                      # $89B1
	if (o.mind[s] & 0x3F) != 0x10:                      # $89B9
		o.id[s] = o.id[s] & 0xBF                        # $906C
	# $89C0 -- the noise it makes ($F1 = $21) is not modelled.
	_a989(o, s, 0x32)                                   # $89C6

## $90A9 -- one of the three last shots.  It goes up and a little sideways, and
## how far sideways is $94 turned round and doubled twice; the shifts leave the
## carry $A1D7 then adds the place with.
static func _90a9(o: SolObjects, s: int, j: int, b: int, w: int) -> void:
	o.s_b[j] = b                                        # $90A9
	o.carry = 1                                         # $90B6
	var a: int = o._sbc(0x00, w)                        # $90BB
	o.carry = (a >> 7) & 0x01                           # $90BD
	a = (a << 1) & 0xFF
	o.carry = (a >> 7) & 0x01                           # $90BE
	a = (a << 1) & 0xFF
	o.s_a[j] = a                                        # $90BF
	# $90C2 -- a step to the left borrows out of the high byte.
	var dx: int = 0x0080 if a < 0x80 else 0xFF80
	SolShots.place(o, s, j, dx, 0xFE80, o.carry)        # $A1D7


## $8F1C -- [$3D dead] it spits three last shots upward, one straight and two
## to the sides, and on the picture after that it bursts.
static func _8f1c(o: SolObjects, s: int) -> void:
	if o.a[s] == 0x02:
		_8f85(o, s, 0x0A)                               # $8F7B
		return
	if o.a[s] == 0x00:
		# $8F26 -- the noise it makes ($F1 = $2B) is not modelled.
		o.a[s] = (o.a[s] + 1) & 0xFF                    # $8F2A
	o.cool[s] = 0x0F + (o.clock & 0x01)                 # $80F2
	o.anim_second(s, 0x69)                              # $904B
	if o.left[s] != 0xFF:
		return                                          # $80E0
	o.a[s] = (o.a[s] + 1) & 0xFF                        # $8F3A
	# $8F3D, $8F46 and $8F4D -- three of them, and a full pool only costs the
	# one it could not have.
	for pair in [[0x00, 0xA0], [0x04, 0xA8], [0xFC, 0xA8]]:
		var j: int = SolShots.free_slot(o)              # $ADBA
		if j < 0:
			continue                                    # $8F58
		_90a9(o, s, j, int(pair[1]), int(pair[0]))
		SolShots.put(o, j, 0xA6)                        # $907B

## $90CA -- [$34] four steps, chosen out of $0690 by the table lying right
## behind the jump at $90CD.
static func _90ca(o: SolObjects, s: int) -> void:
	o.carry = 0                                         # $8012
	match o.kind[s]:
		0x00:
			_90d8(o, s)
		0x01:
			_90f5(o, s, 0x9E)
		0x02:
			_9116(o, s)
		0x03:
			_90f5(o, s, 0x9F)


## $90D8 -- step nought: three pictures in four it simply moves on to one of
## the other three, and the hash says which.  On the fourth it drops to a
## height the hash picks as well, and turns into $33 instead.
static func _90d8(o: SolObjects, s: int) -> void:
	var v: int = o.noise & 0x03                         # $90DA
	if v != 0:
		o.kind[s] = v                                   # $90F1
		return
	o.y[s] = (o.y[s] & 0x00FF) | (((o.noise & 0x1F) + 0x20) << 8)
	o.c[s] = 0xB8                                       # $8163
	o.d[s] = 0xFF
	o.b[s] = 0xFF
	o.mind[s] = 0x33                                    # $90ED


## $90F5 and $90FF -- steps one and three: a shot of its own is left where it
## stands, and the slot itself is given up for it ($8121 leaves a nought in A,
## and $9110 writes that nought into the slot).
static func _90f5(o: SolObjects, s: int, kind: int) -> void:
	var j: int = SolShots.free_slot(o)                  # $ADBA
	if j < 0:
		return
	o.s_kind[j] = kind                                  # $9107
	o.s_life[j] = kind                                  # $910A -- the same byte
	o.id[s] = 0                                         # $9110
	SolShots.place(o, s, j, 0x0000, 0x0000, 0)          # $A1D7


## $9116 -- step two: the one picture, and $80 of sinking a picture.
static func _9116(o: SolObjects, s: int) -> void:
	o.pic_lo[s] = 0x34                                  # $911A
	o.pic_hi[s] = 0x03                                  # $911F
	o.z52 = 0x0080                                      # $9122
	o.move(s)                                           # $813F


## $9127 -- [$33] what $90CA turns into: it falls.  On its first picture the
## hash gives it its step sideways and how fast it is already going down; both
## sums borrow, because the jump before them leaves no carry.
static func _9127(o: SolObjects, s: int) -> void:
	if o.kind[s] == 0x00:
		o.kind[s] = (o.kind[s] + 1) & 0xFF              # $912C
		o.carry = 0                                     # $81D9, $826C
		o.c[s] = o._sbc(o.c[s], o.noise & 0x3F)         # $9138
		o.carry = o.noise & 0x01                        # $913F LSR
		o.a[s] = o._sbc(o.noise >> 1, 0x40)             # $9140
	# $9148 -- the step sideways, spread over both bytes by hand.
	o.z50 = o.a[s] | (0xFF00 if o.a[s] >= 0x80 else 0)
	o.fall(s, 0x04)                                     # $B2BB
	o.anim_second(s, 0x08, 3)                           # $8985
	o.move(s)                                           # $813F

## $B0CD -- [$14] it wears the one animation out and is then given up.
static func _b0cd(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x0A, 3)                           # $99DB
	if o.left[s] != 0xFF:
		return                                          # $80E0
	_a989(o, s, 0x05)                                   # $B0D7


## $B0DC -- [$03] the same, out of a picture of its own, and looked at only
## every other picture -- which one depending on the slot it sits in.
static func _b0dc(o: SolObjects, s: int) -> void:
	if ((s ^ o.clock) & 0x01) == 0:
		return                                          # $B0DF
	o.anim_second(s, 0x07, 3)                           # $99DB
	if o.left[s] != 0xFF:
		return
	_a989(o, s, 0x05)                                   # $B0D7


## $B2AA and $B2AE -- [$08] and [$09] wear one picture and do nothing else.
static func _b2aa(o: SolObjects, s: int, pic: int) -> void:
	o.pic_lo[s] = pic                                   # $B2B0
	o.pic_hi[s] = 0x00                                  # $B2B5


## $B0EC -- [$0A] what is left behind once something is picked up.  It counts
## down in $0690; when the count runs out it pays what it was worth into the
## bonus and finishes itself off.  Either way it falls, faces its step and
## wears whatever picture its own $0610 names.
static func _b0ec(o: SolObjects, s: int) -> void:
	o.kind[s] = (o.kind[s] - 1) & 0xFF                  # $B0EC
	if o.kind[s] == 0x00:
		# $B0F4 -- the compare leaves the carry the sum below then takes in,
		# so the larger of the two is really worth one more than it says.
		o.carry = 1 if o.a[s] >= 0x02 else 0
		var v: int = 0x05 if o.a[s] < 0x02 else 0x13
		var lo: int = o._adc(v, o.hero_bonus & 0xFF)    # $B0FC
		var hi: int = (o.hero_bonus >> 8) & 0xFF
		if o.carry != 0:
			hi = (hi + 1) & 0xFF                        # $B104
		o.hero_bonus = lo | hi << 8
		# $B107 -- the noise it makes ($F1 = $0F) is not modelled.
		o.finish(s)                                     # $80BF
	o.fall(s, 0x03)                                     # $B2BB
	o.move_facing(s)                                    # $813A
	o.anim_second(s, o.a[s], 3)                         # $8985

## $B255 -- [$06] lights its fuse the first time it is looked at and then does
## nothing but wear one picture until the fuse runs out.
static func _b255(o: SolObjects, s: int) -> void:
	if o.kind[s] == 0x00:
		o.kind[s] = (o.kind[s] + 1) & 0xFF              # $B25A
		o.a[s] = 0x80                                   # $B25F
	o.anim_second(s, 0x03, 3)                           # $8985
	_b239(o, s)                                         # $B267


## $B26B -- [$07] the same in three parts: it waits out $20 pictures wearing
## one, then wears another until that one is worn out and is given up.
static func _b26b(o: SolObjects, s: int) -> void:
	var k: int = o.kind[s]
	if k == 0x00:
		o.kind[s] = (k + 1) & 0xFF                      # $B270
		o.a[s] = 0xE0                                   # $B275
		return
	if k == 0x01:
		o.a[s] = (o.a[s] + 1) & 0xFF                    # $B29C
		if o.a[s] == 0x00:
			o.kind[s] = (o.kind[s] + 1) & 0xFF          # $B2A1
		o.anim_second(s, 0x04, 3)                       # $B2A4
		return
	o.anim_second(s, 0x08, 3)                           # $B27D
	# $B282 -- the noise it makes ($F1 = $21) is not modelled.
	if o.left[s] != 0xFF:
		return                                          # $B292
	_a989(o, s, 0x00)                                   # $B299

## $A031 -- [$20] a fuse with no picture of its own: it flashes by having its
## wait set to one thing on the pictures its slot makes odd and to another on
## the rest, and is gone when $0610 runs out.
static func _a031(o: SolObjects, s: int) -> void:
	o.cool[s] = 0xFE if ((s ^ o.clock) & 0x01) != 0 else 0x0F
	o.a[s] = (o.a[s] - 1) & 0xFF                        # $A03E
	if o.a[s] == 0x00:
		o.id[s] = 0                                     # $80B9


## $A047 -- [$1F] one animation, worn once, and then it is gone.
static func _a047(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x20, 4)                           # $99D9
	if o.left[s] == 0xFF:
		o.id[s] = 0                                     # $80B9

## $8BFA -- one of the two it lets go as it turns: a whole page down the screen
## from itself, and either up or down from that.
static func _8bfa(o: SolObjects, s: int, b: int) -> void:
	o.z94 = b                                           # $8BFA
	var j: int = SolShots.free_slot(o)                  # $ADBA
	if j < 0:
		return                                          # $8BFF
	o.s_b[j] = o.z94                                    # $8C03
	o.s_a[j] = 0x20                                     # $8C08
	SolShots.put(o, j, 0xA8)                            # $907B
	o.z90 = 0                                           # $8121
	o.z92 = 0x0100                                      # $8C13
	# The compare that sent us here left the carry up, and $A1D7 adds with it.
	SolShots.place(o, s, j, o.z90, o.z92, 1)            # $A1D7


## $8BBA -- [$10] the one that rides the lift.  It wears one long animation and
## lets a shot go on the sixth and eighth pictures of it, one up and one down.
## Then it walks along until it reaches the side it is walking towards, turns
## round, and is pinned back onto the lift's height by $8C1B.
static func _8bba(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x6B)                              # $904B
	var fr: int = o.frame[s]                            # $80E6
	# $8BC4 -- the noise it makes ($F1 = $32) is not modelled.
	if fr == 0x05:
		_8bfa(o, s, 0x08)                               # $8BCA
	elif fr == 0x07:
		_8bfa(o, s, 0xF8)                               # $8BD0
	var cin := 0
	if (o.d[s] & 0x01) == 0:                            # $8BD9
		o.z50 = (o.z50 & 0xFF00) | 0x08                 # $8BDE
		cin = 1 if ((o.x[s] >> 8) & 0xFF) >= 0x3F else 0
		if cin == 1:
			o.d[s] = (o.d[s] + 1) & 0xFF                # $8BF4
	else:
		o.z50 = (o.z50 & 0xFF00) | 0xF8                 # $8BE8
		o.z50 = (o.z50 - 0x0100) & 0xFFFF               # $8BEC
		cin = 1 if ((o.x[s] >> 8) & 0xFF) >= 0x31 else 0
		if cin == 0:
			o.d[s] = (o.d[s] + 1) & 0xFF                # $8BF4
	_8c1b(o, s, cin)                                    # $8BF7

# ------------------------------------------------- the flier that winds up

## $8EB3 -- one part of a walk is over: the number moves on, but only once the
## animation has reached the picture it is held on for ever.
static func _8eb3(o: SolObjects, s: int) -> void:
	if o.left[s] != 0xFF:                               # $80E0
		return
	o.kind[s] = (o.kind[s] + 1) & 0xFF                  # $8EB8


## $8EBC -- the shot it lets go as it turns: the side it faces gives the step
## along, and it always starts half a picture above the thing itself.
static func _8ebc(o: SolObjects, s: int, j: int, kind: int) -> void:
	SolShots.put(o, j, kind)                            # $907B
	var c: int = SolShots.face_step(o, s, j)            # $8ECB
	SolShots.place(o, s, j, o.z90, 0xFF80, c)           # $8EC2, $A1D7


## $80FD -- the step along a behaviour has asked for in $9F, turned round for
## a thing that looks the other way.  The carry it leaves is what $A1D7 then
## adds the place with.
static func _80fd(o: SolObjects, s: int, j: int) -> int:
	if (o.face[s] & 0x80) != 0:                         # $8100
		o.s_a[j] = o.z9f                                # $8101
		return 1
	o.carry = 0
	o.s_a[j] = o._sbc(0x01, o.z9f)                      # $8107
	return o.carry


## $8FDE -- it turns to the hero, holds itself on the screen while he is near,
## and then asks what is under the far side of its feet: where there is ground
## it walks, and where there is none it stands still and only drifts.
static func _8fde(o: SolObjects, s: int) -> void:
	o.face_hero(s)                                      # $8118
	o.a[s] = o.z94                                      # $9053
	o.hold_on(s)                                        # $9050
	o.face[s] = (o.face[s] ^ 0xFF) & 0xFF               # $AE24
	var g: int = o.probe_behind(s, 0x0080, 0x0100)      # $B0AA
	o.face[s] = (o.face[s] ^ 0xFF) & 0xFF               # $AE24
	if g >= 0x80:
		o.step_and_look(s, 0x40)                        # $9D0A
	o.move(s)                                           # $813F


## $8DD7 -- the part between two turns: while the hero is within five whole
## pictures it winds up again, and once he is further off it starts over.
static func _8dd7(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x60)                              # $904B
	o.face_hero(s)                                      # $8118
	if ((o.z90 >> 8) & 0xFF) >= 0x05:                   # $8DE1
		o.kind[s] = 0                                   # $80B3
		return
	_8eb3(o, s)                                         # $8DE8


## $8DEB -- [$3A] the flier, in four parts kept in $0690.  It waits until the
## hero is five pictures off, drops one shot straight down as it opens, walks
## while the ground holds and lets a shot go every other picture, and then
## winds itself back up again.
static func _8deb(o: SolObjects, s: int) -> void:
	var k: int = o.kind[s]
	if k == 0x00:
		o.anim_second(s, 0x60)                          # $8E31
		o.face_hero(s)                                  # $8118
		if ((o.z90 >> 8) & 0xFF) < 0x05:                # $8E3B
			o.kind[s] = 0x02                            # $8E41
			return
		_8eb3(o, s)                                     # $8E45
		return
	if k == 0x01:
		o.anim_second(s, 0x61)                          # $8E48
		if o.frame[s] == 0x02:                          # $80E6
			var j: int = SolShots.free_slot(o)          # $ADBA
			if j >= 0:
				SolShots.put(o, j, 0xA3)                # $8E57
				o.s_b[j] = 0xB0                         # $8E5E
				o.z90 = 0x0080                          # $8E67, $8E6D
				o.z92 = 0xFE80                          # $8E63, $8E69
				o.z9f = 0x12                            # $8E71
				var c: int = _80fd(o, s, j)             # $80FD
				if o.s_a[j] >= 0x80:                    # $8E76
					o.z90 = (o.z90 - 0x0100) & 0xFFFF   # $8E78
				SolShots.place(o, s, j, o.z90, o.z92, c)
				return
		if o.left[s] == 0xFF:                           # $8E7D
			o.kind[s] = 0                               # $80B3
		return
	if k == 0x02:
		_8dd7(o, s)                                     # $8DF4
		return
	o.anim_second(s, 0x62)                              # $8DF6
	if o.left[s] == 0x01:                               # $8DFE
		_8fde(o, s)                                     # $8E02
		o.id[s] = o.id[s] & 0xBF                        # $906C
		if (o.frame[s] & 0x01) != 0:                    # $8E0B
			var j2: int = SolShots.free_slot(o)         # $ADBA
			if j2 >= 0:
				SolShots.put(o, j2, 0xA2)               # $8E13
				var c2: int = SolShots.face_step(o, s, j2)  # $8ECB
				o.z92 = 0xFF90                          # $8E1B
				SolShots.place(o, s, j2, o.z90, o.z92, c2)
	if o.left[s] == 0xFF:                               # $8E27
		o.kind[s] = 0x02                                # $8E2D


## $8C40 -- [$3E] the one that walks the width of the room and turns at the two
## ends.  On the second and fourth pictures of its walk it lets a shot go
## instead of stepping, behind and above it or behind and below it.
static func _8c40(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x6A)                              # $904B
	if (o.d[s] & 0x01) == 0:                            # $8C48
		o.z50 = (o.z50 & 0xFF00) | 0x04                 # $8C4D
		if ((o.x[s] >> 8) & 0xFF) >= 0x4B:              # $8C51
			o.d[s] = (o.d[s] + 1) & 0xFF                # $8C63
	else:
		o.z50 = (o.z50 & 0xFF00) | 0xFC                 # $8C59
		o.z50 = (o.z50 - 0x0100) & 0xFFFF               # $8C5B
		if ((o.x[s] >> 8) & 0xFF) < 0x47:               # $8C5F
			o.d[s] = (o.d[s] + 1) & 0xFF
	var fr: int = o.frame[s]                            # $80EC
	if fr == 0x03 or fr == 0x01:                        # $8C69, $8C6D
		var j: int = SolShots.free_slot(o)              # $ADBA
		if j >= 0:
			o.s_a[j] = s                                # $8C82 -- which slot
			o.s_b[j] = 0x04                             # $8C87
			SolShots.put(o, j, 0xA7)                    # $907B
			# $8C8F -- the noise ($F1 = $12) is not modelled.
			o.z90 = 0x0080                              # $8121, $8C98
			o.z92 = 0x00C0
			var c := 1                                  # $8C9E left it up
			if fr < 0x03:                               # $8CA1
				o.z90 = (o.z90 - 0x0100) & 0xFFFF       # $8CA3
				c = 0
			SolShots.place(o, s, j, o.z90, o.z92, c)    # $A1D7
			return
	o.a[s] = o.z50 & 0xFF                               # $8C6F
	o.b[s] = (o.z50 >> 8) & 0xFF
	o.move(s)                                           # $813F


## $8CA8 -- [$3D] it walks away from the hero rather than towards him ($810D
## answered and the answer turned round), and steps only while the ground
## behind its feet is solid; where it is not, it drops instead.
static func _8ca8(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x68)                              # $904B
	o.a[s] = (o.face_hero_far(s) ^ 0xFF) & 0xFF         # $810D, $8CB0
	if o.probe_behind(s, 0x0080, 0x0100) >= 0x80:       # $B0AA
		o.step_and_look(s, 0x04)                        # $9D0A
		o.move(s)                                       # $813F
		return
	o.z52 = (o.z52 & 0xFF00) | 0x80                     # $8CC4
	o.move(s)                                           # $813F

## $90A7 -- the shot it lets go on its way past: half a picture along and two
## above itself, and the step it takes along is four times how far the hero is
## the other way, so the further off he is the flatter it goes.
static func _90a7(o: SolObjects, s: int, j: int) -> void:
	o.s_b[j] = 0xA8                                     # $90A9
	o.z90 = 0x0080                                      # $90B2, $90B9
	o.z92 = 0xFE80                                      # $90AE, $90B4
	o.carry = 1                                         # $90B6
	var v: int = o._sbc(0x00, o.z94)                    # $90BB
	o.carry = (v >> 7) & 1                              # $90BD
	v = (v << 1) & 0xFF
	o.carry = (v >> 7) & 1                              # $90BE
	v = (v << 1) & 0xFF
	o.s_a[j] = v                                        # $90BF
	if v >= 0x80:
		o.z90 = (o.z90 - 0x0100) & 0xFFFF               # $90C4
	SolShots.place(o, s, j, o.z90, o.z92, o.carry)      # $A1D7


## $9084 -- the half of [$35] that stands still: on the third picture of the
## second animation it lets one go, and when that animation is worn out it
## starts over.
static func _9084(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x57)                              # $904B
	if o.frame[s] == 0x02:                              # $80E6
		o.face_hero(s)                                  # $8118
		var j: int = SolShots.free_slot(o)              # $ADBA
		if j >= 0:
			SolShots.put(o, j, 0xA0)                    # $907B
			_90a7(o, s, j)                              # $90A7
	if o.left[s] == 0xFF:                               # $80E0
		o.kind[s] = 0                                   # $80B3


## $8FF8 -- the half of [$35] that walks: on the second picture of the first
## animation it takes a step, but only where what lies ahead is solid.
static func _8ff8(o: SolObjects, s: int) -> void:
	o.anim_first(s, 0x58)                               # $9026
	# $9000 -- the noise it makes ($F1 = $29) is not modelled.
	if o.frame[s] == 0x01:                              # $9004
		o.z90 = 0x0080                                  # $8121, $900D
		o.z92 = 0x0100                                  # $900F
		if o.probe_ahead(s, o.z90, o.z92) >= 0x80:      # $B170
			o.step_and_look(s, 0x20)                    # $9D0A
	if o.anim_a[s] == 0:                                # $901B
		o.kind[s] = 0
	o.move(s)                                           # $813F


## $902D -- [$35] the walker that stops to shoot.  While the first animation
## is still running $8FF8 has it; otherwise it stands, holds itself on the
## screen while the hero is within seven pictures, and turns to face him.
static func _902d(o: SolObjects, s: int) -> void:
	if o.anim_a[s] != 0:
		_8ff8(o, s)                                     # $8FF8
		return
	if o.cool[s] == 0x01 and (o.mind[s] & 0x40) == 0:   # $80DA, $9037
		o.anim_first(s, 0x58)                           # $9026
		return
	if o.kind[s] != 0:                                  # $9041
		_9084(o, s)
		return
	o.face_hero(s)                                      # $9050 -> $8118
	o.a[s] = o.z94                                      # $9053
	o.hold_on(s)                                        # $9056
	o.anim_second(s, 0x56)                              # $9049

## $8179 -- the step along is set from one byte and turned round for a thing
## that looks left.  Only the low byte is written, so whatever $51 was holding
## is kept, which is how a thing that was already drifting keeps its page.
static func _8179(o: SolObjects, s: int, n: int) -> void:
	o.z50 = (o.z50 & 0xFF00) | n                        # $8179
	if (o.face[s] & 0x80) == 0:
		return                                          # $8180
	o.carry = 1                                         # $8181
	var lo: int = o._sbc(0x00, o.z50 & 0xFF)            # $8184
	var hi: int = o._sbc(0x00, (o.z50 >> 8) & 0xFF)     # $818A
	o.z50 = lo | hi << 8


## $8A33 -- [$3C] the one that circles.  It holds itself on the screen, turns
## a step towards the hero every other picture and drifts along its own
## heading; while $0640 is still counting it does not turn at all but walks its
## heading up instead, which is what makes it go round.  Once it has been let
## go of it charges straight ahead and wears the picture of the charge.
static func _8a33(o: SolObjects, s: int) -> void:
	o.id[s] = (o.id[s] & 0xBF) | 0x40                   # $906E
	if o.anim_a[s] != 0:                                # $8A38
		_8179(o, s, 0x80)                               # $8A29
		o.move(s)                                       # $813F
		o.anim_first(s, 0x05)                           # $8A2E -> $9028
		return
	o.face_hero(s)                                      # $8118
	if (o.mind[s] & 0x40) == 0 and o.cool[s] == 0x01:   # $8173, $80DA
		o.a[s] = (o.a[s] ^ 0x20) & 0xFF                 # $8A4D
		o.anim_first(s, 0x05)                           # $8A2E
		return
	o.anim_second(s, 0x67)                              # $8A55
	if o.d[s] == 0x00:                                  # $8A5D
		if (o.clock & 0x01) != 0:                       # $8A67
			o.turn_toward_hero(s)                       # $802B
		o.step_of(s)                                    # $8066
		o.move(s)                                       # $813F
		return
	o.d[s] = (o.d[s] - 1) & 0xFF                        # $8A5F
	if (o.clock & 0x01) != 0:                           # $8A75
		o.a[s] = (o.a[s] + 1) & 0xFF                    # $8A78
		o.step_of(s)                                    # $8066
		o.z50 = 0                                       # $812C
	o.move(s)                                           # $8A81

## $A6D6 -- a step along of $10, turned round for a thing that looks left, and
## taken back again where what lies just ahead of its middle is solid.
static func _a6d6(o: SolObjects, s: int) -> void:
	_8179(o, s, 0x10)                                   # $A6D8, $8181
	o.z90 = 0x0080                                      # $8121, $A6E3
	o.z92 = 0x0040                                      # $A6DF
	if o.probe_fwd(s, o.z90, o.z92) >= 0x80:            # $B179
		o.z50 = 0                                       # $812C


## $9975 -- [$29] it walks in from the side until it reaches the pillar at $4E
## and stops there: it faces the hero, plays one animation out and then hands
## itself on to the behaviour after its own.
static func _9975(o: SolObjects, s: int) -> void:
	o.z50 = (o.z50 & 0x00FF) | 0x0100                   # $9977
	if ((o.x[s] >> 8) & 0xFF) != 0x4E:                  # $997B
		o.move(s)                                       # $999F
		return
	if o.d[s] == 0x00:                                  # $997F
		# $9984 -- the noise it makes ($F1 = $36) is not modelled.
		o.d[s] = (o.d[s] + 1) & 0xFF                    # $9988
	_a6d6(o, s)                                         # $A6D6
	o.face_hero(s)                                      # $8118
	o.anim_second(s, 0x35)                              # $99D9
	if o.left[s] != 0xFF:
		return                                          # $9996
	o.mind[s] = (o.mind[s] + 1) & 0xFF                  # $9998
	o.a[s] = 0x40                                       # $9A73
	o.kind[s] = (o.kind[s] + 1) & 0xFF


## $959E -- the four waits it blinks through, read by the second bit of the
## count and up.
const BLINK := [0x01, 0x01, 0x02, 0x00]


## $9588 -- [$31] nothing but a blink that runs out: the wait is picked out of
## $959E by what is left of the count, and at nothing the slot goes.
static func _9588(o: SolObjects, s: int) -> void:
	o.cool[s] = BLINK[(o.a[s] >> 1) & 0x03]             # $958F
	o.a[s] = (o.a[s] - 1) & 0xFF                        # $9595
	if o.a[s] == 0x00:
		o.id[s] = 0                                     # $80B9


## $82FB -- [$19] a thing with no will of its own: it wears one animation out
## and is then gone, and while it lasts it drifts by the two pairs the slot
## keeps -- $0610:$0620 down and $0630:$0640 along.
static func _82fb(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x08, 3)                           # $99DB
	if o.left[s] == 0xFF:
		o.id[s] = 0                                     # $80B9
	o.z52 = o.a[s] | o.b[s] << 8                        # $8307
	o.z50 = o.c[s] | o.d[s] << 8                        # $8B8A
	o.move(s)                                           # $813F

## $A511 -- [$1A] it drifts down until its own height is eleven whole pictures
## below the top of the view, and settles there: one animation plays out and
## the behaviour after its own takes over.
static func _a511(o: SolObjects, s: int) -> void:
	o.face_hero(s)                                      # $8118
	o.z52 = (o.z52 & 0x00FF) | 0x0100                   # $A516
	o.carry = 0                                         # $A518
	var want: int = o._adc(0x0B, (o.cam_y >> 8) & 0xFF)  # $A519
	if want != ((o.y[s] >> 8) & 0xFF):                  # $A51D
		o.anim_second(s, 0x0F)                          # $A535
		o.move(s)                                       # $813F
		return
	o.anim_second(s, 0x14)                              # $A521
	if o.left[s] != 0xFF:
		return                                          # $A526
	# $A528 -- the noise it makes ($F1 = $07) is not modelled.
	o.mind[s] = (o.mind[s] + 1) & 0xFF                  # $A52C
	o.kind[s] = 0x01                                    # $A531


# ---------------------------------------------- the pair that runs the walls

## $AD50 -- the question that turns it round.  On the pictures the second bit
## of the count is up it asks what is a whole picture diagonally ahead of it,
## the way it faces and the way it is going, and turns where there is nothing
## there; on the rest it asks what is a whole picture the other way down, and
## turns where there is something.  Turning flips the top bit of $0690, which
## is both which way it runs and which animation it wears.
static func _ad50(o: SolObjects, s: int) -> void:
	if (o.clock & 0x02) != 0:                           # $AD52
		var dx: int = 0x0100 if (o.face[s] & 0x80) != 0 else 0xFF00
		var dy: int = 0x0100 if ((o.z52 >> 8) & 0xFF) < 0x80 else 0xFF00
		o.z90 = (o.x[s] + dx) & 0xFFFF                  # $AD6F
		o.z92 = (o.y[s] + dy) & 0xFFFF                  # $AD7A
		o.z9d = o.z92 & 0xFF                            # $D08F
		if o.probe(o.z90, o.z92) >= 0x80:               # $C00C
			return                                      # $AD8E
	else:
		o.z92 = 0xFF00                                  # $AD8F
		if ((o.z52 >> 8) & 0xFF) >= 0x80:               # $AD97
			o.z92 = 0x0100                              # $AD9B
		if o.probe_above(s, o.z92) < 0x80:              # $B151
			return                                      # $ADB9
	if o.d[s] != 0:                                     # $ADA4
		o.finish(s)                                     # $80BF
	o.d[s] = 0x03                                       # $ADAE
	o.kind[s] = (o.kind[s] ^ 0x80) & 0xFF               # $ADB4


## $AD08 -- how fast it runs and which way.  It keeps to $10 a picture, and
## goes up to $30 only once its wait has run past $20 and the hero is within a
## whole picture along and on the side it is already running towards.
static func _ad08(o: SolObjects, s: int) -> void:
	if o.d[s] != 0:                                     # $AD0B
		o.d[s] = (o.d[s] - 1) & 0xFF                    # $AD0D
	o.z52 = (o.z52 & 0xFF00) | 0x10                     # $AD12
	var near := true
	if o.cool[s] >= 0x20:                               # $AD17
		o.carry = 1
		o._sbc(o.x[s] & 0xFF, o.hero_x & 0xFF)          # $AD1D
		var dx: int = o._sbc((o.x[s] >> 8) & 0xFF,
				(o.hero_x >> 8) & 0xFF)
		o.carry = 0                                     # $AD23
		if o._adc(dx, 0x01) >= 0x02:                    # $AD26
			near = false                                # $AD28
		else:
			o.carry = 1
			o._sbc(o.y[s] & 0xFF, o.hero_y & 0xFF)      # $AD2C
			var dy: int = o._sbc((o.y[s] >> 8) & 0xFF,
					(o.hero_y >> 8) & 0xFF)
			if ((dy ^ o.kind[s]) & 0x80) == 0:          # $AD32
				near = false
	if near:
		o.z52 = (o.z52 & 0xFF00) | 0x30                 # $AD39
	var n := 0x0A                                       # $AD3B
	if (o.kind[s] & 0x80) != 0:                         # $AD40
		n = 0x09                                        # $AD42
		o.carry = 1                                     # $818F
		o.z52 = o._neg16(o.z52)
	o.anim_second(s, n)                                 # $AD47
	_ad50(o, s)                                         # $AD4A
	o.move(s)                                           # $AD4D


## $ACB5 and $ACB9 -- [$11] and [$0F] the pair that runs up and down a wall,
## one looking each way.  They are looked at only every other picture, and only
## while something is holding slot twelve and the count is at a whole $80 do
## they let a shot go straight out of the wall.
static func _acb5(o: SolObjects, s: int, way: int) -> void:
	o.face[s] = way                                     # $ACBB
	if ((s ^ o.clock) & 0x01) != 0:
		return                                          # $ACC4
	if o.id[0x0C] != 0 and (o.clock & 0x7E) == 0:       # $ACC5, $ACCA
		var j: int = SolShots.free_slot(o)              # $ADBA
		if j >= 0:
			var c: int = (o.face[s] >> 7) & 1           # $ACD8
			o.s_a[j] = 0xE2 if c == 1 else 0x22         # $ACD9
			o.s_b[j] = 0x08                             # $ACE2
			SolShots.put(o, j, 0x81)                    # $907B
			o.s_x[j] = o.x[s]                           # $ACEC
			o.carry = c                                 # what $ACD8 left
			var lo: int = o._adc(o.y[s] & 0xFF, 0x80)   # $ACF8
			var hi: int = o._adc((o.y[s] >> 8) & 0xFF, 0x00)
			o.s_y[j] = lo | hi << 8
			# $AD04 -- the noise ($F1 = $12) is not modelled.
	_ad08(o, s)                                         # $AD08

## $8DC5 -- how the hunter reads a place.  Solid is one answer and so are the
## two kinds of floor it will not cross; only the one kind it may cross comes
## back as nothing, and the compare on the way leaves a carry the next add
## takes.
static func _8dc5(o: SolObjects, v: int) -> int:
	if v >= 0x80:
		return v                                        # $8DD6
	var w: int = v & 0xE0                               # $8DC7
	o.carry = 1 if w >= 0x60 else 0                     # $8DC9
	if w == 0x60:
		return 0xFF                                     # $8DD4
	if (w & 0x20) == 0:
		return 0xFF
	return 0x00                                         # $8DD1


## $B189 -- the offset kept in $90:$92 is laid out around the slot: against it
## where the byte handed in is negative, along it where it is not.  The add
## along takes the carry standing, so the callers are careful with it.
static func _b189(o: SolObjects, s: int, t: int) -> void:
	if t >= 0x80:
		o.carry = 1                                     # $B18B
		var l: int = o._sbc(o.x[s] & 0xFF, o.z90 & 0xFF)
		var h: int = o._sbc((o.x[s] >> 8) & 0xFF, (o.z90 >> 8) & 0xFF)
		o.z90 = l | h << 8
	else:
		var l2: int = o._adc(o.x[s] & 0xFF, o.z90 & 0xFF)   # $B19B
		var h2: int = o._adc((o.x[s] >> 8) & 0xFF,
				(o.z90 >> 8) & 0xFF)
		o.z90 = l2 | h2 << 8
	o.carry = 0                                         # $B1A7
	var yl: int = o._adc(o.y[s] & 0xFF, o.z92 & 0xFF)
	var yh: int = o._adc((o.y[s] >> 8) & 0xFF, (o.z92 >> 8) & 0xFF)
	o.z92 = yl | yh << 8


## $8CC9 -- [$3B] the hunter that runs the floors.  It walks towards the hero
## for $64 pictures, looking where it is going both down and along and stopping
## dead where the floor it reads is one it will not cross.  The moment the hero
## is within a picture of it -- down first, along second -- it settles into one
## of two turns, and each of those lets a shot go on the third picture of its
## animation and then starts the walk again.
static func _8cc9(o: SolObjects, s: int) -> void:
	var k: int = o.kind[s]
	if k == 0x00:
		o.d[s] = 0x64                                   # $8D2F
		o.anim_second(s, 0x64)                          # $8D32
		if (((o.clock >> 7) ^ s) & 0x01) != 0:          # $8D37
			_8eb3(o, s)                                 # $8D40
		return
	if k == 0x01:
		o.d[s] = (o.d[s] - 1) & 0xFF                    # $8D44
		if o.d[s] == 0x00:
			o.kind[s] = 0                               # $80B3
			return
		o.anim_second(s, 0x63)                          # $8D4C
		o.carry = 1 if o.frame[s] >= 0x03 else 0        # $8D54
		o.face[s] = 0xFF if o.carry != 0 else 0x00      # $8D5C
		o.far_y(s)                                      # $AE5E
		o.far_x(s)                                      # $AE30
		if (o.z92 & 0xFF) < 0x40 and ((o.z92 >> 8) & 0xFF) == 0:
			o.kind[s] = 0x02                            # $8DBD
			o.face_hero(s)                              # $8118
			return
		if o.z95 < 0x80 and (o.z90 & 0xFF) < 0x40 \
				and ((o.z90 >> 8) & 0xFF) == 0:
			o.kind[s] = 0x03                            # $8DB9
			o.face_hero(s)                              # $8118
			return
		o.turn_toward_hero(s)                           # $802B
		o.step_of(s)                                    # $8066
		o.z90 = 0                                       # $8121
		o.z92 = 0x0100 if ((o.z52 >> 8) & 0xFF) >= 0x80 else 0xFF00
		if _8dc5(o, o.probe_above(s, o.z92)) >= 0x80:   # $B151, $8D90
			o.z52 = 0                                   # $8133
		o.z90 = 0x0100                                  # $8121, $8D9B
		o.z92 = 0
		_b189(o, s, (o.z50 >> 8) & 0xFF)                # $8D9F
		o.z9d = o.z92 & 0xFF
		if _8dc5(o, o.probe(o.z90, o.z92)) >= 0x80:     # $C00C, $8DAB
			o.z50 = 0                                   # $8DB0
		o.move(s)                                       # $813F
		return
	if k == 0x02:
		o.anim_second(s, 0x65)                          # $8D0D
		if o.frame[s] == 0x02:                          # $80E6
			var j: int = SolShots.free_slot(o)          # $ADBA
			if j >= 0:
				o.s_b[j] = 0x04                         # $8D1C
				_8ebc(o, s, j, 0xA5)                    # $8D21
				return
		if o.left[s] == 0xFF:                           # $8D24
			o.kind[s] = 0                               # $80B3
		return
	o.anim_second(s, 0x66)                              # $8CD6
	if o.frame[s] == 0x02:                              # $80E6
		var j2: int = SolShots.free_slot(o)             # $ADBA
		if j2 >= 0:
			o.s_b[j2] = 0x04                            # $8CE5
			SolShots.put(o, j2, 0xA4)                   # $907B
			# $8CED -- the noise ($F1 = $13) is not modelled.
			o.z90 = 0x0080                              # $8121, $8CFA
			o.z92 = 0xFE00                              # $8CF4, $8CF6
			if (o.face[s] & 0x80) == 0:                 # $8CFF
				o.z90 = (o.z90 - 0x0100) & 0xFFFF       # $8D01
			o.s_a[j2] = 0xD0                            # $8D05
			# $8CD9 left the carry up, and $A1D7 adds the place with it.
			SolShots.place(o, s, j2, o.z90, o.z92, 1)   # $A1D7
			return
	if o.left[s] == 0xFF:                               # $8D24
		o.kind[s] = 0                                   # $80B3

## $AE7B -- [$0C] the one that swings about the height it was left at.  That
## height is written into $0640:$0690 the first time it is looked at; $0610
## counts up and is the step down, turned round by the top bit of $0620, and
## every time it comes back to where it started the count goes back to $F0 and
## the turn is flipped.  Its step along is a flat $14, either way by the side
## it faces.
static func _ae7b(o: SolObjects, s: int) -> void:
	# $AED7 -- the trail it draws behind itself is not modelled.
	var flip := false
	if o.kind[s] == 0x00 and o.d[s] == 0x00:            # $AE7E, $AE83
		o.d[s] = o.y[s] & 0xFF                          # $AE8A
		o.kind[s] = (o.y[s] >> 8) & 0xFF                # $AE8F
		flip = true                                     # $AE92 either way
	else:
		o.carry = 1
		var l: int = o._sbc(o.y[s] & 0xFF, o.d[s])      # $AE96
		var h: int = o._sbc((o.y[s] >> 8) & 0xFF, o.kind[s])
		flip = l == 0x00 and h == 0x00
	if flip:
		o.a[s] = 0xF0                                   # $AEA4
		o.b[s] = (o.b[s] ^ 0x80) & 0xFF                 # $AEAA
	o.a[s] = (o.a[s] + 1) & 0xFF                        # $AEAF
	o.z52 = (o.z52 & 0xFF00) | o.a[s]                   # $AEB5
	if o.a[s] >= 0x80:
		o.z52 = (o.z52 - 0x0100) & 0xFFFF               # $AEB9
	if (o.b[s] & 0x80) != 0:                            # $AEBE
		o.carry = 1                                     # $818F
		o.z52 = o._neg16(o.z52)
	if (o.face[s] & 0x80) != 0:                         # $AECC
		o.z50 = ((o.z50 - 0x0100) & 0xFF00) | 0xEC      # $AEC3
	else:
		o.z50 = (o.z50 & 0xFF00) | 0x14                 # $AECE
	o.move(s)                                           # $AED4


## $8446 -- it is put where the hero is, both halves of both numbers.
static func _8446(o: SolObjects, s: int) -> void:
	o.x[s] = o.hero_x
	o.y[s] = o.hero_y


## $8418 -- one of the four, let out on top of the hero.  $AAFA is handed a
## seven, so this one looks for its free slot from seven down, not eleven.
static func _8418(o: SolObjects, s: int, tpl: int) -> void:
	o.hatch(o.hero_x, o.hero_y, tpl, 0x07)          # $AAFA


## $83EF -- [kind $24] it rides the hero, and once he is in the state the end
## of a stage puts him in, it lets four things out of itself at once and goes.
static func _83ef(o: SolObjects, s: int) -> void:
	_8446(o, s)                                     # $8446
	o.anim_second(s, 0x0C, 3)                       # $8985
	if o.hero_state != 0x13:                        # $05A2
		return
	for tpl in [0x48, 0x51, 0x5A, 0x63]:            # $83FE .. $840F
		_8418(o, s, tpl)
	_a989(o, s, 0x00)                               # $8412


## $8457 -- [kind $28] the one that rides him off the stage: it counts down,
## blinks the last of the count away, and takes the wire's fuel with it.
static func _8457(o: SolObjects, s: int) -> void:
	if (o.hero_pic_lo | o.hero_pic_hi) == 0:        # $8457 -- he is not drawn
		return
	_8446(o, s)                                     # $845F
	_87a2(o, s)                                     # $8462
	o.face[s] = 0                                   # $8465, A is the nought
	if o.hero_pose == 0x0E and o.hero_step_t != 0xFF:
		return                                      # $846B, $8472
	o.a[s] = (o.a[s] - 1) & 0xFF                    # $8476
	if o.a[s] == 0x00:
		o.hero_fuel = 0                             # $847E
		_a989(o, s, 0x00)                           # $8483
		return
	var p := 0xE8                                   # $8488
	if o.a[s] >= 0x20:                              # $8486
		if (o.a[s] & 0x08) != 0:                    # $848C -- half the time
			return                                  # it is not drawn at all
		p = 0xE6                                    # $8490
	o.pic_lo[s] = p                                 # $8493
	o.pic_hi[s] = 0x02                              # $8496


## $8F12 -- the eight ways round, read at two offsets: the step along out of
## $8F14 and the step down out of $8F12 itself.
const BURST := [0x00, 0x22, 0x30, 0x22, 0x00, 0xDE, 0xD0, 0xDE, 0x00, 0x22]


## $85C4 -- one of the ring: the pair is handed to it as its own speed, and the
## down half is turned round for the side the thing faces.
static func _85c4(o: SolObjects, s: int) -> void:
	# $85C4 -- the noise ($F1 = $2C) is not modelled.
	var i: int = SolShots.free_slot(o)              # $ADBA
	if i < 0:
		return
	SolShots.put(o, i, 0xAB)                        # $907B
	o.s_a[i] = o.z94                                # $85D4
	var v: int = o.z95                              # $85DB
	if (o.face[s] & 0x80) != 0:                     # $85D7 ASL
		o.carry = 1                                 # $85DD left it up
		v = o._adc(v ^ 0xFF, 0x00)
	o.s_b[i] = v                                    # $85E3
	SolShots.place_at(o, i, s)                      # $A1C2


## $8F05 -- and which of the eight it is.
static func _8f05(o: SolObjects, s: int, y: int) -> void:
	o.z94 = BURST[y + 2]                            # $8F14,Y
	o.z95 = BURST[y]                                # $8F12,Y
	_85c4(o, s)


## $8EE6 -- [dead kind $1C] near enough the hero and it lets the whole ring of
## eight go before it is taken away.
static func _8ee6(o: SolObjects, s: int) -> void:
	if o.far_x(s) >= 0x03:                          # $AE30
		for y in range(0x07, -1, -1):               # $8EED .. $8EF7
			_8f05(o, s, y)
	# $8EF9 -- the noise ($F1 = $21) is not modelled.
	_8f68(o, s)                                     # $8EFD
