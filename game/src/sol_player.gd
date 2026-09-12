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
## $06 as it stood at the end of last frame -- masked, not raw.  $C88B works
## out what was newly pressed by comparing the pad against this, so a mask that
## blanked $06 makes a button that was never let go read as pressed again the
## moment the mask lifts.  A jump held down through being hurt is a second jump
## on the frame he gets control back.
var pad_held := 0


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


## $9477 -- one frame of him, start to finish.  `pad` is the controller as it
## stands; what was newly pressed is worked out here, the way $C882 does it.
func step(pad: int) -> void:
	# The frame counter the whole game shares has already moved on by the time
	# the hero is asked to run: ice reads it, and reads it after the step.
	clock = (clock + 1) & 0xFF
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
		return                              # $9384, not ported yet
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


## $95AD -- under water: a tenth of the gravity and a hold that lasts five
## times as long, which together are what swimming is.
func _wet() -> void:
	_flip_rise(0)
	flags = 0
	ground = GROUND_WATER
	jump = 0xE0
	gravity = 1
	hold_max = 0x20
	step_down = 6


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


## $9689 -- up and down, which is really the state's own handler.  Four of the
## twenty one are ported; the rest fall back to standing, which is what the
## engine can honestly do with them so far.
func _vertical(held: int, pressed: int) -> void:
	match state:
		ST_AIR:
			_air(held, pressed)
		ST_LAND:
			_landing(held, pressed)
		ST_CROUCH:
			_crouch(held, pressed)
		_:
			_ground(held, pressed)


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
	rise = _s16(rise + (-gravity if (flags & UPSIDE_DOWN) != 0 else gravity))
	vy = _s16(vy + rise)
	if vy > FALL_MAX:
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
func _script(id: int) -> void:
	if id != scripted:
		scripted = id
		step_t = 0
		step_i = 0
	_reel(scripted)
	if step_t == 0xFF:
		scripted = 0
		step_t = 0
		step_i = 0


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
			punch = (v & 0x70) >> 1


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
## stricter rule than $A122's.
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
	if not face_left:
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
	if face_left:
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
	var v := _probe(px, y + near)
	if v < 0x80:
		v = _probe(px + step, y + far)
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
		# $A221 going down, $A209 going up.
		if up:
			vy = _s16(vy + (0xFF - (py & 0xFF)))
		else:
			vy = _s16(vy - (py & 0xFF))
	return v


## $A232 and $A253 -- and the same going up, except that this one also reacts
## to what it finds.
func _ceiling() -> int:
	var up: bool = (flags & UPSIDE_DOWN) != 0
	var py: int = y + vy
	var v := _probe(x + vx, py + (FOOT_DY if up else -FOOT_DY))
	if v >= 0x80:
		# $A29E -- how far into the metatile above him the move would have
		# taken him, taken back off the move.
		if up:
			vy = _s16(vy - (py & 0xFF))
		else:
			vy = _s16(vy + (0xFF - (py & 0xFF)))
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
