extends RefCounted
class_name SolShots

## The second pool: what things throw at the hero.
##
## Sixteen slots of its own at $0780, walked by $B2E9 of bank three before the
## objects are walked at all ($CDDA comes before $CDDD).  A slot carries a
## behaviour number in $0780 -- bit seven means it is still flying, and without
## it the thing is burning out -- and $B304 turns that into one of forty eight
## addresses out of one table or the other ($B317 for the flying, $B386 for the
## rest) and jumps.
##
## A slot is six numbers: where it is ($0790:$07A0 and $07B0:$07C0), two bytes
## the behaviour keeps for itself ($07D0 and $07E0, usually the step along and
## the step down) and how much it still has to give ($07F0).
##
## `work/re/sol_shots.md` says where each piece came from and what is still
## missing; a behaviour that has not been read is counted, not guessed at.


## $B2E9 -- one frame of the pool, from the last slot down to the first.  A
## ride under way holds the whole of it still, exactly as it holds the objects.
static func step(o: SolObjects) -> void:
	if o.ride_hold != 0 and o.ride_hold < 0x30:
		return
	for i in range(SolObjects.SHOTS - 1, -1, -1):
		if o.s_kind[i] == 0:
			continue
		_run(o, i)


## $B304 -- which of the two tables, and which entry of it.
static func _run(o: SolObjects, i: int) -> void:
	var m: int = o.s_kind[i]
	if (m & 0x80) == 0:
		_dead(o, i, m & 0x7F)               # $B377
		return
	_live(o, i, m & 0x7F)


## $B317 -- a shot that is still flying.
static func _live(o: SolObjects, i: int, m: int) -> void:
	match m:
		0x03:
			_bubble(o, i)                   # $B8A1
		0x05:
			_arc(o, i)                      # $BB5B
		0x00, 0x01:
			_wear(o, i)                     # $BC17
		0x02:
			_nibble(o, i)                   # $BC2C
		0x04:
			_shatter(o, i)                  # $BB9E
		0x07:
			_held(o, i)                     # $BA22
		0x0A:
			_countdown(o, i)                # $B8F5
		0x0B:
			_plain(o, i)                    # $B918
		0x1C:
			_fall(o, i)                     # $B638
		0x2F:
			_drift_down(o, i)               # $B3E6
		_:
			o.missed_shot(m, false)


## $B386 -- and one that is burning out.  Most of the table is $BD4F, which
## simply lets the slot go; the few that are not point at the same behaviour
## the flying one had.
static func _dead(o: SolObjects, i: int, m: int) -> void:
	match m:
		0x00, 0x01, 0x02, 0x05, 0x06, 0x07, 0x08, 0x0B, 0x0C, 0x1C, \
		0x21, 0x22, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, \
		0x2C, 0x2D, 0x2E:
			gone(o, i)                      # $BD4F
		0x03:
			_bubble(o, i)                   # $B8A1, the same either way
		0x04:
			_wearout(o, i)                  # $BB7B
		0x0A:
			_countdown(o, i)                # $B8F5
		_:
			o.missed_shot(m, true)


# ---- the behaviours ------------------------------------------------------

## $B8A1 -- the bubble: it rises, wandering from side to side, and only lives
## while the map around it is still the water it came out of.
static func _bubble(o: SolObjects, i: int) -> void:
	if ((i ^ o.clock) & 0x03) == 0:
		# $B8E5 -- the map at the bubble's own place, every fourth picture.
		var t: int = o.probe_point(o.s_x[i], o.s_y[i])
		if (t & 0x80) != 0 or (t & 0x78) < 0x60 or (t & 0x18) != 0x08:
			gone(o, i)                      # $B8B9
			return
	# $B8BF -- a quarter turn every picture, and the ring is the nearest one,
	# so the wandering is never more than sixteen sixteenths wide.
	o.s_a[i] = (o.s_a[i] + 0x04) & 0xFF
	var step: Array = o.aim(o.s_a[i], 0)
	# $B8CF -- the rise itself is not the angle's: it is the slot's own second
	# byte with $FF over it, so it is always upwards.
	move(o, i, int(step[0]), (o.s_b[i] | 0xFF00) & 0xFFFF)
	on_screen(o, i)


## $BB5B -- the thrown thing: it keeps the step along it was given and gains
## two a picture downwards, until the gain would turn the byte over and $7F is
## put there instead.
static func _arc(o: SolObjects, i: int) -> void:
	var b: int = (o.s_b[i] + 0x02) & 0xFF
	o.s_b[i] = o.z7f if (b & 0x80) != 0 else b
	drift(o, i)                             # $BC77
	on_screen(o, i)                         # $BCF7


## $B638 -- the plain falling shot: half a tile down every picture, and gone
## the moment the map it has reached is solid.
static func _fall(o: SolObjects, i: int) -> void:
	on_screen(o, i)                         # $BCF7
	# $B8E5 -- the map at the shot's own place, with no offset at all.
	if (o.probe_point(o.s_x[i], o.s_y[i]) & 0x80) != 0:
		gone(o, i)                          # $B64B
		return
	move_y(o, i, 0x0080)                    # $B651 -> $BC7D


## $BD4F -- the slot is let go.
static func gone(o: SolObjects, i: int) -> void:
	o.s_kind[i] = 0


# ---- the moving about, which nearly every behaviour is built out of --------

## $BCC3 -- $90:$91 is the step along, the byte at $07D0 spread over two.
static func along(o: SolObjects, i: int) -> int:
	return _spread(o.s_a[i])


## $BCD1 -- and $92:$93 the step down, out of $07E0.
static func down(o: SolObjects, i: int) -> int:
	return _spread(o.s_b[i])


static func _spread(v: int) -> int:
	return v | (0xFF00 if (v & 0x80) != 0 else 0)


## $BC8F -- the slot moves along by $90:$91.
static func move_x(o: SolObjects, i: int, dx: int) -> void:
	o.s_x[i] = (o.s_x[i] + dx) & 0xFFFF


## $BC7D -- the slot moves down by $92:$93, and no further along.
static func move_y(o: SolObjects, i: int, dy: int) -> void:
	o.s_y[i] = (o.s_y[i] + dy) & 0xFFFF


## $BC7A -- both at once.
static func move(o: SolObjects, i: int, dx: int, dy: int) -> void:
	move_x(o, i, dx)
	move_y(o, i, dy)


## $BC77 -- the plain move, both steps out of the slot's own two bytes.
static func drift(o: SolObjects, i: int) -> void:
	move(o, i, along(o, i), down(o, i))


## $BCFA -- how far along the screen it is, and it is let go the moment it is
## more than sixteen screens away, which is the cartridge's way of saying "off
## the map".  $BCF7 asks the same of the height first.
static func on_screen_x(o: SolObjects, i: int) -> bool:
	var d: int = (o.s_x[i] - o.cam_x) & 0xFFFF
	if (d >> 8) >= 0x10:
		gone(o, i)
		return false
	return true


## $BD55 -- the same for the height.
static func on_screen_y(o: SolObjects, i: int) -> bool:
	var d: int = (o.s_y[i] - o.cam_y) & 0xFFFF
	if (d >> 8) >= 0x10:
		gone(o, i)
		return false
	return true


## $BCF7 -- both, the height first.  The height's own test branches into $BD4F
## rather than jumping, so the width is still asked even once the slot has been
## let go; both are kept here for the same reason.
static func on_screen(o: SolObjects, i: int) -> bool:
	var tall: bool = on_screen_y(o, i)
	var wide: bool = on_screen_x(o, i)
	return tall and wide


## $BCDF -- the same pair, but the height is let through when it is above the
## top of the screen rather than below it.
static func on_screen_up(o: SolObjects, i: int) -> bool:
	var d: int = o.s_y[i] - o.cam_y
	var tall := true
	if d >= 0 and ((d >> 8) & 0xFF) >= 0x10:
		gone(o, i)
		tall = false
	var wide: bool = on_screen_x(o, i)
	return tall and wide


## $ADBA -- the last slot still free, or -1 when there is none.
static func free_slot(o: SolObjects) -> int:
	for i in range(SolObjects.SHOTS - 1, -1, -1):
		if o.s_kind[i] == 0:
			return i
	return -1


## $A7B0 -- the hero's breath, and the bubbles it leaves.  It runs inside his
## own step, before anything is asked of the shots, so a bubble born here has
## already moved by the time the picture is over.
static func breathe(o: SolObjects, p: SolPlayer) -> void:
	var v: int = p.seen                     # $05CA, what he is standing in
	var c := 1
	var wet := false
	if (v & 0x78) < 0x60:
		c = 0                               # $A7B7 -- the compare left it down
	elif (v & 0x18) == 0x08:
		wet = true                          # $A7BF
	if not wet:
		# $A7C1 -- out of the water it comes back two a picture, and the carry
		# the last compare left is added along with them.
		o.z58 = min(o.z58 + 2 + c, 0xFF)
		return
	if p.timer >= 0x1F:                     # $A7CE
		var was: int = o.z58
		if was == 0:
			return
		o.z58 = was - 1
		# $A7DB -- the compare is of what it was, not what it has become: only
		# the first quarter of his breath makes bubbles.
		if was < 0xC0:
			return
	if (o.clock & 0x03) != 0:
		return                              # $A7DF -- one picture in four
	if p.state >= 0x11:
		return                              # $A7E5
	var i: int = free_slot(o)               # $A7EC
	if i < 0:
		return
	o.s_kind[i] = 0x03                      # $A7F8
	o.s_life[i] = 0x03
	o.s_b[i] = 0xE0                         # $A800 -- the rise, always upwards
	# $A805 -- his place, half a tile back.  The carry is still down from the
	# compare that let him through, so it is one sixteenth further back again.
	var back: Array = o._sub2(p.x, 0x0080, 0)
	# $A811 -- the height is his own low byte with a whole screen added.
	var hi: int = ((p.y >> 8) & 0xFF) + 1
	o.s_y[i] = ((hi & 0xFF) << 8) | (p.y & 0xFF)
	# $A81E -- and it is set out sideways by where the count of pictures has
	# got to, so a string of them does not rise in one line.
	o.s_x[i] = o._add2(back[0], ((o.clock & 0x0C) << 4) & 0xFF,
			1 if hi > 0xFF else 0)[0]


## $907B -- the slot is taken: this behaviour, and one to give.
static func put(o: SolObjects, i: int, kind: int) -> void:
	o.s_kind[i] = kind
	o.s_life[i] = 1


## $A1C2 -- the new shot starts exactly where the thing itself is.
static func place_at(o: SolObjects, i: int, s: int) -> void:
	o.s_x[i] = o.x[s]
	o.s_y[i] = o.y[s]


## $A1D7 -- the new shot starts at the thing's own place plus whatever offset
## the behaviour worked out.  The add takes the carry the last thing before it
## left standing, so every caller has to say what that was.
static func place(o: SolObjects, s: int, i: int, dx: int, dy: int,
		c: int) -> int:
	var r: Array = o._add2(o.x[s], dx, c)
	o.s_x[i] = r[0]
	r = o._add2(o.y[s], dy, r[1])
	o.s_y[i] = r[0]
	return r[1]


## $B752 -- the shot is done with: a puff is let out where it stood and the
## slot is given up.
static func puff(o: SolObjects, i: int) -> void:
	o.hatch(o.s_x[i], o.s_y[i], 0xBD)       # $B93E -> $AAC2 -> $AB10
	gone(o, i)                              # $B75A


## $B8E5 -- what the map holds where the shot itself is.
static func under(o: SolObjects, i: int) -> int:
	return o.probe_point(o.s_x[i], o.s_y[i])


## $B3E6 -- the thing let go from the top of the picture.  It sinks, and while
## its own count is still running it leans towards the hero; once the count is
## out it keeps whichever way it was last given.  On the stage that scrolls
## down it does not lean at all.
static func _drift_down(o: SolObjects, i: int) -> void:
	if ((i ^ o.clock) & 0x01) != 0:
		if (under(o, i) & 0x80) != 0:
			puff(o, i)                      # $B3F1
			return
	var dx := 0x0008                        # $B3F7
	var dy := 0x0010
	if o.s_a[i] != 0:
		o.s_a[i] = (o.s_a[i] - 1) & 0xFF    # $B404
		dx = 0x0004
		dy = 0x0004
	if o.s_a[i] != 0:
		# $B412 -- which side of the hero it is on is kept in its second byte.
		o.carry = 1
		o._sbc(o.s_x[i] & 0xFF, o.hero_x & 0xFF)
		o.s_b[i] = o._sbc((o.s_x[i] >> 8) & 0xFF, (o.hero_x >> 8) & 0xFF)
	if (o.s_b[i] & 0x80) == 0:
		dx = (-dx) & 0xFFFF                 # $B424
	if o.level.stage == 2:
		dx = 0                              # $B433
	move(o, i, dx, dy)                      # $BC7A
	on_screen_up(o, i)                      # $BCDF


## $BC54 -- the step packed into one byte: the top nibble is the step along and
## the bottom one, shifted up, the step down, both of them signed.
static func _nibble_step(o: SolObjects, i: int) -> void:
	var v: int = o.s_a[i]
	var dx: int = v & 0xF0
	if dx >= 0x80:
		dx |= 0xFF00
	var dy: int = (v << 4) & 0xF0
	if dy >= 0x80:
		dy |= 0xFF00
	move(o, i, dx, dy)                      # $BC71
	on_screen(o, i)                         # $BCF7


## $BC2C -- and nothing else: it goes the way its byte says until it is off.
static func _nibble(o: SolObjects, i: int) -> void:
	_nibble_step(o, i)


## $B918 -- the plainest of the lot: both of its bytes are the step.
static func _plain(o: SolObjects, i: int) -> void:
	drift(o, i)                             # $BC77
	on_screen(o, i)                         # $BCF7


## $B8F5 / $BB7B -- it counts down and is gone when the count runs out; the two
## are the same but for what they paint.
static func _countdown(o: SolObjects, i: int) -> void:
	on_screen(o, i)                         # $BCF7
	o.s_b[i] = (o.s_b[i] - 1) & 0xFF
	if o.s_b[i] == 0:
		gone(o, i)                          # $B8FD


static func _wearout(o: SolObjects, i: int) -> void:
	o.s_b[i] = (o.s_b[i] - 1) & 0xFF        # $BB7B
	if o.s_b[i] == 0:
		gone(o, i)
		return
	on_screen(o, i)


## $BC17 -- it waits its count out where it is and then becomes the one that
## travels ($82).  The count is put back, so it starts again at one.
static func _wear(o: SolObjects, i: int) -> void:
	o.s_b[i] = (o.s_b[i] - 1) & 0xFF
	if o.s_b[i] == 0:
		o.s_b[i] = 1                        # $BC1C
		o.s_kind[i] = 0x82
	on_screen(o, i)


## $BBE6 -- one of the four pieces it breaks into: the same place, its own
## packed step, and one picture of life.
static func _shard(o: SolObjects, i: int, step: int) -> void:
	var j: int = free_slot(o)               # $ADBA
	if j < 0:
		return
	o.s_a[j] = step                         # $BBEF
	o.s_x[j] = o.s_x[i]                     # $BBFE
	o.s_y[j] = o.s_y[i]
	put(o, j, 0x85)                         # $907B
	o.s_b[j] = 0x01                         # $BBFA


## $BB9E -- it travels by its packed step until the map it reaches is solid,
## and then it breaks into four that fly off the four ways.
static func _shatter(o: SolObjects, i: int) -> void:
	if (under(o, i) & 0x80) != 0:
		for step in [0xEE, 0xF9, 0x07, 0x12]:
			_shard(o, i, step)              # $BBA9..$BBB8
		o.s_kind[i] = o.s_kind[i] & 0x7F    # $BBBB
		return
	_nibble_step(o, i)                      # $BBC4


## $BA22 -- one of the ring: while the thing that let it go is still winding up
## it hangs where it is, and the moment that turn is over they all fly off.
static func _held(o: SolObjects, i: int) -> void:
	if o.kind[0] == 0x04 and o.frame[0] < 0x03:
		on_screen(o, i)                     # $BA30
		return
	drift(o, i)                             # $BA4F
	on_screen(o, i)


## $8ECB -- the step the side a thing faces gives its shot: the byte itself
## into $07D0 and a whole page either way into $90:$91.  What the side left in
## the carry is handed back, because $A1D7 then adds the place with it.
static func face_step(o: SolObjects, s: int, i: int) -> int:
	var c: int = (o.face[s] >> 7) & 1       # $8ED3
	o.s_a[i] = 0x30 if c == 1 else 0xD0
	o.z90 = 0x0100 if c == 1 else 0xFF00
	o.z92 = 0
	return c


# $9619 / $9622 -- what each of the nine is and what its second byte holds.
const SHOWER_KIND := [0x8D, 0x8E, 0x8F, 0x92, 0x93, 0x94, 0x97, 0x98, 0x99]
const SHOWER_B := [0x00, 0x03, 0x05, 0x00, 0x03, 0x05, 0x00, 0x03, 0x05]


## $95E7 -- the shower: nine at once, written straight into the first nine
## slots whether anything was in them or not.  The carry runs on from one to
## the next, because nothing between two turns of the loop puts it back.
static func shower(o: SolObjects, s: int) -> void:
	o.z90 = 0                               # $8121
	o.z92 = 0
	var c: int = (o.face[s] >> 7) & 1       # $95F1
	var a: int = 0x40 if c == 1 else 0xC0
	var dx: int = 0x0100 if c == 1 else 0xFF00
	for j in range(8, -1, -1):
		o.s_kind[j] = SHOWER_KIND[j]        # $95FF
		o.s_life[j] = SHOWER_KIND[j]
		o.s_b[j] = SHOWER_B[j]              # $9608
		c = place(o, s, j, dx, 0xFF00, c)   # $A1D7
		o.s_a[j] = a                        # $9612
