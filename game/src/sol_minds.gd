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
