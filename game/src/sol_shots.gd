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
	if o.born_wait != 0 and o.born_wait < 0x30:
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
		0x00, 0x01:
			_wear(o, i)                     # $BC17
		0x02:
			_nibble(o, i)                   # $BC2C
		0x03:
			_bubble(o, i)                   # $B8A1
		0x04:
			_shatter(o, i)                  # $BB9E
		0x05:
			_arc(o, i)                      # $BB5B
		0x06:
			_crawl(o, i)                    # $BA5C
		0x07:
			_held(o, i)                     # $BA22
		0x08, 0x09:
			_turn_world(o, i)               # $B953
		0x0A:
			_countdown(o, i)                # $B8F5
		0x0B:
			_plain(o, i)                    # $B918
		0x0C, 0x26:
			_gain(o, i)                     # $B896, $BC47
		0x0D, 0x10, 0x11:
			_ring(o, i)                     # $B7F2, $B86F, $B87A
		0x0E:
			_becomes(o, i, 0x90)            # $B859
		0x0F:
			_becomes(o, i, 0x91)            # $B864
		0x12, 0x15, 0x16:
			_ring_up(o, i)                  # $B788, $B7A9, $B7B4
		0x13:
			_becomes(o, i, 0x95)            # $B793
		0x14:
			_becomes(o, i, 0x96)            # $B79E
		0x17, 0x1A, 0x1B:
			_ring_down(o, i)                # $B7BD, $B7DE, $B7E9
		0x18:
			_becomes(o, i, 0x9A)            # $B7C8
		0x19:
			_becomes(o, i, 0x9B)            # $B7D3
		0x1C:
			_fall(o, i)                     # $B638
		0x1D:
			_sink(o, i)                     # $B760
		0x1E:
			_bore(o, i)                     # $B5C3
		0x1F:
			_drop(o, i)                     # $B618
		0x20:
			_gain_until(o, i)               # $B740
		0x21, 0x22:
			_slide(o, i)                    # $B721, $B70F
		0x23:
			_bounce(o, i)                   # $B65B
		0x24:
			_wait_then_down(o, i)           # $B6CB
		0x25:
			_wait_then_along(o, i)          # $B6F0
		0x27:
			_carried(o, i)                  # $B564
		0x28:
			_thrown(o, i)                   # $B506
		0x29, 0x2D:
			_along_only(o, i)               # $B4CC, $B4A2
		0x2A, 0x2B:
			_plain(o, i)                    # $B4BC, $B4AF
		0x2C:
			_turning(o, i)                  # $BD0E
		0x2E:
			_dragged(o, i)                  # $B451
		0x2F:
			_drift_down(o, i)               # $B3E6
		_:
			o.missed_shot(m, false)


## $B386 -- and one that is burning out.  Half the table is $BD4F, which simply
## lets the slot go; the rest point at the same behaviour the flying one had.
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
		0x09:
			_turn_world(o, i)               # $B953
		0x0A:
			_countdown(o, i)                # $B8F5
		0x0D, 0x10, 0x11:
			_ring(o, i)                     # $B7F2, $B86F, $B87A
		0x0E:
			_becomes(o, i, 0x90)            # $B859
		0x0F:
			_becomes(o, i, 0x91)            # $B864
		0x12, 0x15, 0x16:
			_ring_up(o, i)                  # $B788, $B7A9, $B7B4
		0x13:
			_becomes(o, i, 0x95)            # $B793
		0x14:
			_becomes(o, i, 0x96)            # $B79E
		0x17, 0x1A, 0x1B:
			_ring_down(o, i)                # $B7BD, $B7DE, $B7E9
		0x18:
			_becomes(o, i, 0x9A)            # $B7C8
		0x19:
			_becomes(o, i, 0x9B)            # $B7D3
		0x1D, 0x20, 0x23, 0x2F:
			puff(o, i)                      # $B752
		0x1E:
			_bore(o, i)                     # $B5C3
		0x1F:
			_drop(o, i)                     # $B618
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


## $BCA1 -- the map at the shot's place with whatever offset $90:$92 already
## hold, and the two are left holding the place itself afterwards.
static func under_at(o: SolObjects, i: int, dx: int, dy: int) -> int:
	o.z90 = (o.s_x[i] + dx) & 0xFFFF
	o.z92 = (o.s_y[i] + dy) & 0xFFFF
	return o.probe_point(o.z90, o.z92)


## $B8E5 -- what the map holds where the shot itself is, with no offset at all.
static func under(o: SolObjects, i: int) -> int:
	return under_at(o, i, 0x0000, 0x0000)


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


# ---- the rest of the two tables ------------------------------------------

## $BD69 -- the width again, but the window is half a screen to the left of the
## view and two screens to the right of it rather than sixteen either way.
static func on_screen_wide(o: SolObjects, i: int) -> bool:
	var d: int = (o.s_x[i] - o.cam_x) & 0xFFFF
	if (((d >> 8) + 0x08) & 0xFF) >= 0x20:
		gone(o, i)
		return false
	return true


## $B5A6 -- four more downwards every picture, stopped at $7F just before it
## would turn over, and then the plain move with the top of the view left open.
## What it answers is whether the slot is still there.
static func _gain_step(o: SolObjects, i: int) -> bool:
	var b: int = o.s_b[i]
	if (b & 0x80) != 0:
		b = (b + 0x04) & 0xFF               # $B5B4
	else:
		var t: int = (b + 0x04) & 0xFF
		b = t if (t & 0x80) == 0 else 0x7F  # $B5B0
	o.s_b[i] = b                            # $B5B6
	drift(o, i)                             # $BC77
	on_screen_up(o, i)                      # $BCDF
	return o.s_kind[i] != 0


## $B896 and $BC47 -- and nothing else but that.
static func _gain(o: SolObjects, i: int) -> void:
	_gain_step(o, i)


## $B832 -- two further round the ring every picture, and the step that ring at
## its slowest gives.  $C078 is the same $8FF6 the objects read.
static func _ring_step(o: SolObjects, i: int) -> void:
	o.s_b[i] = (o.s_b[i] + 0x02) & 0xFF     # $B837
	o.spin(o.s_b[i], 0x00)                  # $C078


## $B822 -- and the move it ends in: along out of its own byte, which treads on
## the ring's own step along, and down out of the ring.  The width is judged by
## $BD69's window rather than $BCFA's.
static func _ring_move(o: SolObjects, i: int) -> void:
	o.z90 = along(o, i)                     # $BCC3
	move(o, i, o.z90, o.z92)                # $BC7A
	on_screen_y(o, i)                       # $BD55
	on_screen_wide(o, i)                    # $BD69


## $B81F -- the ring as it comes.
static func _ring(o: SolObjects, i: int) -> void:
	_ring_step(o, i)
	_ring_move(o, i)


## $B7FD -- the ring, lifted a tile and a half.
static func _ring_up(o: SolObjects, i: int) -> void:
	_ring_step(o, i)
	o.z92 = (o.z92 - 0x18) & 0xFFFF         # $B800
	_ring_move(o, i)


## $B80E -- and the ring dropped by the same.
static func _ring_down(o: SolObjects, i: int) -> void:
	_ring_step(o, i)
	o.z92 = (o.z92 + 0x18) & 0xFFFF         # $B811
	_ring_move(o, i)


## $B793 and its five fellows -- the slot sits still until its count is out and
## then takes up the behaviour that does the moving.  The number written always
## has bit seven in it, so a slot that was burning out starts flying again.
static func _becomes(o: SolObjects, i: int, m: int) -> void:
	o.s_b[i] = (o.s_b[i] - 1) & 0xFF
	if o.s_b[i] == 0:
		o.s_kind[i] = m


## $B760 -- it sinks a sixteenth of a tile a picture, and the moment the map
## under it is solid it goes in a puff of its own.
static func _sink(o: SolObjects, i: int) -> void:
	if (under(o, i) & 0x80) != 0:
		puff(o, i)                          # $B752
		return
	o.z90 = 0                               # $8121
	o.z92 = 0x0010                          # $B768
	move_y(o, i, o.z92)                     # $BC7D
	on_screen(o, i)                         # $BCF7


## $B740 -- it gains downwards until the map under it is solid, and then it is
## done with in the same puff.
static func _gain_until(o: SolObjects, i: int) -> void:
	if (under(o, i) & 0x80) != 0:
		puff(o, i)                          # $B752
		return
	_gain_step(o, i)                        # $B745


## $B618 -- a whole tile down every picture and nothing else at all.
static func _drop(o: SolObjects, i: int) -> void:
	on_screen(o, i)                         # $BCF7
	o.z92 = 0x0100                          # $B62D
	move_y(o, i, o.z92)                     # $BC7D


## $B5C3 -- the borer.  It sinks slowly and breaks whatever it passes through,
## and it does the breaking by hand through slot thirteen, whose own place and
## count it treads on to do it.  Where the map it has reached is solid it is
## gone and a $24 is left standing there.
static func _bore(o: SolObjects, i: int) -> void:
	on_screen(o, i)                         # $BCF7
	if (under(o, i) & 0x80) != 0:
		o.s_kind[i] = 0                     # $B60D
		o.hatch(o.s_x[i], o.s_y[i], 0x24)   # $B93E -> $AAC2
		return
	o.z92 = 0x0060                          # $B5E2
	move_y(o, i, o.z92)                     # $BC7D
	# $B5ED -- only the high bytes of the place are handed over, because that
	# is all $BF0B ever looks at, and the low bytes of slot thirteen are left
	# holding whatever they held.
	o.x[SolObjects.BLAST] = (o.x[SolObjects.BLAST] & 0x00FF) \
			| (o.s_x[i] & 0xFF00)
	o.y[SolObjects.BLAST] = (o.y[SolObjects.BLAST] & 0x00FF) \
			| (o.s_y[i] & 0xFF00)
	o.a[SolObjects.BLAST] = 0               # $061D
	# $B606 -- one list of one cell: its own.
	SolMinds._a93c(o, SolObjects.BLAST, [[0x00, 0x00, 0x80]])


## $B6B1 -- it comes off the wall with half the speed it had, the other way
## about, and the answer is whether what is left is still worth anything.
static func _bounce_off(o: SolObjects, i: int) -> bool:
	var b: int = o.s_b[i]
	b = (b >> 1) | (b & 0x80)               # $B6B4 -- ASL then ROR keeps the sign
	b = (0x100 - b) & 0xFF                  # $B6B8 -- nothing less it
	o.s_b[i] = b
	var n: int = b if (b & 0x80) == 0 else ((0x100 - b) & 0xFF)
	return n >= 0x04                        # $B6C8


## $B65B -- the bouncing one.  It looks a little ahead downwards and a little
## ahead along; where the way down is shut it either comes off the wall or,
## once it has too little left to bounce with, gives up in a puff, and where
## the way along is shut it simply stops going that way.
static func _bounce(o: SolObjects, i: int) -> void:
	on_screen(o, i)                         # $BCF7
	var dy: int = 0xFFA0 if (o.s_b[i] & 0x80) != 0 else 0x0060
	if (under_at(o, i, 0x0000, dy) & 0x80) != 0:
		if not _bounce_off(o, i):           # $B6B1
			puff(o, i)                      # $B752
			return
		_gain_step(o, i)                    # $B68C
		return
	var dx: int = 0xFFC0 if (o.s_a[i] & 0x80) != 0 else 0x0040
	if (under_at(o, i, dx, 0x0000) & 0x80) != 0:
		o.s_a[i] = 0                        # $B6A9
	_gain_step(o, i)                        # $B6AE


## $B6CB -- it waits its count out where it is and then sinks by the byte that
## everywhere else is the step along.
static func _wait_then_down(o: SolObjects, i: int) -> void:
	on_screen(o, i)                         # $BCF7
	if o.s_b[i] != 0:
		o.s_b[i] = (o.s_b[i] - 1) & 0xFF    # $B707
		return
	o.z90 = along(o, i)                     # $BCC3
	o.z92 = o.z90                           # $B6DF
	o.z90 = 0                               # $B6E7
	move_y(o, i, o.z92)                     # $BC7D


## $B6F0 -- the same wait, and then it travels along instead.
static func _wait_then_along(o: SolObjects, i: int) -> void:
	on_screen(o, i)                         # $BCF7
	if o.s_b[i] != 0:
		o.s_b[i] = (o.s_b[i] - 1) & 0xFF    # $B707
		return
	o.z90 = along(o, i)                     # $BCC3
	move_x(o, i, o.z90)                     # $BC8F


## $B70F and $B721 -- along by its own byte, and the view asked first.
static func _slide(o: SolObjects, i: int) -> void:
	on_screen(o, i)                         # $BCF7
	o.z90 = along(o, i)                     # $BCC3
	move_x(o, i, o.z90)                     # $BC8F


## $B4A2 and $B4CC -- the same, but the move comes first.
static func _along_only(o: SolObjects, i: int) -> void:
	o.z90 = along(o, i)                     # $BCC3
	move_x(o, i, o.z90)                     # $BC8F
	on_screen(o, i)                         # $BCF7


## $B451 -- it goes the way its own byte says, and on a map that drags things
## down ($34) it leans upwards half a tile a picture as well.
static func _dragged(o: SolObjects, i: int) -> void:
	o.z90 = 0                               # $8121
	o.z92 = 0
	o.z90 = along(o, i)                     # $BCC3
	if o.z34 != 0:
		o.z92 = 0xFFF8                      # $B45B
	move(o, i, o.z90, o.z92)                # $BC7A
	on_screen(o, i)                         # $BCF7


## $B564 -- the carried one: its own first byte names a slot of the other pool,
## and it takes that slot's first two numbers as its step.  While its count is
## still running it does not sink at all.
static func _carried(o: SolObjects, i: int) -> void:
	on_screen(o, i)                         # $BCF7
	if o.s_kind[i] == 0:
		return                              # $B56C
	if o.s_b[i] != 0:
		o.s_b[i] = (o.s_b[i] - 1) & 0xFF    # $B574
		o.z90 = 0                           # $8121
		o.z92 = 0
	else:
		o.z92 = 0x0080                      # $B585
	# $B58D -- the whole byte is the index in the cartridge, and a slot number
	# is all anything ever puts there, so it is held to the sixteen.
	var s: int = o.s_a[i] & 0x0F
	o.z90 = o.a[s] | (o.b[s] << 8)          # $0610, $0620
	move(o, i, o.z90, o.z92)                # $BC7A


## $B506 -- the one that is thrown out sideways and then falls.  While its own
## count runs it travels by the down byte laid on its side; when the count is
## out the byte starts going two down a picture instead, with a floor at $80.
static func _thrown(o: SolObjects, i: int) -> void:
	if o.s_a[i] != 0:                       # $B506
		o.s_a[i] = (o.s_a[i] - 1) & 0xFF    # $B50B
		if o.s_a[i] != 0:
			o.z92 = down(o, i)              # $BCD1
			o.z90 = o.z92                   # $B51D
			move_x(o, i, o.z90)             # $BC8F
			on_screen(o, i)                 # $BCF7
			return
		o.s_b[i] = 0x08                     # $B510
	var b: int = o.s_b[i]                   # $B52E
	o.carry = 1
	if (b & 0x80) != 0:
		var t: int = o._sbc(b, 0x02)        # $B534
		if t >= 0x80:
			b = t                           # $B53E
		else:
			# $B53A -- the compare left the borrow down, so what is put back
			# is $83 less two less one.
			b = o._sbc(0x83, 0x02)
	else:
		b = o._sbc(b, 0x02)                 # $B53C
	o.s_b[i] = b
	o.z92 = down(o, i)                      # $BCD1
	move_y(o, i, o.z92)                     # $BC7D
	on_screen(o, i)                         # $BCF7


## $BD0E -- the sinking one that turns as it goes.  Every fourth picture it
## asks what is a whole tile below and gives up where that is solid, and the
## same picture turns it one step further round, skipping the fourth of four.
static func _turning(o: SolObjects, i: int) -> void:
	var tick: bool = ((i ^ o.clock) & 0x03) == 0
	if tick:
		o.z90 = 0                           # $8121
		o.z92 = 0x0100                      # $BD18
		if (under_at(o, i, 0x0000, 0x0100) & 0x80) != 0:
			gone(o, i)                      # $BD4F
			return
	o.z92 = 0x0040                          # $BD1F
	move_y(o, i, o.z92)                     # $BC7D
	on_screen(o, i)                         # $BCF7
	if o.s_kind[i] == 0:
		return                              # $BD32
	if tick:
		o.s_a[i] = (o.s_a[i] + 1) & 0xFF    # $BD3A
	while (o.s_a[i] & 0x03) == 0x03:        # $BD3D
		o.s_a[i] = (o.s_a[i] + 1) & 0xFF


## $BB4F -- the four ways it can crawl, read at four offsets into one run of
## twelve bytes: the step along out of the first and seventh, the step down out
## of the third and ninth.
const CRAWL := [0x00, 0x00, 0xC0, 0x40, 0x00, 0x00,
		0x00, 0x00, 0xFF, 0x00, 0x00, 0x00]


## $BAFB / $BB10 / $BB25 / $BB3A -- one way tried.  A whole tile that way is
## asked of the map, and where it is open the way is taken and the thing is put
## back in the middle of its own tile across the way it is now going.
static func _try_way(o: SolObjects, i: int, w: int) -> bool:
	var dx := 0x0000
	var dy := 0x0000
	match w:
		0: dy = 0xFF00                      # $BAFE
		1: dy = 0x0100                      # $BB13
		2: dx = 0xFF00                      # $BB28
		3: dx = 0x0100                      # $BB3D
	if (under_at(o, i, dx, dy) & 0x80) != 0:
		return false
	if w < 0x02:
		o.s_x[i] = (o.s_x[i] & 0xFF00) | 0x80
	else:
		o.s_y[i] = (o.s_y[i] & 0xFF00) | 0x80
	o.s_a[i] = w
	return true


## $BA71 -- and the order the four are tried in, which is a different order for
## each way it is already going.  The one for "going left" asks the way down
## twice over and never asks the way right at all; that is the cartridge's own
## doing and it is kept.
const CRAWL_ORDER := [[0, 3, 2, 1], [1, 2, 3, 0], [2, 0, 1, 1], [3, 1, 0, 2]]


## $BA5C -- the one that crawls along the wall.  It counts down, and every
## picture it looks for the first open way in its own order and goes that way.
static func _crawl(o: SolObjects, i: int) -> void:
	# $BA5C -- the noise ($F1 = $27) is not modelled.
	o.s_b[i] = (o.s_b[i] - 1) & 0xFF        # $BA66
	if o.s_b[i] == 0:
		gone(o, i)                          # $BD4F
		return
	o.z90 = 0                               # $BAF8 -> $8121
	o.z92 = 0
	# $BA71 -- the last of the four is asked for as "anything above two", so a
	# byte that somehow holds more than three is read as the last of them.
	var w0: int = min(o.s_a[i], 0x03)
	for w in CRAWL_ORDER[w0]:
		if _try_way(o, i, w):
			break
	var y: int = min(o.s_a[i], 0x03)        # $BACD
	move(o, i, CRAWL[y] | (CRAWL[y + 6] << 8),
			CRAWL[y + 2] | (CRAWL[y + 8] << 8))
	on_screen(o, i)                         # $BCF7


## $B9EA -- the three numbers of the tile set each way up asks for.
const TURN_TILES := [[0x0A, 0x09, 0x27], [0x02, 0x12, 0x27], [0x05, 0x16, 0x27]]


## $BA0A -- turning him over turns the fall he had built up with it, and the
## borrow $B966's own compare left is still in hand for the sum.
static func _turn_rise(o: SolObjects, f: int) -> void:
	if ((f ^ o.hero_flags) & 0x80) == 0:
		return                              # $BA20
	o.carry = 1 if o.z399 >= 0x05 else 0
	var v: int = o.hero_rise & 0xFFFF
	var lo: int = o._sbc(0x00, v & 0xFF)    # $BA12
	var hi: int = o._sbc(0x00, (v >> 8) & 0xFF)
	o.hero_rise = (lo | (hi << 8)) & 0xFFFF


## $B953 -- the one that turns the world over.  While the map lets it through
## it simply sinks by its own byte; where it stops, and only while the screen
## is owed nothing or owed the last of a room, up becomes down: the hero's flag
## turns, the fall he had is turned round with it, and the three numbers a jump
## is made of are rewritten.  A $87 is left where it stopped either way.
static func _turn_world(o: SolObjects, i: int) -> void:
	o.z90 = 0                               # $8121
	o.z92 = 0
	if (under_at(o, i, 0x0000, 0x0000) & 0x80) == 0:
		o.z92 = down(o, i)                  # $BCD1
		move_y(o, i, o.z92)                 # $BC7D
		on_screen(o, i)                     # $BCF7
		return
	if o.z26 == 0x00 or o.z26 == 0x06:      # $B95B
		var row := -1
		if o.z399 != 0x05 and (o.noise & 0x03) == 0:
			# $B970 -- now and then it puts the world back the way it started,
			# whatever the hero's own flag says.
			row = 2
		elif ((o.s_b[i] ^ o.hero_flags) & 0x80) != 0:
			# $B97C -- the shot's own sign says which way up it wants him.
			var f: int = (o.s_b[i] & 0x80) ^ o.hero_flags
			_turn_rise(o, f)                # $BA0A
			o.hero_flags = f                # $B984
			# $B987 -- four rolls and a mask, which is bit seven and nothing
			# else, so it is the flag itself that picks the row.
			row = 1 if (f & 0x80) != 0 else 0
		if row >= 0:
			o.z399 = TURN_TILES[row][0]     # $B98E
			o.z39a = TURN_TILES[row][1]
			o.z39b = TURN_TILES[row][2]
			# $B9A6 -- the noise ($F1 = $14) is not modelled.
			o.hero_jump = 0x00              # $B9F5
			o.hero_grav = 0x04
			o.hero_hold_max = 0x06
	o.hatch(o.s_x[i], o.s_y[i], 0x87)       # $B9AD -> $AAC2
	gone(o, i)                              # $BD4F
