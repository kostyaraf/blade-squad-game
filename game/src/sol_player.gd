extends RefCounted
class_name SolPlayer

## Solbrain's hero, moved the way the cartridge moves him.
##
## Everything is whole numbers in sixteenths of a pixel, the units the console
## itself used, so the same jump comes out to the same sixteenth.  The order of
## the steps is the order of $9477 in bank 12; `work/re/sol_player.md` says
## which line came from where.
##
## He is not a slot of a table the way Power Blade's hero is.  He is his own
## block of memory ($05A2 onward) and his own code, and nothing else in the
## game shares either.

const A := 0x80
const B := 0x40
const SELECT := 0x20
const START := 0x10
const UP := 0x08
const DOWN := 0x04
const LEFT := 0x02
const RIGHT := 0x01

## $05A2.  Twenty one of them; these four are the ones that carry a hero who is
## only walking, jumping and ducking, and they are the four the engine knows.
const ST_GROUND := 0x00
const ST_AIR := 0x01
const ST_LAND := 0x02
const ST_CROUCH := 0x03
const STATES := 21

## $9C4B -- which states may be steered at all, one mask per state, and only
## bits 0 and 1 of it are ever looked at.
const STEER := [0xCF, 0xCF, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCF, 0xCF, 0xCF,
		0xCF, 0xCF, 0xCF, 0xCF, 0xCF, 0xCF, 0xCC, 0xC0, 0xC0, 0xC0, 0xC0]

## $9C03 -- how much speed letting go takes off.  One flat table of seventy two
## bytes read at $05CD + $05A2: the kind of ground picks the block of twenty
## four, the state picks the byte inside it.
const DRAG := [
		0x04, 0x01, 0x04, 0x04, 0x04, 0x04, 0x20, 0x20,
		0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
		0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
		0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0x20, 0x20,
		0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
		0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
		0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x20, 0x20,
		0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
		0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
]

## $05CD, the kind of ground under him: plain, the heavy going of water, and
## ice.  It is an offset into the table above, which is why the numbers look
## like that.
const GROUND_PLAIN := 0x00
const GROUND_WATER := 0x18
const GROUND_ICE := 0x30

const TOP_SPEED := 0x16         # $9C69, $9C74
const FALL_MAX := 0x60          # $A113
const JUMP_FULL := 0xE0         # $9ECD, what landing hands back
const JUMP_FLOOR := 0xB8        # $A2C1, under this it stops weakening
const HOLD_MAX := 6             # $05EA
const GRAVITY := 4              # $05E9
const GROUND_PULL := 0x20       # $9EE9
const BELT_PUSH := 8            # $9648, $965B

## $05C9, the two marks the jump leaves.
const JUMP_USED := 0x80
const HURT_IN_AIR := 0x40

## $05CB, the marks the ground he is standing in leaves.
const UPSIDE_DOWN := 0x80
const OUT_OF_WATER := 0x20

## The probes, as offsets from where he says he is.  The right hand one really
## is fourteen pixels below him and not two above: $A41F adds $E0 with $A425
## adding nothing on top, so the sign never reaches the high byte.  The
## cartridge is like that and so is this.
const FOOT_DY := 16 * 16
const WALL_DX := 8 * 16
const WALL_LOW_DY := 14 * 16
const WALL_HIGH_DY := -6 * 16
## ...and the right hand one's upper point is a sixteenth further up still,
## because $A430 subtracts with the borrow $C00F left behind.
const WALL_HIGH_RIGHT_DY := -6 * 16 - 1

var lvl: SolLevel
## $38:$39 and $3A:$3B -- how far along the area he may go.  The level carries
## them as the view's own limits, which is where the cartridge gets them too.
var x_min := 0
var x_end := 0
var stage := 0

var x := 0                      # $80:$81, sixteenths of a pixel
var y := 0                      # $82:$83, and sixteen pixels above his feet
var vx := 0                     # $05B6:$05B7, this frame's move
var vy := 0                     # $05B8:$05B9
var rise := 0                   # $05AD:$05AE, the vertical speed before it lands
var speed := 0                  # $35, one signed byte
const ST_BURST := 0x0D          ## $97D4 -- the doubled weapon burning off
var state := ST_GROUND          # $05A2
var timer := 0                  # $05A3
## $05B2 -- which way he is looking, and the whole byte of it.  The two places
## that write it ($9B6D and $AD5C) put a rolled copy of the direction being
## held in, so bit 7 means looking left, bit 6 means right is held, and bit 5
## is whatever the carry happened to be.  Three readers want the whole byte:
## $AE1E and $B884 copy it into a slot's own face, and $AD48 takes bit 6 out
## of it to say which way the satellite turns.
var face := 0
var face_left: bool:
	get:
		return (face & 0x80) != 0
	set(v):
		face = (face & 0x7F) | (0x80 if v else 0x00)
var hold := 0                   # $05AC
var jump := JUMP_FULL           # $05E8
var gravity := GRAVITY          # $05E9
var hold_max := HOLD_MAX        # $05EA
var ground := GROUND_PLAIN      # $05CD
var flags := 0                  # $05CB
var jump_flags := 0             # $05C9
var hurt := 0                   # $05C2
var scripted := 0               # $05A5
## $05AB -- the burst of the doubled weapon.  $92CD sets it to $7F when a
## combination gives the weapon he already holds, and state $0D counts it down
## by four a picture; the satellite's own $A5D9 and $A5F6 read it as a ring.
var burst := 0                  # $05AB
var push_x := 0                 # $05A8:$05A9
var anim := 0                   # $05CE
var suit := 8                   # $05C5
var seen := 0                   # $05CA, the ground he stood in last frame
var swim := 0                   # $05CC
var shield := 0                 # $05C8
var fuel := 0                   # $05AF
var step_down := 6              # $5B, what a second push of one jump costs
var clock := 0                  # $0C, the frame counter the whole game shares
## $70, the kind of map this stage is drawn from.  It reaches him through the
## side probes: $D012 compares it against $3C and the add that follows uses the
## carry that comparison left, so on a map numbered above $3C every one of
## those probes lands a sixteenth further along.
var map_kind := 0
## $9D -- what the last probe left behind.  Off the stage that carries it is
## the low byte of the point that was looked at; on it, where the lift's own
## line answered, it is nought.  $A209 and $A221 read it back.
var z9d := 0
## The animation.  $05B5 is the one the state itself asks for and $05A5 the
## named one a shot or an arrival sets going; $05A4 counts the current step
## down and $05B4 says which step it is; $05A6:$05A7 is the picture those two
## arrive at, and the picture is the whole of what the drawing wants.
var pose := 0                   # $05B5
var step_t := 0                 # $05A4
var step_i := 0                 # $05B4
var pic_lo := 0                 # $05A6
var pic_hi := 0                 # $05A7
## $937A -- the picture he is drawn out of this frame and the marks that go
## with it ($9E).  -1 is "not drawn at all".
var draw_id := -1
var draw_mark := 0
## $B81E -- which reach of $B8F7 the animation has just asked to be struck
## with, or -1 for none.  $B862 empties it again on the same picture.
var punch := -1
## Where he stood when it asked.  $B834 jumps straight into $B862, which reads
## $80..$83 there and then -- and $B7CE is reached from inside $9477, ahead of
## the move at $94DB.  So the reach is laid out around the place the picture
## started in, not around the place the step leaves him in.  While he stands
## still the two are the same; while he is falling they are a step apart.
var punch_x := 0
var punch_y := 0
## Where this picture found him, kept for the line above.
var was_x := 0
var was_y := 0
## $06 as it stood at the end of last frame -- masked, not raw.  $C88B works
## out what was newly pressed by comparing the pad against this, so a mask that
## blanked $06 makes a button that was never let go read as pressed again the
## moment the mask lifts.  A jump held down through being hurt is a second jump
## on the frame he gets control back.
var pad_held := 0

## The sixteen slots of the object pool, or nothing at all.  Seventeen of his
## twenty one states read and write slot $0C, which is where his own machinery
## -- the satellite, and the wire it throws -- lives, so the pool has to be
## within his reach.  The stand that plays buttons at him alone hands him none,
## and the four states that stand for walking about never look at it.
var pool = null

const SAT := 0x0C               # $060C and the rest: his satellite's own slot


func _init(level: SolLevel) -> void:
	lvl = level
	if level == null:
		return                  # the drawing stand wants him without a level
	stage = level.stage
	x_min = int(level.camera["x_min"])
	x_end = int(level.camera["x_end"])


func place(px: int, py: int) -> void:
	x = px
	y = py
	vx = 0
	vy = 0
	rise = 0
	speed = 0
	state = ST_GROUND
	timer = 0
	hold = 0
	jump = JUMP_FULL


## $91AC -- the picture the hero is not run at all, because the wait for a new
## satellite is between one and $2F.  Two things still happen: the frame
## counter moves on, and $C882 works out what was newly pressed.  Neither is
## inside $9477, so neither is skipped with it.
func skip(pad: int) -> void:
	was_x = x
	was_y = y
	clock = (clock + 1) & 0xFF
	_aura()
	pad_held = pad


## $9159 -- what being hit costs him, which runs before $9477 and so before
## anything else of his picture.  The aura itself is drawing and is left out;
## what is kept is that it wipes how hard he has been working the fire button,
## and that every thirty second picture a step of the hurt wears off.
func _aura() -> void:
	if hurt == 0:
		return
	anim = 0                                    # $9170
	if (clock & 0x1F) != 0:
		return                                  # $917E
	if hurt == 1:
		# $91A8 -- $43, which is the noise, and nothing here has one.
		return
	if hurt == 2:
		_clear_script()                         # $918F
		state = 0x0F                            # $9194
	if state < 0x11:
		hurt = (hurt - 1) & 0xFF                # $91A2


## $9477 -- one frame of him, start to finish.  `pad` is the controller as it
## stands; what was newly pressed is worked out here, the way $C882 does it.
func step(pad: int) -> void:
	was_x = x
	was_y = y
	# The frame counter the whole game shares has already moved on by the time
	# the hero is asked to run: ice reads it, and reads it after the step.
	clock = (clock + 1) & 0xFF
	_aura()                                 # $9159, and it runs before $9477
	# The kind of ground he is on is worked out afresh every frame: the level's
	# own frame routine clears it ($AAA9 in bank 9) before the hero runs, and
	# water ($95B7) and ice ($9672) put it back while he is still in them.  So
	# ice stops being slippery on the frame he steps off it, not later.  A
	# stage with neither never writes the byte at all.
	ground = GROUND_PLAIN
	# $CD79 -- and the same is true of the marks he is drawn with: the frame
	# routine keeps only "upside down" and throws the rest away, so "not in
	# water" has to be earned again every picture.
	flags &= UPSIDE_DOWN
	var held := pad
	var pressed: int = pad & ~pad_held
	# $9477: the frame's move starts at nothing every time, and is decided
	# whole before anything is applied.
	vx = 0
	vy = 0
	# $948D
	if timer < 0xFF:
		timer += 1
	# $9495 -- four more, and $FC only when the add carried out of the byte.
	# $FE and $FF are reachable and the shot's own counting leans on it.
	anim += 4
	if anim > 0xFF:
		anim = 0xFC
	# $94A5 -- the pad, and how much of it reaches him.
	var masked := _mask(held, pressed)
	held = masked[0]
	pressed = masked[1]
	pad_held = held
	# $94D2, $94D5 and $94D8, in that order: the ground he stands in first,
	# then up and down, then left and right.
	#
	# The order is not a detail.  The state's own handler is what turns $35
	# into the frame's move ($9EDB `LDA $35 / JSR $A122`), and it runs before
	# $9AA5 gets to touch $35 at all -- so the move a frame makes is the speed
	# the frame before it left behind, and the speed decided now is spent on
	# the frame after.  Measured: holding right from a standstill leaves him
	# where he was for one frame while $35 is already 2.
	_terrain()
	_vertical(held, pressed)
	_horizontal(held)
	# $94DB -- and only now does he move.
	x = (x + vx) & 0xFFFF
	y = (y + vy) & 0xFFFF
	# $937A -- and only now is the picture chosen, because two of its branches
	# write back into him.
	_picture()


## $937A -- which picture he wears this frame, and the marks that go with it.
## `draw_id` of -1 means he is not drawn at all, which the flicker of a hero
## who has just arrived or just been hit is made of.
func _picture() -> void:
	draw_id = -1
	draw_mark = flags                       # $937A -- $9E starts as $05CB
	if suit == 0:
		_bare_picture()                     # $9384
		return
	if timer >= 0x70:                       # $93CE -- an old enough hero
		_worn()
		return
	if timer == 0x1F:
		# $93DB -- the frame the arrival is over.
		if hurt != 0:
			_worn()
			return
		if state != ST_AIR:
			state = ST_GROUND               # $8830
		step_t = 0                          # $93EA
		step_i = 0
		return
	if timer > 0x1F:
		# $93F3 -- every other frame of what is left of the arrival he is
		# simply left out, and that is the flicker.
		if (timer & 1) == 0 or hurt != 0:
			_worn()
		return
	# $93FC -- the first thirty one frames: arriving, or reeling from a hit.
	if hurt != 0:
		if (clock & 0x04) == 0:
			draw_mark |= 0x03               # $9407 -- and in the wrong colours
		_worn()
		return
	if face_left:
		draw_mark |= 0x40                   # $9414
	if state == ST_GROUND or state == ST_LAND:
		# $9423 -- every other frame of the arrival, and nothing between.
		if (clock & 0x01) != 0:
			draw_id = 0x64
		return
	if (jump_flags & HURT_IN_AIR) != 0:     # $942D
		draw_id = 0xC2 if timer < 0x08 else 0x72
		return
	draw_id = 0xBC if timer < 0x08 else 0xBA


## $9384 -- a hero with no suit on is not drawn out of his animation at all: he
## has three fixed pictures, and which of the three is all the drawing does.
## The last of the three is also where he is finished off for good, because
## nothing else notices a hero who has run out of everything.
func _bare_picture() -> void:
	SolSprites.load_data()
	var base: int = SolSprites.bare[0]
	if timer >= 0x06:                       # $9387
		if state == 0x01 and fuel == 0:     # $938D -- hit, and free to move
			base = SolSprites.bare[2]
		else:
			base = SolSprites.bare[1]
			if state == 0x00 and timer == 0xFF:
				# $93A9 -- state nought and a count that has stopped: the
				# picture he is finished off in.
				burst = 0xFF
				state = 0x0C
				if pool != null:
					pool.zf8 = 0x0C         # $93B1
					if pool.id[SAT] != 0:   # $93B3 -- and the satellite with
						pool.id[SAT] = 0xFF # him
						pool.b[SAT] = 0x20
	# $93C4 -- the picture next door is the same one mirrored.
	draw_id = base + (1 if face_left else 0)


## $9689 -- the shimmer of the shield: with one up, and in a state that does
## not put it out, the third colour of the sprites' first set walks through
## four values every other picture.
func _shine() -> void:
	if shield == 0:                         # $9689
		return
	SolSprites.load_data()
	if SolSprites.shine_off[state & 0x3F] != 0:
		return                              # $9694
	if pool == null or pool.z5fa != 0:      # $9699 -- not while the stage ends
		return
	pool.shine_to(SolSprites.shine[(clock >> 1) & 0x03])


## $944D -- the picture the animation arrived at, and the one next door when he
## faces the other way: it is the same picture mirrored, and its own flags
## carry the $40 that turns it about.
func _worn() -> void:
	var id: int = pic_lo | ((pic_hi & 0x1F) << 8)
	if id == 0:
		return
	draw_id = (id + 1) & 0xFFFF if face_left else id


## $94A5 -- how much of the pad he is allowed.  Being hurt gives it all back:
## the cartridge jumps clear of the masking when $05C2 is set, which is what
## lets a hurt hero be thrown about while the buttons are ignored elsewhere.
func _mask(held: int, pressed: int) -> Array:
	if hurt != 0:
		return [held, pressed]
	if suit == 0:
		return [0, 0]
	if (jump_flags & HURT_IN_AIR) != 0:
		return [held & (0x3F if timer > 0x20 else 0x33), 0]
	if timer < 0x20:
		return [0, 0]
	return [held, pressed]


## $94FA -- what he is standing in, and what that does to the way he moves.
## Water, ice and the pull of a current are all the same one answer: the
## property byte of the metatile his own middle is inside.
func _terrain() -> void:
	var v := _probe(x, y)
	# $A17A -- on the stage that carries, and only there, the look at his own
	# middle hurts him if what it found is of a class that hurts.  The wrapper
	# it goes through ($A172) hands the answer on unchanged either way.
	if map_kind == 0x3C and (v & 0xE0) != 0x60 and (v & 0xE0 & 0x40) != 0:
		_wound()                            # $A18F
	var was := seen
	seen = v
	# $9503 -- inside something solid, nothing to say.
	if v >= 0x80:
		return
	# $9505 -- and only four of the classes mean anything here.
	if (v & 0x78) < 0x60:
		return
	match v & 0x18:
		0x00:
			_dry(was, v)
		0x08:
			_wet()
		0x10:
			_current(was, v)
		_:
			flags |= OUT_OF_WATER


## $9541 -- the ordinary world: four of gravity, six frames of hold, and a jump
## that starts weak because this is what the surface of water hands back.
func _plain() -> void:
	step_down = 6
	_flip_rise(0)
	flags = 0
	ground = GROUND_PLAIN
	jump = 0xB8
	gravity = 4
	hold_max = 6
	flags = OUT_OF_WATER


## $9522 -- the frame he comes out of the water.  Rising, he is given a shove;
## falling, half of what he had is taken away.
func _dry(was: int, now: int) -> void:
	_plain()
	if was == now:
		return
	if rise >= 0:
		hold >>= 1
		rise >>= 1
	elif hold >= 0x10:
		# $9622 -- a jump held long enough breaks the surface properly.
		rise = -36
	else:
		hold = 0
	# $9633 -- and the splash, whichever way he was going.  It goes in at his
	# own place but on the row above him, and $8C6E counts the slots upward.
	# The noise ($F1 = $09) is not modelled.
	if pool != null:
		pool.hatch_up(x, y & 0xFF00, 0x36)


## $95AD -- under water: a tenth of the gravity and a hold that lasts five
## times as long, which together are what swimming is.  And once in every two
## hundred and fifty six pictures a bubble goes up.
func _wet() -> void:
	_flip_rise(0)                       # $9603
	flags = 0
	ground = GROUND_WATER
	jump = 0xE0
	gravity = 1
	hold_max = 0x20
	step_down = 6
	_bubble()


## $95CD -- the bubble itself.  It is let go on the one picture in two hundred
## and fifty six the count is nought, and not while he is being hurt or put
## away.  $8D9B hands back the topmost free slot rather than the first, and the
## height is a hundred and twenty nine sixteenths above him, not a hundred and
## twenty eight: the compare that let him through left the carry down and the
## take-away below it has no SEC of its own.
func _bubble() -> void:
	if pool == null or pool.clock != 0:
		return                          # $95CF
	if state >= 0x11:
		return                          # $95D6
	var i: int = SolShots.free_slot(pool)       # $8D9B
	if i < 0:
		return                          # $95DB
	pool.s_kind[i] = 0x03               # $95DD
	pool.s_life[i] = 0x03
	pool.s_b[i] = 0xE0                  # $95E5
	pool.s_x[i] = x                     # $95EA
	pool.s_y[i] = int(pool._sub2(y, 0x0080, 0)[0])      # $95F4


## $9565 -- a current: past a walking pace it pushes back half a pixel a frame.
func _current(was: int, now: int) -> void:
	swim = 0
	if was != now:
		pass                            # $9578, a splash and nothing more
	if state < 0x0C and speed != 0:
		var far: int = -speed if speed < 0 else speed
		if far >= 0x0C:
			_shove(0x10 if speed < 0 else 0x18)
	flags = OUT_OF_WATER


## $9603 -- gravity turning over turns the speed he had over with it.
func _flip_rise(mark: int) -> void:
	if ((mark ^ flags) & 0x80) != 0:
		rise = _s16(-rise)


## $963D -- what a belt, a patch of ice or a current does to the frame's move.
## The same routine serves all three; which one it is is in the two low bits of
## the property byte.
func _shove(v: int) -> void:
	match v & 0x18:
		0x10:
			vx = _s16(vx + BELT_PUSH)
			_wall()
		0x18:
			vx = _s16(vx - BELT_PUSH)
			_wall()
		0x08:
			# $9670 -- ice: nothing holds, and every eighth frame a little of
			# what he has is given back.
			ground = GROUND_ICE
			if (clock & 0x07) == 0 and speed != 0:
				speed += 1 if speed < 0 else -1


## $9689 -- up and down: the shimmer of the shield first, and then the state's
## own handler.  $96C0 holds twenty one pointers and $05A2 picks one; all
## twenty one are here, in the order of the table and not of the code.
func _vertical(held: int, pressed: int) -> void:
	_shine()                                # $9689
	match state:
		ST_GROUND:
			_ground(held, pressed)          # $9ED3
		ST_AIR:
			_air(held, pressed)             # $A005
		ST_LAND:
			_landing(held, pressed)         # $9EA1
		ST_CROUCH:
			_crouch(held, pressed)          # $9C7D
		0x04:
			_wire_hold(held)                # $98CF
		0x05:
			_wire_out(held, pressed)        # $9938
		0x06:
			_wire_climb(held, pressed)      # $99A8
		0x07:
			_wire_ride(held, pressed)       # $99FB
		0x08:
			_door(pressed)                  # $98A8
		0x09:
			_arrive()                       # $9896
		0x0A:
			_door_out(held)                 # $986A
		0x0B:
			_door_up()                      # $9886
		0x0C:
			_dying()                        # $978A
		ST_BURST:
			_bursting()                     # $97D4
		0x0E:
			_dead()                         # $97A7
		0x0F:
			_hurt_out()                     # $9816
		0x10:
			_riding()                       # $982E
		0x11:
			_waiting()                      # $96FF
		0x12:
			_leaving()                      # $9729
		0x13:
			_landed()                       # $9751
		0x14:
			pass                            # $9783, and $0C is not his to keep
		_:
			_ground(held, pressed)


## $97D4 -- the doubled weapon burning off.  He does not move at all; $05AB is
## taken down four a picture and when it will not go any lower he is put back
## on his feet and left alone for $7F pictures.
func _bursting() -> void:
	_floor()                                    # $97D4
	timer = 0x20                                # $8825
	if burst >= 4:
		burst -= 4                              # $97DA
		return
	scripted = 0                                # $B7AC
	step_t = 0
	step_i = 0
	state = ST_GROUND                           # $97ED
	pose = 0
	anim = 0                                    # $97F5
	hurt = 0x7F                                 # $97FA


# ---- the seventeen states a hero who is only walking never reaches ----
#
# The wire, the two rides, the doors and dying.  Most of them read and write
# slot $0C of the object pool, so `pool` has to be there; where it is not the
# state does as much of itself as it honestly can and no more.


## $98C9 -- ducking, which is where every one of the wire's states goes once
## whatever it was holding on to has gone.
func _to_crouch() -> void:
	state = ST_CROUCH


## $8806 -- the animation a state wears, and whether it has reached the step
## that never ends.
func _posed(id: int) -> bool:
	_pose(id)
	return step_t == 0xFF


## $B7AC -- the little script put away entirely, and nought handed back.
func _clear_script() -> int:
	scripted = 0
	step_t = 0
	step_i = 0
	return 0


## $A2F3 -- a push up at full strength: letting go of the wire while climbing
## is a whole jump, not the weakened one $A2BE gives.
func _spring_full() -> void:
	rise = jump - 0x100
	jump_flags = JUMP_USED
	hold = 0x80
	state = ST_AIR


## $9A7C -- letting go of the wire.  The satellite is told to reel itself back
## in and he is thrown out the way he is not looking.
func _let_go() -> void:
	if pool == null:
		return
	pool.mind[SAT] |= 0x80                      # $9A80
	fuel = 0x60                                 # $9A8C
	pool.c[SAT] = 0xA0 if face_left else 0x60   # $9A95
	speed = 0x20 if face_left else -0x20        # $9AA2


## $9347 and $934C -- the satellite's slot wiped clean.  The first of the two
## gives it a life as well; the ride comes in at the top and the stage's own
## landing comes in one line down.
func _clear_sat(alive: bool) -> void:
	if pool == null:
		return
	if alive:
		pool.life[SAT] = 0x10                   # $9347
	pool.cool[SAT] = 0xFF                       # $934C
	pool.mind[SAT] &= 0x7F
	pool.b[SAT] = 0
	pool.c[SAT] = 0
	pool.d[SAT] = 0
	pool.kind[SAT] = 0
	pool.left[SAT] = 0
	pool.frame[SAT] = 0
	pool.anim_a[SAT] = 0
	pool.anim_b[SAT] = 0
	pool.pic_lo[SAT] = 0
	pool.pic_hi[SAT] = 0


## Whether the satellite's slot still holds anything at all.  $FF is the mark
## it wears while it is being taken away, and counts as gone.
func _sat_gone() -> bool:
	if pool == null:
		return true
	var who: int = pool.id[SAT]
	return who == 0 or who == 0xFF


## $98CF -- [$04] holding on to the wire while it winds him in.  The count in
## $05AB is what paces it, and every whole turn of the satellite costs him a
## step of fuel until there is not enough left for another.
func _wire_hold(held: int) -> void:
	_apply_speed()                              # $98CF
	if _under() < 0x80:
		_fall()                                 # $98D9
		return
	if _sat_gone():
		_to_crouch()                            # $98E5
		return
	pool.anim_second(SAT, 0x14, 1)              # $98EC
	if (held & A) == 0:
		_to_crouch()                            # $98F1
		return
	# $98F3 -- which quarter of its turn counts depends which way up he is.
	var want: int = 0x10 if (flags & UPSIDE_DOWN) != 0 else 0x30
	if (pool.a[SAT] & 0x3F) != want:
		_pose(0x03)                             # $9933
		return
	burst = (burst - 1) & 0xFF                  # $990C
	if burst != 0:
		_pose(0x03)
		return
	burst = (burst + 1) & 0xFF                  # $9911
	if fuel < 0x30:
		state = 0x05                            # $991F
		return
	fuel = (fuel - 0x10) & 0xFF                 # $9925
	_pose(0x11)                                 # $992E


## $9938 -- [$05] the wire thrown and still going out.  B lets go of it, down
## keeps him where he is, and the wire reaching its end ($06CC of $FF) is what
## starts him climbing.
func _wire_out(held: int, pressed: int) -> void:
	_apply_speed()                              # $9938
	if _under() < 0x80:
		_fall()                                 # $9942
		return
	if pool == null:
		_to_crouch()
		return
	pool.face[SAT] = face                       # $9945
	if _sat_gone():
		_to_crouch()                            # $99A0
		return
	if (pressed & B) != 0:                      # $9954
		_script(0x15)
		state = ST_CROUCH                       # $995D
		pool.b[SAT] = ST_CROUCH                 # $9962
		_let_go()
		fuel = 0x10                             # $9968
		return
	pool.anim_second(SAT, 0x15, 1)              # $9972
	# $9975 -- while it is still going out its head flickers between two.
	if pool.left[SAT] != 0xFF:
		pool.pic_lo[SAT] = (0x62 + (clock & 0x02)) & 0xFF
	if (held & A) == 0:
		_to_crouch()                            # $99A0
		return
	if (held & DOWN) != 0:
		_pose(0x11)                             # $99A3
		return
	if pool.left[SAT] != 0xFF:
		_pose(0x11)
		return
	fuel = 0x60                                 # $9995
	state = 0x06


## $99A8 -- [$06] climbing the wire.  B lets go of it, and letting go from here
## is a whole jump.
func _wire_climb(held: int, pressed: int) -> void:
	_apply_speed()                              # $99A8
	if _under() < 0x80:
		_fall()                                 # $99B2
		return
	# $99B5 -- a noise every eighth picture, which is not modelled.
	if _sat_gone():
		_to_crouch()                            # $99EB
		return
	pool.anim_second(SAT, 0x16, 1)              # $99CC
	pool.face[SAT] = face                       # $99CF
	if (pressed & B) != 0:                      # $99D5
		pool.b[SAT] = _script(0x14)             # $99DE
		_let_go()
		_spring_full()                          # $99E4
		return
	if (held & A) == 0:
		_to_crouch()                            # $99EB
		return
	if _posed(0x12):                            # $99EE
		state = 0x07


## $99FB -- [$07] at the top of the wire, where the view itself carries him.
## It is the one wire state with no ground under it: letting go here falls.
func _wire_ride(held: int, pressed: int) -> void:
	# $99FB -- a noise every eighth picture, which is not modelled.
	if _sat_gone():
		_fall()                                 # $9A31
		return
	pool.anim_second(SAT, 0x16, 1)              # $9A12
	pool.face[SAT] = face                       # $9A15
	if (pressed & B) != 0:                      # $9A1B
		pool.b[SAT] = _script(0x14)             # $9A24
		_let_go()
		_spring_full()                          # $9A2A
		return
	if (held & A) == 0:
		_fall()                                 # $9A31
		return
	# $9A39 and $9A5A -- the satellite's own place against the top edge of the
	# view, a tile in on the right way up and fourteen on the wrong one.  The
	# hero is pulled after it a pixel a picture while it is past that line.
	if (flags & UPSIDE_DOWN) != 0:
		if pool.y[SAT] < ((pool.cam_y + 0x0E00) & 0xFFFF):
			vy = 0x0010                         # $9A4A
			_ceiling()                          # $A253
	else:
		if pool.y[SAT] >= ((pool.cam_y + 0x0100) & 0xFFFF):
			vy = -0x0010                        # $9A6A
			_ceiling()
	_pose(0x13)                                 # $9A77


## $98A8 -- [$08] standing in a door.  A takes him out of it downward, B takes
## him through it.
func _door(pressed: int) -> void:
	if scripted != 0:
		_script(0x18)                           # $98AD
		return
	if (pressed & A) != 0:
		state = 0x0A                            # $98B6
		return
	if (pressed & B) == 0:
		_pose(0x17)                             # $98BE
		return
	_script(0x18)                               # $98C3, and a noise with it


## $9896 -- [$09] coming down into a door.  A pixel a picture until the little
## script is over.
func _arrive() -> void:
	vy = _s16((vy & 0xFF00) | 0x04)             # $9896
	if _posed(0x19):
		state = 0x08                            # $98A2


## $986A -- [$0A] stepping out of a door.  Holding down lets him drop; anything
## else springs him out.
func _door_out(held: int) -> void:
	if not _posed(0x1A):                        # $986C
		return
	if (held & DOWN) != 0:
		_fall()                                 # $9877
	else:
		_launch()                               # $987D
	_apply_speed()                              # $9880


## $9886 -- [$0B] the same, and this one always springs.
func _door_up() -> void:
	if not _posed(0x1B):
		return
	_launch()                                   # $988D
	_apply_speed()                              # $9890


## $978A -- [$0C] dying.  $05AB counts the picture down and what it reaches is
## the state that hands the game on.
func _dying() -> void:
	_floor()                                    # $978A
	burst = (burst - 1) & 0xFF
	if burst != 0:
		return
	# $9792 -- $26 and $27, what the screen still owes, are the blanking's
	# business and nothing here has a model of it.
	state = 0x0E                                # $9799
	shield = 0                                  # $979E
	hurt = 0


## $97A7 -- [$0E] dead.  What is left after the count is the stage flow: which
## screen comes next ($02), how the view is put back ($2E) and the noise ($F0).
## Those are Э4.5's, so all that is kept here is the try being spent.
func _dead() -> void:
	_floor()                                    # $97A7
	_pose(0x20)                                 # $97AA
	if pool == null or pool.z26 != 0:
		return                                  # $97AF
	var left: int = pool.w_x[0x0C] & 0xFF       # $071C
	if pool.flow != null:
		# $97B3 -- with a flow to hand it to, the whole of the rest of $97A7
		# is the flow's: the try is spent there and the mode is named there.
		pool.flow.lives = left
		pool.flow.died()
		pool.w_x[0x0C] = (pool.w_x[0x0C] & 0xFF00) | (pool.flow.lives & 0xFF)
		return
	if left != 0:
		pool.w_x[0x0C] = (pool.w_x[0x0C] & 0xFF00) | ((left - 1) & 0xFF)


## $9816 -- [$0F] the picture a hit ends on.  Everything the hit left is put
## away and he falls straight into the state after this one.
func _hurt_out() -> void:
	_floor()                                    # $9816
	timer = 0x20                                # $8825
	_clear_script()                             # $B7AC
	hurt = 0                                    # $981F
	if pool != null:
		pool.id[0x0F] = 0                       # $9822
		pool.d[SAT] = 0x10                      # $9827
	state = (state + 1) & 0xFF                  # $982A


## $982E -- [$10] being carried.  He wears one of two pictures depending on
## whether there is anything under him at all, and $064C counts the ride out.
func _riding() -> void:
	timer = 0x20                                # $8825
	_pose(0x00 if _floor() >= 0x80 else 0x06)   # $983A, $9836
	# $983F -- and the count climbs by four a picture, bit seven thrown away.
	var b: int = burst & 0x7F
	if b < 0x7C:
		burst = (b + 0x04) & 0xFF
	if pool == null:
		return
	# $984D -- while something is in the slot the ride only counts down on the
	# quarter of its turn that $061C names.
	if pool.id[SAT] != 0 and ((pool.a[SAT] + 0xE8) & 0x3F) >= 0x10:
		return
	pool.d[SAT] = (pool.d[SAT] - 1) & 0xFF      # $985E
	if pool.d[SAT] != 0:
		return
	state = ST_GROUND                           # $8830
	_clear_sat(true)                            # $9347


## $96FF -- [$11] waiting for what his satellite threw to burn out.  While any
## of the eight is still flying nothing happens at all; once they are gone the
## little script runs and its fourth step throws him upward.
func _waiting() -> void:
	if pool == null:
		return
	var any := 0
	for i in range(8):
		any |= pool.w_kind[i]                   # $9703
	if any != 0:
		return
	_pose(0x05)                                 # $970E
	if step_i < 0x04:
		return                                  # $9716
	# $971A -- a noise on the one picture the step turns over, and nothing else.
	vy = -0x0080                                # $971E


## $9729 -- [$12] leaving a stage.  With nothing under him he slides out of the
## picture; standing on something he waits out the script and the fuel.
func _leaving() -> void:
	# $9783 -- $0C, the picture counter the whole game shares, is handed to the
	# engine frame by frame, so a bit set in it here would be thrown away.
	if _under() < 0x80:
		vx = _s16((vx & 0xFF00) | 0x20)         # $9731
		vy = _s16((vy & 0xFF00) | 0x20)
		return
	if not _posed(0x0E):                        # $973A
		return
	if fuel != 0:
		return                                  # $9741
	state = 0x13                                # $9746
	burst = 0x14


## $9751 -- [$13] the picture the ride into a stage ends on.  The whole pool
## but his own four slots is emptied, and what it reads out of $0757 and $07F0
## is the stage's own bookkeeping, which is Э4.5's and not his.
func _landed() -> void:
	burst = (burst - 1) & 0xFF                  # $9754
	if burst != 0:
		return
	_pose(0x00)                                 # $9770
	state = ST_GROUND                           # $8830
	if pool != null:
		for i in range(0x0C):
			pool.id[i] = 0                      # $977A
	_clear_sat(false)                           # $934C


## $9ED3 -- on the ground, standing or running.
func _ground(held: int, pressed: int) -> void:
	# $9ED3 -- a named animation is still running, so it and not the ground
	# says what he looks like, and the crouch and the jump are not offered.
	if scripted != 0:
		_script(scripted)
		_apply_speed()
		if _under() >= 0x80:
			return
		vy = _s16(vy + GROUND_PULL)
		_fall()
		return
	# $9EFC -- down, and something under him, is a crouch.
	if (held & DOWN) != 0:
		if _floor() >= 0x80:
			state = ST_CROUCH
			return
	# $9F0D -- A, and he is off.
	if (pressed & A) != 0:
		_under()
		_spring(pressed)
		hold = 0
		_apply_speed()
		return
	# $9F21 -- otherwise a look at what is under him, and if there is nothing
	# there a small push down and a fall.
	_apply_speed()
	if _under() >= 0x80:
		_upright(held, pressed)
		return
	vy = _s16(vy + GROUND_PULL)
	_fall()


## $9F41 -- what a hero on his feet looks like: standing still, walking, or
## running once the speed is up.
func _upright(held: int, pressed: int) -> void:
	if (pressed & B) != 0:
		_shoot(0x0F, 0x01)
		return
	if (held & 0x03) == 0:
		_pose(0x00)
		return
	var far: int = -speed if speed < 0 else speed
	_pose(0x02 if far >= 0x0E else 0x10)


## $9F67 and $9D2A -- letting a shot go.  $05CE is how hard the button is being
## worked: it climbs while he keeps firing and two in a row past the threshold
## bring out the long animation instead of the short one.
func _shoot(long_id: int, short_id: int) -> void:
	var long := false
	if anim >= 0x50:
		if (anim & 0x03) >= 2:
			long = true
		else:
			anim = 0xFF
	else:
		anim &= 0x03
		if anim >= 2:
			long = true
	if long:
		anim = 0x4A
		_script(long_id)
	else:
		anim = (anim + 1) & 0xFF
		_script(short_id)


## $9EA1 -- the moment after he lands.  Any button at all cuts it short.
func _landing(held: int, pressed: int) -> void:
	_apply_speed()
	# $9EA9 -- nothing under him and he simply falls; the little pull down that
	# standing adds ($9EE9) is not part of this state.
	if _under() < 0x80:
		_fall()
		return
	# $9EAE -- a hand on the pad and he is up at once; an empty pad and he
	# waits out the little script $9EBF starts, which is over when its last
	# step marks itself as never ending ($8806 reads $05A4 back).
	var done := held != 0
	if done:
		scripted = 0
		step_t = 0
		step_i = 0
	else:
		_pose(0x0C)
		done = step_t == 0xFF
	if done:
		state = ST_GROUND
		# $9ECD -- and the next jump starts at full strength again.
		jump = JUMP_FULL
		# $9ED0 -- and then falls straight into standing, in this same frame,
		# so a jump asked for on the frame he gets up is a jump.
		_ground(held, pressed)


## $9C7D -- ducking.  He keeps his place and lets go of the ground under him
## the same way standing does.
func _crouch(held: int, pressed: int) -> void:
	# $9C7D -- a named animation, and the crouch's own business is skipped.
	if scripted != 0:
		_script(scripted)
		_apply_speed()
		if _under() < 0x80:
			_fall()
		return
	_apply_speed()
	if _under() < 0x80:
		_fall()
		return
	held = _panels(held)                    # $9CA0
	# $9CE1 -- letting go of down stands him up, and $9D19 still has its say
	# about what he looks like on the way.
	if (held & DOWN) == 0:
		state = ST_GROUND
	if (pressed & B) == 0:
		_pose(0x03)
		return
	# $9D2A -- the crouching shot, which keeps its own script once started.
	if scripted == 0x15:
		_script(0x15)
		return
	_shoot(0x16, 0x09)


## $9CA0 -- ducking on one of the stage's four panels.  What he is standing on
## is compared against four tile numbers, and each of the four buys something
## different; nothing at all happens on a picture the background still owes a
## row or a column, because a panel used up rewrites the map.
##
## `held` is handed back: a panel holds the button down for him ($9E48) so
## that letting go of it does not stand him up in the middle of a purchase.
func _panels(held: int) -> int:
	if pool == null:
		return held
	if pool.row_due != 0 or pool.col_due != 0:
		return held                         # $9CA4
	var tile: int = _floor_tile() & 0xFE    # $9CAB
	if tile == 0:
		return held                         # $9CAE
	var row: Array = SolPanels.tiles(stage)
	if tile == int(row[0]):
		held = _buy_shield(held)            # $9DBE
	if tile == int(row[1]):
		held = _buy_suit(held)              # $9CC3
	if tile == int(row[2]):
		held = _buy_try(held)               # $9E30
	if tile == int(row[3]):
		# $9DDF -- and the fourth is whichever of the three this stage names.
		match SolPanels.gift(stage):
			0x00: held = _buy_shield(held)
			0x01: held = _buy_suit(held)
			_: held = _buy_try(held)
	# $9E48 writes the button into $06 itself, and $06 is both the pad this
	# picture and what the next one works out "newly pressed" against, so the
	# one the panel holds down is remembered as held.  Left and right are read
	# out of the same byte afterwards, and neither cares about this bit.
	pad_held |= held & SolPanels.one("hold_pad")
	return held


## $2A -- the metatile his feet are inside, which is what the floor probe
## leaves behind ($D0FD).  It is the one the stage names and not the one shown
## in its place: a panel is never a metatile that can be broken into another.
func _floor_tile() -> int:
	var py: int = y + (-FOOT_DY if (flags & UPSIDE_DOWN) != 0 else FOOT_DY)
	var m: int = lvl.raw_at((x & 0xFFFF) >> 4, (py & 0xFFFF) >> 4)
	return 0 if m < 0 else m


## $9E55 -- whether what he has not been paid yet, less what a panel has
## already taken, comes to the price.
func _afford(price: int) -> bool:
	return ((pool.hero_bonus - pool.z56) & 0xFFFF) >= price


## $9E4F -- and the price put on the tab.  $CDE3 takes it off a point a
## picture, which is why the count of the strip runs down instead of jumping.
func _spend(price: int) -> void:
	pool.z56 = (pool.z56 + price) & 0xFF


## $9DBE -- the first panel: a shield, for ten.
func _buy_shield(held: int) -> int:
	if shield == SolPanels.one("shield_full"):
		return held                         # $9DC3
	var price: int = SolPanels.cost(SolPanels.SHIELD)
	if not _afford(price):
		return held                         # $9DCA
	_spend(price)                           # $9DCC
	shield = SolPanels.one("shield_full")
	held |= SolPanels.one("hold_pad")       # $9DD4 -- $9E48
	# $9DD7 -- a noise, and noises are not modelled.
	_panel_used()                           # $9DDB
	return held


## $9CC3 and $9E00 -- the second: the suit, thirty for the whole of it.  A
## step goes on every odd picture while he stands there, and the thirty is
## only taken when the eighth step lands -- so a suit filled halfway and
## walked away from costs nothing at all.
func _buy_suit(held: int) -> int:
	var full: int = SolPanels.one("suit_full")
	if suit >= full:
		return held                         # $9CC8, and $9E05 again
	var price: int = SolPanels.cost(SolPanels.SUIT)
	if not _afford(price):
		return held                         # $9E0C
	held |= SolPanels.one("hold_pad")       # $9E0E -- $9E48
	timer = SolPanels.one("hold_timer")     # $9E11 -- $8825
	if (clock & 0x01) == 0:
		return held                         # $9E17
	suit += 1                               # $9E19
	if suit != full:
		return held                         # $9E21
	# $9E23 -- a noise, and then the panel is used up and the price taken.
	_panel_used()                           # $9E27
	_spend(price)                           # $9E2A
	return held


## $9E30 -- the third: a try, for two hundred.
func _buy_try(held: int) -> int:
	var price: int = SolPanels.cost(SolPanels.TRY)
	if not _afford(price):
		return held                         # $9E35
	_spend(price)                           # $9E37
	held |= SolPanels.one("hold_pad")       # $9E3A -- $9E48
	# $9E3D -- $071C, which lives in the low byte of the satellite's own slot.
	pool.w_x[0x0C] = (pool.w_x[0x0C] & 0xFF00) \
			| ((pool.w_x[0x0C] + 1) & 0xFF)
	# $9E40 -- a noise, and noises are not modelled.
	_panel_used()                           # $9E44
	return held


## $9E6D -- a panel used up: the two places under his feet are broken open and
## the puff of it is hatched between them.
func _panel_used() -> void:
	var below: int = (y & 0xFFFF) + 0x0100
	pool.break_panel((x & 0xFE00), below)               # $9E71 -- $81 & $FE
	pool.break_panel((x & 0xFF00) | 0x0100, below)      # $9E7E -- $81 | $01
	# $9E92 -- and the thing itself stands between the two, on his own row.
	pool.hatch_up((x & 0xFE00) | 0x0100, y & 0xFF00,
			SolPanels.one("spawn"))


## $A005 -- in the air.
func _air(held: int, pressed: int) -> void:
	# $A005 -- while he is still rising the button may push again, up to
	# $05EA times, and letting go ends it for good.
	if rise < 0:
		var again := hurt != 0 or timer >= 0x20
		if again:
			again = suit != 0 and (held & A) != 0 and (pressed & A) == 0
		if not again:
			hold = 0xFF
		if hold < hold_max:
			hold += 1
			_spring(pressed)
	# $A036 -- the frame's move across, then $A0BB's gravity down.
	_apply_speed()
	# $A0BB -- the fall gathers the same way round whichever way up the world
	# is: $B9F5 leaves $05E9 at four either way, and the turning itself
	# ($BA0A) takes the fall's own sign over, once, at the moment it turns.
	rise = _s16(rise + gravity)
	if (flags & UPSIDE_DOWN) != 0:
		# $A0D0 -- and it comes off the move rather than going on, with the
		# borrow still down: the add above clears the carry on both its ways
		# out ($A0C5 falls through with it clear, $A0CA clears it), so one
		# more than the fall is what is taken.
		vy = _s16(vy - rise - 1)
		if vy < -FALL_MAX - 1:                  # $A0E4 and $A0EB, $FF9F
			vy = -FALL_MAX - 1
	else:
		vy = _s16(vy + rise)                    # $A0FA
		if vy > FALL_MAX:                       # $A113
			vy = FALL_MAX
	# $A078 and $A084 -- the floor going down, the ceiling going up.  Both look
	# where the move would put him, not where he is.
	if rise >= 0:
		if _meet() >= 0x80:
			_settle(held)
			return
	elif _ceiling() >= 0x80:
		# $A08F -- SEC/ROR on the low byte alone, which is what kills the
		# rise; the high byte is left where it was.
		hold = hold_max
		rise = _s16((rise & 0xFF00) | (((rise & 0xFF) >> 1) | 0x80))
	# $A093 -- and what he looks like on the way up or down.
	if scripted != 0:
		_script(scripted if scripted == 0x14 else 0x08)
		return
	if (pressed & B) != 0:
		_script(0x08)
		return
	_pose(0x06 if rise < 0 else 0x07)


## $B7BA -- the animation the state itself wears.  Asking for the one already
## running changes nothing; asking for another starts it at its first step.
func _pose(id: int) -> void:
	if id != pose:
		pose = id
		step_t = 0
		step_i = 0
	_reel(pose)


## $B78E -- a named animation, which puts itself away once it reaches the step
## that never ends.
## What it hands back is the step's own length, or nought where the step was
## the one that never ends -- $99D9 and $9A1F keep it.
func _script(id: int) -> int:
	if id != scripted:
		scripted = id
		step_t = 0
		step_i = 0
	_reel(scripted)
	if step_t == 0xFF:
		scripted = 0
		step_t = 0
		step_i = 0
		return 0
	return step_t


## $B7CE -- one frame of whichever little script is running.  A step's length
## of $FF means it never ends, and the script is a ring: running off the end
## comes back to the first step.  Being hurt swaps the whole book for another.
func _reel(id: int) -> void:
	SolSprites.load_data()
	if step_t != 0:
		if step_t == 0xFF:
			return
		step_t -= 1
		if step_t != 0:
			return
	var book: Array = SolSprites.hurt if hurt != 0 else SolSprites.scripts
	if id >= book.size():
		return
	var steps: Array = book[id]
	if steps.is_empty():
		return
	if step_i >= steps.size():
		step_i = 0                      # $B837 -- a length of nought is the end
	var s: Array = steps[step_i]
	step_t = int(s[0])
	pic_lo = int(s[1])
	pic_hi = int(s[2])
	step_i += 1
	# $B81E -- a handful of the animations strike on one of their steps.  The
	# table says on which step and which of the four reaches; bit 7 means the
	# animation never strikes at all.  What is struck is slot fifteen of the
	# object pool, and that is $B862's business, so only the ask is kept here.
	if id < SolSprites.loop.size():
		var v: int = int(SolSprites.loop[id])
		if (v & 0x80) == 0 and (v & 0x0F) == step_i:
			punch = (v & 0x70) >> 1          # $B833
			punch_x = was_x                  # $B871
			punch_y = was_y


## $A2B5 -- a push up, unless this jump has already been spent and the button
## is not being asked again.
func _spring(pressed: int) -> void:
	if (jump_flags & JUMP_USED) != 0 or (pressed & A) != 0:
		_launch()
	else:
		state = ST_AIR


## $A2BE -- push him up, and make the next push of this jump weaker.
func _launch() -> void:
	if jump >= JUMP_FLOOR:
		jump -= step_down
	rise = jump - 0x100
	jump_flags = JUMP_USED
	state = ST_AIR


## $A2DD -- nothing under him any more.
func _fall() -> void:
	hold = 0
	rise = 0
	jump_flags = JUMP_USED
	state = ST_AIR


## $A30C -- he has met the ground.  The move was cut back inside the probe so
## his feet come down exactly on the surface; here he is either already walking
## or he spends a moment getting up.
func _settle(held: int) -> void:
	hold = 0
	rise = 0
	jump_flags = 0
	# $A31A -- and whatever animation was running is put away entirely.
	scripted = 0
	step_t = 0
	step_i = 0
	# $A323 -- a direction already held and he is simply walking.
	state = ST_GROUND if (held & 0x03) != 0 else ST_LAND
	# $A330
	jump = JUMP_FULL


## $9AA5 -- left and right.  Steering when a direction is held, drag when not,
## and on the one frame after a hurt neither: a throw backwards instead.
func _horizontal(held: int) -> void:
	if scripted != 0 and timer != 1 and state != ST_AIR:
		_drag()
		return
	if timer == 1:
		_thrown()
		return
	# $9AC3 -- and the carry that comparison leaves is read again at $9B55.
	_steer(held, 1 if timer >= 1 else 0)


## $9ABE -- the frame after $9FA5 set the clock back to nothing.
func _thrown() -> void:
	if suit != 0:
		if hurt != 0:
			_steer(0, 1)                    # $9ACD, and the clock is one
			return
		if state != ST_AIR:
			_knock()
			return
		jump_flags = 0xC0
		_steer(0, 1)                        # $9AD8, after an equal CPX
		return
	_knock()


## $9ADA -- the throw itself.  Water takes four fifths of it away.
func _knock() -> void:
	if gravity >= 2:
		speed = 0x20 if face_left else -0x20
	else:
		speed = 0x08 if face_left else -0x08
	if suit == 0 or swim != 0:
		# $9B06 -- a hero with no suit on, or one already reeling, goes twice
		# as far.
		speed = _sbyte(speed * 2)
		swim = 0
	jump = 0xF0 if gravity < 2 else 0xD0
	_launch()


## $9B1E -- on the way to the steering, the one thing that lets the wire go: a
## hero with no suit on and no line left, standing in state two on the eighth
## step of his animation, is pushed off it backwards.
##
## Each of the four comparisons leaves a carry, and $9B55 rolls that carry into
## the byte it writes to $05B2, so the carry is handed on rather than dropped.
func _release(c_in: int) -> int:
	if suit != 0:
		return c_in                         # $9B21
	if fuel != 0:
		return c_in                         # $9B26
	if state != 2:
		return 1 if state >= 2 else 0       # $9B2D
	if step_t != 8:
		return 1 if step_t >= 8 else 0      # $9B34
	fuel = (fuel + 1) & 0xFF                # $9B36
	jump = 0xF8                             # $9B39
	var c: int = 1 if jump >= JUMP_FLOOR else 0
	_launch()                               # $9B3E
	speed = 0x18 if face_left else -0x18    # $9B41
	return c


## $9B4C -- the steering proper.  The direction held is rolled three places
## right and the whole byte of it becomes $05B2: bit 7 is "looking left", bit 6
## is "right is held", bit 5 is the carry that came down from $9B1E.
func _steer(held: int, c_in: int) -> void:
	var carry: int = _release(c_in)
	var dir: int = held & STEER[state] & 0x03
	if dir == 0:
		_drag()
		return
	var v: int = dir                        # $9B55, three rolls right
	for _k in range(3):
		var nc: int = v & 0x01
		v = ((carry << 7) | (v >> 1)) & 0xFF
		carry = nc
	# $9B59 -- turning round on ordinary ground costs half the speed.
	if ((v ^ face) & 0x80) != 0 and state != ST_AIR and ground == GROUND_PLAIN:
		speed = _asr(speed)
	face = v                                # $9B6D
	# $9B72 and $9B7E -- two a frame, one on anything slippery.
	var gain: int = 1 if ground != GROUND_PLAIN else 2
	speed = _sbyte(speed + (-gain if face_left else gain))
	# $9C60
	speed = clampi(speed, -TOP_SPEED, TOP_SPEED)


## $9B8A -- nothing held: take the drag off, and stop dead rather than cross
## zero.  Which drag is the state's business and the ground's together.  What
## is left of the move then has the wall put to it a second time, by a slightly
## stricter rule than $A122's -- and without the suit, only its sign is left.
func _drag() -> void:
	var move := speed
	if speed != 0:
		var d: int = DRAG[ground + state]
		if speed > 0:
			speed = 0 if speed - d < 0 else speed - d
		else:
			speed = 0 if speed + d > 0 else speed + d
		move = speed
	if move == 0 and push_x == 0:
		return
	# $9BDA -- and without the suit what is left of the move is thrown away
	# before the side is picked: the pair is shifted a whole byte down, so all
	# that survives of it is its sign, nought or one step back.  Under a push
	# that could send the question to the other wall, but the push is dead --
	# $05A8:$05A9 is written in one place only ($91B8) and written nought --
	# so the sign is the same sign either way and nothing comes of it.  It is
	# here because it is there.
	if move != 0 and suit == 0:
		move = 0 if move > 0 else -1
	if move + push_x >= 0:
		_wall_right(true)
	else:
		_wall_left(true)


## $A122 -- the one byte of speed becomes the frame's move, plus whatever is
## pushing him from outside, and then the wall has its say.
##
## It adds rather than sets, and it is called more than once on the frame the
## landing hands back to standing, so that frame really does move him twice.
## That is the cartridge ($9EA1 applies, $9ED0 falls into $9ED3, which applies
## again) and it is kept.
func _apply_speed() -> void:
	if speed == 0 and push_x == 0:
		return
	vx = _s16(vx + speed + push_x)
	_wall()


## $A15D -- which way the move points is which wall is asked about.
func _wall() -> void:
	if vx >= 0:
		_wall_right(false)
	else:
		_wall_left(false)


## $A3E5 and $A3C0 -- the wall on his right, and the end of the area behind it.
## `settled` picks the second of the two: it is the one the drag path uses, and
## it tells the two apart by which way he faces rather than which way he moves.
func _wall_right(settled: bool) -> void:
	var stop := false
	if _side(WALL_DX) >= 0x80:
		stop = not face_left if settled else vx >= 0
	if not stop:
		stop = x > x_end - 0x100
	if not stop:
		return
	# $A3DA against $A3FF: the drag's own wall takes the speed away whichever
	# way he looks, and only the move's wall asks first.
	if settled or not face_left:
		speed = 0
	vx = 0


## $A355 and $A336 -- and the same on his left.
func _wall_left(settled: bool) -> void:
	var stop := false
	if _side(-WALL_DX) >= 0x80:
		stop = face_left if settled else vx < 0
	if not stop:
		stop = x_min >= x if settled else x_min >= x - 0x100
	if not stop:
		return
	# $A34A against $A374 -- the same again on this side.
	if settled or face_left:
		speed = 0
	vx = 0


## $A411 and $A381 -- two heights, and either of them is a wall.  The pair is
## the same on both sides; only the order they are asked in differs.
##
## The second point is a whole move further across than the first.  That is not
## design: $A411 works out the point once and leaves it in $90:$91, and $D010
## adds the move to $90:$91 in place every time it is called, so the second
## call adds it again on top of the first.  A hero going fast reaches a wall a
## frame earlier with his upper half than with his lower.
## A wall that hurts hurts on touch: $A3B0 and $A43F ask $9FA5 for it, but
## unlike the ground under him a wall never pushes or slips.
func _side(dx: int) -> int:
	var step: int = vx + (1 if map_kind > 0x3C else 0)
	var px: int = x + dx + step
	var near: int = WALL_HIGH_DY if dx < 0 else WALL_LOW_DY
	var far: int = WALL_LOW_DY if dx < 0 else WALL_HIGH_RIGHT_DY
	var v := _probe_side(px, y + near)
	if v < 0x80:
		v = _probe_side(px + step, y + far)
	if (v & 0xE0) != 0x60 and (v & 0x40) != 0:
		_wound()
	return v


## $A1B3 -- what is sixteen pixels below him, with nothing added for the move.
func _floor() -> int:
	return _probe(x, y + (-FOOT_DY if (flags & UPSIDE_DOWN) != 0 else FOOT_DY))


## $A194 -- the same look, and then what the ground under him does about it:
## spikes hurt, belts push, ice lets go.
func _under() -> int:
	var v := _floor()
	_react(v)
	return v


## $A1D6 -- where the move would put his feet.  When that is inside something
## the move is cut back so that they come down on the surface exactly: what is
## left of the metatile he would have ended up in is taken off the move, so his
## feet land on the surface and not a sixteenth past it.
func _meet() -> int:
	var up: bool = (flags & UPSIDE_DOWN) != 0
	var py: int = y + vy
	var v := _probe(x + vx, py + (-FOOT_DY if up else FOOT_DY))
	if v >= 0x80:
		# $A221 going down, $A209 going up.  What is taken off is $9D, which
		# the probe itself left behind: the low byte of the point it looked
		# at, or nought where the lift's own line answered ($D087).
		if up:
			vy = _s16(vy + (0xFF - z9d))
		else:
			vy = _s16(vy - z9d)
	return v


## $A232 and $A253 -- and the same going up, except that this one also reacts
## to what it finds.
func _ceiling() -> int:
	# $A26E -- the stage that is all water has no ceiling at all: the probe
	# gives its own $3C back, which is neither a block nor anything to react
	# to, and the move is left whole.
	if map_kind == 0x3C:
		return 0x3C
	var up: bool = (flags & UPSIDE_DOWN) != 0
	var py: int = y + vy
	var v := _probe(x + vx, py + (FOOT_DY if up else -FOOT_DY))
	if v >= 0x80:
		# $A29E -- how far into the metatile above him the move would have
		# taken him, taken back off the move.
		if up:
			vy = _s16(vy - z9d)
		else:
			vy = _s16(vy + (0xFF - z9d))
	_react(v)
	return v


## $A198 and $A236 -- the three things a property byte can ask for.
func _react(v: int) -> void:
	var kind := v & 0xE0
	if kind == 0x60:
		return
	if (kind & 0x40) != 0:
		_wound()
	elif kind == 0xA0:
		_shove(v)


## $9FA5 -- being hurt.  The first touch costs a step of suit; a touch while
## already hurt only deepens it.  Either way the clock goes back to nothing,
## and that is what $9AA5 reads next frame to throw him backwards.
func _wound() -> void:
	if hurt != 0:
		if timer < 0x20:
			return
		var left := hurt - 8
		hurt = (left | 7) if left >= 0 else 2
	else:
		if timer < 0x70:
			return
		if shield != 0:
			shield -= 1
		if suit == 0:
			return
		var left := suit - 1
		if left < 0:
			left = 0
			fuel = 0
		suit = left
	timer = 0


## The property byte of the metatile at a point, shifted up three the way the
## cartridge shifts it ($D101): bit 7 solid, bit 6 hurts, bit 5 a second kind.
func _probe(px: int, py: int) -> int:
	# $D035 -- the stage that carries has no tile map under him at all.  Its
	# floor is the one line the lift keeps: $75 sixteen times over, taken from
	# the top of the view, and a point between that line and two hundred and
	# fifty five sixteenths below it is answered solid.
	#
	# The routine does not only answer, though.  It takes however far past the
	# line the point was off his fall and puts $72 back on, which is what
	# settles him $E0 above the line and carries him up with it.  Every probe
	# that comes this way does it, not only the one that means to land him.
	if map_kind == 0x3C and pool != null:
		var line: int = ((pool.z75 << 4) + pool.cam_y) & 0xFFFF     # $D04E
		var d: int = (py - line) & 0xFFFF                           # $D059
		if d < 0x100:
			z9d = 0                                                 # $D087
			vy = _s16(vy - d + pool.z72)            # $D06B and $D079
			return 0x80                                             # $D08B
	z9d = py & 0xFF                                                 # $D08F
	return (lvl.collision_at((px & 0xFFFF) >> 4, (py & 0xFFFF) >> 4) << 3) & 0xFF


## $D010 -- the lookup the two side probes go through instead.  On the stage
## that carries it answers nothing at all: $D014 turns straight round with $70
## still in hand, so both walls read $3C, which is neither a block nor anything
## to react to.
func _probe_side(px: int, py: int) -> int:
	if map_kind == 0x3C:
		return 0x3C                                                 # $D014
	z9d = px & 0xFF                                                 # $D01D
	return (lvl.collision_at((px & 0xFFFF) >> 4, (py & 0xFFFF) >> 4) << 3) & 0xFF


func _sbyte(v: int) -> int:
	v &= 0xFF
	return v - 0x100 if v >= 0x80 else v


func _s16(v: int) -> int:
	v &= 0xFFFF
	return v - 0x10000 if v >= 0x8000 else v


## An arithmetic shift right of one signed byte, which is what $9B69's ROL/ROR
## pair comes to.
func _asr(v: int) -> int:
	return _sbyte((v & 0xFF) >> 1 | (v & 0x80))
