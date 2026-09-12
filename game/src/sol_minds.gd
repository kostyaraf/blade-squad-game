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
	_body(o, s)
	# $81A9 -- a thing that has been finished off touches nobody; the hero's
	# own contact ($C02A) and the weapon's ($C02D) are the rest of Э4.3.


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
	match m:
		0x01, 0x36, 0x37:
			pass                            # $B0CC -- nothing at all
		0x1E:
			_a10b(o, s)
		0x1B:
			_a53d(o, s)
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
		0x21:
			_9e12(o, s)
		0x24:
			_9d41(o, s)
		0x25, 0x26, 0x27:
			_9b05(o, s)
		0x2A:
			_99a2(o, s)
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
		0x3F:
			_pickup(o, s)
		_:
			o.missed(m, false)


## $827B -- and for one that is finished.
static func _dead(o: SolObjects, s: int, m: int) -> void:
	match m:
		0x0C, 0x0E:
			_af31(o, s, 0x00)               # $AF23
		0x0F, 0x11:
			_af31(o, s, 0x0A)               # $AF27
		0x1E:
			_a10b(o, s)
		0x1B:
			_a53d(o, s)
		0x18:
			_8802(o, s)
		0x0D:
			_af31(o, s, 0x14)               # $AF2B
		0x12:
			_af31(o, s, 0x32)               # $AF2F
		0x3F:
			_pickup_dead(o, s)
		_:
			o.missed(m, true)


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
	# $95E7 fills the shot pool, which is not ported yet.
	o.z90 = 0
	o.z92 = 0
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
## would let one fly.  The pool of shots is not ported, so it never does.
static func _9905(o: SolObjects, s: int) -> void:
	if _9961(o, s) == 0:
		return
	if o.far_x(s) >= 0x04 or o.cool[s] < 0x40:
		_9954(o, s, 0x37)
		return
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
	o.d[s] = (o.d[s] - 1) & 0xFF


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
			if o.frame[s] != 0x01 and o.frame[s] != 0x02 \
					and o.left[s] == 0xFF:
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
			if o.kind[s] < 0x80:
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
			o.mark[o.id[s] & 0x3F] = 0 if n == 0 else n - 1
	if free:
		o.id[s] = 0                         # $80B9
	o.score += score


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
	if o.kind[s] >= 0x02:
		# $AFE8 -- it is getting back up; what it says while it does is sound.
		if o.kind[s] == 0x08:
			o.face_hero(s)              # $8118
			o.face[s] = o.face[s] ^ 0xFF
		o.kind[s] = 0
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
			o.b[s] = (o.b[s] + 1) & 0xFF
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
	# $A21D -- it would let a shot go on step two; the shot pool is not ported.
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
				return                          # $A70B -- only a flash
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
			_a5c6(o, s, 0x11)
		0x15, 0x17:
			_a7e7(o, s, 0x12)
		0x16:
			_a5c6(o, s, 0x18)                   # $A598
			if o.kind[s] != 0x17:
				return
			if (o.clock & 0x01) == 0:
				o.kind[s] = 0x19
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
	# $8848 -- on step two it would let a shot go, but the shot pool is not
	# ported and always answers "no room".


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
		# $8EA9 -- it would let a shot go on step two, but the shot pool is
		# not ported and always answers "no room".
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
		# $89E8 -- it would let a puff of smoke go here, but the effects pool
		# is not ported and always answers "no room", so nothing happens.
		o.move(s)
		return
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
	o.face_hero(s)
	if ((o.face[s] ^ o.d[s]) & 0x80) != 0:
		if (o.b[s] & 0x01) != 0:
			return
		o.nudge(s, 0x01 if (o.d[s] & 0x80) == 0 else 0xFF)
	else:
		if (o.b[s] & 0x02) != 0:
			return
		if o.z94 >= 0x02:
			o.nudge(s, 0xFE if (o.d[s] & 0x80) == 0 else 0x02)
	o.speed_to_step(s)


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
	match o.kind[s]:
		0x00, 0x0A: _k86a1(o, s)
		0x02: _k86c9(o, s)
		0x04: _k8729(o, s)
		0x0C: _k861c(o, s)
		0x0E: _k85ea(o, s, 0x00)
		0x10: _k85ea(o, s, 0xFF)
		0x12: _k856c(o, s, 0x75, 0x00)
		0x14: _k856c(o, s, 0x76, 0xFF)
		0x16: _k8545(o, s)
		0x1E:
			_a10b(o, s)
		0x1B:
			_a53d(o, s)
		0x18: _k84fb(o, s)
		0x1C: _k84d6(o, s)
		0x1E: _k84ba(o, s)
		0x2C: _k865c(o, s)
		_: o.missed(0x3F, false)


## $8359 -- and the same family once it has been finished off.
static func _pickup_dead(o: SolObjects, s: int) -> void:
	match o.kind[s]:
		0x00, 0x02, 0x04, 0x0E, 0x10: _af31(o, s, 0x32)
		0x0C: _af31(o, s, 0x0A)
		0x12, 0x14, 0x2C: _af31(o, s, 0x14)
		0x1E:
			_a10b(o, s)
		0x1B:
			_a53d(o, s)
		0x18: _a989(o, s, 0x00)             # $8F65 -- the sound, then $8F68
		0x16: _k8545(o, s)
		0x1E: _k84aa(o, s)
		_: o.missed(0x3F, true)


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
	# $8516 -- from here it is rising, and what it meets is Э4.3's second half.
	o.missed(0x3F, false)


## $8545 -- it flickers and now and then lets something go.
static func _k8545(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x77)


## $856C / $8566 -- the one that faces a way and fires a spread.
static func _k856c(o: SolObjects, s: int, anim: int, way: int) -> void:
	o.face[s] = way
	o.anim_second(s, anim)
	if o.frame[s] != 0x02:
		if o.frame[s] == 0x03:
			o.d[s] = (o.d[s] + 1) & 0xFF    # $8583 -- which half of the spread
		return
	o.cool[s] = 0x0F + (o.clock & 1)        # $80F2


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
	var gone := false
	if o.level.stage == 1 and ((o.cam_x >> 8) & 0xFF) >= 0x70:
		gone = true
	elif o.level.stage == 2 and ((o.cam_y >> 8) & 0xFF) >= 0x90:
		gone = true
	if gone:
		o.id[s] = 0                         # $80B9


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


## $86C9 -- the spread, and $8729 the single shot.  What they let go is the
## other pool ($0780), which is not here yet.
static func _k86c9(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x6D)
	_pickup_tail(o, s)


static func _k8729(o: SolObjects, s: int) -> void:
	o.anim_second(s, 0x6E)
	_pickup_tail(o, s)


## $875E -- when the walk is over the family goes back to its first kind.
static func _pickup_tail(o: SolObjects, s: int) -> void:
	if o.left[s] == 0xFF:
		o.kind[s] = 0
