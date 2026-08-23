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
var anims: Dictionary
var anim_index: Array
var weapon_anim: Array

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
## $0111:$0112:$0113.  One counter with three jobs, as on the cartridge: how
## far the current fall has gone, how much of a slide is left, and -- in its
## bottom byte alone -- how long he has been standing still.
var fall := 0
var anim_id := 1                # which little script is running
var anim_i := 0                 # where it is in it
var anim_t := 0                 # frames left on this pose
var weapon := 0
var shots := 0                  # his own shots still in the air
var limit := 0                  # $99: one more than that many is too many
var cam := 0                    # where the level is, in pixels
## Which body the sideways check uses; $A095 swaps it while he is off the
## ground, and the crouch and the slide name their own.
var body_x := 1
var pad := 0
var hit := 0
## $05A2 -- how much of a movement survives what he is standing in: bit 6
## takes half of it and bit 7 takes half again.
var scale := 0
## $9A -- which suit he is wearing; one of them wades as if the water were
## not there.
var suit := 0
var dead := false
var sunk := false               # $0668 bit 6
## What the last check of the ground answered: $01 is the map, which he is set
## down onto squarely, and $81 is mud, which holds him wherever he is.
var floor_kind := 0
## Which of the things standing in the level he came down on ($0115).
var floor_obj := 0
## $0110 -- the frames, counted.  In water and mud the animations only move
## on every other one of them.
var ticks := 0
## $011F..$015F -- the boxes of whatever objects are solid to him this frame,
## each one left, right, top and bottom in the screen's own numbers.  Э3 fills
## these from the objects themselves; until then the race feeds them in.
var solids: Array = []
## $0668 as the level left it before his own update ran: bit 7 a ceiling, bit 6
## a floor, bit 5 a wall to his left, bit 4 one to his right.  A boss room sets
## all four and he cannot move at all.
var held := 0
## $94 -- how far the view slid this frame, which is taken off him before
## anything else ($D34D).
var shift := 0
## $063C and $0652 -- how far a moving floor is carrying him this frame.
var push_x := 0
var push_y := 0


func _init(level: Pb2Level) -> void:
	lvl = level
	cfg = Nes._load_json("%s/pb2/player.json" % Nes.DATA)
	body = cfg["body"]
	body_index = cfg["body_index"]
	anims = cfg["anims"]
	anim_index = cfg["anim_index"]
	weapon_anim = cfg["weapon_anim"]


func place(sx: int, sy: int, camera: int) -> void:
	x = sx << 8
	y = sy << 8
	cam = camera


# ---------------------------------------------------------------- the frame

func step(buttons: int, pressed: int, camera: int,
		shots_out: int = 0, shot_limit: int = 0) -> void:
	pad = buttons
	hit = pressed
	shots = shots_out
	limit = shot_limit
	dx = 0
	dy = 0
	scale = 0
	# $8E49 clears it at the end of every update, so what the mud says about
	# him is said afresh each frame -- on top of whatever the level says.
	sunk = (held & 0x40) != 0
	ticks = (ticks + 1) & 0xFF          # $8E1A
	# $D34D runs before his update: the objects are kept in the camera's frame
	# of reference, so when the view slides everything in it slides the other
	# way.  He runs against the edge of the screen and stops moving across it
	# -- the world moves.  How far the view slid is $94, which the cartridge
	# hands us; the camera itself is only wanted for reading the map.
	if lvl.vertical:
		y -= shift << 8
	else:
		x -= shift << 8
	cam = camera
	_terrain()
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
	_carry(0x18)
	_a1c2()
	if state & 0x80:
		state = 0x80
		body_x = 1
		_friction()
		_ground_exits()
		return
	if pad & (LEFT | RIGHT):
		fall &= ~0xFF
		if _a08d():
			_set_pose(POSE_STAND)
		else:
			if not (state & 0x02):
				state = 0x02
				_anim_start(1)
			_anim_step(1)
	else:
		fall = (fall & ~0xFF) | ((fall - 1) & 0xFF)
		var t: int = fall & 0xFF
		_set_pose(POSE_IDLE if t >= 0x70 and t < 0x80 else POSE_STAND)
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
	if state & 0x80:
		return                             # $8F5A -- no jumping while swinging
	if _jump_wanted():
		_jump()
	elif pad & DOWN:
		_crouch_start()


## $91B5 -- in the air.
func _air() -> void:
	_carry(0x2B)
	_a1c2()
	if state & 0x80:
		dx += vx
		body_x = 1
		_move_x(body_x)
	else:
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
			_set_pose(POSE_RISE)
		else:
			_set_pose(POSE_RISE)
			_move_y()
		return
	if _floor_hit(8):
		_land()
	else:
		_set_pose(POSE_RISE if dy < 2 * 256 else POSE_FALL)
		_move_y()


## $8F8C -- crouching.
func _crouch() -> void:
	_apply_vertical(10)
	_carry(0x1B)
	body_x = 2
	_friction()
	if not _floor_solid(10):
		# $8FE1: crouching he stands a pixel lower, so he is set down that
		# pixel as he leaves the ledge -- and he leaves it at rest, not
		# stepping off it.
		y += 0x100
		_step_off(0)
		return
	_a1c2()
	if state & 0x80:
		if pad & (LEFT | RIGHT):
			face_left = (pad & LEFT) != 0
		return
	# $8FB0: he only straightens up if there is room over his head.
	if not (pad & DOWN) and _ceiling_free(11):
		_stand()
		return
	# $8FC5: there is no sliding in mud.
	if (hit & A) and not (scale & 0x80) and _slide_wanted():
		_slide_start()
	elif pad & (LEFT | RIGHT):
		face_left = (pad & LEFT) != 0


## $9036 -- the slide.
##
## He keeps a distance left to travel ($0111:$0112) and spends his speed out of
## it; when it runs out the slide is over.
func _slide() -> void:
	_apply_vertical(8)
	_carry(0x21)
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
	# $90AB: under a ceiling too low to stand up under he can still turn about,
	# and the slide carries him back the other way.
	if (pad & (LEFT | RIGHT)) and roof:
		var about: bool = (pad & RIGHT) == 0
		if about != face_left:
			vy = -vy                    # $B303
			face_left = about
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
	_carry(0x1B)
	body_x = 2
	_friction()
	if not _floor_solid(10):
		_step_off()
		return
	fall = (fall & ~0xFF) | ((fall - 1) & 0xFF)
	if (fall & 0xFF) == 0:
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
	if vy < 0:
		if not (pad & A):
			vy += int(cfg["gravity_released"])
	else:
		# $921B: water holds him back on the way down as well as along
		var cap: int = int(cfg["fall_max"])
		if (scale & 0x40) and suit != 2:
			cap = int(cfg["fall_max_slow"])
		if vy >= cap:
			vy = cap
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
	_set_pose(POSE_RISE)
	fall = 0
	state = 0x01
	sub = SUB_AIR


## $9FDB -- walking off a ledge is a very small jump.
func _step_off(speed: int = 0x7FFFFFFF) -> void:
	vy = int(cfg["step_off_speed"]) if speed == 0x7FFFFFFF else speed
	_set_pose(POSE_RISE)
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
	# $9425: the map puts him down on a line of its own ($9ED2); a thing he
	# has landed on puts him just above itself ($9F72); mud leaves him exactly
	# where it swallowed him to.  In every case the fraction is thrown away.
	if floor_kind == 0x01:
		px += int(cfg["snap_down"][_grid_y(px)])
	elif floor_kind == 0x80 and floor_obj < solids.size():
		px = int(solids[floor_obj][2]) - 1
	y = px << 8
	vy = 0
	if fall >= int(cfg["hard_landing"]) << 8:
		_set_pose(POSE_CROUCH)
		fall = (fall & ~0xFF) | 12
		state = 0x08
		sub = SUB_LANDED
	else:
		_stand()


## $8EB0
func _stand() -> void:
	_set_pose(POSE_STAND)
	fall &= ~0xFF
	state = 0
	sub = SUB_GROUND


## $8F80
func _crouch_start() -> void:
	_set_pose(POSE_CROUCH)
	state = 0x08
	sub = SUB_CROUCH


func _slide_wanted() -> bool:
	# $8FCA: there has to be room in front of him for the sliding body
	return not _wall(-8 if face_left else 7, 4, face_left)


## $8FEC
func _slide_start() -> void:
	_set_pose(POSE_SLIDE)
	state = 0x10
	sub = SUB_SLIDE
	fall = int(cfg["slide_distance"][0])
	vx = int(cfg["slide_start"][1 if face_left else 0])


## $A1C2 -- keep an attack going, or start one when B is pressed.
func _a1c2() -> void:
	if state & 0x80:
		# $A1CE: mud does not slow the swing down, and water only slows it for
		# the suits that water slows -- the opposite way round from his feet.
		var quick: bool = (scale & 0x80) != 0 \
				or ((scale & 0x40) != 0 and suit == 2)
		if _anim_step(int(weapon_anim[weapon]), not quick):
			state &= 0x7F
			anim_t = 1                      # $A1F1
			anim_i = 1
		return
	if not (hit & B):
		return
	if shots > limit:                       # $A3D9
		return
	var w := _a403()
	if w < 0:
		return
	weapon = w
	state |= 0x80
	_anim_start(int(weapon_anim[weapon]))


## $A403 -- which throw this is: what he is doing decides, and where he aims.
func _a403() -> int:
	var s := state
	for bit in range(7):
		if not (s & (1 << bit)):
			continue
		match bit:
			0: return _aim_air()
			1: return _aim_ground()
			2: return 2
			3: return 1
			4: return -1                    # $A4EB -- this suit cannot throw
			5: return _aim_ground()         # suit weapons wait for E3
			6: return _aim_ground()
	return _aim_ground()


func _aim_ground() -> int:                  # $A421
	if not (pad & UP):
		return 0
	return 5 if pad & (LEFT | RIGHT) else 3


func _aim_air() -> int:                     # $A448
	if not (pad & (UP | DOWN)):
		return 0
	if pad & UP:
		return 5 if pad & (LEFT | RIGHT) else 3
	return 6 if pad & (LEFT | RIGHT) else 4


## $9E44 -- a pose only sticks if he is not in the middle of a swing.
func _set_pose(p: int) -> void:
	if not (state & 0x80):
		pose = p


## $B017 -- start a little animation script from its first pose.
func _anim_start(id: int) -> void:
	anim_id = id
	anim_i = 0
	_advance()


## $B01F -- one tick of it; true when the script says it is over.
func _anim_step(id: int, gated: bool = true) -> bool:
	anim_id = id
	# $B01F: what slows him down slows the picture of him with it
	if gated and scale != 0 and not ((scale & 0x40) and suit == 2):
		if (ticks & 1) == 0:
			return false
	anim_t -= 1
	if anim_t > 0:
		return false
	return _advance()


func _advance() -> bool:
	var script: Array = anims[anim_index[anim_id]]
	var i: int = anim_i + 1
	var v: int = int(script[i]) if i < script.size() else 0xFE
	if v >= 0xFD:
		if v == 0xFD:
			pose = int(script[i + 1])
			return true
		if v == 0xFE:
			return true
		i = 1
		v = int(script[1])
	pose = v
	anim_i = i
	anim_t = int(script[0])
	return false


# ------------------------------------------------------------- the ground

## $ACBA -- can he move sideways this frame?  Nothing moves if he cannot.
func _move_x(pose_index: int) -> bool:
	if dx == 0:
		return false
	# $ACBA reaches as far as the frame asked for, not as far as the water
	# will let him go: what slows him down is taken off only at $B16D, where
	# the step is actually made.
	if _wall((dx + (x & 0xFF)) >> 8, pose_index, dx < 0):
		vx = 0
		return true
	x += _scaled(dx)
	return false


## $ACD5 -- is there a wall this many whole pixels to the side of him?
##
## The screen is a wall too: the console never lets him past its sixteenth
## column or its two hundred and forty first, which is what keeps him in view.
func _wall(step_px: int, pose_index: int, left: bool) -> bool:
	return _wall_class(step_px, pose_index, left) != 0


## What is beside him: nothing, the map ($01), a thing standing in the level
## ($80), what the level itself holds him against ($81), or the edge of the
## screen ($82).
## Which way he is going is the sign of what he was asked to move ($ACD7 reads
## the high byte of it), not the sign of what is left after his own fraction is
## added in -- half a pixel to the left still looks to the left.
func _wall_class(step_px: int, pose_index: int, left: bool) -> int:
	var desc: Array = _desc(pose_index)
	var edge: int
	if left:
		if held & 0x20:                     # $ACDA
			return 0x81
		if (x >> 8) < int(cfg["screen_left"]):
			return 0x82
		edge = step_px - desc[0] - 1
	else:
		if held & 0x10:                     # $AD0B
			return 0x81
		if (x >> 8) >= int(cfg["screen_right"]):
			return 0x82
		edge = step_px + desc[0]
	# $AD2C and $AD5E: the map for every point of him, and only then the things
	# standing in the level.
	for i in range(1, desc.size()):
		if i > 1 and desc[i] == 0:
			break
		if _class_byte((x >> 8) + edge, (y >> 8) + desc[i]) & 0x80:
			return 0x01
	for i in range(1, desc.size()):
		if i > 1 and desc[i] == 0:
			break
		if _object_at((x >> 8) + edge, (y >> 8) + desc[i]) >= 0:
			return 0x80
	return 0x00


## $A126 -- a floor that moves takes him with it.
##
## He goes only as far as there is room for: a wall of the map stops him, but
## the thing carrying him is not in his way, and neither is anything else
## standing in the level.
func _carry(i: int) -> void:
	if push_x != 0:
		var c: int = _wall_class(push_x, i, push_x < 0)
		if c == 0x00 or c == 0x80:
			x += push_x << 8
	if push_y == 0:
		return
	var v: int
	if push_y > 0:
		v = _floor_class(i + 1, push_y + _desc(i + 1)[0])
	else:
		v = _ceiling_class(i + 2, push_y + _desc(i + 2)[0])
	if v == 0x00 or v == 0x80:
		y += push_y << 8


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
	y += _scaled(dy)


func _desc(i: int) -> Array:
	return body[body_index[i]]


## $AE2A -- what is under him at this row: nothing, the map, something
## standing in the level, or mud that holds him wherever it swallowed him to.
func _floor_class(pose_index: int, row: int) -> int:
	# $AE38: mud holds him up whatever the map underneath says.
	if sunk:
		return 0x81
	var desc: Array = _desc(pose_index)
	# $AE55 and $AE62: the map first, for both feet, and only then the things
	# standing in the level.
	var left: int = _class_byte((x >> 8) + desc[1], (y >> 8) + row)
	if left & 0x80:
		return 0x01
	var right: int = _class_byte((x >> 8) + desc[2], (y >> 8) + row)
	if right & 0x80:
		return 0x01
	# $AE69: a ladder holds him up at its top rung and nowhere else -- his feet
	# have to be in the near half of its cell, and there has to be nothing in
	# the cell above it.
	if left == 0x01 or right == 0x01:
		var rung: int = desc[1] if left == 0x01 else desc[2]
		if _grid_y((y >> 8) + row) < 8 \
				and _class_byte((x >> 8) + rung, (y >> 8) + row - 0x10) == 0:
			return 0x01
	for i in [1, 2]:
		var n: int = _object_at((x >> 8) + desc[i], (y >> 8) + row)
		if n >= 0:
			floor_obj = n
			return 0x80
	return 0x00


func _floor_hit(pose_index: int) -> bool:
	var desc: Array = _desc(pose_index)
	var row: int = ((dy + (y & 0xFF)) >> 8) + desc[0]
	floor_kind = _floor_class(pose_index, row)
	return floor_kind != 0


func _floor_solid(pose_index: int) -> bool:
	floor_kind = _floor_class(pose_index, _desc(pose_index)[0])
	return floor_kind != 0


## $AD9E -- what is over him at this row.
func _ceiling_class(pose_index: int, row: int) -> int:
	if held & 0x80:                         # $ADAC
		return 0x81
	var desc: Array = _desc(pose_index)
	if _class_byte((x >> 8) + desc[1], (y >> 8) + row) & 0x80 \
			or _class_byte((x >> 8) + desc[2], (y >> 8) + row) & 0x80:
		return 0x01
	for i in [1, 2]:
		if _object_at((x >> 8) + desc[i], (y >> 8) + row) >= 0:
			return 0x80
	return 0x00


func _ceiling_hit(pose_index: int) -> bool:
	var desc: Array = _desc(pose_index)
	return _ceiling_class(pose_index,
			((dy + (y & 0xFF)) >> 8) + desc[0]) != 0


func _ceiling_free(pose_index: int) -> bool:
	return _ceiling_class(pose_index, _desc(pose_index)[0]) == 0


## $AC35 -- what is the ground made of, this far from him?
func _class_byte(sx: int, sy: int) -> int:
	if sx < 0 or sx > 0xFF:
		return 0x80
	var top: int = int(cfg["view_top"])
	if lvl.vertical:
		# $F52C: the view slides down the map, so the camera is added to the
		# line, in eight bits -- and past the two hundred and twenty fourth
		# line nothing is read at all.
		sy &= 0xFF
		if sy >= 0xE0:
			return 0x00
		return lvl.class_byte(sx, Pb2Level.map_row(cam, sy))
	# $F57E: below the two hundred and twenty fourth line nothing is read at
	# all, and above the top of the view the cache holds the last area's rows,
	# which we have no way of keeping -- so the first row stands in for them.
	if sy >= 0xE0:
		return 0x00
	sy = maxi(sy, top)
	return lvl.class_byte(cam + sx, sy - top)


## $B16D -- water and mud take their share of every movement.
func _scaled(v: int) -> int:
	if scale == 0:
		return v
	# $B174: the wading suit walks through water at its own pace
	if (scale & 0x40) and suit == 2:
		return v
	v >>= 1
	if scale & 0x80:
		v >>= 1
	return v


# ------------------------------------------------------- what he stands in

## $B316 -- what the place he is standing in does to him.
##
## Eight points down his two sides, from under his feet to the top of his head,
## are asked what the level is made of there.  Water slows him and lifts him,
## a moving floor carries him along, deep mud swallows him, and one or two
## things kill him outright.  Which eight points depends on how he is standing.
func _terrain() -> void:
	if sub < 4:
		return
	var set_id: int = int(cfg["probe_set"][pose])
	if set_id == 0:
		return
	var pts: Array = cfg["probes"][cfg["probe_index"][set_id]]
	# The cartridge counts the points up and stores them down, so the first
	# point -- his left foot -- ends up last.
	var p := [0, 0, 0, 0, 0, 0, 0, 0]
	for i in range(8):
		p[7 - i] = _feel(int(pts[i][0]), int(pts[i][1]))

	if p[0] == 2:
		dead = true
		return
	if p[0] == 4:
		scale = 0x40                    # $B394: his head is under water
	if p[1] == 2:
		dead = true
		return
	if p[2] == 4:
		_swim(p)
		return
	if p[2] == 2:
		dead = true
		return
	if p[3] == 4:
		_swim(p)
		return
	if p[3] == 2:
		dead = true
		return
	_b3b6(p)


## $B3B6 -- what is level with his knees, and then what is under his feet.
func _b3b6(p: Array) -> void:
	if p[4] == 2:
		dead = true
		return
	if p[4] == 5:                           # $B401
		if p[5] == 2:
			dead = true
			return
		_belt(1 if p[5] == 6 and _far_side() else 3)
		_b3d2(p)
		return
	if p[4] == 6:                           # $B41C
		if p[5] == 2:
			dead = true
			return
		_belt(3 if p[5] == 5 and _far_side() else 1)
		_b3d2(p)
		return
	if p[5] == 2:
		dead = true
		return
	if p[5] == 5:
		_belt(3)
	elif p[5] == 6:
		_belt(1)
	_b3d2(p)


## $B3D2 -- the two points under his feet: moving floors, and deep mud.
func _b3d2(p: Array) -> void:
	if p[6] == 0x87:                        # $B42D
		_belt(0 if p[7] == 0x88 and _far_side() else 2)
		return
	if p[6] == 0x88:                        # $B43A
		_belt(2 if p[7] == 0x87 and _far_side() else 0)
		return
	if p[6] == 3:
		_mud(p[7])
		return
	if p[7] == 0x88:
		_belt(0)
	elif p[7] == 0x87:
		_belt(2)
	elif p[7] == 3:
		_mud(p[6])


## $ABA6 and $F42C -- what the level is made of at a point beside him.
func _feel(ox: int, oy: int) -> int:
	var sx: int = (x >> 8) + ox
	var sy: int = (y >> 8) + oy
	if not lvl.vertical:
		sy = clampi(sy, 0x10, 0xAF)
	# $B34A: a few areas have a line across them -- water below it, or a fall
	# that kills -- and there the map underneath does not matter.
	match lvl.kind:
		8:
			if lvl.line + 0x1F >= sy:
				return 2
		0x0A:
			if sy < 0x98 and sy >= lvl.line:
				return 4
		6:
			if sy - 4 >= lvl.line:
				return 2
	if lvl.vertical:
		return lvl.terrain_at(sx, Pb2Level.map_row(cam, sy & 0xFF))
	return lvl.terrain_at(cam + sx, sy - int(cfg["view_top"]))


## $AFC1 -- where in its sixteen pixel cell a line of the screen falls.
##
## In a level that scrolls downwards his own line means nothing on its own: the
## cells are the map's and the map has slid past him, so the camera goes in too.
func _grid_y(v: int) -> int:
	if lvl.vertical:
		v += cam & 0xFF
	return v & 0x0F


## $B4A0 -- which half of a sixteen pixel cell he is standing in, which is how
## two different floors under his two feet are settled between them.
func _far_side() -> bool:
	var v: int = (x >> 8) & 0xFF
	if not lvl.vertical:
		v = (v + (cam & 0xFF)) & 0xFF
	return (v & 0x0F) >= 8


## $B47C..$B494 -- a floor that moves carries him with it.
func _belt(which: int) -> void:
	# $B482 and $B494: against his own way the wading suit is not carried
	if (which == 1 or which == 3) and suit == 2:
		return
	dx += int(cfg["belt"][which])


## $B4AF -- water: half of every movement, and a push towards the surface.
func _swim(p: Array) -> void:
	scale = 0x40
	if state & 0x01 and sub != 0x0E:
		var up: Array = cfg["swim_up"]
		vy = _toward(vy, int(cfg["swim_limit"]),
				int(up[0]) if vy < 0 else int(up[1]))
	_b3b6(p)


## $B44E -- deep mud: a quarter of every movement, and it swallows him.
func _mud(other: int) -> void:
	scale = 0x80
	if state & 0x60:
		return
	if other < 0x80:
		if not sunk:
			# $B1AA: the sinking is not slowed by what does the sinking
			y += int(cfg["sink"])
		if ((y >> 8) & 0xFF) >= int(cfg["drown_y"]):
			dead = true
			return
	sunk = true


func _solid(off_x: int, off_y: int) -> bool:
	var sx: int = (x >> 8) + off_x
	var sy: int = (y >> 8) + off_y
	if _class_byte(sx, sy) & 0x80:
		return true
	return _object_at(sx, sy) >= 0


## $AC5C -- a thing standing in the level is as good as a wall.
##
## The point is pushed to the edge of the screen before it is compared, the way
## the cartridge does it: anything off to the left counts as column zero and
## anything off to the right as column two hundred and fifty five.  Answers
## which thing it was, or minus one.
func _object_at(sx: int, sy: int) -> int:
	if solids.is_empty():
		return -1
	sx = 0 if sx < 0 else (0xFF if sx > 0xFF else sx)
	sy = 0 if sy < 0 else (0xFF if sy > 0xFF else sy)
	# $ACB4 counts down, so the last of them is met first.
	for i in range(solids.size() - 1, -1, -1):
		var b: Array = solids[i]
		if sx >= int(b[0]) and sx <= int(b[1]) \
				and sy >= int(b[2]) and sy <= int(b[3]):
			return i
	return -1
