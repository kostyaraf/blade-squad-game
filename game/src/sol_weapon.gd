extends RefCounted
class_name SolWeapon

## The third pool: what the hero's own satellite throws.
##
## Sixteen slots at $0700, but only the first eight are ever walked: $B168 in
## bank thirteen counts X down from seven and hands each to $B18D, which reads
## $0700,X and jumps.  Bit seven set means the thing is still flying and the
## table at $B1A6 is used; without it the thing is being born or burning out
## and the table at $B1E1 is used instead.  Both tables are twenty two long.
##
## A slot is six numbers: where it is ($0710:$0720 and $0730:$0740), the two
## bytes the behaviour keeps for itself ($0750 and $0760 -- usually the step
## along and the step down, but several count with them instead) and how much
## it can still go through ($0770).
##
## The whole pool is walked at $CDD2, inside the same call that draws the hero:
## $8007 of bank twelve is $9150, which is "draw him ($9159), then walk this
## pool ($B168)".  So it runs after his own step and before either of the other
## two pools.
##
## `work/re/sol_weapons.md` says where each piece came from.


## $B168 -- one picture of the pool, from slot seven down to slot nought.
static func step(o: SolObjects) -> void:
	for i in range(SolObjects.WALKED - 1, -1, -1):
		_one(o, i)


## $B18D -- which of the two tables, and which entry of it.
static func _one(o: SolObjects, i: int) -> void:
	var m: int = o.w_kind[i]
	if m == 0:
		return                              # $B1A5
	if (m & 0x80) != 0:
		_live(o, i, m & 0x7F)
		return
	_dead(o, i, m)


## $B1A6 -- a thing that is still flying.
static func _live(o: SolObjects, i: int, m: int) -> void:
	match m:
		0x00, 0x15:
			_orbit(o, i)                    # $B6E1
		0x01:
			_spin(o, i)                     # $B5C2
		0x02, 0x0A, 0x0B:
			_bounce(o, i, 0x8C)             # $B36B
		0x03, 0x07, 0x08:
			_carried(o, i)                  # $B42C
		0x04, 0x09:
			_straight(o, i)                 # $B3F1
		0x05:
			_grow(o, i)                     # $B4B4
		0x06:
			_beam(o, i)                     # $B4ED
		0x0C:
			_bounce(o, i, 0x8D)             # $B353
		0x0D:
			_bounce(o, i, 0x8E)             # $B357
		0x0E:
			_bounce(o, i, 0x8F)             # $B35B
		0x0F:
			_bounce(o, i, 0x90)             # $B35F
		0x10:
			_bounce(o, i, 0x91)             # $B363
		0x11:
			_bounce(o, i, 0x00)             # $B367
		0x12:
			_slash(o, i)                    # $B225
		0x13:
			_thrown(o, i)                   # $B6A7
		0x14:
			_coming_back(o, i)              # $B61B
		_:
			o.missed_weapon(m, false)


## $B1E1 -- and one that is not.  Most of the table is $B21F, which simply
## gives the slot up.
static func _dead(o: SolObjects, i: int, m: int) -> void:
	match m:
		0x00, 0x01, 0x02, 0x05, 0x06, 0x08, 0x0A, 0x0B, 0x0C, 0x0D, \
		0x0E, 0x0F, 0x10, 0x11, 0x13, 0x14:
			gone(o, i)                      # $B21F
		0x03, 0x07:
			_pop(o, i)                      # $B20D
		0x04, 0x09:
			_burst(o, i)                    # $B294
		0x12:
			_slash(o, i)                    # $B225, the same either way
		0x15:
			_quiet(o, i)                    # $B216
		_:
			o.missed_weapon(m, true)


# ---- the scratch the behaviours share --------------------------------------

## $880F (bank twelve) -- the four scratch bytes are wiped.
static func _clear(o: SolObjects) -> void:
	o.z90 = 0
	o.z92 = 0


static func _spread(v: int) -> int:
	return (v | 0xFF00) if v >= 0x80 else v


## $B313 -- the slot's own two speeds, each spread over two bytes.
static func _speeds(o: SolObjects, i: int) -> void:
	o.z90 = _spread(o.w_vx[i])
	o.z92 = _spread(o.w_vy[i])


## $B2E2 -- the scratch is added to where it is, along.
static func _add_x(o: SolObjects, i: int) -> void:
	o.carry = 0
	var lo: int = o._adc(o.w_x[i] & 0xFF, o.z90 & 0xFF)
	var hi: int = o._adc((o.w_x[i] >> 8) & 0xFF, (o.z90 >> 8) & 0xFF)
	o.w_x[i] = lo | hi << 8


## $B2D0 -- and down.
static func _add_y(o: SolObjects, i: int) -> void:
	o.carry = 0
	var lo: int = o._adc(o.w_y[i] & 0xFF, o.z92 & 0xFF)
	var hi: int = o._adc((o.w_y[i] >> 8) & 0xFF, (o.z92 >> 8) & 0xFF)
	o.w_y[i] = lo | hi << 8


## $B2CD -- both.
static func _add_both(o: SolObjects, i: int) -> void:
	_add_x(o, i)
	_add_y(o, i)


## $B2CA -- the plain move: its own two speeds, spread and added.
static func _move(o: SolObjects, i: int) -> void:
	_speeds(o, i)
	_add_both(o, i)


## $B2F4 -- the other way about: where it is is added to the scratch, so that
## the scratch becomes the place the thing is looking at.
static func _look(o: SolObjects, i: int) -> void:
	o.carry = 0
	var lo: int = o._adc(o.w_x[i] & 0xFF, o.z90 & 0xFF)
	var hi: int = o._adc((o.w_x[i] >> 8) & 0xFF, (o.z90 >> 8) & 0xFF)
	o.z90 = lo | hi << 8
	o.carry = 0
	lo = o._adc(o.w_y[i] & 0xFF, o.z92 & 0xFF)
	hi = o._adc((o.w_y[i] >> 8) & 0xFF, (o.z92 >> 8) & 0xFF)
	o.z92 = lo | hi << 8


## $C00C -> $D032 -- what the map has where the scratch points.
##
## The carry matters: the way back out of $D032 goes through $C998, whose last
## sum is "this bank plus one", and that never carries.  So a probe always
## leaves the carry clear, and $B3BD leans on it by subtracting without setting
## it first.
static func _probe(o: SolObjects) -> int:
	var t: int = o.probe_point(o.z90, o.z92)
	o.carry = 0
	return t


## $B5BC -- the slot is given up.
static func gone(o: SolObjects, i: int) -> void:
	o.w_kind[i] = 0


## $B595 -- sixteen cells out of the picture in either direction and it is
## gone.  What is left in the scratch is where it stands on the screen.
static func on_screen(o: SolObjects, i: int) -> bool:
	o.carry = 1
	var lo: int = o._sbc(o.w_x[i] & 0xFF, o.cam_x & 0xFF)
	var hi: int = o._sbc((o.w_x[i] >> 8) & 0xFF, (o.cam_x >> 8) & 0xFF)
	if hi >= 0x10:
		gone(o, i)                          # $B5BC
		return false
	o.z90 = lo | hi << 8
	o.carry = 1
	var ly: int = o._sbc(o.w_y[i] & 0xFF, o.cam_y & 0xFF)
	var hy: int = o._sbc((o.w_y[i] >> 8) & 0xFF, (o.cam_y >> 8) & 0xFF)
	if hy >= 0x10:
		gone(o, i)
		return false
	o.z92 = ly | hy << 8
	return true


## $B32C -- it is carried along by the satellite's own step, which the
## satellite leaves in four of its own scratch bytes.
static func _ride(o: SolObjects, i: int) -> void:
	o.carry = 0
	var lo: int = o._adc(o.b[SolObjects.SAT], o.w_x[i] & 0xFF)      # $062C
	var hi: int = o._adc(o.c[SolObjects.SAT], (o.w_x[i] >> 8) & 0xFF)
	o.w_x[i] = lo | hi << 8
	o.carry = 0
	lo = o._adc(o.d[SolObjects.SAT], o.w_y[i] & 0xFF)               # $064C
	hi = o._adc(o.kind[SolObjects.SAT], (o.w_y[i] >> 8) & 0xFF)     # $069C
	o.w_y[i] = lo | hi << 8


# ---- the behaviours --------------------------------------------------------

## $B216 -- the slot is given up and the satellite's walk is put back to its
## first step.
static func _quiet(o: SolObjects, i: int) -> void:
	o.left[SolObjects.SAT] = 0              # $8DCA, with X = $0C
	o.frame[SolObjects.SAT] = 0
	o.anim_a[SolObjects.SAT] = 0
	gone(o, i)                              # $B21F


## $B20D -- the slot is given up where it stands, and the puff is drawn there
## for the one picture.
static func _pop(o: SolObjects, i: int) -> void:
	gone(o, i)                              # $B5BC
	on_screen(o, i)                         # $B595


## $B294 -- the bang: slot thirteen of the other pool is made into the blast,
## and this slot is given up.
static func _burst(o: SolObjects, i: int) -> void:
	o.life[SolObjects.BLAST] = 0x7F         # $06FD
	o.cool[SolObjects.BLAST] = 0x7F         # $06ED
	o.id[SolObjects.BLAST] = 0x0C           # $060D
	o.mind[SolObjects.BLAST] = 0x0C         # $065D
	o.x[SolObjects.BLAST] = o.w_x[i]        # $AD:$BD
	o.y[SolObjects.BLAST] = o.w_y[i]        # $CD:$DD
	o.left[SolObjects.BLAST] = 0            # $06CD
	o.frame[SolObjects.BLAST] = 0           # $06DD
	o.anim_a[SolObjects.BLAST] = 0          # $06AD
	gone(o, i)                              # $B21F


## $B37C -- the step is tried along and then down, and each way that runs into
## something solid is turned round.  Answers how many of the two did.
##
## The second turn is the cartridge's own slip: $B398 sets the carry before it
## negates, $B3BD does not, and a probe always leaves the carry clear -- so the
## step down comes back one too far.
static func _rebound(o: SolObjects, i: int) -> int:
	var hit := 0                            # $4D
	_clear(o)                               # $880F
	o.z90 = _spread(o.w_vx[i])              # $B381
	_look(o, i)                             # $B2F4
	if (_probe(o) & 0x80) != 0:
		o.carry = 1                         # $B398 SEC
		o.w_vx[i] = o._sbc(0x00, o.w_vx[i])
		hit += 1
	_clear(o)                               # $B3A3
	o.z92 = _spread(o.w_vy[i])
	_look(o, i)
	if (_probe(o) & 0x80) != 0:
		o.w_vy[i] = o._sbc(0x00, o.w_vy[i])     # $B3BD, without the SEC
		hit += 1
	_move(o, i)                             # $B2CA
	on_screen(o, i)                         # $B595
	return hit


## $B36B and the six above it -- it bounces off the walls, and on the picture
## it bounces it becomes something else.
static func _bounce(o: SolObjects, i: int, become: int) -> void:
	if _rebound(o, i) != 0:
		o.w_kind[i] = become                # $B378


## $B3F1 -- it goes straight on until the map where it stands is solid, and
## then it becomes the bang.
static func _straight(o: SolObjects, i: int) -> void:
	o.z90 = o.w_x[i]                        # $B3F1
	o.z92 = o.w_y[i]
	if (_probe(o) & 0x80) != 0:
		o.w_kind[i] = 0x09                  # $B410
		return
	_move(o, i)                             # $B2CA
	on_screen(o, i)


## $B42C -- it rides the satellite while its count runs down, and once the
## count would run out it also moves by its own step, which is packed into the
## two halves of a single byte.
static func _carried(o: SolObjects, i: int) -> void:
	_ride(o, i)                             # $B32C
	o.w_vy[i] = (o.w_vy[i] - 1) & 0xFF
	if o.w_vy[i] != 0:
		on_screen(o, i)                     # $B439
		return
	o.w_vy[i] = 0x01                        # $B434
	var v: int = o.w_vx[i]                  # $B449
	o.z90 = _spread(v & 0xF0)
	o.z92 = _spread((v << 4) & 0xF0)
	_add_both(o, i)                         # $B2CD
	on_screen(o, i)


## $B4B4 -- the one that widens: five pictures of a step that is half noise,
## and then it turns into the sixth behaviour.
static func _grow(o: SolObjects, i: int) -> void:
	if o.w_vx[i] >= 0x06:
		o.w_kind[i] = 0x86                  # $B4E4
		o.w_vx[i] = 0x86
		return
	o.w_vx[i] = (o.w_vx[i] + 1) & 0xFF
	_clear(o)                               # $880F
	var a: int = (o.noise & 0x78) | 0x40    # $B4C1
	o.z90 = a
	o.z92 = (a >> 1) + 0x08                 # $B4C9, the carry out of the LSR
	if (o.w_vy[i] & 0x80) != 0:             # is nought, bit nought of $90 is
		o.carry = 1                         # $8FD6 SEC
		o.z90 = o._neg16(o.z90)
	if (o.hero_flags & 0x80) != 0:
		o.carry = 1                         # $8FE8 SEC
		o.z92 = o._neg16(o.z92)
	_add_both(o, i)                         # $B2CD
	on_screen(o, i)                         # $B577


## $B4ED -- the one that crawls along whatever it is on: while the map below it
## is empty it falls, and while the map below it is solid it slides, turning
## round when the way ahead is solid too.  Each turn costs eight of its life.
static func _beam(o: SolObjects, i: int) -> void:
	o.w_vx[i] = (o.w_vx[i] - 1) & 0xFF
	if o.w_vx[i] == 0:
		gone(o, i)                          # $B571 -> $B5BC
		return
	_clear(o)                               # $880F
	o.z92 = 0x0080 if (o.hero_flags & 0x80) != 0 else 0xFF80
	_look(o, i)                             # $B2F4
	if (_probe(o) & 0x80) == 0:
		# $B513 -- nothing under it, so it falls.
		_clear(o)
		o.z92 = 0x0030 if (o.hero_flags & 0x80) != 0 else 0xFFD0
		_add_y(o, i)                        # $B2D0
		on_screen(o, i)                     # $B577
		return
	# $B52B -- the way ahead is only looked at every other picture.
	if ((i ^ o.clock) & 0x01) != 0:
		_clear(o)                           # $B531
		o.z90 = _spread(o.w_vy[i])
		_look(o, i)
		if (_probe(o) & 0x80) != 0:
			# $B55E -- it turns round, and that costs it eight.
			o.carry = 1
			o.w_vy[i] = o._sbc(0x00, o.w_vy[i])
			o.carry = 1
			var r: int = o._sbc(o.w_vx[i], 0x08)
			if r == 0 or o.carry == 0:
				gone(o, i)                  # $B571
				return
			o.w_vx[i] = r                   # $B574
			on_screen(o, i)
			return
	# $B54B -- it slides along, by the step it keeps in its second byte.
	o.z90 = _spread(o.w_vy[i])
	_add_x(o, i)                            # $B2E2
	on_screen(o, i)                         # $B577


## $B225 -- the slash: one thing in the pool stands for a whole row of pictures
## drawn one above the other, and the row is walked here.  Only the first turn
## of the loop moves anything; the rest is drawing, and the one thing that can
## still happen is that the row is found to be off the top of the screen.
static func _slash(o: SolObjects, i: int) -> void:
	o.z92 = (o.w_vx[i] | 0xFF00) & 0xFFFF   # $B229, always upwards
	_add_y(o, i)                            # $B2D0
	var n: int = o.w_vy[i]                  # $B237
	while true:
		# $B23B -- no SEC: the carry runs on from whatever came before.
		var lo: int = o._sbc(o.w_x[i] & 0xFF, o.cam_x & 0xFF)
		var hi: int = o._sbc((o.w_x[i] >> 8) & 0xFF, (o.cam_x >> 8) & 0xFF)
		o.z90 = lo | hi << 8
		var ly: int = o._sbc(o.w_y[i] & 0xFF, o.cam_y & 0xFF)
		var hy: int = o._sbc((o.w_y[i] >> 8) & 0xFF, (o.cam_y >> 8) & 0xFF)
		o.z92 = ly | hy << 8
		if o.carry == 0 and hy < 0xF2:
			gone(o, i)                      # $B25D
			return
		# $B260 -- the rest of the turn only draws, and the pool is not
		# touched again.
		var a: int = 0x01 if n == 0x01 else n
		o.carry = 0
		o._adc(a, hy)                       # $B26C
		n = (n - 1) & 0xFF                  # $B290
		if n == 0:
			return


## $B5C2 -- the one that spins outwards: the angle is its own first byte and
## how far it reaches comes from how much of its life is left.
static func _spin(o: SolObjects, i: int) -> void:
	o.w_vy[i] = (o.w_vy[i] - 1) & 0xFF
	if o.w_vy[i] == 0:
		gone(o, i)                          # $B5C5
		return
	var v: int = o.w_vy[i]                  # $B5C7
	var ring: int = ((v << 2) & 0x30) + 0x40 + ((v >> 6) & 1)
	var st: Array = o.aim(o.w_vx[i], ring & 0xFF)       # $8FF6
	o.z90 = int(st[0])
	o.z92 = int(st[1])
	_add_both(o, i)                         # $B2CD
	on_screen(o, i)


## $B6A7 -- the thrown one: it flies out on the step packed into its first
## byte, and when its count runs out it turns into the one that comes back.
static func _thrown(o: SolObjects, i: int) -> void:
	on_screen(o, i)                         # $B5FE
	o.w_vy[i] = (o.w_vy[i] - 1) & 0xFF
	if o.w_vy[i] == 0:
		o.w_kind[i] = (o.w_kind[i] + 1) & 0xFF          # $B6AF
		var t: int = 0x19 if (o.w_vx[i] & 0x80) != 0 else 0x08
		if (o.w_vx[i] & 0x01) != 0:
			t = t ^ 0x30                    # $B6BF
		o.w_vx[i] = t
		return
	_clear(o)                               # $B6C7
	o.z90 = _spread(o.w_vx[i])
	o.z92 = 0xFFB0 if (o.w_vx[i] & 0x01) != 0 else 0x0050
	_add_both(o, i)                         # $B2CD


## $B61B -- and the one that comes back: it turns four steps of the circle a
## picture towards the satellite, and is caught the moment the two stand in
## the same cell both ways.
static func _coming_back(o: SolObjects, i: int) -> void:
	on_screen(o, i)                         # $B5FE
	var sx: int = o.x[SolObjects.SAT]       # $AC:$BC
	var sy: int = o.y[SolObjects.SAT]       # $CC:$DC
	if ((sx >> 8) & 0xFF) == ((o.w_x[i] >> 8) & 0xFF) \
			and ((sy >> 8) & 0xFF) == ((o.w_y[i] >> 8) & 0xFF):
		o.kind[SolObjects.SAT] = 0x01       # $069C
		gone(o, i)                          # $B657
		return
	o.w_vy[i] = (o.w_vy[i] + 1) & 0xFF      # $B65A
	var n: int = o.w_vy[i]
	var ring := 0x50                        # $B69A
	if n < 0x0F:
		# $B670 -- which way the satellite lies, and one nudge towards it.
		var want: int = o.angle_between(o.w_x[i], o.w_y[i], sx, sy)
		o.carry = 1
		var d: int = o._sbc(want, o.w_vx[i]) & 0x3F
		o.carry = 1 if d >= 0x20 else 0
		o.w_vx[i] = o._adc(0x03 if d >= 0x20 else 0xFC, o.w_vx[i])
		if n < 0x05:
			ring = 0x30                     # $B696
		elif n < 0x0B:
			ring = 0x20                     # $B692
	elif n >= 0x28:
		o.w_vy[i] = 0                       # $B668
	var st: Array = o.aim(o.w_vx[i], ring)  # $B6A1
	o.z90 = int(st[0])
	o.z92 = int(st[1])
	_add_both(o, i)                         # $B2CD


## $B6E1 -- the ring that turns about the satellite.  It is put back on the
## satellite every picture and then pushed out by twice the step the shared
## angle gives, and that angle is the satellite's own, wound on by its own
## turning rate.
##
## The step down is the cartridge's own slip: $B73D reads $4C:$4D for it, which
## is where the step along was put, so the two are always the same.
static func _orbit(o: SolObjects, i: int) -> void:
	o.z90 = 0xE0                            # $B6EB, which ring to read
	o.carry = 0                             # $B6EF CLC
	o.kind[SolObjects.SAT] = o._adc(o.kind[SolObjects.SAT], o.d[SolObjects.SAT])
	var ang: int = o.kind[SolObjects.SAT]   # $069C, and what $8FF6 is handed
	o.w_vx[i] = (o.w_vx[i] - 1) & 0xFF
	if o.w_vx[i] == 0:
		o.w_vy[i] = 0                       # $B6FE
		gone(o, i)
		return
	var st: Array = o.aim(ang, 0xE0)        # $B706
	var dx: int = (int(st[0]) << 1) & 0xFFFF        # $B709
	o.w_x[i] = o.x[SolObjects.SAT]          # $B721
	o.w_y[i] = o.y[SolObjects.SAT]
	o.z90 = dx                              # $B735
	o.z92 = dx                              # $B73D, the slip
	if ((o.hero_face ^ o.hero_flags) & 0x80) != 0:
		o.carry = 1                         # $8FD6 SEC
		o.z90 = o._neg16(o.z90)
	_add_both(o, i)                         # $B76C -> $B2CD
