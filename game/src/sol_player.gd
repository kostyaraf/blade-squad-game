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

## $9C03, $9C1B, $9C33 -- how much speed letting go takes off, by state, and
## which of the three by the ground he is on.  $05CD is the offset into them, so
## the three tables are really one of 24 bytes repeated; they are kept apart
## here because that is easier to read and comes to the same thing.
const DRAG := [
		[4, 1, 4, 4, 4, 4, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
		 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20],
		[1, 0, 1, 1, 1, 1, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
		 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20],
		[0, 1, 0, 0, 0, 0, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
		 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20],
]

const TOP_SPEED := 0x16         # $9C69, $9C74
const FALL_MAX := 0x60          # $A113
const JUMP_FULL := 0xE0         # $9ECD, what landing hands back
const JUMP_FLOOR := 0xB8        # $A2C1, under this it stops weakening
const JUMP_STEP := 6            # $5B
const HOLD_MAX := 6             # $05EA
const GRAVITY := 4              # $05E9
const GROUND_PULL := 0x20       # $9EE9

## The three probes, as offsets from where he says he is.  The right hand one
## really is fourteen pixels below him and not two above: $A41F adds $E0 with
## $A425 adding nothing on top, so the sign never reaches the high byte.  The
## cartridge is like that and so is this.
const FOOT_DY := 16 * 16
const WALL_DX := 8 * 16
const WALL_RIGHT_DY := 14 * 16
const WALL_LEFT_DY := -6 * 16

var lvl: SolLevel
## $38:$39 and $3A:$3B -- how far along the area he may go.  The level carries
## them as the view's own limits, which is where the cartridge gets them too.
var x_min := 0
var x_end := 0

var x := 0                      # $80:$81, sixteenths of a pixel
var y := 0                      # $82:$83, and sixteen pixels above his feet
var vx := 0                     # $05B6:$05B7, this frame's move
var vy := 0                     # $05B8:$05B9
var rise := 0                   # $05AD:$05AE, the vertical speed before it lands
var speed := 0                  # $35, one signed byte
var state := ST_GROUND          # $05A2
var timer := 0                  # $05A3
var face_left := false          # $05B2 bit 7
var hold := 0                   # $05AC
var jump := JUMP_FULL           # $05E8
var gravity := GRAVITY          # $05E9
var hold_max := HOLD_MAX        # $05EA
var ground := 0                 # $05CD: 0 normal, 1 slippery, 2 ice
var upside_down := false        # $05CB bit 7
var hurt := 0                   # $05C2
var scripted := 0               # $05A5
var used_jump := false          # $05C9 bit 7
var push_x := 0                 # $05A8:$05A9
var anim := 0                   # $05CE
var suit := 8                   # $05C5
## $05A4 stands in for the little animation script the landing waits on: the
## cartridge lets state 2 run until the script marked itself finished ($8806,
## $05A4 = $FF), and until the scripts are ported this counts the frames it
## took instead -- nine, measured.
var land := 0
const LAND_FRAMES := 9


func _init(level: SolLevel) -> void:
	lvl = level
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


## $9477 -- one frame of him, start to finish.
func step(held: int, pressed: int) -> void:
	# $9477: the frame's move starts at nothing every time, and is decided
	# whole before anything is applied.
	vx = 0
	vy = 0
	# $948D
	if timer < 0xFF:
		timer += 1
	# $9495
	anim = min(anim + 4, 0xFC)
	# $94A5 -- while he is hurt the pad is taken away from him.  The cartridge
	# masks it with one of three patterns by how far the hurt has gone; until
	# the hurt states are ported the whole pad goes.
	if hurt != 0:
		held = 0
		pressed = 0
	# $94D5 and $94D8, in that order: up and down first, then left and right.
	#
	# The order is not a detail.  The state's own handler is what turns $35
	# into the frame's move ($9EDB `LDA $35 / JSR $A122`), and it runs before
	# $9AA5 gets to touch $35 at all -- so the move a frame makes is the speed
	# the frame before it left behind, and the speed decided now is spent on
	# the frame after.  Measured: holding right from a standstill leaves him
	# where he was for one frame while $35 is already 2.
	_vertical(held, pressed)
	_steer(held)
	# $94DB -- and only now does he move.
	x = (x + vx) & 0xFFFF
	y = (y + vy) & 0xFFFF


## $9AA5 -- left and right.  Steering when a direction is held, drag when not.
## It settles $35 and nothing else; what the frame actually moves by was worked
## out by the state's handler a moment ago, out of the $35 this is replacing.
func _steer(held: int) -> void:
	var dir: int = held & STEER[state] & 0x03
	if dir == 0:
		_drag()
	else:
		var want_left := dir == LEFT
		# $9B59 -- turning round on ordinary ground costs half the speed.
		if want_left != face_left and state != ST_AIR and ground == 0:
			speed = _asr(speed)
		face_left = want_left
		# $9B72 and $9B7E -- two a frame, one on anything slippery.
		var gain: int = 1 if ground != 0 else 2
		speed = _sbyte(speed + (-gain if face_left else gain))
		# $9C60
		speed = clampi(speed, -TOP_SPEED, TOP_SPEED)


## $9B8A -- nothing held: take the drag off, and stop dead rather than cross
## zero.  Which drag is the state's business and the ground's together.
func _drag() -> void:
	if speed == 0:
		return
	var d: int = DRAG[ground][state]
	if speed > 0:
		speed = 0 if speed - d < 0 else speed - d
	else:
		speed = 0 if speed + d > 0 else speed + d


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
	vx += speed + push_x
	var back: bool = vx < 0
	var px: int = x + (-WALL_DX if back else WALL_DX) + vx
	# $A411 and $A381 -- two heights, and either of them is a wall.  The pair
	# is the same on both sides; only the order they are asked in differs.
	var blocked: bool = _solid(px, y + WALL_RIGHT_DY) or _solid(px, y + WALL_LEFT_DY)
	if not blocked:
		# $A3CA and $A35F -- and where there is no wall there is still the end
		# of the area, which he may not walk out of.  The cartridge compares a
		# whole page off: the limit against his place less 256.
		blocked = x_min >= x - 0x100 if back else x > x_end - 0x100
	if blocked:
		# $A3FF and $A36F -- the move is cancelled outright, and his speed
		# goes with it if he was facing the way he was blocked.
		if face_left == back:
			speed = 0
		vx = 0


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
			_crouch(held)
		_:
			_ground(held, pressed)


## $9ED3 -- on the ground, standing or running.
func _ground(held: int, pressed: int) -> void:
	# $9EFC -- down, and something under him, is a crouch.
	if (held & DOWN) != 0:
		if _foot():
			state = ST_CROUCH
			return
	# $9F0D -- A, and he is off.
	if (pressed & A) != 0:
		_foot()
		_launch()
		hold = 0
		_apply_speed()
		return
	# $9F21 -- otherwise the small push that keeps him on the floor, and a
	# check of what is under him.
	_apply_speed()
	vy = 0
	rise = _s16(rise + GROUND_PULL)
	if not _foot():
		_fall()
		return
	_settle()


## $9EA1 -- the moment after he lands.  Any button at all cuts it short.
func _landing(held: int, pressed: int) -> void:
	_apply_speed()
	if not _foot():
		_fall()
		return
	land += 1
	# $9EAE -- a hand on the pad and he is up at once; an empty pad and he
	# waits out the little script $9EBF starts.
	if held != 0 or land >= LAND_FRAMES:
		state = ST_GROUND
		# $9ECD -- and the next jump starts at full strength again.
		jump = JUMP_FULL
		# $9ED0 -- and then falls straight into standing, in this same frame,
		# so a jump asked for on the frame he gets up is a jump.
		_ground(held, pressed)


## $9C7D -- ducking.  He keeps his place and lets go of the ground under him
## the same way standing does.
func _crouch(held: int) -> void:
	_apply_speed()
	if not _foot():
		_fall()
		return
	if (held & DOWN) == 0:
		state = ST_GROUND


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
			_launch()
	# $A036 -- the frame's move across, then $A0BB's gravity down.
	_apply_speed()
	rise = _s16(rise + (-gravity if upside_down else gravity))
	vy = rise
	if vy > FALL_MAX:
		vy = FALL_MAX
	# $A078 and $A084 -- the floor going down, the ceiling going up.  Both look
	# where the move would put him, not where he is.
	if vy > 0:
		if _solid(x + vx, y + vy + FOOT_DY):
			_land(held)
	elif vy < 0:
		if _solid(x + vx, y + vy - FOOT_DY):
			# $A08F -- SEC/ROR on the low byte alone, which is what kills the
			# rise; the high byte is left where it was.
			hold = hold_max
			rise = _s16((rise & 0xFF00) | (((rise & 0xFF) >> 1) | 0x80))
			vy = rise


## $A2BE -- push him up, and make the next push of this jump weaker.
func _launch() -> void:
	if jump >= JUMP_FLOOR:
		jump -= JUMP_STEP
	rise = jump - 0x100
	used_jump = true
	state = ST_AIR


## $A2DD -- nothing under him any more.
func _fall() -> void:
	hold = 0
	rise = 0
	used_jump = true
	state = ST_AIR


## $A221 and $A30C -- he has met the ground.  The move is cut back so his feet
## come down exactly on the surface, and then either he is already walking or
## he spends a moment getting up.
func _land(held: int) -> void:
	vy -= (y + vy) & 0xFF
	hold = 0
	rise = 0
	used_jump = false
	# $A323 -- a direction already held and he is simply walking.
	state = ST_GROUND if (held & 0x03) != 0 else ST_LAND
	land = 0
	# $A330
	jump = JUMP_FULL


## What standing does once it knows there is something under him: nothing at
## all, because the pull he was given is cancelled by the floor.
func _settle() -> void:
	rise = 0
	vy = 0


## $A1B3 -- is there floor sixteen pixels below him?
func _foot() -> bool:
	return _solid(x, y + (-FOOT_DY if upside_down else FOOT_DY))


## props bit 4, the solid one, at a point given in sixteenths of a pixel.
func _solid(px: int, py: int) -> bool:
	return (lvl.collision_at(px >> 4, py >> 4) & 0x10) != 0


## $9B69 -- ROL/ROR on one byte is a halving that keeps the sign.
static func _asr(v: int) -> int:
	return v >> 1 if v >= 0 else -((-v + 1) >> 1)


static func _sbyte(v: int) -> int:
	v &= 0xFF
	return v - 0x100 if v >= 0x80 else v


static func _s16(v: int) -> int:
	v &= 0xFFFF
	return v - 0x10000 if v >= 0x8000 else v
