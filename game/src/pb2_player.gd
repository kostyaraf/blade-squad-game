extends RefCounted
class_name Pb2Player

## Power Blade 2's hero, moved the way the cartridge moves him.
##
## Everything is whole numbers: position in 1/256 of a pixel, speed in 1/256 of
## a pixel per frame -- the same units the console used, so the same jump comes
## out.  The order the steps run in is the order of the routine at $8EC1 and
## $91B5; work/re/pb2_player.md says which line came from where.

const A := 0x80
const B := 0x40
const UP := 0x08
const DOWN := 0x04
const LEFT := 0x02
const RIGHT := 0x01

const SUB_GROUND := 4
const SUB_CROUCH := 5
const SUB_SLIDE := 7
const SUB_AIR := 8
const SUB_LANDED := 9

const POSE_STAND := 0x11
const POSE_IDLE := 0x12
const POSE_CROUCH := 0x09
const POSE_SLIDE := 0x0D
const POSE_RISE := 0x18
const POSE_FALL := 0x19
const WALK_POSES := [0x06, 0x07, 0x08, 0x05]

var lvl: Pb2Level
var cfg: Dictionary
var body: Dictionary
var body_index: Array

# where he is, in 1/256 of a pixel, measured from the screen's top left corner
# exactly as the cartridge measures it: x across, y at the level of his feet
var x := 0
var y := 0
var vx := 0
var vy := 0
var dx := 0                     # what this frame wants to move him by
var dy := 0
var state := 0
var sub := SUB_GROUND
var pose := POSE_STAND
var face_left := false
var idle := 0                   # $0111 when standing, the fall counter in the air
var fall := 0                   # $0112:$0113, how far this fall has gone
var anim_t := 0
var anim_f := 0
var cam := 0                    # where the level is, in pixels
## Which body the sideways check uses; $A095 swaps it while he is off the
## ground, and the crouch and the slide name their own.
var body_x := 1
var pad := 0
var hit := 0


func _init(level: Pb2Level) -> void:
	lvl = level
	cfg = Nes._load_json("%s/pb2/player.json" % Nes.DATA)
	body = cfg["body"]
	body_index = cfg["body_index"]


func place(sx: int, sy: int, camera: int) -> void:
	x = sx << 8
	y = sy << 8
	cam = camera


# ---------------------------------------------------------------- the frame

func step(buttons: int, pressed: int, camera: int) -> void:
	pad = buttons
	hit = pressed
	cam = camera
	dx = 0
	dy = 0
	match sub:
		SUB_GROUND: _ground()
		SUB_AIR: _air()
		SUB_CROUCH: _crouch()
		SUB_SLIDE: _slide()
		SUB_LANDED: _landed()
		_: _ground()


## $8EC1 -- standing, walking, and everything that starts from the ground.
func _ground() -> void:
	_apply_vertical(8)
	if pad & (LEFT | RIGHT):
		idle = 0
		if _a08d():
			pose = POSE_STAND
		else:
			if not (state & 0x02):
				state = 0x02
				anim_t = 0
				anim_f = 0
			_animate()
	else:
		idle = (idle - 1) & 0xFF
		pose = POSE_IDLE if idle >= 0x70 and idle < 0x80 else POSE_STAND
		state = 0
		_friction()
	_ground_exits()


## $8F2D -- the ground's four ways out: a ladder, a ledge, a jump, a crouch.
func _ground_exits() -> void:
	if not _floor_solid(8):
		_step_off()
		return
	if pad & UP:
		return                             # ladders come with E2's next step
	if _jump_wanted():
		_jump()
	elif pad & DOWN:
		_crouch_start()


## $91B5 -- in the air.
func _air() -> void:
	_a08d()
	# $91D0: pressed into a wall he is pushed a pixel out of it
	if _class_byte((x >> 8) + 5, (y >> 8) - 8) & 0x80:
		x -= 0x100
	elif _class_byte((x >> 8) - 6, (y >> 8) - 8) & 0x80:
		x += 0x100
	_gravity()
	if dy < 0:
		if _ceiling_hit(3):
			vy = 0
			y &= ~0xFF                     # $92BD: the fraction is dropped
			pose = POSE_RISE
		else:
			pose = POSE_RISE
			_move_y()
		return
	if _floor_hit(8):
		_land()
	else:
		pose = POSE_RISE if dy < 2 * 256 else POSE_FALL
		_move_y()


## $8F8C -- crouching.
func _crouch() -> void:
	_apply_vertical(10)
	body_x = 2
	_friction()
	if not _floor_solid(10):
		_step_off()
		return
	if not (pad & DOWN):
		_stand()
		return
	if (hit & A) and _slide_wanted():
		_slide_start()
	elif pad & (LEFT | RIGHT):
		face_left = (pad & LEFT) != 0


## $9036 -- the slide.
##
## He keeps a distance left to travel ($0111:$0112) and spends his speed out of
## it; when it runs out the slide is over.
func _slide() -> void:
	_apply_vertical(8)
	# $9040: a ceiling low enough to make him keep sliding
	var roof: bool = not _ceiling_free(11)
	if face_left:
		vx = _toward(vx, -int(cfg["slide_speed"]), -int(cfg["slide_step"]))
		fall += vx
	else:
		vx = _toward(vx, int(cfg["slide_speed"]), int(cfg["slide_step"]))
		fall -= vx
	if fall < 0:
		if not roof:
			_slide_end()
			return
		fall = int(cfg["slide_retry"])
	elif not (pad & DOWN) and not roof:
		_slide_end()
		return
	dx += vx
	if _move_x(4) and not roof:
		_slide_end()
		return
	if not _floor_solid(5):
		_step_off()


## $912E -- the slide is over: he sheds most of his speed and crouches.
func _slide_end() -> void:
	if not _floor_solid(5):
		_step_off()
		return
	var brake: int = int(cfg["slide_brake"])
	vx = _toward(vx, 0, brake if vx < 0 else -brake)
	_crouch_start()


## $9193 -- the twelve frames after a long fall.
func _landed() -> void:
	_apply_vertical(10)
	body_x = 2
	_friction()
	if not _floor_solid(10):
		_step_off()
		return
	idle -= 1
	if idle <= 0:
		_crouch_start()


# ------------------------------------------------------------- the pieces

## $A08D -- what the direction keys do.
##
## Right and left each have three cases, and the case is chosen by the whole
## pixels of the speed he already has: from a stop he gains half a pixel a
## frame up to one, and coming down from something faster he loses it slowly.
func _a08d() -> bool:
	body_x = 42 if (state & 1) else 1
	var speed: int = int(cfg["walk_speed"])
	if pad & RIGHT:
		face_left = false
		var hi: int = vx >> 8
		var step_size: int = int(cfg["walk_step"])
		if hi >= 4:
			step_size = int(cfg["brake_fast"])
		elif hi >= 2:
			step_size = int(cfg["brake_slow"])
		return _accelerate(speed, step_size)
	if pad & LEFT:
		face_left = true
		var hi: int = (vx >> 8) & 0xFF
		var step_size: int = -int(cfg["walk_step"])
		if vx < 0 and hi <= 0xFB:
			step_size = -int(cfg["brake_fast"])
		elif vx < 0 and hi <= 0xFE:
			step_size = -int(cfg["brake_slow"])
		return _accelerate(-speed, step_size)
	return _friction()


## $A06D -- nothing held: half a pixel a frame towards a stop.
func _friction() -> bool:
	var step_size: int = int(cfg["friction"]) if vx >= 0 else -int(cfg["friction"])
	return _accelerate(0, step_size)


func _accelerate(limit: int, step_size: int) -> bool:
	vx = _toward(vx, limit, step_size)
	dx += vx
	return _move_x(body_x)


## $B23A -- walk a value towards a limit and stop there.
static func _toward(value: int, limit: int, step_size: int) -> int:
	value += step_size
	if step_size > 0:
		if value > limit:
			value = limit
	elif value < limit:
		value = limit
	return value


## $91EF -- weight, and the extra weight of letting the button go.
func _gravity() -> void:
	vy += int(cfg["gravity"])
	if vy < 0 and not (pad & A):
		vy += int(cfg["gravity_released"])
	if vy > int(cfg["fall_max"]):
		vy = int(cfg["fall_max"])
	dy += vy
	fall += vy


func _jump_wanted() -> bool:
	if state & 0x80:
		return false
	if not (hit & A):
		return false
	return _ceiling_free(0)


## $9FE2
func _jump() -> void:
	vy = int(cfg["jump_speed"])
	pose = POSE_RISE
	fall = 0
	state = 0x01
	sub = SUB_AIR


## $9FDB -- walking off a ledge is a very small jump.
func _step_off() -> void:
	vy = int(cfg["step_off_speed"])
	pose = POSE_RISE
	fall = 0
	state = 0x01
	sub = SUB_AIR


## $9423 -- landing.
##
## His feet are put on the last row of the sixteen pixel cell he came down in
## ($9ED2 through the table at $AFD7), which is what makes a landing land on
## the floor and not a fraction of a pixel above it.
func _land() -> void:
	var px: int = y >> 8
	y = (px + int(cfg["snap_down"][px & 0x0F])) << 8
	vy = 0
	if fall >= int(cfg["hard_landing"]) << 8:
		pose = POSE_CROUCH
		idle = 12
		state = 0x08
		sub = SUB_LANDED
	else:
		_stand()


## $8EB0
func _stand() -> void:
	pose = POSE_STAND
	idle = 0
	state = 0
	sub = SUB_GROUND


## $8F80
func _crouch_start() -> void:
	pose = POSE_CROUCH
	state = 0x08
	sub = SUB_CROUCH


func _slide_wanted() -> bool:
	# $8FCA: there has to be room in front of him for the sliding body
	return not _wall(-8 if face_left else 7, 4)


## $8FEC
func _slide_start() -> void:
	pose = POSE_SLIDE
	state = 0x10
	sub = SUB_SLIDE
	fall = int(cfg["slide_distance"][0])
	vx = int(cfg["slide_start"][1 if face_left else 0])


func _animate() -> void:
	anim_t += 1
	if anim_t >= 10:
		anim_t = 0
		anim_f = (anim_f + 1) % 4
	pose = WALK_POSES[anim_f]


# ------------------------------------------------------------- the ground

## $ACBA -- can he move sideways this frame?  Nothing moves if he cannot.
func _move_x(pose_index: int) -> bool:
	if dx == 0:
		return false
	if _wall((dx + (x & 0xFF)) >> 8, pose_index):
		vx = 0
		return true
	x += dx
	return false


## $ACD5 -- is there a wall this many whole pixels to the side of him?
##
## The screen is a wall too: the console never lets him past its sixteenth
## column or its two hundred and forty first, which is what keeps him in view.
func _wall(step_px: int, pose_index: int) -> bool:
	var desc: Array = _desc(pose_index)
	var edge: int
	if step_px < 0:
		if (x >> 8) < int(cfg["screen_left"]):
			return true
		edge = step_px - desc[0] - 1
	else:
		if (x >> 8) >= int(cfg["screen_right"]):
			return true
		edge = step_px + desc[0]
	for i in range(1, desc.size()):
		if i > 1 and desc[i] == 0:
			break
		if _solid(edge, desc[i]):
			return true
	return false


## $A036 -- move him up or down by what this frame asked for.
func _apply_vertical(pose_index: int) -> void:
	if dy == 0:
		vy = 0
		return
	if dy < 0:
		if _ceiling_hit(pose_index + 1):
			vy = 0
			return
	elif _floor_hit(pose_index):
		vy = 0
		return
	_move_y()


func _move_y() -> void:
	y += dy


func _desc(i: int) -> Array:
	return body[body_index[i]]


## $AE2A -- is there floor under the step he is about to take?
func _floor_hit(pose_index: int) -> bool:
	var desc: Array = _desc(pose_index)
	var row: int = ((dy + (y & 0xFF)) >> 8) + desc[0]
	return _solid(desc[1], row) or _solid(desc[2], row)


func _floor_solid(pose_index: int) -> bool:
	var desc: Array = _desc(pose_index)
	return _solid(desc[1], desc[0]) or _solid(desc[2], desc[0])


## $AD9E
func _ceiling_hit(pose_index: int) -> bool:
	var desc: Array = _desc(pose_index)
	var row: int = ((dy + (y & 0xFF)) >> 8) + desc[0]
	return _solid(desc[1], row) or _solid(desc[2], row)


func _ceiling_free(pose_index: int) -> bool:
	var desc: Array = _desc(pose_index)
	return not (_solid(desc[1], desc[0]) or _solid(desc[2], desc[0]))


## $AC35 -- what is the ground made of, this far from him?
func _class_byte(sx: int, sy: int) -> int:
	if sx < 0 or sx > 0xFF:
		return 0x80
	var top: int = int(cfg["view_top"])
	if not lvl.vertical:
		sy = clampi(sy, top, int(cfg["view_bottom"]) - 1)
	var mx: int = cam + sx
	var my: int = sy - top
	return lvl.class_byte(mx, my)


func _solid(off_x: int, off_y: int) -> bool:
	return _class_byte((x >> 8) + off_x, (y >> 8) + off_y) & 0x80 != 0
