class_name Pb2Bosses
extends RefCounted

## The ten bosses.
##
## Each of them is reached through the shell in `pb2_objects.gd`, which keeps
## the states that are the same for all ten -- the wait at the start and the
## death at the end -- and hands the turn over here for the one state in the
## middle that is the boss's own.  From there a boss drives itself on a step
## of its own (`F_SELF`, $05CE), not on the state the shell reads, which is
## why every one of them is a second little state machine.
##
## They do not live together in the cartridge: each is in a bank of its own,
## reached by a far call through $F107 that swaps the bank in and out again.
## Which bank is the only thing that is not the boss's own business, so it is
## left out here.

const F_TYPE := Pb2Objects.F_TYPE
const F_MARK := Pb2Objects.F_MARK
const F_BITS := Pb2Objects.F_BITS
const F_KIND := Pb2Objects.F_KIND
const F_LIFE := Pb2Objects.F_LIFE
const F_YHI := Pb2Objects.F_YHI
const F_Y := Pb2Objects.F_Y
const F_XHI := Pb2Objects.F_XHI
const F_X := Pb2Objects.F_X
const F_VY := Pb2Objects.F_VY
const F_VX := Pb2Objects.F_VX
const F_HOLD := Pb2Objects.F_HOLD
const F_PUSH := Pb2Objects.F_PUSH
const F_ANG := Pb2Objects.F_ANG
const F_REC_BYTE := Pb2Objects.F_REC_BYTE
const F_GROUND := Pb2Objects.F_GROUND
const F_STATE := Pb2Objects.F_STATE
const F_SELF := Pb2Objects.F_SELF
const F_COUNT := Pb2Objects.F_COUNT
const F_KEEP := Pb2Objects.F_KEEP
const F_KEEP2 := Pb2Objects.F_KEEP2
const F_VXFR := Pb2Objects.F_VXFR
const F_VYFR := Pb2Objects.F_VYFR
const F_STUN := Pb2Objects.F_STUN


## $F107 -- which bank holds which boss.  A boss whose mind has not been
## carried over yet is not in here, and the shell then leaves it standing.
const DRIVEN := {0x50: "_turn_50", 0x51: "_turn_51", 0x52: "_turn_52",
		0x53: "_turn_53", 0x54: "_turn_54", 0x55: "_turn_55",
		0x56: "_turn_56", 0x57: "_turn_56", 0x58: "_turn_56",
		0x59: "_turn_56"}


func turn(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	var f = DRIVEN.get(s[F_TYPE])
	if f != null:
		call(f, w, n, s)


# ------------------------------------------------------------------ $50
#
# $BB28 (bank 9) -- the first one, the one with the head on the arm.
#
# Thirteen steps.  It comes awake, walks a little, aims its head and shoots,
# and if the hero is where it can reach him it leaps at him; a leap that lands
# is followed by a rest, and one that does not is followed by a fall.

## $BB67 and $BDC8 and the rest -- the pictures it wears.  $BF is the wait,
## $C0 the head aiming, $C8 the leap, $34 the walk.
const PIC_50_WAIT := 0xBF
const PIC_50_AIM := 0xC0
const PIC_50_LEAP := 0xC8
const ANIM_50_WALK := 0x34

## $BD67 -- three heads, by how far round the arm has swung, and with each of
## them the height the shot leaves at and the two ends of the swing.
const HEAD_50 := [0xC2, 0xC3, 0xC1]
const HEAD_50_DOWN := [0x06, 0xE8, 0xFA]
const HEAD_50_LOW := [0x18, 0x58, 0x3C]
const HEAD_50_HIGH := [0x28, 0x68, 0x44]
## $BDA1 -- what it shoots, and how fast.
const SHOT_50 := 0x48
const SHOT_50_SPEED := 0x12


func _turn_50(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	match s[F_SELF]:
		0: _wake_50(w, s)
		1: _armed_50(s)
		2: _aim_50(w, n, s)
		3: _ready_50(w, s)
		4: _walk_50(w, n, s)
		5: _fall_50(w, n, s)
		6: _rest_50(w, s)
		7: _shoot_50(w, n, s)
		8: _pick_50(w, s)
		9: _leap_50(w, s)
		10: _land_50(w, n, s)
		11: _pause_50(w, s)
		12: _drop_50(w, n, s)


## $BB5A -- two arms are put out first, each a thing of its own that hangs on
## the boss and is told by its step ($05CE) which of the two it is.
func _wake_50(w: Pb2Objects, s: PackedByteArray) -> void:
	for which in [0xE0, 0x60]:
		var k: int = w.free_slot_wide()                # $C86A
		if k < 0:
			continue
		var arm: PackedByteArray = w.slots[k]
		arm[F_TYPE] = 0x4F
		arm[F_SELF] = which
	_wait_50(s, 0x20)
	s[F_SELF] += 1


## $BB7E -- it stands still, and then turns to face the middle of the room.
func _armed_50(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	s[F_COUNT] = 0x08                                  # $BDDA
	s[F_KEEP] = 0x20
	s[F_KEEP2] = 0x01
	_face_middle_50(s)
	s[F_SELF] += 1


## $BB91 -- the aiming and the shooting, which $BD73 does; it says when it is
## done and the walk may begin.
func _aim_50(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	if not _head_50(w, n, s):
		return
	_wait_50(s, 0x0C)
	s[F_SELF] += 1


## $BB9F -- and then it starts walking.
func _ready_50(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	_walk_start_50(w, s)
	s[F_SELF] += 1


## $BBAB -- the walk itself, until a wall stops it.  Then it leans back and
## the leap begins.
func _walk_50(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	w.step_anim(s)                                     # $C8EE
	w.step_both(s)
	if w.walled_either_turn(n, s, 0x10, 0x1C, 0x80) >= 0x80:
		return
	w.set_speed_side_facing(s, 0xFF, 0xA0)             # $C903
	w.set_speed_down(s, 0x01, 0x80)                    # $C909
	s[F_KIND] = PIC_50_LEAP
	s[F_SELF] += 1


## $BBCE -- the leap comes down, and where it lands it stands still a while.
func _fall_50(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	w.add_speed_down(s, 0x20)                          # $C90C
	w.step_both(s)                                     # $C8F1
	if w.walled_either_turn(n, s, 0x10, 0x1C, 0x00) < 0x80:
		return
	w.snap_down_from(s, 0x18)                          # $C984
	_wait_50(s, 0x18)
	s[F_SELF] += 1


## $BBED -- the rest, and then it goes back to aiming.
func _rest_50(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	w.face_hero(s)                                     # $C8FD
	s[F_COUNT] = 0x10                                  # $BDDA
	s[F_KEEP] = 0x40
	s[F_KEEP2] = 0x01
	s[F_SELF] += 1


## $BC00 -- the same aiming again.  The cartridge means to turn towards him
## every eight pictures here, but the byte it tries is the one the jump left
## behind and not the count it read, so the turn never comes; what is written
## down is what it does.
func _shoot_50(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	if not _head_50(w, n, s):
		return
	_wait_50(s, 0x08)
	s[F_SELF] += 1


## $BC1A -- and now it chooses: a leap at him, a leap across the room, or
## another round of aiming.
func _pick_50(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	_face_middle_50(s)                                 # $BDE7
	var hero: PackedByteArray = w.slots[0]
	if w.looking_away(s):                              # $C98D
		_walk_start_50(w, s)
		s[F_SELF] += 1
		return
	# $BC28 -- and he must be on the other half of the room from it.
	if ((hero[F_X] ^ 0x80) & 0x80) != (s[F_X] & 0x80):
		_walk_start_50(w, s)
		s[F_SELF] += 1
		return
	if hero[F_Y] >= 0x60 and hero[F_X] >= 0x40 and hero[F_X] < 0xC0:
		s[F_KIND] = PIC_50_LEAP
		w.set_speed_side_facing(s, 0xFF, 0x00)
		w.set_speed_down(s, 0xFA, 0x00)
		s[F_SELF] = 0x0A
		return
	w.turn(s)                                          # $C918
	_leap_across_50(w, s)
	s[F_SELF] = 0x0C


## $BC75 -- the leap across the room, which ends at either wall.
func _leap_50(w: Pb2Objects, s: PackedByteArray) -> void:
	w.step_anim(s)
	w.step_both(s)
	var far: bool = (s[F_BITS] & 0x40) != 0            # $C990
	if far:
		if s[F_X] < 0xB3:
			return
	elif s[F_X] >= 0x4E:
		return
	_leap_across_50(w, s)
	s[F_SELF] = 0x0C


## $BC93 -- the leap at him comes down, and it rests where it lands.
func _land_50(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	w.add_speed_down(s, 0x36)
	w.step_both(s)
	if s[F_VY] >= 0x80:
		return
	if w.walled_either_turn(n, s, 0x10, 0x1C, 0x00) < 0x80:
		return
	w.snap_down_from(s, 0x18)
	_wait_50(s, 0x18)
	s[F_SELF] += 1


## $BCB7 -- that rest over, it walks again.
func _pause_50(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	_walk_start_50(w, s)
	s[F_SELF] = 0x09


## $BCC5 -- and the leap across comes down into the round it began with.
func _drop_50(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	w.add_speed_down(s, 0x36)
	w.step_both(s)
	if s[F_VY] >= 0x80:
		return
	if w.walled_either_turn(n, s, 0x10, 0x1C, 0x00) < 0x80:
		return
	w.snap_down_from(s, 0x18)
	_wait_50(s, 0x10)
	s[F_SELF] = 0x01


## $BDBF -- stand still for so long, wearing the waiting picture.
func _wait_50(s: PackedByteArray, frames: int) -> void:
	s[F_COUNT] = frames
	s[F_KIND] = PIC_50_WAIT


## $BDE7 -- face the middle of the room: which half of it it stands on.
func _face_middle_50(s: PackedByteArray) -> void:
	s[F_BITS] = 0x00 if s[F_X] >= 0x80 else 0x40


## $BDC8 -- start walking, slowly, the way it is looking.
func _walk_start_50(w: Pb2Objects, s: PackedByteArray) -> void:
	w.set_speed_side_facing(s, 0xFE, 0x00)
	w.set_speed_down(s, 0x00, 0x00)
	w.start_anim(s, ANIM_50_WALK)


## $BDF4 -- and start the leap across, which is faster and goes up.
func _leap_across_50(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_KIND] = PIC_50_LEAP
	w.set_speed_side_facing(s, 0xFE, 0xE0)
	w.set_speed_down(s, 0xFA, 0x00)


## $BD73 -- the head.  It waits, then swings round towards him a step at a
## time, and every sixteenth step of the swing it shoots.  True when the whole
## round is over and the walk may begin.
func _head_50(w: Pb2Objects, n: int, s: PackedByteArray) -> bool:
	if s[F_COUNT] != 0:
		s[F_COUNT] -= 1
		s[F_KIND] = PIC_50_AIM
		return false
	s[F_KEEP] = (s[F_KEEP] - 1) & 0xFF
	if s[F_KEEP] == 0:
		return true
	if (s[F_KEEP] & 0x07) != 0:
		return false
	var aim: Array = _swing_50(w, s)
	if aim.is_empty():
		return false
	if s[F_KEEP2] == 0:
		return false
	if (s[F_KEEP] & 0x0F) != 0:
		return false
	var side: int = 0xEA if (s[F_BITS] & 0x40) != 0 else 0x16
	if w.make_child_aimed(s, side, aim[1], SHOT_50, SHOT_50_SPEED,
			aim[0]) < 0:
		s[F_KEEP2] = (s[F_KEEP2] - 1) & 0xFF
	return false


## $BCEB -- swing the head towards him and pick the picture that shows it.
## Empty when he is behind it and there is nothing to aim at; otherwise the
## angle the shot leaves at and how far down the head is.
func _swing_50(w: Pb2Objects, s: PackedByteArray) -> Array:
	if w.looking_away(s):                              # $C98D
		s[F_KIND] = PIC_50_AIM
		return []
	var hero: PackedByteArray = w.slots[0]
	var a: int = w._atan(s[F_X], (s[F_Y] - 0x08) & 0xFF,
			hero[F_X], (hero[F_Y] - 0x18) & 0xFF)      # $C8B2
	a = (a + 0x40) & 0x7F
	if (s[F_BITS] & 0x40) != 0:                        # $C990
		a = (-a) & 0x7F                                # $C858 -> $CAEB
	var i := 0
	if a >= 0x38:
		i = 1
		if a < 0x48:
			i = 2
	s[F_KIND] = HEAD_50[i]
	if HEAD_50_LOW[i] >= a:
		a = HEAD_50_LOW[i]
	elif HEAD_50_HIGH[i] < a:
		a = HEAD_50_HIGH[i]
	var ang: int = (0x40 + a) & 0xFF
	if (s[F_BITS] & 0x40) != 0:
		ang = (0x80 - ang) & 0xFF
	return [ang, HEAD_50_DOWN[i]]


# ------------------------------------------------------------------ $51
#
# $BE07 (bank 8) -- the second one, which hangs in the air.
#
# It has no steps to speak of: one frame to put its three helpers out, and
# after that the same frame over and over.  What makes it a fight is that the
# frame is three little pulls at once -- one sideways towards the hero, one
# up and down that keeps it a set height off him, and a count that every so
# often stops it dead and throws a pair of shots.

## $BE14 -- the run of pictures it wears while it hangs, and $BE45/$BF2C the
## two single pictures it snaps to: one for a hard turn, one for the shot.
const ANIM_51_HANG := 0x36
const PIC_51_TURN := 0xA8
const PIC_51_SHOOT := 0xA9
## $BE4A and $BF2F -- how long either of those two is held.
const HOLD_51 := 0x10
## $BE2A -- the three that come out with it, and $BF5F what it shoots.
const HELP_51 := 0x45
const HELP_51_COUNT := 3
const SHOT_51 := 0x3B
## $BE0F and $BF25 -- the first shot comes half as soon as the rest.
const WAIT_51_FIRST := 0x80
const WAIT_51 := 0xB4
## $BEF1 -- how hard it pulls sideways, by how far off the hero is.  The
## further away, the harder; $BEA0 is where the four bands are cut.
const PULL_51 := [0x20, 0x10, 0x04, 0x02]
const BAND_51 := [0x30, 0x60, 0x80]
## $BEE9/$BED6 -- and never faster than two points a step either way.
const SPEED_51_MAX := 0x02
## $BEFA and $BF09 -- it measures the hero from a point sixteen below itself,
## and holds itself that far off: nearer than sixty-four it backs away, further
## than that it closes in, so it never settles.
const REACH_51 := 0x10
const BAND_51_DOWN := 0x40
const PULL_51_FAR := 0x04
const PULL_51_NEAR := 0x10
## $BE41 -- coming down faster than this it wears the turning picture.
const FALL_51_TURN := 0x02
## $BE64/$BE83 -- how far above and how far to the side it feels for wall.
const CEIL_51 := 0xF0
const SIDE_51 := 0x18
## $BE57 -- and how far above the water it will not go.
const WATER_51 := 0x10
## $BF91 -- the eight ways a shot can leave, picked by which side it looks and
## whether it is hanging low.
const SHOT_51_ANG := [0x70, 0x50, 0xB0, 0x90, 0x10, 0x30, 0xD0, 0xF0]
const LOW_51 := 0x60


func _turn_51(w: Pb2Objects, _n: int, s: PackedByteArray) -> void:
	if s[F_SELF] == 0:
		_wake_51(w, s)
		return
	_pull_51(w, s)                                     # $BE9A
	_hover_51(w, s)                                    # $BEF5
	w.face_hero(s)                                     # $C8FD
	w.step_anim(s)                                     # $C837
	# $BE3C -- dropping hard it wears the turning picture for a moment.  The
	# picture is written straight over the run's own, which goes on stepping
	# underneath and takes it back when the hold runs out.
	if s[F_VY] < 0x80 and s[F_VY] >= FALL_51_TURN:
		s[F_KIND] = PIC_51_TURN
		s[F_HOLD] = HOLD_51
	_swim_51(w, s)                                     # $BE4F
	_slide_51(w, s)                                    # $BE7A
	_shoot_51(w, s)                                    # $BF1F


## $BE0C -- the one frame it spends coming awake: it starts its run, sets the
## count to the first shot, and puts its three helpers out.
func _wake_51(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_SELF] += 1
	s[F_COUNT] = WAIT_51_FIRST
	w.start_anim(s, ANIM_51_HANG)                      # $C83A
	for _i in range(HELP_51_COUNT):                    # $BE1B x3
		var k: int = w.free_slot_wide()                # $C86A
		if k < 0:
			continue
		var help: PackedByteArray = w.slots[k]
		help[F_TYPE] = HELP_51


## $BE9A -- the sideways pull.  Which way it pulls is not simply "towards
## him": inside the nearest band it pulls the way it is already going, and in
## the middle band it pulls *away*, so that it swings past him rather than
## settling on top of him.
func _pull_51(w: Pb2Objects, s: PackedByteArray) -> void:
	var side: Array = w.hero_side(s)                   # $C93C
	var far: int = side[0]
	var further: bool = side[1]
	var i := 3
	var back := false
	if far >= BAND_51[2]:                              # $BEA0
		back = further                                 # $BEB7 -- towards him
	elif far >= BAND_51[1]:
		i = 2
		back = not further                             # $BEBC -- and away
	elif far >= BAND_51[0]:
		i = 1
		back = s[F_VX] >= 0x80                         # $BEC1 -- as it went
	else:
		i = 0
		# $BEB0 -- and in the last band it is not the hero it looks at but
		# which half of the screen he stands in.
		back = w.slots[0][F_X] >= 0x80
	if back:
		w.sub_speed_side(s, PULL_51[i])                # $BEC7 -> $C915
		if s[F_VX] >= 0x80 and s[F_VX] < 0xFF:
			w.set_speed_side(s, (-SPEED_51_MAX) & 0xFF, 0x00)
	else:
		w.add_speed_side(s, PULL_51[i])                # $BEDA -> $C912
		if s[F_VX] < 0x80 and s[F_VX] >= SPEED_51_MAX:
			w.set_speed_side(s, SPEED_51_MAX, 0x00)


## $BEF5 -- and the pull up and down, which is measured from a point sixteen
## below it.  The place is moved, asked, and put back, so nothing but the
## question sees the move.
func _hover_51(w: Pb2Objects, s: PackedByteArray) -> void:
	var keep: int = s[F_Y]                             # $10
	w.nudge_down(s, 0x00, REACH_51)                    # $C930
	var down: Array = w.hero_down(s)                   # $C93F
	s[F_Y] = keep                                      # $BF04
	var below: bool = down[1]
	if down[0] >= BAND_51_DOWN:                        # $BF09
		if below:
			w.sub_speed_down(s, PULL_51_FAR)           # $C90F
		else:
			w.add_speed_down(s, PULL_51_FAR)           # $C90C
	elif below:
		w.add_speed_down(s, PULL_51_NEAR)              # $C90C
	else:
		w.sub_speed_down(s, PULL_51_NEAR)              # $C90F


## $BE4F -- the step down, with two things that stop it: the water, which it
## will not sink to within sixteen lines of, and a ceiling sixteen above it.
func _swim_51(w: Pb2Objects, s: PackedByteArray) -> void:
	if s[F_VY] < 0x80:                                 # $BE4F, going down
		if ((w.water - WATER_51) & 0xFF) >= s[F_Y]:    # $BE54
			w.step_down(s)                             # $C8F4
			return
		w.set_speed_down(s, 0xFF, 0x80)                # $BE5E -> $C909
		return
	if w.ground(s, 0x00, CEIL_51) < 0x80:              # $BE64 -> $C888
		w.step_down(s)                                 # $C8F4
		return
	w.set_speed_down(s, 0x00, 0x80)                    # $BE73 -> $C909


## $BE7A -- and the step across, which a wall on the side it is going stops
## dead rather than turning it round.
func _slide_51(w: Pb2Objects, s: PackedByteArray) -> void:
	var off: int = SIDE_51 if s[F_VX] < 0x80 else (-SIDE_51) & 0xFF
	if w.ground(s, off, 0x00) < 0x80:                  # $C888
		w.step_side(s)                                 # $C8F7
		return
	w.set_speed_side(s, 0x00, 0x00)                    # $C906


## $BF1F -- every so often it stops where it is and throws two shots, one out
## of each side of itself.
func _shoot_51(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	s[F_COUNT] = WAIT_51
	s[F_KIND] = PIC_51_SHOOT
	s[F_HOLD] = HOLD_51
	w.set_speed_side(s, 0x00, 0x00)                    # $C906
	w.set_speed_down(s, 0x00, 0x00)                    # $C909
	# $BF3D -- which of the eight ways the pair leaves by: four for the side
	# it looks, and two more if it is hanging low.
	var pick: int = 4 if (s[F_BITS] & 0x40) != 0 else 0   # $C990
	if s[F_Y] >= LOW_51:                               # $BF4A
		pick += 2
	_bolt_51(w, s, 0x00, pick)                         # $BF58
	_bolt_51(w, s, 0xFF, pick + 1)                     # falls into $BF5F


## $BF5F -- one shot.  `hand` is which of the pair it is: the high bit picks
## the side it is set out to and the low bit shifts the way it leaves by one.
func _bolt_51(w: Pb2Objects, s: PackedByteArray, hand: int, pick: int) -> void:
	var k: int = w.make_child(s, 0x00, 0x00, SHOT_51)  # $C8DF
	if k < 0:
		return
	var c: PackedByteArray = w.slots[k]
	c[F_KEEP2] = 0x08 if hand < 0x80 else 0xF8         # $BF6E
	c[F_KEEP] = 0x20 + (hand & 1)                      # $BF79
	c[F_COUNT] = SHOT_51_ANG[pick & 7]                 # $BF83
	c[F_SELF] = SHOT_51_ANG[pick & 7]


# ------------------------------------------------------------------ $52
#
# $B8A4 (bank 6) -- the third one: a head that swoops the room with two
# pieces of tail behind it.
#
# The head and its tail are the same type, told apart by $0668 -- nought is
# the head.  What makes the tail follow is a ring of twelve places the head
# writes every other frame and each piece of tail reads out of a dozen ticks
# behind, so the tail walks the very road the head walked.
#
# Seven steps: settle, glide, arc, turn about, hover, drop, rise.

## $B979/$B9A4 -- what comes out with it: two of one kind, and two pieces of
## its own tail.
const HAND_52 := 0x4A
const TAIL_52 := 0x52
## $B98C/$B994 -- how far behind the head each piece of tail is set.
const LAG_52 := [0x09, 0x12]
## $B9E4/$BA81 -- the two runs of pictures, and $BA03 and the rest the single
## ones it snaps to.
const ANIM_52_GLIDE := 0x37
const ANIM_52_HOVER := 0x38
const PIC_52_DIVE := 0xCD
const PIC_52_TURN := 0xCF
const PIC_52_SHOT_UP := 0xCE
const PIC_52_SHOT_DOWN := 0xD3
const PIC_52_OPEN := 0xD4
const PIC_52_FALL := 0xD5
const PIC_52_HIT := 0xD6
const PIC_52_REST := 0xD7
## $B91D -- while it wears one of these five it hangs at the top of the room.
const PIC_52_HIGH := [0xD0, 0xD5]
const HIGH_52 := 0x28
## $B9B7 -- where it settles, and how fast it sets off.
const FLOOR_52 := 0x90
const GLIDE_52 := [0xFD, 0x80]
## $B9BA -- inside these it faces the hero; outside it faces the middle.
const EDGE_52 := [0x30, 0xD0]
## $B9F9/$BA4F -- and these are the ends of its swoop.
const FAR_52 := [0x30, 0xD0]
const WALL_52 := [0x18, 0xE8]
## $BA08 -- the dive, and $BA0F how heavy it is, which is picked afresh.
const DIVE_52 := 0xFB
const WEIGHT_52 := 0x10
const SHOTS_52 := 0x0A
const SPACE_52 := 0x10
## $BAC0 -- coming out of a turn it is thrown the other way.
const BACK_52 := [0xFE, 0x80]
const THROW_52 := 0x40
## $BAAE and $BB50 -- the two little counts it keeps.
const TURN_52 := 0x0A
const FALL_52 := 0x08
const REST_52 := 0x14
const OPEN_52 := 0x08
## $BB67 -- how heavy it is while it drops.
const DROP_52 := 0x20
## $BB26 -- how near he has to be for it to drop, and $BB2A the two suits it
## will drop on from further off.
const NEAR_52 := 0x20
const SUITS_52 := [0x01, 0x03]
## $BBC4 -- what it shoots, how fast, and how far round it will aim.
const SHOT_52 := 0x46
const SHOT_52_SPEED := 0x12
const SHOT_52_ARC := 0x40


func _turn_52(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	if s[F_GROUND] != 0:                               # $B8A4
		_tail_52(w, n, s)
		return
	_step_52(w, s)                                     # $B956
	# $B8AC -- and every other frame it writes down where it has been.
	s[F_ANG] = (s[F_ANG] - 1) & 0xFF
	if s[F_ANG] != 0:
		return
	s[F_ANG] = 0x02
	var i: int = s[F_REC_BYTE]
	w.trail_x[i] = s[F_X]
	w.trail_y[i] = s[F_Y]
	w.trail_pic[i] = s[F_KIND]
	w.trail_bits[i] = s[F_BITS]
	i = (i + 1) & 0xFF
	s[F_REC_BYTE] = 0 if i == Pb2Objects.TRAIL else i


## $B8E0 -- a piece of the tail, which has no mind of its own: it reads the
## ring the head wrote and wears what the head wore.  With the meter empty
## there is no head to follow, and it goes.
func _tail_52(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	if w.slots[int(w.cfg_boss["slot"])][F_LIFE] == 0:  # $04A9
		w.clear(n)                                     # $C810
		return
	s[F_ANG] = (s[F_ANG] - 1) & 0xFF
	if s[F_ANG] != 0:
		s[F_BITS] = 0x80                               # $B918
	else:
		s[F_ANG] = 0x02
		var i: int = s[F_REC_BYTE]
		s[F_X] = w.trail_x[i]
		s[F_Y] = w.trail_y[i]
		s[F_KIND] = w.trail_pic[i]
		s[F_BITS] = w.trail_bits[i]
		i = (i + 1) & 0xFF
		s[F_REC_BYTE] = 0 if i == Pb2Objects.TRAIL else i
	# $B91D -- five of the pictures belong at the top of the room, and a piece
	# of tail wearing one of them is put there whatever the ring said.
	if s[F_KIND] >= PIC_52_HIGH[0] and s[F_KIND] < PIC_52_HIGH[1]:
		s[F_Y] = HIGH_52
	# $B92D -- and the two that are a mouth open to shoot are the tail's own
	# shot, thrown once each time the picture comes round.
	if s[F_KIND] == PIC_52_SHOT_UP:
		if s[F_PUSH] == 0:
			_shot_up_52(w, s)                          # $BB97
			s[F_PUSH] = (s[F_PUSH] + 1) & 0xFF
		return
	if s[F_KIND] == PIC_52_SHOT_DOWN:
		if s[F_PUSH] == 0:
			_shot_down_52(w, s)                        # $BBE3
			s[F_PUSH] = (s[F_PUSH] + 1) & 0xFF
		return
	s[F_PUSH] = 0


func _step_52(w: Pb2Objects, s: PackedByteArray) -> void:
	match s[F_SELF]:                                   # $B956
		0: _hatch_52(w, s)
		1: _glide_52(w, s)
		2: _arc_52(w, s)
		3: _about_52(w, s)
		4: _hover_52(w, s)
		5: _drop_52(w, s)
		6: _rise_52(w, s)


## $B974 -- the one frame it spends coming awake: two of one kind out, then
## the two pieces of its own tail, each set a little further behind it.
func _hatch_52(w: Pb2Objects, s: PackedByteArray) -> void:
	var last: PackedByteArray = s
	for _i in range(2):                                # $B976, $B97E
		var k: int = w.free_slot_wide()                # $C86A
		if k < 0:
			continue
		last = w.slots[k]
		last[F_TYPE] = HAND_52
	# $B986 -- and the second of the two is told it is the second.  The
	# cartridge writes it with the place still standing at that one, which is
	# where it is written here too.
	last[F_SELF] = (last[F_SELF] + 1) & 0xFF
	for lag in LAG_52:                                 # $B989, $B991
		var k: int = w.free_slot_wide()                # $B9A1 -> $C86A
		if k < 0:
			continue
		var tail: PackedByteArray = w.slots[k]
		tail[F_TYPE] = TAIL_52
		tail[F_MARK] = 0x80
		tail[F_STATE] = 0x02
		tail[F_GROUND] = (tail[F_GROUND] + 1) & 0xFF
		tail[F_ANG] = lag
	s[F_ANG] = (s[F_ANG] + 1) & 0xFF                   # $B99B
	_settle_52(w, s)


## $B9B7 -- back to the near end of the room, facing the way it will go.
func _settle_52(w: Pb2Objects, s: PackedByteArray) -> void:
	if s[F_X] < EDGE_52[0] or s[F_X] >= EDGE_52[1]:
		# $B9C2 -- out at the edge it does not look at the hero at all, only
		# at which half of the room it stands in.
		s[F_BITS] = 0x00 if ((s[F_X] + 1) & 0xFF) >= 0x80 else 0x40
	else:
		w.face_hero(s)                                 # $C8FD
	w.set_speed_side_facing(s, GLIDE_52[0], GLIDE_52[1])   # $C903
	w.set_speed_down(s, 0x00, 0x00)                    # $C909
	s[F_Y] = FLOOR_52
	w.start_anim(s, ANIM_52_GLIDE)                     # $C83A
	s[F_SELF] = 1                                      # $BB93


## $B9EE -- it slides along until it reaches the far end, and then dives.
func _glide_52(w: Pb2Objects, s: PackedByteArray) -> void:
	w.step_anim(s)                                     # $C8EE
	if s[F_VX] < 0x80:
		if s[F_X] < FAR_52[1]:
			return
	elif s[F_X] >= FAR_52[0]:
		return
	_dive_52(w, s)


## $BA03 -- the dive itself, which is thrown up and then falls back, and how
## heavy it is is picked afresh each time.
func _dive_52(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_KIND] = PIC_52_DIVE
	w.set_speed_down(s, DIVE_52, 0x00)                 # $C909
	var r: int = w.random()                            # $C939
	s[F_KEEP] = ((r & 0x3F) + WEIGHT_52
			+ (1 if w.rng_carry else 0)) & 0xFF
	s[F_KEEP2] = SPACE_52
	s[F_PUSH] = SHOTS_52
	s[F_SELF] = 2                                      # $BB93


## $BA28 -- the arc.  Coming down past the floor it settles again; thrown up
## past the ceiling it turns into the hover; and either wall turns it about.
## Everything else is the shooting, which is spaced out by two little counts.
func _arc_52(w: Pb2Objects, s: PackedByteArray) -> void:
	w.add_speed_down(s, s[F_KEEP])                     # $C90C
	w.step_both(s)                                     # $C8F1
	if s[F_VY] < 0x80:
		if s[F_Y] < FLOOR_52:
			_wall_52(w, s)
			return
		_settle_52(w, s)
		return
	if HIGH_52 >= s[F_Y]:                              # $BA40
		_rear_52(w, s)
		return
	_wall_52(w, s)


## $BA47 -- either wall turns it about; away from them it goes on shooting.
func _wall_52(w: Pb2Objects, s: PackedByteArray) -> void:
	if s[F_VX] < 0x80:
		if s[F_X] >= WALL_52[1]:
			_about_start_52(s)
			return
	elif s[F_X] < WALL_52[0]:
		_about_start_52(s)
		return
	# $BA5B -- the count of shots left, and between them the count of frames.
	if s[F_PUSH] == 0:
		return
	if s[F_KEEP2] != 0:
		s[F_KEEP2] = (s[F_KEEP2] - 1) & 0xFF
		if s[F_KEEP2] != 0:
			return
		# $BA6A -- a shot it could not aim is tried again in four frames.
		if not _shot_up_52(w, s):
			s[F_KEEP2] = 0x04
		return
	s[F_PUSH] = (s[F_PUSH] - 1) & 0xFF                 # $BA76
	if s[F_PUSH] == 0:
		s[F_KIND] = PIC_52_DIVE


## $BAA9 -- and the turn about, which is only a picture and a wait.
func _about_start_52(s: PackedByteArray) -> void:
	s[F_KIND] = PIC_52_TURN
	s[F_COUNT] = TURN_52
	s[F_SELF] = 3                                      # $BB93


## $BAB8 -- when the wait is up it turns, is thrown back the way it came by a
## push picked afresh, and dives again.
func _about_52(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	w.turn(s)                                          # $C918
	w.set_speed_side_facing(s, BACK_52[0], BACK_52[1])  # $C903
	var r: int = w.random()                            # $C939
	var push: int = ((r & 0x3F) + THROW_52
			+ (1 if w.rng_carry else 0)) & 0xFF
	if s[F_VX] < 0x80:
		w.add_speed_side(s, push)                      # $C912
	else:
		w.sub_speed_side(s, push)                      # $C915
	_dive_52(w, s)


## $BA81 -- thrown up past the ceiling it rears: it stops dead, is set going
## at the hero, and hangs at the top of the room.
func _rear_52(w: Pb2Objects, s: PackedByteArray) -> void:
	w.start_anim(s, ANIM_52_HOVER)                     # $C83A
	w.set_speed_down(s, 0x00, 0x00)                    # $C909
	w.set_speed_side_at_hero(s, 0xFF, 0x00)            # $C900
	s[F_KEEP2] = SPACE_52 if s[F_KEEP2] != 0 else 0x7F
	s[F_PUSH] = SHOTS_52
	s[F_SELF] = 4                                      # $BB93


## $BAE0 -- the hover, where it is at its most dangerous: it shoots downwards,
## and when the hero comes near enough it lets itself fall on him.
func _hover_52(w: Pb2Objects, s: PackedByteArray) -> void:
	w.boss_step = 1                                    # $5F
	if s[F_KEEP2] < 0x80:
		if s[F_KEEP2] != 0:
			s[F_KEEP2] = (s[F_KEEP2] - 1) & 0xFF
			if s[F_KEEP2] != 0:
				_watch_52(w, s)
				return
			if _shot_down_52(w, s):                    # $BBE3
				return
			s[F_KEEP2] = FALL_52
			_watch_52(w, s)
			return
		# $BAFC -- with no shots left it opens, and the frame after that it
		# is done hovering.
		s[F_PUSH] = (s[F_PUSH] - 1) & 0xFF
		if s[F_PUSH] != 0:
			return
		if s[F_KIND] == PIC_52_OPEN:                   # $BB11
			s[F_KEEP2] = 0xFF
			w.start_anim(s, ANIM_52_HOVER)             # $C83A
			_watch_52(w, s)
			return
		s[F_KIND] = PIC_52_OPEN
		s[F_PUSH] = OPEN_52
		return
	_watch_52(w, s)


## $BB1B -- while it hovers it watches him, and drops when he is under it.
## In the two suits that climb it will drop from further off, so long as he is
## not far below as well.
func _watch_52(w: Pb2Objects, s: PackedByteArray) -> void:
	w.step_anim(s)                                     # $C8EE
	s[F_Y] = HIGH_52
	var side: Array = w.hero_side(s)                   # $C93C
	if side[0] >= NEAR_52:
		if not (w.suit in SUITS_52):                   # $9A
			return
		var down: Array = w.hero_down(s)               # $C93F
		if down[0] >= NEAR_52:
			return
	w.set_speed_side(s, 0x00, 0x00)                    # $C906
	w.set_speed_down(s, 0x01, 0x00)                    # $C909
	s[F_KIND] = PIC_52_FALL
	s[F_COUNT] = FALL_52
	s[F_SELF] = 5                                      # $BB93


## $BB58 -- the drop, which ends on the floor and leaves it lying there.
func _drop_52(w: Pb2Objects, s: PackedByteArray) -> void:
	if s[F_COUNT] != 0:
		s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
		if s[F_COUNT] == 0:
			s[F_KIND] = PIC_52_HIT
	w.add_speed_down(s, DROP_52)                       # $C90C
	w.step_both(s)                                     # $C8F1
	if s[F_Y] < FLOOR_52:
		return
	s[F_Y] = FLOOR_52
	s[F_KIND] = PIC_52_REST
	s[F_COUNT] = REST_52
	s[F_SELF] += 1


## $BB8A -- and the rest at the end of it, after which it settles and begins
## the whole round again.
func _rise_52(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	_settle_52(w, s)


## $BB97 -- a shot upwards at him.  It will not aim behind itself, and it will
## not aim more than a quarter turn off level; when either says no the shot is
## not thrown, and that is what the answer here means.
func _shot_up_52(w: Pb2Objects, s: PackedByteArray) -> bool:
	if w.looking_away(s):                              # $C98D
		return false
	var hero: PackedByteArray = w.slots[0]
	var ang: int = w._atan(s[F_X], (s[F_Y] - 0x06) & 0xFF,
			hero[F_X], (hero[F_Y] - 0x18) & 0xFF)      # $C8B2
	if ((ang + 0x20) & 0x7F) >= SHOT_52_ARC:
		return false
	var off: int = 0x14 if (s[F_BITS] & 0x40) != 0 else 0xEC   # $C990
	if w.make_child_aimed(s, off, 0xFA, SHOT_52,
			SHOT_52_SPEED, ang) < 0:                   # $C8E5
		return false
	s[F_KIND] = PIC_52_SHOT_UP
	return true


## $BBE3 -- and the same downwards, which is aimed from beside its mouth
## rather than from the middle of it.
func _shot_down_52(w: Pb2Objects, s: PackedByteArray) -> bool:
	if w.looking_away(s):                              # $C98D
		return false
	var off: int = 0x0A if (s[F_BITS] & 0x40) != 0 else 0xF6   # $C990
	var hero: PackedByteArray = w.slots[0]
	var ang: int = w._atan((s[F_X] + off) & 0xFF, s[F_Y],
			hero[F_X], (hero[F_Y] - 0x18) & 0xFF)      # $C8B2
	if ((ang - 0x20) & 0x7F) >= SHOT_52_ARC:
		return false
	if w.make_child_aimed(s, off, 0x06, SHOT_52,
			SHOT_52_SPEED, ang) < 0:                   # $C8E5
		return false
	s[F_KIND] = PIC_52_SHOT_DOWN
	return true


# ------------------------------------------------------------------ $53
#
# $BC37 (bank 7) -- the fourth one, and the only one that is two things.
#
# The room holds two of it, in places fourteen and fifteen, and place
# fourteen is made by copying place fifteen over itself.  Each has its own
# life; the meter at the top of the screen shows the two added together, and
# the fight is over only when both are out.  Which is why every turn begins
# by looking at what the other one has left ($BF1A).
#
# Nine steps: land, wait, fall, dive, slide, walk, charge, drop, rest.

## $BC61 -- what each of the two starts with, and $BF29 how much of that is
## only the meter: below this it is dead, and the meter shows the rest.
const LIFE_53 := 0x80
const FLOOR_53_LIFE := 0x60
const DEAD_53 := 0x61
## $BC72 -- which way the copy looks and $BC78 the picture it wears are read
## out of bosses.json, along with the place it is made in.  $BD09 and $BD43 --
## the two pictures it wears itself ($BD08, $BD42), standing and leaping.
const PIC_53_STAND := 0xDD
const PIC_53_LEAP := 0xDE
## $BC7F -- and where it is set: at the near edge, a screen above the room.
const START_53 := [0x00, 0xF0]
const START_53_SPEED := 0x02
## $BCA1 -- the floor it lands on, and the run it wears standing there.
const FLOOR_53 := 0x8D
const ANIM_53_STAND := 0x39
## $BCBD -- how long it waits before it moves, which is shortest when the
## hero is close, longer when he is looking at it and longer still when he
## is not.
const NEAR_53 := 0x20
const WAIT_53_NEAR := 0x20
const WAIT_53_SEEN := 0x30
const WAIT_53_AWAY := 0x08
## $BDBB -- the leap away, and $BDA5 the dodge, which is the same going up.
const LEAP_53 := [0xFE, 0x80]
const DODGE_53_DOWN := [0xFA, 0x00]
const DODGE_53_SIDE := [0xFE, 0x00]
## $BD07/$BD41 -- the two arcs it throws itself along, each a count of frames
## to reach him in and a lift to make the arc out of.
const ARC_53_LOW := [0x28, 0xFC]
const ARC_53_HIGH := [0x28, 0xFD]
## $BD1B, $BD59, $BEA1, $BEE5 -- how heavy it is in each of the four steps
## that fall.
const WEIGHT_53_FALL := 0x34
const WEIGHT_53_DIVE := 0x26
const WEIGHT_53_CHARGE := 0x36
const WEIGHT_53_DROP := 0x38
## $BD61 -- the hop, which starts a little above the floor.
const HOP_53_Y := 0x96
const HOP_53_SIDE := [0xFC, 0x00]
const HOP_53_LONG := 0x24
## $BD7C -- and how hard the slide brakes.
const BRAKE_53 := 0x08
## $BDDE and the rest -- how long it walks before it looks up, and the bands
## it judges the hero by when it does.
const WALK_53_LOOK := 0x15
const WALK_53_TURN := 0x42
const HERO_53_LOW := 0x90
const HERO_53_MID := 0x40
const REACH_53 := [0x30, 0x60, 0x70, 0x80]
## $BE5C -- and how it sets off at him afterwards.
const CHARGE_53 := [0x03, 0x00]
const CHARGE_53_UP := [0xFA, 0x00]
## $BECA -- four pictures as the charge runs on.
const PIC_53_RUN := 0xDF
const RUN_53 := [0x16, 0x22, 0x2A]
## $BEFE -- how long it rests when it lands.
const REST_53 := 0x20
## $BF9E and $BFAF -- how near a shot has to pass for it to dodge.
const DODGE_53_DOWN_NEAR := 0x20
const DODGE_53_SIDE_NEAR := 0x50
## $BF82 -- and which places his shots are kept in.
const SHOTS_53 := [1, 2, 3]


func _turn_53(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	# $BC3A -- the first step is the one that makes the second of the two, so
	# there is nothing to share yet.
	if s[F_SELF] != 0 and _share_53(w, n, s):          # $BF1A
		return
	match s[F_SELF]:                                   # $BC42
		0: _hatch_53(w, s)
		1: _wait_53(w, n, s)
		2: _fall_53(w, s)
		3: _dive_53(w, s)
		4: _slide_53(w, s)
		5: _walk_53(w, n, s)
		6: _charge_53(w, s)
		7: _drop_53(w, s)
		8: _rest_53(w, s)


## $BF1A -- what the two of them share.
##
## The meter is one and there are two lives behind it, so whenever either of
## them has been hurt the two are added up and the meter written afresh.  The
## adding is done in the meter's own byte, which is the second one's life --
## so the second one's life is put back afterwards.
##
## The answer is whether the turn is over: below the floor the one that was
## hurt is finished, and the cartridge throws the rest of its turn away.
func _share_53(w: Pb2Objects, n: int, s: PackedByteArray) -> bool:
	var other: PackedByteArray = w.slots[n ^ 1]
	var life: int = s[F_LIFE]
	if life == s[F_COUNT]:                             # $BF21
		return false
	s[F_COUNT] = life
	if life >= DEAD_53:
		_meter_53(w, s, other)
		return false
	# $BF2D -- and this is where the turn is thrown away.
	other[F_COUNT] = other[F_LIFE]
	if other[F_LIFE] != 0:
		# $BF49 -- the other one is still up, so this one only bursts.
		other[F_COUNT] = 0
		w.make_burst(n)                                # $C9C0
		return true
	s[F_LIFE] = 0
	w.slots[int(w.cfg_boss["slot"])][F_LIFE] = 0       # $04A9
	s[F_MARK] = 0x80                                   # $C9AB
	s[F_STATE] = 3                                     # the shell's own death
	return true


## $BF51 -- the two lives added up, each above the floor, laid in the meter's
## byte for as long as the drawing takes and then taken out again.
func _meter_53(w: Pb2Objects, s: PackedByteArray, other: PackedByteArray) -> void:
	var mine: int = _above_53(s)
	var theirs: int = _above_53(other)
	var boss: PackedByteArray = w.slots[int(w.cfg_boss["slot"])]
	var keep: int = boss[F_LIFE]                       # $BF60
	boss[F_LIFE] = (theirs + mine) & 0xFF
	# $C8C4 -- and here the cartridge draws it.  The bar at the top of the
	# screen is the HUD's own work and is not the boss's, so nothing is drawn
	# here; the byte it would have read is written all the same.
	boss[F_LIFE] = keep                                # $BF7C


## $BF58 and $BF6B -- how much of one life is meter.  A life of $FF is one
## that has been hurt this very frame and not yet settled; what it was is kept
## in $05FA.
func _above_53(s: PackedByteArray) -> int:
	var life: int = s[F_KEEP] if s[F_LIFE] == 0xFF else s[F_LIFE]
	life -= FLOOR_53_LIFE
	return 0 if life < 0 else life


## $BC61 -- the first frame, which makes the second of the two out of the
## first and sets it walking in from the near edge, a screen above the room.
func _hatch_53(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_LIFE] = LIFE_53
	s[F_COUNT] = LIFE_53
	var mate: int = int(w.cfg_boss["twin_slot"])       # $BC69
	w.copy_row(mate, s)                                # $C963
	var twin: PackedByteArray = w.slots[mate]
	twin[F_GROUND] = int(w.cfg_boss["twin_bits"])
	twin[F_BITS] = int(w.cfg_boss["twin_bits"])
	twin[F_KIND] = int(w.cfg_boss["twin_pic"])
	twin[F_X] = START_53[0]
	twin[F_Y] = START_53[1]
	twin[F_YHI] = (twin[F_YHI] - 1) & 0xFF             # $BC87
	w.set_speed_side(twin, START_53_SPEED, 0x00)       # $C906
	twin[F_SELF] = 7                                   # $BF16
	_land_53(w, s)                                     # $BCA1
	s[F_KEEP2] = 0x40


## $BCA1 -- down on the floor, standing, waiting.  How long it waits is what
## it makes of where the hero is: close by, it goes at once; further off, it
## waits longer if he is looking at it than if he is not.
func _land_53(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_Y] = FLOOR_53
	w.start_anim(s, ANIM_53_STAND)                     # $C83A
	s[F_BITS] = s[F_GROUND]                            # $BCAB
	w.set_speed_side(s, 0x00, 0x00)                    # $C906
	w.set_speed_down(s, 0x00, 0x00)                    # $C909
	var side: Array = w.hero_side(s)                   # $C93C
	var wait: int = WAIT_53_NEAR
	if side[0] >= NEAR_53:
		# $BCC5 -- which way it would have to look, and which way he does.
		var want: int = 0x00 if s[F_X] >= 0x80 else 0x40
		var his: int = w.slots[0][F_BITS] & 0x40
		wait = WAIT_53_SEEN if his == want else WAIT_53_AWAY
	s[F_KEEP2] = wait
	s[F_SELF] = 1                                      # $BF16


## $BCE6 -- the wait.  A shot on its way cuts it short, and so does the other
## one of the two being down or standing about as well.
func _wait_53(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	if _shot_coming_53(w, s):                          # $BF80
		_leap_53(w, s)
		return
	s[F_KEEP2] = (s[F_KEEP2] - 1) & 0xFF
	if s[F_KEEP2] != 0:
		return
	var other: PackedByteArray = w.slots[n ^ 1]
	if other[F_LIFE] == 0 or other[F_SELF] == 1:
		_leap_53(w, s)
		return
	s[F_KEEP2] = (s[F_KEEP2] + 1) & 0xFF               # $BD00


## $BDBB -- up and away, behind itself.
func _leap_53(w: Pb2Objects, s: PackedByteArray) -> void:
	w.set_speed_side_facing(s, LEAP_53[0], LEAP_53[1])  # $C903
	s[F_KEEP2] = 0
	w.set_speed_down(s, 0x00, 0x00)                    # $C909
	s[F_SELF] = 5                                      # $BF16


## $BD1B -- coming down out of the low arc.
func _fall_53(w: Pb2Objects, s: PackedByteArray) -> void:
	w.add_speed_down(s, WEIGHT_53_FALL)                # $C90C
	_drift_53(w, s, 0xF0)


## $BD55 -- and out of the high one, which is where it is at its heaviest.
func _dive_53(w: Pb2Objects, s: PackedByteArray) -> void:
	w.boss_step = 1                                    # $5F
	w.add_speed_down(s, WEIGHT_53_DIVE)                # $C90C
	_drift_53(w, s, 0xF0)


## $BD20 -- the step both arcs take: a wall ahead stops it dead sideways, and
## the floor ends the arc.
func _drift_53(w: Pb2Objects, s: PackedByteArray, side: int) -> void:
	if w.walled_ahead(s, side, 0x04, 0xF4) >= 0x80:    # $C954
		w.set_speed_side(s, 0x00, 0x00)                # $C906
	w.step_both(s)                                     # $C8F1
	if s[F_Y] < FLOOR_53:
		return
	_land_rest_53(w, s)


## $BD07 -- throw itself at him along a low arc.
func _arc_low_53(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_KIND] = PIC_53_STAND
	w.face_hero(s)                                     # $C8FD
	w.set_speed_reach(s, ARC_53_LOW[0], ARC_53_LOW[1])  # $C9CF
	s[F_SELF] = 2                                      # $BF16


## $BD41 -- and along a high one.
func _arc_high_53(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_KIND] = PIC_53_LEAP
	w.face_hero(s)                                     # $C8FD
	w.set_speed_reach(s, ARC_53_HIGH[0], ARC_53_HIGH[1])   # $C9CF
	s[F_SELF] = 3                                      # $BF16


## $BD61 -- the little hop, which is thrown backwards rather than at him.
func _hop_53(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_KIND] = PIC_53_LEAP
	s[F_Y] = HOP_53_Y
	w.set_speed_side_at_hero(s, HOP_53_SIDE[0], HOP_53_SIDE[1])   # $C900
	s[F_KEEP2] = HOP_53_LONG
	s[F_SELF] = 4                                      # $BF16


## $BD7C -- the slide the hop lands in, which brakes itself to a stop and ends
## at a wall or when its count runs out.
func _slide_53(w: Pb2Objects, s: PackedByteArray) -> void:
	if s[F_VX] < 0x80:
		w.sub_speed_side(s, BRAKE_53)                  # $C915
	else:
		w.add_speed_side(s, BRAKE_53)                  # $C912
	w.step_side(s)                                     # $C8F7
	s[F_KEEP2] = (s[F_KEEP2] - 1) & 0xFF
	if s[F_KEEP2] == 0:
		_land_rest_53(w, s)
		return
	if w.walled_ahead(s, 0xEC, 0x00, 0xF4) >= 0x80:    # $C954
		_land_rest_53(w, s)


## $BDD0 -- the walk, and the one step where it thinks.
##
## For the first twenty-one frames it only walks; after that it weighs where
## the hero is -- how far along, and how far down -- against four bands, and
## out of that comes one of five things: an arc at him low, an arc at him
## high, a hop away, a charge, or more walking.
func _walk_53(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	if _shot_coming_53(w, s):                          # $BF80
		_dodge_53(w, s)
		return
	w.step_anim(s)                                     # $C8EE
	s[F_KEEP2] = (s[F_KEEP2] + 1) & 0xFF
	if s[F_KEEP2] < WALK_53_LOOK:
		_walk_on_53(w, s)
		return
	var far: int = w.hero_side(s)[0]                   # $C93C
	var hy: int = w.slots[0][F_Y]                      # $04C6
	if hy >= HERO_53_LOW:                              # $BE08 -- he is low
		if far >= REACH_53[3]:
			_walk_end_53(w, s)
			return
		if not w.looking_away(s):                      # $C98D
			_pick_53(w, s)
			return
		if s[F_KEEP2] >= WALK_53_TURN:
			_pick_53(w, s)
			return
		# $BE18 -- long enough looking the wrong way, and with the other one
		# down, it turns round to face him for good.
		if w.slots[n ^ 1][F_LIFE] == 0:
			s[F_GROUND] = s[F_GROUND] ^ 0x40
		_charge_start_53(w, s)
		return
	if hy >= HERO_53_MID:                              # $BDF8 -- he is level
		if far >= REACH_53[2]:
			_walk_end_53(w, s)
			return
		if far < REACH_53[0] or w.looking_away(s):
			_arc_low_53(w, s)
			return
		_arc_high_53(w, s)
		return
	# $BDF1 -- and he is high up
	if far >= REACH_53[1]:
		_walk_end_53(w, s)
		return
	_arc_low_53(w, s)


## $BE2C -- one of the two it picks at random when he is low and it is facing
## him: a hop away, or a high arc thrown backwards.
func _pick_53(w: Pb2Objects, s: PackedByteArray) -> void:
	if (w.random() & 1) != 0:                          # $C939
		_hop_53(w, s)
		return
	_arc_high_53(w, s)                                 # $BE35
	w.set_speed_down(s, 0xFC, 0x80)                    # $C909
	w.set_speed_side_at_hero(s, 0xFC, 0xE0)            # $C900


## $BE46 -- looking away it walks on; looking at him it charges.
func _walk_end_53(w: Pb2Objects, s: PackedByteArray) -> void:
	if w.looking_away(s):                              # $C98D
		_charge_start_53(w, s)
		return
	_walk_on_53(w, s)


## $BE4B -- and a wall ahead of it ends the walk too.
func _walk_on_53(w: Pb2Objects, s: PackedByteArray) -> void:
	if w.walled_ahead(s, 0xF8, 0x04, 0xF4) >= 0x80:    # $C954
		_charge_start_53(w, s)


## $BE5C -- turn back the way it was made looking, and run.
func _charge_start_53(w: Pb2Objects, s: PackedByteArray) -> void:
	w.set_speed_down(s, CHARGE_53_UP[0], CHARGE_53_UP[1])   # $C909
	s[F_REC_BYTE] = 0
	s[F_BITS] = s[F_GROUND]
	w.set_speed_side_facing(s, CHARGE_53[0], CHARGE_53[1])  # $C903
	s[F_SELF] = 6                                      # $BF16


## $BDA5 -- the dodge: it hops up out of the way of the shot and comes down
## in the low arc.
func _dodge_53(w: Pb2Objects, s: PackedByteArray) -> void:
	_arc_low_53(w, s)                                  # $BD07
	s[F_Y] = FLOOR_53
	w.set_speed_down(s, DODGE_53_DOWN[0], DODGE_53_DOWN[1])   # $C909
	w.set_speed_side_facing(s, DODGE_53_SIDE[0], DODGE_53_SIDE[1])   # $C903


## $BE7A -- the charge, which is a run along the floor with a picture that
## walks on as it goes.  A wall ends it; the floor under it holds it up.
func _charge_53(w: Pb2Objects, s: PackedByteArray) -> void:
	w.boss_step = 2                                    # $5F
	if s[F_Y] >= FLOOR_53:
		if w.walled_ahead(s, 0x10, 0x04, 0xF4) >= 0x80:   # $C954
			_land_53(w, s)                             # $BCA1
			return
		w.set_speed_down(s, CHARGE_53_UP[0], CHARGE_53_UP[1])
		s[F_REC_BYTE] = 0
	w.add_speed_down(s, WEIGHT_53_CHARGE)              # $C90C
	if w.walled_ahead(s, 0x10, 0x04, 0xF4) >= 0x80:    # $C954
		w.set_speed_side(s, 0x00, 0x00)                # $C906
		if s[F_VY] >= 0x80:
			w.set_speed_down(s, 0x00, 0x00)            # $C909
	w.step_both(s)                                     # $C8F1
	s[F_REC_BYTE] = (s[F_REC_BYTE] + 1) & 0xFF
	var k: int = PIC_53_RUN
	for edge in RUN_53:                                # $BECA
		if s[F_REC_BYTE] >= edge:
			k += 1
	s[F_KIND] = k


## $BEE3 -- the fall at the end of a charge that ran off the floor.
func _drop_53(w: Pb2Objects, s: PackedByteArray) -> void:
	w.add_speed_down(s, WEIGHT_53_DROP)                # $C90C
	w.step_both(s)                                     # $C8F1
	if s[F_YHI] != 0:
		return
	if s[F_Y] < FLOOR_53:
		return
	_land_rest_53(w, s)


## $BEFB -- down, and a rest before it looks about again.
func _land_rest_53(w: Pb2Objects, s: PackedByteArray) -> void:
	_land_53(w, s)                                     # $BCA1
	s[F_KEEP2] = REST_53
	s[F_SELF] = 8                                      # $BF16


## $BF08 -- the rest, which a shot on its way cuts short.
func _rest_53(w: Pb2Objects, s: PackedByteArray) -> void:
	if not _shot_coming_53(w, s):                      # $BF80
		_charge_start_53(w, s)
		return
	s[F_KEEP2] = (s[F_KEEP2] - 1) & 0xFF
	if s[F_KEEP2] == 0:
		_charge_start_53(w, s)


## $BF80 -- is one of his three throws on its way here?
##
## Only a throw that is running level counts, and only one that is near enough
## in both ways, and only one whose speed points at this rather than away from
## it.  The first that does ends the looking.
func _shot_coming_53(w: Pb2Objects, s: PackedByteArray) -> bool:
	for k in SHOTS_53:
		var shot: PackedByteArray = w.slots[k]
		if (shot[F_VX] | shot[F_VXFR]) == 0:           # $BF82
			continue
		if (shot[F_VY] | shot[F_VYFR]) != 0:           # $BF8A
			continue
		if absi(s[F_Y] - shot[F_Y]) >= DODGE_53_DOWN_NEAR:   # $C858
			continue
		var beyond: bool = s[F_X] >= shot[F_X]         # $BFA9 -- the carry
		if absi(s[F_X] - shot[F_X]) >= DODGE_53_SIDE_NEAR:
			continue
		# $BFB4 -- a throw going the way the numbers grow is coming at this
		# one only while this one is the further along, and the other way
		# round for one going back.
		if (shot[F_VX] >= 0x80) != beyond:
			return true
	return false


# ------------------------------------------------------------------ $54
#
# $BB40 (bank 1) -- the fifth one, which the hero can stand on.
#
# It walks the floor with two arms beside it, and when he is near enough it
# stops, rises to the top of the room, hangs there bobbing and dropping
# things, and comes down again.  What makes it its own is $BCAA: every frame
# of the walk it offers itself to him as something to stand on, and if he is
# standing on it and has just been hurt it throws him off and takes four back
# into its own meter.
#
# Six steps, kept in $05CE: hatch, close, walk, rise, hover, fall.

## $BB77 -- the two arms it puts out beside it.
const ARM_54 := 0x4D
## $BB7D -- the walk it wears, the height it walks at, and how long it looks
## at him before it starts.
const ANIM_54_WALK := 0x3C
const FLOOR_54 := 0x80
const WAIT_54_LOOK := 0x18
## $BB9C -- it turns its head every eighth frame of that, and $BBA6 how close
## he has to be for it not to wait the whole count out.
const LOOK_54_EVERY := 0x07
const NEAR_54 := 0x11
## $BBAB -- and then it walks at him this fast.
const WALK_54 := [0xFE, 0x00]
## $BBD0 -- the wall it feels for, put out at two heights.
const WALL_54_SIDE := 0xE8
const WALL_54_LOW := 0x04
const WALL_54_HIGH := 0xF4
## $BBF5 -- how close he must come for it to think of rising, $BBFF how high
## he must be standing, and $BC15 the run it wears going up.
const RISE_54_NEAR := 0x28
const RISE_54_HIGH := 0x70
const ANIM_54_RISE := 0x3B
## $BC1F -- how hard it pulls itself up, and $BC27 where it stops.
const LIFT_54 := 0x20
const CEIL_54 := 0x40
## $BC36 -- how often it drops something while it hangs there, $BC3D how long
## it hangs, and $BC53 how close he must be for it to come down again.
const DROP_54_EVERY := 0x10
const HOVER_54 := 0xB0
const DOWN_54_NEAR := 0x15
## $BC76 -- what it drops, straight down and standing still.
const FALL_54 := 0x25
const FALL_54_ANG := 0x40
const FALL_54_SPEED := 0x00
## $BC8D -- and how fast it starts down, $BC97 how heavy it is coming down.
const DOWN_54 := 0x01
const WEIGHT_54 := 0x38
## $BD55 -- the bob: two-and-thirty steps read forwards and back and then
## turned about, so that it rides up and down over four-and-sixty frames.
const BOB_54 := [
	0x00, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x01,
	0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
	0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
	0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]
## $BCAA -- the box it holds out for him to stand on: how wide, how far above
## where it stands, and the height it pretends to be at while it is asked.
const STAND_54_WIDE := 0x10
const STAND_54_UP := 0xE0
const STAND_54_Y := 0xA0
## $BCD0 -- what it will not do while he is still flashing, $BCDA how far up
## its own box he must be, $BCED how long it waits before it may throw him
## again and $BD10 how much it takes back each time.
const THROWN_54_WAIT := 0x60
const ON_TOP_54 := 0x03
const THROW_54_UP := 0xFC
const THROW_54_SIDE := 0x08
const THROW_54_KEEP := 0xF8
const HEAL_54 := 0x04
const HEAL_54_MAX := 0x41
const HEAL_54_CAP := 0x40
## $BD93 and $BDA4 -- how near an arm has to be for it to count as in the way.
const CLEAR_54_DOWN := 0x20
const CLEAR_54_SIDE := 0x50
const CLEAR_54_LAST := 0x04


func _turn_54(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	match s[F_SELF]:                                   # $BB40
		0: _hatch_54(w, s)
		1: _close_54(w, s)
		2: _walk_54(w, n, s)
		3: _rise_54(w, s)
		4: _hover_54(w, n, s)
		5: _fall_54(w, s)


## $BB64 -- the first frame puts out the two arms.  The count that is put up
## afterwards belongs to the second arm and not to the boss: the cartridge
## has not put its own place back yet, and the arm is the one that is asked.
func _hatch_54(w: Pb2Objects, s: PackedByteArray) -> void:
	var last := -1
	for _i in range(2):                                # $BB66, $BB69
		last = w.free_slot_wide()                      # $C86A
		if last < 0:
			continue
		w.slots[last][F_TYPE] = ARM_54                 # $BB77
	if last >= 0:
		var arm: PackedByteArray = w.slots[last]
		arm[F_SELF] = (arm[F_SELF] + 1) & 0xFF         # $BB6C
	_start_54(w, s)                                    # $BB7D


## $BB7D -- back on the floor, looking at him, and waiting.
func _start_54(w: Pb2Objects, s: PackedByteArray) -> void:
	w.start_anim(s, ANIM_54_WALK)                      # $C83A
	s[F_Y] = FLOOR_54
	w.face_hero(s)                                     # $C8FD
	s[F_COUNT] = WAIT_54_LOOK
	s[F_SELF] = 1                                      # $BB60


## $BB94 -- it waits, turning its head every eighth frame, until either the
## waiting is over or he has come close enough by himself.
func _close_54(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		if (s[F_COUNT] & LOOK_54_EVERY) == 0:
			w.face_hero(s)                             # $C8FD
		if w.hero_side(s)[0] >= NEAR_54:               # $C93C
			return
	w.set_speed_side_at_hero(s, WALK_54[0], WALK_54[1])    # $C900
	s[F_COUNT] = 0x00
	s[F_KEEP] = 0x00
	s[F_KEEP2] = 0x00
	s[F_PUSH] = 0x00
	w.set_speed_down(s, 0x00, 0x00)                    # $C909
	s[F_SELF] += 1                                     # $BB5C


## $BBC7 -- the walk.  A wall turns it about once and sends it back to the
## beginning the second time; and somewhere along it, if he is near enough
## and high enough, or if an arm is coming the other way, it stops and rises.
func _walk_54(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	_offer_54(w, s)                                    # $BCAA
	w.step_anim(s)                                     # $C8EE
	w.step_both(s)
	_thrown_54(w, s)                                   # $BCC4
	if w.walled_ahead_turn(n, s, WALL_54_SIDE, WALL_54_LOW,
			WALL_54_HIGH, 0x00) >= 0x80:               # $C957
		if s[F_PUSH] != 0:
			_start_54(w, s)                            # $BC09
			return
		s[F_PUSH] = (s[F_PUSH] + 1) & 0xFF
		w.turn_about(s)                                # $C91B
	if w.looking_away(s):                              # $C98D
		return
	var go := false
	if s[F_KEEP2] == 0 and w.hero_side(s)[0] < RISE_54_NEAR:   # $C93C
		s[F_KEEP2] = (s[F_KEEP2] + 1) & 0xFF
		go = w.slots[0][F_Y] < RISE_54_HIGH            # $BBFF
	if not go and not _arm_coming_54(w, s):            # $BD75
		return
	w.set_speed_down(s, 0x00, 0x00)                    # $C909
	w.set_speed_side(s, 0x00, 0x00)                    # $C906
	w.start_anim(s, ANIM_54_RISE)                      # $C83A
	s[F_SELF] = 3                                      # $BB60


## $BC1F -- straight up to the top of the room.
func _rise_54(w: Pb2Objects, s: PackedByteArray) -> void:
	w.sub_speed_down(s, LIFT_54)                       # $C90F
	w.step_anim(s)                                     # $C8EE
	w.step_both(s)
	if s[F_Y] >= CEIL_54:
		return
	w.set_speed_side_at_hero(s, WALK_54[0], WALK_54[1])    # $C900
	s[F_KEEP] = DROP_54_EVERY
	s[F_COUNT] = HOVER_54
	s[F_SELF] = 4                                      # $BB60


## $BC45 -- hanging there, bobbing, walking after him and letting something
## go every sixteenth frame.  When the count is out and he is near enough it
## stops and lets itself fall.
func _hover_54(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	_bob_54(w, s)                                      # $BD28
	w.step_anim(s)                                     # $C8EE
	w.step_both(s)
	if s[F_COUNT] == 0:
		if w.hero_side(s)[0] < DOWN_54_NEAR:           # $C93C
			w.set_speed_side(s, 0x00, 0x00)            # $C906
			w.set_speed_down(s, DOWN_54, 0x00)         # $C909
			s[F_SELF] += 1                             # $BB5C
			return
	else:
		s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if w.walled_ahead_turn(n, s, WALL_54_SIDE, WALL_54_LOW,
			WALL_54_HIGH, 0x00) >= 0x80:               # $C957
		w.turn_about(s)                                # $C91B
	s[F_KEEP] = (s[F_KEEP] - 1) & 0xFF
	if s[F_KEEP] != 0:
		return
	s[F_KEEP] = 0x20                                   # $BC71
	w.make_child_aimed(s, 0x00, 0x00, FALL_54, FALL_54_SPEED,
			FALL_54_ANG)                               # $C8E5


## $BC97 -- and down again, back to the beginning.
func _fall_54(w: Pb2Objects, s: PackedByteArray) -> void:
	w.add_speed_down(s, WEIGHT_54)                     # $C90C
	w.step_anim(s)                                     # $C8EE
	w.step_both(s)
	if s[F_Y] < FLOOR_54:
		return
	_start_54(w, s)                                    # $BCA7


## $BCAA -- it holds itself out as something to stand on.  For the length of
## the asking it says it stands a whole cell lower than it does, because the
## box is reckoned upwards from where a thing stands and this one is asked
## about from above.
func _offer_54(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_Y] = STAND_54_Y
	w.ride(s, STAND_54_WIDE, STAND_54_UP)              # $C8CD -> $8E06
	# $BCC0 -- and back to where it really stands, which the cartridge writes
	# out as a number and does not put back from anywhere.
	s[F_Y] = FLOOR_54


## $BCC4 -- and if he is standing on it, and something has just hurt him, it
## throws him off and takes four back into its own meter.
func _thrown_54(w: Pb2Objects, s: PackedByteArray) -> void:
	if s[F_KEEP] != 0:                                 # $05FA
		s[F_KEEP] = (s[F_KEEP] - 1) & 0xFF
		return
	var hero: PackedByteArray = w.slots[0]
	if (hero[F_MARK] & 0x60) != 0:                     # $BCD0
		_push_54(w, s)                                 # $BD23
		return
	if w.looking_away(s):                              # $C98D
		return
	if w.held < ON_TOP_54:                             # $0164
		return
	if hero[F_STUN] == 0:                              # $05B8
		return
	if (hero[F_MARK] & 0x01) != 0:                     # $BCE8
		s[F_KEEP] = THROWN_54_WAIT
	else:
		hero[F_KEEP2] = THROW_54_KEEP                  # $BCF2
	hero[F_VY] = THROW_54_UP                           # $BCF7
	hero[F_VX] = THROW_54_SIDE if s[F_VX] < 0x80 else (-THROW_54_SIDE) & 0xFF
	hero[F_VXFR] = 0x00
	hero[F_VYFR] = 0x00
	var life: int = s[F_LIFE] + HEAL_54                # $BD10
	s[F_LIFE] = HEAL_54_CAP if life >= HEAL_54_MAX else life
	# $C8C4 -- and the cartridge draws the meter here; the bar at the top of
	# the screen is the HUD's own work and waits for it.


## $BD23 -- the other half of standing on something: what to do about him now
## that the answer is known.  It is the same debt as $B91C, and nothing moves
## by it yet.
func _push_54(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_Y] = STAND_54_Y
	w.ride_apply(s, STAND_54_WIDE, STAND_54_UP)        # $C8CD -> $8E09
	s[F_Y] = FLOOR_54


## $BD28 -- the bob.  One count runs round and the low five bits read a table
## of noughts and ones; bit five reads it backwards and bit six turns it
## about, so that four-and-sixty frames make one rise and one fall.
func _bob_54(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_ANG] = (s[F_ANG] + 1) & 0xFF                   # $063C
	var t: int = s[F_ANG]
	var i: int = t & 0x1F
	if (t & 0x20) != 0:
		i = (~i) & 0x1F                                # $BD38
	var v: int = BOB_54[i]
	if ((t + 0x20) & 0x40) != 0:
		v = (-v) & 0xFF                                # $C858
	w.set_speed_down(s, v, 0x00)                       # $C909


## $BD75 -- is one of its own arms coming the other way?  Three places are
## looked at: one that is moving across and not up or down, near enough both
## ways, and on the side it is heading for.
func _arm_coming_54(w: Pb2Objects, s: PackedByteArray) -> bool:
	for k in range(1, CLEAR_54_LAST):                  # $BD77
		var o: PackedByteArray = w.slots[k]
		if (o[F_VX] | o[F_VXFR]) == 0:
			continue
		if (o[F_VY] | o[F_VYFR]) != 0:
			continue
		var d: int = s[F_Y] - o[F_Y]
		if abs(d) >= CLEAR_54_DOWN:                    # $BD93
			continue
		var e: int = s[F_X] - o[F_X]
		if abs(e) >= CLEAR_54_SIDE:                    # $BDA4
			continue
		# $BDA9 -- the arm is coming this way when it moves towards the side
		# the boss is on.
		if (o[F_VX] >= 0x80) == (e < 0):
			return true
	return false


# ------------------------------------------------------------------ $55
#
# $BDC0 (bank 1) -- the sixth one, which never walks anywhere.
#
# It fades out, appears again a set distance to one side of the hero, and
# from there throws one of two things at him: a single shot low and to the
# side, or a fan of six spread out along the line between them.  Nine steps
# go round and round: fade in, wait, move, fade out, ready, throw one, catch,
# throw six, rest.
#
# The fading is the top bit of $042C written out of a table of two-and-thirty
# noughts and eighties, which is what makes it flicker rather than melt.

## $BDEC -- how long each step of the round lasts.
const WAIT_55_FADE := 0x20
const WAIT_55_STILL := 0x80
const WAIT_55_SHOW := 0x20
const WAIT_55_READY := 0x10
const WAIT_55_THROW := 0x20
## $BE22 -- two-and-thirty noughts and eighties.  Read forwards it fades one
## way and backwards the other, and bit seven of $042C is what it writes.
const BLINK_55 := [
	0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80,
	0x00, 0x80, 0x80, 0x00, 0x80, 0x80, 0x00, 0x80,
	0x80, 0x00, 0x00, 0x80, 0x80, 0x00, 0x00, 0x80,
	0x80, 0x80, 0x00, 0x00, 0x00, 0x80, 0x80, 0x80]
## $BE4B -- where it comes back: a height out of the die, and a set distance
## to one side of the hero -- the far side, so that it is always on screen.
const HIGH_55 := [0x3F, 0x38]
const AWAY_55 := [0x60, 0xA0]
## $BE66, $BEA8, $BEFE -- the three pictures it wears: still, drawing back,
## and holding the fan.  Each throw is the picture after the one it stands in.
const PIC_55_STILL := 0xED
const PIC_55_DRAW := 0xEE
const PIC_55_FAN := 0xF0
## $BEBF and $BF13 -- how far into the throw the thing actually leaves.
const AT_55_ONE := 0x18
const AT_55_AIM := 0x1E
const AT_55_FAN := 0x14
## $BEC4 -- the single shot: what it is, how fast, how far out to the side
## and down, and the two ways it may be aimed.
const SHOT_55 := 0x4B
const SHOT_55_SPEED := 0x14
const SHOT_55_SIDE := [0xE8, 0x18]
const SHOT_55_ANG := [0x58, 0x28]
const SHOT_55_DOWN := 0xF0
## $BF32 -- the fan is aimed at a point six rows above his feet, $BF3A opened
## out by a fifth of the way round, and $BF49 six shots a twentieth apart.
const FAN_55 := 0x4C
const FAN_55_SPEED := 0x10
const FAN_55_LIFT := 0xF6
const FAN_55_OPEN := 0x20
const FAN_55_COUNT := 6
const FAN_55_STEP := 0x0C
## $BF95 -- and the band of heights at which the hero is taken hold of.
const HOLD_55_TOP := 0x8E
const HOLD_55_BOTTOM := 0x94
const HOLD_55_MARK := 0x40
const HOLD_55_DROP := 0xF0
## $BEEE -- which of its own numbers says it has hold of him.
const HELD_55 := 0x02
const READY_55 := 0x01


func _turn_55(w: Pb2Objects, _n: int, s: PackedByteArray) -> void:
	_hold_55(w, s)                                     # $BF87
	match s[F_SELF]:                                   # $BDC3
		0: _wake_55(s)
		1: _fade_in_55(s)
		2: _place_55(w, s)
		3: _fade_out_55(w, s)
		4: _draw_55(s)
		5: _throw_one_55(w, s)
		6: _caught_55(w, s)
		7: _throw_fan_55(w, s)
		8: _rest_55(s)


## $BF87 -- run before every one of the nine steps.  While it has hold of the
## hero his own two spare bytes are written: how far he is to be lifted, and
## the mark that says he is held.  Below the band he is simply dropped.
##
## The hero's code does not yet read either of them -- that is the same debt
## as the things he stands on ($B91C) -- so this writes what the cartridge
## writes and nothing moves by it yet.  $BF90 also puts out the weather while
## he is held, which is the palette's business and waits for the bar.
func _hold_55(w: Pb2Objects, s: PackedByteArray) -> void:
	if s[F_GROUND] != HELD_55:                         # $BF8A
		return
	var hero: PackedByteArray = w.slots[0]
	if hero[F_Y] < HOLD_55_TOP:                        # $BF95
		return
	if hero[F_Y] >= HOLD_55_BOTTOM:                    # $BF9B
		hero[F_GROUND] = HOLD_55_DROP                  # $BFAF
		return
	hero[F_REC_BYTE] = (HOLD_55_TOP - hero[F_Y]) & 0xFF
	hero[F_GROUND] = hero[F_GROUND] | HOLD_55_MARK


## $BDEC -- out of sight and out of reach, for as long as the fading takes.
func _wake_55(s: PackedByteArray) -> void:
	s[F_COUNT] = WAIT_55_FADE
	s[F_SELF] = 1
	s[F_MARK] = 0x80                                   # $C9AB


## $BDF9 -- fading in, one byte of the table a frame.
func _fade_in_55(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		s[F_BITS] = (s[F_BITS] & 0x7F) | BLINK_55[s[F_COUNT] & 0x1F]
		return
	s[F_KIND] = 0x00                                   # $BE0D
	s[F_BITS] = 0x00
	s[F_COUNT] = WAIT_55_STILL
	s[F_GROUND] = READY_55
	s[F_SELF] += 1                                     # $BDE5


## $BE42 -- and when the waiting is over it is set down again: a height out of
## the die, and a set distance from the hero, on whichever side keeps it in
## the room.
func _place_55(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	var r: int = w.random()                            # $C939
	s[F_Y] = ((r & HIGH_55[0]) + HIGH_55[1]
			+ (1 if w.rng_carry else 0)) & 0xFF
	var hero: int = w.slots[0][F_X]                    # $0508
	var away: int = AWAY_55[0] if hero < 0x80 else AWAY_55[1]
	s[F_X] = (away + hero) & 0xFF
	w.face_hero(s)                                     # $C8FD
	s[F_KIND] = PIC_55_STILL
	s[F_COUNT] = WAIT_55_SHOW
	s[F_SELF] += 1                                     # $BDE5


## $BE73 -- and fades back in, the table read the other way round.
func _fade_out_55(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		var i: int = (-s[F_COUNT]) & 0x1F              # $BE7B
		s[F_BITS] = (s[F_BITS] & 0x7F) | BLINK_55[i]
		return
	s[F_BITS] = 0x00
	w.face_hero(s)                                     # $C8FD
	s[F_MARK] = 0x01                                   # $C99F
	s[F_COUNT] = WAIT_55_READY
	s[F_SELF] += 1                                     # $BDE5


## $BEA2 -- a breath, and then the arm goes back.
func _draw_55(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	s[F_KIND] = PIC_55_DRAW
	s[F_COUNT] = WAIT_55_THROW
	s[F_SELF] += 1                                     # $BDE5


## $BEB5 -- the one shot, thrown out of the middle of the step and aimed by
## which way it looks rather than by where he is.
func _throw_one_55(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] == 0:
		s[F_COUNT] = WAIT_55_THROW                     # $BEE1
		s[F_KIND] = PIC_55_STILL
		s[F_SELF] += 1                                 # $BDE5
		return
	if s[F_COUNT] != AT_55_ONE:
		return
	s[F_KIND] = (s[F_KIND] + 1) & 0xFF                 # $BEC1
	var i: int = 1 if (s[F_BITS] & 0x40) != 0 else 0   # $C990
	w.make_child_aimed(s, SHOT_55_SIDE[i], SHOT_55_DOWN, SHOT_55,
			SHOT_55_SPEED, SHOT_55_ANG[i])             # $C8E5


## $BEEE -- it does not go on until it has hold of him.
func _caught_55(w: Pb2Objects, s: PackedByteArray) -> void:
	if s[F_GROUND] != HELD_55:
		return
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	w.face_hero(s)                                     # $C8FD
	s[F_KIND] = PIC_55_FAN
	s[F_COUNT] = WAIT_55_THROW
	s[F_SELF] += 1                                     # $BDE5


## $BF0B -- the fan.  A fifth of the way into the step it works out the line
## to a point six rows above his feet and opens the fan a fifth of the way
## round off it; a fifth later it lets all six go at once, each a twentieth
## of the way round from the last.
func _throw_fan_55(w: Pb2Objects, s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] == 0:
		s[F_COUNT] = WAIT_55_THROW                     # $BF71
		s[F_KIND] = PIC_55_STILL
		s[F_SELF] += 1                                 # $BDE5
		return
	if s[F_COUNT] == AT_55_AIM:
		w.face_hero(s)                                 # $C8FD
		var hero: PackedByteArray = w.slots[0]
		var ang: int = w._atan(s[F_X], s[F_Y], hero[F_X],
				(hero[F_Y] + FAN_55_LIFT) & 0xFF)      # $C8B2
		s[F_KEEP] = (ang - FAN_55_OPEN) & 0xFF
		return
	if s[F_COUNT] != AT_55_FAN:
		return
	s[F_KIND] = (s[F_KIND] + 1) & 0xFF                 # $BF40
	var a: int = s[F_KEEP]
	for _i in range(FAN_55_COUNT):                     # $BF4E
		w.make_child_aimed(s, 0x00, 0x00, FAN_55, FAN_55_SPEED, a)
		a = (a + FAN_55_STEP) & 0xFF
	# $BF6C -- and the sound $33 with them, which is the noise the cartridge
	# makes and not anything the table holds; the sound is its own work.


## $BF7E -- and then it goes out again and the round starts over.
func _rest_55(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	_wake_55(s)                                        # $BDEC


# ------------------------------------------------ $56, $57, $58 and $59
#
# $BDDE (bank 2) -- the four at the end of a stage, which share one body and
# differ only in four little tables and in one branch.
#
# It stands and shoots, and once in a while it leaps: up, along until it
# finds a wall, and down again, and the landing sets it going the other way.
# Six steps, kept in $058C and not in $05CE like everybody else, because the
# shell that wraps every boss keeps its own count in the same byte and takes
# over from the seventh on.
#
# $57 and $58 throw a thing straight out to the side; $56 and $59 work out
# the line to him and will not throw at all if he is too far round it.

## $BDF7, $BE86, $BE93, $BEA6, $BF88 -- how long each waiting lasts.
const WAIT_56_FIRST := 0x20
const WAIT_56_AFTER := 0x38
const WAIT_56_TURN := 0x06
const WAIT_56_AGAIN := 0x20
const WAIT_56_LAND := 0x40
## $BE7F, $BE8C, $BF95 -- standing, turning and holding still.
const PIC_56_SHOOT := 0xB8
const PIC_56_TURN := 0xB9
const PIC_56_STAND := 0xB7
## $BE18 -- above this out of the die it does not shoot but turns instead,
## and $BE1F it never shoots more than twice without turning.
const HOLD_56_ODDS := 0xB0
const HOLD_56_RUN := 0x02
## $BFBD -- what it throws, and $BFD6 how fast each of the four throws it.
const SHOT_56 := 0x44
const SHOT_56_SPEED := [0x0C, 0x0E, 0x0E, 0x0E]
const SHOT_56_SIDE := [0xEA, 0x16]
## $BE45 -- the line is taken to ten points above his feet, $BE4D turned an
## eighth of the way round and $BE51 thrown away if it is more than this,
## which is the arc in front of it that it can reach.
const AIM_56_LIFT := 0xF6
const AIM_56_TURN := 0x20
const AIM_56_ARC := 0x78
## $BE65 -- and the two ways the other pair throw, which are straight out.
const FLAT_56_ANG := [0x80, 0x00]
## $BEB9 -- the leap: the run it wears going up, and how hard it pushes off.
const ANIM_56_LEAP := 0x32
const LEAP_56 := [0xFF, 0x80]
## $BED3 and $BF80 -- how heavy it is going up and coming down, $BEDA and
## $BF57 how far below it it feels for the floor, $BEE1 and $BF63 the place
## it is set down on.
const WEIGHT_56 := 0x20
const FLOOR_56_UP := 0x10
const FLOOR_56_DOWN := 0x12
const SNAP_56 := 0x10
## $BF1F and $BF23 -- how fast each of the four travels while it is in the
## air, and $BF27/$BF2B how hard each comes down when it lands.
const GLIDE_56_FRAC := [0x80, 0x00, 0x80, 0x00]
const GLIDE_56_WHOLE := [0xFB, 0xFF, 0xFF, 0xFF]
const LAND_56_FRAC := [0x20, 0x40, 0x00, 0x00]
const LAND_56_WHOLE := [0xFF, 0xFC, 0xFB, 0xFB]
## $BF04 -- and how fast it starts to come down out of the leap.
const DROP_56 := 0x02
## $BF3B -- the wall it looks for, put out at two heights.
const WALL_56_SIDE := 0xEC
const WALL_56_HIGH := 0xF8
const WALL_56_LOW := 0x08
## $BF8D -- where the leap ends when it never found a wall at all.
const HOME_56_Y := 0x80
## $BECC -- which of the three boxes a big thing wears while it leaps.
const BOX_56_LEAP := 0x01


func _turn_56(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:                                  # $BDDE -> $C97E
		0: _wake_56(w, s)
		1: _shoot_56(w, s)
		2: _after_56(s)
		3: _leap_56(w, n, s)
		4: _glide_56(w, n, s)
		5: pass                                        # $BF9D


## $BDED -- nothing at all until the game is being played again, and then it
## may be touched and the first shot is set going.
func _wake_56(w: Pb2Objects, s: PackedByteArray) -> void:
	if w.playing != 3:                                 # $27
		return
	s[F_MARK] = 0x01                                   # $C99F
	s[F_SELF] = WAIT_56_FIRST
	s[F_STATE] += 1                                    # $C966


## $BE00 -- it watches him, and when the waiting is done it either throws
## something or turns round.  It turns when looking at him would have turned
## it anyway, when the die says so, when it has thrown twice already, or --
## for the two that aim -- when he is too far round for it to reach.
func _shoot_56(w: Pb2Objects, s: PackedByteArray) -> void:
	w.face_hero(s)                                     # $C8FD
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] != 0:
		return
	var was: int = s[F_BITS]
	_face_by_place_56(s)                               # $BF9E
	if was != s[F_BITS]:
		_turn_round_56(s)                              # $BE8C
		return
	if w.random() >= HOLD_56_ODDS:                     # $C939
		_turn_round_56(s)
		return
	if s[F_PUSH] >= HOLD_56_RUN:                       # $0626
		_turn_round_56(s)
		return
	var t: int = s[F_TYPE]
	if t == 0x57 or t == 0x58:                         # $BE23
		var mag: int = _speed_56(s)                 # $BFBD
		var i: int = 1 if (s[F_BITS] & 0x40) != 0 else 0   # $C990
		w.make_child_aimed(s, _side_56(s), 0x00, SHOT_56, mag,
				FLAT_56_ANG[i])                        # $C8E5
		_thrown_56(s)
		return
	# $BE2E -- the two that aim work the line out first and give it up if he
	# is behind them.
	var mag2: int = _speed_56(s)
	var hero: PackedByteArray = w.slots[0]
	var ang: int = w._atan((_side_56(s) + s[F_X]) & 0xFF, s[F_Y],
			hero[F_X], (hero[F_Y] + AIM_56_LIFT) & 0xFF)   # $C8B2
	if ((ang + AIM_56_TURN) & 0x7F) >= AIM_56_ARC:     # $BE51
		_turn_round_56(s)
		return
	w.make_child_at_hero(s, _side_56(s), 0x00, SHOT_56, mag2)   # $C8E2
	_thrown_56(s)


## $BFBD -- how fast this one of the four throws, and which side of itself it
## throws from.
func _speed_56(s: PackedByteArray) -> int:
	return SHOT_56_SPEED[(s[F_TYPE] - 0x56) & 0xFF]    # $BFD6


## $BFC9 -- out in front of it, which way round depending on how it looks.
func _side_56(s: PackedByteArray) -> int:
	return SHOT_56_SIDE[1] if (s[F_BITS] & 0x40) != 0 else SHOT_56_SIDE[0]


## $BE77 -- the throw made, it holds the pose and waits.
func _thrown_56(s: PackedByteArray) -> void:
	s[F_PUSH] = (s[F_PUSH] + 1) & 0xFF                 # $0626
	s[F_KIND] = PIC_56_SHOOT
	s[F_SELF] = WAIT_56_AFTER
	s[F_STATE] = 2                                     # $C972


## $BE8C -- and if it is not to throw, it turns, which takes it into the leap.
func _turn_round_56(s: PackedByteArray) -> void:
	s[F_KIND] = PIC_56_TURN
	s[F_SELF] = WAIT_56_TURN
	s[F_PUSH] = 0x00
	s[F_STATE] = 3                                     # $C975


## $BE9E -- the pose after a throw, and then round to the next one.
func _after_56(s: PackedByteArray) -> void:
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] != 0:
		return
	s[F_SELF] = WAIT_56_AGAIN
	_stand_56(s)                                       # $BF92


## $BF92 -- back on its feet, and back to watching him.
func _stand_56(s: PackedByteArray) -> void:
	s[F_MARK] = 0x01                                   # $C99F
	s[F_KIND] = PIC_56_STAND
	s[F_STATE] = 1                                     # $C96F


## $BEAC -- the turn, and out of it the leap.  While the count is still
## running it is only the pose; on the frame the count runs out it is thrown
## upwards, and after that it rises until it feels the ceiling of its own
## fall -- that is, until it meets the floor again on the way down.
func _leap_56(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	if s[F_SELF] != 0:
		s[F_SELF] = (s[F_SELF] - 1) & 0xFF
		if s[F_SELF] != 0:
			return
		s[F_MARK] = 0x20                               # $C9A5
		w.start_anim(s, ANIM_56_LEAP)                  # $C83A
		w.set_speed_side(s, 0x00, 0x00)                # $C906
		w.set_speed_down(s, LEAP_56[0], LEAP_56[1])    # $C909
		return
	w.boss_step = BOX_56_LEAP                          # $5F
	w.step_anim(s)                                     # $C8EE
	w.add_speed_down(s, WEIGHT_56)                     # $C90C
	if w.ground_turn_clear(n, s, 0x00, FLOOR_56_UP) < 0x80:    # $C945
		return
	w.snap16(s, SNAP_56)                               # $C984
	var i: int = (s[F_TYPE] - 0x56) & 0xFF             # $BFB5
	w.set_speed_side_facing(s, GLIDE_56_WHOLE[i], GLIDE_56_FRAC[i])   # $C903
	s[F_KEEP] = LAND_56_FRAC[i]
	s[F_KEEP2] = LAND_56_WHOLE[i]
	w.set_speed_down(s, DROP_56, 0x00)                 # $C909
	s[F_SELF] = 0x00
	s[F_STATE] += 1                                    # $C966


## $BF2F -- along and down.  It travels the way it looks until a wall stops
## it, and it bounces off the floor once, with the speed the tables hold; the
## second time it touches the floor the leap is over.  Coming down without
## ever having found a wall it is put back at the height it started from.
func _glide_56(w: Pb2Objects, n: int, s: PackedByteArray) -> void:
	w.boss_step = BOX_56_LEAP                          # $5F
	w.step_anim(s)                                     # $C837
	if s[F_SELF] == 0:
		if w.walled_ahead_turn(n, s, WALL_56_SIDE, WALL_56_LOW,
				WALL_56_HIGH, 0x00) >= 0x80:           # $C957
			s[F_SELF] = (s[F_SELF] + 1) & 0xFF
		else:
			w.step_side(s)                             # $C8F7
	if s[F_VY] < 0x80 \
			and w.ground_turn_clear(n, s, 0x00, FLOOR_56_DOWN) >= 0x80:
		if s[F_SELF] != 0:
			s[F_SELF] = WAIT_56_LAND                   # $BF88
			s[F_Y] = HOME_56_Y
			_stand_56(s)                               # $BF92
			return
		w.snap16(s, SNAP_56)                           # $C984
		s[F_VYFR] = s[F_KEEP]                          # $054A
		s[F_VY] = s[F_KEEP2]                           # $0534
	w.add_speed_down(s, WEIGHT_56)                     # $C90C
	w.step_down(s)                                     # $C8F4


## $BF9E -- which way it ought to look, which is which half of the room it is
## standing in and not where he is.
func _face_by_place_56(s: PackedByteArray) -> void:
	if s[F_X] < 0x80:
		s[F_BITS] = s[F_BITS] | 0x40
	else:
		s[F_BITS] = s[F_BITS] & 0xBF
