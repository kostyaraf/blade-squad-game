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
const SUB_FLY := 12
const SUB_SWIM := 14
const SUB_WALL := 20
const SUB_ROOF := 22
const SUB_ROOF_ON := 24
const SUB_HANG := 25
const SUB_ROOF_OVER := 26
const SUB_HAUL := 27
const SUB_HAUL_CARRIED := 28
const SUB_LADDER := 16
const SUB_LADDER_ON := 17
const SUB_LADDER_OFF := 18
const SUB_LADDER_MID := 19

const POSE_STAND := 0x11
const POSE_IDLE := 0x12
const POSE_CROUCH := 0x09
const POSE_SLIDE := 0x0D
const POSE_RISE := 0x18
const POSE_FALL := 0x19
const WALK_POSES := [0x06, 0x07, 0x08, 0x05]

## PB3 accepts Down+Jump on the same tick; native cartridge input is unchanged.
var combo_slide := false

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
## $54 -- how many frames the button has been held, counted up by $D23A once
## every fourth picture and never past the world's own ceiling.
var charge := 0
## The table of things.  While it is there he takes his own places in it and
## what he throws is really thrown; without it the harness tells him instead
## how many of his throws are still in the air.
var world = null
var cam := 0                    # where the level is, in pixels
## Which body the sideways check uses; $A095 swaps it while he is off the
## ground, and the crouch and the slide name their own.
var body_x := 1
var pad := 0
var hit := 0
## $05A2 -- how much of a movement survives what he is standing in: bit 6
## takes half of it and bit 7 takes half again.
var scale := 0
## $05A2 as the things left it, for a stand that has no table of things.
var grip := 0
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
## The other way, which Power Blade 2 never needs: an area of that game slides
## one way only, so $94 is enough for it.  A Solbrain stage slides both ways at
## once, and the PB3 mode puts the second slide here.  In both games on their
## own this stays nought and nothing changes.
var shift_y := 0
## $063C and $0652 -- how far a moving floor is carrying him this frame.
var push_x := 0
var push_y := 0
## $0116 -- he has hold of something and the level is told not to move him.
var cling := 0
## Foreign terrain damage found by the normal eight body probes.
var touched_sol_hazard := false
## $0C..$0F -- what the two side probes of $9720 last answered, and which
## thing standing in the level each of them found.
var hold_a := 0
var hold_a_n := 0
var hold_b := 0
var hold_b_n := 0
## What $9A29 answered when it was asked and did not take hold: $01 nothing
## was tried, $80 there is floor under his feet, $00 there was nothing to take.
var grab_kind := 0


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
	touched_sol_hazard = false
	# $05A2 is his own cell, and $8E49 wipes it at the end of every update, so
	# what the mud says about him is said afresh each frame.  But the things
	# take their turn before he does ($CF1C before $CF20), and one of them --
	# $21, which lies still and holds ($90F8) -- writes the divisor into that
	# cell before his step begins.  What it left there is his to keep, and the
	# level puts its own word on top of it.
	scale = world.slots[0][Pb2Objects.F_HOLD] if world != null else grip
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
	# Nought in both games on their own; see `shift_y`.
	y -= shift_y << 8
	cam = camera
	_terrain()
	match sub:
		SUB_GROUND: _ground()
		SUB_AIR: _air()
		SUB_CROUCH: _crouch()
		SUB_SLIDE: _slide()
		SUB_LANDED: _landed()
		SUB_FLY: _fly()
		SUB_SWIM: _paddle()
		SUB_LADDER: _ladder()
		SUB_LADDER_ON: _ladder_on()
		SUB_LADDER_OFF: _ladder_off()
		SUB_LADDER_MID: _ladder_mid()
		SUB_WALL: _climb()
		SUB_ROOF: _roof()
		SUB_ROOF_ON: _roof_on()
		SUB_HANG: _hang()
		SUB_ROOF_OVER: _roof_over()
		SUB_HAUL: _haul(false)
		SUB_HAUL_CARRIED: _haul(true)
		_: _ground()
	# $8E49 -- and the cell is wiped, so that the next thing to write into it
	# writes into an empty one.
	if world != null:
		world.slots[0][Pb2Objects.F_HOLD] = 0


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
	# $8F33: up, under something, is neither a jump nor a crouch -- he stays
	# where he is, or falls if the ground has gone.
	if (pad & UP) and _head_kind(0) != 0:
		if not _floor_solid(8):
			_step_off()
		return
	# $8F43: suit one reaches behind him for a lip to hang from
	if _ledge_grab():
		return
	if grab_kind == 0x00:
		_step_off()
		return
	if grab_kind == 0x01 and not _floor_solid(8):
		_step_off()
		return
	if state & 0x80:
		return                             # $8F5A -- no jumping while swinging
	if pad & UP:
		# $8F62: with up held the jump is all that is left
		if hit & A:
			_jump()
		return
	if combo_slide and (pad & DOWN) and (hit & A) and _slide_wanted():
		_crouch_start()
		_slide_start()
	elif _jump_wanted():
		_jump()
	elif pad & DOWN:
		# $8F77: down over a ladder takes the ladder, not a crouch.
		if not _ladder_grab():
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
		if _suit_air(true):
			return
		if _ceiling_hit(3):
			vy = 0
			y &= ~0xFF                     # $92BD: the fraction is dropped
			_set_pose(POSE_RISE)
			return
		_set_pose(POSE_RISE)
	elif _floor_hit(8):
		_land()
		return
	else:
		if _suit_air(false):
			return
		_set_pose(POSE_RISE if dy < 2 * 256 else POSE_FALL)
	# $93B9: up, in mid air, with a ladder level with his chest -- he catches
	# hold of it where he is, and the movement he had begun is never made.
	if not (state & 0x80) and (pad & UP) \
			and _class_byte(x >> 8, (y >> 8) + int(cfg["ladder_air"])) == 0x01:
		_ladder_hold()
		return
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
	# $8FBA: crouched over a ladder, down takes the ladder.
	if pad & DOWN:
		if _ladder_grab():
			return
	# $8FB0: he only straightens up if there is room over his head.
	elif _ceiling_free(11):
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
	# $90D3: the wall check and the movement are one call here, as they are
	# at $A056; which body the ground is then read with depends on it.
	var stopped: bool = _move_x(4)
	if stopped and not roof:
		_slide_end()
		return
	# $90E2 and $90F7: suit one grabs a wall in front of him, or a lip behind
	if _slide_reach():
		return
	if _ledge_grab():
		return
	if not _floor_solid(8 if stopped else 5):
		_slide_off()


## $9107 -- the slide runs off a ledge.
##
## What made him slide was something low over his head, and standing up under it
## would leave him inside it.  So before he steps off he is put down eight
## pixels, and then set on the line the cell he is in gives him -- against the
## bottom of what is over him if that is a thing standing in the level, and on
## the far side of the cell if it is the map.
func _slide_off() -> void:
	var v: int = _ceiling_class(11, _desc(11)[0])
	if v != 0:
		y += 8 << 8
		var head: int = ((y >> 8) - 36) & 0xFF
		if v == 0x01:
			y += int(cfg["snap_stand"][_grid_y(head)]) << 8
		elif v == 0x80 and floor_obj < solids.size():
			var d: int = (int(solids[floor_obj][3]) - head) & 0xFF
			y += (d - 0x100 if d >= 0x80 else d) << 8
	_step_off()


## $912E -- the slide is over: he sheds most of his speed and crouches.
func _slide_end() -> void:
	if _slide_reach():
		return
	if _ledge_grab():
		return
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


# --------------------------------------------------------------- the suits
#
# Three of the four Power Suits have a way of being in the air that is not his
# own: two swims, three flies, one takes hold of walls.  The air step asks for
# them at $927A (going up) and $9315 (coming down), and what they turn into is
# a handler number of its own, dispatched from the same table at $8E66.

## $927A and $9315 -- what the suit he has on does in mid air.
##
## True when it has taken the frame over: either he has gone into a state of
## its own, or there was ground close under him after all and he was simply
## moved down onto it and left there ($941F).
func _suit_air(rising: bool) -> bool:
	if state & 0x80:
		return false                    # $9271 and $9306: not mid swing
	if (y >> 8) < 0x28:
		return false                    # $9273 and $930E: not near the top
	if suit == 1 and (pad & A):
		# $927F and $931A: suit one reaches for whatever is around him
		if rising:
			_set_pose(POSE_RISE)
		if _floor_solid(0x0D):
			_move_y()                   # $941F
			return true
		var over: int = _head_kind(0x0C)
		if over == 0x00:
			if not rising:
				# $9332: only now is the falling picture of him chosen
				_set_pose(POSE_RISE if (dy >> 8) < 2 else POSE_FALL)
			_air_grab()                 # $938D
			return true
		if over < 0x81:
			# $92D3: a ceiling within reach, and he takes hold of it
			if over == 0x01:
				_snap_head(0xE0)
			else:
				_snap_head_obj(0xE0)
			Pb2Sound.want(0x3A)         # $92E8 -- he has it
			_shove_side()
			_roof_start()
			return true
		if not rising:
			_move_y()                   # $932F
			return true
		# $92BD: coming up under the edge of the world he only bumps his head
		vy = 0
		y &= ~0xFF
		_set_pose(POSE_RISE)
		return true
	if rising or (scale & 0x40):
		# $929E and $9348: swimming, and only in water
		if suit != 2 or not (scale & 0x40):
			return false
	elif scale != 0:
		return false                    # $9346: mud is nobody's suit
	elif (dy >> 8) == 0 or suit != 3:
		return false                    # $935E: suit three, once he is falling
	else:
		# $9369: unless there is ground right under him, he takes off
		if _floor_solid(0x0D):
			_move_y()                   # $941F
			return true
		_shove_side()
		_shove_down()
		# $9AF6
		fall &= ~0xFFFF
		_anim_start(6)
		state = 0x01
		sub = SUB_FLY
		return true
	# $92A9 and $9351: into the water, unless there is ground right under him
	if _floor_solid(0x0D):
		_move_y()
		return true
	_shove_side()
	_shove_down()
	# $9CDF
	_anim_start(10)
	state = 0x01
	sub = SUB_SWIM
	return true


## $938D -- a ladder at his chest, or a wall at his side, or neither.
func _air_grab() -> void:
	if _class_byte(x >> 8, (y >> 8) + int(cfg["ladder_air"])) == 0x01:
		if pad & UP:
			_ladder_hold()              # $9491
			return
		_move_y()
		return
	# $93A1: a wall, but not one he is too near the foot of the screen for
	if (pad & (LEFT | RIGHT)) and (y >> 8) < 0xC8 and _grab_wall():
		# $9417 -- the second road to the same noise: out of a slide it is
		# $9182 that asks, here it is $9419, and both say "he caught it".
		Pb2Sound.want(0x3A)
		_wall_start()
		return
	_move_y()


## $9E4D -- before he changes into something wider he is pushed out of a wall.
##
## The map first, for both sides of him, and then the things standing in the
## level; the map moves him to the near line of the cell he is caught in, a
## thing to its own edge.
func _shove_side() -> void:
	var px: int = x >> 8
	var head: int = ((y >> 8) - 0x10) & 0xFF
	if _class_byte(px + 5, head) & 0x80:
		x += int(cfg["snap_right"][_grid_x((px + 5) & 0xFF)]) << 8
		return
	if _class_byte(px - 6, head) & 0x80:
		x += int(cfg["snap_left"][_grid_x((px - 6) & 0xFF)]) << 8
		return
	var n: int = _object_at(px + 5, head)
	if n >= 0:
		x += _byte(int(solids[n][0]) - (px + 5)) << 8
		return
	n = _object_at(px - 6, head)
	if n >= 0:
		x += _byte(int(solids[n][1]) - (px - 6)) << 8


## $9E8C -- and out of a ceiling, the same way.
func _shove_down() -> void:
	var px: int = x >> 8
	var head: int = ((y >> 8) - 0x1C) & 0xFF
	if (_class_byte(px + 5, head) & 0x80) or (_class_byte(px - 6, head) & 0x80):
		y += int(cfg["snap_stand"][_grid_y(head)]) << 8
		return
	var n: int = _object_at(px + 5, head)
	if n < 0:
		n = _object_at(px - 6, head)
	if n >= 0:
		y += _byte(int(solids[n][3]) - head) << 8


## $9B24 and $9D9F -- his feet are set on what stopped them, and he stands up.
func _settle(kind: int) -> void:
	var px: int = y >> 8
	if kind == 0x01:
		px += int(cfg["snap_down"][_grid_y(px)])
	elif kind == 0x80 and floor_obj < solids.size():
		px = int(solids[floor_obj][2]) - 1
	y = px << 8
	vy = 0                              # $B2FA
	_stand()


# --------------------------------------------------------- three, which flies

## $9B0A -- flying.
##
## A is the engine: held, it holds him up, and with left or right it drives him
## along.  Let go, he sinks eight two-hundred-and-fifty-sixths of a pixel a
## frame more each frame.  Anything under his feet ends it.
func _fly() -> void:
	_carry(0x2B)
	# $9B0F: the flying body is wide, and it is the whole of it that lands
	if _floor_solid(0x17):
		_settle(floor_kind)
		return
	if suit != 3 or scale != 0:
		_step_off()                     # $9B36 and $9B3E
		return
	if not (state & 0x80):
		_fly_face()
		# $9B70: still, forwards, or backwards
		var id: int = 6
		var hi: int = (vx >> 8) & 0xFF
		if hi != 0x00 and hi != 0xFF:
			id = 7 if (vx < 0) == face_left else 8
		_anim_step(id)
	_a1c2()
	# $9B95: the engine is heard every twentieth step
	var beat: int = ((fall >> 8) & 0xFF) + 1
	if beat >= int(cfg["fly_beat"]):
		beat = 0
		Pb2Sound.want(0x16)             # $9BA4
	fall = (fall & ~0xFF00) | ((beat & 0xFF) << 8)
	_fly_along()
	body_x = 0x2A
	_move_x(body_x)
	_fly_down()
	# $9C6B: however hard he is pushed he never drops faster than this
	if vy >= int(cfg["fly_fall_max"]):
		vy = int(cfg["fly_fall_max"])
	dy += vy
	_apply_vertical(0x15)


## $9B46 -- which way he is looking.
##
## With B held he simply looks the way he is asked to; without it the direction
## keys only turn him the way he is already going, so that a turn in the air
## costs him the speed first.
func _fly_face() -> void:
	if pad & B:
		if pad & RIGHT:
			face_left = false
		elif pad & LEFT:
			face_left = true
		return
	if pad & RIGHT:
		if vx >= 0:
			face_left = false
	elif pad & LEFT:
		if vx < 0:
			face_left = true


## $9BA9 -- the push along, out of the six records at $9CA7.
func _fly_along() -> void:
	var k: int = -1
	if pad & A:
		if pad & RIGHT:
			k = 0 if vx >= 0 else 4
		elif pad & LEFT:
			k = 1 if vx < 0 else 5
	if k < 0:
		# $9BB6: with nothing asked of him he is only trimmed towards a drift
		if vx < 0:
			k = 3
		elif vx != 0:
			k = 2
		else:
			return                      # $9BC0: standing still, nothing to do
	var rec: Array = cfg["fly_along"][k]
	vx = _toward(vx, int(rec[0]), int(rec[1]))
	dx += vx


## $9BF4 -- the push up or down, out of the eight records at $9CBF.
##
## Two of the paths take the record and the sinking both; the hovering ones
## take the record alone, and holding nothing takes only the sinking.
func _fly_down() -> void:
	var k: int = -1
	var sink: bool = false
	if not (pad & A):
		if pad & DOWN:
			k = 0                       # $9BFF
			sink = true
		else:
			sink = true                 # $9C68
	elif pad & B:
		k = _fly_hover()                # $9C11
	elif pad & UP:
		k = 6 if (vy >= 0 and (vy >> 8) >= 2) else 7
		sink = true                     # $9C4E
	elif pad & DOWN:
		k = 5                           # $9C4A
		sink = true
	else:
		k = _fly_hover()
	if k >= 0:
		var rec: Array = cfg["fly_down"][k]
		vy = _toward(vy, int(rec[0]), int(rec[1]))
	if sink:
		vy += int(cfg["fly_sink"])      # $9C95


## $9C11 -- hovering: the record that answers whichever way he is drifting.
##
## Drifting slowly, one way or the other, he is only nudged on every eighth
## frame -- which is what makes him bob.
func _fly_hover() -> int:
	var hi: int = (vy >> 8) & 0xFF
	if vy >= 0:
		if hi != 0:
			return 1
		fall = (fall & ~0xFF) | ((fall + 1) & 0xFF)
		return 2 if (fall & 0x0F) == 8 else -1
	if hi != 0xFF:
		return 3
	fall = (fall & ~0xFF) | ((fall + 1) & 0xFF)
	return 4 if (fall & 0x0F) == 8 else -1


# ---------------------------------------------------------- two, which swims

## $9CEB -- swimming.
func _paddle() -> void:
	_carry(0x2B)
	if suit != 2:
		_step_off()                     # $9CF6
		return
	if not (scale & 0x40):
		_jump()                         # $9CFE: out of the water and up
		return
	_a1c2()
	if state & 0x80:
		body_x = 1
		_friction()                     # $9D09
		_paddle_vert(-1)
		return
	if pad & RIGHT:
		face_left = false
		_paddle_along(0)
	elif pad & LEFT:
		face_left = true
		_paddle_along(1)
	else:
		body_x = 1
		_friction()                     # $9D19
	# $9D44
	if pad & UP:
		_paddle_vert(0)
	elif pad & DOWN:
		_paddle_vert(1)
	else:
		_paddle_vert(-1)


func _paddle_along(k: int) -> void:
	var rec: Array = cfg["swim_along"][k]
	vx = _toward(vx, int(rec[0]), int(rec[1]))
	dx += vx
	body_x = 0x2A
	_move_x(body_x)


## $9D50 -- up, down, or towards a stop, and then the movement itself.
func _paddle_vert(way: int) -> void:
	var rec: Array
	if way == 0:
		rec = cfg["swim_vert"][0]
	elif way == 1:
		rec = cfg["swim_vert"][1]
	else:
		rec = cfg["swim_slow"][0 if vy >= 0 else 1]
	vy = _toward(vy, int(rec[0]), int(rec[1]))
	dy += vy                            # $B21A
	if dy < 0:
		_apply_vertical(0x15)           # $9D82
	elif _floor_hit(8):
		_settle(floor_kind)             # $9D8F
		return
	else:
		_move_y()                       # $9DAB
	# $9DAE: the picture is turned over whatever the water says
	if not (state & 0x80):
		var hi: int = (vx >> 8) & 0xFF
		_anim_step(10 if (hi == 0x00 or hi == 0xFF) else 9, false)


# ------------------------------------------------- one, which holds on

## $9FBD -- suit one with the button held, which is the whole of its reach.
func _reach() -> bool:
	return suit == 1 and (pad & A) != 0


## $9720 -- what is beside him at his shoulder and at his hip.
##
## Both answers are kept, and which thing standing in the level each of them
## found, because everything suit one does is settled between the two.
func _hold_probe() -> void:
	hold_a = _wall_class(0, 0x10, face_left)
	hold_a_n = floor_obj
	hold_b = _wall_class(0, 0x11, face_left)
	hold_b_n = floor_obj


## $974B -- is there a wall here worth taking hold of?
##
## Both points have to find something, and neither may be what the level itself
## holds him against; then he is pulled square up to it.
func _grab_wall() -> bool:
	_hold_probe()
	if hold_b == 0 or hold_b >= 0x81:
		return false
	if hold_a == 0 or hold_a >= 0x81:
		return false
	if hold_a == 0x80:
		floor_obj = hold_a_n
		_snap_side_obj(0x05, face_left)
	elif hold_b == 0x80:
		floor_obj = hold_b_n
		_snap_side_obj(0x05, face_left)
	else:
		_snap_side(0x05, face_left, true)
	return true


## $9EE6, $9EF0 and the four little routines that pick between them.
##
## He is pushed to one edge of the sixteen pixel cell his side has gone into.
## `to_left` is which edge, and `far` which pair of tables: the pair that puts
## him just clear of the cell, or the pair that puts him hard against it.
func _snap_side(a: int, to_left: bool, far: bool) -> void:
	var d: int = _byte((~a) & 0xFF) if to_left else _byte(a)
	var t: Array
	if far:
		t = cfg["snap_left"] if to_left else cfg["snap_right"]
	else:
		t = cfg["snap_up"] if to_left else cfg["snap_stand"]
	x += int(t[_grid_x(((x >> 8) + d) & 0xFF)]) << 8


## $9F4A and $9F5C -- the same, against the edge of a thing.
func _snap_side_obj(a: int, to_left: bool) -> void:
	if floor_obj >= solids.size():
		return
	var d: int = _byte((~a) & 0xFF) if to_left else _byte(a)
	var edge: int = int(solids[floor_obj][1 if to_left else 0])
	x += _byte(edge - (((x >> 8) + d) & 0xFF)) << 8


## $9F23 -- his head is set on the line of the cell it went into.
func _snap_head(a: int) -> void:
	y += int(cfg["snap_stand"][_grid_y(((y >> 8) + _byte(a)) & 0xFF)]) << 8


## $9EBE -- the same, by the other table, which the turn over a top uses.
func _snap_head_far(a: int) -> void:
	y += int(cfg["snap_left"][_grid_y(((y >> 8) + _byte(a)) & 0xFF)]) << 8


## $9F8A -- or just under the thing it went into.
func _snap_head_obj(a: int) -> void:
	if floor_obj >= solids.size():
		return
	y += _byte(int(solids[floor_obj][3]) - (((y >> 8) + _byte(a)) & 0xFF)) << 8


## $9EC8 -- his feet, on the line the cell gives them.
func _snap_feet(a: int) -> void:
	y += int(cfg["snap_down"][_grid_y(((y >> 8) + _byte(a)) & 0xFF)]) << 8


## $9F74 -- or on top of the thing under them.
func _snap_feet_obj(a: int) -> void:
	if floor_obj >= solids.size():
		return
	y += _byte(int(solids[floor_obj][2]) - (((y >> 8) + _byte(a)) & 0xFF)) << 8


## $9A29 -- from the ground he reaches behind him for a lip to hang from.
##
## True when he has taken hold; otherwise `grab_kind` says why not, because the
## three places that ask go on differently for each answer.
func _ledge_grab() -> bool:
	grab_kind = 0x01
	if not _reach():
		return false
	if _floor_solid(8):
		grab_kind = 0x80
		return false
	grab_kind = 0x00
	if _floor_solid(0x25):
		return false
	# $9A3C: the hand goes out behind him, not in front
	var c: int = _wall_class(0, 0x13, not face_left)
	if c != 0x01 and c != 0x80:
		return false
	y += 16 << 8
	face_left = not face_left
	if c == 0x80:
		_snap_side_obj(0x05, face_left)
	else:
		_snap_side(0x05, face_left, true)
	vx = 0
	vy = 0
	pose = 0x3D
	cling = 1
	fall = (fall & ~0xFF) | 0x0C
	state = 0x20
	sub = SUB_HANG
	return true


## $915A -- and out of a slide, where it is a wall in front of him he catches.
##
## True when it took him, in which case the slide never finishes its frame:
## the cartridge throws the return address away and jumps straight into the
## climbing handler.
func _slide_reach() -> bool:
	if pad & DOWN:
		return false
	if not _reach():
		return false
	if _floor_solid(0x0D):
		return false
	if _head_kind(0x0B) != 0:
		return false
	face_left = not face_left
	y += 10 << 8
	if _grab_wall():
		Pb2Sound.want(0x3A)             # $9182 -- he caught it
		_wall_start()
		return true
	face_left = not face_left
	y -= 10 << 8
	return false


## $9A97 -- hanging where he caught the lip, for twelve frames.
func _hang() -> void:
	_pushed()
	cling = 1
	var px: int = x >> 8
	if _class_byte(px + 5, y >> 8) & 0x80:
		x += int(cfg["snap_right"][_grid_x((px + 5) & 0xFF)]) << 8
	elif _class_byte(px - 6, y >> 8) & 0x80:
		x += int(cfg["snap_left"][_grid_x((px - 6) & 0xFF)]) << 8
	if _floor_solid(8):
		_settle(floor_kind)             # $9AC5
		return
	fall = (fall & ~0xFF) | ((fall - 1) & 0xFF)
	if (fall & 0xFF) != 0:
		return
	# $9ADE: he swings his feet down onto the wall, unless there is floor there
	y += 22 << 8
	if _floor_solid(8):
		y -= 22 << 8
		_step_off()
		return
	_wall_start()


## $977F -- onto the wall, facing it.
func _wall_start() -> void:
	_anim_start(3)
	pose = 0x2F
	vx = 0
	vy = 0
	state = 0x20
	sub = SUB_WALL


## $9797 -- up and down a wall.
##
## The two probes settle it: both hands on it and he climbs either way, only
## his hip and he can go down, only his shoulder and he is at the top and can
## go up over it.
func _climb() -> void:
	_carry(0x26)
	if suit != 1:
		_step_off()
		return
	if (y >> 8) >= 0xD8:
		_step_off()                     # $97AA
		return
	_hold_probe()
	var way: int = 0
	if hold_b != 0 and hold_a != 0:
		# $9815: both of them -- up or down as he asks
		_a1c2()
		if state & 0x80:
			_wall_tail()
			return
		if not (pad & (UP | DOWN)):
			_wall_idle()
			return
		way = 1 if (pad & DOWN) else -1
	elif hold_b != 0:
		# $97B5: only his hip, which is the foot of the wall
		if (y >> 8) >= 0x40:
			_ledge_haul()
			return
		_a1c2()
		if state & 0x80:
			_wall_tail()
			return
		if not (pad & DOWN):
			_wall_idle()
			return
		way = 1
	else:
		if hold_a == 0:
			_step_off()                 # $97D7
			return
		# $97DA: only his shoulder, which is the top of it
		var reach: bool = false
		if hold_a >= 0x80:
			reach = _wall_class(0, 0x2E, face_left) != 0
		if not reach:
			reach = _wall_class(0, 0x0F, face_left) != 0
		if not reach:
			_wall_over()                # $98F2
			return
		_a1c2()
		if state & 0x80:
			_wall_tail()
			return
		if not (pad & UP):
			_wall_idle()
			return
		way = -1
	# $9832: a pixel a frame, up or down
	dy += way << 8
	if dy >= 0:
		if _floor_class(0x27, ((dy + (y & 0xFF)) >> 8) + _desc(0x27)[0]) != 0:
			_step_off()
			return
		_wall_climb()
		return
	var v: int = _head_kind(0x28)
	if v == 0x00:
		if (y >> 8) >= 0x2C:
			_wall_climb()
			return
		_wall_hold()
		return
	if v == 0x82:
		_wall_hold()
		return
	if v == 0x01:
		_snap_head(0xE0)
	elif v == 0x80:
		_snap_head_obj(0xE0)
	# $9875: his head is under a ceiling, and he goes onto it
	_roof_start()
	face_left = not face_left
	pose = 0x25
	anim_t = 0x10
	anim_i = 4


## $9862 -- still on the wall, and nothing has changed about him.
func _wall_hold() -> void:
	_anim_start(3)
	pose = 0x2F
	_wall_tail()


## $988B -- the climb itself.
func _wall_climb() -> void:
	_move_y()
	# $988E: the picture of him is kept inside its eight frames
	if anim_t >= 9:
		anim_t -= 8
	_anim_step(3)
	_wall_tail()


## $98A2 -- hanging on it with nothing asked of him.
func _wall_idle() -> void:
	anim_t = (anim_t - 1) & 0xFF
	if anim_t == 0 or anim_t >= 0x80:
		_anim_start(3)
		pose = 0x2F
		anim_t = 2
	else:
		_apply_vertical(0)
	_wall_tail()


## $98B4 -- and the ways off it: the ground under him, or the button.
func _wall_tail() -> void:
	if _floor_solid(0x29):
		_step_off()
		return
	if state & 0x80:
		return
	if not (hit & A):
		return
	if pad & (LEFT | RIGHT):
		# $98C8: pressed into the wall he is holding, he holds on
		if (pad & 3) == (2 if face_left else 1):
			return
	face_left = not face_left
	if (pad & UP) and _jump_wanted():
		_jump()
	else:
		_step_off()


## $98F2 -- over the top of the wall.
func _wall_over() -> void:
	face_left = not face_left
	if hold_a == 0x80:
		floor_obj = hold_a_n
		_snap_side_obj(0xFC, not face_left)
	else:
		_snap_side(0xFC, not face_left, false)
	y += 4 << 8
	vx = 0
	vy = 0
	_anim_start(5)
	state = 0x40
	sub = SUB_ROOF_OVER


## $9921 -- from the foot of the wall straight into the pull up.
func _ledge_haul() -> void:
	y -= 20 << 8
	if hold_a == 0x80:
		_haul_start(true)
		return
	_snap_feet(0xF0)
	_haul_start(false)


## $99A4 and $99A8 -- he has the lip and begins to pull himself over it.
func _haul_start(carried: bool) -> void:
	sub = SUB_HAUL_CARRIED if carried else SUB_HAUL
	pose = 0x3D
	cling = 1
	fall = (fall & ~0xFF) | 0x0C
	state &= 0x7F


## $99C5 and $99C8 -- twelve frames of pulling, and then he is over.
func _haul(carried: bool) -> void:
	if carried:
		_pushed()
	cling = 1
	fall = (fall & ~0xFF) | ((fall - 1) & 0xFF)
	if (fall & 0xFF) != 0:
		return
	# $99D2: no room to stand up where he is coming out means he comes out
	# sliding instead
	var blocked: bool = _wall_class(0, 0x12, face_left) != 0
	_haul_step()
	if blocked:
		_slide_start()
		return
	_set_pose(POSE_CROUCH)
	fall = (fall & ~0xFF) | 0x0C
	state = 0x08
	sub = SUB_LANDED


## $99FE -- and the step that puts him on top of what he was hanging from.
func _haul_step() -> void:
	x += (-16 if face_left else 16) << 8
	y -= 12 << 8
	if _floor_hit(8):
		if floor_kind == 0x01:
			y += int(cfg["snap_down"][_grid_y(y >> 8)]) << 8
		elif floor_kind == 0x80:
			_snap_feet_obj(0x01)


## $9523 -- onto a ceiling, hanging under it.
func _roof_start() -> void:
	vx = 0
	vy = 0
	_anim_start(0)
	anim_t = 10
	state = 0x40
	sub = SUB_ROOF


## $9537 -- hand over hand along a ceiling.
func _roof() -> void:
	_carry(0x1E)
	if suit != 1:
		_step_off()
		return
	if not lvl.vertical:
		cling = 1                       # $9545
	var v: int = _roof_kind(0x0C)
	if v == 0x82:
		_roof_drop()                    # $9704
		return
	if v == 0x00:
		_roof_end()
		return
	# $95B0
	_a1c2()
	if state & 0x80:
		_roof_tail()
		return
	if pad & RIGHT:
		face_left = false               # $A111
	elif pad & LEFT:
		face_left = true
	if pad & (LEFT | RIGHT):
		_roof_along()
	else:
		_roof_still()


## $955E -- the ceiling has run out over his head.
func _roof_end() -> void:
	# $955E: a ladder there instead, and he steps onto it
	if _class_byte(x >> 8, (y >> 8) + int(cfg["ladder_air"])) == 0x01:
		sub = SUB_LADDER_MID
		_set_pose(POSE_RISE)
		return
	var c: int = _wall_class(0, 0x10, face_left)
	if c == 0x00:
		_roof_drop()
		return
	if c == 0x80:
		_snap_side_obj(0x00, not face_left)
	elif c == 0x01:
		_snap_side(0x00, not face_left, false)
	# $9592: he swings up onto the end of it
	y -= 8 << 8
	vx = 0
	vy = 0
	_anim_start(4)
	state = 0x20
	sub = SUB_ROOF_ON


## $95C4 -- hanging under it with nothing asked of him.
func _roof_still() -> void:
	if scale != 0 and (ticks & 1) != 0:
		_roof_slide()
		return
	if pose == 0x26:
		anim_t = 10
		_roof_slide()
		return
	anim_t = (anim_t - 1) & 0xFF
	if anim_t != 0:
		_roof_slide()
		return
	# $95DB: the shuffle is over, and the frame it ended on settles the next
	var frame: int = anim_i
	_anim_start(0)
	var step_px: int = _cling_step(frame + 7)
	anim_t = 10
	if step_px == 0:
		_roof_slide()
		return
	# $95F1: and it goes on the way he is facing, whatever is held
	_roof_turn(step_px, true)


## $9605 -- and with left or right held, the shuffle itself.
func _roof_along() -> void:
	if scale != 0 and (ticks & 1) == 0:
		_roof_tail()
		return
	_anim_step(0, false)
	var t: int = anim_t
	var step_px: int = 0
	if t == 7:
		anim_t -= 1
		step_px = 1
	elif t == 6:
		step_px = _cling_step(anim_i - 1)
	if step_px == 0:
		# $9634: one pixel, if there is room for it
		_roof_bump(_wall_class(-1 if face_left else 1, 0x0E, face_left))
		return
	_roof_turn(step_px, false)


## $9649 -- the shuffle is made in whichever direction is asked for.
func _roof_turn(step_px: int, by_face: bool) -> void:
	var left: bool = face_left if by_face else (pad & RIGHT) == 0
	if left:
		step_px = -step_px
		face_left = true
	else:
		face_left = false
	dx += step_px << 8
	_roof_bump(_step_kind(0x0E))


## $966B -- and what it ran into.
func _roof_bump(c: int) -> void:
	if c == 0x00:
		x += _scaled(dx)                # $96EF
		_roof_tail()
		return
	if c == 0x01:
		_snap_side(0x05, face_left, false)
	elif c == 0x80:
		_snap_side_obj(0x05, face_left)
	# $9685
	if pad & UP:
		_roof_frame()
		return
	_hold_probe()
	if hold_b != 0:
		if hold_b == 0x82 or hold_a == 0 or hold_a == 0x82:
			_roof_frame()
			return
		_wall_start()                   # $977F
		return
	# $969F: down, and there is a lip under him to swing onto
	if not (pad & DOWN) or not _reach():
		_roof_frame()
		return
	if _wall_class(0, 0x24, face_left) != 0:
		_roof_frame()
		return
	var c2: int = _wall_class(0, 0x14, face_left)
	if c2 == 0x00 or c2 == 0x82:
		_roof_frame()
		return
	if c2 == 0x80:
		_snap_feet_obj(0xF0)
		_haul_start(true)
	else:
		_snap_feet(0xF0)
		_haul_start(false)


## $96D8 -- which picture of him goes with where the shuffle stopped.
func _roof_frame() -> void:
	if pose == 0x25:
		anim_i = 2
	elif pose == 0x27:
		anim_i = 6
	_roof_tail()


## $95FD -- the movement, when nothing has interrupted it.
func _roof_slide() -> void:
	_move_x(0x0E)
	_roof_tail()


## $96F2 -- ground under him, or the button, and he lets go.
func _roof_tail() -> void:
	if _floor_solid(0x29):
		_roof_drop()
		return
	if state & 0x80:
		return
	if hit & A:
		_roof_drop()


## $9704 -- letting go of a ceiling drops him a pixel a frame, not fifty.
func _roof_drop() -> void:
	y += 4 << 8
	_step_off(0x0100)


## $9710 -- how far one shuffle along a ceiling carries him.
##
## The cartridge reads the sixteen bytes at two different offsets, so they are
## kept whole and the offset is given here.
func _cling_step(i: int) -> int:
	var t: Array = cfg["cling_step"]
	if i < 0 or i >= t.size():
		return 0
	return int(t[i])


## $9937 -- the turn off the end of a ceiling onto the wall under it.
func _roof_on() -> void:
	_pushed()
	if not _anim_step(4):
		return
	anim_t = 0x10
	anim_i = 4
	face_left = not face_left
	_grab_wall()
	# $9782
	vx = 0
	vy = 0
	state = 0x20
	sub = SUB_WALL


## $9955 -- and the turn off the top of a wall onto the ceiling over it.
func _roof_over() -> void:
	_pushed()
	if not _anim_step(5):
		return
	face_left = not face_left
	x += (-6 if face_left else 6) << 8
	y -= 8 << 8
	var v: int = _head_kind(0x0C)
	if v == 0x01:
		_snap_head_far(0xE1)
	elif v == 0x80:
		_snap_head_obj(0xE1)
	_roof_start()
	pose = 0x25
	anim_t = 0x10
	anim_i = 4


# ------------------------------------------------------------- the pieces

# ------------------------------------------------------------- the ladder

## $A003 -- he is over a ladder and has asked to go down it.
##
## Both points just under his feet have to be ladder, not one; then he lets go
## of the ground, is set ten pixels down into it, and stands there for eight
## frames before he begins to climb.
func _ladder_grab() -> bool:
	for pt in cfg["ladder_probe"]:
		if _class_byte((x >> 8) + int(pt[0]), (y >> 8) + int(pt[1])) != 0x01:
			return false
	vx = 0
	vy = 0
	y += int(cfg["ladder_mount"])
	fall = (fall & ~0xFF) | int(cfg["ladder_mount_wait"])
	# $A026: the pose is set outright, without asking whether he is swinging.
	pose = int(cfg["ladder_pose"])
	state = 0x04
	sub = SUB_LADDER_ON
	return true


## $9491 -- catching a ladder out of the air: he stops dead where he is.
func _ladder_hold() -> void:
	vx = 0
	vy = 0
	_anim_start(2)
	# $9499 -- bare he catches it in silence; in a suit it clangs.
	if suit != 0:
		Pb2Sound.want(0x3A)             # $949D
	state = 0x04
	sub = SUB_LADDER


## $9F9C -- a ladder is climbed down the middle of it.
##
## Every frame on a ladder he is drawn a pixel towards the centre line of the
## sixteen pixel cell, and once he is on it he stays.
## True while he is still being drawn towards it.
func _ladder_centre() -> bool:
	var v: int = (x >> 8) & 0xFF
	if not lvl.vertical:
		v = (v + (cam & 0xFF)) & 0xFF
	v &= 0x0F
	if v == 8:
		return false
	x += 0x100 if v < 8 else -0x100
	return true


## $948B -- stepping onto a ladder from the side, which suit one does off a
## ceiling: he is walked to the middle of it and only then takes hold.
func _ladder_mid() -> void:
	if _ladder_centre():
		return
	_ladder_hold()


## $945F -- taking hold of the ladder: eight frames, then one step down it.
func _ladder_on() -> void:
	_ladder_centre()
	fall = (fall & ~0xFF) | ((fall - 1) & 0xFF)
	if (fall & 0xFF) != 0:
		return
	y += int(cfg["ladder_step"])
	_anim_start(2)
	sub = SUB_LADDER


## $9477 -- letting go of the top of it: eight frames, then back on his feet.
func _ladder_off() -> void:
	_ladder_centre()
	fall = (fall & ~0xFF) | ((fall - 1) & 0xFF)
	if (fall & 0xFF) != 0:
		return
	y += int(cfg["ladder_off_lift"])
	# $9ED2: and his feet are put on a line of the map, as after a fall.
	y += int(cfg["snap_down"][_grid_y(y >> 8)]) << 8
	_stand()


## $94A9 -- climbing.
##
## Up and down each pick a speed and turn the animation over; with neither held
## he simply hangs there, and the jump button lets go.  Nothing on a ladder
## looks at walls or floors: what stops him is the ladder itself running out.
func _ladder() -> void:
	_ladder_centre()
	_a1c2()
	if state & 0x80:
		vy = 0                              # $94E8 -- a swing holds him still
	elif pad & DOWN:
		var d: Array = cfg["ladder_down"]
		vy = _toward(vy, int(d[0]), int(d[1]))
		_anim_step(2)
	elif pad & UP:
		var u: Array = cfg["ladder_up"]
		vy = _toward(vy, int(u[0]), int(u[1]))
		_anim_step(2)
	elif hit & A:
		_step_off(int(cfg["ladder_jump"]))
		return
	else:
		# $A111: he can still turn to face the way he is shooting.
		if pad & (LEFT | RIGHT):
			face_left = (pad & LEFT) != 0
		vy = 0
	dy += vy
	_move_y()
	# $94F1: no ladder left where his chest is -- he has come off the bottom.
	if _class_byte(x >> 8, (y >> 8) + int(cfg["ladder_hold"])) != 0x01:
		_step_off()
		return
	# $94FF: none left over his head either -- he is at the top and climbs off.
	if _class_byte(x >> 8, (y >> 8) + int(cfg["ladder_top"])) == 0x01:
		return
	vy = 0
	y += int(cfg["ladder_top_lift"])
	fall = (fall & ~0xFF) | int(cfg["ladder_top_wait"])
	pose = int(cfg["ladder_pose"])
	sub = SUB_LADDER_OFF


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


## $9FCB
func _jump_wanted() -> bool:
	if state & 0x80:
		return false
	if not (hit & A):
		return false
	return _ceiling_free(0)


## $AD8D -- what is over him at this body, with nothing added for the frame.
func _head_kind(pose_index: int) -> int:
	return _ceiling_class(pose_index, _desc(pose_index)[0])


## $AD9E -- and the same with the frame's movement added in.
func _roof_kind(pose_index: int) -> int:
	var desc: Array = _desc(pose_index)
	return _ceiling_class(pose_index, ((dy + (y & 0xFF)) >> 8) + desc[0])


## $ACBA -- what is in the way of the sideways movement this frame asks for.
func _step_kind(pose_index: int) -> int:
	return _wall_class((dx + (x & 0xFF)) >> 8, pose_index, dx < 0)


## $A166 -- carried by whatever is carrying him, and nothing asked of the map.
func _pushed() -> void:
	x += push_x << 8
	y += push_y << 8


## $9FE2
func _jump() -> void:
	vy = int(cfg["jump_speed"])
	if combo_slide and lvl is SolAsPb2:
		# PB3 compatibility: one extra gravity step clears Solbrain's
		# 64-pixel risers. Native Nova peaks at 62 pixels and cannot pass.
		vy -= int(cfg["gravity"])
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
		Pb2Sound.want(0x19)             # $9453 -- he came down hard
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
	# $8FFF: a suit slides further and faster, whichever suit it is
	var suited: int = 0 if suit == 0 else 1
	fall = int(cfg["slide_distance"][suited])
	vx = int(cfg["slide_start"][suited * 2 + (1 if face_left else 0)])


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
	try_throw()


## $A1F8 -- the throw itself, once it is settled that he is not already in the
## middle of one.  It is its own entry so that the weapon check can ask him to
## throw without asking him to move.
func try_throw() -> void:
	if not (hit & B):
		return
	# $A3D9 -- a free place, and only if he is under his count.  Without a
	# table of things the harness says how many are out instead.
	var k := -1
	if world != null:
		k = world.free_shot_slot()
		if k < 0:
			return
	elif shots > limit:
		return
	var aim: Array = _a403()
	if aim[1] < 0:                          # $A209 -- this one cannot throw
		return
	weapon = aim[1]
	state |= 0x80
	_anim_start(int(weapon_anim[weapon]))
	if world != null:                       # $A226
		# $05A2 is his own cell and the throw reads it straight ($A358 for the
		# speed water takes off, $A33E for the ceiling, $A3C2 for the beam's
		# life).  The end of every step wipes it ($8E40) and his own movement
		# fills it in again before $A1C2 is reached, so what the table of
		# things last saw is always nought: the live one is his.
		world.slots[0][Pb2Objects.F_HOLD] = scale
		# And his place is his own too.  $A4FD reads $0508 and $04C6 as they
		# stand at that instant, and out of the crouch ($8F8C) he has already
		# been moved -- $A036 down and $A06D along -- before $8FA2 asks for
		# the throw.  A table of things written down at the top of the frame
		# is a picture of where he was, not of where he is.
		world.slots[0][Pb2Objects.F_X] = (x >> 8) & 0xFF
		world.slots[0][Pb2Objects.F_Y] = (y >> 8) & 0xFF
		world.fire(k, aim[0], weapon, world.charge_tier(charge))
	charge = 0                              # $A25A


## $A403 -- which throw this is: what he is doing decides, and where he aims.
##
## Two answers come out of it, and the cartridge keeps them in two registers:
## the way the throw goes (0..7, the compass the tables of $A8BD and $A905 are
## laid out along) and the pose he throws in (0..14, which $A4EE turns into one
## of his little animations).  A pose of minus one means this one cannot throw
## at all.
func _a403() -> Array:
	var s := state
	for bit in range(7):
		if not (s & (1 << bit)):
			continue
		match bit:
			0: return _aim_air()            # $A448
			1: return _aim_ground()         # $A421
			2: return [_side(false), 2]     # $A468
			3: return _aim_crouch()         # $A46C
			4: return [0, -1]               # $A4EB
			5: return _aim_suit()           # $A476
			6: return _aim_hang()           # $A4D0
	return _aim_ground()


## $A43F and $A4C6 -- which of a pair of opposite ways he is looking.  The two
## roads read the same bit the opposite way about, and $A476's road is the one
## that wants `flip`.
func _side(flip: bool) -> int:
	return int(face_left != flip)


func _aim_ground() -> Array:                # $A421
	if not (pad & UP):
		return [_side(false), 0]            # $A43D
	return _aim_up(0)                       # $A427


## $A427 -- up, or up and to one side, out of the pose the caller names.
func _aim_up(pose: int) -> Array:
	if not (pad & (LEFT | RIGHT)):
		return [2, 3]                       # $A438
	return [4 + int(face_left), 5]          # $A42D


func _aim_air() -> Array:                   # $A448
	if not (pad & (UP | DOWN)):
		return [_side(false), 0]            # $A44C
	if pad & UP:
		return _aim_up(0)                   # $A450
	if not (pad & (LEFT | RIGHT)):
		return [3, 4]                       # $A458
	return [6 + int(face_left), 6]          # $A45D


func _aim_crouch() -> Array:                # $A46C
	if pad & (LEFT | RIGHT):
		return [6 + int(face_left), 1]      # $A45F
	return [_side(false), 1]                # $A43F


## $A4D0 -- hanging.  Down and to one side is the only slant it allows.
func _aim_hang() -> Array:
	if not (pad & DOWN):
		return [_side(false), 7]            # $A4E6
	if not (pad & (LEFT | RIGHT)):
		return [3, 8]                       # $A4DC
	return [6 + int(face_left), 12]         # $A4E1


## $A476 -- the eight ways a suit fires.  This road reads the way he looks the
## other way about from every other road, and a slant only comes out when the
## way pressed is not the way the picture of him still points.
func _aim_suit() -> Array:
	if not (pad & (UP | DOWN)):
		return [_side(true), 9]             # $A4C4
	if pad & DOWN:                          # $A47C
		if not (pad & (LEFT | RIGHT)):
			return [3, 11]                  # $A4BF
		if pad & RIGHT:                     # $A4A8
			return [6, 14] if face_left else [3, 11]
		return [3, 11] if face_left else [7, 14]
	if not (pad & (LEFT | RIGHT)):
		return [2, 10]                      # $A49D
	if pad & RIGHT:                         # $A486
		return [4, 13] if face_left else [2, 10]
	return [2, 10] if face_left else [5, 13]


## $D23A -- one more frame of the hold, once every fourth picture and never
## past the ceiling the world he is in sets.  It runs at $CF00, in the level's
## own frame and not in his, so it is counted once for every picture and not
## once for every step of his.
func step_charge(tick: int) -> void:
	if (tick & 0x03) != 0x03:
		return
	if world == null:
		return
	var cap: int = int(world.hold_cap[world.power])
	if charge != cap:
		charge += 1


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
		var n: int = _object_at((x >> 8) + edge, (y >> 8) + desc[i])
		if n >= 0:
			floor_obj = n               # $AD55: the same slot the others use
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


static func _byte(v: int) -> int:
	v &= 0xFF
	return v - 0x100 if v >= 0x80 else v


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
	# $ADCF: over the top of the world there is nothing to read, and the
	# cartridge does not try -- it answers $82, a ceiling, and stops him there.
	# The check is on the whole sixteen-bit line, before the map is asked at
	# all, so it holds for an area of any height.
	if (y >> 8) + row < 0:
		return 0x82
	if _class_byte((x >> 8) + desc[1], (y >> 8) + row) & 0x80 \
			or _class_byte((x >> 8) + desc[2], (y >> 8) + row) & 0x80:
		return 0x01
	for i in [1, 2]:
		# $AE09: which thing it was is written down, the same slot the floor
		# probe uses.
		var n: int = _object_at((x >> 8) + desc[i], (y >> 8) + row)
		if n >= 0:
			floor_obj = n
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
	if lvl is SolAsPb2:
		# Solbrain's floor may lie below PB2's HUD boundary. Query the
		# actual world, including rows above/below the borrowed screen.
		return lvl.class_byte(cam + sx, sy - int(cfg["view_top"]))
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
	if not lvl.vertical and not lvl is SolAsPb2:
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
	if lvl is SolAsPb2 and lvl.hurts_at(cam + sx, sy - int(cfg["view_top"])):
		touched_sol_hazard = true
	return lvl.terrain_at(cam + sx, sy - int(cfg["view_top"]))


## $AFC1 -- where in its sixteen pixel cell a line of the screen falls.
##
## In a level that scrolls downwards his own line means nothing on its own: the
## cells are the map's and the map has slid past him, so the camera goes in too.
func _grid_y(v: int) -> int:
	if lvl is SolAsPb2:
		v += (lvl as SolAsPb2).cam_y - int(cfg["view_top"])
	elif lvl.vertical:
		v += cam & 0xFF
	return v & 0x0F


## $AFCC -- where in its sixteen pixel cell a column of the screen falls.
func _grid_x(v: int) -> int:
	if not lvl.vertical:
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
