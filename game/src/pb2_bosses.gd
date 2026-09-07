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


## $F107 -- which bank holds which boss.  A boss whose mind has not been
## carried over yet is not in here, and the shell then leaves it standing.
const DRIVEN := {0x50: "_turn_50", 0x51: "_turn_51", 0x52: "_turn_52"}


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
