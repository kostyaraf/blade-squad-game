extends RefCounted
class_name Pb2Objects

## The table of live things and the scan that fills it -- $E3F3 in bank 15.
##
## The level's list says what stands where, sorted along the way the view
## travels.  Nothing is alive until the view uncovers it: once a step, and only
## in a step in which the view moved, the game walks the list and turns into an
## object every record that has just come over the edge of the screen.  Killing
## one does not use the record up -- back the view goes, and there it is again.

const SLOTS := 22
## $801A and $D36B: the sweep and the slide walk from here to the end.
const FIRST_LIVE := 0x06

## $E55E -- the four types the area gives out once each time it opens.
const ONCE_A_VISIT := [0x24, 0x3E, 0x40, 0x3A]
## $E499 and $E4B3: the records of a level may only be put in these.  The
## search runs upwards but keeps the last free one it saw, not the first, so
## they fill from the top down.
const FIRST_PLACED := 0x0E
const LAST_PLACED := 0x15
const END_OF_LIST := 0xFF

## The cartridge keeps a thing's twenty-nine bytes as twenty-nine tables of
## twenty-two, from $0400 to $0668: field f of place n lives at $0400 + 22*f + n.
## Here the same table is read the short way about -- twenty-two places of
## twenty-nine bytes -- so a place is one row and the field number is
## (address - $0400) / 22.
const FIELDS := 29
const F_TYPE := 0        ## $0400 -- what it is; zero means the place is free
const F_MARK := 1        ## $0416 -- a bitfield; eight at birth
const F_BITS := 2        ## $042C -- bit 6 is which way it looks
const F_KIND := 3        ## $0442 -- to the type's own taste: mostly the picture
const F_ANIM := 4        ## $0458 -- which run of pictures it is walking through
const F_STEP := 5        ## $046E -- and which step of that run it is on
const F_REC := 6         ## $0484 -- which record it came from, one-based
## $049A -- the record's third byte: health, and for a collectable
## which of the sixteen it is.  $FF means it cannot be killed.
const F_LIFE := 7
const F_YHI := 8         ## $04B0 -- how many screens off the top, signed
const F_Y := 9           ## $04C6 -- where down the screen
const F_YFR := 10        ## $04DC -- and the 1/256ths of a point
const F_XHI := 11        ## $04F2
const F_X := 12          ## $0508
const F_XFR := 13        ## $051E
const F_VY := 14         ## $0534 -- whole points a step, signed
const F_VYFR := 15       ## $054A -- and the 1/256ths
const F_VX := 16         ## $0560
const F_VXFR := 17       ## $0576
const F_STATE := 18      ## $058C -- which row of the table laid after JSR $C97E
const F_HOLD := 19       ## $05A2 -- frames left to hold the step of the run
const F_STUN := 20       ## $05B8 -- while it is not zero the turn is skipped
const F_SELF := 21       ## $05CE -- to the type's own taste; often its record byte
const F_COUNT := 22      ## $05E4 -- a count of frames the type keeps itself
const F_KEEP := 23       ## $05FA -- to the type's own taste
const F_KEEP2 := 24      ## $0610 -- and another
const F_PUSH := 25       ## $0626 -- which way a blow threw it; also, for the
                         ##          ones that circle, the whole of the angle
const F_ANG := 26        ## $063C -- and its 1/256ths
const F_REC_BYTE := 27   ## $0652 -- where a type keeps the record's own byte
                         ##          when the field it came in is wanted
const F_GROUND := 28     ## $0668 -- nought in the air, $81 standing, $82 in
                         ##          the water that has risen


var lvl: Pb2Level
## Twenty-two rows of twenty-nine bytes.
var slots: Array = []
## $E5B1 -- which bit of `got` a collectable answers to.
var pickup_bit := PackedByteArray()
## $8401 -- which picture it wears.
var pickup_pic := PackedByteArray()
## The runs of pictures, out of bank 6 by way of $802D.
var anims: Array = []

## $9D72 -- how long the one that shuttles walks before it turns.
var swing := PackedByteArray()
## $9EE1 and $9EE9 -- eight speeds for the one that circles, low byte and high.
var spin_lo := PackedByteArray()
var spin_hi := PackedByteArray()
## $F301 -- a quarter of a turn's worth of cosine, out of the fixed bank.
var trig := PackedByteArray()
## $FD31 -- the shift that sits a thing on the floor line of its own tile.
var snap := PackedByteArray()
## $F64F -- the same quarter turn as $F301, scaled to $20 for $F5BA.
var aim := PackedByteArray()
## $F783, $F76F and $F77F -- the three tables $F6E2 turns a pair of
## lengths into an angle with.
var atan := PackedByteArray()
var octant := PackedByteArray()
var quarter := PackedByteArray()
## $B44F -- how far above $04C6 the middle of a thing lies, signed.
var middle := PackedByteArray()
## $B3EF -- how much health a touch of this type takes off the hero.
var hurt := PackedByteArray()
## $B768 -- half a width and half a height per type.  A big thing ($50 and up)
## has three of them and picks by $5F, the step it is on.
var box: Array = []
## $B721 and $B725 -- how hard a shot hits and how big it is, by its own type.
var shot_power := PackedByteArray()
var shot_size := PackedByteArray()
## $B717 -- the state a big thing goes into when it is killed.
var big_death := PackedByteArray()
## $B73C and $B764 -- two lists of types death reads.
var leaves_one := PackedByteArray()
var written_down := PackedByteArray()

## $8212 and $820A -- which sweep a type belongs to and how far past the edge
## that sweep lets a thing get.  Read from data/pb2/objects.json.
var cull_class := PackedByteArray()
var cull_margin := PackedByteArray()
var cull_rules: Array = []

## $8080 -- the minds the engine has of its own.  A type that is not in here
## is still told what it did; a type that is drives itself and is compared.
const MINDS := {0x02: "_mind_02", 0x10: "_mind_10", 0x23: "_mind_23",
		0x12: "_mind_12", 0x17: "_mind_17", 0x19: "_mind_19",
		0x13: "_mind_13", 0x1D: "_mind_1d",
		0x2C: "_mind_2c", 0x2D: "_mind_2c",
		0x42: "_mind_42",
		0x2E: "_mind_2c",
		0x22: "_mind_22", 0x37: "_mind_37", 0x2F: "_mind_2f",
		0x1E: "_mind_1e", 0x38: "_mind_38", 0x24: "_mind_24",
		0x3C: "_mind_3c", 0x1B: "_mind_1b", 0x1A: "_mind_1a", 0x15: "_mind_15"}

## $0119 -- one up every frame; $FB81 halves it between the places.
var clock := 0
## $1C -- the console's own count of pictures.  The touch sweep looks at half
## the places in one picture and the other half in the next, and it is this
## count, not $0119, that says which half.
var frame := 0
## $27 -- three while a level is being played.
var playing := 3
## $5F -- which step a big thing is on; its box changes with it.
var boss_step := 0
## $4A -- the switches of the level; $B5B7 reads bit three of it.
var switch := 0
## $0164 -- what has hold of the hero.  It is the hero's own book-keeping
## ($B90D in bank 9, and the moving floor at $A3C0 clears it); the things
## only read it.
var held := 0
## The harness hands the hero's row over from the cartridge, already counted
## down and already blinked.  When it does, the touch sweep must not count it
## down a second time.
var hero_told := false
## $0168:$0169 -- the seed the whole game shares.
var seed := 0
## $9A -- which suit he has on; nought is none.
var suit := 0
## $29 -- the line the water or the lava has climbed to.  The area is entered
## with the line its record names ($87 says what sort of area it is); four
## little routines under $CEE0 move it after that, and they run at the head of
## the level's frame, before anything else.
var water := 0
## What the last stirring of the seed left in the carry.
var rng_carry := false
## $2A -- while it is set the level stands still.
var frozen := 0
## $66:$67 -- where the view stands; the minds read the map through it.
var cam := 0
## $FC -- how far down the level the screen itself has been drawn, in lines,
## kept between nought and two hundred and thirty nine ($DA97).  It is not the
## view: the view is moved in one go and the screen is drawn a line at a time,
## so in a frame where the view jumps the two part company for that frame.
## Down a level a thing asks the ground about the screen ($F52C), so it is
## this and not the view that road must read.  Below nought it means the
## harness has not said, and the view answers for it.
var draw := -1
## $94 -- how far the view moved this frame; a thing that holds an old place
## of its own has to move it back by the same, or its circle would ride along
## with the screen instead of standing in the world.
var slide := 0
## $2B:$2C -- the sixteen collectables taken for good.
var got := 0
## $0172, $0171 long -- what this visit of the area has given out.
var done: Array = []
## $8A -- set as the area opens, so that the first scan fills the whole screen
## and not only its edge.  The first scan to reach the end of the list, or a
## record that is still ahead of the screen, puts it out.
var fill := 0


func _init(level: Pb2Level) -> void:
	lvl = level
	water = lvl.line
	for i in range(SLOTS):
		slots.append(empty_row())
	var f := FileAccess.open("res://data/pb2/objects.json", FileAccess.READ)
	var t: Dictionary = JSON.parse_string(f.get_as_text())
	# Every number that comes back from JSON is a float, and a float will not
	# even be compared with a word without complaint, so they are put back into
	# the shape the code below expects once, here.
	pickup_bit = PackedByteArray(t["pickup_bit"])
	pickup_pic = PackedByteArray(t["pickup_pic"])
	cull_class = PackedByteArray(t["cull_class"])
	cull_margin = PackedByteArray(t["cull_margin"])
	for r in t["cull_rules"]:
		var rule := {}
		for k in ["horiz", "vert"]:
			rule[k] = r[k] if r[k] is String else int(r[k])
		cull_rules.append(rule)
	for v in t["swing"]:
		swing.append(int(v))
	for v in t["spin_lo"]:
		spin_lo.append(int(v))
	for v in t["spin_hi"]:
		spin_hi.append(int(v))
	for v in t["trig"]:
		trig.append(int(v))
	for v in t["snap"]:
		snap.append(int(v))
	for v in t["aim"]:
		aim.append(int(v))
	for v in t["atan"]:
		atan.append(int(v))
	for v in t["octant"]:
		octant.append(int(v))
	for v in t["quarter"]:
		quarter.append(int(v))
	middle = PackedByteArray(t["middle"])
	hurt = PackedByteArray(t["hurt"])
	shot_power = PackedByteArray(t["shot_power"])
	shot_size = PackedByteArray(t["shot_size"])
	big_death = PackedByteArray(t["big_death"])
	leaves_one = PackedByteArray(t["leaves_one"])
	written_down = PackedByteArray(t["written_down"])
	for r in t["box"]:
		var steps := []
		for pair in r:
			steps.append([int(pair[0]), int(pair[1])])
		box.append(steps)
	for r in t["anims"]:
		var run := {"last": int(r["last"]), "hold": int(r["hold"]),
				"first": int(r["first"])}
		if r.has("steps"):
			var steps := []
			for v in r["steps"]:
				steps.append(int(v))
			run["steps"] = steps
		anims.append(run)


static func empty_row() -> PackedByteArray:
	var row := PackedByteArray()
	row.resize(FIELDS)
	return row


## $E3F3.  `pos` is $66:$67 as the step begins, before the view has moved, and
## `shift` is how far it moved in the step BEFORE this one: the scan runs at
## $CF0E and the view is driven at $CF11, so what it reads is last step's.
func scan(pos: int, shift: int) -> void:
	if shift == 0 and fill == 0:
		return
	var world := _world(pos)
	var edge := (world >> 4) & 0xFF
	var list: Array = lvl.spawns
	for i in range(list.size()):
		var rec: Dictionary = list[i]
		var along: int = int(rec["along"])
		if along == END_OF_LIST:
			break
		# $E44D: everything before the view's own column is behind us.
		if along < edge:
			continue
		var delta: int = (along << 4) - world
		if delta > 0xFF:
			break                        # $E472 -- still ahead; so is the rest
		if delta < 0:
			continue                     # $E474 -- behind
		if fill == 0:
			# $E47E: only what has just come over the edge, and which edge
			# depends on which way the view is going.
			if shift >= 0:
				if delta < 0xF8:
					continue
			elif delta >= 0x08:
				continue
		_place(i + 1, rec, delta)
	fill = 0


## $E497 -- find it a slot, unless it already has one.
func _place(rec_index: int, rec: Dictionary, delta: int) -> void:
	var free := -1
	for n in range(FIRST_PLACED, LAST_PLACED + 1):
		var s: PackedByteArray = slots[n]
		if s[F_TYPE] == 0:
			free = n                     # $E50D -- the last free one wins
		elif s[F_REC] == rec_index:
			return                       # $E4AE -- it is out there already
	if free < 0:
		return                           # $E4BA -- no room; it is dropped
	# $E4BD and $E4C2 -- the two things that are not put out twice.
	if _gated(rec_index, rec):
		return
	# $D6D4 wiped the whole record a moment ago, high bytes and all.
	var s: PackedByteArray = empty_row()
	slots[free] = s
	s[F_TYPE] = int(rec["type"])
	s[F_LIFE] = int(rec["flags"])
	s[F_REC] = rec_index
	s[F_MARK] = 0x08
	# $E4DB: down a level the record's own number is the height and the other
	# byte the width; along a level it is the other way about.
	if lvl.vertical:
		s[F_X] = int(rec["across"])
		s[F_Y] = delta
	else:
		s[F_X] = delta
		s[F_Y] = int(rec["across"])


## Something that is not the level's list has written a type here.  The engine
## has no minds for the things yet, so it is simply told; what matters to the
## scan is only whether the place is free.
##
## A thing that was already there and merely changed into something else keeps
## its record: it is still that record's thing, and the scan must go on passing
## it by.  Only an empty place that fills from somewhere else becomes a stranger,
## with no record at all, so that no record ever takes it for itself.
func take(n: int, what: int) -> void:
	var s: PackedByteArray = slots[n]
	if s[F_TYPE] == 0:
		s[F_REC] = 0
	s[F_TYPE] = what


## $D6D4 -- everything about the slot goes, the record's number with it, so
## the same record will be made again if the view comes back over it.
func clear(n: int) -> void:
	slots[n] = empty_row()


## $E3F7 and $E422 -- how far the view has travelled counted in pixels.  Down a
## level a screen is two hundred and forty lines, not two hundred and fifty six.
func _world(pos: int) -> int:
	if lvl.vertical:
		return (pos >> 8) * 240 + (pos & 0xFF)
	return pos


## $D34D -- the view slid by `dv`, so everything standing on the screen slid
## back by it.  Both bytes at once: the console does it as a sixteen-bit
## subtraction, the low byte with the borrow going into the high one, and the
## sign of the slide carried up through $00.
##
## Only the way the level runs is touched; across it nothing scrolls.
func shift(dv: int) -> void:
	slide = dv & 0xFF
	var hi := F_YHI if lvl.vertical else F_XHI
	var lo := F_Y if lvl.vertical else F_X
	for n in range(FIRST_LIVE, SLOTS):
		var s: PackedByteArray = slots[n]
		if s[F_TYPE] == 0:
			continue
		var v := (((s[hi] << 8) | s[lo]) - dv) & 0xFFFF
		s[lo] = v & 0xFF
		s[hi] = v >> 8


## $B0C0 in bank 11 -- the big one that grabs him (12 records).
##
## Every frame, before anything else, it tells the hero he is held ($BF20,
## which reaches $B90D in bank 9) and stands on the ground.  The first is the
## hero's own book-keeping -- $0160, $0161 and $0164 -- and writes nothing in
## the table of things, so the engine leaves it to him.
func _mind_38(n: int, s: PackedByteArray) -> void:
	ground_stand_deep(s, 0xE8)                         # $9BA5
	if s[F_STATE] == 0:
		_wake_38(s)
	elif s[F_STATE] == 1:
		_walk_38(n, s)
	else:
		_rush_38(n, s)


## $B0D5 -- it wakes walking away from him.
func _wake_38(s: PackedByteArray) -> void:
	s[F_LIFE] = 0x08                                   # $BE5A 08
	s[F_MARK] = 0x01
	start_anim(s, 0x1F)                                # $BEAD 1F
	record_home_along(s)                               # $C9B1
	set_speed_side_at_hero(s, 0x01, 0xC0)              # $BEBF C0 01
	turn_about(s)                                      # $C91B
	s[F_STATE] += 1                                    # $C966


## $B0EB -- walking, and looking for the moment to rush.
func _walk_38(n: int, s: PackedByteArray) -> void:
	step_anim(s)                                       # $C8EE
	step_both(s)
	_grab_38(s)                                        # $B198
	if s[F_SELF] != 0:
		s[F_SELF] = (s[F_SELF] - 1) & 0xFF
		if s[F_SELF] == 0:
			s[F_SELF] = 0x14                           # $BE75 14
			s[F_STATE] += 1                            # $C966
			return
	# $B102 -- a wall ahead, and it waits a frame.
	if walled_ahead_turn(n, s, 0x24, 0xEC, 0xFF, 0x00) >= 0x80:
		s[F_SELF] = 0x01
		return
	# $B10A -- how far ahead the ground goes: two and a bit tiles when he is
	# close by, two and a half when he is not.
	var down: Array = hero_down(s)                     # $C93F
	var out := 0x28
	if not bool(down[2]) and int(down[0]) < 0x10:
		out = 0x22
	if s[F_BITS] & 0x40:                               # $C990
		out = (0x100 - out) & 0xFF
	var under: int = ground_turn_wall(n, s, out, 0x04)  # $C948 with Y = 4
	if under < 0x80 and under != 0x01 and not in_water(s):
		s[F_SELF] = 0x01                               # $9C44 -- nothing there
		return
	if s[F_SELF] != 0:
		return
	if strayed_far(s):                                 # $ACD0
		s[F_SELF] = 0x01
		return
	var side: Array = hero_side(s)                     # $C93C
	if bool(side[2]):
		return
	if int(side[0]) < 0x18:
		return
	if looking_away(s):                                # $C98D -- $B14E BCS
		return
	s[F_SELF] = 0x20


## $B15A -- the rush.  It bleeds speed for as long as its own byte lasts and
## wears the other picture for the last ten frames of it.
func _rush_38(n: int, s: PackedByteArray) -> void:
	step_side(s)                                       # $C8F7
	_grab_38(s)                                        # $B198
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] != 0:
		step_anim(s)                                   # $C837
		if s[F_SELF] < 0x0A:
			s[F_KIND] = 0xB6                           # $BE6E B6
		# $B175 -- the cartridge looks at the whole of the speed across and
		# takes the sixteenth off the way it is already going, so the run is
		# a slowing one: away from him it adds, towards him it takes away.
		if s[F_VX] & 0x80:
			add_speed_side(s, 0x10)                    # $B17A -> $C912
		else:
			sub_speed_side(s, 0x10)                    # $B17D -> $C915
		return
	# $B180 -- it has run itself out.
	if strayed_far(s):                                 # $ACD0
		s[F_SELF] = 0x60                               # $BE75 60
	turn_about(s)                                      # $C91B
	set_speed_side_facing(s, 0x01, 0xC0)               # $BEC5 C0 01
	start_anim(s, 0x1F)                                # $BEAD 1F
	s[F_STATE] -= 1                                    # $C969


## $B198 and $B1A8 -- it holds him, and throws him.
##
## Only one field of its own is touched: the count, which is how long it
## waits before it may throw again.  The rest is the hero's own row, which
## the harness hands over, and $0164, which he keeps for himself.
func _grab_38(s: PackedByteArray) -> void:
	if s[F_COUNT] != 0:
		s[F_COUNT] -= 1
		return
	var hero: PackedByteArray = slots[0]
	if (hero[F_MARK] & 0x60) != 0:
		return                                         # $B1A1 -- already held
	if not looking_away(s):                            # $C98D -- $B1B2 BCC
		return
	if hero[F_STUN] == 0:
		return
	if held < 0x03:                                    # $0164
		return
	if (hero[F_MARK] & 0x01) != 0:
		s[F_COUNT] = 0x20
	else:
		hero[F_KEEP2] = 0xF8
	hero[F_VY] = 0xFC
	hero[F_VX] = 0x08 if not (s[F_VX] & 0x80) else 0xF8
	hero[F_VXFR] = 0x00
	hero[F_VYFR] = 0x00


# --- Touching ---------------------------------------------------------
#
# $B23D and what hangs off it, all in bank 7.  See work/re/pb2_contact.md.
# It runs at $CF08, between the hero's own step and the turns of the things,
# and it works from his side: he walks the places and settles who touched
# whom, both ways -- his shoulder against a thing, and his shots against it.


## Two bytes, and how far apart they are, in eight bits ($B2EF).
static func _apart(a: int, b: int) -> int:
	var d := (a - b) & 0xFF
	if a >= b:
		return d
	return (0x100 - d) & 0xFF


## $B768 -- half a width and half a height.  A big thing keeps three of them
## and picks by the step it is on.
func _box_of(s: PackedByteArray) -> Array:
	var t: int = s[F_TYPE]
	var b: Array = box[t]
	if t < 0x50 or b.size() == 1:
		return b[0]
	return b[boss_step % b.size()]


## $B44F -- the middle of a thing, up the screen from where it stands.
func _middle_of(s: PackedByteArray) -> int:
	return (s[F_Y] - middle[s[F_TYPE]]) & 0xFF


## $B23D -- the sweep.
##
## Half the places in one picture and half in the next: a thing is asked about
## only every other frame, and slipping past one at speed without being touched
## is something the cartridge lets happen.
func contact() -> void:
	if playing != 3:
		return
	var hero: PackedByteArray = slots[0]
	if hero[F_LIFE] == 0:
		return
	# $B248 -- the forty pictures after a blow are counted down here and
	# nowhere else, and he flashes for as long as they last.  When the harness
	# hands his row over it has already been counted down on the cartridge.
	if not hero_told and hero[F_STUN] != 0:
		hero[F_STUN] -= 1
		hero[F_BITS] ^= 0x80
	var n: int = 6 if (frame & 1) != 0 else 7
	while n < SLOTS:
		var s: PackedByteArray = slots[n]
		if slots[0][F_LIFE] != 0 and s[F_TYPE] != 0 \
				and (s[F_XHI] | s[F_YHI]) == 0:
			_touch(n)
			_shots(n)
		n += 2


## $B285 -- is this one asked about at all, and does the hero reach it?
func _touch(n: int) -> void:
	var s: PackedByteArray = slots[n]
	var hero: PackedByteArray = slots[0]
	if s[F_TYPE] == 0x0C:
		return                                  # the door is never touched
	if hero[F_LIFE] == 0:
		return
	if hero[F_STUN] != 0:
		# While he flashes only two sorts still reach him.
		if (s[F_MARK] & 0x50) == 0:
			return
	else:
		hero[F_BITS] &= 0x7F                    # $B29E -- done flashing
		if (s[F_MARK] & 0x88) != 0:
			return
	# His own box depends on what he is doing ($B2C1).
	var up := 0x0F
	var half_w := 6
	var half_h := 13
	if (hero[F_MARK] & 0x08) != 0:
		up = 0x0C
		half_w = 4
		half_h = 9
	elif (hero[F_MARK] & 0x10) != 0:
		up = 0x08
		half_w = 8
		half_h = 8
	var b := _box_of(s)
	var mid := _middle_of(s)
	var dx := _apart(hero[F_X], s[F_X])
	var dy := _apart((hero[F_Y] - up) & 0xFF, mid)
	if ((int(b[0]) + half_w) & 0xFF) < dx:
		return
	if ((int(b[1]) + half_h) & 0xFF) < dy:
		return
	if (s[F_MARK] & 0x40) != 0:
		_pick_up(n)                             # $B4AF
		return
	if (s[F_MARK] & 0x10) != 0:
		_trip(n)                                # $B5A5
		return
	_wound_hero(n)                              # $B39E
	s = slots[n]
	if s[F_MARK] == 0x80 or s[F_TYPE] == 0:
		return                                  # $B33D -- it is already gone
	# $B36A -- forty pictures of grace, and which way the blow threw him.
	hero[F_STUN] = 0x28
	if (s[F_MARK] & 0x02) != 0:
		hero[F_PUSH] = 0xFF
	elif hero[F_X] >= s[F_X]:
		hero[F_PUSH] = 0x00
	else:
		hero[F_PUSH] = 0x01
	if (s[F_MARK] & 0x02) != 0:
		clear(n)                                # it ends on him


## $B39E -- the suit strikes back, and what is left of the blow reaches him.
func _wound_hero(n: int) -> void:
	var s: PackedByteArray = slots[n]
	var hero: PackedByteArray = slots[0]
	if (hero[F_MARK] & 0x10) != 0 and suit != 0:
		if (s[F_MARK] & 0x02) != 0:
			clear(n)
			return
		_wound(n, 3)
		if slots[n][F_LIFE] == 0:
			return                              # it died; he is not touched
	# $B3C0 -- health off him, by what the thing is.
	if hero[F_LIFE] == 0:
		return
	var v: int = hero[F_LIFE] - hurt[s[F_TYPE]]
	hero[F_LIFE] = v & 0xFF
	if v <= 0:
		hero[F_LIFE] = 0
		hero[F_KEEP] = 0
		slide = 0


## $B4AF -- what he picks up.  The thing is gone either way; the second sort
## is remembered for the whole game ($E580).
##
## What each one gives him -- $B4CD and the eight little routines after it --
## is his own counters, not the table, and waits for the head-up display.
func _pick_up(n: int) -> void:
	var s: PackedByteArray = slots[n]
	var what: int = s[F_TYPE]
	if what == 0x02:
		var f: int = s[F_LIFE]
		var bit: int = pickup_bit[(f >> 4) & 0x0F]
		if (f & 1) != 0:
			got |= bit << 8
		else:
			got |= bit
	if what == 0x01 or what == 0x02:
		clear(n)


## $B5A5 -- the ones that go off when he stands on them.
func _trip(n: int) -> void:
	var s: PackedByteArray = slots[n]
	if s[F_TYPE] == 0x03:
		if slots[0][F_MARK] != 0:
			return
		if (switch & 0x08) == 0:
			return
	s[F_STATE] = 0x02
	s[F_MARK] = 0x80


## $B5D5 -- his five shots against this one thing.
func _shots(n: int) -> void:
	var s: PackedByteArray = slots[n]
	if s[F_STUN] != 0:
		return
	if (s[F_BITS] & 0x80) != 0:
		return
	for y in range(1, 6):
		var shot: PackedByteArray = slots[y]
		if (shot[F_YHI] | shot[F_XHI]) != 0:
			continue
		var what: int = shot[F_TYPE]
		if what == 0:
			continue
		if what >= shot_size.size():
			continue          # nothing the hero throws is bigger than three
		_hit(n, y, shot_size[what])


## $B606 -- can this shot hurt this thing, and does it reach it?
func _hit(n: int, y: int, size: int) -> void:
	var s: PackedByteArray = slots[n]
	if s[F_TYPE] == 0:
		return
	if s[F_LIFE] == 0xFF:
		return                                  # nothing can break it
	if s[F_STUN] != 0:
		return
	if (s[F_MARK] & 0xDA) != 0:
		return
	if (s[F_BITS] & 0x80) != 0:
		return
	var b := _box_of(s)
	var mid := _middle_of(s)
	var shot: PackedByteArray = slots[y]
	var dx := _apart(shot[F_X], s[F_X])
	var dy := _apart(shot[F_Y], mid)
	if ((int(b[0]) + size) & 0xFF) < dx:
		return
	if ((int(b[1]) + size) & 0xFF) < dy:
		return
	if (s[F_MARK] & 0x20) != 0:
		s[F_STUN] = 0x08                        # armour: it only rings
		return
	# $B688 -- the door opens instead of dying.
	if s[F_TYPE] == 0x0C:
		s[F_STATE] = 0x02
		s[F_MARK] = 0x80
		return
	_wound(n, shot_power[slots[y][F_TYPE]])


## $B698 -- health off a thing, and what is left of it when there is none.
func _wound(n: int, power: int) -> void:
	var s: PackedByteArray = slots[n]
	if s[F_LIFE] == 0xFF:
		return
	var v: int = s[F_LIFE] - power
	s[F_LIFE] = v & 0xFF
	if v > 0:
		s[F_STUN] = 0x08 if s[F_TYPE] < 0x50 else 0x10
		return
	if s[F_TYPE] >= 0x50:
		# $B6FC -- a big one has a death of its own to walk through.
		s[F_STATE] = big_death[s[F_TYPE] - 0x50]
		s[F_LIFE] = 0
		s[F_MARK] = 0x80
		return
	var what: int = s[F_TYPE]
	s[F_LIFE] = 0
	s[F_STATE] = 0
	s[F_KEEP2] = 0
	# $B729 -- a few sorts leave a one behind for the burst to read.
	s[F_KEEP] = 1 if leaves_one.has(what) else 0
	# $B747 -- and the four that the area only gives out once are written
	# down, so that this visit does not give them out again.
	if written_down.has(what):
		done.append(s[F_REC])
	# It does not free its place: it turns into the burst, and the burst
	# frees it when it has finished.
	s[F_TYPE] = 0x01
	s[F_MARK] = 0x80



## $92E7 (bank 10) -- the one that stands off and spits.
##
## It sets itself going, turns its face away from him -- only the face; the
## speed it was just given still points his way -- and then walks, letting one
## of type $25 go every thirty frames while he is within a quarter screen.
func _mind_24(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_LIFE] = 0x04                               # $BE5A
		s[F_MARK] = 0x01
		start_anim(s, 0x15)                            # $BEAD
		set_speed_side_at_hero(s, 0xFE, 0x80)          # $BEBF with 80 FE
		turn(s)                                        # $C918
		s[F_STATE] += 1                                # $C966
		return
	if s[F_COUNT] != 0:
		s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	else:
		var side: Array = hero_side(s)                 # $C93C
		if not side[2] and side[0] < 0x40:
			# Behind it, whichever way it is going.
			var off: int = 0x08 if s[F_VX] < 0x80 else 0xF8
			if make_child(s, off, 0x04, 0x25) >= 0:    # $C8DF
				s[F_COUNT] = 0x1E
	step_anim(s)                                       # $C8EE -- $FA05
	step_both(s)


## $BDA3 (bank 11) -- the three shapes the boxed walk knows.  Six signed
## bytes each: how far below and how far above to ask about the floor and the
## ceiling, then the two heights at which to ask about a wall, then how far
## out to ask, going right and going left.  The fourth entry of the table
## points at the third.
const BOXED := [[0x10, 0xF0, 0x08, 0xF8, 0x0C, 0xF4],
		[0x04, 0xE0, 0xFC, 0xEC, 0x0C, 0xF4],
		[0x04, 0xE0, 0xF8, 0xE8, 0x0C, 0xF4],
		[0x04, 0xE0, 0xF8, 0xE8, 0x0C, 0xF4]]


## $BCBB (bank 11) -- move both ways, and be stopped by whatever is in the
## way.
##
## The four low bits of $0668 are the four sides it is pressed against: one
## and two up and down, sixty-four and one hundred and twenty-eight right and
## left.  While a side is set the thing has already been stopped there, so the
## wall behind it is only asked about again every other frame ($BE3E); turning
## round frees it at once.  Being stopped zeroes the speed on that axis and
## sets the side.
func move_boxed(n: int, s: PackedByteArray, shape: int) -> void:
	var t: Array = BOXED[shape]
	if (s[F_VY] | s[F_VYFR]) != 0:
		var g: int = s[F_GROUND]
		var go := true
		if (g & 0x01) != 0:
			# Held against the ceiling: falling frees it, rising waits.
			if s[F_VY] < 0x80:
				_free_up_down(s)
			else:
				go = its_turn(n, clock)
		elif (g & 0x02) != 0:
			if s[F_VY] >= 0x80:
				_free_up_down(s)
			else:
				go = its_turn(n, clock)
		if go:
			var down: int = t[0] if s[F_VY] < 0x80 else t[1]
			if walled_either_turn(n, s, 0x07, down, 0x00) < 0x80:
				step_down(s)                       # $C8F4
				_free_up_down(s)
			else:
				_free_up_down(s)
				s[F_GROUND] = s[F_GROUND] | (0x02 if s[F_VY] < 0x80 else 0x01)
				s[F_VY] = 0
				s[F_VYFR] = 0
	if (s[F_VX] | s[F_VXFR]) == 0:
		return
	var g2: int = s[F_GROUND]
	var go2 := true
	if (g2 & 0x80) != 0:
		if s[F_VX] < 0x80:
			_free_side(s)
		else:
			go2 = its_turn(n, clock)
	elif (g2 & 0x40) != 0:
		if s[F_VX] >= 0x80:
			_free_side(s)
		else:
			go2 = its_turn(n, clock)
	if not go2:
		return
	var side: int = t[4] if s[F_VX] < 0x80 else t[5]
	var blocked: bool = ground_turn_clear(n, s, side, t[2]) >= 0x80 \
			or ground_turn_clear(n, s, side, t[3]) >= 0x80
	if not blocked:
		step_side(s)                                   # $C8F7
		_free_side(s)
		return
	_free_side(s)
	s[F_GROUND] = s[F_GROUND] | (0x40 if s[F_VX] < 0x80 else 0x80)
	s[F_VX] = 0
	s[F_VXFR] = 0


## $BD91 and $BD9A -- let go of the two sides up and down, and of the two
## sides across.
func _free_up_down(s: PackedByteArray) -> void:
	s[F_GROUND] = s[F_GROUND] & 0xFC


func _free_side(s: PackedByteArray) -> void:
	s[F_GROUND] = s[F_GROUND] & 0x3F


## $AD0F (bank 11) -- is one of his boomerangs on its way here?
##
## Only the three places $01 to $03 are looked at, and only a boomerang that
## is running flat: it must have a speed across, none up or down, be within
## thirty-two lines and ninety-six points, and be coming this way rather than
## going.  A thing off the screen, or one already facing him, does not look.
func boomerang_coming(s: PackedByteArray) -> bool:
	if (s[F_XHI] | s[F_YHI]) != 0:                     # $C9C3 -- $FD8C
		return false
	if looking_away(s):                                # $C98D -- $AD17 BCS
		return false
	for y in range(1, 4):
		var shot: PackedByteArray = slots[y]
		if (shot[F_VX] | shot[F_VXFR]) == 0:
			continue
		if (shot[F_VY] | shot[F_VYFR]) != 0:
			continue
		var dy: int = abs(s[F_Y] - shot[F_Y])          # $C858 negates a borrow
		if dy >= 0x20:
			continue
		var d: int = s[F_X] - shot[F_X]
		var further: bool = d >= 0                     # the carry, kept
		var dx: int = d if d >= 0 else (-d) & 0xFF
		if dx >= 0x60:
			continue
		if shot[F_VX] >= 0x80:                         # it is running left
			if not further:
				return true
		elif further:
			return true
	return false


## $B500 (bank 11) -- the one that hops at him and spits, and that ducks a
## boomerang by hopping the other way.
func _mind_3c(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _wake_3c(s)
		1: _wait_3c(s)
		2: _leap_3c(n, s)
		3: _spit_3c(s)


## $B50B -- it keeps the health it was laid out with, because that byte says
## which of the two sorts it is, and takes eight of its own.
func _wake_3c(s: PackedByteArray) -> void:
	s[F_REC_BYTE] = s[F_LIFE]
	s[F_LIFE] = 0x08                                   # $BE5A
	s[F_MARK] = 0x01
	start_anim(s, 0x26)                                # $BEAD
	record_home_along(s)                               # $C9B1
	s[F_SELF] = 0x28                                   # $BE75
	s[F_STATE] += 1                                    # $C966


## $B523 -- standing.  It counts down to a hop; a boomerang cuts the count
## short and every other one of those hops goes backwards.
func _wait_3c(s: PackedByteArray) -> void:
	if boomerang_coming(s):                            # $AD0F
		s[F_COUNT] = (s[F_COUNT] + 1) & 0xFF
		if (s[F_COUNT] & 1) == 0:
			set_speed_side_at_hero(s, 0xFE, 0x80)      # $BEBF with 80 FE
		else:
			set_speed_side_at_hero(s, 0xFF, 0x40)      # $BEBF with 40 FF
			flip_speed_side(s)                         # $C91E
	else:
		s[F_SELF] = (s[F_SELF] - 1) & 0xFF
		if s[F_SELF] != 0:
			face_hero(s)                               # $C8FD
			return
		# The second sort always spits; the first only now and then, and
		# never while it is pressed against a wall.
		var spit: bool = s[F_REC_BYTE] != 0
		if not spit:
			spit = random() >= 0xA0 and (s[F_GROUND] & 0xC0) == 0
		if spit:
			start_anim(s, 0x26)                        # $BEAD
			s[F_STATE] = 3                             # $C975
			return
		set_speed_side_at_hero(s, 0xFE, 0x80)          # $BEBF with 80 FE
	# $B563 -- how high the hop is: higher from low ground, higher again
	# when he himself is up above.
	if s[F_Y] < 0x50:
		set_speed_down(s, 0xFC, 0x00)                  # $BEB9 with 00 FC
	elif slots[0][F_Y] < 0x50:
		set_speed_down(s, 0xF9, 0x00)                  # $BEB9 with 00 F9
	else:
		set_speed_down(s, 0xFA, 0x00)                  # $BEB9 with 00 FA
	s[F_STATE] = 2                                     # $C972
	if s[F_REC_BYTE] != 0:
		set_speed_side(s, 0x00, 0x00)                  # $BEB3 with 00 00
	# What it will walk off a wall with: half a point, the other way.
	s[F_PUSH] = 0xFF if s[F_VX] < 0x80 else 0x00       # $BE91
	s[F_ANG] = 0x80                                    # $BE98


## $B5AA -- in the air.
func _leap_3c(n: int, s: PackedByteArray) -> void:
	move_boxed(n, s, 3)                                # $BCBB with Y = 3
	if (s[F_GROUND] & 0x02) != 0:
		# Down again: sit on the line and stand.
		snap_down(s)                                   # $C981
		start_anim(s, 0x26)                            # $BEAD
		s[F_SELF] = 0x20                               # $BE75
		s[F_STATE] = 1                                 # $C96F
		return
	add_speed_down(s, 0x4B)                            # $C90C
	if s[F_VY] >= 0x80:
		s[F_KIND] = 0x90                               # $BE6E
	else:
		s[F_KIND] = 0x91                               # $BE6E
		if s[F_VY] >= 0x04:
			set_speed_down(s, 0x04, 0x00)              # $BEB9 with 00 04
	face_hero(s)                                       # $C8FD
	if (s[F_GROUND] & 0xC0) != 0:
		# Against a wall: away from it at what $B593 laid down.
		s[F_VX] = s[F_PUSH]
		s[F_VXFR] = s[F_ANG]
		return
	if strayed_far(s):                                 # $ACD0
		flip_speed_side(s)                             # $C91E


## $B605 -- spitting.  The run of pictures runs on, and the seventh frame of
## the one before the last lets a $3D go.
func _spit_3c(s: PackedByteArray) -> void:
	face_hero(s)                                       # $C8FD
	step_anim(s)                                       # $C837
	if s[F_KIND] == 0x90:
		s[F_STATE] = 1                                 # $C96F
		s[F_KIND] = (s[F_KIND] - 1) & 0xFF
		s[F_SELF] = 0x10 if s[F_REC_BYTE] == 0 else 0x38
		return
	if s[F_KIND] != 0x8F:
		return
	if s[F_HOLD] != 0x07:
		return
	var right: bool = (s[F_BITS] & 0x40) != 0          # $C990
	make_child_aimed(s, 0x10 if right else 0xF0, 0xE2, 0x3D, 0x14,
			0x00 if right else 0x80)                   # $C8E5

## $8000 -- every place gets its turn, in order, once a step.
##
## For one place the order is sweep, then stun, then mind: the sweep at $8134
## runs first, and a place it has taken gets no turn this step.  $2A freezes
## the level, and while it is set only the door and the thing at $03 move.
##
## Returns the places the sweep freed, in the order it walked them.
func turns() -> Array:
	clock = (clock + 1) & 0xFF
	var gone := []
	for n in range(FIRST_LIVE, SLOTS):
		var s: PackedByteArray = slots[n]
		if s[F_TYPE] == 0:
			continue
		if _cull_one(s):
			clear(n)                       # $8024 -> $8075 -> $D6D4
			gone.append(n)
			continue
		if not _may_move(s):
			continue
		var mind = MINDS.get(s[F_TYPE])
		if mind != null:
			call(mind, n, s)
	return gone


## $8026 and $8043 -- a stunned thing always counts its stun down, and most of
## them lose the turn as well.  The ones that do not are the big and the tough:
## the bosses, four kinds in the middle of the table, and anything with $20 of
## health or more.
func _may_move(s: PackedByteArray) -> bool:
	if s[F_STUN] != 0:
		s[F_STUN] -= 1
		if not _acts_stunned(s):
			return false
	if frozen == 0:
		return true
	return s[F_TYPE] == 0x03 or s[F_TYPE] == 0x04    # $802F


func _acts_stunned(s: PackedByteArray) -> bool:
	var t: int = s[F_TYPE]
	if t >= 0x4F or t == 0x38 or t == 0x10 or t == 0x13:
		return true
	if t < 0x38 and ((t >= 0x1D and t < 0x20) or (t >= 0x2C and t < 0x2F)):
		return true
	return s[F_LIFE] >= 0x20                          # $806B


## $8134 -- who has gone far enough past the edge to be thrown away.


func _cull_one(s: PackedByteArray) -> bool:
	var rule: Dictionary = cull_rules[cull_class[s[F_TYPE]]]
	var h = rule["horiz"]
	if h is String:
		if h == "none":
			return false
		# $8172 -- the strictest of them: off the screen at all and it is gone.
		return s[F_XHI] != 0 or s[F_YHI] != 0
	return _off_side(s[F_XHI], s[F_X], h) or _off_down(s, rule["vert"])


## $81A4 -- the same shape for either pair.  A high byte of zero means the
## thing is on the screen and stays; otherwise the low byte says how far past
## the edge it has got, and the pair of margins says how far is too far.
func _off_side(hi: int, lo: int, pair: int) -> bool:
	if hi == 0:
		return false
	if hi >= 0x80:
		return lo < cull_margin[pair]          # $81AE
	return lo >= cull_margin[pair + 1]         # $81B7


func _off_down(s: PackedByteArray, rule) -> bool:
	if not (rule is String):
		return _off_side(s[F_YHI], s[F_Y], rule)   # $81D6
	if rule == "drop":
		# $81BD -- below the screen it is gone at once; above it there are
		# thirty-two lines of grace.
		if s[F_YHI] == 0:
			return false
		if s[F_YHI] < 0x80:
			return true
		return s[F_Y] < 0xE0
	# $81EF -- as 'drop', and gone at $D0 even while it is still on the screen.
	if s[F_YHI] == 0:
		return s[F_Y] >= 0xD0
	if s[F_YHI] < 0x80:
		return true
	return s[F_Y] < 0xE0


## $E523 and $E559 -- may this record come out at all?
##
## Two kinds of thing are not put out again.  A collectable (type $02) that
## has been taken is gone for the whole game: sixteen bits in `got` remember
## which.  Four other types -- the door, the two lifts and the switch -- are
## given out once per visit to an area, and `done` is the list of the records
## that have already been.
##
## Both are asked after a free place has been found and before anything is
## written, so a blocked record leaves the place free for the next one.
func _gated(rec_index: int, rec: Dictionary) -> bool:
	var kind := int(rec["type"])
	if kind == 0x02:
		var f := int(rec["flags"])
		# $E530: the top nibble says which of the sixteen it is, and the
		# bottom bit which of the two bytes holds it.
		var bit: int = pickup_bit[(f >> 4) & 0x0F]
		var word: int = (got >> 8) if (f & 1) else (got & 0xFF)
		return (word & bit) != 0
	if kind in ONCE_A_VISIT:
		return done.has(rec_index)
	return false


# --- The common step ---------------------------------------------------
#
# A mind never adds place to speed itself: it sets a speed and calls one of
# these, all of which live in the fixed bank 15.  So the walk of every one of
# the ninety types is this handful of lines, ported once.  Discussed in
# work/re/pb2_object_move.md.


## $FA0B -- one step down.  Three bytes of place, two of speed, both signed;
## the sign of the whole-points byte is what reaches the third byte of place.
func step_down(s: PackedByteArray) -> void:
	var far := 0xFF if s[F_VY] >= 0x80 else 0x00
	var v: int = s[F_YFR] + s[F_VYFR]
	s[F_YFR] = v & 0xFF
	v = s[F_Y] + s[F_VY] + (v >> 8)
	s[F_Y] = v & 0xFF
	s[F_YHI] = (s[F_YHI] + far + (v >> 8)) & 0xFF


## $FA2F -- the same across.
func step_side(s: PackedByteArray) -> void:
	var far := 0xFF if s[F_VX] >= 0x80 else 0x00
	var v: int = s[F_XFR] + s[F_VXFR]
	s[F_XFR] = v & 0xFF
	v = s[F_X] + s[F_VX] + (v >> 8)
	s[F_X] = v & 0xFF
	s[F_XHI] = (s[F_XHI] + far + (v >> 8)) & 0xFF


## $FA08 -- both, and the order matters: across first.
func step_both(s: PackedByteArray) -> void:
	step_side(s)
	step_down(s)


## $FA55 -- shift down where it stands, without touching its speed.  `frac` is
## the 1/256ths, `whole` the points, signed.
func nudge_down(s: PackedByteArray, frac: int, whole: int) -> void:
	var far := 0xFF if whole >= 0x80 else 0x00
	var v: int = s[F_YFR] + frac
	s[F_YFR] = v & 0xFF
	v = s[F_Y] + whole + (v >> 8)
	s[F_Y] = v & 0xFF
	s[F_YHI] = (s[F_YHI] + far + (v >> 8)) & 0xFF


## $FA75 -- and across.
func nudge_side(s: PackedByteArray, frac: int, whole: int) -> void:
	var far := 0xFF if whole >= 0x80 else 0x00
	var v: int = s[F_XFR] + frac
	s[F_XFR] = v & 0xFF
	v = s[F_X] + whole + (v >> 8)
	s[F_X] = v & 0xFF
	s[F_XHI] = (s[F_XHI] + far + (v >> 8)) & 0xFF


## $F9BD and $F9B5 -- set a speed outright.  `whole` is the points a step,
## `frac` the 1/256ths.
func set_speed_down(s: PackedByteArray, whole: int, frac: int) -> void:
	s[F_VY] = whole & 0xFF
	s[F_VYFR] = frac & 0xFF


func set_speed_side(s: PackedByteArray, whole: int, frac: int) -> void:
	s[F_VX] = whole & 0xFF
	s[F_VXFR] = frac & 0xFF


## $FA93 -- add to the speed down as a fraction of a point.  This is weight:
## how much is the type's own business, but the shape is always this.
func add_speed_down(s: PackedByteArray, frac: int) -> void:
	var v: int = ((s[F_VY] << 8) | s[F_VYFR]) + frac
	s[F_VY] = (v >> 8) & 0xFF
	s[F_VYFR] = v & 0xFF


## $FAA3 -- the same across.
func add_speed_side(s: PackedByteArray, frac: int) -> void:
	var v: int = ((s[F_VX] << 8) | s[F_VXFR]) + frac
	s[F_VX] = (v >> 8) & 0xFF
	s[F_VXFR] = v & 0xFF


## $FAB3 and $FAC7 -- take away instead.
func sub_speed_down(s: PackedByteArray, frac: int) -> void:
	var v: int = (((s[F_VY] << 8) | s[F_VYFR]) - frac) & 0xFFFF
	s[F_VY] = v >> 8
	s[F_VYFR] = v & 0xFF


func sub_speed_side(s: PackedByteArray, frac: int) -> void:
	var v: int = (((s[F_VX] << 8) | s[F_VXFR]) - frac) & 0xFFFF
	s[F_VX] = v >> 8
	s[F_VXFR] = v & 0xFF


## $F99F and $F989 -- turn a speed round, all sixteen bits of it.
func flip_speed_down(s: PackedByteArray) -> void:
	var v: int = (-((s[F_VY] << 8) | s[F_VYFR])) & 0xFFFF
	s[F_VY] = v >> 8
	s[F_VYFR] = v & 0xFF


func flip_speed_side(s: PackedByteArray) -> void:
	var v: int = (-((s[F_VX] << 8) | s[F_VXFR])) & 0xFFFF
	s[F_VX] = v >> 8
	s[F_VXFR] = v & 0xFF


## $F980 -- look the other way.  $F97D is this and flip_speed_side together.
func turn(s: PackedByteArray) -> void:
	s[F_BITS] = s[F_BITS] ^ 0x40


## $F9DC -- is the hero to the left of it?  True when he is: the console
## returns this as the carry, set when the thing is the further along.
func hero_is_left(s: PackedByteArray) -> bool:
	if s[F_XHI] >= 0x80:
		return false
	if s[F_XHI] != 0:
		return true
	return s[F_X] >= slots[0][F_X]


## $F9C5 -- face him: bit 6 set means he is on the far side.
func face_hero(s: PackedByteArray) -> void:
	if hero_is_left(s):
		s[F_BITS] = s[F_BITS] & 0xBF
	else:
		s[F_BITS] = s[F_BITS] | 0x40


## $FB25 ($C93C) -- how far across the hero is.  The cartridge answers three
## things at once: the length, which side he is on (the carry, set when the
## thing is the further along) and whether the answer means anything at all
## (the overflow, set when the thing is a whole screen away, where the length
## it hands back is only the count of screens).  [length, further, adrift]
func hero_side(s: PackedByteArray) -> Array:
	if s[F_XHI] != 0:
		return [s[F_XHI], s[F_XHI] < 0x80, true]
	var d: int = s[F_X] - slots[0][F_X]
	if d < 0:
		return [-d, false, false]
	return [d, true, false]


## $FB4B ($C93F) -- the same, up and down.
func hero_down(s: PackedByteArray) -> Array:
	if s[F_YHI] != 0:
		return [s[F_YHI], s[F_YHI] < 0x80, true]
	var d: int = s[F_Y] - slots[0][F_Y]
	if d < 0:
		return [-d, false, false]
	return [d, true, false]


## $FD41 ($C98D) -- is it looking away from him?  The cartridge weighs only
## the low bytes of the two places ($CADB), so a hero a screen off still counts
## as being to one side or the other.
##
## The name is the way round the cartridge answers, and it is worth saying
## why.  Bit six set is looking the way the numbers grow ($F9C5 sets it when
## the hero is the further along), $CADB hands back the carry set when the
## hero is the further along, and $FD41 sets its own carry when those two
## **disagree** -- which is the thing looking the other way.  Every branch off
## $C98D in the game is written against that, so the answer is kept as it is
## and the name is made to match.
func looking_away(s: PackedByteArray) -> bool:
	var he_is_right: bool = s[F_X] < slots[0][F_X]
	return he_is_right != ((s[F_BITS] & 0x40) != 0)


## $F97D ($C91B) -- turn round: the speed across changes sign and so does the
## way it looks.
func turn_about(s: PackedByteArray) -> void:
	flip_speed_side(s)
	turn(s)


## $FB81 -- whose turn it is to look at the ground.  The count of frames is
## halved and the places share it out between them, so a thing sees the floor
## every other frame and never on the same frame as its neighbour.  Its walk
## and the way it falls off a ledge both hang on this, so it is kept.
func its_turn(n: int, clock: int) -> bool:
	return ((n ^ clock) & 1) == 0


## $F8A1 ($C8DF) -- put a new thing out beside this one, of the type in $24.
##
## The offsets are signed bytes, and a thing may not be born off the screen.
## When one of the two high bytes comes out other than zero $F924 pulls its
## own return address off the stack and returns straight to whoever called
## $F8A1 with the carry up -- which is the same answer a nursery with no room
## left gives.  Either way there is no child and the mind carries on, so both
## are the -1 here.
##
## Only the eight places from six to thirteen can hold what a thing bears
## ($CB1B); the eight above them belong to the level's own list.
func make_child(s: PackedByteArray, side: int, down: int, what: int) -> int:
	var x: int = ((s[F_XHI] << 8) | s[F_X]) + _signed(side)
	if (x >> 8) & 0xFF:
		return -1
	var y: int = ((s[F_YHI] << 8) | s[F_Y]) + _signed(down)
	if (y >> 8) & 0xFF:
		return -1
	for n in range(FIRST_LIVE, FIRST_PLACED):
		var c: PackedByteArray = slots[n]
		if c[F_TYPE] != 0:
			continue
		c[F_TYPE] = what
		c[F_MARK] = 0x08
		c[F_X] = x & 0xFF
		c[F_Y] = y & 0xFF
		return n
	return -1


## $F9EE and $F9F7 -- set the sideways speed and then point it the right way.
## $F9EE turns to face the hero first; $F9F7 keeps whichever way it already
## looks.  Either way a thing that looks left walks left.
func set_speed_side_facing(s: PackedByteArray, whole: int, frac: int) -> void:
	set_speed_side(s, whole, frac)
	if s[F_BITS] & 0x40:
		flip_speed_side(s)


func set_speed_side_at_hero(s: PackedByteArray, whole: int, frac: int) -> void:
	set_speed_side(s, whole, frac)
	face_hero(s)
	if s[F_BITS] & 0x40:
		flip_speed_side(s)


## $FD98 -- some records ask for the thing to stand half a tile over from
## where the list put it: across in a level that scrolls sideways, down in one
## that scrolls up.
func nudge_eight(s: PackedByteArray, rec_byte: int) -> void:
	if not (rec_byte & 0x40):
		return
	if lvl.vertical:
		nudge_down(s, 0, 8)
	else:
		nudge_side(s, 0, 8)


# --- Round the circle ---
#
# $F245 answers where a point is, given how far round it has gone and how far
# out it is.  It is built out of $F274, which does one axis, and $F2E6, which
# multiplies a length by a point of the cosine table.  Nothing here is
# rounded the way a book would round it: the multiply adds the carry that
# fell out of reading the next bit of the table, so the answer is a point or
# two off from the true cosine, and that is the answer the cartridge gives.


## $F2E6 -- how much of `mag` is left after `i` sixty-fourths of a quarter
## turn.  The first two entries are never really read: the cartridge answers
## the whole length instead.
func _trig(i: int, mag: int) -> int:
	if i < 2:
		return mag
	var t: int = trig[i]
	var a := 0
	for _k in range(8):
		var carry: int = t & 1
		t >>= 1
		if carry == 1:
			var sum: int = a + mag + 1
			a = sum & 0xFF
			carry = sum >> 8
		a = ((carry << 7) | (a >> 1)) & 0xFF
	return a


## $F274 -- `mag` points along the angle `ang`, as a pair of signed bytes.
func _along(mag: int, ang: int) -> Array:
	if mag == 0:
		return [0, 0]
	if mag >= 0x80:
		mag = (-mag) & 0xFF
		ang = ang ^ 0x80
	var q: int = ang & 0x3F
	var i := 0
	var j := 0
	if q == 0:
		if ang & 0x40:
			i = 0x40
		else:
			j = 0x40
	elif ang & 0x40:
		i = (-q) & 0x3F
		j = q
	else:
		i = q
		j = (-q) & 0x3F
	var side: int = _trig(i, mag)
	var down: int = _trig(j, mag)
	if ang & 0x80:
		down = (-down) & 0xFF
	if ((ang + 0x40) & 0xFF) >= 0x80:
		side = (-side) & 0xFF
	return [side, down]


## $F245 ($C88B) -- two lengths at right angles make an ellipse, not a circle;
## the minds that use it hand one of the two as zero.  Answers [across, down].
func around(ang: int, out_side: int, out_down: int) -> Array:
	var a: Array = _along(out_side, ang)
	var b: Array = _along(out_down, (ang + 0x40) & 0xFF)
	return [(a[0] + b[0]) & 0xFF, (a[1] + b[1]) & 0xFF]


## $E2D5 ($C83A, wrapper $BEAD) -- start a run of pictures over.
func start_anim(s: PackedByteArray, which: int) -> void:
	s[F_ANIM] = which
	var run: Dictionary = anims[which]
	s[F_HOLD] = int(run["hold"])
	s[F_KIND] = int(run["first"])
	s[F_STEP] = 0


## $E30F ($C837) -- hold the step a frame longer, and when its frames are up
## go on to the next; at the end of the run it starts again.
func step_anim(s: PackedByteArray) -> int:
	s[F_HOLD] = (s[F_HOLD] - 1) & 0xFF
	if s[F_HOLD] != 0:
		return s[F_HOLD]
	return _next_step(s, s[F_ANIM])


## $E309 ($C88E) -- the same, except that the run to go on with is named
## rather than taken from the thing: $E309 walks into the middle of $E30F,
## past the load of $0458.  Finish this step, then carry on in that run.
func step_anim_into(s: PackedByteArray, which: int) -> int:
	s[F_HOLD] = (s[F_HOLD] - 1) & 0xFF
	if s[F_HOLD] != 0:
		return s[F_HOLD]
	return _next_step(s, which)


## Answers with the picture it settled on, because that is what the console
## leaves in A and what the minds that watch a swing through look at.
func _next_step(s: PackedByteArray, which: int) -> int:
	var run: Dictionary = anims[which]
	s[F_HOLD] = int(run["hold"])
	var last: int = int(run["last"])
	if s[F_STEP] == last:
		s[F_STEP] = 0
	else:
		s[F_STEP] += 1
	# $E374 -- a long record does not walk the pictures one after another; it
	# has a list of its own, and the step picks out of that.
	if run.has("steps"):
		var steps: Array = run["steps"]
		s[F_KIND] = (int(run["first"]) + int(steps[s[F_STEP]])) & 0xFF
	else:
		s[F_KIND] = (int(run["first"]) + s[F_STEP]) & 0xFF
	return s[F_KIND]


# --- What a thing sees under it ----------------------------------------


## $10 -- the lines at the head of a page the view never shows ($F438).
const VIEW_TOP := 0x10


## $F342 ($C888) -- what the ground is, this far along and this far down from
## the thing.  Both offsets are signed bytes; the answer is one of the four
## bytes of $F5A9 while the point is on the screen, and the ground's own kind
## once it is not -- the cartridge reads the two through different doors and
## does not make them agree, and neither do we.
## `force_far` forces the far road whatever kind of area this is: the fifteenth
## clatch of $F3AA/$F3BA points straight at $F42C, and a mind that wants the
## ground's own kind rather than one of the four bytes writes $0F into $87
## for the length of the question.
func ground(s: PackedByteArray, side_off: int, down_off: int,
		force_far := false) -> int:
	var sx: int = (((s[F_XHI] << 8) | s[F_X]) + _signed(side_off)) & 0xFFFF
	var sy: int = (((s[F_YHI] << 8) | s[F_Y]) + _signed(down_off)) & 0xFFFF
	var xhi: int = sx >> 8
	var xlo: int = sx & 0xFF
	var yhi: int = sy >> 8
	var ylo: int = sy & 0xFF
	# $F36A -- across the level is one screen wide, and the question is never
	# let out past its edge: it is pulled back to the edge instead.  The screen
	# byte itself is left as it was, and the roads below still look at it, so a
	# point pulled back can still be a point off the screen.
	if lvl.vertical:
		if xhi != 0:
			xlo = 0x00 if xhi >= 0x80 else 0xFF
	elif yhi != 0:
		ylo = VIEW_TOP if yhi >= 0x80 else 0xAF
	else:
		ylo = clampi(ylo, VIEW_TOP, 0xAF)
	var off: bool = xhi != 0 or yhi != 0
	if force_far:
		return _ground_far(xhi, xlo, yhi, ylo)
	if lvl.kind == 7:
		# $F3CA -- everything below the hundred and forty fourth line of this
		# kind of area is wall, and past the screen a ground of kind three
		# counts as wall too.
		if off:
			var far: int = _ground_far(xhi, xlo, yhi, ylo)
			return 0x80 if far == 0x03 else far
		return _ground_near(xlo, ylo) if ylo < 0x90 else 0x80
	if lvl.kind == 4 or lvl.kind == 10:
		# $F40D and $F3E3 both bend the question around $29, which is not a
		# constant: it is the line the lava or the water has risen to, and the
		# engine does not keep it yet.  One area apiece uses these, and until
		# $29 is kept they are answered as any other area would be, which is
		# right everywhere the water is not.
		pass
	# $F3FC
	if off or ylo >= 0xB0:
		return _ground_far(xhi, xlo, yhi, ylo)
	return _ground_near(xlo, ylo)


## $F52C -- the cell under a point of the screen, as one of the four bytes.
## This is the same question the hero asks and the same answer he gets.
func _ground_near(sx: int, sy: int) -> int:
	if sy >= 0xE0:
		return 0x00
	if lvl.vertical:
		return lvl.class_byte(sx, Pb2Level.map_row(_drawn_view(), sy))
	return lvl.class_byte(cam + sx, sy - VIEW_TOP)


## The view as the screen has it ($FC), in the view's own numbers.  Only the
## line within the page is kept in $FC, so the page comes from the view, and
## the two are brought together the short way round: a screen that has fallen
## behind is a handful of lines behind, never half a level.
func _drawn_view() -> int:
	if draw < 0:
		return cam
	var lo: int = cam & 0xFF
	var d: int = draw - lo
	if d > 120:
		d -= 240
	elif d < -120:
		d += 240
	var here: int = lo + d
	var out: int = cam + d
	if here < 0:
		out -= 16
	elif here >= 240:
		out += 16
	return out


## $F42C -- past the edge of the screen the cache holds nothing, so the map
## itself is read, and what comes back is the ground's own kind.
func _ground_far(xhi: int, xlo: int, yhi: int, ylo: int) -> int:
	if lvl.vertical:
		return lvl.terrain_at(xlo, _line(yhi, ylo))
	var far: int = (xhi << 8) | xlo
	if xhi >= 0x80:
		far -= 0x10000
	return lvl.terrain_at(cam + far, ylo - VIEW_TOP)


## $F45B and $F479 -- which line of the map a line below the view falls on,
## when the view may be more than a page away.  The console keeps the level in
## pages of two hundred and forty lines and reads it in pages of two hundred
## and fifty six, so sixteen lines are added for every page boundary crossed.
func _line(hi: int, lo: int) -> int:
	var far: int = (hi << 8) | lo
	if hi >= 0x80:
		far -= 0x10000
	var total: int = (cam >> 8) * 240 + (cam & 0xFF) + far
	var page: int = floori(float(total) / 240.0)
	return page * 256 + (total - page * 240)


## $FB88 ($C945) -- ask the ground, but only when it is this thing's turn;
## when it is not, the answer is that there is nothing there.
func ground_turn_clear(n: int, s: PackedByteArray, side: int,
		down: int) -> int:
	if not its_turn(n, clock):
		return 0x00
	return ground(s, side, down)


## $FB92 ($C948) -- the same, but out of turn the answer is a wall.
func ground_turn_wall(n: int, s: PackedByteArray, side: int,
		down: int) -> int:
	if not its_turn(n, clock):
		return 0x80
	return ground(s, side, down)


## $FBBA ($C94B through $BED7) -- is there a wall this far out to either side?
## The same question is put twice, once each way, and one wall is enough.
func walled_either(s: PackedByteArray, side: int, down: int) -> int:
	if ground(s, side, down) & 0x80:
		return 0x80
	if ground(s, (-_signed(side)) & 0xFF, down) & 0x80:
		return 0x80
	return 0x00


## $FBA6 ($C94E) and $FBB0 ($C951) -- the same, in turn only.
func walled_either_turn(n: int, s: PackedByteArray, side: int, down: int,
		out_of_turn: int) -> int:
	if not its_turn(n, clock):
		return out_of_turn
	return walled_either(s, side, down)


## $FAFB ($C939) -- the next number.  The seed is stirred and its new
## HIGH byte is the answer.  The carry the stirring leaves behind is part of
## the answer too: the callers go straight on into an ADC or an SBC, so a
## number that ran off the top of the seed comes out one larger.
func random() -> int:
	var t: int = ((seed * 5) & 0xFFFF) + 0x3711
	rng_carry = t > 0xFFFF
	seed = t & 0xFFFF
	return seed >> 8


## A byte the cartridge reads as a signed offset.
static func _signed(b: int) -> int:
	return b - 0x100 if b >= 0x80 else b


## $CAF1 ($C870) -- how far the hero is above or below, as a plain length.
func hero_gap_down(s: PackedByteArray) -> int:
	var d: int = s[F_Y] - slots[0][F_Y]
	return d if d >= 0 else -d


## $FD1D and $FD20 -- sit the thing on the floor line of the tile it is in.
## Down a level the view's own place is counted in, because there the map
## slides under the thing instead of past it.
func snap_down(s: PackedByteArray) -> void:
	var y: int = s[F_Y]
	if lvl.vertical:
		y = (y + (cam & 0xFF)) & 0xFF
	nudge_down(s, 0, snap[y & 0x0F])


## $FD16 -- the same, reckoned from a place `off` below where it stands.
func snap_down_from(s: PackedByteArray, off: int) -> void:
	var y: int = (s[F_Y] + off) & 0xFF
	if lvl.vertical:
		y = (y + (cam & 0xFF)) & 0xFF
	nudge_down(s, 0, snap[y & 0x0F])


## $9C44 -- is it under the water that has risen?  Only kinds five and nine of
## an area have such water; everywhere else the answer is no.
##
## A thing counts as under it when it stands below the line, and also when it
## stands no more than a point above it: the cartridge takes the difference,
## turns it about when it came out short, and only then asks whether it is two
## or more.
func in_water(s: PackedByteArray) -> bool:
	if lvl.kind != 5 and lvl.kind != 9:
		return false
	if s[F_YHI] != 0:
		return false
	var d: int = s[F_Y] - water
	if d >= 0:
		return true
	return (-d) < 2


## $9BD0 -- fall or stand.  A thing already standing is left standing: it is
## whatever knocked it off that clears the field, not this.
func ground_stand(s: PackedByteArray) -> void:
	if s[F_GROUND] == 0x81:
		if not in_water(s):
			return
	if ground(s, 0x00, 0x01) >= 0x80:
		snap_down(s)
		s[F_GROUND] = 0x81
	else:
		s[F_GROUND] = 0x00


## $9BA5 -- the same, and then drowning: a thing in the risen water with
## nothing under it at `deep` is taken away.  Nothing can be in that water
## until $29 is kept, so for now this is only the standing.
func ground_stand_deep(s: PackedByteArray, _deep: int) -> void:
	ground_stand(s)


## $FBF0 -- is there a wall the way it is looking?  The offset across is
## turned about when it looks the other way, and the ground is asked at two
## heights: one wall is enough.
func walled_ahead(s: PackedByteArray, side: int, first: int,
		second: int) -> int:
	var a: int = side
	if s[F_BITS] & 0x40:
		a = (-_signed(a)) & 0xFF
	if ground(s, a, first) >= 0x80:
		return 0x80
	if ground(s, a, second) >= 0x80:
		return 0x80
	return 0x00


## $FBD7, $FBDC and $FBE6 -- asked every frame, or only on the thing's own
## frame with a settled answer for the frames in between.  $FBDC answers "no
## wall" out of turn and $FBE6 answers "a wall".
func walled_ahead_turn(n: int, s: PackedByteArray, side: int, first: int,
		second: int, out_of_turn: int) -> int:
	if not its_turn(n, clock):
		return out_of_turn
	return walled_ahead(s, side, first, second)


## $FC16 -- $FBDC, and turn round where there is a wall.
func walled_ahead_turn_about(n: int, s: PackedByteArray, side: int,
		first: int, second: int) -> void:
	if walled_ahead_turn(n, s, side, first, second, 0x00) >= 0x80:
		turn(s)
		flip_speed_side(s)


## $F637 -- how much of a length is left after `i` sixty-fourths of a quarter
## turn, to sixteen bits.  The same missing CLC as $F2E6: read the note there.
func _aim16(i: int, mag: int) -> Array:
	var t: int = aim[i]
	var a := 0
	var f := 0
	for _k in range(8):
		var carry: int = t & 1
		t >>= 1
		if carry == 1:
			var sum: int = a + mag + 1
			a = sum & 0xFF
			carry = sum >> 8
		var out: int = a & 1
		a = ((carry << 7) | (a >> 1)) & 0xFF
		f = ((out << 7) | (f >> 1)) & 0xFF
	return [a, f]


## $F5BA -- point a speed of `mag` along the angle `ang`.  This is $F274 over
## again, but the answer goes straight into the speed and keeps its fraction.
## A length of nought stops the thing outright.
func set_speed_at(s: PackedByteArray, mag: int, ang: int) -> void:
	if mag == 0:
		s[F_VXFR] = 0
		s[F_VX] = 0
		s[F_VYFR] = 0
		s[F_VY] = 0
		return
	var m: int = (mag - 1) & 0xFF
	var q: int = ang & 0x3F
	var i := 0
	var j := 0
	if q == 0:
		if ang & 0x40:
			i = 0x40
		else:
			j = 0x40
	elif ang & 0x40:
		i = (-q) & 0x3F
		j = q
	else:
		i = q
		j = (-q) & 0x3F
	var side: Array = _aim16(i, m)
	s[F_VX] = side[0]
	s[F_VXFR] = side[1]
	var down: Array = _aim16(j, m)
	s[F_VY] = down[0]
	s[F_VYFR] = down[1]
	if ang & 0x80:
		flip_speed_down(s)
	if ((ang + 0x40) & 0xFF) >= 0x80:
		flip_speed_side(s)


## $F8D3 ($C8E5) -- put a new thing out beside this one and send it off at an
## angle.  As with $F8A1 neither the child nor the parent may be off the
## screen; the cartridge gives up on the whole turn where it is, and the -1
## here stands for that.
func make_child_aimed(s: PackedByteArray, side: int, down: int, what: int,
		mag: int, ang: int) -> int:
	var x: int = ((s[F_XHI] << 8) | s[F_X]) + _signed(side)
	if (x >> 8) & 0xFF:
		return -1
	var y: int = ((s[F_YHI] << 8) | s[F_Y]) + _signed(down)
	if (y >> 8) & 0xFF:
		return -1
	if s[F_XHI] != 0 or s[F_YHI] != 0:                 # $F913
		return -1
	for n in range(FIRST_LIVE, FIRST_PLACED):
		var c: PackedByteArray = slots[n]
		if c[F_TYPE] != 0:
			continue
		c[F_TYPE] = what
		c[F_X] = x & 0xFF
		c[F_Y] = y & 0xFF
		c[F_MARK] = 0x08
		set_speed_at(c, mag, ang)
		return n
	return -1


# --- The minds ---------------------------------------------------------


## $83EA -- a collectable.  It does nothing at all: on its first turn it says
## what it is (the mark $40, which is what makes the hero pick it up rather
## than be hurt by it) and picks its picture out of the record's own byte, and
## from then on its state is one and it returns at once.
func _mind_02(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] != 0:
		return
	s[F_MARK] = 0x40                       # $C9A8 -> $FD82
	s[F_KIND] = pickup_pic[s[F_LIFE] & 0x0F]
	s[F_STATE] += 1                        # $C966 -> $FCEE


## $9DA5 -- the one that walks to and fro and drops something behind it.
func _mind_17(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _wake_17(s)
		1: _walk_17(n, s)
		2: _wait_17(s)


## $9DAE -- it keeps the record's byte for itself, because the field it came
## in is wanted for the one hit that kills it.  The byte says two things: the
## bottom bit which of two pictures it wears and how far down it drops what it
## drops, and the top bit whether it walks a point a frame or half of one.
func _wake_17(s: PackedByteArray) -> void:
	s[F_SELF] = s[F_LIFE]
	s[F_LIFE] = 0x01                       # $BE5A
	s[F_MARK] = 0x01
	s[F_KIND] = 0x12 if s[F_SELF] & 1 else 0x1A
	if s[F_SELF] & 0x80:
		set_speed_side(s, 0x00, 0x80)      # $BEB3 with 80 00
		s[F_COUNT] = 0x30
	else:
		set_speed_side(s, 0x01, 0x00)      # $BEB3 with 00 01
		s[F_COUNT] = 0x18
	s[F_STATE] += 1


## $9DE3 -- walk until the count runs out, then drop one behind.  Behind is
## against the way it is going, sixteen points off, and what it drops is told
## whose it is: the new thing keeps the place of its parent in the same field.
func _walk_17(n: int, s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		step_side(s)
		return
	s[F_COUNT] = 0x40
	var side: int = 0x10 if s[F_VX] & 0x80 else 0xF0
	var down: int = 0x04 if s[F_SELF] & 1 else 0xFF
	var born: int = make_child(s, side, down, 0x18)
	if born >= 0:
		slots[born][F_SELF] = n
	s[F_STATE] += 1


## $9E17 -- stand still while the count runs out, then turn round and walk
## again.  It is the way it moves that turns, not the way it looks.
func _wait_17(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	s[F_COUNT] = 0x60 if s[F_SELF] & 0x80 else 0x30
	flip_speed_side(s)
	s[F_STATE] -= 1



## $8BED -- the one that swims up and down while it drifts across.
func _mind_12(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		set_speed_down(s, 0x00, 0x00)              # $BEB9 with 00 00
		set_speed_side_at_hero(s, 0xFE, 0x80)      # $BEBF with 80 FE
		start_anim(s, 3)
		s[F_LIFE] = 0x01                           # $BE5A
		s[F_MARK] = 0x01
		s[F_STATE] += 1
		return
	# $8C09 -- $FA05: the picture goes on and it moves both ways.
	step_anim(s)
	step_both(s)
	if s[F_COUNT] == 0:
		add_speed_down(s, 0x40)
		# Only the whole points are looked at going down, so it turns round
		# the moment it reaches four, whatever the fraction.
		if s[F_VY] == 0x04:
			s[F_COUNT] = 1
	else:
		sub_speed_down(s, 0x40)
		# Going up it waits for four exactly, fraction and all.
		if s[F_VY] == 0xFC and s[F_VYFR] == 0:
			s[F_COUNT] = 0


## $9D1F -- the one that shuttles to and fro on a count of its own.
func _mind_19(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		var rec: int = s[F_LIFE]
		s[F_REC_BYTE] = rec
		nudge_eight(s, rec)                        # $FD98
		s[F_MARK] = 0x20                           # $FD7E
		s[F_STATE] += 1                            # $FCEE
		s[F_KIND] = 0x20                           # $BE6E
		_wind_19(s)
		var frac: int = 0x80 if rec & 0x04 else 0x00
		if rec & 0x80:
			set_speed_side(s, 0xFF, frac)
		else:
			set_speed_down(s, 0xFF, frac)
		return
	# $9D53 -- walk, and when the count is out turn both ways round at once.
	step_both(s)
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] != 0:
		return
	_wind_19(s)
	flip_speed_side(s)
	flip_speed_down(s)


## $9D65 -- how many frames the next leg lasts.
func _wind_19(s: PackedByteArray) -> void:
	s[F_SELF] = swing[s[F_REC_BYTE] & 0x0F]


## $9E2F -- the one that circles a place it remembers.
func _mind_10(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		# The place it stands at is the middle of the circle from now on.
		s[F_SELF] = s[F_X]
		s[F_COUNT] = s[F_XHI]
		s[F_KEEP] = s[F_Y]
		s[F_KEEP2] = s[F_YHI]
		s[F_REC_BYTE] = s[F_LIFE]
		s[F_MARK] = 0x20                           # $FD7E
		s[F_KIND] = 0x1D                           # $BE6E
		s[F_STATE] += 1                            # $FCEE
		return
	# $9E5C -- hold the middle still in the world while the view moves.
	var far: int = 0xFF if slide >= 0x80 else 0x00
	if lvl.vertical:
		var v: int = (((s[F_KEEP2] << 8) | s[F_KEEP]) - slide - far * 0x100) \
				& 0xFFFF
		s[F_KEEP] = v & 0xFF
		s[F_KEEP2] = v >> 8
	else:
		var v: int = (((s[F_COUNT] << 8) | s[F_SELF]) - slide - far * 0x100) \
				& 0xFFFF
		s[F_SELF] = v & 0xFF
		s[F_COUNT] = v >> 8
	# How far out, by the top bit of the record; how fast, by the low three.
	var out: int = 0xD0 if s[F_REC_BYTE] >= 0x80 else 0xE0
	var which: int = s[F_REC_BYTE] & 0x07
	var ang: int = ((s[F_PUSH] << 8) | s[F_ANG]) \
			+ ((spin_hi[which] << 8) | spin_lo[which])
	s[F_ANG] = ang & 0xFF
	s[F_PUSH] = (ang >> 8) & 0xFF
	var off: Array = around(s[F_PUSH], 0x00, out)
	var x: int = (((s[F_COUNT] << 8) | s[F_SELF])
			+ _signed(off[0])) & 0xFFFF
	s[F_X] = x & 0xFF
	s[F_XHI] = x >> 8
	var y: int = (((s[F_KEEP2] << 8) | s[F_KEEP])
			+ _signed(off[1])) & 0xFFFF
	s[F_Y] = y & 0xFF
	s[F_YHI] = y >> 8


## $8E9D -- the one that walks the floor and stops to shoot.  Whatever it is
## doing, it falls first.
func _mind_1d(n: int, s: PackedByteArray) -> void:
	ground_stand_deep(s, 0xF2)                         # $9BA5 with $F2
	match s[F_STATE]:
		0: _wake_1d(s)
		1: _walk_1d(n, s)
		2: _raise_1d(s)
		3: _fire_1d(s)
		4: _lower_1d(s)
		5: _stuck_1d(n, s)


## $8EB1
func _wake_1d(s: PackedByteArray) -> void:
	s[F_MARK] = 0x20                                   # $FD7E
	s[F_KIND] = 0x31                                   # $BE6E
	s[F_LIFE] = 0x02                                   # $BE63
	s[F_COUNT] = 0x30                                  # $BE7C
	s[F_STATE] += 1


## $8EC3 -- walk.  Far above or below him it takes its time; level with him it
## hurries, and counts down to the moment it stops and shoots.
func _walk_1d(n: int, s: PackedByteArray) -> void:
	if hero_gap_down(s) >= 0x10:
		set_speed_side_facing(s, 0xFF, 0x80)           # $BEC5 with 80 FF
	else:
		s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
		if s[F_COUNT] == 0:
			# $8F04 -- turn to him and start the swing.
			face_hero(s)
			start_anim(s, 4)
			s[F_STATE] += 1
			return
		set_speed_side_facing(s, 0xFE, 0x00)           # $BEC5 with 00 FE
	# $BF06 with F6 F1 FF -- a wall ten points ahead, at two heights.
	if walled_ahead_turn(n, s, 0xF6, 0xFF, 0xF1, 0x00) >= 0x80:
		_stop_1d(s)
		return
	# And the ledge: eight ahead and four down.  Out of its own turn the
	# answer is a floor, so it walks two frames for every one it looks.
	var ahead: int = 0x08 if s[F_BITS] & 0x40 else 0xF8
	if ground_turn_wall(n, s, ahead, 0x04) >= 0x80 or in_water(s):
		step_both(s)
		return
	_stop_1d(s)


## $8EFD -- there is nowhere to walk: stand a moment, then turn.
func _stop_1d(s: PackedByteArray) -> void:
	s[F_KEEP] = 0x04                                   # $BE83
	s[F_STATE] = 5                                     # $FD0A


## $8F0E -- the swing goes up; at the top of it the arm is out and it can hurt.
func _raise_1d(s: PackedByteArray) -> void:
	if step_anim(s) != 0x33:
		return
	s[F_COUNT] = 0x18                                  # $BE7C
	s[F_MARK] = 0x01                                   # $FD76
	s[F_STATE] += 1


## $8F20 -- hold the arm out, and at the end of it let two go at once.
func _fire_1d(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	_shoot_1d(s, 0xF8, 0xF8, 0xA0)
	s[F_STATE] += 1


## $8F63 -- two shots, one after the other, and the angle of each is turned
## about when it is looking the other way.
func _shoot_1d(s: PackedByteArray, down: int, side: int, ang: int) -> void:
	var a: int = ang
	if s[F_BITS] & 0x40:
		a = a ^ 0x40
	_shoot_one_1d(s, down, side, a)
	a = 0x00 if s[F_BITS] & 0x40 else 0x80
	_shoot_one_1d(s, down, side, a)


## $8F7C
func _shoot_one_1d(s: PackedByteArray, down: int, side: int,
		ang: int) -> void:
	var across: int = side
	if s[F_BITS] & 0x40:
		across = ((-_signed(across)) + 1) & 0xFF
	make_child_aimed(s, across, down, 0x14, 0x0C, ang)


## $8F36 -- the arm comes down and it walks again.
func _lower_1d(s: PackedByteArray) -> void:
	if step_anim(s) != 0x31:
		return
	s[F_MARK] = 0x20                                   # $FD7E
	s[F_COUNT] = 0x30                                  # $BE7C
	s[F_STATE] = 1                                     # $FCFA


## $8F48 -- stood against a wall or a drop.  Turn, and if that way is walled
## too, turn back and try again in two frames.
func _stuck_1d(n: int, s: PackedByteArray) -> void:
	s[F_KEEP] = (s[F_KEEP] - 1) & 0xFF
	if s[F_KEEP] != 0:
		return
	turn(s)
	flip_speed_side(s)                                 # $F97D
	# $BF00 -- this one is asked every frame, not every other.
	if walled_ahead(s, 0xF6, 0xFF, 0xF1) < 0x80:
		s[F_STATE] = 1                                 # $FCFA
		return
	turn(s)
	flip_speed_side(s)
	s[F_KEEP] = 0x02                                   # $BE83


## $A95C -- the one that runs him down and takes hold of him.  Three types
## share the one mind, and which of the three it is gets written afresh at the
## end of every turn from the picture it happens to be wearing ($A964), so
## that how far past the edge of the screen it is allowed to live changes with
## what it is doing.
func _mind_2c(n: int, s: PackedByteArray) -> void:
	ground_stand_deep(s, 0xE8)                         # $9BA5 with $E8
	_states_2c(n, s)
	# $A964
	if s[F_KIND] == 0x48:
		s[F_TYPE] = 0x2D
	elif s[F_KIND] == 0x47:
		s[F_TYPE] = 0x2E
	else:
		s[F_TYPE] = 0x2C


## $A97D -- seven steps.  The sixth is not reached from in here: a blow puts
## it there.
func _states_2c(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _wake_2c(s)
		1: _watch_2c(s)
		2: _walk_2c(n, s)
		3: _charge_2c(n, s, true)
		4: _rest_2c(n, s)
		5: _charge_2c(n, s, false)
		6: _hurt_2c(s)


## $A99D
func _wake_2c(s: PackedByteArray) -> void:
	s[F_MARK] = 0x01                                   # $FD76
	start_anim(s, 0x19)                                # $BEAD
	s[F_SELF] = 0x80                                   # $BE75
	s[F_STATE] += 1                                    # $FCEE


## $A9AB -- stand and watch.  Only while it wears the waiting picture does it
## weigh whether to set off; in any other it merely turns the pictures over.
func _watch_2c(s: PackedByteArray) -> void:
	if _grab_2c(s):
		return
	face_hero(s)                                       # $C8FD
	if s[F_KIND] != 0x47:
		step_anim(s)                                   # $C837
		return
	# Above him it wants twenty points, below him sixteen, before it moves.
	var r: int = _gap_2c(s, 0x20, 0x10)                # $AACF
	if r != 0:
		return
	_set_off_2c(s)


## $A9C9 -- take up the walking picture and go.
func _set_off_2c(s: PackedByteArray) -> void:
	s[F_SELF] = 0x80                                   # $BE75
	s[F_COUNT] = 0x28                                  # $BE7C
	s[F_KIND] = 0x45                                   # $BE6E
	s[F_STATE] = 2                                     # $FCFE


## $A9D8 -- walk towards him, and when the count runs out throw one at him.
func _walk_2c(n: int, s: PackedByteArray) -> void:
	if _grab_2c(s):
		return
	if s[F_SELF] == 0:
		# Thirty points above him or thirty-two below and it gives up.
		var r: int = _gap_2c(s, 0x30, 0x20)            # $AACF
		if r < 0:
			return
		if r > 0:
			s[F_SELF] = 0x40                           # $BE75
			start_anim(s, 0x19)                        # $BEAD
			s[F_STATE] -= 1                            # $FCF2
			return
		if not its_turn(n, clock):
			return
		# Somewhere to put its foot means it may break into a run; hemmed
		# in, it stands where it is and counts down to the throw.
		if _may_step_2c(n, s):                         # $AAE0
			_charge_start_2c(s)                        # $AA18
			return
	else:
		s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	face_hero(s)                                       # $C8FD
	_throw_2c(s)                                       # $AAB0
	s[F_COUNT] = 0x38                                  # $BE7C


## $AA18 -- lean into a run at him.
func _charge_start_2c(s: PackedByteArray) -> void:
	start_anim(s, 0x18)                                # $BEAD
	set_speed_side_at_hero(s, 0xFE, 0xC0)              # $BEBF with C0 FE
	s[F_SELF] = 0xFF                                   # $BE75
	s[F_STATE] = 3                                     # $FD02


## $AA28 and $AA2B -- the run.  The two are the same code entered a step
## apart: once it has hold of him it does not try to take hold again.
func _charge_2c(n: int, s: PackedByteArray, may_grab: bool) -> void:
	if may_grab and _grab_2c(s):
		return
	if not _may_step_2c(n, s):                         # $AAE0
		# Nowhere to go: turn, and mark that it has turned once already.
		if s[F_KEEP] == 0:
			s[F_SELF] = 0x01                           # $BE75
		turn_about(s)                                  # $C91B
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] == 0:
		_give_up_2c(s)
		return
	var side: Array = hero_side(s)                     # $C93C
	var near: bool = not side[2] and side[0] < 0x40
	if near and not looking_away(s):                   # $C98D -- $AA4D BCS
		var r: int = _gap_2c(s, 0x20, 0x10)            # $AACF
		if r < 0:
			_give_up_2c(s)
			return
		if r == 0:
			# On him: leap, with the picture that hurts.
			set_speed_side_facing(s, 0xFD, 0x80)       # $BEC5 with 80 FD
			s[F_KIND] = 0x48                           # $BE6E
			s[F_SELF] = 0x18                           # $BE75
			s[F_STATE] = 4                             # $FD06
			return
	if s[F_KEEP] == 0:
		var far: int = _gap_2c(s, 0x30, 0x20)          # $AACF
		if far != 0:
			_give_up_2c(s)
			return
	else:
		s[F_KEEP] = (s[F_KEEP] - 1) & 0xFF
	step_anim(s)                                       # $C8EE -- $FA05 is
	step_both(s)                                       # $E30F and then $FA08


## $AA82 -- lost him: face him and fall back to walking.
func _give_up_2c(s: PackedByteArray) -> void:
	face_hero(s)                                       # $C8FD
	_set_off_2c(s)                                     # $A9C9


## $AA88 -- after the leap.  It slides to a stop, and either the count runs
## out or the floor does.
func _rest_2c(n: int, s: PackedByteArray) -> void:
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] != 0 and _may_step_2c(n, s):          # $AAE0
		# $AA9D -- two two-hundred-and-fifty-sixths of a point a frame, off
		# whichever side the speed is on.
		if s[F_VX] >= 0x80:
			add_speed_side(s, 0x02)                    # $C912
		else:
			sub_speed_side(s, 0x02)                    # $C915
		step_side(s)                                   # $C8F7
		return
	s[F_SELF] = 0x20                                   # $BE75
	s[F_KIND] = 0x47                                   # $BE6E
	s[F_STATE] = 1                                     # $FCFA


## $A98E -- struck.  Nothing in the mind puts it here.
func _hurt_2c(s: PackedByteArray) -> void:
	s[F_MARK] = 0x01                                   # $C99F
	_charge_start_2c(s)                                # $AA18
	s[F_SELF] = 0x50                                   # $BE75
	s[F_KEEP] = 0x40                                   # $BE83


## $AACF -- how far above or below him it is, weighed against two thresholds:
## `over` when it is the lower of the two, `under` when it is the higher.
## Answers -1 when he is a whole screen away and the question means nothing,
## 0 when it is within the threshold and 1 when it is not.
func _gap_2c(s: PackedByteArray, over: int, under: int) -> int:
	var r: Array = hero_down(s)                        # $C93F
	if r[2]:
		return -1
	var thr: int = over if r[1] else under
	return 1 if r[0] >= thr else 0


## $AAE0 -- is there anywhere to put its foot?  A wall twenty points ahead at
## either of two heights stops it, and so does a drop ten points ahead.
func _may_step_2c(n: int, s: PackedByteArray) -> bool:
	# $BF06 with EC FF EC
	if walled_ahead_turn(n, s, 0xEC, 0xEC, 0xFF, 0x00) >= 0x80:
		return false
	var ahead: int = 0x0A if s[F_BITS] & 0x40 else 0xF6
	if ground_turn_wall(n, s, ahead, 0x04) >= 0x80:    # $C948
		return true
	return in_water(s)                                 # $9C44


## $AB02 -- take hold of him.  Six things must all be so, and the cartridge
## pulls its own way back off the stack when they are, so the rest of the
## turn never happens.
func _grab_2c(s: PackedByteArray) -> bool:
	if suit == 0:                                      # $9A
		return false
	if slots[0][F_MARK] & 0x10 == 0:                   # $0416
		return false
	if (s[F_BITS] ^ slots[0][F_BITS]) & 0x40:          # they look the same way
		return false
	if looking_away(s):                                # $C98D -- $AB1A BCS
		return false
	if _gap_2c(s, 0x04, 0x04) != 0:                    # $AACF
		return false
	var side: Array = hero_side(s)                     # $C93C
	if side[2] or side[0] >= 0x40:
		return false
	s[F_SELF] = 0x35                                   # $BE75
	start_anim(s, 0x18)                                # $BEAD
	set_speed_side_at_hero(s, 0xFE, 0x80)              # $BEBF with 80 FE
	turn_about(s)                                      # $C91B
	s[F_STATE] = 5                                     # $FD0A
	return true


## $AAB0 -- the thing it throws: a length of twelve, level, out to whichever
## side it looks and twenty-three points up.
func _throw_2c(s: PackedByteArray) -> void:
	var ang: int = 0x00
	var side: int = 0x10
	if s[F_BITS] & 0x40 == 0:                          # $C990
		ang = 0x80
		side = 0xF0
	make_child_aimed(s, side, 0xE9, 0x16, 0x0C, ang)   # $C8E5


## $976B -- how far above itself the one that sits still lets its shot out.
## The eight are the two mountings, the two ways of looking and the two sides
## he may be on.
const AIM_13 := [0xF4, 0xE5, 0xE5, 0xF4, 0xFD, 0xEC, 0xEC, 0xFD]
## $96D4 -- and which way each mounting looks to begin with.
const FACE_13 := [0x00, 0x40, 0x40, 0x00]


## $96AA -- the one that sits still and shoots him.  The record's own byte
## says how it is mounted: the lowest bit of it, kept in $05CE for good, is
## whether it hangs off something and so never falls.
func _mind_13(_n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _wake_13(s)
		1: _rouse_13(s)
		2: _aim_13(s)
		3: _shoot_13(s)


## $96B5
func _wake_13(s: PackedByteArray) -> void:
	var rec: int = s[F_LIFE]
	s[F_SELF] = rec
	s[F_BITS] = FACE_13[((rec & 1) << 1) | (rec >> 7)]
	s[F_LIFE] = 0x03                                   # $BE63
	s[F_COUNT] = 0x10                                  # $BE7C
	s[F_STATE] += 1                                    # $FCEE


## $9773 -- one that hangs off something is not pulled down.
func _fall_13(s: PackedByteArray) -> void:
	if s[F_SELF] & 1 == 0:
		ground_stand(s)                                # $9BD0


## $96D8 -- wait out the count, then take up the run of pictures that
## belongs to the mounting.
func _rouse_13(s: PackedByteArray) -> void:
	_fall_13(s)
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	start_anim(s, 0x06 if s[F_SELF] & 1 else 0x07)     # $C83A
	s[F_STATE] += 1                                    # $FCEE


## $96F1 -- turn the pictures over until the one that means it is open.
func _aim_13(s: PackedByteArray) -> void:
	_fall_13(s)
	step_anim(s)                                       # $C837
	if s[F_KIND] != 0x37 and s[F_KIND] != 0x16:
		return
	s[F_MARK] = 0x01                                   # $C99F
	var r: int = random() & 0x1F                       # $C939
	s[F_COUNT] = (r + 0x20 + (1 if rng_carry else 0)) & 0xFF
	s[F_KEEP] = 0x03
	s[F_STATE] += 1                                    # $FCEE


## $9717 -- three shots, then a long wait.
func _shoot_13(s: PackedByteArray) -> void:
	_fall_13(s)
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	s[F_COUNT] = 0x30                                  # $BE7C
	# $972B -- the cartridge means LDY here and writes LDA, and gets away
	# with it: $F1C9 counts the inline bytes down to nought, so Y is nought
	# already when the count of frames above was laid in.
	var i: int = 0x04 if s[F_SELF] & 1 else 0x00
	if s[F_BITS] & 0x40 == 0:                          # $C990
		i += 2
	var ang: int = 0x80
	if not hero_side(s)[1]:                            # $C93C
		i += 1
		ang = 0x00
	var side: int = 0x08 if i & 1 else 0xF8
	if make_child_aimed(s, side, AIM_13[i], 0x16, 0x0C, ang) < 0:
		return
	s[F_KEEP] = (s[F_KEEP] - 1) & 0xFF
	if s[F_KEEP] != 0:
		return
	s[F_COUNT] = 0x90                                  # $BE7C
	s[F_KEEP] = 0x03                                   # $BE83


## $8DDB -- the four corners of a cell of sixteen, as the one that returns
## asks them: side then down, taken two at a time from the one list.
const CORNERS_42 := [[0x07, 0x07], [0xF8, 0x07], [0x07, 0xF8], [0xF8, 0xF8]]


## $FDA9 -- remember where it stands as a place in the level rather than a
## place on the screen, so that it can be put back there however far the view
## has gone since.
func record_home(s: PackedByteArray) -> void:
	record_home_along(s)
	if not lvl.vertical:
		s[F_PUSH] = s[F_Y]
		s[F_ANG] = s[F_YHI]
		return
	# Down a level a page is two hundred and forty lines and the count is kept
	# in two hundred and fifty sixes, so the sixteen between them are added on
	# at every page the sum crosses.
	var t: int = (cam & 0xFF) + s[F_Y]
	var carry: int = t >> 8
	var y: int = t & 0xFF
	s[F_ANG] = ((cam >> 8) + s[F_YHI] + carry) & 0xFF
	if carry:
		y = (y + 0x10) & 0xFF
	if y >= 0xF0:
		y &= 0x0F
		s[F_ANG] = (s[F_ANG] + 1) & 0xFF
	s[F_PUSH] = y


## $FDE5 ($C9B1) -- the first half of it on its own: only where it stands
## along the level, which is all the ones that must not stray far need.
func record_home_along(s: PackedByteArray) -> void:
	# $FDF0 -- across, the view counts only where the level scrolls sideways.
	if lvl.vertical:
		s[F_KEEP] = s[F_X]
		s[F_KEEP2] = s[F_XHI]
	else:
		var v: int = ((s[F_XHI] << 8) | s[F_X]) + cam
		s[F_KEEP] = v & 0xFF
		s[F_KEEP2] = (v >> 8) & 0xFF


## $ACD0 in bank 11, shared by $38 and $3C -- has it walked too far from the
## place it woke in?  Home less here, in sixteen bits; a screen and a half
## either way is too far, and only if it is still going that way.
func strayed_far(s: PackedByteArray) -> bool:
	var here_hi := 0
	var here_lo := 0
	if lvl.vertical:
		here_hi = s[F_XHI]
		here_lo = s[F_X]
	else:
		var w: int = ((s[F_XHI] << 8) | s[F_X]) + cam
		here_hi = (w >> 8) & 0xFF
		here_lo = w & 0xFF
	var d: int = (((s[F_KEEP2] << 8) | s[F_KEEP]) - ((here_hi << 8) | here_lo)) \
			& 0xFFFF
	var hi: int = d >> 8
	var lo: int = d & 0xFF
	var going_back: bool = (s[F_VX] & 0x80) != 0
	if lo < 0x80:
		if hi != 1:                                    # $ACED CPY #$01
			return false
		return going_back                              # $ACF5 BMI
	if hi != 0xFE:                                     # $ACFC CPY #$FE
		return false
	return not going_back                              # $AD04 BPL


## $FE08 -- and the way back.
func restore_home(s: PackedByteArray) -> void:
	if lvl.vertical:
		s[F_XHI] = s[F_KEEP2]
		s[F_X] = s[F_KEEP]
	else:
		var t: int = s[F_KEEP] - (cam & 0xFF)
		s[F_X] = t & 0xFF
		s[F_XHI] = (s[F_KEEP2] - (cam >> 8) - (1 if t < 0 else 0)) & 0xFF
	if not lvl.vertical:
		s[F_Y] = s[F_PUSH]
		s[F_YHI] = s[F_ANG]
		return
	var d: int = s[F_PUSH] - (cam & 0xFF)
	var hi: int = (s[F_ANG] - (cam >> 8) - (1 if d < 0 else 0)) & 0xFF
	# The sixteen a page over-counts, taken back off once for every page.
	var pages: int = ((s[F_ANG] - (cam >> 8)) << 4) & 0xFF
	var y: int = (d & 0xFF) - pages
	s[F_Y] = y & 0xFF
	s[F_YHI] = (hi - (1 if y < 0 else 0)) & 0xFF


## $FC45 ($C963) -- write one place's record over another's.  All of it but
## the record's own number and the last four fields.
func copy_row(dst: int, src: PackedByteArray) -> void:
	var d: PackedByteArray = slots[dst]
	for f in range(0, 25):
		if f == F_REC:
			continue
		d[f] = src[f]
	slots[dst] = d


## $FEAA ($C9C0) -- turn a record into the burst.
func make_burst(n: int) -> void:
	var b: PackedByteArray = slots[n]
	b[F_STATE] = 0                                     # $FCF6
	b[F_TYPE] = 0x01
	b[F_KEEP] = 0x01
	b[F_KEEP2] = 0x00
	b[F_LIFE] = 0x00
	b[F_MARK] = 0x80                                   # $FD86
	slots[n] = b


## $8C3A -- the one that returns.  The level's scan puts it out once; after
## that it keeps its own place in the world, and every time it is killed it
## waits a while and comes back to it.
func _mind_42(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _home_42(s)
		1: _wait_42(s)
		2: _pick_42(n, s)
		3: _blink_42(s)
		4: _fly_42(n, s)


## $8C49 -- learn the spot, and how long to wait before the first coming.
func _home_42(s: PackedByteArray) -> void:
	record_home(s)                                     # $C9AE
	_wind_42(s)
	s[F_STATE] += 1                                    # $FCEE


## $8C4C and $8D85 -- between sixty-three and ninety-four frames.
func _wind_42(s: PackedByteArray) -> void:
	var r: int = random() & 0x1F                       # $C939
	s[F_SELF] = (r + 0x3F + (1 if rng_carry else 0)) & 0xFF


## $8C59
func _wait_42(s: PackedByteArray) -> void:
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] == 0:
		s[F_STATE] += 1                                # $FCEE


## $8C5F -- back to the spot, and look for open air to appear in.  It only
## asks every other frame.
func _pick_42(n: int, s: PackedByteArray) -> void:
	if not its_turn(n, clock):                         # $BE3E
		return
	restore_home(s)                                    # $C9BA
	if s[F_XHI] != 0 or s[F_YHI] != 0:
		# The spot has gone off the level altogether.
		clear(n)                                       # $C810
		return
	if s[F_Y] >= 0xB0 or s[F_Y] < 0x10:
		return
	if not _clear_spot_42(s):                          # $8DAE
		return
	# $8CB0
	s[F_MARK] = 0x80                                   # $C9AB
	s[F_SELF] = 0x40                                   # $BE75
	start_anim(s, 0x05)                                # $BEAD
	s[F_BITS] = 0xC0 if random() & 1 else 0x80         # $C939
	s[F_STATE] += 1                                    # $FCEE


## $8D92 -- a column at random, but not within sixteen of his: that near, the
## column is thrown half a screen over instead.
func _random_x_42(s: PackedByteArray) -> void:
	s[F_X] = random()                                  # $C939
	var d: int = (s[F_X] - slots[0][F_X]) & 0xFF
	if d >= 0x80:
		d = (-d) & 0xFF                                # $C858
	if d < 0x10:
		s[F_X] = s[F_X] ^ 0x80


## $8DAE -- is the cell of sixteen it would appear in open?  All four corners
## must answer with the fourth kind of ground, and they are asked of the map
## itself rather than of the screen.
func _clear_spot_42(s: PackedByteArray) -> bool:
	_random_x_42(s)
	for c in CORNERS_42:
		if ground(s, c[0], c[1], true) != 0x04:        # $87 := $0F
			return false
	return true


## $8CCB -- flicker while it comes through, then take on life and set off.
func _blink_42(s: PackedByteArray) -> void:
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] == 0:
		s[F_BITS] = s[F_BITS] & 0x7F
		s[F_LIFE] = 0x7F                               # $BE5A
		s[F_MARK] = 0x01
		set_speed_side_facing(s, 0xFE, 0x80)           # $BEC5 with 80 FE
		s[F_STATE] += 1                                # $FCEE
		return
	if s[F_SELF] & 3:
		return
	var on: int = 0x80 if s[F_SELF] & 4 else 0x00
	s[F_BITS] = (s[F_BITS] & 0x7F) | on


## $8D03 -- fly at him.  Once in four frames it looks where it is going.
func _fly_42(n: int, s: PackedByteArray) -> void:
	if s[F_LIFE] != 0x7F:
		_die_42(n, s)
		return
	if s[F_YHI] != 0:
		clear(n)                                       # $C810
		return
	if ((n ^ clock) & 3) == 0:
		if s[F_XHI] != 0:
			s[F_BITS] = 0x40 if s[F_XHI] >= 0x80 else 0x00
			set_speed_side_facing(s, 0xFE, 0x80)       # $BEC5 with 80 FE
		var off: int = 0x0B if s[F_BITS] & 0x40 else 0xF4
		# $C945 -- out of its own turn the answer is that nothing is there.
		if ground_turn_clear(n, s, off, 0x00) >= 0x80:
			turn_about(s)                              # $C91B
	step_anim(s)                                       # $C8EE
	step_both(s)


## $8D45 -- killed.  It hands its own body to a free place to burst in and
## goes back to waiting; with nowhere to hand it, it bursts itself and does
## not come again.
func _die_42(n: int, s: PackedByteArray) -> void:
	var free: int = -1
	for k in range(FIRST_PLACED, SLOTS):               # $CB0B
		if slots[k][F_TYPE] == 0:
			free = k
			break
	if free < 0:
		make_burst(n)                                  # $C9C0
		return
	copy_row(free, s)                                  # $C963
	make_burst(free)
	# $8D5F -- and the one down that $FEAA had just put up.
	var b: PackedByteArray = slots[free]
	b[F_KEEP] = 0x00
	slots[free] = b
	# $8D7D
	s[F_MARK] = 0x80                                   # $C9AB
	s[F_KIND] = 0x00
	_wind_42(s)
	s[F_STATE] = 1                                     # $FCFA


## $92D5 -- how heavy the one that swaps floor for ceiling is, by the low
## seven bits of the record's own byte.
const WEIGHT_23 := [0x28, 0x18, 0x11]


## $F6E2 -- the angle from one point to another, as a whole turn in two
## hundred and fifty six.  Which eighth of the turn it falls in comes from
## three bits -- the sign of the difference across, the sign of the difference
## down, and which of the two is the longer -- and how far round that eighth
## from the share of the shorter in the longer.
func _atan(x0: int, y0: int, x1: int, y1: int) -> int:
	var bits := 0
	# $F6E6 -- each subtraction rolls its borrow into the top of $04 and then
	# the difference is made plain.
	var dx: int = x0 - x1
	bits = (bits >> 1) | (0x00 if dx < 0 else 0x80)
	dx = dx if dx >= 0 else -dx
	dx = dx & 0xFF
	var dy: int = y0 - y1
	bits = (bits >> 1) | (0x00 if dy < 0 else 0x80)
	dy = dy if dy >= 0 else -dy
	dy = dy & 0xFF
	# $F704 -- and the third bit is whether the one down is the longer.
	bits = (bits >> 1) | (0x80 if dy >= dx else 0x00)
	if dx == 0:
		return (bits << 1) & 0xFF                      # $F759
	if dy == 0:
		return (bits << 2) & 0xFF                      # $F75D
	if dy == dx:
		# $F762 -- four rolls bring the three bits down to the bottom.
		var r: int = bits
		for _k in range(4):
			r = ((r << 1) | (r >> 7)) & 0xFF
		return quarter[r & 0x03]
	# $F716 -- the shorter over the longer, to eight bits.
	var num: int = dx if bits & 0x80 else dy
	var den: int = dy if bits & 0x80 else dx
	var q := 0
	var rem: int = num
	var carry := 0
	for _k in range(8):
		q = ((q << 1) | carry) & 0x1FF
		var t: int = (rem << 1) | (q >> 8)
		q = q & 0xFF
		carry = 0
		if t >= 0x100 or (t & 0xFF) >= den:
			rem = (t - den) & 0xFF
			carry = 1
		else:
			rem = t & 0xFF
	q = ((q << 1) | carry) & 0xFF
	var i: int = (bits >> 4) & 0x0F
	var up: bool = (octant[i] & 1) != 0
	var base: int = octant[i + 1]
	if up:
		return (base + atan[q] + 1) & 0xFF             # $F751
	return (base - atan[q] - 1) & 0xFF                 # $F755


## $F8C9 ($C8E2) -- put a new thing out beside this one and send it at him.
## The angle is taken from where the child lands to ten points above his feet.
func make_child_at_hero(s: PackedByteArray, side: int, down: int, what: int,
		mag: int) -> int:
	var x: int = ((s[F_XHI] << 8) | s[F_X]) + _signed(side)
	if (x >> 8) & 0xFF:
		return -1
	var y: int = ((s[F_YHI] << 8) | s[F_Y]) + _signed(down)
	if (y >> 8) & 0xFF:
		return -1
	# $F951
	var ang: int = _atan(x & 0xFF, y & 0xFF, slots[0][F_X],
			(slots[0][F_Y] + 0xF6) & 0xFF)
	for k in range(FIRST_LIVE, FIRST_PLACED):          # $CB1B
		var c: PackedByteArray = slots[k]
		if c[F_TYPE] != 0:
			continue
		c[F_TYPE] = what
		c[F_X] = x & 0xFF
		c[F_Y] = y & 0xFF
		c[F_MARK] = 0x08
		set_speed_at(c, mag, ang)
		return k
	return -1


## $9D02 -- how far the risen line stands above a thing, and whether the
## thing has gone under it.  Only the areas that fill up ($87 = 5) have such a
## line at all; anywhere else the cartridge answers $FF and "not under", which
## every caller reads as leave to carry on.  [gap, gone under]
##
func under_line(s: PackedByteArray) -> Array:
	if lvl.kind != 5:                                  # $9D04
		return [0xFF, false]
	if s[F_YHI] & 0x80:                                # $9D08, above the top
		return [0xFF, false]
	if s[F_YHI] != 0:                                  # below the bottom
		return [0x00, true]
	var d: int = water - s[F_Y]                        # $9D0F
	if d < 0:
		return [d & 0xFF, true]
	return [d, false]


## $A650 -- the hatch.  It opens, lets one out, shuts, and waits; and it keeps
## its own number in the table in $05FA so that afterwards it can look at what
## it let out and hold the next one back until that one is done.
func _mind_1e(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _wake_1e(n, s)
		1: _wait_1e(s)
		2: _open_1e(s)
		3: _shut_1e(s)


## $A66C
func _wake_1e(n: int, s: PackedByteArray) -> void:
	if not lvl.vertical:                               # $A715
		nudge_side(s, 0, 8)                            # $C936
	var r: int = random()                              # $C939
	s[F_SELF] = ((r & 0x1F) + 0x1F + (1 if rng_carry else 0)) & 0xFF
	s[F_COUNT] = s[F_LIFE]
	s[F_LIFE] = 0x10                                   # $BE5A
	s[F_MARK] = 0x01
	s[F_KEEP] = n                                      # $A683, its own number
	start_anim(s, 0x0E)                                # $BEAD
	s[F_STATE] += 1                                    # $C966


## $A68E -- shut and counting.  The bottom bit of the record's own byte says
## whether it lets out the grabber, and a hatch that does waits for the one it
## let out to be gone before it opens again.
func _wait_1e(s: PackedByteArray) -> void:
	if s[F_SELF] != 0:
		var u: Array = under_line(s)                   # $9D02
		if u[1] or u[0] < 0x10:
			return
		s[F_SELF] = (s[F_SELF] - 1) & 0xFF
		return
	if s[F_COUNT] & 1:                                 # $A693
		var t: int = slots[s[F_KEEP]][F_TYPE]
		if t == 0x2C or t == 0x2D or t == 0x2E:
			return
	s[F_STATE] += 1                                    # $C966


## $A6BA -- opening.  At the picture $40, the widest, out it comes -- into the
## level's own eight places, not the six the children use.
func _open_1e(s: PackedByteArray) -> void:
	step_anim(s)                                       # $C837
	if s[F_KIND] != 0x40:
		return
	if s[F_XHI] == 0 and s[F_YHI] == 0:                # $C9C3
		var u: Array = under_line(s)                   # $9D02
		if not u[1] and u[0] >= 0x10:
			var px: int = s[F_X]                       # $C924
			var py: int = s[F_Y]
			for k in range(FIRST_PLACED, SLOTS):       # $C86A
				var c: PackedByteArray = slots[k]
				if c[F_TYPE] != 0:
					continue
				c[F_X] = px                            # $C927
				c[F_Y] = py
				if s[F_COUNT] & 1:
					c[F_STATE] = 0x06
					s[F_KEEP] = k
					c[F_TYPE] = 0x2C
				else:
					c[F_TYPE] = 0x1F
				slots[k] = c
				break
	s[F_STATE] += 1                                    # $A6FB


## $A6FE -- shutting.  How long it then waits hangs on the top bit of the
## record's own byte: forty frames or a hundred and twenty.
func _shut_1e(s: PackedByteArray) -> void:
	if step_anim(s) != 0x3D:                           # $C837
		return
	s[F_SELF] = 0x78 if s[F_COUNT] & 0x80 else 0x28
	s[F_STATE] = 1                                     # $C96F


## $93A8 -- the one that opens up and lets one out.  It plays one run of
## pictures through; at the picture $54, the moment it is widest, it puts a
## $33 out where it stands itself, and from then on it only shuts.
func _mind_2f(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_COUNT] = s[F_LIFE]                         # $93AD
		s[F_LIFE] = 0x05                               # $BE5A
		s[F_MARK] = 0x01
		start_anim(s, 0x1A)                            # $BEAD
		s[F_SELF] = 0x28                               # $BE75
		s[F_STATE] += 1                                # $C966
		return
	if s[F_SELF] != 0:
		# $93C7 -- while it still has a count to burn it holds at the last
		# picture, and burns the count every other frame.
		if s[F_KIND] != 0x53:
			step_anim(s)                               # $C837
			return
		if clock & 1:                                  # $0119, ROR
			s[F_SELF] = (s[F_SELF] - 1) & 0xFF
		return
	if step_anim(s) != 0x54:                           # $93DB
		return
	if s[F_XHI] == 0 and s[F_YHI] == 0:                # $C9C3
		var spot_x: int = s[F_X]                       # $C924
		var spot_y: int = s[F_Y]
		for k in range(FIRST_LIVE, FIRST_PLACED):      # $C873
			var c: PackedByteArray = slots[k]
			if c[F_TYPE] != 0:
				continue
			c[F_X] = spot_x                            # $C927
			c[F_Y] = spot_y
			c[F_TYPE] = 0x33
			c[F_STATE] = 3
			c[F_COUNT] = s[F_COUNT]
			slots[k] = c
			break
	s[F_SELF] = 0xFF                                   # $BE75


## $9EF1 (банк 10) -- лифт по расписанию.  Байт записи выбирает одну из
## четырёх записок ($9F64..$9F94); в записке тройками лежат "сколько кадров",
## "какая скорость вбок" и "какая вниз", а ноль в начале тройки отсылает
## обратно к её началу.  Скорости берутся из пяти готовых ($9FA4..$9FB7).
const SCRIPT_15 := [
		[0x18, 0x03, 0x00, 0x20, 0x00, 0x03, 0x30, 0x01, 0x00,
			0x20, 0x00, 0x01, 0x18, 0x03, 0x00, 0x00],
		[0x30, 0x04, 0x00, 0x40, 0x00, 0x04, 0x60, 0x02, 0x00,
			0x40, 0x00, 0x02, 0x30, 0x04, 0x00, 0x00],
		[0x18, 0x01, 0x00, 0x20, 0x00, 0x03, 0x30, 0x03, 0x00,
			0x20, 0x00, 0x01, 0x18, 0x01, 0x00, 0x00],
		[0x30, 0x02, 0x00, 0x40, 0x00, 0x04, 0x60, 0x04, 0x00,
			0x40, 0x00, 0x02, 0x30, 0x02, 0x00, 0x00]]
const XFR_15 := [0x00, 0x00, 0x80, 0x00, 0x80]
const XWH_15 := [0x00, 0x01, 0x00, 0xFF, 0xFF]
const YFR_15 := [0x00, 0x00, 0x80, 0x00, 0x80]
const YWH_15 := [0x00, 0xFF, 0xFF, 0x01, 0x00]

func _mind_15(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		start_anim(s, 0x02)                            # $BEAD
		s[F_REC_BYTE] = s[F_LIFE]
		s[F_LIFE] = 0xFF                               # $BE5A
		s[F_MARK] = 0x01
		_script_15(s)                                  # $9F15
		s[F_STATE] += 1                                # $C966
		return
	s[F_PUSH] = (s[F_PUSH] - 1) & 0xFF
	if s[F_PUSH] == 0:
		_script_15(s)
	step_anim(s)                                       # $C8EE
	step_both(s)


## $9F15 -- взять из записки следующую тройку.
func _script_15(s: PackedByteArray) -> void:
	var prog: Array = SCRIPT_15[s[F_REC_BYTE]]
	var pc: int = s[F_ANG]
	if prog[pc] == 0:                                  # $9F29
		pc = 0
	s[F_PUSH] = prog[pc]
	var ix: int = prog[pc + 1]
	s[F_VXFR] = XFR_15[ix]
	s[F_VX] = XWH_15[ix]
	var iy: int = prog[pc + 2]
	s[F_VYFR] = YFR_15[iy]
	s[F_VY] = YWH_15[iy]
	s[F_ANG] = pc + 3


## $9C7D (банк 10) -- плывун.  Он ждёт случайный срок, всплывает и едет
## вбок с одной из четырёх скоростей, которую выбирает байт записи; упёршись в
## стену, возвращается на своё место и начинает снова.  Ушёл под черту
## воды -- исчез ($9D02).
const SIDE_1A := [0x01, 0x00, 0xFF, 0xFF]
const FRAC_1A := [0x00, 0x80, 0x00, 0x80]

func _mind_1a(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _wake_1a(s)
		1: _wait_1a(s)
		_: _swim_1a(n, s)


## $9C86 -- байт записи убирается в своё поле, а жизнь становится $FF.
func _wake_1a(s: PackedByteArray) -> void:
	s[F_REC_BYTE] = s[F_LIFE]
	s[F_LIFE] = 0xFF                                   # $BE6A
	var i: int = s[F_REC_BYTE] & 0x7F
	set_speed_side(s, SIDE_1A[i], FRAC_1A[i])          # $C906
	s[F_COUNT] = (random() & 0x7F) | 0x01       # $C939
	record_home(s)                                     # $C9AE
	s[F_STATE] += 1                                    # $C966


## $9CBA -- срок вышел, он показывается и начинает биться.
func _wait_1a(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	s[F_MARK] = 0x01                                   # $C99F
	start_anim(s, 0x0C)                                # $BEAD
	s[F_STATE] += 1                                    # $C966


## $9CCA -- ход.  О стену он смотрит лишь каждый восьмой кадр.
func _swim_1a(n: int, s: PackedByteArray) -> void:
	if under_line(s)[1]:                               # $9D02
		clear(n)                                       # $C810
		return
	step_anim(s)                                       # $C837
	step_side(s)                                       # $C8F7
	if ((n ^ clock) & 0x07) != 0:                      # $0119
		return
	var side: int = 0x08 if s[F_REC_BYTE] < 0x80 else 0xF8
	if ground_turn_clear(n, s, side, 0x00) < 0x80:     # $C945
		return
	restore_home(s)                                    # $C9BA
	s[F_KIND] = 0x00                                   # $BE6E
	s[F_MARK] = 0x80                                   # $C9AB
	s[F_COUNT] = 0x40                                  # $BE7C
	s[F_STATE] -= 1                                    # $C969


## $8DE4 (банк 10) -- гнездо.  Оно стоит на месте и рожает $1C, когда герой
## подходит ближе чем на $40 вдоль, но не вплотную ($08).  Ребёнок ложится
## ровно туда же, где гнездо, и в те же восемь мест, что держат детей ($C873).
func _mind_1b(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_MARK] = 0x80                                # $C9AB
		s[F_STATE] += 1                                # $C966
		return
	if s[F_STATE] == 1:
		if (s[F_XHI] | s[F_YHI]) != 0:                 # $C9C3
			return
		var d: int = hero_side(s)[0]                   # $C86D
		if d >= 0x40 or d < 0x08:
			return
		var px: int = s[F_X]                           # $C924
		var py: int = s[F_Y]
		for k in range(FIRST_LIVE, FIRST_PLACED):      # $C873
			var c: PackedByteArray = slots[k]
			if c[F_TYPE] != 0:
				continue
			c[F_X] = px                                # $C927
			c[F_Y] = py
			c[F_TYPE] = 0x1C
			slots[k] = c
			s[F_COUNT] = 0x80                          # $BE7C
			s[F_STATE] += 1                            # $C966
			return
		return
	# $8E21 -- отдых между выводками.
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] == 0:
		s[F_STATE] -= 1                                # $C969


## $910D -- the one that hangs in the air and spits.  The bottom bit of the
## record's own byte says which way round it is: clear and it hangs above and
## sinks towards him, set and it stands below and rises.
func _mind_22(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		_wake_22(s)
		return
	_hang_22(s)


## $9112
func _wake_22(s: PackedByteArray) -> void:
	nudge_eight(s, s[F_LIFE])                          # $C9BD
	s[F_SELF] = s[F_LIFE] & 0x01
	s[F_LIFE] = 0x01                                   # $BE5A
	s[F_MARK] = 0x01
	record_home(s)                                     # $C9AE
	s[F_STATE] += 1                                    # $C966
	_arm_22(s)


## $912A -- the start of a sweep, and of every sweep after the first.  How
## long it waits before setting off is a fresh number each time; the carry the
## seed left behind counts towards it.
func _arm_22(s: PackedByteArray) -> void:
	face_hero(s)                                       # $C8FD
	var r: int = random()                              # $C939
	s[F_COUNT] = ((r & 0x3F) + 0x40 + (1 if rng_carry else 0)) & 0xFF
	s[F_KIND] = 0x3A                                   # $BE6E
	var v: int = 0xFE
	if s[F_SELF] != 0:
		s[F_KIND] = (s[F_KIND] + 1) & 0xFF             # $9144
		v = 0x02
	s[F_VY] = v
	s[F_VYFR] = 0
	s[F_REC_BYTE] = 0x2A                               # $BE9F


## $9156 -- wait, then sweep for forty-two frames, spitting at the twenty-first
## and coming home at the last.
func _hang_22(s: PackedByteArray) -> void:
	if s[F_COUNT] != 0:
		s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
		return
	face_hero(s)                                       # $C8FD
	if s[F_SELF] == 0:
		add_speed_down(s, 0x18)                        # $C90C
	else:
		sub_speed_down(s, 0x18)                        # $C90F
	step_down(s)                                       # $C8F4
	s[F_REC_BYTE] = (s[F_REC_BYTE] - 1) & 0xFF
	if s[F_REC_BYTE] == 0:
		restore_home(s)                                # $C9BA
		_arm_22(s)
		return
	if s[F_REC_BYTE] != 0x15:
		return
	if s[F_SELF] == 0:
		_spit_22(s, 0xA0, 0xF8)                        # $9186
	else:
		_spit_22(s, 0x60, 0xFA)                        # $918C


## $8F63 -- two of them at once: one at the angle it was given, mirrored if it
## looks the other way, and one straight along the ground.
func _spit_22(s: PackedByteArray, ang: int, down: int) -> void:
	var looks_right: bool = (s[F_BITS] & 0x40) != 0    # $C990
	if looks_right:
		ang ^= 0x40
	_shot_22(s, ang, down)
	_shot_22(s, 0x00 if looks_right else 0x80, down)


## $8F7C -- and each of them leaves its mouth, which is six points behind it
## or seven in front.
func _shot_22(s: PackedByteArray, ang: int, down: int) -> void:
	var side: int = 0xFA
	if s[F_BITS] & 0x40:                               # $C990
		side = (0x100 - side + 1) & 0xFF               # $C858
	make_child_aimed(s, side, down, 0x14, 0x0C, ang)


## $B0B8 and $B0BC -- where the one that dives leaves what it leaves: always
## from the corner it has just come from.
const TRAIL_37 := [[0x0C, 0x10], [0xF4, 0x10], [0x0C, 0xF0], [0xF4, 0xF0]]


## $B00E -- the one that dives.  It hangs still until he comes within half a
## screen, then sets off across and down at him and drops four on the way.
func _mind_37(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		_wake_37(s)
		return
	_dive_37(s)


## $B017
func _wake_37(s: PackedByteArray) -> void:
	if s[F_YHI] != 0:
		return
	var side: Array = hero_side(s)                     # $C93C
	if side[2] or side[0] >= 0x80:
		return
	set_speed_side_at_hero(s, 0x00, 0x80)              # $BEBF with 80 00
	turn_about(s)                                      # $C91B
	set_speed_down(s, 0x00, 0x80)                      # $BEB9 with 80 00
	if s[F_Y] >= slots[0][F_Y]:
		flip_speed_down(s)                             # $C921
	start_anim(s, 0x1D if s[F_VY] & 0x80 else 0x1E)    # $C83A
	s[F_LIFE] = 0x04                                   # $BE5A
	s[F_MARK] = 0x01
	s[F_COUNT] = 0x04                                  # $BE7C
	s[F_STATE] += 1                                    # $C966


## $B054 -- and from then on it only flies.  Its own byte counts nineteen
## frames between one dropping and the next.
func _dive_37(s: PackedByteArray) -> void:
	step_anim(s)                                       # $C8EE
	step_both(s)
	if s[F_COUNT] == 0:
		return
	if s[F_SELF] == 0:
		if not _ready_37(s):
			return
		s[F_SELF] = 0x02                               # $BE75
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] != 1:
		return
	s[F_SELF] = 0x14                                   # $BE75
	var q := 0
	if not (s[F_VY] & 0x80):
		q = 2
	if not (s[F_VX] & 0x80):
		q += 1
	var t: Array = TRAIL_37[q]
	if make_child_at_hero(s, int(t[0]), int(t[1]), 0x14, 0x06) < 0:
		return                                         # $B0B2
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF


## $B061 -- whether this is the moment.  Which way it is going decides which
## side of him counts and which way round the two eighths of a screen are
## read, so it always lets go on the near side of him.
func _ready_37(s: PackedByteArray) -> bool:
	var d: Array = hero_down(s)                        # $C93F
	if d[2]:
		return false
	if s[F_VY] & 0x80:                                 # $B061, going up
		if d[1]:
			return false
		return d[0] >= 0x20
	if d[1]:                                           # $B073, going down
		return true
	return d[0] < 0x20


## $91A2 -- the one that swaps floor for ceiling.  The top bit of the record's
## own byte says which of the two it lives on; the rest of it says how heavy
## it is on the way over.
func _mind_23(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _wake_23(s)
		1: _sit_23(s)
		2: _rise_23(n, s)
		3: _drop_23(n, s)
		4: _land_23(s)


## $92D8 -- which picture it sits in.
func _picture_23(s: PackedByteArray) -> void:
	s[F_KIND] = 0x2F if s[F_SELF] >= 0x80 else 0x2C


## $92BD -- and which run of pictures it goes over in.
func _anim_23(s: PackedByteArray) -> void:
	start_anim(s, 0x14 if s[F_SELF] >= 0x80 else 0x13)


## $91AF
func _wake_23(s: PackedByteArray) -> void:
	s[F_SELF] = s[F_LIFE]
	s[F_LIFE] = 0x01                                   # $BE5A
	s[F_MARK] = 0x01
	s[F_COUNT] = 0x1E                                  # $BE7C
	_picture_23(s)                                     # $92D8
	s[F_STATE] += 1                                    # $FCEE


## $91C3 -- sit still, drop one at him halfway through, and at the end of the
## count push off for the other side.
func _sit_23(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		if s[F_COUNT] != 0x20:
			return
		var down: int = 0xFE if s[F_SELF] >= 0x80 else 0xF6
		make_child_at_hero(s, 0x00, down, 0x14, 0x0C)  # $C8E2
		return
	# $91E6
	_anim_23(s)                                        # $92BD
	set_speed_side_at_hero(s, 0xFF, 0x40)              # $BEBF with 40 FF
	if random() >= 0xC0:                               # $C939
		turn_about(s)                                  # $C91B
	s[F_VYFR] = 0
	if s[F_SELF] < 0x80:
		s[F_VY] = 0xFC
		s[F_STATE] += 1                                # $FCEE
	else:
		s[F_VY] = 0x04
		s[F_STATE] = 3                                 # $FD02


## $9212 -- off the floor and up.  It does not begin until the pictures have
## come round to the one that leaves the ground.
func _rise_23(n: int, s: PackedByteArray) -> void:
	if s[F_KIND] != 0x2D:
		step_anim(s)                                   # $C837
		return
	add_speed_down(s, WEIGHT_23[s[F_SELF] & 0x7F])     # $92CB, $C90C
	if s[F_VY] < 0x80:
		if s[F_VY] >= 0x04:
			set_speed_down(s, 0x04, 0x00)              # $BEB9 with 00 04
		# $BEDD with 04 05 -- a floor four below, to either side.
		if walled_either_turn(n, s, 0x05, 0x04, 0x00) >= 0x80:
			snap_down_from(s, 0x00)                    # $C987
			_settle_23(s)
			return
	else:
		# $BEDD with E2 05 -- a ceiling thirty above.
		if walled_either_turn(n, s, 0x05, 0xE2, 0x00) >= 0x80:
			set_speed_down(s, 0x00, 0x00)              # $BEB9 with 00 00
	step_down(s)                                       # $C8F4
	walled_ahead_turn_about(n, s, 0xF6, 0xFF, 0xF1)    # $BF12 with F6 F1 FF
	step_side(s)                                       # $C8F7


## $9260 -- and the same the other way up.
func _drop_23(n: int, s: PackedByteArray) -> void:
	if s[F_KIND] != 0x30:
		step_anim(s)                                   # $C837
		return
	sub_speed_down(s, WEIGHT_23[s[F_SELF] & 0x7F])     # $92CB, $C90F
	if s[F_VY] >= 0x80:
		if s[F_VY] < 0xFB:
			set_speed_down(s, 0xFB, 0x00)              # $BEB9 with 00 FB
		# $BEDD with EC 05 -- a ceiling twenty above.
		if walled_either_turn(n, s, 0x05, 0xEC, 0x00) >= 0x80:
			snap_down_from(s, 0xF0)                    # $C98A
			_settle_23(s)
			return
	else:
		# $BEDD with 10 05 -- a floor sixteen below.
		if walled_either_turn(n, s, 0x05, 0x10, 0x00) >= 0x80:
			set_speed_down(s, 0x00, 0x00)              # $BEB9 with 00 00
	step_down(s)                                       # $C8F4
	walled_ahead_turn_about(n, s, 0xF6, 0xF1, 0xFF)    # $BF12 with F6 FF F1
	step_side(s)                                       # $C8F7


## $9256 -- arrived.
func _settle_23(s: PackedByteArray) -> void:
	_anim_23(s)                                        # $92BD
	s[F_COUNT] = 0x10                                  # $BE7C
	s[F_STATE] = 4                                     # $FD06


## $92A7 -- settle, then sit for between sixty-three and a hundred and
## twenty-six frames before going over again.
func _land_23(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	var r: int = random() & 0x3F                       # $C939
	s[F_COUNT] = (r + 0x3F + (1 if rng_carry else 0)) & 0xFF
	_picture_23(s)                                     # $92D8
	s[F_STATE] = 1                                     # $FCFA
