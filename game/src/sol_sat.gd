extends RefCounted
class_name SolSat

## Э4.1 -- the hero's own four slots of the object pool, $0C to $0F.
##
## They are not things that were let into the stage: $0C is the satellite the
## finished letter combination gives him, $0D holds its bang, $0E what the
## seventh weapon swings in close, and $0F his punch.  They are walked by
## $A489 in bank twelve, which $9150 reaches every picture, after the hero
## himself ($9159) and after the pool he throws into ($B168).
##
## Everything here is bank twelve's $A489..$AE89, plus $B881 out of bank
## thirteen.  The tables come from work/extract/sol_sat.py.

const FIRST := 0x0C          ## the satellite
const LAST := 0x0F           ## his punch


## $A489 -- the whole walk.  Past state $12 the hero is in a cutscene and none
## of the four is touched at all.
static func step(o: SolObjects) -> void:
	if o.hero_state >= 0x12:
		return                                          # $A490
	for x in range(FIRST, LAST + 1):
		_one(o, x)


## $A493 -- one slot.  A slot whose id has bit 7 is on its way out.
static func _one(o: SolObjects, x: int) -> void:
	var t: int = o.id[x]
	if t == 0:
		return                                          # $A49A
	if (t & 0x80) != 0:
		if t == 0xFF:
			_dying(o, x)                                # $A4BC
			return
		if o.z5fa != 0 or o.hero_state == 0x11:         # $A4A3
			if o.hero_hurt != 0:
				return                                  # $A4B2
			o.anim_second(x, 0x22, 1)                   # $A4B4
			_draw(o, x)                                 # $A4B9
			return
	# $A502 -- one more picture since it was last hit, stopping at $FF.
	if o.cool[x] != 0xFF:
		o.cool[x] += 1
	if o.hero_hurt != 0 and x != 0x0F:
		return                                          # $A511
	_behave(o, x)                                       # $A513
	o.id[x] = o.id[x] & 0x3F                            # $A516
	# $A51E -- and what has been thrown at the hero is laid over the slot as
	# well, so his own satellite can be shot down.
	o.shots_hit_thing(x)
	_draw(o, x)                                         # $A521


## $A6CD -- one of the four slots into the sprite table.  Where it stands is
## counted from the corner of the view, and $9E carries the mark: bit seven is
## the hero's own ($05CB, which says which way up he is) and the bottom two bits
## are put on to make the slot flicker.
##
## It flickers on two counts.  While it is still smarting -- $06E0 below twelve
## -- but then only slots twelve and thirteen; and once that has passed, while
## it is down to its last three points of life, on the pictures $0C says.
static func _draw(o: SolObjects, x: int) -> void:
	if o.table == null:
		return
	var mark: int = o.hero_flags & 0x80                 # $A6E7
	var blink := false
	if o.cool[x] < 0x0C:
		blink = x < 0x0E                                # $A6F5
	elif o.life[x] < 0x04 and (o.clock & 0x08) == 0:
		blink = true                                    # $A702
	if blink:
		mark = mark | 0x03                              # $A70A
	# $A70E -- only five bits of the high byte count, and a picture of nought
	# in both halves is not drawn at all.
	var hi: int = o.pic_hi[x] & 0x1F
	var lo: int = o.pic_lo[x]
	if (hi | lo) == 0:
		return                                          # $A717
	if (o.face[x] & 0x80) != 0:
		# $A724 -- the picture next door, and the add carries into the half
		# that was masked, not into the one that was not.
		lo += 1
		if lo > 0xFF:
			lo &= 0xFF
			hi = (hi + 1) & 0xFF
	SolSprites.picture(lo | hi << 8, mark,
			(o.x[x] - o.cam_x) & 0xFFFF, (o.y[x] - o.cam_y) & 0xFFFF, o.table)


## $A4BC -- the slot has been knocked out and falls off the picture.  Which
## way it falls is the hero's own up and down.
static func _dying(o: SolObjects, x: int) -> void:
	var lo := 0xF0                                      # $92
	var hi := 0xFF                                      # $93
	if (o.hero_flags & 0x80) != 0:
		lo = 0x10                                       # $A4C9
		hi = 0x00                                       # $A4CD, the INC of $FF
	if o.b[x] != 0:
		o.b[x] = (o.b[x] - 1) & 0xFF                    # $A4D4
		if o.b[x] == 0:
			for i in range(SolObjects.WEAPONS):         # $881A
				o.w_kind[i] = 0
		o.y[x] = (o.y[x] + (hi << 8 | lo)) & 0xFFFF     # $AE7C
		# $A4E3 -- and while it falls it is only drawn three pictures in four.
		if (o.clock & 0x02) == 0:
			_draw(o, x)                                 # $A4E9
		return
	lo = (lo << 1) & 0xFF                               # $A4EB, and only the low
	o.y[x] = (o.y[x] + (hi << 8 | lo)) & 0xFFFF
	o.anim_second(x, 0x20, 1)                           # $A4F0
	if (o.left[x] & 0x80) == 0:
		_draw(o, x)                                     # $A4F8
		return
	lose(o)                                             # $9359, $A4FD


## $9359 and $A4FD -- the satellite is lost: its ten bytes are wiped and the
## slot stops being anything at all.  It is one place and not two because
## losing it is one thing, and Э5.5 takes a gun away by the same door.
static func lose(o: SolObjects) -> void:
	_clear_sat(o)                                       # $9359
	o.id[FIRST] = 0                                     # $A4FD


## $934C -- the satellite is taken back in hand: it may be hit again and its
## behaviour loses the bit that says it is flying off.
static func _take_back(o: SolObjects) -> void:
	o.cool[FIRST] = 0xFF
	o.mind[FIRST] = o.mind[FIRST] & 0x7F
	_clear_sat(o)


## $9359 -- and the ten bytes of slot twelve that say what it is doing.  Every
## store here names slot twelve outright, whichever slot the caller was on.
static func _clear_sat(o: SolObjects) -> void:
	o.b[FIRST] = 0
	o.c[FIRST] = 0
	o.d[FIRST] = 0
	o.kind[FIRST] = 0
	o.left[FIRST] = 0
	o.frame[FIRST] = 0
	o.anim_a[FIRST] = 0
	o.anim_b[FIRST] = 0
	o.pic_lo[FIRST] = 0
	o.pic_hi[FIRST] = 0


## $A56A -- which of the three things the slot does this picture.
static func _behave(o: SolObjects, x: int) -> void:
	if o.born_wait != 0 and o.born_wait < 0x31:
		_being_born(o, x)                               # $A52F
		return
	var m: int = int(o.sat_table["mode"][o.hero_state & 0x1F])
	if m != 0 and x == FIRST:                           # $A579, $A5B0
		if m < 2:
			_on_wire(o, x)                              # $A61D
		elif m == 2:
			_burst(o, x)                                # $A5D9
		elif m < 4:
			_burst_slow(o, x)                           # $A5F6
		else:
			# $A5BE -- and four and up only draws.  It goes through $A6CD and
			# comes back to $A516, so $A521 lays the very same picture out a
			# second time.
			_draw(o, x)
		return
	_dispatch(o, x)                                     # $A57B


## $A52F -- the satellite is being made.  Under $21 it only stands there; above
## that it is swung round the hero a step a picture.
static func _being_born(o: SolObjects, x: int) -> void:
	if x != FIRST:
		return                                          # $A531
	var pic := 0x17
	if o.born_wait >= 0x21:
		_place(o, x)                                    # $AE25
		var c: int = (o.hero_face >> 7) & 1             # $A53D ASL A
		var v: int = 0x03 if c != 0 else 0xFC
		o.a[x] = (o.a[x] + v + c) & 0xFF                # $A544
		_swing(o, x)                                    # $ADF5
		pic = 0x1E
	o.anim_second(x, pic, 1)                            # $A553
	# $A564 -- and the ring being drawn round him while it is made, which is
	# handed whole pixels at a fixed place and does not go through $A6CD.
	if o.table != null:
		SolSprites.forward(0x0C, 0, 0x60, 0x10, o.table)


## $A5D9 -- the picture the doubled weapon makes: the satellite is swung four
## steps back a picture at a distance the burst's own countdown gives.
static func _burst(o: SolObjects, x: int) -> void:
	_place_flat(o, x)                                   # $AE1B
	o.z90 = o.z5ab & 0xF0                               # $A5DF, the ring
	o.carry = 1                                         # $A5E3
	o.a[x] = o._sbc(o.a[x], 0x04)
	_reach(o, x, o.a[x], o.z90)                         # $AE05
	o.anim_second(FIRST, 0x18, 1)                       # $A5EF forces slot twelve


## $A5F6 -- and the tail of it, where the step back shrinks as the burst dies.
static func _burst_slow(o: SolObjects, x: int) -> void:
	_place_flat(o, x)                                   # $AE1B
	var ring: int = o.z5ab & 0x70                       # $A5FC
	var back: int = ((ring ^ 0x70) >> 4) & 0x07         # $A600
	o.carry = 0                                         # $A60A CLC, and then SBC
	o.a[x] = o._sbc(o.a[x], back)
	_reach(o, x, o.a[x], ring)                          # $AE05
	o.anim_second(FIRST, 0x18, 1)                       # $A616


## $A61D -- the hero is on his wire.  The satellite is swung to one of two
## resting angles and then held a fixed distance above him, by which picture of
## him is up.
static func _on_wire(o: SolObjects, x: int) -> void:
	if (o.hero_flags & 0x80) != 0:
		o.carry = 0                                     # $A622
		var v: int = o.a[x] & 0x3F
		if v != 0x10:                                   # $A628
			var w: int = (v + 0x30) & 0x3F              # $A62C, with the carry
			o.a[x] = (o.a[x] + (1 if w >= 0x20 else 0xFF)) & 0xFF
	else:
		o.carry = 0                                     # $A63A
		var v: int = o.a[x] & 0x3F
		if v != 0x30:                                   # $A642
			var w: int = (v + 0x10) & 0x3F              # $A644
			o.a[x] = (o.a[x] + (1 if w >= 0x20 else 0xFF)) & 0xFF
	_place_flat(o, x)                                   # $A658
	if o.hero_state != 0x06 and o.hero_fuel >= 0x50:
		_reach(o, x, o.a[x], o.hero_fuel)               # $A6A7
		return
	if o.hero_pic_hi != 0:                              # $A669
		_reach(o, x, o.a[x], o.hero_fuel)
		return
	o.carry = 1                                         # $A66E
	var d: int = o._sbc(o.hero_pic_lo, 0xAC)
	if o.carry == 0:                                    # $A674
		_reach(o, x, o.a[x], o.hero_fuel)
		return
	var i: int = d >> 1                                 # $A676
	if o.left[x] != 0xFF:                               # $A678, $8800
		_spark(o, x)                                    # $A67D
	var t: Array = o.sat_table["wire"]
	if (o.hero_flags & 0x80) != 0:
		o.carry = 1                                     # $A687
		var lo: int = o._sbc(o.y[x] & 0xFF, int(t[i & 0x1F]))
		var hi: int = o._sbc((o.y[x] >> 8) & 0xFF, int(t[(i + 1) & 0x1F]))
		o.y[x] = lo | hi << 8
		return
	o.carry = 0                                         # $A697
	var lo: int = o._adc(int(t[i & 0x1F]), o.y[x] & 0xFF)
	var hi: int = o._adc(int(t[(i + 1) & 0x1F]), (o.y[x] >> 8) & 0xFF)
	o.y[x] = lo | hi << 8


## $A6BA -- the little flash the wire makes, every eighth picture.
static func _spark(o: SolObjects, x: int) -> void:
	_bob(o, x, o.clock & 0x03)                          # $A6C9 -> $AE31


## $A57B -- and otherwise the slot's own behaviour.  Bit 7 of it means the
## slot has been knocked away and is finding its way back.
static func _dispatch(o: SolObjects, x: int) -> void:
	var m: int = o.mind[x]
	if (m & 0x80) != 0:
		_knocked(o, x)                                  # $A733
		return
	match m & 0x7F:
		0x00:
			_whip(o, x)                                 # $A94D
		0x01:
			_grenade(o, x)                              # $ACD4
		0x02:
			_beam(o, x)                                 # $A982
		0x03:
			_bouncer(o, x)                              # $AA70
		0x04:
			_fan(o, x)                                  # $AAAC
		0x05:
			_napalm(o, x)                               # $AC11
		0x06:
			_flame(o, x)                                # $AC4A
		0x07:
			_boomerang(o, x)                            # $A8DB
		0x08, 0x09:
			_aim_sat(o, x)                              # $AD45 and nothing else
		0x0A:
			_punching(o, x)                             # $A82A
		0x0B:
			_slashing(o, x)                             # $A84B
		0x0C:
			_puff(o, x)                                 # $AD30
		0x0D:
			_slash(o, x)                                # $ACAA
		_:
			o.missed_sat(m)


## $A82A -- what the hero's own punch does once it is in slot fifteen.  The
## reach itself is $A861's; all that is left here is the noise it makes on the
## second picture of the first step.
static func _punching(o: SolObjects, x: int) -> void:
	_reaching(o, x, 0x1A)                               # $A82C


## $A84B -- and the slash of the seventh weapon, in slot fourteen.
static func _slashing(o: SolObjects, x: int) -> void:
	_reaching(o, x, 0x1C)                               # $A84D


## $A861 -- one picture of either of them.  While the hero is being left alone
## the reach is carried along with him and hunts for a wall to break; the rest
## of the time it wears out a step at a time and is taken away again.
static func _reaching(o: SolObjects, x: int, pic: int) -> void:
	if o.hero_hurt != 0:                                # $A861
		var step := 0x40                                # $A86C
		var high := 0x00
		if (o.face[x] & 0x80) != 0:                     # $A86B ASL A
			step = 0xC0                                 # $A870
			high = 0xFF                                 # $A872 DEY
		o.carry = 0                                     # $A873
		var lo: int = o._adc(step, o.x[x] & 0xFF)
		var hi: int = o._adc(high, (o.x[x] >> 8) & 0xFF)
		o.x[x] = lo | hi << 8
		_break(o, x)                                    # $A8BA
		_wear(o, x, 0x1F)                               # $A880
		return
	if o.hero_timer == 0x01:                            # $A884
		o.id[x] = 0                                     # $A8B4
		return
	if o.cool[x] != 0xFF:                               # $87FA, $A88E
		_wear(o, x, pic + (1 if o.hero_shield != 0 else 0))
		return
	o.a[x] = (o.a[x] - 1) & 0xFF                        # $A8A7
	if o.a[x] != 0:
		return
	_break(o, x)                                        # $A8AC
	if o.cool[x] == 0xFF:                               # $A8AF, $A8B2
		o.id[x] = 0                                     # $A8B4
		return
	_wear(o, x, pic + (1 if o.hero_shield != 0 else 0))  # $A890


## $A896 -- put the picture on, and take the reach away once the picture says
## it has finished ($8800 reads back a step of $FF).
static func _wear(o: SolObjects, x: int, pic: int) -> void:
	o.anim_second(x, pic, 1)                            # $A897
	if o.left[x] != 0xFF:
		return                                          # $A89D
	o.z5ff = (o.z5ff + 5) & 0xFFFFFF                    # $A8C6, three bytes
	o.id[x] = 0                                         # $A8B4


## $A8BA and $B933 -- the reach asks the stage whether it has hit something it
## can break, and $B9CD answers ($0540 is marked and the face redrawn there).
## What it leaves behind is a piece of rubble in the first free slot counting
## down from eleven, and a second piece let out of that one by $8C83, counting
## up from nought.  Which rubble is left depends on what gave way: two of the
## four kinds leave one piece of the wall itself, and the third leaves a run
## through an eight-long list, whose one marked entry asks the suit and the
## hash which of the two harder pieces to leave.
## $B9C5 -- eight kinds of rubble in turn.  The one with bit seven on is not a
## kind at all: it means "ask the suit".
const WALL := [0x05, 0x04, 0x80, 0x07, 0x04, 0x04, 0x05, 0x06]


static func _break(o: SolObjects, x: int) -> void:
	var v: int = o.break_wall(o.x[x], o.y[x])           # $B93F
	if v < 0:
		return                                          # $B942
	var f := -1
	for i in range(0x0B, -1, -1):                       # $B944
		if o.id[i] == 0:
			f = i
			break
	if f < 0:
		return                                          # $B94E
	var m := 0
	if v != 0x03:                                       # $B953
		if o.hero_hurt != 0:                            # $05C2
			m = 0x05                                    # $B95A
		else:
			m = 0x08 + (o.noise & 0x01)                 # $B95E
	else:
		m = WALL[o.z7c & 0x07]                          # $B96E
		o.z7c = (o.z7c + 1) & 0xFF
		if (m & 0x80) != 0:
			if o.hero_suit >= 0x03 and (o.noise & 0x03) == 0:
				m = 0x07                                # $B984
			else:
				m = 0x06                                # $B980
	o.mind[f] = m                                       # $B986
	o.life[f] = 0x10                                    # $B98B
	o.x[f] = (o.x[x] & 0xFF00) | 0x80                   # $B98E
	o.y[f] = (o.y[x] & 0xFF00) | 0x80
	o.cool[f] = 0x80                                    # $B99C
	o.id[f] = 0x80
	o.left[f] = 0                                       # $8DCA
	o.frame[f] = 0
	o.anim_a[f] = 0
	o.pic_lo[f] = 0                                     # $B9A5
	o.pic_hi[f] = 0
	o.a[f] = 0
	o.kind[f] = 0
	# $B9B1 -- the sound the punch makes ($F1 = $25) is not modelled.
	o.hatch_up(o.x[f], o.y[f], 0x24)                    # $B9B7
	if o.id[0x0F] != 0:                                 # $B9BA
		o.cool[0x0F] = 0                                # $B9BF


# ---------------------------------------------------------------------------
# Where the satellite stands, and which way round the hero it is.

## $AE25 -- on the hero, give or take the bob.  The sixteen-picture bob is
## taken away for half of the cycle and added for the other half.
static func _place(o: SolObjects, x: int) -> void:
	var h: int = o.clock >> 1                           # $AE27
	_bob(o, x, h & 0x0F, (h & 0x10) != 0)


## $AE1B -- and the same without any bob at all.
static func _place_flat(o: SolObjects, x: int) -> void:
	o.face[x] = o.hero_face                             # $AE1E
	_bob(o, x, 0)


## $AE31 and $AE42 -- the two halves of it.  The carry the sum leaves is read
## by $AD4E, so it is kept.
static func _bob(o: SolObjects, x: int, i: int, up := false) -> void:
	var v: int = int(o.sat_table["bob"][i & 0x0F])
	var lo: int
	var hi: int
	if up:
		o.carry = 1                                     # $AE31
		lo = o._sbc(o.hero_y & 0xFF, v)
		hi = o._sbc((o.hero_y >> 8) & 0xFF, 0x00)
	else:
		o.carry = 0                                     # $AE42
		lo = o._adc(o.hero_y & 0xFF, v)
		hi = o._adc((o.hero_y >> 8) & 0xFF, 0x00)
	o.y[x] = lo | hi << 8
	o.face[x] = o.hero_face                             # $AE50
	o.x[x] = o.hero_x


## $AD45 -- stand the satellite on the hero and then swing it.  Holding left or
## right turns it; holding nothing lets it drift back to where it rests.
##
## The two rotations at $AD4E leave the carry in the hand of the sum $AE25 just
## did, and the three at $AD59 read it back, so the carry is carried through.
static func _aim_sat(o: SolObjects, x: int) -> void:
	_place(o, x)                                        # $AE25
	var a: int = (o.hero_face ^ o.hero_flags) & 0xFF    # $AD48
	var r: int = ((a << 1) | o.carry) & 0xFF            # $AD4E
	var c: int = (a >> 7) & 1
	var r2: int = ((r << 1) | c) & 0xFF                 # $AD4F
	o.carry = (r >> 7) & 1
	var y: int = r2 & 0x01                              # $AD50
	var pad: int = o.six & 0x03                         # $AD55
	if pad == 0:
		_drift(o, x, y)                                 # $ADA5
		return
	var v: int = pad                                    # $AD59, three rotations
	for _k in range(3):
		var nc: int = v & 1
		v = ((o.carry << 7) | (v >> 1)) & 0xFF
		o.carry = nc
	o.hero_face = v                                     # $AD5C
	var add: int = 0x10 if (o.hero_flags & 0x80) != 0 else 0x30
	var w: int = (o.a[x] + add + o.carry) & 0xFF        # $AD6A
	w = w & 0x3F
	var stop: int = int(o.sat_table["arc"][y])
	if y == 0:                                          # $AD73
		if w == stop:
			_swing(o, x)
			return
		if w < stop:
			_drift(o, x, y)                             # $AD7A
			return
		if not _flying_away(o, x):                      # $AD7C
			o.a[x] = (o.a[x] - 1) & 0xFF                # $AD87
		_swing(o, x)
		return
	if w == stop:                                       # $AD8D
		_swing(o, x)
		return
	if w > stop:
		_drift(o, x, y)                                 # $AD92
		return
	if not _flying_away_up(o, x):                       # $AD94
		o.a[x] = (o.a[x] + 1) & 0xFF                    # $AD9F
	_swing(o, x)


## $AD7C and $ADCA -- a slot that is on its way out may not be turned past the
## side it is leaving on.
static func _flying_away(o: SolObjects, x: int) -> bool:
	if (o.id[x] & 0x80) == 0:
		return false
	return (((o.id[x] << 1) ^ o.face[x]) & 0x80) != 0


## $AD94 and $ADDE -- and the same the other way round.
static func _flying_away_up(o: SolObjects, x: int) -> bool:
	if (o.id[x] & 0x80) == 0:
		return false
	return (((o.id[x] << 1) ^ o.face[x]) & 0x80) == 0


## $ADA5 -- nothing held, so the satellite drifts back to its resting angle,
## one step every other picture.
static func _drift(o: SolObjects, x: int, y: int) -> void:
	if (o.clock & 0x01) == 0:                           # $ADA7 ROR A / BCC
		_swing(o, x)
		return
	var add: int = 0x10 if (o.hero_flags & 0x80) != 0 else 0x30
	var w: int = ((o.a[x] + add) & 0x3F)                # $ADBE, after a CLC
	var rest: int = int(o.sat_table["arc"][3 + y])
	if w == rest:
		_swing(o, x)                                    # $ADC5
		return
	# $ADC3 and $ADC7 both go by way of $ADDB, and only one corner of the four
	# ends up at $ADDE: a slot that is already short of its resting angle and
	# is being turned the first way round.  Everything else is $ADCA.
	if w < rest and y == 0:                             # $ADDB, with Y nought
		if not _flying_away(o, x):                      # $ADDE
			o.a[x] = (o.a[x] + 1) & 0xFF                # $ADE9
		_swing(o, x)
		return
	# $ADCA reads the two bits the other way round from $AD7C, so the slot on
	# its way out is stopped on the other side.
	if not _flying_away_up(o, x):                       # $ADCA
		o.a[x] = (o.a[x] - 1) & 0xFF                    # $ADD5
	_swing(o, x)


## $ADF5 -- how far out the satellite rides, and the step that puts it there.
## A slot that has been left alone for six pictures rides a ring further out.
static func _swing(o: SolObjects, x: int) -> void:
	var ring: int = 0x80 if o.cool[x] >= 0x06 else 0x70
	_reach(o, x, o.a[x], ring)


## $AE05 -- the angle and the ring become a step, four times over, and the step
## is added to where the hero already put the slot.
static func _reach(o: SolObjects, x: int, ang: int, ring: int) -> void:
	o.spin(ang, ring)                                   # $8FF6
	o.z90 = (o.z90 << 2) & 0xFFFF                       # $AE08
	o.z92 = (o.z92 << 2) & 0xFFFF                       # $AE10
	o.x[x] = (o.x[x] + o.z90) & 0xFFFF                  # $AE6F
	o.y[x] = (o.y[x] + o.z92) & 0xFFFF                  # $AE7C


# ---------------------------------------------------------------------------
# The eight weapons.  Each of them swings the satellite first and then decides
# whether anything is thrown.

## $A94D -- weapon one, the whip.  One press, one lash, and the lash carries
## the satellite a little way with it.
static func _whip(o: SolObjects, x: int) -> void:
	_aim_sat(o, x)
	if o.anim_a[x] != 0:
		o.anim_first(x, o.anim_a[x], 1)                 # $A955
		return
	if (o.pad_new & 0x40) == 0:
		o.anim_second(x, 0x00, 1)                       # $A97D
		return
	var i: int = SolWeapon.throw(o, 0x95, x)            # $A95E
	if i < 0:
		o.anim_second(x, 0x00, 1)
		return
	if (o.face[x] & 0x80) != 0:                         # $A966 ASL A
		o.kind[x] = 0x30
		o.d[x] = 0xFC
	else:
		o.kind[x] = 0x10
		o.d[x] = 0x04
	o.anim_first(x, 0x01, 1)                            # $A978


## $ACD4 -- weapon two, the grenade.  It is let go on the third picture of the
## throw, and which grenade depends on how far the throw has got.
static func _grenade(o: SolObjects, x: int) -> void:
	_aim_sat(o, x)
	if o.anim_a[x] == 0:
		if (o.pad_new & 0x40) == 0:                     # $AD07
			o.anim_second(x, 0x23 if o.hero_state == 0x03 else 0x04, 1)
			return
		if o.w_kind[0] != 0:
			return                                      # $AD0B
		o.anim_first(x, 0x06 if o.hero_state == 0x03 else 0x05, 1)
		return
	o.anim_first(x, o.anim_a[x], 1)                     # $ACDC
	if o.frame[x] != 0x02:
		return                                          # $ACE4
	var kind: int = 0x84 if o.anim_a[x] >= 0x06 else 0x89
	var i: int = SolWeapon.throw(o, kind, x)            # $ACF5
	if (o.face[x] & 0x80) != 0 and i >= 0:              # $ACFB
		o.carry = 1
		o.w_vx[i] = o._sbc(0x00, o.w_vx[i])


## $A982 -- weapon three, the beam.  The satellite remembers how far it was
## carried this picture, and the beam is a string of things thrown from it
## while the button is down.
static func _beam(o: SolObjects, x: int) -> void:
	o.anim_second(x, 0x08 if o.hero_state == 0x03 else 0x07, 1)
	o.b[x] = o.x[x] & 0xFF                              # $A992
	o.c[x] = (o.x[x] >> 8) & 0xFF
	o.d[x] = o.y[x] & 0xFF
	o.kind[x] = (o.y[x] >> 8) & 0xFF
	_aim_sat(o, x)                                      # $A9A6
	o.carry = 1                                         # $A9A9
	o.b[x] = o._sbc(o.x[x] & 0xFF, o.b[x])
	o.c[x] = o._sbc((o.x[x] >> 8) & 0xFF, o.c[x])
	o.carry = 1                                         # $A9BA
	o.d[x] = o._sbc(o.y[x] & 0xFF, o.d[x])
	o.kind[x] = o._sbc((o.y[x] >> 8) & 0xFF, o.kind[x])
	if o.kind[SolObjects.BLAST] != 0:                   # $A9CB
		o.kind[SolObjects.BLAST] -= 1
		return
	o.c[SolObjects.BLAST] = (o.c[SolObjects.BLAST] + 1) & 0xFF
	if o.c[SolObjects.BLAST] == 0:                      # $A9D9
		o.c[SolObjects.BLAST] = 0xFF
		var any := 0
		for i in range(SolObjects.WALKED):              # $A9DE
			any |= o.w_kind[i]
		if any != 0:
			return
	if o.d[SolObjects.BLAST] != 0:                      # $A9F8
		_beam_off(o, x)
		return
	if (o.six & 0x40) != 0:
		o.d[SolObjects.BLAST] = 0x10                    # $AA03
		return
	if (o.clock & 0x01) == 0:
		return                                          # $AA0B ROR A / BCC
	var kind: int = 0x83 if o.hero_state == 0x03 else 0x88
	var i: int = SolWeapon.throw(o, kind, x)            # $AA1B
	if i < 0:
		return
	o.w_kind[i] = 0x03                                  # $AA20


## $AA26 -- and the tail of the beam, once the button has been let go.
static func _beam_off(o: SolObjects, x: int) -> void:
	o.d[SolObjects.BLAST] = (o.d[SolObjects.BLAST] - 1) & 0xFF
	if o.d[SolObjects.BLAST] == 0:
		o.kind[SolObjects.BLAST] = 0x40                 # $AA2B
	if (o.clock & 0x01) != 0:
		o.c[SolObjects.BLAST] = 0x60                    # $AA59
		return
	var kind: int = 0x83 if o.hero_state == 0x03 else 0x88
	var i: int = SolWeapon.throw(o, kind, x)            # $AA4D
	if i < 0:
		o.c[SolObjects.BLAST] = 0xFF                    # $AA52
		return
	if (o.face[x] & 0x80) != 0:                         # $AA5F
		o.carry = 0                                     # $AA69 CLC
		o.w_vx[i] = o._adc(o.w_vx[i] ^ 0xF0, 0x10)
	o.c[SolObjects.BLAST] = 0x60


## $AA70 -- weapon four, the bouncer.  One press, one of them.
static func _bouncer(o: SolObjects, x: int) -> void:
	o.anim_second(x, 0x0A if o.hero_state == 0x03 else 0x09, 1)
	_aim_sat(o, x)
	if (o.pad_new & 0x40) == 0:
		return                                          # $AA85
	var kind: int = 0x82 if o.hero_state == 0x03 else 0x8A
	var i: int = SolWeapon.throw(o, kind, x)            # $AA94
	if i < 0:
		return
	if (o.face[x] & 0x80) != 0:                         # $AAA0
		o.carry = 1
		o.w_vx[i] = o._sbc(0x00, o.w_vx[i])


## $AAAC -- weapon five, the fan.  The satellite is first walked round to one
## side, and then it goes through five states of charging and letting go.
static func _fan(o: SolObjects, x: int) -> void:
	o.anim_second(x, 0x0C if o.hero_state == 0x03 else 0x0B, 1)
	_aim_sat(o, x)
	var flip: int = 0x3F if (o.hero_flags & 0x80) != 0 else 0x00
	var one: int = (0x08 if o.hero_state == 0x03 else 0x04) ^ flip
	var two: int = one ^ 0x1F                           # $AADB
	var v: int = o.b[x] & 0x3F                          # $AAE3
	if (o.face[x] & 0x80) == 0:                         # $AAE2 ROL A
		if v != one:
			o.b[x] = (o.b[x] + 1) & 0xFF                # $AAEE
	elif v != two:
		o.b[x] = (o.b[x] - 1) & 0xFF                    # $AAF8
	_fan_state(o, x)                                    # $AB67
	if o.kind[x] == 0 or o.kind[x] == 0x04:
		return                                          # $AB01, $AB05
	if (o.clock & 0x01) == 0:
		o.c[x] = (o.c[x] + 1) & 0xFF                    # $AB16
	var t: Array = o.sat_table["fan"]
	o.carry = 0                                         # $AB1F
	o.d[x] = o._adc(int(t[o.c[x] & 0x1F]), o.b[x])
	if (o.clock & 0x01) != 0:
		return                                          # $AB2C
	var i: int = SolWeapon.throw(o, 0x81, x)            # $AB30
	if i < 0:
		return
	o.w_vx[i] = o.d[x]                                  # $AEB2
	o.w_vy[i] = o.kind[SolObjects.BLAST]


## $AB67 -- the five states of the fan, out of the table at $AB79.
static func _fan_state(o: SolObjects, x: int) -> void:
	match o.kind[x]:
		0x00:
			_fan_idle(o, x)                             # $AB83
		0x01:
			_fan_charging(o, x)                         # $ABAE
		0x02:
			_fan_held(o, x)                             # $ABD6
		0x03:
			_fan_letting_go(o, x)                       # $ABE8
		0x04:
			o.d[SolObjects.BLAST] = \
					(o.d[SolObjects.BLAST] - 1) & 0xFF  # $AC06
			if o.d[SolObjects.BLAST] == 0:
				o.kind[x] = 0
		_:
			o.missed_sat(0x80 | o.kind[x])


## $AB83 -- nothing held yet: a press starts the charge, and otherwise one
## blade is thrown every other picture.
static func _fan_idle(o: SolObjects, x: int) -> void:
	if (o.pad_new & 0x40) != 0:
		o.kind[x] = (o.kind[x] + 1) & 0xFF              # $AB87
		o.kind[SolObjects.BLAST] = 0x01
		o.d[SolObjects.BLAST] = 0x01
		return
	if (o.clock & 0x01) == 0:
		return                                          # $AB96
	var i: int = SolWeapon.throw(o, 0x81, x)            # $AB9A
	if i < 0:
		return
	o.w_vx[i] = o.a[x] ^ 0x3F                           # $AB9F, $AEB2
	o.w_vy[i] = 0x02


## $ABAE -- the button is down and the fan winds up, stopping at $10.
static func _fan_charging(o: SolObjects, x: int) -> void:
	if (o.six & 0x40) == 0:
		o.kind[x] = 0x03                                # $ABB2
		return
	if (o.clock & 0x07) == 0:
		o.kind[SolObjects.BLAST] = \
				(o.kind[SolObjects.BLAST] + 1) & 0xFF   # $ABBE
	if o.kind[SolObjects.BLAST] < 0x11:
		return                                          # $ABC6
	o.kind[SolObjects.BLAST] = 0x10                     # $ABC8
	o.kind[x] = (o.kind[x] + 1) & 0xFF
	o.d[SolObjects.BLAST] = 0x60


## $ABD6 -- wound up and held.  Letting go, or running the hold out, moves on.
static func _fan_held(o: SolObjects, x: int) -> void:
	if (o.six & 0x40) != 0:
		o.d[SolObjects.BLAST] = \
				(o.d[SolObjects.BLAST] - 1) & 0xFF      # $ABDA
		if o.d[SolObjects.BLAST] != 0:
			return
	o.d[SolObjects.BLAST] = 0                           # $ABDF
	o.kind[x] = (o.kind[x] + 1) & 0xFF


## $ABE8 -- and then it unwinds again.
static func _fan_letting_go(o: SolObjects, x: int) -> void:
	if (o.clock & 0x07) == 0:
		o.kind[SolObjects.BLAST] = \
				(o.kind[SolObjects.BLAST] - 1) & 0xFF   # $ABEE
	var v: int = o.kind[SolObjects.BLAST]
	if v != 0 and (v & 0x80) == 0:
		return                                          # $ABF6
	o.kind[SolObjects.BLAST] = 0                        # $ABF8
	o.kind[x] = (o.kind[x] + 1) & 0xFF
	o.d[SolObjects.BLAST] = 0x40


## $AC11 -- weapon six, the napalm.  One every eighth picture while held.
static func _napalm(o: SolObjects, x: int) -> void:
	o.anim_second(x, 0x03 if o.hero_state == 0x03 else 0x02, 1)
	_aim_sat(o, x)
	if (o.six & 0x40) == 0:
		return                                          # $AC28
	if (o.clock & 0x07) != 0:
		return                                          # $AC2E
	var i: int = SolWeapon.throw(o, 0x85, x)            # $AC32
	if i < 0:
		return
	if (o.face[x] & 0x80) != 0:                         # $AC3E
		o.carry = 1
		o.w_vy[i] = o._sbc(0x00, o.w_vy[i])


## $AC4A -- weapon seven, the slash.  Nothing is thrown into the $0700 pool at
## all: the slash is put into slot $0E of this very pool.
static func _flame(o: SolObjects, x: int) -> void:
	_aim_sat(o, x)
	if o.anim_a[x] == 0:
		if (o.pad_new & 0x40) == 0:
			o.anim_second(x, 0x11, 1)                   # $ACA5
			return
		o.anim_first(x, 0x13 if o.hero_state == 0x03 else 0x12, 1)
		return
	o.anim_first(x, o.anim_a[x], 1)                     # $AC52
	if o.left[x] != 0x01 or o.frame[x] != 0x02:
		return                                          # $AC5A, $AC61
	o.z90 = o.x[x]                                      # $AC63
	o.z92 = o.y[x]
	var three: bool = o.hero_state == 0x03              # $AC78 CMP #$03
	o.carry = 1 if o.hero_state >= 0x03 else 0
	_slash_into(o, 0x28 if three else 0x20, 0x0E)       # $B881


## $B862 -- and the other way into it: the hero's own animation, which strikes
## on one named step of a handful of his pictures ($B81E).  What is struck is
## always slot fifteen, and the two longer reaches leave a ten in its angle.
##
## $B871 hands $B881 the hero's own place rather than a slot's, and the carry
## comes from the compare at $B864, so it is set here in the same order.
static func strike(o: SolObjects, at: int, px: int, py: int) -> void:
	o.z90 = px                                          # $B871
	o.z92 = py
	o.carry = 1 if at >= 0x10 else 0                    # $B864
	_slash_into(o, at, LAST)
	if at >= 0x10:
		o.a[LAST] = 0x14                                # $B86D


## $B881 (bank 13) -- put the slash into a slot of this pool.  The sums carry
## on from the compare that chose the stance, which is the cartridge's own
## doing and is kept.
static func _slash_into(o: SolObjects, at: int, s: int) -> void:
	o.face[s] = o.hero_face                             # $B884
	var i: int = at
	if (o.hero_face & 0x80) != 0:
		i += 4                                          # $B889
	var t: Array = o.sat_table["melee_at"]
	var lo: int = o._adc(o.z90 & 0xFF, int(t[i]))       # $B88D
	var hi: int = o._adc((o.z90 >> 8) & 0xFF, int(t[i + 1]))
	o.x[s] = lo | hi << 8
	if (o.hero_flags & 0x80) != 0:
		lo = o._sbc(o.z92 & 0xFF, int(t[i + 2]))        # $B8A2
		hi = o._sbc((o.z92 >> 8) & 0xFF, int(t[i + 3]))
	else:
		lo = o._adc(o.z92 & 0xFF, int(t[i + 2]))        # $B8B5
		hi = o._adc((o.z92 >> 8) & 0xFF, int(t[i + 3]))
	o.y[s] = lo | hi << 8
	var k: int = (i & 0xF8) >> 2                        # $B8C5
	var w: Array = o.sat_table["melee_is"]
	o.mind[s] = int(w[k])                               # $B8CB
	o.life[s] = 0x1F
	o.id[s] = 0x1F
	o.a[s] = 0x0A
	o.pic_lo[s] = int(w[k + 1])                         # $B8DE
	o.pic_hi[s] = 0x01
	o.left[s] = 0
	o.frame[s] = 0
	o.cool[s] = 0xFF


## $A8DB -- weapon eight, the boomerang.  It is let go on the third picture of
## the throw, and a hero standing on his head throws a different one.
static func _boomerang(o: SolObjects, x: int) -> void:
	_aim_sat(o, x)
	if o.anim_a[x] == 0:
		if (o.pad_new & 0x40) != 0:                     # $A919
			o.kind[x] = 0                               # $A937
			o.anim_first(x, 0x25 if o.hero_state == 0x03 else 0x24, 1)
			return
		if o.kind[x] != 0:                              # $A932
			o.kind[x] = 0
			return
		o.anim_second(x, 0x0E if o.hero_state == 0x03 else 0x0D, 1)
		return
	o.anim_first(x, o.anim_a[x], 1)                     # $A8E3
	if o.left[x] != 0x02 or o.frame[x] != 0x02:
		return                                          # $A8EB, $A8F2
	var i: int = SolWeapon.throw(o, 0x93, x)            # $A8F6
	if i < 0:
		return
	if (o.face[x] & 0x80) != 0:                         # $A900
		o.carry = 1
		o.w_vx[i] = o._sbc(0x00, o.w_vx[i])
	if (o.hero_flags & 0x80) != 0:                      # $A90E
		o.w_vx[i] = o.w_vx[i] | 0x01


## $AD30 -- behaviour $0C, the puff the wire leaves.  It stands still until its
## walk reaches the step that is held for ever.
static func _puff(o: SolObjects, x: int) -> void:
	o.cool[x] = 0x0C                                    # $AD32
	o.anim_second(x, 0x19, 1)
	if o.left[x] != 0xFF:
		return                                          # $AD3D
	o.id[x] = 0


## $ACAA -- behaviour $0D, the slash itself.  Once it has been hit it counts
## down instead; otherwise it lives as long as its walk does.
static func _slash(o: SolObjects, x: int) -> void:
	if o.cool[x] == 0xFF:                               # $ACAD
		o.a[x] = (o.a[x] - 1) & 0xFF                    # $ACC9
		if o.a[x] != 0:
			return
		o.id[x] = 0
		return
	o.anim_second(x, 0x1C, 1)                           # $ACAF
	if o.left[x] == 0xFF:
		o.id[x] = 0                                     # $ACB7
		return
	if o.left[x] != 0x01 or o.frame[x] != 0x01:
		return                                          # $ACBB, $ACC2


# ---------------------------------------------------------------------------
# The slot that has been knocked away.

## $A733 -- bit 7 of the behaviour.  The satellite has been hit and either
## drifts off the side, falls, or finds its way back to the hero.
static func _knocked(o: SolObjects, x: int) -> void:
	o.anim_second(x, 0x14, 1)                           # $A735
	if (o.b[x] & 0x80) != 0:
		_coming_back(o, x)                              # $A779
		return
	if (o.id[x] & 0x80) != 0:
		o.b[x] = 0xFF                                   # $A754
		_leaving(o, x)
		return
	o.carry = 1                                         # $A742, a 16-bit compare
	var lo: int = o._sbc(o.x[x] & 0xFF, o.cam_x & 0xFF)
	var hi: int = o._sbc((o.x[x] >> 8) & 0xFF, (o.cam_x >> 8) & 0xFF)
	if o.carry != 0 and hi < 0x10:
		# $A76A -- still on the picture, so it only slides sideways.
		o.z90 = 0
		o.z92 = 0                                       # $880F
		var v: int = o.c[x]
		o.z90 = v | (0xFF00 if (v & 0x80) != 0 else 0)
		o.x[x] = (o.x[x] + o.z90) & 0xFFFF              # $AE6F
		o.y[x] = (o.y[x] + o.z92) & 0xFFFF
		return
	o.b[x] = 0x80                                       # $A750
	_leaving(o, x)


## $A75D -- and which way it leaves, which is the sign of its sideways step
## turned round.
static func _leaving(o: SolObjects, x: int) -> void:
	o.kind[x] = ((o.c[x] >> 2) ^ 0x20) & 0x20


## $A779 -- it is off the picture now.  It is held against the edge until the
## hero is near enough for it to come back.
static func _coming_back(o: SolObjects, x: int) -> void:
	if o.b[x] == 0xFF:
		_finding_hero(o, x)                             # $A7B3
		return
	if (o.clock & 0x01) != 0:
		o.b[x] = (o.b[x] + 1) & 0xFF                    # $A782
	var hi: int = (o.cam_x >> 8) & 0xFF                 # $A789
	if (o.c[x] & 0x80) == 0:
		o.carry = 0
		hi = o._adc(hi, 0x10)                           # $A78D
	o.x[x] = (o.x[x] & 0xFF) | hi << 8
	o.carry = 1                                         # $A791
	o._sbc(o.y[x] & 0xFF, o.cam_y & 0xFF)
	var d: int = o._sbc((o.y[x] >> 8) & 0xFF, (o.cam_y >> 8) & 0xFF)
	if o.carry == 0:
		# $A7A0 -- above the picture, so it is pulled down to the top of it.
		o.carry = 0
		var h: int = o._adc(0x00, (o.cam_y >> 8) & 0xFF)
		o.y[x] = (o.y[x] & 0xFF) | h << 8
	o.pic_lo[x] = 0                                     # $A7A4
	o.pic_hi[x] = 0
	o.frame[x] = 0
	o.left[x] = 0


## $A7B3 -- and the way home.  The heading is worked out from the hero to the
## satellite, and the satellite is steered two steps a picture toward it.
##
## $C051 saves Y in $90 before it swaps banks, so the hero's own low byte is
## gone by the time the heading is worked out and the animation walk's leftover
## Y stands in for it.  That is the cartridge's doing and it is kept.
static func _finding_hero(o: SolObjects, x: int) -> void:
	var px: int = o.hero_x                              # $A7BB
	var py: int = o.hero_y
	var sx: int = o.x[FIRST]                            # $A7C3, always slot twelve
	var sy: int = o.y[FIRST]
	if ((px >> 8) & 0xFF) == ((sx >> 8) & 0xFF):        # $A7D3
		var a: int = (py >> 8) & 0xFF
		var b: int = (sy >> 8) & 0xFF
		if a == b or ((a - 1) & 0xFF) == b or ((a + 1) & 0xFF) == b:
			_take_back(o)                               # $A7F9
			o.a[x] = 0x30
			return
	var ang: int = o.angle_between(o.y_reg, py, sx, sy)  # $A802, with $90 gone
	if (ang & 0x80) != 0:
		_take_back(o)                                   # $A805
		o.a[x] = 0x30
		return
	o.carry = 1                                         # $A807
	var d: int = o._sbc(ang, o.kind[x]) & 0x3F
	o.carry = 0                                         # $A815
	o.kind[x] = o._adc(0x02 if d >= 0x20 else 0xFE, o.kind[x])
	o.spin(o.kind[x], 0x50)                             # $A81C, $8FF6
	o.x[x] = (o.x[x] + o.z90) & 0xFFFF                  # $AE6F
	o.y[x] = (o.y[x] + o.z92) & 0xFFFF


# ---------------------------------------------------------------------------
# The letters.  Three of them are picked up in a stage, and a combination the
# game knows gives a satellite.  $923B is the tail of $9159, which is mostly
# drawing the hero and the strip at the bottom; these are the only parts of it
# that are not drawing.


## $923B -- is a combination finished, and is anything already counting down.
static func letters(o: SolObjects) -> void:
	if o.hero_hurt != 0 or o.born_wait != 0:
		_counting(o)                                    # $9241
		return
	if o.hero_state == 0x0D:
		return                                          # $924A
	# $924B -- the eight combinations, read from the top down; the first that
	# matches starts the wait at $80.
	for i in range(7, -1, -1):
		if int(o.sat_table["combos"][i]) == o.letters:
			o.born_wait = 0x80                          # $925C
			break
	if o.born_wait != 0:
		_counting(o)                                    # $9262
		return
	_boxes(o)                                           # $9264


## $92B5 -- the wait counts down.  At $30 exactly the satellite is made; below
## that nothing more is done, and the whole pool is standing still anyway
## ($A56A holds it there).  Above it the boxes are drawn on the pictures whose
## bit three is clear, which is what makes them flash.
static func _counting(o: SolObjects) -> void:
	if o.born_wait == 0:
		return                                          # $92BB
	o.born_wait = (o.born_wait - 1) & 0xFF
	if o.born_wait == 0x30:
		_make(o)                                        # $92CD
		return
	if o.born_wait < 0x30:
		return                                          # $92C4
	if (o.born_wait & 0x08) == 0:
		_boxes(o)                                       # $92CA


## $9264 and $927B -- the three boxes on the strip.  Drawing them is not this
## module's business, but each box carries a timer of its own in $070C, $070D
## and $070E -- three bytes of the $0700 pool that the pool walk never reaches,
## because $B168 only walks the first eight -- and a box whose timer is running
## is drawn empty every other four pictures.  Only the timer is state.
static func _boxes(o: SolObjects) -> void:
	for i in range(3):
		if o.w_kind[0x0C + i] != 0:
			o.w_kind[0x0C + i] = (o.w_kind[0x0C + i] - 1) & 0xFF  # $9292


## $92CD -- the combination is looked up once more and paid out.  A combination
## that gives the weapon he is already holding does not give a second one: the
## one he has bursts instead, and that is the "super" the game is named for.
static func _make(o: SolObjects) -> void:
	var at := -1
	for i in range(7, -1, -1):
		if int(o.sat_table["combos"][i]) == o.letters:
			at = i
			break
	if at < 0:
		return                                          # $92DA
	o.letters = 0                                       # $92DD
	o.id[SolObjects.BLAST] = 0                          # $92E0
	for i in range(11):
		o.w_kind[i] = 0                                 # $92E5, eleven of them
	var give: int = int(o.sat_table["weapon_of"][at])
	var have: int = o.id[FIRST] & 0x3F                  # $92EB
	if have != 0 and have == give:
		o.life[FIRST] = 0x10                            # $92F7
		o.hero_state = 0x0D                             # $9302
		o.z5ab = 0x7F                                   # $9307
		o.letters = 0                                   # $930C
		return
	# $9310 -- a new satellite, resting on the side he is looking away from.
	o.a[FIRST] = 0x2B if (o.hero_face & 0x80) != 0 else 0x35
	o.mind[FIRST] = at                                  # $9324
	o.id[FIRST] = give                                  # $9327
	o.life[FIRST] = 0x10                                # $9347
	_take_back(o)                                       # $934C
