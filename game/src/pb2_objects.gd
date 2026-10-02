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
## $B8D3 -- how long the boss's trail is before it starts over.
const TRAIL := 0x0C
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

## $0677 -- the spare byte of the fifteenth place, which is where a boss
## stands.  $F163 reads it every frame as a request for a noise.
const NOISE_SLOT := 15


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
const MINDS := {0x46: "_mind_46", 0x3D: "_mind_3d", 0x48: "_mind_48", 0x01: "_mind_01", 0x02: "_mind_02", 0x11: "_mind_12", 0x45: "_mind_42", 0x1F: "_mind_1f", 0x2A: "_mind_2a", 0x16: "_mind_16", 0x18: "_mind_18", 0x10: "_mind_10", 0x23: "_mind_23",
		0x12: "_mind_12", 0x17: "_mind_17", 0x19: "_mind_19",
		0x13: "_mind_13", 0x1D: "_mind_1d",
		0x2C: "_mind_2c", 0x2D: "_mind_2c",
		0x42: "_mind_42",
		0x2E: "_mind_2c",
		0x22: "_mind_22", 0x37: "_mind_37", 0x2F: "_mind_2f",
		0x1E: "_mind_1e", 0x38: "_mind_38", 0x24: "_mind_24",
		0x3C: "_mind_3c", 0x1B: "_mind_1b", 0x1A: "_mind_1a", 0x15: "_mind_15",
		0x27: "_mind_27", 0x28: "_mind_28",
		0x07: "_mind_07", 0x08: "_mind_08", 0x2B: "_mind_2b",
		0x29: "_mind_29", 0x20: "_mind_20",
		0x39: "_mind_39",
		0x09: "_mind_09", 0x0A: "_mind_0a", 0x0B: "_mind_0b",
		0x3E: "_mind_3e", 0x3A: "_mind_3a", 0x3B: "_mind_3b",
		0x40: "_mind_40", 0x41: "_mind_41",
		0x43: "_mind_43",
		0x36: "_mind_36", 0x34: "_mind_34", 0x35: "_mind_35",
		0x0C: "_mind_0c",
		0x14: "_mind_14", 0x21: "_mind_21",
		0x0F: "_mind_0f", 0x47: "_mind_47",
		0x3F: "_mind_3f", 0x0D: "_mind_0d", 0x0E: "_mind_0e",
		0x04: "_mind_04", 0x03: "_mind_03",
		0x05: "_mind_05", 0x06: "_mind_06",
		0x50: "_mind_boss", 0x51: "_mind_boss", 0x52: "_mind_boss",
		0x53: "_mind_boss", 0x54: "_mind_boss", 0x55: "_mind_boss",
		0x56: "_mind_boss", 0x57: "_mind_boss", 0x58: "_mind_boss",
		0x59: "_mind_boss",
		0x25: "_mind_25", 0x26: "_mind_26", 0x44: "_mind_44",
		0x4B: "_mind_4b", 0x4C: "_mind_4c", 0x4D: "_mind_4d",
		0x4F: "_mind_4f"}

## $BE36 -- one bit a stage, tried against $5B to tell a stage already beaten.
const STAGE_BIT := [0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40]

## $E00A -- the table the boss rooms are filed under.  With $79 set the whole
## game reads this one whatever $53 holds, which is how a room can belong to
## the stage the hero came from and still be built out of its own list.
const BOSS_STAGE := 6

## $9C -- which area of the stage is being played.  The door puts the next one
## here before the level is asked to build itself again.
var area := 0
## $53 -- which stage is being played, in the game's own count.  Neither door
## touches it: a boss room is the seventh table's area, opened by setting $79,
## and the stage the hero walked in from stays here, because that is what the
## room reads to know which of the twelve bosses it holds ($8737, $87BB).
var came := 0
## $79 -- what opens next is a boss room, not another area of the stage.
var boss := 0
## $AD -- which half of a stage is being played: the walk, or the boss.
var phase := 0
## $4E, and with it $48 := 0 and $4A := 2 -- the end of the walk through 4:3
## takes the pad away and holds it towards the left itself.  See $0E.
var take_pad := false
## $18 := 6 -- the same place asks for the scene between the two halves of the
## stage.  What is shown is the whole game's business, not the table's.
var interlude := false
## $5B -- which stages have already been beaten.  A door with a life in its
## record is not there at all on a second walk through a beaten stage.
var cleared := 0

## $0119 -- one up every frame; $FB81 halves it between the places.
var clock := 0
## $1C -- the console's own count of pictures.  The touch sweep looks at half
## the places in one picture and the other half in the next, and it is this
## count, not $0119, that says which half.
var frame := 0
## $27 -- three while a level is being played.
var playing := 3
## $1A -- which step the level itself is on.  $CDCE picks the frame's work out
## of a table by it, and five is the step that plays the level: the water that
## rises is the fifth entry's own work and moves in no other step.
var live := 5
## $5F -- which step a big thing is on; its box changes with it.
var boss_step := 0
## $0184, $0190, $019C and $01A8 -- twelve places, twelve heights, twelve
## pictures and twelve ways of looking, which one boss writes as it goes and
## the two pieces of its tail read a dozen ticks behind it, so that they walk
## the road it walked.  It is level memory, not the boss's own, so it is here.
var trail_x := PackedByteArray()
var trail_y := PackedByteArray()
var trail_pic := PackedByteArray()
var trail_bits := PackedByteArray()
## $016A -- how full the boss's meter goes.  Nothing sets the boss's own
## health: the meter is filled four at a time up to this, and the filling is
## the giving.
var boss_bar := 0
## $4E -- a boss is on the floor.  While it is set the level is not the
## hero's own any more: the suit menu will not open ($D0A6) and the meter
## stands at the top of the screen.
var boss_here := 0

## $88F0 -- the boss of the room has fallen.  What happens next is not this
## table's business (the stage is marked cleared and the game leaves for the
## choosing screen), but $88EB is where the cartridge learns it, so the word
## is passed on from here.
var beat := false
## data/pb2/bosses.json -- who the two triggers put out, and how it dies.
var cfg_boss: Dictionary = {}
var death_cfg: Dictionary = {}
var small_shot_cfg: Dictionary = {}
var hatchling_cfg: Dictionary = {}
var drop_clock := 0  ## $98 -- successive deaths read successive nibbles.
## The ten minds themselves, which live in a file of their own.
var bosses := Pb2Bosses.new()
## $4A -- held buttons of the native hero, read by $B5BC and $A61D.
var pad_held := 0
## $5C -- which of the three sets of colours the background is wearing, and in
## bit 7 whether the walk through them is stopped at all.  In the three storm
## areas (2:3, 2:4 and 3:5) that bit turns itself over every 256 pictures --
## the storm going out and coming back -- and what the hero grabs hold of in
## those areas ($A50B) does nothing while it is set.
var storm := 0
## $0160:$0161 -- where the thing the hero rides stood when it last looked.
var ridden := [0, 0]
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
## Who keeps the counters that are his and not the level's -- the suits, the
## energy, the spare tanks.  A harness that plays without them leaves it empty
## and the pickups then only vanish.
var status = null
## $29 -- the line the water or the lava has climbed to.  The area is entered
## with the line its record names ($87 says what sort of area it is); four
## little routines under $CEE0 move it after that, and they run at the head of
## the level's frame, before anything else.
var water := 0
## $20 -- which way it is going: nought down, anything else up.  Each of the
## four routines reads it its own way round.
var flow := 0
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
## $3B -- shared bits of destroyed blocks and the level lever ($8B5E/$8B7F). It is
## wiped whenever an area is set up ($E3E8, $DFE4), so a new one of these is
## a new eight.
var broken := 0
## $0172, $0171 long -- what this visit of the area has given out.
var done: Array = []
## Э3.3 -- what he throws.  $55 is how far the blade has been raised, $A2
## whether it is the second blade, $99 how many may be in the air at once
## beyond the first, and $0400 -- the hero's own place, which keeps no type --
## counts the frames of the blade's whirr.
var power := 0
var second := 0
var extra := 0
var whirr := 0
## $011F and the three tables after it: the boxes the level itself declares
## solid this frame.  The hero works them out; a throw aimed down asks them
## whether there is floor under the place it would go.
var solids: Array = []
## PB3 guests need each platform even when the native hero does not touch it.
var guest_surfaces: Array = []
## $011A -- thirty-six to the hero's pose: where in the table of answers
## ($B990) his own six rows begin.
var hero_block := 0
## $011B..$011E -- the hero's box this frame: left, right, top, bottom.  $8009
## works it out at the head of the sweep, before any thing has had its turn,
## so all of them are measured against the one box.
var hero_box: Array = [0, 0, 0, 0]
## $08..$0B -- where the two boxes last overlapped, as $B867 left it.
var overlap: Array = [0, 0, 0, 0]
## $0167 -- something has taken hold of him this frame already, and the next
## thing only declares itself solid.
var claimed := 0
## $0117 and $0118 -- one bit a slot, six to thirteen in the first and
## fourteen to twenty-one in the second: this thing is something the suit's
## satellites may go for.  A thing sets its own bit on every turn it takes
## ($C9D2), and the hero's step wipes both bytes at the end of the frame
## ($8E4C), so they say what was there this frame and nothing older.
var marks := 0
var marks2 := 0
## $063C and $0652 -- how far the thing carrying him moves him this frame.
## They are bytes with a sign in them, and his own step reads them as such.
var push_x := 0
var push_y := 0
## The tables of work/re/pb2_weapons.md, out of data/pb2/weapons.json.
var spawn_dy := PackedByteArray()
var spawn_dx := PackedByteArray()
var throw: Array = []
var accel: Array = []
var beam_tile := PackedByteArray()
var beam_v: Array = []
var beam_a: Array = []
var beam_life: Array = []
var hold_cap := PackedByteArray()
var hold_mark: Array = []
## $01 and $02 -- the step down and the step across that
## $A764 works out, which the roads after it read.
var aim_up := 0
var aim_side := 0


## $8A -- set as the area opens, so that the first scan fills the whole screen
## and not only its edge.  The first scan to reach the end of the list, or a
## record that is still ahead of the screen, puts it out.
var fill := 0


func _init(level: Pb2Level) -> void:
	lvl = level
	area = lvl.area
	came = lvl.stage
	water = lvl.line
	for i in range(SLOTS):
		slots.append(empty_row())
	var f := FileAccess.open("res://data/pb2/objects.json", FileAccess.READ)
	var t: Dictionary = JSON.parse_string(f.get_as_text())
	# Every number that comes back from JSON is a float, and a float will not
	# even be compared with a word without complaint, so they are put back into
	# the shape the code below expects once, here.
	death_cfg = t["death"]
	small_shot_cfg = t["small_shots"]
	hatchling_cfg = t["hatchling"]
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
	for r in t["hero_box"]:
		hero_boxes.append([int(r[0]), int(r[1]), int(r[2]), int(r[3])])
	hero_blocks = PackedByteArray(t["hero_block"])
	ride_before = PackedByteArray(t["ride_before"])
	ride_action = PackedByteArray(t["ride_action"])
	var wf := FileAccess.open("res://data/pb2/weapons.json", FileAccess.READ)
	var w: Dictionary = JSON.parse_string(wf.get_as_text())
	spawn_dy = PackedByteArray(w["spawn_dy"])
	spawn_dx = PackedByteArray(w["spawn_dx"])
	beam_tile = PackedByteArray(w["beam_tile"])
	hold_cap = PackedByteArray(w["hold_cap"])
	for r in w["throw"]:
		var worlds := []
		for row in r:
			worlds.append(_words(row))
		throw.append(worlds)
	for r in w["accel"]:
		accel.append(_words(r))
	for r in w["beam_v"]:
		beam_v.append(_words(r))
	for r in w["beam_a"]:
		beam_a.append(_words(r))
	for r in w["beam_life"]:
		beam_life.append(_words(r))
	for r in w["hold_mark"]:
		hold_mark.append(_words(r))
	trail_x.resize(TRAIL)
	trail_y.resize(TRAIL)
	trail_pic.resize(TRAIL)
	trail_bits.resize(TRAIL)
	var bf := FileAccess.open("res://data/pb2/bosses.json", FileAccess.READ)
	cfg_boss = JSON.parse_string(bf.get_as_text())
	for r in t["anims"]:
		var run := {"last": int(r["last"]), "hold": int(r["hold"]),
				"first": int(r["first"])}
		if r.has("steps"):
			var steps := []
			for v in r["steps"]:
				steps.append(int(v))
			run["steps"] = steps
		anims.append(run)


## Every number JSON hands back is a float; a table of them is put back into
## words once, as it is read.
static func _words(row: Array) -> Array:
	var out := []
	for v in row:
		out.append(int(v))
	return out


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
	# Э5.7 -- the furthest column the list was ever read up to, so that a run
	# can tell "the level put nothing out" from "the level was never walked as
	# far as its first thing".  Nothing reads it but a stand.
	reached = maxi(reached, edge + 0x0F)
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
	# $D72D -- and with the slot goes the mark it left for the satellites.
	if n >= FIRST_LIVE:
		unmark_target(n)                               # $FEE0


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
## which reaches $B90D in bank 9) and stands on the ground.  The first writes
## nothing in the table of things -- $0160, $0161 and $0164 are the hero's own
## book-keeping -- but $0164 is what the grab below reads to decide whether it
## has anything to throw, so the move itself cannot be skipped.
func _mind_38(n: int, s: PackedByteArray) -> void:
	ride(s, 0x0E, 0xE4)                                # $BF20 -> $B90D
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
		# $B1A1 -- he is already in someone's hands, and all this one does is
		# stand under him.
		ride_apply(s, 0x0E, 0xE4)
		return
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


## Э5.4 -- a hero of the other game standing in this area.  He is a row of
## the same twenty nine bytes and nothing else, so the sweep can ask about him
## exactly as it asks about the row at $0400, and `guest_box` is the box his
## own game gives him, because his picture means nothing to this game's
## tables.  Empty means nobody is there, and then everything below is the
## cartridge unchanged.  See `work/re/pb3_hits.md`.
## Э5.7 -- how far along the list the scan has ever looked.
var reached := -1
var guest_row := PackedByteArray()
var guest_box: Array = []
## Э5.7 -- and more than one of them.  When neither of a pair's two heroes came
## from the game the level did, both of them are guests in it; the pair puts
## the rest here, as `[row, box, suit]` (legacy guests omit suit), and the one named above stays what it is
## because it is what Э5.4's stand hands over.
## PB3 entries: [row, combat_box, suit, held_buttons, standing_for_gate].
## Legacy contact fixtures may omit the trailing metadata.
var more_guests: Array = []

## Э5.8 -- and what a guest of this area is carrying.  One entry a guest,
## `[arms, spend]`: `arms` is what of his is in the air, each one
## `[x, y, reach, power]` in this area's own screen pixels, and
## `spend.call(j, cost)` tells his own game what the thing cost arm `j`.
## What that game makes of it is its own business -- a Solbrain gun takes it
## off $0770 and stops flying at nought, a Power Blade blade spends itself on
## nothing and flies on.  Stepping them is not this pool's: they are his, and
## they are stepped where he is.  See `work/re/pb3_arms.md`.
var guest_arms: Array = []
## PB3 only: resolve foreign breakable terrain before a blade is discarded.
var terrain_strike: Callable = Callable()


## Everyone in the room who is not the row at $0400, as `[row, box]`.
func guest_list() -> Array:
	var out: Array = []
	if not guest_row.is_empty() and guest_box.size() == 3:
		out.append([guest_row, guest_box])
	for g in more_guests:
		out.append(g)
	return out


## $B2C1 -- the hero's own box, by what he is doing: how far above his feet
## the middle of it lies, and its two halves.
static func own_box(hero: PackedByteArray) -> Array:
	if (hero[F_MARK] & 0x08) != 0:
		return [0x0C, 4, 9]
	if (hero[F_MARK] & 0x10) != 0:
		return [0x08, 8, 8]
	return [0x0F, 6, 13]


## $B23D -- the sweep.
##
## Half the places in one picture and half in the next: a thing is asked about
## only every other frame, and slipping past one at speed without being touched
## is something the cartridge lets happen.
##
## Э5.4 -- a guest of the other game is asked about the same things in the same
## order and on the same pictures.  The rhythm belongs to the area and not to
## the hero: two heroes asked on different pictures would make "slipped past at
## speed" mean two things at once in one room.  What he throws is his own
## game's and is not swept here.
func contact() -> void:
	if playing != 3:
		return
	var hero: PackedByteArray = slots[0]
	var guests: Array = guest_list()
	# Э5.8 -- and a guest's weapons are reason enough on their own: what he
	# threw can be in the air with him nowhere near it.
	if hero[F_LIFE] == 0 and guests.is_empty() and guest_arms.is_empty():
		return
	# $B248 -- the forty pictures after a blow are counted down here and
	# nowhere else, and he flashes for as long as they last.  When the harness
	# hands his row over it has already been counted down on the cartridge.
	if hero[F_LIFE] != 0 and not hero_told and hero[F_STUN] != 0:
		hero[F_STUN] -= 1
		hero[F_BITS] ^= 0x80
	# And the guest's own grace is counted down the same way.  The flashing is
	# not: how a guest is drawn is his own game's business.
	for g in guests:
		var row: PackedByteArray = g[0]
		if row[F_STUN] != 0:
			row[F_STUN] -= 1
	var n: int = 6 if (frame & 1) != 0 else 7
	while n < SLOTS:
		var s: PackedByteArray = slots[n]
		# $B24E -- the sweep keeps the place in X for as long as it looks at
		# it, and both of the little routines below run with it still there.
		# So a noise asked for from inside them is asked for in its name,
		# even though the code doing the asking is the blade's, not its own.
		Pb2Sound.at_slot = n
		if s[F_TYPE] != 0 and (s[F_XHI] | s[F_YHI]) == 0:
			if slots[0][F_LIFE] != 0:
				_touch(n, slots[0], own_box(slots[0]), suit)
				_shots(n)
			# Э5.8 -- and what the guests are carrying, over the same thing
			# and in the same order.  Their own hero need not be here at all
			# for what he threw to be in the air.
			if not guest_arms.is_empty():
				_guest_shots(n)
			for g in guests:
				var row: PackedByteArray = g[0]
				if row[F_LIFE] != 0 and slots[n][F_TYPE] != 0:
					_touch(n, row, g[1], int(g[2]) if g.size() > 2 else 0,
						int(g[3]) if g.size() > 3 else 0,
						bool(g[4]) if g.size() > 4 else true)
		n += 2
	Pb2Sound.at_slot = -1


## $B285 -- is this one asked about at all, and does the hero reach it?
func _touch(n: int, hero: PackedByteArray, mine: Array, actor_suit: int = -1,
		actor_pad: int = -1, actor_ready: bool = true) -> void:
	var s: PackedByteArray = slots[n]
	if s[F_TYPE] == 0x0C:
		return                                  # a breakable block is scenery
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
	# His own box ($B2C1), which for a guest is the one his own game gives him.
	# PB3 doorways use the level's approach box. Solbrain's walking art has
	# a four-pixel half-width and stops nine pixels from the door; the native
	# six-pixel half-width reaches its trigger without requiring a slide.
	if s[F_TYPE] in [0x03, 0x04]:
		mine = own_box(hero)
	var up: int = int(mine[0])
	var half_w: int = int(mine[1])
	var half_h: int = int(mine[2])
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
		_trip(n, hero, pad_held if actor_pad < 0 else actor_pad, actor_ready) # $B5A5
		return
	_wound_hero(n, hero, suit if actor_suit < 0 else actor_suit) # $B39E
	s = slots[n]
	if s[F_MARK] == 0x80 or s[F_TYPE] == 0:
		return                                  # $B33D -- it is already gone
	# $B36A -- forty pictures of grace, and which way the blow threw him.
	hero[F_STUN] = 0x28
	Pb2Sound.want(0x18)                         # $B371 -- he has been hit
	if (s[F_MARK] & 0x02) != 0:
		hero[F_PUSH] = 0xFF
	elif hero[F_X] >= s[F_X]:
		hero[F_PUSH] = 0x00
	else:
		hero[F_PUSH] = 0x01
	if (s[F_MARK] & 0x02) != 0:
		clear(n)                                # it ends on him


## $B39E -- the suit strikes back, and what is left of the blow reaches him.
func _wound_hero(n: int, hero: PackedByteArray, actor_suit: int = -1) -> void:
	var s: PackedByteArray = slots[n]
	# Native callers use the pool suit; PB3 contacts supply the actual actor.
	if (hero[F_MARK] & 0x10) != 0 and (suit if actor_suit < 0 else actor_suit) != 0:
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
## is his own counters and not the table's, so it is handed to whoever keeps
## them.  A harness that keeps none says so by leaving `status` empty.
func _pick_up(n: int) -> void:
	var s: PackedByteArray = slots[n]
	var what: int = s[F_TYPE]
	if status != null:
		status.life = slots[0][F_LIFE]
		# A foreign pickup must not resurrect an inactive native slot.
		# Reward recipient/conversion remains PB3 GAP-01.
		if status.life != 0 or (s[F_LIFE] & 15) != 0:
			status.take(s[F_LIFE])          # $B4CD
		playing = status.mode             # $27: a pickup may begin a refill
		power = status.power_level
		second = status.second_blade
		extra = status.extra_shot
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
func _trip(n: int, hero: PackedByteArray, actor_pad: int, actor_ready: bool) -> void:
	var s: PackedByteArray = slots[n]
	if s[F_TYPE] == 0x03:
		if hero[F_MARK] != 0 or not actor_ready:
			return
		if (actor_pad & 0x08) == 0:
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
		Pb2Sound.want(0x26)                     # $B67F -- it rang off armour
		s[F_STUN] = 0x08                        # armour: it only rings
		return
	# $B688 -- a breakable block has no health to take off: one hit does it.
	if s[F_TYPE] == 0x0C:
		s[F_STATE] = 0x02
		s[F_MARK] = 0x80
	else:
		_wound(n, shot_power[slots[y][F_TYPE]])
	Pb2Sound.want(0x21)                         # $B67A -- and this one told


## Э5.8 -- a guest's weapons against this one thing.  The same walk as $B5D5,
## and the same gates below it; what differs is only that the place, the reach
## and the strength come as numbers instead of out of this game's tables by
## type, because a guest's weapon has no type here.
func _guest_shots(n: int) -> void:
	var s: PackedByteArray = slots[n]
	# $B5D8 and $B5E1 -- a thing still ringing from the last blow, or one
	# already on its way out, is not asked about at all.
	if s[F_STUN] != 0:
		return
	if (s[F_BITS] & 0x80) != 0:
		return
	for g in guest_arms:
		var arms: Array = g[0]
		var spend: Callable = g[1]
		for j in range(arms.size()):
			var a: Array = arms[j]
			if a.size() != 4:
				continue
			var cost: int = _guest_hit(n, a)
			if cost >= 0 and spend.is_valid():
				spend.call(j, cost)


## $B606 with the shot's numbers handed in.  It answers what the thing cost
## the shot -- which in this game is how much that thing hurts, the very
## number $8731 takes off $0770 in the other one -- or minus one for a miss.
func _guest_hit(n: int, a: Array) -> int:
	var s: PackedByteArray = slots[n]
	if s[F_TYPE] == 0:
		return -1
	if s[F_LIFE] == 0xFF:
		return -1                               # nothing can break it
	if s[F_STUN] != 0:
		return -1
	if (s[F_MARK] & 0xDA) != 0:
		return -1
	if (s[F_BITS] & 0x80) != 0:
		return -1
	var b := _box_of(s)
	var mid := _middle_of(s)
	var reach: int = int(a[2])
	var dx := _apart(int(a[0]) & 0xFF, s[F_X])
	var dy := _apart(int(a[1]) & 0xFF, mid)
	if ((int(b[0]) + reach) & 0xFF) < dx:
		return -1
	if ((int(b[1]) + reach) & 0xFF) < dy:
		return -1
	# The same two places as $B67F and $B67A above.  No recording can show
	# this: the cartridge has no guest, and a guest's weapon reaching one of
	# this game's things is Э5.8's own rule.  The noise is this game's thing
	# being hit, so it is this game's driver that says so.
	if (s[F_MARK] & 0x20) != 0:
		Pb2Sound.want(0x26)                     # $B67F
		s[F_STUN] = 0x08                        # armour: it only rings
		return hurt[s[F_TYPE]]
	# $B688 -- a breakable block has no health to take off: one hit does it.
	if s[F_TYPE] == 0x0C:
		s[F_STATE] = 0x02
		s[F_MARK] = 0x80
	else:
		_wound(n, int(a[3]))
	Pb2Sound.want(0x21)                         # $B67A
	return hurt[s[F_TYPE]]


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
## $BF32 -- cycle the three background CHR bank sets.
## In the three stormy areas it steps every four frames (normally eight), and every 256
## pictures the storm switches off and on again -- that is the seventh bit of
## $5C.  While the suit menu is open ($4D), nothing moves at all.
func step_colour(menu: bool) -> void:
	var thunder: bool = ((came == 2 and (area == 3 or area == 4))
			or (came == 3 and area == 5))
	if thunder:
		if menu:                                       # $BF50
			return
		if frame == 0:                                 # $BF55
			storm ^= 0x80
			if storm >= 0x80:
				return
			# $BF61 -- the thunder.  The request stands on exactly the
			# step the storm lights up on, and no harness judges it: $BF32
			# is called by the picture's own order ($CEF0), and no stand
			# compares that against the cartridge.  The place is Э6.3.7.
			Pb2Sound.want(0x15)
		if storm >= 0x80:                              # $BF66
			return
		if (frame & 0x03) != 0:
			return
	else:
		if storm >= 0x80:                              # $BF72
			return
		if (frame & 0x07) != 0:
			return
	storm = (storm + 1) % 3                            # $BF7C


func turns() -> Array:
	clock = (clock + 1) & 0xFF
	# $8009 -- his box first of all, and then $800C wipes what the level said
	# about him last frame.  The order matters: the box is the one he stood in
	# when the frame opened, and every thing of this frame is measured by it.
	hero_look()                                        # $BF18 -> $BA44
	solids = []                                        # $011F
	guest_surfaces.clear()
	claimed = 0                                        # $0167
	# $F163 -- the spare byte of the fifteenth place read as a request for a
	# noise: one asks for it once, two asks for it over and over.  The once is
	# taken back where it is read, the over and over is left standing.  There
	# is no sound in the engine, so the taking back is all that is left of it.
	#
	# It belongs to one boss and no one else.  $F11F is ten ways of drawing a
	# boss, picked by which of the ten it is, and $F163 is the sixth of them:
	# only while $55 stands in the fifteenth place is the byte read at all.
	# Everywhere else it is an ordinary field of whatever place happens to be
	# fifteenth, and taking it back there would be wiping a thing's own ground.
	#
	# It is done here, at the head of the frame, because that is where the
	# cartridge does it: the byte is written during a thing's turn and the
	# taking back is stamped with the frame after.  A step of the game can run
	# over two frames of the console, so whether the byte still stands at the
	# end of the step it was written in is a question of which frame it fell
	# in, and only doing it a frame at a time gets that right.
	var noisy: PackedByteArray = slots[NOISE_SLOT]
	if noisy[F_TYPE] == 0x55 and noisy[F_GROUND] == 0x01:   # $F172
		noisy[F_GROUND] = 0x00
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
			# Whose turn it is, for as long as it lasts: a thing asks the
			# driver for a noise from inside its own mind, and the cartridge
			# knows which thing asked because the turn runs with the place in
			# X.  Nothing else in the engine reads it.
			Pb2Sound.at_slot = n
			call(mind, n, s)
			Pb2Sound.at_slot = -1
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


## $CED2 -- the water and the lava that rise, at the head of the level's frame
## and before anything else in it.
##
## Four little routines, one for each sort of area that has such water, and all
## four behind the same two gates: the level must be being played ($27 is
## three) and the area's own wait must have run out ($5E, the same count the
## view holds still for).  The view is handed over because that count is its
## own and it counts it down again itself a moment later ($D93A), so keeping a
## second copy here would count it twice.
func water_turn(view) -> void:
	if live != 5 or playing != 3:                      # $CDCE, $CED2
		return
	if view.wait != 0:                                 # $CED8
		view.wait -= 1
		if view.wait != 0:
			return
	_water_up_down(view)                               # $D13B
	_water_swing()                                     # $D1CD
	_water_lava()                                      # $D1AD
	_water_climb(view)                                 # $D18D


## $D13B -- kind four: the piece of the level that is turned about.  The line
## and the screen's own drawing point move against each other a step every
## fourth picture, and each turns the water round at its own end: the drawing
## point counts backwards from $EF to $E1 going up and forwards from nought to
## $38 coming down.
func _water_up_down(_view) -> void:
	if lvl.kind != 0x04 or (frame & 0x03) != 0:
		return
	# The drawing point is the screen's own and the harness may not have said
	# what it is; without it the line cannot be moved either, for the two turn
	# each other round.
	if draw < 0:
		return
	if flow != 0:
		water = (water + 1) & 0xFF
		draw = (draw - 1) & 0xFF
		if draw == 0xFF:                               # $D151
			draw = 0xEF
		elif draw == 0xE1:                             # $D157
			flow = 0
	else:
		water = (water - 1) & 0xFF
		draw = (draw + 1) & 0xFF
		if draw == 0xF0:                               # $D177
			draw = 0x00
		elif draw == 0x38:                             # $D17D
			flow = 1


## $D18D -- kind eight: the water climbs to $44 and stops there.  It waits for
## the view to let go of the level ($21), which in ordinary play it never
## does, so in ordinary play this water stands still.
func _water_climb(view) -> void:
	if lvl.kind != 0x08 or view.grip != 0 or water == 0x44:
		return
	flow = 1
	water = (water + 1) & 0xFF


## $D1AD -- kind ten: the lava sinks a line every sixty-fourth picture until it
## reaches $40, and then stops for good.
func _water_lava() -> void:
	if lvl.kind != 0x0A or water == 0x40 or (frame & 0x3F) != 0:
		return
	water = (water - 1) & 0xFF


## $D1CD -- kinds six and nine: the water swings between $3F and $8F for ever,
## kind six every fourth picture and kind nine every eighth.
func _water_swing() -> void:
	var mask: int
	if lvl.kind == 0x06:
		# $D1D8 -- kind six is heard, one picture in sixteen ($1C AND $17
		# covers four bits, not five).  Kind nine jumps past the asking at
		# $D1D5 and swings in silence.
		if (frame & 0x17) == 0:
			Pb2Sound.want(0x25)                        # $D1E0
		mask = 0x03
	elif lvl.kind == 0x09:
		mask = 0x07
	else:
		return
	if (frame & mask) != 0:
		return
	if flow != 0:
		water = (water - 1) & 0xFF
		if water == 0x3F:                              # $D201
			flow = 0
	else:
		water = (water + 1) & 0xFF
		if water == 0x8F:                              # $D232
			flow = 1


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
	if lvl is SolAsPb2:
		# PB2 clamps its ordinary playfield to $10..$AF. Solbrain uses the
		# full moving viewport, so that clamp tests a different world cell.
		return lvl.class_byte(cam + (sx - 65536 if sx >= 32768 else sx),
				(sy - 65536 if sy >= 32768 else sy) - VIEW_TOP)
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
	if lvl.kind == 10:
		# $F3E3 -- the strip between the line the water has climbed to and the
		# hundred and fifty second answers as one row, $9C, whatever row was
		# really asked: the rising water carries its own floor with it.
		if off:
			return _ground_far(xhi, xlo, yhi, ylo)
		if ylo < 0x98 and ylo >= water:
			return _ground_near(xlo, 0x9C)
	elif lvl.kind == 4:
		# $F40D -- the area with the turned-about piece.  Below the line the
		# water has climbed to and above the hundred and twenty eighth row
		# there is nothing at all; everything above the line is asked with the
		# row moved down by $80 - $29.
		if off:
			return _ground_far(xhi, xlo, yhi, ylo)
		if ylo < 0x80:
			if ylo >= water:
				return 0x00
			return _ground_near(xlo, (ylo - water + 0x80) & 0xFF)
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
##
## The console does the sum in bytes and mends the page boundary once, and a
## point above the top of the level is not mended at all: $F493 takes sixteen
## off a line that has run past two hundred and forty without taking one off
## the page, so the question comes back round to the foot of the page it
## started on.  Reckoning the lines as a whole number instead would answer for
## a line above the level, where there is nothing, and the cartridge answers
## for the foot of the page, where there may well be a wall.
func _line(hi: int, lo: int) -> int:
	var cam_hi: int = (cam >> 8) & 0xFF
	var cam_lo: int = cam & 0xFF
	var line: int = cam_lo + lo                        # $F44B
	var carry: int = 1 if line > 0xFF else 0
	line &= 0xFF
	var page: int = (cam_hi + hi + carry) & 0xFF       # $F451
	# $F455 -- the high byte as it was before the sum says which way to go.
	if hi < 0x80:
		var step: int = (((page - cam_hi) & 0xFF) << 4) & 0xFF  # $F45B
		line += step
		page = (page + (1 if line > 0xFF else 0)) & 0xFF
		line &= 0xFF
		if line >= 0xF0:                               # $F46F
			line &= 0x0F
			page = (page + 1) & 0xFF
	else:
		var step2: int = (((cam_hi - page) & 0xFF) << 4) & 0xFF  # $F479
		line -= step2
		page = (page - (1 if line < 0 else 0)) & 0xFF
		line &= 0xFF
		if line >= 0xF0:                               # $F48F
			line &= 0xEF
	return (page << 8) | line


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


## $FD98 ($C9BD) -- eight along the way the level runs, if bit six of what is
## handed in is set.  Only the wall gun uses it, to sit the near half of a
## pair eight points off the far half.
func shift_eight(s: PackedByteArray, what: int) -> void:
	if (what & 0x40) == 0:
		return
	if lvl.vertical:                                   # $97
		nudge_down(s, 0x00, 0x08)                      # $FA53
	else:
		nudge_side(s, 0x00, 0x08)                      # $FA73


## $FF00 ($C9C6) -- count down $05FA and, when it runs out, load it again with
## `every` and write down the angle from here to him.  `off` moves the point
## aimed at along the screen; if it would carry off the byte the cartridge
## drops it and aims at him plainly.
##
## Тем же ходом ствол поворачивается: на два к записанному углу, а с
## расстояния в четыре и ближе -- прямо на него ($FF37).  Угол пишется редко,
## поворот идёт каждый кадр.
func aim_clock(s: PackedByteArray, every: int, off: int) -> void:
	s[F_KEEP] = (s[F_KEEP] - 1) & 0xFF
	if s[F_KEEP] == 0:
		s[F_KEEP] = every
		var tx: int = slots[0][F_X] + _signed(off)     # $FF11
		if tx < 0 or tx > 0xFF:                        # $FF1B
			tx = slots[0][F_X]
		s[F_COUNT] = _atan(s[F_X], s[F_Y], tx, slots[0][F_Y])
	aim_turn(s)


## $FF37 ($C9C9) -- the second half of $FF00 on its own: bring the angle it
## holds two points nearer the one it wants, and take the last small step
## whole.
func aim_turn(s: PackedByteArray) -> void:
	var d: int = (s[F_COUNT] - s[F_SELF]) & 0xFF
	if d == 0:
		return
	if ((d + 0x04) & 0xFF) < 0x09:                     # $FF44
		s[F_SELF] = s[F_COUNT]
		return
	if d >= 0x80:                                      # $FF49
		s[F_SELF] = (s[F_SELF] - 2) & 0xFF
	else:
		s[F_SELF] = (s[F_SELF] + 2) & 0xFF


## $FF62 ($C9CC) -> $F690 -- the angle from this thing to him, weighing both
## bytes of each place and not only the low one.  His own high bytes are taken
## as nought, which is what $FF80 puts there.
##
## $F690 does not hand the difference over as a signed number: it halves the
## whole of it and lays it in whichever of the two places makes the sign come
## out right for $F6E2, leaving the other at nought.
func aim_at_hero_wide(s: PackedByteArray) -> int:
	var a: Array = _halve16(s[F_XHI], s[F_X], 0x00, slots[0][F_X])
	var b: Array = _halve16(s[F_YHI], s[F_Y], 0x00, slots[0][F_Y])
	return _atan(a[0], b[0], a[1], b[1])


func _halve16(hi0: int, lo0: int, hi1: int, lo1: int) -> Array:
	var d: int = (((hi0 << 8) | lo0) - ((hi1 << 8) | lo1)) & 0xFFFF
	if d < 0x8000:                                     # $F69A
		return [(d >> 1) & 0xFF, 0x00]
	return [0x00, (((0x10000 - d) & 0xFFFF) >> 1) & 0xFF]


## $FD5F ($C993) -- look the way it moves.
func face_by_speed(s: PackedByteArray) -> void:
	if s[F_VX] >= 0x80:
		s[F_BITS] = s[F_BITS] & 0xBF                   # $FD6D
	else:
		s[F_BITS] = s[F_BITS] | 0x40                   # $FD64


## $FC3C ($C942) -- a free place, the level's own eight ($CB0B) asked before
## the eight a thing may bear ($CB1B).  Nothing is written into it here.
func free_slot_wide() -> int:
	for k in range(FIRST_PLACED, SLOTS):               # $CB0B
		if slots[k][F_TYPE] == 0:
			return k
	for k in range(FIRST_LIVE, FIRST_PLACED):          # $CB1B
		if slots[k][F_TYPE] == 0:
			return k
	return -1


## $FB73 ($C8EB) -- step, unless the place it stands in is solid, and then go.
func ground_or_die(n: int, s: PackedByteArray) -> void:
	if ground_turn_clear(n, s, 0x00, 0x00) >= 0x80:
		clear(n)                                       # $D6D4
		return
	step_both(s)                                       # $FA08


## $FD41 ($C98D) -- is it looking his way, and how far off sideways is he?
## The answer is the pair; the first is true when the two agree.
func facing_hero(s: PackedByteArray) -> Array:
	var right: bool = s[F_X] < slots[0][F_X]           # $CADB
	var d: int = (s[F_X] - slots[0][F_X]) & 0xFF
	if right:
		d = (-d) & 0xFF
	var looks_right: bool = (s[F_BITS] & 0x40) != 0
	return [right == looks_right, d]


## $CADB ($C86D) and $CAF1 ($C870) -- how far he is, weighing only the low
## bytes of the two places.  A hero a whole screen off therefore reads as
## being close, which is what the cartridge does and so what is kept.
func apart_side(s: PackedByteArray) -> int:
	var d: int = (s[F_X] - slots[0][F_X]) & 0xFF
	return d if s[F_X] >= slots[0][F_X] else (-d) & 0xFF


func apart_down(s: PackedByteArray) -> int:
	var d: int = (s[F_Y] - slots[0][F_Y]) & 0xFF
	return d if s[F_Y] >= slots[0][F_Y] else (-d) & 0xFF


## $FC1F ($C960) -- повернуть назад там, где земля впереди кончилась.  Щуп
## вбок берётся по лицу, а спрашивается он только в свой ход: не в свой ход
## $FB92 отвечает "стена", и поворота не будет.
func ground_turn_edge(n: int, s: PackedByteArray, side: int,
		down: int) -> void:
	var a: int = side
	if (s[F_BITS] & 0x40) != 0:                        # $FC24
		a = (-a) & 0xFF
	if ground_turn_wall(n, s, a, down) < 0x80:         # $FB92
		turn_about(s)                                  # $F97D


## $F1EF -- шестнадцать на шестнадцать, со знаком: $01:$00 разделить на
## $03:$02, ответ в $05:$04.  Знак берётся только со старшего байта делимого,
## а остаток живёт в шестнадцати битах -- верхний бит при сдвиге теряется,
## как на плате.
static func divide16(num: int, den: int) -> int:
	var neg: bool = (num & 0x8000) != 0
	var n: int = (-num) & 0xFFFF if neg else num & 0xFFFF
	var rem := 0
	var q := 0
	for _k in range(16):                               # $F20F
		var bit: int = (n >> 15) & 1
		n = (n << 1) & 0xFFFF
		rem = ((rem << 1) | bit) & 0xFFFF
		var t: int = rem - den
		var c: bool = t >= 0
		if c:
			rem = t
		q = ((q << 1) | (1 if c else 0)) & 0xFFFF
	return (-q) & 0xFFFF if neg else q


## $FE62 ($C9CF) -- скорость, которой он дойдёт до героя за `frames` кадров,
## плюс подъём `lift` вниз (со знаком), чтобы вышла дуга.  Расстояние берётся
## в младших байтах и кладётся в старший байт делимого, так что ответ сам
## ложится в целое и дробное скорости.
func set_speed_reach(s: PackedByteArray, frames: int, lift: int) -> void:
	var dx: int = (slots[0][F_X] - s[F_X]) & 0xFF
	var q: int = divide16((dx << 8) & 0xFFFF, frames)
	s[F_VXFR] = q & 0xFF
	s[F_VX] = (q >> 8) & 0xFF
	var dy: int = (slots[0][F_Y] - s[F_Y]) & 0xFF
	q = divide16((dy << 8) & 0xFFFF, frames)
	s[F_VYFR] = q & 0xFF
	s[F_VY] = ((q >> 8) + lift) & 0xFF                 # $FEA3


## $B90D и $B91C -- вещь, на которую герой встаёт ($8E06/$8E09 через $F1A0,
## банк 9).  Первый ход кладёт коробку вещи в список твёрдых ($011F и
## $0120..$0150), спрашивает, с какой стороны герой в неё вошёл ($B867), и
## пишет ответ в $0164; второй по тому же ответу толкает героя ($063C и $0652
## героя) и запоминает, где вещь стояла ($0160:$0161).
## Ни один из двух не трогает полей самой вещи -- всё, что они пишут,
## принадлежит герою, а герой в проверке умов приходит из картриджа уже
## посчитанным.  Поэтому здесь от них нужен только порядок вызова; сама работа
## -- долг Э3.4, записан в docs/status_ver3.md.
## $BA44 (bank 9) -- the hero's own box.  Which of the eleven records ($BB04
## and after, four numbers with a sign in them: left, right, top, bottom) is
## his is decided by the lowest raised bit of his mark ($0416), and the poses
## $18 and $1A take records of their own beside it.  The records are laid out
## by that same count, as the pointer $BAEE names them.
var hero_boxes: Array = []
## $BAE6 -- and by the same count $011A: the pose times thirty-six.
var hero_blocks := PackedByteArray()
## $B98A -- six to a side, because the answer of the frame before picks one of
## six rows, and $B990 -- one hundred and eighty answers: five blocks of six
## rows of six, the block being $011A.
var ride_before := PackedByteArray()
var ride_action := PackedByteArray()


## $BA44..$BA52 -- счёт позы: сколько нулей снизу в метке героя, но не больше
## семи.
func _hero_pose() -> int:
	var m: int = slots[0][F_MARK]                      # $0416
	var y := 0
	var x := 7
	while true:                                        # $BA4B
		var bit: int = m & 1
		m >>= 1
		if bit != 0:
			break
		y += 1
		x -= 1
		if x == 0:
			break
	return y


## $BA8A..$BAE5 -- четыре края героя.  Край, что ушёл за свою страницу, либо
## прижимается к краю экрана, либо -- если ушёл не в ту сторону -- объявляет
## коробку негодной; у героя такого не бывает, и картридж её всё равно кладёт.
func _hero_solid() -> Array:
	var h: PackedByteArray = slots[0]
	var i: int = _hero_pose()
	if h[F_STATE] == 0x18:                             # $BA73
		i = 0x0A if (h[F_BITS] & 0x40) != 0 else 0x09
	elif h[F_STATE] == 0x1A:
		i = 0x08
	var r: Array = hero_boxes[i]
	var t: int = h[F_X] + r[0]                         # $BA96
	var left: int = t & 0xFF
	if ((0xFF + h[F_XHI] + (t >> 8)) & 0xFF) != 0:
		left = 0x00
	t = h[F_X] + r[1]                                  # $BAAA
	var right: int = t & 0xFF
	if ((h[F_XHI] + (t >> 8)) & 0xFF) != 0:
		right = 0xFF
	t = h[F_Y] + r[2]                                  # $BABE
	var top: int = t & 0xFF
	if ((0xFF + h[F_YHI] + (t >> 8)) & 0xFF) != 0:
		top = 0x00
	t = h[F_Y] + r[3]                                  # $BAD2
	var bottom: int = t & 0xFF
	if ((h[F_YHI] + (t >> 8)) & 0xFF) != 0:
		bottom = 0xFF
	return [left, right, top, bottom]


## $B793 -- коробка вещи.  Два числа, что передаёт ум, -- половина ширины и
## половина высоты, со знаком; правый край на них вперёд, левый на них назад и
## ещё на один (там `CLC; SBC`), низ по самому месту, верх на высоту вверх.
## Пустой ответ значит, что вещь целиком за краем.
func _thing_solid(s: PackedByteArray, side: int, down: int) -> Array:
	var t: int = s[F_X] + side                         # $B797
	var right: int = t & 0xFF
	var hi: int = (s[F_XHI] + (t >> 8)) & 0xFF
	if hi != 0:
		if hi >= 0x80:
			return []
		right = 0xFF
	t = s[F_X] - side - 1                              # $B7AA
	var left: int = t & 0xFF
	hi = (s[F_XHI] - (1 if t < 0 else 0)) & 0xFF
	if hi != 0:
		if hi < 0x80:
			return []
		left = 0x00
	var bottom: int = s[F_Y]                           # $B7BF
	if s[F_YHI] != 0:
		if s[F_YHI] >= 0x80:
			return []
		bottom = 0xFF
	t = s[F_Y] + down                                  # $B7CF
	var top: int = t & 0xFF
	hi = (s[F_YHI] + 0xFF + (t >> 8)) & 0xFF
	if hi != 0:
		if hi < 0x80:
			return []
		top = 0x00
	return [left, right, top, bottom]


## $BA52..$BA70 -- $011A: thirty-six to the pose.  The record $6C is the one
## he lies down in, and it only stays itself while his mark and his state
## agree about which way he is lying; anything else makes it $90.
func _hero_block() -> int:
	var b: int = hero_blocks[_hero_pose()]
	if b != 0x6C:
		return b
	var h: PackedByteArray = slots[0]
	var lying: bool = (h[F_BITS] & 0x40) != 0          # $042C
	if h[F_STATE] == 0x18:                             # $BA5C
		return 0x6C if lying else 0x90
	return 0x90 if lying else 0x6C                     # $BA69


## $BA44 ($8E00 through $BF18) -- the hero's box and his place in the table of
## answers.  $8009 asks for it at the head of the frame, before the count of
## solids is wiped and before any thing has had its turn, so every thing of
## the frame is measured against the one box.
func hero_look() -> void:
	hero_block = _hero_block()
	hero_box = _hero_solid()


## $B7EA -- the box goes on the end of the list of solids of this frame.
func _add_solid(b: Array) -> void:
	solids.append([b[0], b[1], b[2], b[3]])            # $0120..$0150


## $B808 -- pushed sideways, out of the side he came in by.
func _push_side() -> void:
	claimed = 1                                        # $0167
	if hero_box[1] == overlap[1]:                      # $011C == $09
		push_x = (overlap[0] - hero_box[1]) & 0xFF
	else:
		push_x = (overlap[1] - hero_box[0]) & 0xFF


## $B828 -- and the same up or down.
func _push_down() -> void:
	claimed = 1                                        # $0167
	if hero_box[3] == overlap[3]:                      # $011E == $0B
		push_y = (overlap[2] - hero_box[3]) & 0xFF
	else:
		push_y = (overlap[3] - hero_box[2]) & 0xFF


## $B848 -- carried both ways: he goes exactly as far as the thing has gone
## since it last looked.
func _carry_both(s: PackedByteArray) -> void:
	push_x = (s[F_X] - ridden[0]) & 0xFF               # $0160
	push_y = (s[F_Y] - ridden[1]) & 0xFF               # $0161
	claimed = 1


## $B867 -- с какой стороны герой вошёл в вещь.  Пересечение двух коробок:
## шире, чем выше, -- значит сверху или снизу; выше, чем шире, -- сбоку; а
## если герой целиком внутри, ответ пятый.
func _which_side(b: Array) -> int:
	var h: Array = hero_box
	if b[1] < h[0]:                                    # $B869
		return 0
	var ov_right: int = h[1] if b[1] >= h[1] else b[1]
	if h[1] < b[0]:                                    # $B878
		return 0
	var ov_left: int = b[0] if b[0] >= h[0] else h[0]
	if b[3] < h[2]:                                    # $B88B
		return 0
	var ov_bottom: int = h[3] if b[3] >= h[3] else b[3]
	if h[3] < b[2]:                                    # $B89C
		return 0
	var ov_top: int = b[2] if b[2] >= h[2] else h[2]
	# $08..$0B -- $B808 and $B828 read the overlap back out of them.
	overlap = [ov_left, ov_right, ov_top, ov_bottom]
	var tall: int = (ov_bottom - ov_top) & 0xFF        # $B8AF
	var wide: int = (ov_right - ov_left) & 0xFF
	if wide < tall:                                    # $B8DD
		if h[1] == ov_right:
			return 5 if h[0] == ov_left else 3
		return 5 if b[0] == ov_left else 4
	if h[3] == ov_bottom:                              # $B8BF
		return 5 if h[2] == ov_top else 1
	return 5 if b[2] == ov_top else 2


## $B90D ($8E06 через $F1A0, банк 9) -- вещь, на которую герой встаёт: коробка,
## сторона, ответ в $0164 и памятка, где вещь стояла ($B900).  Ум читает $0164
## сразу после этого хода, поэтому число возвращается и наружу.
func ride(s: PackedByteArray, side: int, down: int) -> int:
	var b: Array = _thing_solid(s, side, down)         # $B793
	held = 0 if b.is_empty() else _which_side(b)       # $B867, $B915
	ridden = [s[F_X], s[F_Y]]                          # $B900
	return held


## $B91C ($8E09 through $BF26) -- the answering turn.  The pose he is in
## ($011A), the side he was on when the thing last looked ($0164) and the side
## he is on now together name one of one hundred and eighty answers ($B990),
## and the answer is one of seven: leave him be, only declare the box solid,
## carry him both ways, push him up or down, push him sideways, or one of the
## two that do both.  Every answer but the first ends with the box on the list.
##
## Once something has taken hold of him this frame ($0167) nothing else may:
## the second thing only declares itself solid.
func ride_apply(s: PackedByteArray, side: int, down: int) -> void:
	var b: Array = _thing_solid(s, side, down)         # $B793
	if b.is_empty():                                   # $B91F
		return
	if not more_guests.is_empty():
		var dx: int = (int(s[F_X]) - int(ridden[0]) + 128) % 256 - 128
		var dy: int = (int(s[F_Y]) - int(ridden[1]) + 128) % 256 - 128
		guest_surfaces.append([b, dx, dy])
	if claimed != 0:                                   # $B921 -> $B987
		_add_solid(b)
		return
	var row: int = (hero_block + ride_before[held]) & 0xFF   # $B926
	var what: int = ride_action[(row + _which_side(b)) & 0xFF]
	match what:
		0:                                             # $B91B
			return
		2:                                             # $B984
			_carry_both(s)
		3:                                             # $B97E
			_push_down()
		4:                                             # $B978
			_push_side()
		5:                                             # $B968
			_push_down()
			push_x = (s[F_X] - ridden[0]) & 0xFF
		6:                                             # $B958
			_push_side()
			push_y = (s[F_Y] - ridden[1]) & 0xFF
	_add_solid(b)                                      # $B7EA


## $BDA3 -- three records of six numbers each, picked by the number the mind
## hands over.  In order: the feeler put out below while going down, the one
## put out above while going up, two more below for the two side questions,
## and the feeler put out sideways going right and going left.
const MOVER := [
	[0x10, 0xF0, 0x08, 0xF8, 0x0C, 0xF4],
	[0x04, 0xE0, 0xFC, 0xEC, 0x0C, 0xF4],
	[0x04, 0xE0, 0xF8, 0xE8, 0x0C, 0xF4],
	[0x04, 0xE0, 0xF8, 0xE8, 0x0C, 0xF4]]


## $BCBB (bank 11) -- the walk of everything that flies and stops dead against
## a wall.  What it has run into is kept in $0668: bit 0 the ceiling, bit 1 the
## floor, bit 6 a wall on the right, bit 7 a wall on the left.  While a bit is
## up and the thing is still pushing that way, it only asks the ground on its
## own frames ($BE3E), so the same wall is not paid for twice a frame.
func mover(n: int, s: PackedByteArray, which: int) -> void:
	var r: Array = MOVER[which]
	if (s[F_VY] | s[F_VYFR]) != 0:                     # $BCC5
		var go := true
		if (s[F_GROUND] & 0x01) != 0:                  # $BCDD
			if s[F_VY] < 0x80:
				s[F_GROUND] &= 0xFC                    # $BD91
			else:
				go = its_turn(n, clock)                # $BCE2
		elif (s[F_GROUND] & 0x02) != 0:                # $BCD6
			if s[F_VY] >= 0x80:
				s[F_GROUND] &= 0xFC
			else:
				go = its_turn(n, clock)
		if go:
			var down: int = r[0] if s[F_VY] < 0x80 else r[1]
			if walled_either_turn(n, s, 0x07, down, 0x00) >= 0x80:
				s[F_GROUND] &= 0xFC                    # $BD07
				s[F_GROUND] |= 0x01 if s[F_VY] >= 0x80 else 0x02
				s[F_VY] = 0x00
				s[F_VYFR] = 0x00
			else:
				step_down(s)                           # $C8F4
				s[F_GROUND] &= 0xFC
	if (s[F_VX] | s[F_VXFR]) == 0:                     # $BD23
		return
	var go2 := true
	if (s[F_GROUND] & 0x80) != 0:                      # $BD3B
		if s[F_VX] < 0x80:
			s[F_GROUND] &= 0x3F                        # $BD9A
		else:
			go2 = its_turn(n, clock)                   # $BD40
	elif (s[F_GROUND] & 0x40) != 0:                    # $BD34
		if s[F_VX] >= 0x80:
			s[F_GROUND] &= 0x3F
		else:
			go2 = its_turn(n, clock)
	if not go2:
		return
	var side: int = r[4] if s[F_VX] < 0x80 else r[5]   # $BD4A
	var hit: bool = ground_turn_clear(n, s, side, r[2]) >= 0x80
	if not hit:                                        # $BD62
		hit = ground_turn_clear(n, s, side, r[3]) >= 0x80
	if hit:
		s[F_GROUND] &= 0x3F                            # $BD74
		s[F_GROUND] |= 0x80 if s[F_VX] >= 0x80 else 0x40
		s[F_VX] = 0x00
		s[F_VXFR] = 0x00
		return
	step_side(s)                                       # $C8F7
	s[F_GROUND] &= 0x3F


# --- The minds ---------------------------------------------------------


## $8728 and $87B2 (bank 10) -- the two things a boss room holds.
##
## A boss room is an area of the seventh table, and there is one record in it
## and nothing else.  Type $05 stands in the six rooms in the middle of a
## stage and puts out the boss $50 + the room; type $06 stands in the four at
## the end and puts out $56 + the stage.  Past their first state the two are
## the same code, and both of them do the same three things: make the boss,
## wait for the hero to be drawn, and then fill the meter.
func _mind_05(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _call_05(s)
		1: _hold_boss(s)
		2: _fill_boss(n, s)


func _mind_06(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _call_06(s)
		1: _hold_boss(s)
		2: _fill_boss(n, s)


## $8731 -- the one in the middle of a stage, chosen by which room it is.
func _call_05(s: PackedByteArray) -> void:
	s[F_MARK] = 0x80                                   # $C9AB -> $FD86
	var i: int = area
	var b: PackedByteArray = slots[int(cfg_boss["slot"])]
	b[F_TYPE] = int(cfg_boss["mid_first"]) + i
	b[F_X] = int(cfg_boss["mid_x"][i])
	b[F_Y] = int(cfg_boss["mid_y"][i])
	b[F_KIND] = int(cfg_boss["mid_pic"][i])
	boss_bar = int(cfg_boss["mid_life"][i])
	boss_here = 1                                      # $4E
	s[F_STATE] += 1                                    # $C966


## $87BB -- the one at the end of a stage, chosen by which stage it is.  Only
## the place and the meter come out of a table; the picture is one number for
## all four of them.
func _call_06(s: PackedByteArray) -> void:
	s[F_MARK] = 0x80                                   # $C9AB -> $FD86
	var i: int = came                                  # $53
	var b: PackedByteArray = slots[int(cfg_boss["slot"])]
	b[F_KIND] = int(cfg_boss["end_pic"])
	b[F_TYPE] = int(cfg_boss["end_first"]) + i
	b[F_X] = int(cfg_boss["end_x"][i])
	b[F_Y] = int(cfg_boss["end_y"][i])
	boss_bar = int(cfg_boss["end_life"][i])
	boss_here = 1
	s[F_STATE] += 1


## $875D -- nothing happens until the hero has a picture of his own, which is
## to say until the level has finished opening and he is being drawn.
func _hold_boss(s: PackedByteArray) -> void:
	if slots[0][F_KIND] == 0:
		return
	playing = 4                                        # $27 -- out of play
	s[F_STATE] += 1


## $876A -- the meter, four every four pictures, with a sound each time; when
## it is full the boss has the health it shows and the game is played again.
func _fill_boss(n: int, s: PackedByteArray) -> void:
	if (frame & (int(cfg_boss["bar_every"]) - 1)) != 0:
		return
	Pb2Sound.want(0x23)                                # $8772 -- the meter
	var b: PackedByteArray = slots[int(cfg_boss["slot"])]
	b[F_LIFE] = (b[F_LIFE] + int(cfg_boss["bar_step"])) & 0xFF
	if b[F_LIFE] != boss_bar:
		return
	playing = 3                                        # $27 -- played again
	boss_here = 0
	boss_bar = 0
	boss_step = 0                                      # $5F
	clear(n)                                           # $C810 -> $D6D4


## $BDE9 and $BDBD (bank 11) -- the shell all ten bosses wear.
##
## The six in the middle of a stage keep three states of their own and the
## four at the end keep six; past those the states are the same for all ten,
## and they are the death.  A boss's own mind is not a state at all: it is
## reached through the last of the states the shell keeps, and it drives
## itself on a step of its own ($05CE) from there on.
func _mind_boss(n: int, s: PackedByteArray) -> void:
	var own: int = int(cfg_boss["mid_states"]) if s[F_TYPE] < int(
			cfg_boss["end_first"]) else int(cfg_boss["end_states"])
	var st: int = s[F_STATE]
	if st >= own:
		match st - own:
			0: _die_shake_start(s)
			1: _die_shake(s)
			2: _die_rest(s)
			3: _die_life(n, s)
			4: _die_energy(s)
			5: _die_done(n, s)
		return
	if s[F_TYPE] >= int(cfg_boss["end_first"]):
		# $BDBD -- the four at the end are let go at once and keep their own
		# six states; the shell only clears the step their box is read by.
		boss_step = 0
		bosses.turn(self, n, s)
		return
	# $BDFE and $BE0F -- the six in the middle stand still for a while first.
	match st:
		0:
			if playing != 3:
				return
			s[F_MARK] = 0x01                           # $C99F -> $FD76
			s[F_COUNT] = int(cfg_boss["wake_wait"])
			s[F_STATE] += 1
		1:
			if playing != 3:
				return
			s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
			if s[F_COUNT] == 0:
				s[F_STATE] += 1
		2:
			boss_step = 0                              # $BE1B
			bosses.turn(self, n, s)


## $87F7 -- the death begins.  The meter goes back up, the picture starts on
## the burst, and the thing is shaken through seven places.
func _die_shake_start(s: PackedByteArray) -> void:
	boss_here = 1                                      # $4E
	start_anim(s, 0x01)                                # $C83A
	s[F_COUNT] = int(cfg_boss["die_shake"])
	s[F_KEEP] = 0
	s[F_STATE] += 1


## $882D -- one shake every so many pictures, seven of them, and then on.
func _die_shake(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		step_anim(s)                                   # $C837
		return
	s[F_COUNT] = int(cfg_boss["die_shake"])
	start_anim(s, 0x01)
	var off: Array = cfg_boss["shake"][s[F_KEEP]]
	var x: int = (((s[F_XHI] << 8) | s[F_X]) + int(off[0])) & 0xFFFF
	s[F_X] = x & 0xFF
	s[F_XHI] = x >> 8
	var y: int = (((s[F_YHI] << 8) | s[F_Y]) + int(off[1])) & 0xFFFF
	s[F_Y] = y & 0xFF
	s[F_YHI] = y >> 8
	s[F_KEEP] += 1
	if s[F_KEEP] == cfg_boss["shake"].size():
		s[F_KEEP] = 0
		s[F_STATE] += 1


## $8871 -- the burst is over: the hero stops blinking, his health is given
## back, and the boss is not drawn any more.
func _die_rest(s: PackedByteArray) -> void:
	slots[0][F_BITS] &= 0x7F
	if status != null:
		status.refill_life = int(cfg_boss["refill_life"])   # $2F
	playing = 5                                        # $27 -- health back
	s[F_KIND] = 0
	s[F_KEEP] = int(cfg_boss["after_wait"])
	s[F_STATE] += 1


## $8895 -- wait out the health, then either the suit's energy (the last
## stage) or an extra life (every other).
func _die_life(n: int, s: PackedByteArray) -> void:
	if playing == 5:
		return
	playing = 4
	s[F_KEEP] = (s[F_KEEP] - 1) & 0xFF
	if s[F_KEEP] != 0:
		return
	# $88A5 -- the last boss of all is the only one whose own noise is still
	# going when the health comes back, and it is the only one hushed here.
	if s[F_TYPE] == 0x55:
		Pb2Sound.hush()                                # $88AC
	if lvl.stage == 5:
		if status != null:
			status.refill_energy = int(cfg_boss["refill_energy"])   # $30
		playing = 6
		s[F_KEEP] = int(cfg_boss["after_wait"])
		s[F_STATE] += 1
		return
	Pb2Sound.hush()                                    # $88B5
	Pb2Sound.want(0x10)                                # $88BA -- one life more
	if status != null:
		status.lives = (status.lives + 1) & 0xFF       # $9F
	s[F_STATE] += 2


## $88D8 -- and the same wait again after the energy.
func _die_energy(s: PackedByteArray) -> void:
	if playing == 6:
		return
	playing = 4
	s[F_KEEP] = (s[F_KEEP] - 1) & 0xFF
	if s[F_KEEP] != 0:
		return
	s[F_STATE] += 1


## $88EB -- the room is over.  What the cartridge does next is the whole game's
## business ($18, $19, $1A) and belongs to the level's own flow; what the
## table knows is that this area is finished and the stage goes on.
func _die_done(n: int, s: PackedByteArray) -> void:
	playing = 3
	boss = 0                                           # $79
	phase = 0                                          # $AD
	boss_here = 0
	beat = true                                        # $88F0 follows $88EB
	live = 6                                           # $1A -- build again
	clear(n)


## $8A5D (bank 10) -- the block that can be knocked out of the background.
##
## It is not drawn and it is not solid: the wall the player sees and stands on
## is the level's own map, and this is a hitbox sitting on one sixteen by
## sixteen cell of it.  One hit and the cell is gone ($8AF0), a puff of smoke
## is shown, and the bit it was given is set in `broken` so that the same cell
## is not put back when the view brings it round again.
##
## Six states: nought arms it, one is the wait, two is the destruction, three
## the puff, and four and five are what happens after the view has carried it
## off the screen and back.
func _mind_0c(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _arm_0c(s)
		1: pass                                        # $8A96
		2: _smash_0c(s)
		3: _puff_0c(s)
		4: _again_0c(n, s)
		5: _park_0c(s)


## $CF1C, but only the blocks -- for the stand that judges what he throws.
## There the whole table is told from the cartridge and nothing has a mind of
## its own, yet a block knocked out of the wall opens the cell it sat on, and
## a throw flies through the hole afterwards.  The block's own state is the
## cartridge's; giving it its turn opens the cell on the very step the
## cartridge opened it, and nothing else in the table is touched.
func blocks_turn() -> void:
	for n in range(FIRST_LIVE, SLOTS):
		if slots[n][F_TYPE] == 0x0C:
			_mind_0c(n, slots[n])


## $8A6C -- it is hittable, it stands at the middle of its cell rather than at
## its left edge, and a cell already broken this visit is never armed at all.
func _arm_0c(s: PackedByteArray) -> void:
	s[F_MARK] = 0x01                                   # $C99F -> $FD76
	var x: int = (((s[F_XHI] << 8) | s[F_X]) + 8) & 0xFFFF
	s[F_X] = x & 0xFF
	s[F_XHI] = x >> 8
	if (broken & (1 << (s[F_LIFE] & 0x07))) == 0:
		s[F_STATE] += 1                                # $C966
		return
	s[F_STATE] = 0x04
	s[F_MARK] = 0x80                                   # $C9AB -> $FD86


## $8A97 -- the destruction.
func _smash_0c(s: PackedByteArray) -> void:
	broken ^= 1 << (s[F_LIFE] & 0x07)                  # $3B
	start_anim(s, 0x01)                                # $C83A
	_open_cell(s)                                      # $8AF0
	s[F_SELF] = 0x10
	Pb2Sound.want(0x24)                                # $8AB1 -- it breaks
	s[F_STATE] += 1


## $8AB7 -- the smoke, for as long as the count lasts.
func _puff_0c(s: PackedByteArray) -> void:
	step_anim(s)                                       # $C837
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] != 0:
		return
	s[F_STATE] = 0x05
	s[F_KIND] = 0x00


## $8ACA -- the view has brought it back, so the cell is opened again.  Down a
## level it waits until the cell is on the screen and then goes on waiting;
## along one there is nothing to wait for and the place is given up.
func _again_0c(n: int, s: PackedByteArray) -> void:
	if not lvl.vertical:
		_open_cell(s)
		clear(n)                                       # $C810
		return
	if s[F_Y] >= 0xB8:
		return
	_open_cell(s)
	s[F_STATE] += 1


## $8AE2 -- off the foot of the screen, and it is ready to be opened again.
func _park_0c(s: PackedByteArray) -> void:
	if s[F_Y] >= 0xB8:
		s[F_STATE] = 0x04


## $8AF0 -- the cell itself: its left edge is eight to the left of where the
## thing stands, and its top is where the thing stands.
func _open_cell(s: PackedByteArray) -> void:
	var sx: int = (s[F_X] - 8) & 0xFF
	if lvl.vertical:
		lvl.break_cell(sx, Pb2Level.map_row(_drawn_view(), s[F_Y]))
	else:
		lvl.break_cell(cam + sx, s[F_Y] - VIEW_TOP)



## $826C -- a defeated enemy animates, then disappears or becomes a pickup.
## The cartridge shares $8279/$82A8 with the crawling projectile.
func _mind_01(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _start_crawl(s)
		1: _crawl_step(s)
		2: _drop_01(n, s)
		3:
			s[F_SELF] = int(death_cfg["lifetime"])
			set_speed_down(s, 0, 0)
			s[F_COUNT] = 0
			s[F_GROUND] = 0
			if ground(s, 0, int(death_cfg["head_probe"])) >= 0x80:
				s[F_COUNT] += 1
			s[F_STATE] += 1
		4:
			s[F_SELF] = (s[F_SELF] - 1) & 0xFF
			if s[F_SELF] == 0:
				clear(n)
				return
			var falling := false
			if s[F_COUNT] != 0:
				if ground_turn_wall(n, s, 0, int(death_cfg["head_probe"])) >= 0x80:
					falling = true
				else:
					s[F_COUNT] -= 1
					falling = s[F_COUNT] == 0
			if not falling:
				ground_stand(s)
				if s[F_GROUND] != 0:
					return
			add_speed_down(s, int(death_cfg["gravity"]))
			if s[F_VY] == int(death_cfg["fall_limit"]):
				set_speed_down(s, int(death_cfg["fall_speed"]), 0)
			step_down(s)


## $82F3 / $833A -- deterministic loot sequence and duplicate upgrade gates.
func _drop_01(n: int, s: PackedByteArray) -> void:
	if s[F_KEEP] != 0:
		clear(n)
		return
	var choice: int = int(death_cfg["drop_table"][drop_clock >> 1])
	var low: bool = (drop_clock & 1) != 0
	drop_clock = (drop_clock + 1) & int(death_cfg["drop_mask"])
	choice = (choice if low else choice >> 4) & 15
	if choice == 0:
		clear(n)
		return
	var pic: int = int(death_cfg["drop_pic"][choice])
	if (pic == 6 and extra == int(death_cfg["max_extra"])) \
			or (pic == 12 and second == int(death_cfg["max_second"])) \
			or (pic == 5 and power == int(death_cfg["max_power"])):
		clear(n)
		return
	s[F_KIND] = pic
	s[F_LIFE] = int(death_cfg["drop_item"][choice])
	s[F_MARK] = 0x40
	s[F_STATE] += 1


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


## $9C68 -- straight enemy bullet: move until the native terrain test clears it.
func _mind_16(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_MARK] = int(small_shot_cfg["bullet_mark"])
		s[F_KIND] = int(small_shot_cfg["bullet_pic"])
		s[F_STATE] += 1
		return
	mark_target(n)
	ground_or_die(n, s)


## $A893 -- aimed turret bullet; the first few ticks leave its muzzle.
func _mind_2a(n: int, s: PackedByteArray) -> void:
	if s[F_SELF] != 0:
		s[F_SELF] -= 1
		if s[F_SELF] != 0:
			mark_target(n)
			step_both(s)
			return
		s[F_MARK] = int(small_shot_cfg["bullet_mark"])
		s[F_KIND] = int(small_shot_cfg["aimed_pic"])
	if ground_turn_clear(n, s, 0, 0) >= 0x80:
		clear(n)
		return
	mark_target(n)
	step_both(s)


## $9D79 -- stationary trail left by $17; expires or disappears with its parent.
func _mind_18(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_LIFE] = int(small_shot_cfg["trail_life"])
		s[F_MARK] = int(small_shot_cfg["trail_mark"])
		start_anim(s, int(small_shot_cfg["trail_anim"]))
		s[F_COUNT] = int(small_shot_cfg["trail_ticks"])
		s[F_STATE] += 1
		return
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] == 0 or slots[s[F_SELF]][F_TYPE] != int(small_shot_cfg["trail_parent"]):
		clear(n)
		return
	mark_target(n)
	step_anim(s)


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
	# The cartridge weighs the two bytes apart, and the high one first: $ACEB
	# splits on its sign, and only then is the low one asked whether it has
	# passed the half.  A whole screen and a half is the plain reading of it,
	# but the two halves are never put back together, so a high byte of two or
	# more is judged on its low byte alone.  That is kept as it stands.
	if hi < 0x80:                                      # $ACEB
		if hi == 0x01 or lo >= 0x80:                   # $ACED, $ACF1
			return going_back                          # $ACF5
		return false
	if hi == 0xFE or lo < 0x80:                        # $ACFC, $AD00
		return not going_back                          # $AD04
	return false


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


## $FC45 ($C963) -- write one place's record over another's.  Every field but
## the record's own number: twenty-eight in all, the cached place among them,
## so the copy is rebased by the view exactly as the original is.
func copy_row(dst: int, src: PackedByteArray) -> void:
	var d: PackedByteArray = slots[dst]
	for f in range(0, 29):
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
		# $F762 -- four rolls, and they go through the carry, which the CMP a
		# moment ago left up.  What lands in the bottom two places is the pair
		# of signs, bits five and six; a plain roll of the byte alone would
		# bring down four and five instead and answer the wrong corner.
		return quarter[(bits >> 5) & 0x03]
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
	ride(s, 0x07, 0xDE)                                # $A654
	match s[F_STATE]:
		0: _wake_1e(n, s)
		1: _wait_1e(s)
		2: _open_1e(s)
		3: _shut_1e(s)
	ride_apply(s, 0x07, 0xDE)                          # $A65E


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


## $A71F -- the hatch's walking child: cross floor, fall off edges, burst at a wall.
func _mind_1f(n: int, s: PackedByteArray) -> void:
	var c := hatchling_cfg
	match s[F_STATE]:
		0:
			s[F_LIFE] = int(c.life)
			s[F_MARK] = int(small_shot_cfg.trail_mark)
			start_anim(s, int(c.anim))
			face_by_speed(s)
			set_speed_side_facing(s, int(c.speed[1]), int(c.speed[0]))
			if walled_ahead(s, int(c.spawn_wall[0]), int(c.spawn_wall[1]), int(c.spawn_wall[2])) >= 0x80:
				turn_about(s)
			s[F_STATE] += 1
			return
		1, 2:
			# $9BC7: floating on the water line counts as support.
			var wet := in_water(s)
			if wet:
				s[F_Y] = water
			if s[F_STATE] == 1:
				if not wet and walled_either_turn(n, s, int(c.floor_probe[0]), int(c.floor_probe[1]), 0x80) < 0x80:
					set_speed_down(s, 0, 0)
					s[F_STATE] += 1
			else:
				if wet or walled_either_turn(n, s, int(c.floor_probe[0]), int(c.floor_probe[1]), 0) >= 0x80:
					if not wet:
						snap_down(s)
					s[F_STATE] -= 1
				else:
					add_speed_down(s, int(c.gravity))
					if s[F_VY] == int(c.fall_limit):
						set_speed_down(s, int(c.fall_limit), 0)
					step_down(s)
			step_anim(s)
			if walled_ahead_turn(n, s, int(c.walk_wall[0]), int(c.walk_wall[1]), int(c.walk_wall[2]), 0) < 0x80:
				step_side(s)
			else:
				s[F_COUNT] = int(c.burst_ticks)
				start_anim(s, int(c.burst_anim))
				s[F_STATE] = 3
		3:
			s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
			if s[F_COUNT] == 0:
				clear(n)
			else:
				step_anim(s)


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


## $A8B4 (банк 11) -- двойня.  Дождавшись героя ближе тридцати двух шагов
## вдоль, вещь снимает с себя точную копию в список уровня, копию
## разворачивает, и дальше обе идут одним и тем же путём в разные стороны:
## отступить вбок, упасть, поехать вбок, всплыть и погаснуть.
func _mind_2b(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _split_2b(n, s)
		1: _step_off_2b(s)
		2: _sink_2b(s)
		4: _slide_2b(s)
		6: _last_2b(n, s)
		_: _pause_2b(s)


## $A8C5 -- ждать и раздвоиться.  Свободного места в списке уровня нет --
## считает до сорока и пропадает.
func _split_2b(n: int, s: PackedByteArray) -> void:
	if s[F_COUNT] == 0:
		var sd: Array = hero_side(s)                   # $C93C
		if sd[2] or sd[0] >= 0x20:
			return
		s[F_COUNT] = (s[F_COUNT] + 1) & 0xFF
	for k in range(FIRST_PLACED, SLOTS):               # $C86A
		if slots[k][F_TYPE] != 0:
			continue
		copy_row(k, s)                                 # $C963
		var c: PackedByteArray = slots[k]
		turn_about(c)                                  # $C91B
		c[F_STATE] = (c[F_STATE] + 1) & 0xFF
		slots[k] = c
		s[F_STATE] += 1                                # $C966
		return
	s[F_SELF] = (s[F_SELF] + 1) & 0xFF
	if s[F_SELF] == 0x40:
		clear(n)                                       # $C810


## $A8FD -- отступить вбок и приготовиться падать.
func _step_off_2b(s: PackedByteArray) -> void:
	nudge_side(s, 0x00, 0x50 if (s[F_BITS] & 0x40) != 0 else 0xB0)
	s[F_LIFE] = 0xFF                                   # $BE5A
	s[F_MARK] = 0x01
	s[F_KIND] = 0x70                                   # $BE6E
	set_speed_down(s, 0xFF, 0x00)                      # $BEB9
	s[F_SELF] = 0x30
	s[F_COUNT] = 0x30
	s[F_STATE] += 1                                    # $C966


## $A921 -- сорок восемь кадров вверх, потом разворот вбок.
func _sink_2b(s: PackedByteArray) -> void:
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] != 0:
		step_down(s)                                   # $C8F4
		return
	set_speed_side_facing(s, 0x01, 0x80)               # $BEC5
	s[F_KEEP] = 0x35                                   # $BE83
	s[F_SELF] = 0x30                                   # $BE75
	s[F_STATE] += 1                                    # $C966


## $A939 -- пережидание между ходами; оно же и третье, и пятое состояние.
func _pause_2b(s: PackedByteArray) -> void:
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] == 0:
		s[F_STATE] += 1                                # $C966


## $A93F -- пятьдесят три кадра вбок, потом обратно вниз.
func _slide_2b(s: PackedByteArray) -> void:
	s[F_KEEP] = (s[F_KEEP] - 1) & 0xFF
	if s[F_KEEP] != 0:
		step_side(s)                                   # $C8F7
		return
	flip_speed_down(s)                                 # $C921
	s[F_SELF] = 0x30
	s[F_STATE] += 1                                    # $C966


## $A951 -- последний путь: сорок восемь кадров и конец.
func _last_2b(n: int, s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] == 0:
		clear(n)                                       # $C810
		return
	step_down(s)                                       # $C8F4


## $9FDE и $9FB8 (банк 10) -- два челнока.  Один ходит вниз и вверх, другой
## вбок; всё, что их отличает, -- какую скорость они заводят, каким шагом
## идут и какую скорость переворачивают, когда счёт вышел.
##
## Оба зовут ещё $A053 и $A05A -- а те через $BF20/$BF26 и $C8CD уходят в
## банки 8/9, к складу лишних картинок ($B90D, $B91C).  Читают они оттуда
## только место вещи, а пишут в $08..$11, $0160, $0161 и $0164 -- ни одного
## поля вещи, так что приёмке до них дела нет.
const COUNT_07 := [0x70, 0x62, 0x40, 0xE0, 0xB0, 0x60, 0x50, 0xC0, 0x60,
		0xA4, 0x80, 0x70, 0x62, 0x40, 0xE0, 0xB0, 0x60, 0x50, 0xC0, 0xC0,
		0xA4, 0xA0, 0x00, 0x00]
const KEEP_07 := [0x70, 0x62, 0x40, 0xE0, 0xB0, 0x60, 0x50, 0xC0, 0xC0,
		0xA4, 0xA0, 0x00, 0x00, 0x80, 0x80, 0x01, 0xFF, 0x00, 0xFF, 0xA9,
		0x0F, 0xA0, 0xF1, 0x4C]
const FRAC_07 := [0x00, 0x00, 0x80, 0x80]
const WHOLE_07 := [0x01, 0xFF, 0x00, 0xFF]


## $A004 (банк 11) -- просыпание, общее на обоих.  Верхние шесть бит жизни
## выбирают, сколько идти в одну сторону, нижние два -- как быстро.
func _wake_07(s: PackedByteArray) -> Array:
	s[F_MARK] = 0x80                                   # $C9AB
	if lvl.vertical:                                   # $97
		nudge_down(s, 0x00, 0xFF)                      # $C930
	var i: int = s[F_LIFE] >> 2
	s[F_COUNT] = COUNT_07[i]
	s[F_KEEP] = KEEP_07[i]
	var j: int = s[F_LIFE] & 0x03
	s[F_STATE] += 1                                    # $C966
	return [WHOLE_07[j], FRAC_07[j]]


## $9FDE -- челнок вниз и вверх.
func _mind_07(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_KIND] = 0x0D                               # $BE6E
		var sp: Array = _wake_07(s)                    # $A004
		set_speed_down(s, sp[0], sp[1])                # $C909
		return
	ride(s, 0x0F, 0xF1)                                # $A053
	step_down(s)                                       # $C8F4
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] == 0:
		s[F_COUNT] = s[F_KEEP]
		flip_speed_down(s)                             # $C921
	ride_apply(s, 0x0F, 0xF1)                          # $A05A


## $9FB8 -- челнок вбок.
func _mind_08(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_KIND] = 0x0D                               # $BE6E
		var sp: Array = _wake_07(s)                    # $A004
		set_speed_side(s, sp[0], sp[1])                # $C906
		return
	ride(s, 0x0F, 0xF1)                                # $A053
	step_side(s)                                       # $C8F7
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] == 0:
		s[F_COUNT] = s[F_KEEP]
		flip_speed_side(s)                             # $C91E
	ride_apply(s, 0x0F, 0xF1)                          # $A05A


## $9780 (банк 10) -- ползун по стенам.  У него двенадцать положений
## ($05CE): по три на каждую из четырёх сторон, за которую он держится.  Он
## ползёт, пока не упрётся, тогда переваливает за угол; сбитый вниз -- падает
## с весом, своим для каждого положения.  Раненый становится вещью $28 --
## тем же умом, но входящим сразу в тело ($977D → $97FB) и с другими вылетами
## щупа ($FB/$FE и $F8/$FC), потому что перевёрнутый он крупнее.
##
## Все таблицы взяты длиннее, чем нужно живому: раненый прибавляет к своему
## положению шесть ($97B1), и картридж при этом спокойно читает за конец
## таблицы -- то, что лежит следом.
const WEIGHT_27 := [0x28, 0x24, 0x02, 0xD8, 0xDC, 0xFE, 0x14, 0x12, 0x02,
		0xEC, 0xEE, 0xFE, 0x03, 0x05, 0x03, 0x03, 0x05, 0x03, 0x09, 0x0B]
const NEXT_UP_27 := [0x03, 0x05, 0x03, 0x03, 0x05, 0x03, 0x09, 0x0B, 0x09,
		0x09, 0x0B, 0x09, 0x00, 0x02, 0x00, 0x00, 0x02, 0x00, 0x06, 0x08]
const NEXT_DOWN_27 := [0x00, 0x02, 0x00, 0x00, 0x02, 0x00, 0x06, 0x08, 0x06,
		0x06, 0x08, 0x06, 0x00, 0x01, 0x01, 0x02, 0x03, 0x03, 0x04, 0x05]
const PIC_27 := [0x00, 0x01, 0x01, 0x02, 0x03, 0x03, 0x04, 0x05, 0x05, 0x06,
		0x07, 0x07, 0x5E, 0x5D, 0x61, 0x60, 0x64, 0x63, 0x67, 0x66]
const KIND_MOVE_27 := [0x5E, 0x5D, 0x61, 0x60, 0x64, 0x63, 0x67, 0x66, 0x5F,
		0x5F, 0x62, 0x62, 0x65, 0x65, 0x68, 0x68, 0xF4, 0xEC, 0xFC, 0xFC]
const KIND_STILL_27 := [0x5F, 0x5F, 0x62, 0x62, 0x65, 0x65, 0x68, 0x68, 0xF4,
		0xEC, 0xFC, 0xFC, 0xF8, 0xF4, 0xFC, 0xFC, 0x04, 0x04, 0x0C, 0x14]
const UP_27 := [0xF4, 0xEC, 0xFC, 0xFC, 0xF8, 0xF4, 0xFC, 0xFC, 0x04, 0x04,
		0x0C, 0x14, 0x04, 0x04, 0x08, 0x0C, 0xF6, 0xEE, 0x0A, 0x12]
const DOWN_27 := [0x04, 0x04, 0x0C, 0x14, 0x04, 0x04, 0x08, 0x0C, 0xF6, 0xEE,
		0x0A, 0x12, 0xFA, 0xF6, 0x06, 0x0A, 0xFF, 0xFF, 0x01, 0x01]
const AHEAD_27 := [0xF6, 0xEE, 0x0A, 0x12, 0xFA, 0xF6, 0x06, 0x0A, 0xFF, 0xFF,
		0x01, 0x01, 0xFF, 0xFF, 0x01, 0x01, 0xFE, 0xFC, 0xFD, 0x02]
const AHEAD2_27 := [0xFF, 0xFF, 0x01, 0x01, 0xFF, 0xFF, 0x01, 0x01, 0xFE,
		0xFC, 0xFD, 0x02, 0x04, 0x03, 0xFF, 0xFE, 0xFD, 0x01, 0x02, 0x03]
const VY_27 := [0xFE, 0xFC, 0xFD, 0x02, 0x04, 0x03, 0xFF, 0xFE, 0xFD, 0x01,
		0x02, 0x03, 0x00, 0x00, 0x00, 0x03, 0x03, 0x03, 0x06, 0x06]
const AROUND_27 := [0x00, 0x00, 0x00, 0x03, 0x03, 0x03, 0x06, 0x06, 0x06,
		0x09, 0x09, 0x09, 0xEC, 0xEC, 0xEC, 0x14, 0x14, 0x14, 0xF4, 0xF4]
const PROBE_27 := [0xEC, 0xEC, 0xEC, 0x14, 0x14, 0x14, 0xF4, 0xF4, 0xF4, 0x0C,
		0x0C, 0x0C, 0xBD, 0x8C, 0x05, 0xD0, 0x0A, 0x20, 0xA2, 0xC9]

## $FD31 -- на сколько сдвинуть, чтобы стать вплотную к нижней черте клетки
## в шестнадцать точек.  Ноль..семь тянут назад, восемь..пятнадцать -- вперёд;
## после этого младшие четыре бита всегда пятнадцать.
const SNAP16 := [0xFF, 0xFE, 0xFD, 0xFC, 0xFB, 0xFA, 0xF9, 0xF8,
		0x07, 0x06, 0x05, 0x04, 0x03, 0x02, 0x01, 0x00]


## $FD16 ($C984, $C987, $C98A) -- поставить на черту клетки.  В области,
## идущей вниз, к своей высоте прибавляется младший байт вида ($67), потому
## что там клетки считаются от карты, а не от экрана.
func snap16(s: PackedByteArray, extra: int) -> void:
	var t: int = (extra + s[F_Y]) & 0xFF
	if lvl.vertical:                                   # $97
		t = (t + (cam & 0xFF)) & 0xFF
	nudge_down(s, 0x00, SNAP16[t & 0x0F])              # $FA53


func _mind_27(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_LIFE] = 0x7F                               # $BE5A
		s[F_MARK] = 0x01
		set_speed_side_at_hero(s, 0xFF, 0x80)          # $BEBF
		var r: int = random()                          # $C939
		s[F_COUNT] = ((r & 0x0F) + 1
				+ (1 if rng_carry else 0)) & 0xFF
		s[F_STATE] += 1                                # $C966
		return
	if s[F_LIFE] != 0x7F:                              # $979E
		_hurt_27(s)
	_body_27(n, s)


## $977D -- раненый.  Он входит прямо в тело: ни просыпания, ни второй раны.
func _mind_28(n: int, s: PackedByteArray) -> void:
	_body_27(n, s)


## $97A2 -- рана.  Он делается вещью на единицу старше, переворачивается
## (положение плюс шесть) и оставляет в списке уровня свою копию.
func _hurt_27(s: PackedByteArray) -> void:
	s[F_TYPE] = (s[F_TYPE] + 1) & 0xFF
	s[F_LIFE] = 0x01                                   # $BE63
	s[F_STUN] = 0x08
	s[F_SELF] = (s[F_SELF] + 6) & 0xFF
	var g: int = PIC_27[s[F_SELF]]
	if s[F_COUNT] != 0:
		s[F_COUNT] = 0x01                              # $BE7C
		s[F_KIND] = KIND_STILL_27[g]
	else:
		s[F_KIND] = KIND_MOVE_27[g]
	if (s[F_VXFR] | s[F_VX]) != 0:
		set_speed_side_facing(s, 0xFF, 0x00)           # $BEC5
	for k in range(FIRST_PLACED, SLOTS):               # $C86A
		if slots[k][F_TYPE] != 0:
			continue
		copy_row(k, s)                                 # $C963
		var c: PackedByteArray = slots[k]
		if c[F_COUNT] != 0:
			c[F_COUNT] = 0x20                          # $BE7C
			slots[k] = c
		break
	turn_about(s)                                      # $C91B


## $97FB -- тело.  Пока счёт идёт, он ползёт; счёт вышел -- выбирает,
## куда дальше; счёт в нуле -- он падает.
func _body_27(n: int, s: PackedByteArray) -> void:
	if s[F_COUNT] == 0:
		_fall_27(n, s)
		return
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	_turn_27(s)


## $9809 -- счёт вышел.  Упёрся щупом -- переваливает за угол; стоит прямо --
## иногда бросается к герою, иначе плетётся наугад.
func _turn_27(s: PackedByteArray) -> void:
	var cornered := false
	var probe: int = 0xFB if s[F_TYPE] == 0x27 else 0xFE
	if walled_either(s, probe, PROBE_27[s[F_SELF]]) >= 0x80:   # $C94B
		s[F_SELF] = AROUND_27[s[F_SELF]]
		s[F_KEEP] = s[F_KEEP] | 0x01
		cornered = true
	var upright: int = s[F_SELF]
	if upright == 0 or upright == 3 or upright == 6 or upright == 9:
		var rushed := false
		if s[F_KEEP] != 0:
			s[F_KEEP] = (s[F_KEEP] - 1) & 0xFF
		else:
			var sd: Array = hero_side(s)               # $C93C
			if not sd[2]:
				s[F_KEEP] = 0x03                       # $BE83
				set_speed_side_at_hero(s, 0xFE, 0x00)  # $BEBF
				s[F_SELF] = (s[F_SELF] + 1) & 0xFF
				rushed = true
		if not rushed:
			# $986A -- бредёт, и раз в пятую шестую поворачивает.
			set_speed_side_at_hero(s, 0xFF, 0x40)      # $BEBF
			if random() >= 0xD0:                       # $C939
				turn_about(s)                          # $C91B
	else:
		set_speed_side_at_hero(s, 0xFF, 0xE0)          # $BEBF
	# $9881 -- стена прямо перед лицом останавливает ход вбок.
	var side: int = 0xF8 if s[F_TYPE] == 0x27 else 0xFC
	var g: int = PIC_27[s[F_SELF]]
	var v: int = AHEAD_27[g]
	var half: int = (v >> 1) | (0x80 if v >= 0x80 else 0x00)   # $9899 ROR
	if walled_ahead(s, side, v, half) >= 0x80:         # $C954
		set_speed_side(s, 0x00, 0x00)                  # $BEB3
	set_speed_down(s, VY_27[s[F_SELF]], 0x00)          # $C909
	if cornered:
		set_speed_down(s, 0x01 if s[F_VY] < 0x80 else 0xFF, 0x00)


## $98C4 -- падение.  Вес свой на каждое положение, и обе скорости зажаты.
func _fall_27(n: int, s: PackedByteArray) -> void:
	var w: int = WEIGHT_27[s[F_SELF]]
	if w < 0x80:
		add_speed_down(s, w)                           # $C90C
	else:
		sub_speed_down(s, (0x100 - w) & 0xFF)          # $C858, $C90F
	if s[F_VY] < 0x80:
		if s[F_VY] >= 0x04:
			set_speed_down(s, 0x04, 0x00)              # $BEB9
	elif s[F_VY] < 0xFC:
		set_speed_down(s, 0xFC, 0x00)                  # $BEB9
	if s[F_VX] < 0x80:
		if s[F_VX] >= 0x01:
			sub_speed_side(s, 0x10)                    # $C915
	elif s[F_VX] < 0xFF:
		add_speed_side(s, 0x10)                        # $C912
	# $990C
	var g: int = PIC_27[s[F_SELF]]
	var side: int = 0xF8 if s[F_TYPE] == 0x27 else 0xFC
	if walled_ahead_turn(n, s, side, AHEAD2_27[g],
			AHEAD_27[g], 0x00) >= 0x80:                # $C957
		nudge_side(s, 0x00, 0xFE if (s[F_BITS] & 0x40) != 0 else 0x02)
		set_speed_side(s, 0x00, 0x00)                  # $BEB3
	step_side(s)                                       # $C8F7
	var under: int = 0xFB if s[F_TYPE] == 0x27 else 0xFF
	if s[F_VY] < 0x80:
		if walled_either_turn(n, s, under, DOWN_27[g], 0x00) >= 0x80:
			_land_27(s, true)                          # $997C
			return
	elif walled_either_turn(n, s, under, UP_27[g], 0x00) >= 0x80:
		_land_27(s, false)                             # $999E
		return
	s[F_KIND] = KIND_MOVE_27[g]
	step_down(s)                                       # $C8F4


## $997C и $999E -- прилип.  Он встаёт вплотную к тому, во что упёрся,
## берёт новое положение и снова заводит счёт.
func _land_27(s: PackedByteArray, downward: bool) -> void:
	# $99D5 -- звук.  Из двенадцати положений четыре молчат, и это те, на
	# которых он только что был: прилипнув снова к тому же, он не звучит.
	if s[F_SELF] != 0x00 and s[F_SELF] != 0x03 \
			and s[F_SELF] != 0x06 and s[F_SELF] != 0x09:
		Pb2Sound.want(0x20)                            # $99E8
	var g: int = PIC_27[s[F_SELF]]
	nudge_down(s, 0x00, DOWN_27[g] if downward else UP_27[g])   # $C930
	snap16(s, 0x00)                                    # $C987 / $C98A
	s[F_SELF] = NEXT_DOWN_27[s[F_SELF]] if downward \
			else NEXT_UP_27[s[F_SELF]]
	# $99BD
	var r: int = random()                              # $C939
	s[F_COUNT] = ((r & 0x0F) + 0x0F + (1 if rng_carry else 0)) & 0xFF
	s[F_KIND] = KIND_STILL_27[PIC_27[s[F_SELF]]]


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


## $A7AD (банк 11) -- пушка в стене.  Она никуда не смотрит: угол ей дан
## записью и больше не меняется.  Раз в шестнадцать кадров она считает, под
## каким углом стоит герой ($C9C6), и если он попал в её створ шириной в
## восемь на сторону -- даёт очередь из трёх.
##
## Шесть чисел записи лежат парами: первые три -- угол, вторые три -- ширина
## створа.  Запись даёт только два бита ($A7B5 AND #$03), а таблицы по три
## длиной, так что четвёртая запись читает начало соседней -- как на плате.
const WAKE_29 := [0x40, 0x80, 0x00, 0xC0, 0x00, 0x80]
## $A88A -- сколько прибавить к углу, прежде чем спросить, не за спиной ли он.
const OFF_29 := [0x00, 0xC0, 0x40]
## $A88D и $A890 -- где рождается выстрел, вниз и вбок.
const DOWN_29 := [0x04, 0x00, 0x00]
const SIDE_29 := [0x00, 0xFE, 0x02]


func _mind_29(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		# $A7B2 -- два бита записи говорят, куда она смотрит.
		s[F_PUSH] = s[F_LIFE] & 0x03
		shift_eight(s, s[F_LIFE])                      # $C9BD
		s[F_LIFE] = 0x01                               # $BE5A
		s[F_MARK] = 0x01
		var i: int = s[F_PUSH]
		s[F_KIND] = (0x25 + i) & 0xFF
		s[F_SELF] = WAKE_29[i]
		s[F_COUNT] = WAKE_29[i + 3]
		s[F_KEEP] = (s[F_KEEP] + 1) & 0xFF
		s[F_KEEP2] = (s[F_KEEP2] + 1) & 0xFF
		s[F_STATE] += 1                                # $C966
		return
	# $A7E9 -- сошла с экрана: очередь сбросить и ждать.
	if (s[F_XHI] | s[F_YHI]) != 0:                     # $C9C3
		_hold_29(s)
		return
	aim_clock(s, 0x10, 0x00)                           # $C9C6
	if s[F_REC_BYTE] == 0:
		s[F_KEEP2] = (s[F_KEEP2] - 1) & 0xFF           # $A803
		if s[F_KEEP2] != 0:
			return
		# $A808 -- он в створе?  Ровно тот же угол, или на восемь в любую
		# сторону от него.
		if s[F_SELF] != s[F_COUNT]:
			var d: int = ((s[F_COUNT] - s[F_SELF]) + 0x08) & 0xFF
			if d >= 0x11:                              # $A81A
				s[F_KEEP2] = 0x10                      # $BE8A
				return
		s[F_ANG] = 0x03                                # $BE98
		s[F_REC_BYTE] = (s[F_REC_BYTE] + 1) & 0xFF
		s[F_KEEP2] = (s[F_KEEP2] + 1) & 0xFF
	# $A82A -- очередь идёт.
	s[F_KEEP2] = (s[F_KEEP2] - 1) & 0xFF
	if s[F_KEEP2] != 0:
		return
	s[F_KEEP2] = 0x10                                  # $BE8A
	if not _shoot_29(s):
		return
	s[F_ANG] = (s[F_ANG] - 1) & 0xFF                   # $A87C
	if s[F_ANG] != 0:
		return
	s[F_REC_BYTE] = 0x00                               # $BE9F
	s[F_KEEP2] = 0x90                                  # $BE8A


## $A7EE -- сошла с экрана.
func _hold_29(s: PackedByteArray) -> void:
	s[F_REC_BYTE] = 0x00                               # $BE9F
	s[F_KEEP2] = 0x10                                  # $BE8A


## $A833 -- один выстрел.  Три запрета: угол с прибавкой должен быть меньше
## $81, и он должен стоять ближе ста двадцати восьми точек и вбок, и вниз.
## Три запрета кончаются отсчётом очереди, а нерождённый выстрел -- нет:
## $A862 уходит сразу на выход, минуя $A87C.  Отсюда и ответ.
func _shoot_29(s: PackedByteArray) -> bool:
	var i: int = s[F_PUSH]
	if ((s[F_SELF] + OFF_29[i]) & 0xFF) >= 0x81:       # $A83D
		return true
	if apart_side(s) >= 0x80:                          # $C86D
		return true
	if apart_down(s) >= 0x80:                          # $C870
		return true
	var k: int = make_child(s, SIDE_29[i], DOWN_29[i], 0x2A)   # $C8DF
	if k < 0:
		return false
	var c: PackedByteArray = slots[k]
	c[F_SELF] = 0x05                                   # $BE75
	# $A86A -- угол выстрела ложится на ближайшую шестнадцатую доли круга.
	set_speed_at(c, 0x0C, (s[F_SELF] + 0x08) & 0xF0)   # $C8AF
	return true


## $8F96 (банк 10) -- тот, что бросает.  Шесть состояний: заводится, ходит
## по краю и бросает, стоит после броска, гибнет, лежит, встаёт снова.
func _mind_20(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:                                  # $C97E
		0: _wake_20(s)
		1: _walk_20(n, s)
		2: _throw_20(s)
		3: _die_20(s)
		4: _lie_20(s)
		5: _rise_20(s)


## $8FA5
func _wake_20(s: PackedByteArray) -> void:
	s[F_LIFE] = 0x7F                                   # $BE5A
	s[F_MARK] = 0x01
	start_anim(s, 0x10)                                # $BEAD
	set_speed_side_at_hero(s, 0xFF, 0x80)              # $BEBF 80 FF
	s[F_SELF] = 0x40                                   # $BE75
	s[F_STATE] += 1                                    # $C966


## $8FB9 -- ходит по краю; счёт вышел -- бросает.
func _walk_20(n: int, s: PackedByteArray) -> void:
	if s[F_LIFE] < 0x7E:                               # $8FBC
		_hurt_20(s)
		return
	walled_ahead_turn_about(n, s, 0xF6, 0xFF, 0xEC)    # $BF12 F6 EC FF
	# $BE4E отдаёт первый байт в Y, второй в A: щуп вбок -- $F8, вниз -- $04.
	ground_turn_edge(n, s, 0xF8, 0x04)                 # $BEE9 04 F8
	step_anim(s)                                       # $C8EE
	step_both(s)
	if s[F_SELF] != 0:
		s[F_SELF] = (s[F_SELF] - 1) & 0xFF
		return
	# $8FE1 -- бросок вылетает из точки на сорок выше его собственной.
	if not _lob_20(s, 0x00, 0xD8):                     # $9055
		return
	start_anim(s, 0x12)                                # $BEAD
	s[F_SELF] = 0x16                                   # $BE75
	s[F_STATE] += 1                                    # $C966


## $8FD7 -- рана.
func _hurt_20(s: PackedByteArray) -> void:
	s[F_MARK] = 0x80                                   # $C9AB
	start_anim(s, 0x11)                                # $BEAD
	s[F_STATE] = 3                                     # $C975


## $8FF5 -- стоит после броска.
func _throw_20(s: PackedByteArray) -> void:
	if s[F_LIFE] < 0x7E:
		_hurt_20(s)
		return
	if s[F_SELF] != 0:
		s[F_SELF] = (s[F_SELF] - 1) & 0xFF
		if s[F_SELF] != 0:
			step_anim(s)                               # $C837
			return
		s[F_COUNT] = 0x40                              # $BE7C
		start_anim(s, 0x10)                            # $BEAD
	# $9011
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	s[F_SELF] = 0xFF                                   # $BE75
	s[F_STATE] -= 1                                    # $C969


## $901E -- гибнет; картинка $A3 кончает падение.
func _die_20(s: PackedByteArray) -> void:
	step_anim(s)                                       # $C837
	if s[F_KIND] != 0xA3:
		return
	s[F_COUNT] = 0xC0                                  # $BE7C
	s[F_STATE] += 1                                    # $C966


## $9030 -- лежит.
func _lie_20(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	s[F_STATE] += 1                                    # $C966


## $9036 -- встаёт; картинка $A4 кончает подъём.
func _rise_20(s: PackedByteArray) -> void:
	step_anim(s)                                       # $C837
	if s[F_KIND] != 0xA4:
		return
	start_anim(s, 0x10)                                # $BEAD
	s[F_LIFE] = 0x7F                                   # $BE5A
	s[F_MARK] = 0x01
	s[F_SELF] = 0x40                                   # $BE75
	set_speed_side_at_hero(s, 0xFF, 0x80)              # $BEBF 80 FF
	s[F_STATE] = 1                                     # $C96F


## $9055 -- бросок.  Не за экраном, лицом к нему, и он между $28 и $4F
## точками вбок.  Ответ -- вышло ли: не вышло, и ход обрывается.
func _lob_20(s: PackedByteArray, side: int, down: int) -> bool:
	if (s[F_XHI] | s[F_YHI]) != 0:                     # $C9C3
		return false
	if looking_away(s):                                # $C98D
		return false
	var d: int = apart_side(s)                         # тот же $CADB
	if d >= 0x50:                                      # $9063
		return false
	if d < 0x28:                                       # $9067
		return false
	var k: int = make_child(s, side, down, 0x21)       # $C8DF
	if k < 0:
		return false
	set_speed_reach(slots[k], 0x40, 0xFE)              # $C9CF
	Pb2Sound.want(0x38)                                # $9087 -- он бросил
	return true


## $B697 (банк 11) -- прыгун.  Четыре состояния: заводится, падает, ходит и
## бросает.  Запись он помнит в $0652 и по ней решает, много ли ходить.
func _mind_39(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:                                  # $C97E
		0: _wake_39(s)
		1: _fall_39(n, s)
		2: _walk_39(n, s)
		3: _throw_39(s)


## $B6A2
func _wake_39(s: PackedByteArray) -> void:
	s[F_REC_BYTE] = s[F_LIFE]
	s[F_LIFE] = 0x08                                   # $BE63
	record_home_along(s)                               # $C9B1
	_start_39(s)


## $B6B2 -- отсюда он начинает и сюда же возвращается, отбросив.
func _start_39(s: PackedByteArray) -> void:
	s[F_KIND] = 0xAC                                   # $BE6E
	s[F_MARK] = 0x20                                   # $C9A5
	set_speed_down(s, 0xFD, 0x00)                      # $BEB9 00 FD
	s[F_SELF] = 0xB4                                   # $BE75
	s[F_COUNT] = 0x00                                  # $BE7C
	s[F_STATE] = 1                                     # $C96F


## $B6C9 -- падает.  Вверх -- потолок его останавливает; вниз -- пол сажает,
## и с третьего касания он переходит к ходьбе.
func _fall_39(n: int, s: PackedByteArray) -> void:
	if s[F_SELF] != 0:
		s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	add_speed_down(s, 0x1C)                            # $C90C
	if s[F_VY] >= 0x80:
		# $BEDD E8 04 -- вбок $04, вниз $E8 (второй байт в A, первый в Y).
		if walled_either_turn(n, s, 0x04, 0xE8, 0x00) >= 0x80:
			set_speed_down(s, 0x00, 0x00)              # $BEB9 00 00
		step_down(s)                                   # $C8F4
		return
	if s[F_VY] >= 0x04:                                # $B6EA
		set_speed_down(s, 0x04, 0x00)                  # $BEB9 00 04
	if walled_either_turn(n, s, 0x04, 0x04, 0x00) < 0x80:
		step_down(s)                                   # $C8F4
		return
	# $B6FA -- пока идёт первый отсчёт, каждое касание пола считается.
	if s[F_SELF] != 0:
		s[F_COUNT] = (s[F_COUNT] + 1) & 0xFF
		if s[F_COUNT] < 0x04:
			set_speed_down(s, 0xFD, 0x00)              # $BEB9 00 FD
			step_down(s)                               # $C8F4
			return
	# $B709
	snap16(s, 0x00)                                    # $C987
	start_anim(s, 0x20)                                # $BEAD
	set_speed_side_at_hero(s, 0xFF, 0x80)              # $BEBF 80 FF
	s[F_STATE] += 1                                    # $C966
	s[F_SELF] = 0x01 if s[F_REC_BYTE] != 0 else 0x40   # $BE75


## $B731 -- ходит.  Ушла земля из-под ног -- падает снова; ушёл далеко от
## своего места или упёрся -- поворачивает; вышел отсчёт -- бросает.
func _walk_39(n: int, s: PackedByteArray) -> void:
	# $BEE3 04 08 -- вбок $08, вниз $04.
	if walled_either_turn(n, s, 0x08, 0x04, 0x80) < 0x80:
		s[F_SELF] = 0x00                               # $BE75
		set_speed_down(s, 0x00, 0x80)                  # $BEB9 80 00
		s[F_STATE] -= 1                                # $C969
		return
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] == 0:
		start_anim(s, 0x21)                            # $BEAD
		s[F_MARK] = 0x01                               # $C99F
		face_hero(s)                                   # $C8FD
		s[F_SELF] = 0x46                               # $BE75
		s[F_STATE] += 1                                # $C966
		return
	step_anim(s)                                       # $C837
	var back: bool = strayed_far(s)                    # $ACD0
	if not back:
		# $BF06 F6 FF E8 -- вбок $F6, щупы $E8 и $FF.
		back = walled_ahead_turn(n, s, 0xF6, 0xE8, 0xFF, 0x00) >= 0x80
	if back:
		s[F_SELF] = (s[F_SELF] + 0x14) & 0xFF
		turn_about(s)                                  # $C91B
	step_side(s)                                       # $C8F7


## $B779 -- бросает.  Пока картинка не $B1, он только её и крутит; на $10
## отсчёта из него вылетает вещь $14.
func _throw_39(s: PackedByteArray) -> void:
	face_hero(s)                                       # $C8FD
	if s[F_KIND] != 0xB1:
		step_anim(s)                                   # $C837
		return
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] == 0:
		_start_39(s)                                   # $B7AA -> $B6B2
		return
	if s[F_SELF] != 0x10:
		return
	var side: int = 0x0A if (s[F_BITS] & 0x40) != 0 else 0xF6   # $C990
	make_child_at_hero(s, side, 0xEA, 0x14, 0x0C)      # $C8E2


## $A1EC..$A30F (банк 11) -- четыре таблицы скоростей и дорожки площадок, одним
## куском, как они лежат в картридже: указатели дорожек ($A20C и $A21D) метят
## внутрь этого же куска.
const RAIL_BASE := 0xA1EC
const RAIL_DATA := [
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x80, 0x00, 0x00, 0x01, 0xFF,
		0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x80, 0x80, 0x00, 0x00,
		0xFF, 0x01, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x2E, 0x40, 0x4D, 0x59,
		0x5E, 0x75, 0x8D, 0xA2, 0xB3, 0xD2, 0xF1, 0xF5, 0xFA, 0xFE, 0x2E, 0x01,
		0x05, 0xA2, 0xA2, 0xA2, 0xA2, 0xA2, 0xA2, 0xA2, 0xA2, 0xA2, 0xA2, 0xA2,
		0xA2, 0xA2, 0xA2, 0xA2, 0xA3, 0xA3, 0x43, 0x40, 0x43, 0x41, 0x43, 0x20,
		0x53, 0x21, 0x43, 0x20, 0x53, 0x21, 0x43, 0x40, 0x43, 0x41, 0x53, 0x00,
		0x1F, 0x10, 0xC7, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0xC7, 0x11, 0x23,
		0x00, 0x52, 0x60, 0x53, 0x60, 0x52, 0x60, 0x53, 0x60, 0x52, 0x60, 0x53,
		0x00, 0xE5, 0x32, 0xF1, 0xF1, 0x00, 0xE3, 0xA3, 0xE1, 0xE3, 0xE3, 0x63,
		0xC0, 0x83, 0x21, 0x62, 0x21, 0x23, 0x21, 0x22, 0x41, 0xE3, 0xC0, 0x83,
		0x61, 0xE3, 0xE3, 0xA1, 0x00, 0x62, 0xA2, 0x60, 0xC3, 0x21, 0x22, 0x41,
		0xE3, 0x43, 0x20, 0xE3, 0xA1, 0xE3, 0xE3, 0x23, 0xE0, 0x43, 0x61, 0x63,
		0x60, 0xE3, 0x23, 0x20, 0x00, 0x62, 0xA2, 0x61, 0xC3, 0x60, 0xE3, 0x43,
		0x21, 0xE3, 0xA0, 0xE3, 0xC3, 0xE1, 0x63, 0x60, 0x63, 0x61, 0xE3, 0x23,
		0x21, 0x00, 0xE3, 0xC3, 0xE0, 0xE3, 0xE3, 0x23, 0xE1, 0xC3, 0xE0, 0x82,
		0x81, 0xE3, 0xE3, 0xE3, 0x23, 0x81, 0x00, 0xE2, 0xE2, 0x22, 0xE0, 0x22,
		0xA1, 0xE2, 0x42, 0xA0, 0x62, 0x61, 0xE2, 0x60, 0x83, 0x81, 0xE2, 0x62,
		0x21, 0x82, 0x21, 0x82, 0x21, 0x82, 0x40, 0x83, 0x20, 0xE2, 0xE2, 0x42,
		0x81, 0x00, 0xA2, 0x21, 0x43, 0xA1, 0xE2, 0xE2, 0x82, 0x41, 0xC3, 0x20,
		0xE2, 0xA2, 0x20, 0x63, 0x40, 0x82, 0x21, 0x82, 0x21, 0x82, 0x21, 0x63,
		0x21, 0xE2, 0xE2, 0xE2, 0x42, 0x60, 0xA2, 0x61, 0x00, 0x60, 0xE3, 0xA3,
		0x00, 0x41, 0xE3, 0xE3, 0x23, 0x00, 0x61, 0xE3, 0xE3, 0x00, 0xE3, 0xE3,
		0x00, 0xE2, 0xE2, 0x22, 0x00, 0xE3, 0xE3, 0x23, 0x00, 0x20, 0x7E, 0xC9,
		0x19, 0xA3, 0x51, 0xA3,
]
## $A20C:$A21D -- какая дорожка чьей записи ($049A).
const RAIL_PATH := [0xA22E, 0xA240, 0xA24D, 0xA259, 0xA25E, 0xA275, 0xA28D, 0xA2A2, 0xA2B3, 0xA2D2, 0xA2F1, 0xA2F5, 0xA2FA, 0xA2FE, 0xA22E, 0xA301, 0xA305]
## $A0B9 -- на сколько площадка опускается, когда просыпается.
const DROP_0A := [0x00, 0x00, 0x00, 0x0A]


## $A061 (банк 11) -- площадка, что срывается, когда на неё встали.
func _mind_09(_n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:                                  # $C97E
		0:                                             # $A06C
			s[F_KIND] = 0x0D                           # $BE6E 0D
			s[F_COUNT] = 0x28                          # $BE7C 28
			set_speed_down(s, 0x04, 0x00)              # $BEB9 00 04
			s[F_STATE] += 1                            # $C966
		1:                                             # $A07C
			ride(s, 0x0F, 0xF1)                        # $A053
			if held == 0x01:                           # $0164
				s[F_STATE] += 1
			ride_apply(s, 0x0F, 0xF1)                  # $A05A
		2:                                             # $A08C
			ride(s, 0x0F, 0xF1)
			s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
			if s[F_COUNT] == 0:
				s[F_STATE] += 1
			ride_apply(s, 0x0F, 0xF1)
		3:                                             # $A09A
			step_down(s)                               # $C8F4


## $A5EC -- шестнадцать высот, по которым вещь качает героя: круг, пройденный
## по счёту картинок ($1C >> 1).
const SWING_0B := [0xCC, 0xCB, 0xCA, 0xC9, 0xC8, 0xC7, 0xC6, 0xC5,
		0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9, 0xCA, 0xCB]

## $A64B и $A64D -- чем герою заводят шаг, когда вещь его отпускает.  Картридж
## читает обе по байту записи ($049A), а таблица короткая: из четырёх байтов,
## какие в уровнях встречаются (0, 1, 2 и $80), три попадают в неё, а $80
## уводит далеко за конец -- в $A6CB/$A6CD, посреди кода соседнего ума.
const LET_0B := {0x00: [0x60, 0x00], 0x01: [0x00, 0x02],
		0x02: [0x00, 0xFE], 0x80: [0x9D, 0x2D]}


## $A50B (банк 11) -- то, за что герой цепляется: в грозовых областях (2:3,
## 2:4 и 3:5) оно хватает его и качает.  Все пять шагов пишут в место героя,
## а не в своё, и все смотрят на $5C: пока гроза выключена, вещь стоит.
func _mind_0b(_n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _wake_0b(s)
		1: _wait_0b(s)
		2: _grip_0b(s)
		3: _drop_0b(s)
		4: _free_0b(s)


## $A518 -- по седьмому биту записи вещь уходит либо ждать, либо сразу
## отпускать.
func _wake_0b(s: PackedByteArray) -> void:
	if not lvl.vertical:                               # $A715
		nudge_side(s, 0, 8)                            # $C936
	s[F_STATE] = 1 if (s[F_LIFE] & 0x7F) == 0 else 3


## $A52B -- ждать: счёт вниз, и пока он не ушёл под ноль, а герой не в позе
## восемь, ничего не происходит.
func _wait_0b(s: PackedByteArray) -> void:
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF                 # $A52B
	if s[F_SELF] < 0x80 and slots[0][F_STATE] != 0x08:
		return
	_drop_0b(s)                                        # $A539


## $A539 -- шаг три, он же выход из ожидания: в грозу переходить дальше, без
## грозы стоять ещё $40 кадров.
func _drop_0b(s: PackedByteArray) -> void:
	if storm >= 0x80:                                  # $5C
		s[F_SELF] = 0x40                               # $A547
		return
	s[F_STATE] = (s[F_STATE] + 1) & 0xFF               # $C966
	s[F_COUNT] = 0x00
	s[F_SELF] = 0x00


## $A5FC -- спросить у $B90D, стоит ли герой на этой вещи.  У помеченной
## седьмым битом записи щуп уходит на $E0 выше.
func _ride_0b(s: PackedByteArray, down: int) -> int:
	if s[F_LIFE] >= 0x80:                              # $A5FF
		down = (down + 0xE0) & 0xFF
	return ride(s, 0x22, down)                         # $A606


## $A550 -- сам захват.
func _grip_0b(s: PackedByteArray) -> void:
	if storm >= 0x80:                                  # $A552
		s[F_STATE] = (s[F_STATE] - 1) & 0xFF           # $C969
		return
	s[F_COUNT] = (s[F_COUNT] + 1) & 0xFF               # $A554
	var h: PackedByteArray = slots[0]
	if h[F_STATE] != 0x08:                             # $A557
		# Поймал: герою гасят дробь падения и заводят медленный подъём.
		if _ride_0b(s, 0xD0) == 0:                     # $A560
			return
		h[F_KEEP] = 0x00                               # $05FA
		h[F_VYFR] = 0x00                               # $054A
		h[F_KEEP2] = 0xFF                              # $0610
		h[F_VY] = 0xFF                                 # $0534
		return
	# $A576 -- он уже висит: пока подъём не выбран до конца, его тормозят.
	if h[F_VY] >= 0x80 and h[F_VY] != 0xFF:
		if _ride_0b(s, 0x80) == 0:                     # $A581
			return
		var d: int = 0xE4 if h[F_VY] >= 0xFB else 0xEC  # $A586
		var f: int = h[F_VYFR] + d
		h[F_VYFR] = f & 0xFF
		h[F_VY] = (h[F_VY] + 0xFF + (1 if f > 0xFF else 0)) & 0xFF
		return
	# $A5A5 -- качание: одна из шестнадцати высот по счёту картинок.
	if _ride_0b(s, SWING_0B[(frame >> 1) & 0x0F]) == 0:
		return
	h[F_VY] = 0xFF                                     # $A5B4
	h[F_VYFR] = 0xCE
	if held != 0x01:                                   # $A5BE
		_loose_0b(h)
		return
	var gap: int = (overlap[2] - hero_box[3]) & 0xFF   # $0A против $011E
	if gap != 0:
		if gap < 0xFE:                                 # $A5CF
			_loose_0b(h)
			return
		_push_down()                                   # $BF1C -> $B828
	h[F_KEEP2] = 0x01                                  # $A5D4
	h[F_KEEP] = 0x00
	_hold_0b(s)                                        # $A60F


## $A5E1 -- он рядом, но не на ней.
func _loose_0b(h: PackedByteArray) -> void:
	h[F_KEEP] = 0x00                                   # $05FA
	h[F_KEEP2] = 0xFE                                  # $0610


## $A60F -- пока счёт меньше $D0, героя держат: скорость вбок гасят, а дробь
## места по иксу ставят по удерживаемому направлению.
func _hold_0b(s: PackedByteArray) -> void:
	if s[F_COUNT] >= 0xD0:                             # $A612
		return
	var h: PackedByteArray = slots[0]
	h[F_VXFR] = 0x00                                   # $0576
	h[F_VX] = 0x00                                     # $0560
	h[F_XFR] = 0x00 if (pad_held & 0x01) != 0 else 0x80  # $051E, $4A


## $A62C -- отпустить: щуп пошире, и если герой на ней, ему заводят шаг из
## двух табличек по байту записи.
func _free_0b(s: PackedByteArray) -> void:
	if storm >= 0x80:                                  # $A62E
		s[F_STATE] = (s[F_STATE] - 1) & 0xFF           # $C969
		return
	ride(s, 0x28, 0xB0)                                # $A634
	if held == 0:                                      # $A637
		return
	var r: Array = LET_0B.get(s[F_LIFE], [0x00, 0x00])
	var h: PackedByteArray = slots[0]
	h[F_SELF] = r[0]                                   # $05CE
	h[F_COUNT] = r[1]                                  # $05E4


## $A09D (банк 11) -- площадка на рельсе.  Она идёт по дорожке из записей
## $A22E и дальше: каждый байт -- сколько кадров ($FC) и в какую сторону ($03).
## Нуль в дорожке значит "поворот": счёт идёт назад и сторона выворачивается.
func _mind_0a(_n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:                                # $A09D
		s[F_MARK] = 0x80                               # $C9AB
		start_anim(s, 0x0A)                            # $BEAD 0A
		_rail_pick(s)                                  # $A15A
		nudge_down(s, 0x00, DROP_0A[s[F_LIFE]])        # $C930
		s[F_STATE] += 1                                # $C966
		return
	ride(s, 0x10, 0xF6)                                # $A0BD
	if s[F_ANG] != 0:                                  # $A0C4
		s[F_ANG] = (s[F_ANG] - 1) & 0xFF               # $A109
		if s[F_ANG] == 0 and _rail_lost(s):            # $A1C4
			s[F_ANG] = 0x0F                            # $BE98 0F
		_rail_step(s)
		return
	var pose: int = slots[0][F_STATE]                  # $A0C9
	if pose == 0x0C or pose == 0x0E:
		_rail_idle(s)
		return
	if held == 0:                                      # $A0D4
		_rail_idle(s)
		return
	if held == 0x02 and suit != 0x01:                  # $A0D9, $9A
		_rail_idle(s)
		return
	if s[F_VY] != 0:                                   # $A0E3
		if s[F_REC_BYTE] < 0x14:                       # $A0F5
			s[F_REC_BYTE] += 1
			ride_apply(s, 0x10, 0xF6)
			return
		s[F_ANG] = 0x10                                # $A102
	elif s[F_REC_BYTE] < 0x14:                         # $A0E8
		s[F_REC_BYTE] += 1
		ride_apply(s, 0x10, 0xF6)
		return
	_rail_step(s)                                      # $A117


## $A14F -- герой сошёл: счёт ожидания с начала.
func _rail_idle(s: PackedByteArray) -> void:
	s[F_REC_BYTE] = 0x00                               # $BE9F 00
	ride_apply(s, 0x10, 0xF6)                          # $A153


## $A117 -- ход площадки: картинка, движение, звук раз в тринадцать кадров и
## отсчёт до следующего колена дорожки.
func _rail_step(s: PackedByteArray) -> void:
	step_anim(s)                                       # $C8EE
	step_both(s)
	s[F_GROUND] = (s[F_GROUND] + 1) & 0xFF             # $A11A
	if s[F_GROUND] == 0x0D:
		s[F_GROUND] = 0x00                             # $BEA6 00
		Pb2Sound.want(0x12)                            # $A12A -- она идёт
	s[F_PUSH] = (s[F_PUSH] - 1) & 0xFF                 # $A12D
	if s[F_PUSH] == 0:
		if s[F_KEEP2] >= 0x80:                         # $A132
			s[F_KEEP] = (s[F_KEEP] - 1) & 0xFF
		else:
			s[F_KEEP] = (s[F_KEEP] + 1) & 0xFF
		_rail_step_leg(s)                              # $A169
		if s[F_VX] != 0:                               # $A143
			s[F_ANG] = 0x00
	ride_apply(s, 0x10, 0xF6)                          # $A153


## $A15A -- какая дорожка досталась этой площадке, и сразу первое её колено.
func _rail_pick(s: PackedByteArray) -> void:
	var p: int = RAIL_PATH[s[F_LIFE]]                  # $A20C, $A21D
	s[F_SELF] = p & 0xFF
	s[F_COUNT] = (p >> 8) & 0xFF
	_rail_step_leg(s)


## $A169 -- взять из дорожки колено под счётом $05FA и разложить его на
## сколько ($0626) и куда ($0576/$0560/$054A/$0534).
func _rail_step_leg(s: PackedByteArray) -> void:
	var p: int = ((s[F_COUNT] << 8) | s[F_SELF]) - RAIL_BASE
	var y: int = s[F_KEEP]
	if y >= 0x80:                                      # $A176
		y = 0
		s[F_KEEP] = 0
		s[F_KEEP2] ^= 0x80
	var a: int = RAIL_DATA[p + y]                      # $A186
	while a == 0:                                      # $A188
		y = (y - 1) & 0xFF
		if y == 0:
			break
		s[F_KEEP] = y                                  # $A17A
		s[F_KEEP2] ^= 0x80
		a = RAIL_DATA[p + y]
	s[F_PUSH] = a & 0xFC                               # $A18D
	var flip: bool = (s[F_KEEP2] & 0x80) != 0          # $A192
	var d: int = RAIL_DATA[p + y] & 0x03               # $A196
	if flip:
		d ^= 0x01
	if s[F_TYPE] != 0x0A:                              # $A19F
		d += 4
	s[F_VXFR] = RAIL_DATA[0xA1EC - RAIL_BASE + d]      # $A1EC
	s[F_VX] = RAIL_DATA[0xA1F4 - RAIL_BASE + d]        # $A1F4
	s[F_VYFR] = RAIL_DATA[0xA1FC - RAIL_BASE + d]      # $A1FC
	s[F_VY] = RAIL_DATA[0xA204 - RAIL_BASE + d]        # $A204


## $A1C4 -- четыре щупа по углам: сошла ли площадка с рельса.
func _rail_lost(s: PackedByteArray) -> bool:
	if ground(s, 0xEC, 0x08) >= 0x80:                  # $C888
		if ground(s, 0xEC, 0xF8) < 0x80:               # $A1CD
			return true
	if ground(s, 0x14, 0x08) < 0x80:                   # $A1D6
		return false
	return ground(s, 0x14, 0xF8) < 0x80                # $A1DF


## $BC1B -- how long to wait before picking the sideways speed again, and
## which of the speeds below to take, by the number handed in.
const SIDE_PICK_3E := [[0x40, 2], [0x10, 0], [0x20, 1], [0x30, 2],
		[0x60, 3], [0x20, 4]]
## $BC27 -- the sideways speeds: whole and 1/256ths, all of them toward him.
const SIDE_SPEED_3E := [[0xFE, 0x00], [0xFE, 0x40], [0xFE, 0x80],
		[0xFE, 0xC0], [0xFF, 0xE0]]
## $BC7F -- and the up-and-down ones.
const DOWN_SPEED_3E := [[0x01, 0x80], [0x01, 0x00], [0x00, 0x80],
		[0x00, 0x40], [0x00, 0x20]]


## $BACB (bank 11) -- the flier that hangs over him and drops on him.  It
## drifts about at the height he is, springs up out of the way of a boomerang,
## hangs there long enough to spit once, and comes down.
func _mind_3e(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:                                  # $C97E
		0: _wake_3e(s)
		1: _hover_3e(n, s)
		2: _rise_3e(n, s)
		3: _dive_3e(n, s)


## $BAD6 -- four lives, and both its counts nudged on by one from whatever the
## list left in them, so that neither picks a speed on its first frame.
func _wake_3e(s: PackedByteArray) -> void:
	s[F_LIFE] = 0x04                                   # $BE5A 04
	s[F_MARK] = 0x01
	start_anim(s, 0x24)                                # $BEAD 24
	s[F_SELF] = (s[F_SELF] + 1) & 0xFF
	s[F_COUNT] = (s[F_COUNT] + 1) & 0xFF
	record_home_along(s)                               # $C9B1
	s[F_STATE] += 1                                    # $C966


## $BAEA -- hanging about him.  A boomerang on its way sends it straight up,
## unless it is already stopped against a wall to one side.
func _hover_3e(n: int, s: PackedByteArray) -> void:
	step_anim(s)                                       # $C837
	_pick_down_3e(s)                                   # $BC31
	_drift_3e(n, s)                                    # $BBAB
	face_hero(s)                                       # $C8FD
	_pick_side_3e(s)                                   # $BBD6
	if not boomerang_coming(s):                        # $AD0F
		return
	if (s[F_GROUND] & 0xC0) != 0:                      # $BAFF
		return
	_set_side_3e(s, 0)                                 # $BC05 with nought
	set_speed_down(s, 0xF8, 0x00)                      # $BEB9 00 F8
	s[F_KIND] = 0x89                                   # $BE6E 89
	s[F_PUSH] = 0x80                                   # $BE91 80
	s[F_ANG] = 0x00                                    # $BE98 00
	s[F_STATE] += 1                                    # $C966


## $BB1F -- up, then a wait at the top.  While it still climbs it only gathers
## weight; once it hangs it takes aim and spits, and $063C is the rest it
## takes between one shot and the next.
func _rise_3e(n: int, s: PackedByteArray) -> void:
	if s[F_VY] >= 0x80:                                # $BB22 BPL
		add_speed_down(s, 0x64)                        # $C90C
		_drift_3e(n, s)                                # $BBAB
		return
	s[F_PUSH] = (s[F_PUSH] - 1) & 0xFF                 # $BB2C
	if s[F_PUSH] == 0 or (s[F_GROUND] & 0xC0) != 0:    # $BB31
		_dive_start_3e(s)
		return
	s[F_KIND] = 0x8A                                   # $BE6E 8A
	set_speed_down(s, 0x00, 0x00)                      # $BEB9 00 00
	_drift_3e(n, s)                                    # $BBAB
	face_hero(s)                                       # $C8FD
	_pick_side_3e(s)                                   # $BBD6
	if s[F_ANG] != 0:                                  # $BB4A
		s[F_ANG] = (s[F_ANG] - 1) & 0xFF
		if s[F_ANG] != 0:
			return
	var side: Array = hero_side(s)                     # $C93C
	if bool(side[2]) or int(side[0]) >= 0x80:          # $BB57, $BB5B
		_dive_start_3e(s)
		return
	if int(side[0]) >= 0x30:                           # $BB5F
		return
	if make_child_aimed(s, 0x00, 0xF0, 0x3F, 0x04, 0x40) < 0:
		return
	s[F_ANG] = 0x20                                    # $BE98 20


## $BB7B -- it gives up hanging and comes down.
func _dive_start_3e(s: PackedByteArray) -> void:
	s[F_KIND] = 0x89                                   # $BE6E 89
	set_speed_down(s, 0x01, 0x80)                      # $BEB9 80 01
	set_speed_side(s, 0x00, 0x00)                      # $BEB3 00 00
	s[F_STATE] += 1                                    # $C966


## $BB8C -- the drop.  It goes back to hanging on the floor, or when he has
## got below it, or when it has come down level with him.
func _dive_3e(n: int, s: PackedByteArray) -> void:
	mover(n, s, 1)                                     # $BCBB with one
	var again: bool = (s[F_GROUND] & 0x02) != 0        # $BB91
	if not again:
		var d: Array = hero_down(s)                    # $C93F
		if bool(d[2]):                                 # $BB9B
			return
		again = bool(d[1]) or int(d[0]) < 0x08         # $BB9D, $BB9F
	if not again:
		return
	s[F_SELF] = 0x08                                   # $BE75 08
	s[F_STATE] = 1                                     # $C96F


## $BBAB -- the move it makes wherever it is.  Too far from where it woke
## turns it about; a wall it has stopped against makes it pick a fresh speed
## on the very next frame.
func _drift_3e(n: int, s: PackedByteArray) -> void:
	mover(n, s, 1)                                     # $BCBB with one
	if strayed_far(s):                                 # $ACD0
		s[F_SELF] = 0x80                               # $BE75 80
		if s[F_VX] >= 0x80:                            # $BBB9
			set_speed_side(s, 0x01, 0x00)              # $BEB3 00 01
		else:
			set_speed_side(s, 0xFF, 0x00)              # $BEB3 00 FF
		return
	if (s[F_GROUND] & 0xC0) != 0:                      # $BBCA
		s[F_SELF] = 0x01                               # $BE75 01


## $BBD6 -- how fast to go across, picked afresh when the count runs out.  The
## further off he is the slower it comes, and a wall it is stuck against gets
## its own entry so that it backs away.
func _pick_side_3e(s: PackedByteArray) -> void:
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] != 0:
		return
	var side: Array = hero_side(s)                     # $C93C
	var y := 8
	if bool(side[2]):                                  # $BBDF
		y = 2
	elif (s[F_GROUND] & 0xC0) != 0:                    # $BBE2
		y = 10
	elif int(side[0]) >= 0x60:                         # $BBEF
		y = 4
	elif int(side[0]) >= 0x30:                         # $BBF3
		y = 6
	_set_side_3e(s, y)


## $BC05 -- the pick itself, kept apart because the hover state jumps straight
## in here with a nought of its own.
func _set_side_3e(s: PackedByteArray, y: int) -> void:
	var pick: Array = SIDE_PICK_3E[y >> 1]
	s[F_SELF] = pick[0]
	var sp: Array = SIDE_SPEED_3E[pick[1]]
	set_speed_side_at_hero(s, sp[0], sp[1])            # $C900


## $BC31 -- and how fast up or down, on a count of its own.  The carry the
## question about him leaves behind says which way, and $C921 turns the speed
## over when he is the further down.
func _pick_down_3e(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		return
	s[F_COUNT] = 0x22                                  # $BE7C 22
	var d: Array = hero_down(s)                        # $C93F
	var y := 8
	if bool(d[2]):                                     # $BC3F
		y = 0
	elif (s[F_GROUND] & 0xC0) != 0:                    # $BC42
		y = 4
	elif int(d[0]) >= 0x60:                            # $BC4E
		y = 2
	elif int(d[0]) >= 0x30:                            # $BC52
		y = 4
	elif int(d[0]) >= 0x10:                            # $BC56
		y = 6
	var sp: Array = DOWN_SPEED_3E[y >> 1]
	set_speed_down(s, sp[0], sp[1])                    # $C909
	if bool(d[1]):                                     # $BC78 -- the kept carry
		flip_speed_down(s)                             # $C921


## $B2D5 and $B2DE -- how fast it goes down when it dives, and $B2E7 the
## weight that eats the dive away again, both by which eighth of the screen
## he stands in.  The last entry is the one it takes off the floor.
const DIVE_3A := [[0x03, 0x00], [0x02, 0x80], [0x02, 0x40], [0x01, 0xC0],
		[0x01, 0x80], [0x01, 0x00], [0x00, 0x00], [0xFF, 0x80], [0x00, 0x00]]
const DIVE_PULL_3A := [0x0E, 0x0F, 0x10, 0x14, 0x18, 0x1C, 0x22, 0x24, 0x01]
## $B3A3 -- the wobble it flies with: a line down, or none.  The count runs up
## and down the table and the sign turns over every sixty-four frames, so what
## comes out is a slow swim.
const WOBBLE_3A := [0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1,
		0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1]
## $B409 -- the angle the two young start off at, by which way it looks.
const YOUNG_3A := [0x90, 0x70, 0xF0, 0x10]


## $B1EC (bank 11) -- the swimmer.  It drifts about him with a wobble, lets
## two young go, then takes aim and dives.
func _mind_3a(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:                                  # $C97E
		0: _wake_3a(n, s)
		1: _drift_3a(n, s)
		2: _hold_3a(n, s)
		3: _spit_3a(n, s)
		4: _drift_3a(n, s)
		5: _aim_dive_3a(n, s)
		6: _dive_3a(n, s)


## $B1FD -- it wakes and goes straight on into the drift below.
func _wake_3a(n: int, s: PackedByteArray) -> void:
	record_home_along(s)                               # $C9B1
	s[F_LIFE] = 0x08                                   # $BE5A 08
	s[F_MARK] = 0x01
	start_anim(s, 0x22)                                # $BEAD 22
	s[F_PUSH] = 0x20                                   # $BE91 20
	s[F_STATE] = 1                                     # $C96F
	_fly_3a(n, s)                                      # $B21F


## $B21F -- the move it makes in every drifting state.
func _fly_3a(n: int, s: PackedByteArray) -> void:
	step_anim(s)                                       # $C837
	_swim_3a(n, s)                                     # $B222


## $B222 -- the same without the picture, which the spitting state wants.
func _swim_3a(n: int, s: PackedByteArray) -> void:
	face_hero(s)                                       # $C8FD
	_wobble_3a(s)                                      # $B376
	mover(n, s, 0)                                     # $B371


## $B212 -- drifting, which is both the second state and the fifth.  Off the
## edge of the screen, or a count run out, moves it on.
func _drift_3a(n: int, s: PackedByteArray) -> void:
	if (s[F_XHI] | s[F_YHI]) != 0:                     # $C9C3
		s[F_STATE] += 1                                # $C966
	else:
		s[F_PUSH] = (s[F_PUSH] - 1) & 0xFF
		if s[F_PUSH] == 0:
			s[F_STATE] += 1
	_fly_3a(n, s)                                      # $B21F


## $B22B -- one frame to set the count for the spitting.
func _hold_3a(n: int, s: PackedByteArray) -> void:
	s[F_PUSH] = 0x10
	s[F_STATE] += 1                                    # $C966
	_fly_3a(n, s)                                      # $B21F


## $B232 -- it opens up and lets two young go on the eighth frame.
func _spit_3a(n: int, s: PackedByteArray) -> void:
	_swim_3a(n, s)                                     # $B222
	var done: bool = (s[F_XHI] | s[F_YHI]) != 0        # $C9C3
	if not done:
		s[F_PUSH] = (s[F_PUSH] - 1) & 0xFF
		done = s[F_PUSH] == 0
	if not done:
		if s[F_PUSH] == 0x08:                          # $B23F
			_young_3a(s)                               # $B3C3
		s[F_KIND] = 0x98 if s[F_PUSH] >= 0x08 else 0x99
		return
	start_anim(s, 0x22)                                # $BEAD 22
	s[F_PUSH] = 0x50                                   # $BE91 50
	s[F_STATE] += 1                                    # $C966


## $B263 -- one frame of taking aim.  It leans toward him, backs off if it has
## come too far from home, and picks the dive by how far down he is.
func _aim_dive_3a(n: int, s: PackedByteArray) -> void:
	start_anim(s, 0x23)                                # $BEAD 23
	s[F_PUSH] = 0x50                                   # $BE91 50
	var side: Array = hero_side(s)                     # $C93C
	if bool(side[2]) or int(side[0]) >= 0x30:          # $B26E, $B272
		set_speed_side_at_hero(s, 0xFE, 0x00)          # $BEBF 00 FE
	else:
		s[F_BITS] = 0x00 if s[F_X] >= 0x80 else 0x40   # $B276
		set_speed_side_facing(s, 0xFE, 0x00)           # $BEC5 00 FE
	if strayed_far(s):                                 # $ACD0
		set_speed_side_facing(s, 0xFF, 0x80)           # $BEC5 80 FF
		flip_speed_side(s)                             # $C91E
	var y := 8
	if (s[F_GROUND] & 0x02) == 0:                      # $B29A
		var a: int = s[F_Y]
		if s[F_YHI] != 0:                              # $B2AB
			a = 0x00 if s[F_YHI] >= 0x80 else 0xFF
		y = (a & 0xE0) >> 5
	s[F_ANG] = DIVE_PULL_3A[y]                         # $B2BD
	set_speed_down(s, DIVE_3A[y][0], DIVE_3A[y][1])    # $C909
	mover(n, s, 0)                                     # $B371
	s[F_STATE] += 1                                    # $C966


## $B2F0 -- the dive.  The weight eats into it every frame and the fall is
## held to two lines; a wall or too long a way from home turns it back.
func _dive_3a(n: int, s: PackedByteArray) -> void:
	s[F_PUSH] = (s[F_PUSH] - 1) & 0xFF
	if s[F_PUSH] == 0:
		_dive_end_3a(s)                                # $B355
		return
	sub_speed_down(s, s[F_ANG])                        # $C90F
	if s[F_VY] >= 0x80 and s[F_VY] < 0xFE:             # $B2FB, $B300
		set_speed_down(s, 0xFE, 0x00)                  # $BEB9 00 FE
	if s[F_YHI] >= 0x80 and s[F_VY] >= 0x80:           # $B309, $B30E
		_dive_end_3a(s)
		return
	# $B31A -- here the cartridge does a TYA on a Y that nothing in the object
	# loop ever sets: $CA0B hands the old one back and $FAB3 does not touch
	# it.  Sampled on the real machine over three areas and seven hundred and
	# sixty-two turns it was nought every time, so the nudge across that hangs
	# off it never happens and is left out.
	var back: bool = (s[F_GROUND] & 0xC0) != 0         # $B330
	if not back and strayed_far(s):                    # $ACD0
		back = true
		if s[F_PUSH] >= 0x20:                          # $B33C
			s[F_PUSH] = 0x20                           # $BE91 20
	if back:
		set_speed_side_facing(s, 0xFF, 0xE0)           # $BEC5 E0 FF
		flip_speed_side(s)                             # $C91E
	step_anim(s)                                       # $C837
	mover(n, s, 0)                                     # $B371


## $B355 -- the dive is over and it goes back to drifting.
func _dive_end_3a(s: PackedByteArray) -> void:
	start_anim(s, 0x22)                                # $BEAD 22
	s[F_PUSH] = 0x18                                   # $BE91 18
	s[F_STATE] = 1                                     # $C96F
	if s[F_VX] >= 0x80:                                # $B360
		set_speed_side(s, 0xFF, 0xC0)                  # $BEB3 C0 FF
	else:
		set_speed_side(s, 0x00, 0x40)                  # $BEB3 40 00


## $B376 -- the swim.  $05E4 runs up for ever; its low five bits walk the
## table there and back, and its sixty-fourth bit turns the sign over.
func _wobble_3a(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] + 1) & 0xFF
	var c: int = s[F_COUNT]
	var i: int = c & 0x1F
	if (c & 0x20) != 0:                                # $B382
		i = (~i) & 0x1F                                # $B386
	var v: int = WOBBLE_3A[i]
	if (((c + 0x20) & 0xFF) & 0x40) != 0:              # $B390
		v = (-v) & 0xFF                                # $C858
	set_speed_down(s, v, 0x00)                         # $C909


## $B3C3 -- the two young, one turning each way.
func _young_3a(s: PackedByteArray) -> void:
	var first: int = 2 if (s[F_BITS] & 0x40) != 0 else 0   # $C990
	_young_one_3a(s, 0x00, first)
	_young_one_3a(s, 0xFF, first + 1)                  # $B3D3


## $B3D7 -- and one of them.  $00 says which way it circles, $01 which angle
## it starts from.
func _young_one_3a(s: PackedByteArray, tag: int, i: int) -> void:
	var c: int = make_child(s, 0x00, 0x00, 0x3B)       # $C8DF
	if c < 0:
		return
	var y: PackedByteArray = slots[c]
	y[F_KEEP2] = 0x0A if (tag & 0x80) == 0 else 0xF6   # $B3E6
	y[F_KEEP] = (0x14 + (tag & 0x01)) & 0xFF           # $B3F1
	y[F_COUNT] = YOUNG_3A[i]                           # $B3FD
	y[F_SELF] = YOUNG_3A[i]


## $B477 and $B47F -- the young's look and which way round it is drawn, by
## which eighth of the turn it points.
const KIND_3B := [0x9C, 0x9D, 0x9E, 0x9D, 0x9C, 0x9B, 0x9A, 0x9B]
const BITS_3B := [0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40]


## $B40D (bank 11) -- the young of the swimmer: it curls round toward him,
## keeping a little to one side, and bursts on the first wall it meets.
func _mind_3b(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:                                  # $C97E
		0: _wake_3b(s)
		1: _curl_3b(n, s)
		2: _burst_3b(n, s)


## $B416 -- two lives and a long life of its own.
func _wake_3b(s: PackedByteArray) -> void:
	s[F_LIFE] = 0x02                                   # $BE5A 02
	s[F_MARK] = 0x01
	s[F_PUSH] = 0xFF                                   # $BE91 FF
	_aim_3b(s)                                         # $B455
	s[F_STATE] += 1                                    # $C966


## $B424 -- the curl.  $FF00 turns it two at a time toward a point ten across
## from him, and whenever the angle has moved the speed is laid down afresh.
func _curl_3b(n: int, s: PackedByteArray) -> void:
	if s[F_PUSH] != 0:
		s[F_PUSH] = (s[F_PUSH] - 1) & 0xFF
		var was: int = s[F_SELF]
		aim_clock(s, 0x06, s[F_KEEP2])                 # $C9C6
		if s[F_SELF] != was:                           # $B439
			_aim_3b(s)
	_wall_3b(n, s)                                     # $B487
	mark_target(n)                                     # $C9D2
	step_both(s)                                       # $C8F1


## $B44A -- the burst, which lasts as long as its picture.
func _burst_3b(n: int, s: PackedByteArray) -> void:
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] != 0:
		step_anim(s)                                   # $C837
	else:
		clear(n)                                      # $C810


## $B455 -- lay the speed along the angle, and pick the look to match.
func _aim_3b(s: PackedByteArray) -> void:
	set_speed_at(s, 0x0C, s[F_SELF])                   # $C8AF
	var i: int = ((s[F_SELF] + 0x10) >> 5) & 0x07      # $B45D
	s[F_KIND] = KIND_3B[i]
	s[F_BITS] = BITS_3B[i]


## $B487 -- a wall under its nose ends it.
func _wall_3b(n: int, s: PackedByteArray) -> void:
	if ground_turn_clear(n, s, 0x00, 0x00) < 0x80:     # $BECB 00 00
		return
	start_anim(s, 0x01)                                # $BEAD 01
	s[F_SELF] = 0x10                                   # $BE75 10
	s[F_TYPE] = 0x3B
	s[F_STATE] = 2                                     # $C972


## $B914 -- the nine pictures, three to a pose: leaning back, straight on,
## leaning forward.
const LOOK_40 := [0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30]
## $B979 -- what it does when it fires, by which way it looks and whether he
## is above it: the pose to hold, the angle, and where the shot comes out.
const SHOT_40 := [[0x02, 0x60, 0xF6, 0xEA], [0x01, 0xA0, 0xF6, 0xCC],
		[0x02, 0x20, 0x0A, 0xEA], [0x01, 0xE0, 0x0A, 0xCC]]


## $B7AD (bank 11) -- the hovering gunner.  It keeps station beside him, holds
## itself at the line $68 of the screen when he is close, and fires down the
## angle it happens to be leaning at.
func _mind_40(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:                                # $B7AD
		record_home_along(s)                           # $C9B1
		s[F_LIFE] = 0x08                               # $BE5A 08
		s[F_MARK] = 0x01
		start_anim(s, 0x2A)                            # $BEAD 2A
		s[F_REC_BYTE] = 0x40                           # $BE9F 40
		_steer_40(s)                                   # $B7FA
		s[F_STATE] += 1                                # $C966
		return
	face_hero(s)                                       # $C8FD
	_steer_40(s)                                       # $B7FA
	_climb_40(s)                                       # $B8A7
	mover(n, s, 2)                                     # $BCBB with two
	if s[F_ANG] == 0:                                  # $B7D5
		s[F_PUSH] = 0x00
	else:
		s[F_ANG] = (s[F_ANG] - 1) & 0xFF
		if s[F_ANG] == 0:
			s[F_PUSH] = 0x00                           # $B7DF
	if s[F_ANG] == 0:                                  # $B7E4
		s[F_REC_BYTE] = (s[F_REC_BYTE] - 1) & 0xFF
		if s[F_REC_BYTE] == 0:
			_shoot_40(s)                               # $B91D
	s[F_ANIM] = _look_40(s)                            # $B8E1
	step_anim(s)                                       # $C837


## $B7FA -- which way to lean.  $05E4 is a rest it takes after every change of
## mind, $05CE the way it settled on.
func _steer_40(s: PackedByteArray) -> void:
	if s[F_COUNT] != 0:                                # $B7FA
		s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF           # $B865
		_push_40(s, s[F_SELF] >= 0x80)                 # $B868
		return
	if strayed_far(s):                                 # $ACD0
		s[F_SELF] = 0x00 if s[F_VX] >= 0x80 else 0x80  # $B80F
		_halt_40(s)                                    # $B834
		return
	var wall: int = s[F_GROUND] & 0xC0                 # $B804
	var sd: Array = hero_side(s)                       # $C93C
	if wall != 0:
		s[F_SELF] = 0x00 if (wall & 0x80) != 0 else 0x80
		if bool(sd[2]) or int(sd[0]) < 0x30:           # $B82C, $B82F
			_halt_40(s)
			return
		var go: int = _band_40(s, int(sd[0]), bool(sd[1]))
		if go >= 0:
			_push_40(s, go == 1)
		return
	# $B840 -- nothing in the way.
	var go2: int
	if bool(sd[2]):                                    # $B843
		go2 = 1 if bool(sd[1]) else 0
	elif int(sd[0]) < 0x50:                            # $B846
		# $B85C turns the kept carry over: this close it backs off instead.
		go2 = 0 if bool(sd[1]) else 1
	else:
		go2 = _band_40(s, int(sd[0]), bool(sd[1]))
	if go2 >= 0:
		_push_40(s, go2 == 1)


## $B84A -- the middle band.  Past $60 it simply leans his way; between $50
## and $60 it does so only when he is above it, and holds that lean for forty
## frames.  A -1 means it leaves the lean it had.
func _band_40(s: PackedByteArray, far: int, past_him: bool) -> int:
	if far >= 0x60:                                    # $B84A
		return 1 if past_him else 0
	var d: Array = hero_down(s)                        # $C93F
	if not bool(d[1]):                                 # $B851
		return -1
	s[F_COUNT] = 0x28                                  # $BE7C 28
	return 1 if past_him else 0


## $B834 -- it stops dead and thinks again in sixty frames.
func _halt_40(s: PackedByteArray) -> void:
	set_speed_side(s, 0x00, 0x00)                      # $BEB3 00 00
	s[F_COUNT] = 0x3C                                  # $BE7C 3C
	_push_40(s, s[F_SELF] >= 0x80)                     # $B868


## $B86D and $B88A -- the lean itself.  The push is a thirty-second of a line
## when it already goes that way and a sixteenth when it must turn round
## first, and two lines a frame is as fast as it may go.
func _push_40(s: PackedByteArray, left: bool) -> void:
	if left:
		s[F_SELF] = 0x80                               # $B88A
		sub_speed_side(s, 0x08 if s[F_VX] >= 0x80 else 0x10)
		if s[F_VX] >= 0x80 and s[F_VX] < 0xFE:         # $B89B, $B89D
			set_speed_side(s, 0xFE, 0x00)              # $BEB3 00 FE
		return
	s[F_SELF] = 0x00                                   # $B86D
	add_speed_side(s, 0x08 if s[F_VX] < 0x80 else 0x10)
	if s[F_VX] < 0x80 and s[F_VX] >= 0x02:             # $B87E, $B880
		set_speed_side(s, 0x02, 0x00)                  # $BEB3 00 02


## $B8A7 -- how it holds its height.  Far off it makes for him; close up it
## makes for the line $68 instead, so that it comes to rest above his head.
func _climb_40(s: PackedByteArray) -> void:
	var d: Array = hero_down(s)                        # $C93F
	var up: bool
	if bool(d[2]) or int(d[0]) >= 0x40:                # $B8AB, $B8AD
		up = bool(d[1])
	else:
		up = slots[0][F_Y] >= 0x68                     # $B8B6
	if up:
		sub_speed_down(s, 0x10)                        # $C90F
	else:
		add_speed_down(s, 0x10)                        # $C90C
	if s[F_VY] < 0x80:                                 # $B8C8
		if s[F_VY] >= 0x02:
			set_speed_down(s, 0x02, 0x00)              # $BEB9 00 02
	elif s[F_VY] < 0xFE:                               # $B8D7
		set_speed_down(s, 0xFE, 0x00)                  # $BEB9 00 FE


## $B8E1 -- which of the nine pictures to show: the pose it holds, and within
## that whether it leans back, stands straight or leans forward.
func _look_40(s: PackedByteArray) -> int:
	var y: int = (s[F_PUSH] * 3) & 0xFF                # $B8E1
	var lean := 2                                      # $B90E
	if (s[F_VX] | s[F_VXFR]) != 0 and (s[F_GROUND] & 0xC0) == 0:
		if (s[F_BITS] & 0x40) != 0:                    # $C990
			if s[F_VX] >= 0x80:                        # $B908
				lean = 1
			elif s[F_VX] == 0x02:                      # $B90A
				lean = 0
		elif s[F_VX] < 0x80:                           # $B900
			lean = 1
		elif s[F_VX] == 0xFE:                          # $B902
			lean = 0
	return LOOK_40[y + lean]


## $B91D -- the shot.  With no room for a child it drops the pose and tries
## again in seventeen frames; with one it holds the pose for forty-eight and
## waits a hundred and twenty-eight before the next.
func _shoot_40(s: PackedByteArray) -> void:
	var i := 0                                         # $B925
	if (s[F_BITS] & 0x40) != 0:                        # $C990
		i = 2
	var d: Array = hero_down(s)                        # $C93F
	if bool(d[1]):                                     # $B931
		i += 1
	var r: Array = SHOT_40[i]
	s[F_PUSH] = r[0]                                   # $B937
	var c: int = make_child_aimed(s, r[2], r[3], 0x41, 0x10, r[1])
	if c < 0:                                          # $B94E
		s[F_PUSH] = 0x00                               # $BE91 00
		s[F_REC_BYTE] = 0x11                           # $BE9F 11
		return
	slots[c][F_SELF] = r[1]                            # $B954
	start_anim(s, _look_40(s))                         # $B957, $C83A
	s[F_ANG] = 0x30                                    # $BE98 30
	s[F_REC_BYTE] = 0x80                               # $BE9F 80
	set_speed_side(s, 0x00, 0x00)                      # $BEB3 00 00
	set_speed_down(s, 0x00, 0x00)                      # $BEB9 00 00


## $BA07 and $BA0B -- where the burst is put out, by the quarter of the turn
## the shot points into; $BA72 and $BA7A the two corners it feels for when it
## bounces, and $BA82 the angle it takes from each; $BA9E which way round it
## is drawn; $BAB1 and $BAB5 what sits right in front of its nose.
const BORN_41_DOWN := [0x10, 0x10, 0xFE, 0xFE]
const BORN_41_SIDE := [0x08, 0xF7, 0xF7, 0x08]
const FEEL_41_DOWN := [0xF7, 0xF7, 0x08, 0x08, 0x08, 0x08, 0xF7, 0xF7]
const FEEL_41_SIDE := [0x08, 0xF7, 0xF7, 0x08, 0xF7, 0x08, 0x08, 0xF7]
const TURN_41 := [0xE0, 0xA0, 0x60, 0x20, 0x60, 0x20, 0xE0, 0xA0]
const BITS_41 := [0x00, 0x40, 0x00, 0x40]
const NOSE_41_DOWN := [0x08, 0x08, 0xF7, 0xF7]
const NOSE_41_SIDE := [0x08, 0xF7, 0xF7, 0x08]


## $B9A4 (bank 11) -- what the hovering gunner fires.  It goes flat out along
## one of the four slants, bursts on the first wall, and comes off it again
## along the slant the table names.  $C9D2 at its head marks its bit in $0117,
## the drawing's own book, which is not kept here.
func _mind_41(n: int, s: PackedByteArray) -> void:
	mark_target(n)                                     # $C9D2
	match s[F_STATE]:                                  # $C97E
		0: _wake_41(n, s)
		1: _fly_41(n, s)
		2: _burst_41(n, s)
		3: _bounce_41(n, s)


## $B9B2 -- it comes to itself on its own frame, and not at all if it was born
## inside a wall.
func _wake_41(n: int, s: PackedByteArray) -> void:
	if not its_turn(n, clock):                         # $BE3E
		return
	if _nose_41(n, s) >= 0x80:                         # $BAA2
		clear(n)                                       # $C810
		return
	s[F_LIFE] = 0xFF                                   # $BE5A FF
	s[F_MARK] = 0x01
	s[F_KEEP] = 0xC8                                   # $BE83 C8
	_look_41(s)                                        # $BA94
	_glow_41(s)                                        # $BAB9
	Pb2Sound.want(0x2A)                                # $B9CC -- it is fired
	s[F_STATE] += 1                                    # $C966


## $B9D6 -- flying.  Two hundred frames of life run down while it goes; the
## wall its nose meets makes the burst.
func _fly_41(n: int, s: PackedByteArray) -> void:
	_glow_41(s)                                        # $BAB9
	step_both(s)                                       # $C8F1
	if _nose_41(n, s) < 0x80:                          # $BAA2
		if s[F_KEEP] != 0:                             # $B9E1
			s[F_KEEP] = (s[F_KEEP] - 1) & 0xFF
		return
	var q: int = _quarter_41(s)                        # $BA8A
	if make_child(s, BORN_41_SIDE[q], BORN_41_DOWN[q], 0x43) < 0:
		clear(n)                                       # $B9FD
		return
	Pb2Sound.want(0x1E)                                # $BA01 -- and bursts
	s[F_STATE] += 1                                    # $C966


## $BA0F -- it carries on into the wall until the ground says so.  With life
## still on it, it bounces; run out, it goes.
func _burst_41(n: int, s: PackedByteArray) -> void:
	step_both(s)                                       # $C8F1
	if ground_turn_clear(n, s, 0x00, 0x00) < 0x80:     # $BECB 00 00
		return
	if s[F_KEEP] == 0:                                 # $BA1A
		clear(n)                                       # $C810
		return
	s[F_COUNT] = 0x00                                  # $BE7C 00
	s[F_KEEP2] = 0x03                                  # $BE8A 03
	_glow_41(s)                                        # $BAB9
	s[F_STATE] += 1                                    # $C966


## $BA2D -- the bounce.  It feels one corner, and if that is blocked too it
## tries the other four entries along; blocked both ways it simply turns back
## the way it came.
func _bounce_41(n: int, s: PackedByteArray) -> void:
	if not its_turn(n, clock):                         # $BE3E
		return
	var i: int = (_quarter_41(s) + s[F_COUNT]) & 0xFF  # $BA35
	if ground_turn_clear(n, s, FEEL_41_SIDE[i], FEEL_41_DOWN[i]) >= 0x80:
		if s[F_COUNT] == 0x04:                         # $BA61
			_turn_41(s, s[F_SELF] ^ 0x80)              # $BA6A
			return
		s[F_COUNT] = 0x04                              # $BE7C 04
		return
	_turn_41(s, TURN_41[i])                            # $BA4C


## $BA4F -- take the new angle and set off along it again.
func _turn_41(s: PackedByteArray, ang: int) -> void:
	s[F_SELF] = ang
	set_speed_at(s, 0x10, ang)                         # $C8AF
	_look_41(s)                                        # $BA94
	s[F_STATE] = 1                                     # $C96F


## $BA8A -- which quarter of the turn it points into.  The cartridge rolls the
## angle three times through the carry and keeps two bits, which comes to the
## top two bits of the angle whatever the carry happened to be.
func _quarter_41(s: PackedByteArray) -> int:
	return (s[F_SELF] >> 6) & 0x03


## $BA94 -- which way round it is drawn.
func _look_41(s: PackedByteArray) -> void:
	s[F_BITS] = BITS_41[_quarter_41(s)]


## $BAA2 -- what is right in front of its nose.
func _nose_41(n: int, s: PackedByteArray) -> int:
	var q: int = _quarter_41(s)
	return ground_turn_clear(n, s, NOSE_41_SIDE[q], NOSE_41_DOWN[q])


## $BAB9 -- for its first three frames it is not drawn at all, so that it does
## not flash inside the thing that fired it.
func _glow_41(s: PackedByteArray) -> void:
	if s[F_KEEP2] != 0:
		s[F_KEEP2] = (s[F_KEEP2] - 1) & 0xFF
		s[F_KIND] = 0x00                               # $BE6E 00
		return
	s[F_KIND] = 0x83                                   # $BE6E 83


## $B989 (bank 11) -- the burst that shot leaves on the wall.  The waking
## state falls straight on into the counting one.
func _mind_43(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:                                # $B989
		start_anim(s, 0x31)                            # $BEAD 31
		s[F_SELF] = 0x0E                               # $BE75 0E
		s[F_STATE] += 1                                # $C966
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF                 # $B999
	if s[F_SELF] == 0:
		clear(n)                                       # $C810
	else:
		step_anim(s)                                   # $C837


## --- Цепь ($36 с детьми $34 и $35, банк 11) --------------------------------
##
## Голова ($36) сидит там, где её положил обход уровня, и родит пять звеньев.
## Каждое звено помнит соседа ближе к голове (F_KEEP2) и соседа дальше
## (F_ANG), а голова помнит хвост -- последнее звено -- в своём F_KEEP2 и
## держит в F_PUSH и F_ANG набор битов: по одному на каждое занятое место,
## младший бит F_PUSH -- место шесть.
##
## Ход звена ($AE17) раз в четыре хода: встать туда, где стоит сосед ближе к
## голове, взять его же длину (F_REC_BYTE) и отойти от него на эту длину под
## своим углом (F_SELF).  Длина растёт от головы: пока голова тянется, её
## F_REC_BYTE ползёт вниз по цепи по звену за раз, и цепь вытягивается волной.

const TYPE_36 := [0x34, 0x35, 0x35, 0x35, 0x35]
const MASK_36 := [0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80]
const DEATH_36 := [0x01, 0x0B, 0x15, 0x1F, 0x29]
const HOLD_35 := [0x00, 0x08, 0x09, 0x0A, 0x0B]
const CLAMP_34 := [0x84, 0x84, 0xFC, 0x04, 0x7C, 0x04]


## $AE8D -- голова.
func _mind_36(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _born_36(n, s)
		1: _reach_36(n, s)
		2: _fade_worm(n, s)


## $AE9A -- построить цепь.  Пока голова за краем или слишком низко, ничего.
func _born_36(n: int, s: PackedByteArray) -> void:
	if (s[F_XHI] | s[F_YHI]) != 0:                     # $C9C3
		clear(n)                                       # $C810
		return
	if s[F_Y] >= 0xC0:                                 # $AEA2
		return
	if s[F_LIFE] != 0xFF:                              # $AEA9
		s[F_GROUND] = s[F_LIFE]
	s[F_LIFE] = 0xFF                                   # $BE5A
	s[F_MARK] = 0x01
	s[F_KIND] = 0x6D                                   # $BE6E
	s[F_REC_BYTE] = 0x00                               # $BE9F
	var ang: int = 0x40 if s[F_GROUND] != 0 else 0xC0  # $AEC6
	var prev: int = n
	var low := 0
	var high := 0
	for i in range(4, -1, -1):                         # $04 = 4 .. 0
		var c: int = free_slot_wide()                  # $C942
		if c < 0:                                      # $AF46
			_hold_mask_36(s, low, high)
			_sweep_36(s)
			clear(n)
			return
		var b: PackedByteArray = slots[c]
		b[F_SELF] = ang                                # $AEDC
		b[F_COUNT] = ang
		b[F_KEEP] = (b[F_KEEP] + 1) & 0xFF             # $AEE2
		b[F_KEEP2] = prev                              # $AEE7
		var p: PackedByteArray = slots[prev]
		p[F_ANG] = c                                   # $AEEC
		slots[prev] = p
		prev = c
		b[F_REC_BYTE] = 0x00                           # $BE9F
		b[F_GROUND] = s[F_GROUND]                      # $AEF7
		b[F_PUSH] = i                                  # $AEFF
		b[F_TYPE] = TYPE_36[i]                         # $AF03
		b[F_LIFE] = 0xFF                               # $BE5A
		b[F_MARK] = 0x01
		slots[c] = b
		_link_step_place(c)                            # $AE2C
		var bit: int = MASK_36[(c - 0x06) & 0x07]      # $AF10
		if c >= 0x0E:
			high |= bit
		else:
			low |= bit
	s[F_KEEP2] = prev                                  # $AF30
	_hold_mask_36(s, low, high)                        # $AF39
	s[F_STATE] = 1                                     # $C966


## $AF39 -- набор битов ложится в два поля головы.
func _hold_mask_36(s: PackedByteArray, low: int, high: int) -> void:
	s[F_PUSH] = low
	s[F_ANG] = high


## $AF5C -- голова тянется и убирается.  Хвост -- последнее звено -- она
## помнит в F_KEEP2; по его жизни она и решает, не пора ли умирать.
func _reach_36(n: int, s: PackedByteArray) -> void:
	var tail: int = s[F_KEEP2]
	var t: PackedByteArray = slots[tail]
	if t[F_LIFE] < 0x76:                               # $AF62
		_die_36(s)
		return
	var off: bool = (s[F_XHI] | s[F_YHI]) != 0         # $C9C3
	var tail_gone: bool = ((t[F_YHI] | t[F_XHI]) != 0
			or t[F_Y] >= 0xC0)
	if off:                                            # $AF83
		if tail_gone:
			_sweep_36(s)                               # $AFAD
			clear(n)
			return
		_pull_36(s)
		return
	if s[F_Y] < 0xC0:                                  # $AF6E
		_push_36(s)                                    # $AF9D
		return
	if tail_gone:                                      # $AF72
		_sweep_36(s)                                   # $AFB3
		s[F_STATE] = (s[F_STATE] - 1) & 0xFF           # $C969
		return
	_pull_36(s)


## $AF92 -- короче на один.
func _pull_36(s: PackedByteArray) -> void:
	if s[F_REC_BYTE] >= 0x01:
		s[F_REC_BYTE] -= 1


## $AF9D -- длиннее на два, но не дальше $70.
func _push_36(s: PackedByteArray) -> void:
	var a: int = s[F_REC_BYTE] + 0x02
	if a >= 0x71:
		a = 0x70
	s[F_REC_BYTE] = a


## $AFB9 -- умирать всей цепью: каждому звену свой срок по его месту в ней,
## голове -- самый долгий.  Набор битов при этом вычитывается досуха.
func _die_36(s: PackedByteArray) -> void:
	for k in _mask_slots_36(s):
		var b: PackedByteArray = slots[k]
		b[F_REC_BYTE] = DEATH_36[b[F_PUSH]]            # $AFD2
		b[F_STATE] = 2                                 # $C972
		slots[k] = b
	s[F_REC_BYTE] = 0x33                               # $BE9F
	s[F_STATE] = 2                                     # $C972


## $AFEF -- убрать всё, что в наборе.
func _sweep_36(s: PackedByteArray) -> void:
	for k in _mask_slots_36(s):
		clear(k)                                       # $C810


## Шестнадцать сдвигов вправо через перенос: F_ANG -- старшая половина набора,
## F_PUSH -- младшая, и первым выходит место шесть.
func _mask_slots_36(s: PackedByteArray) -> Array:
	var out: Array = []
	for i in range(0x10):
		var carry: int = s[F_PUSH] & 0x01
		s[F_PUSH] = (s[F_PUSH] >> 1) | ((s[F_ANG] & 0x01) << 7)
		s[F_ANG] = s[F_ANG] >> 1
		if carry != 0:
			out.append(0x06 + i)
	return out


## $AE75 -- общий третий ход всех трёх: досчитать до нуля и лопнуть.  Хвосту
## ($34) вдобавок гасят F_KEEP, что $FEAA только что поднял.
func _fade_worm(n: int, s: PackedByteArray) -> void:
	s[F_REC_BYTE] = (s[F_REC_BYTE] - 1) & 0xFF
	if s[F_REC_BYTE] != 0:
		return
	var was: int = s[F_TYPE]
	make_burst(n)                                      # $C9C0
	if was == 0x34:
		var b: PackedByteArray = slots[n]
		b[F_KEEP] = 0x00                               # $BE83
		slots[n] = b


## $AD64 -- звено.
func _mind_35(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _wake_35(s)
		1: _swing_35(n, s)
		2: _fade_worm(n, s)


func _wake_35(s: PackedByteArray) -> void:
	s[F_KIND] = 0x6D                                   # $BE6E
	s[F_STATE] = 1                                     # $C966


## $AD74 -- взять угол у соседа дальше по цепи и потянуться за ним.
func _swing_35(n: int, s: PackedByteArray) -> void:
	_follow_35(s)                                      # $AE56
	_link_step(n, s)                                   # $AE17


## $AE56 -- ждать свой срок, и по нему списать угол соседа (F_ANG).  Срок тем
## длиннее, чем ближе звено к голове.
func _follow_35(s: PackedByteArray) -> void:
	s[F_KEEP] = (s[F_KEEP] - 1) & 0xFF
	if s[F_KEEP] == 0:
		s[F_KEEP] = HOLD_35[s[F_PUSH]]                 # $AE5E
		s[F_COUNT] = slots[s[F_ANG]][F_SELF]           # $AE67
	aim_turn(s)                                        # $C9C9


## $AE17 -- ход звена, раз в четыре хода.
func _link_step(n: int, s: PackedByteArray) -> void:
	if ((n ^ clock) & 0x03) != 0:                      # $AE18
		return
	_link_step_place(n)                                # $AE2C
	set_speed_at(s, s[F_REC_BYTE], s[F_SELF])          # $C8AF
	step_both(s)                                       # $C8F1


## $AE2C -- встать туда, где стоит сосед ближе к голове, и взять его длину.
func _link_step_place(n: int) -> void:
	var s: PackedByteArray = slots[n]
	var p: PackedByteArray = slots[s[F_KEEP2]]
	s[F_YHI] = p[F_YHI]
	s[F_Y] = p[F_Y]
	s[F_XHI] = p[F_XHI]
	s[F_X] = p[F_X]
	s[F_XFR] = 0x00                                    # $AE47
	s[F_YFR] = 0x00
	s[F_REC_BYTE] = p[F_REC_BYTE]                      # $AE4F
	slots[n] = s


## $AD7A -- хвост: тот, что стреляет и по чьей жизни умирает вся цепь.
func _mind_34(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _wake_34(s)
		1: _aim_34(n, s)
		2: _fade_worm(n, s)


func _wake_34(s: PackedByteArray) -> void:
	s[F_KIND] = 0x6C                                   # $BE6E
	s[F_LIFE] = 0x7F                                   # $BE63
	s[F_HOLD] = 0x90                                   # $AD8B
	s[F_STATE] = 1                                     # $C966


## $AD93 -- пока хвост на виду, угол берётся по младшим байтам ($C9C6); за
## краем -- по обоим ($C9CC), и реже.
func _aim_34(n: int, s: PackedByteArray) -> void:
	if (s[F_XHI] | s[F_YHI]) == 0:                     # $C9C3
		aim_clock(s, 0x11, 0x00)                       # $C9C6
	else:
		s[F_KEEP] = (s[F_KEEP] - 1) & 0xFF             # $ADA2
		if s[F_KEEP] == 0:
			s[F_KEEP] = 0x11                           # $BE83
			s[F_COUNT] = aim_at_hero_wide(s)           # $C9CC
		aim_turn(s)                                    # $C9C9
	# $ADB4 -- и загнать угол в тот сектор, что цепи позволен.
	var i: int = 0x03 if s[F_GROUND] != 0 else 0x00
	if ((s[F_COUNT] - CLAMP_34[i]) & 0xFF) >= 0x78:    # $ADC1
		i += 1
		if not hero_is_left(s):                        # $C8FA
			i += 1
		s[F_COUNT] = CLAMP_34[i]
	_link_step(n, s)                                   # $AE17
	face_by_speed(s)                                   # $C993
	s[F_HOLD] = (s[F_HOLD] - 1) & 0xFF
	if s[F_HOLD] == 0:                                 # $ADF0
		s[F_HOLD] = 0xFF
		var m: int = _muzzle_34(s)
		make_child_at_hero(s, m, 0x00, 0x14, 0x0C)     # $C8E2
		return
	if s[F_HOLD] == 0x50:                              # $ADE3
		_spit_34(s)


## $AE0A -- откуда выходит выстрел: десять точек в ту сторону, куда смотрит.
func _muzzle_34(s: PackedByteArray) -> int:
	return 0x0A if (s[F_BITS] & 0x40) != 0 else 0xF6   # $C990


## $9055 (банк 10) -- бросить хватку ($21), но только если хвост на виду,
## смотрит на него и он не ближе $28 и не дальше $50 вбок.
func _spit_34(s: PackedByteArray) -> void:
	if (s[F_XHI] | s[F_YHI]) != 0:                     # $C9C3
		return
	var look: Array = facing_hero(s)                   # $C98D
	if not look[0]:
		return
	if look[1] >= 0x50 or look[1] < 0x28:              # $9063
		return
	var c: int = make_child(s, _muzzle_34(s), 0x00, 0x21)
	if c < 0:                                          # $9076
		return
	var b: PackedByteArray = slots[c]
	set_speed_reach(b, 0x40, 0xFE)                     # $C9CF
	slots[c] = b
	Pb2Sound.want(0x38)                                # $9087 -- он бросил


## $8BD8 -- то, что хвост цепи кидает в него: одна картинка и прямой полёт,
## пока не упрётся.
func _mind_14(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_MARK] = 0x02                               # $C9A2
		s[F_KIND] = 0x2A                               # $BE6E
		s[F_STATE] = 1                                 # $C966
		return
	mark_target(n)                                     # $C9D2
	ground_or_die(n, s)                                # $C8EB


## $908E (банк 10) -- хватка: летит по дуге, ложится на землю и держит его,
## пока не выйдет её срок.
func _mind_21(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _wake_21(s)
		1: _fly_21(n, s)
		2: _hold_21(n, s)


func _wake_21(s: PackedByteArray) -> void:
	s[F_LIFE] = 0xFF                                   # $BE5A
	s[F_MARK] = 0x01
	s[F_KIND] = 0x6E                                   # $BE6E
	face_by_speed(s)                                   # $C993
	s[F_STATE] = 1                                     # $C966


## $90A5 -- падать не быстрее четырёх точек за ход; упёрлась низом -- лечь.
func _fly_21(n: int, s: PackedByteArray) -> void:
	add_speed_down(s, 0x10)                            # $C90C
	if s[F_VY] < 0x80:
		if s[F_VY] >= 0x04:                            # $90AF
			set_speed_down(s, 0x04, 0x00)              # $BEB9
		if ground_turn_clear(n, s, 0x00, 0x04) >= 0x80:
			_land_21(s)                                # $90D6
			return
	else:
		if ground_turn_clear(n, s, 0x00, 0xFC) >= 0x80:
			set_speed_down(s, 0x00, 0x00)              # $BEB9
	_slide_21(n, s)                                    # $90FC
	mark_target(n)                                     # $C9D2
	step_down(s)                                       # $C8F4


func _land_21(s: PackedByteArray) -> void:
	snap_down(s)                                       # $C981
	s[F_MARK] = 0x80                                   # $C9AB
	s[F_KIND] = (s[F_KIND] + 1) & 0xFF                 # $90DC
	s[F_STATE] = 2                                     # $C966


## $90FC -- вбок, пока впереди нет стены; есть -- встать.
func _slide_21(n: int, s: PackedByteArray) -> void:
	if walled_ahead_turn(n, s, 0xF8, 0x01, 0xFF, 0x00) >= 0x80:
		set_speed_side(s, 0x00, 0x00)                  # $C906
		return
	step_side(s)                                       # $C8F7


## $90E2 -- лежит и держит.  Что пишется в героя ($05A2 без счёта -- его
## собственное поле), в проверке умов приходит из картриджа готовым; здесь оно
## записано как есть.
func _hold_21(n: int, s: PackedByteArray) -> void:
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] == 0:
		clear(n)                                       # $C810
		return
	ride(s, 0x08, 0xF8)                                # $BF20
	if held != 0:                                      # $90F1
		var h: PackedByteArray = slots[0]
		h[F_HOLD] = 0x80                               # $90F8
		slots[0] = h


## --- Площадка, что сама себе земля ($0F с напарником $47, банк 11) --------
##
## Она идёт по тем же дорожкам ($A22E и дальше), что и площадка на рельсе, и
## пользуется тем же счётом колен ($A15A и $A169).  Своего у неё две вещи.
##
## Первая: она родит напарника ($47) -- второй конец, что идёт по своей
## дорожке и стирает за собой то, что она за собой оставляет.
##
## Вторая: раз в $20 ходов она пишет прямо в местность ($C8AC ставит клетку в
## два, $C8A9 её гасит) и рисует поверх неё две плитки.  Ни то, ни другое не
## трогает полей вещей: движок читает местность из уровня, а не из своего
## запаса на $0680, и держать этот запас пока не умеет -- долг записан к Э3.4
## вместе с остальной ездой.  Из всего $A3D0 полю достаётся только F_ANG.

## $A333 -- пары: сколько ждать до хода и какая жизнь достанется напарнику.
## Второй байт пары -- это первый байт следующей, и картридж читает их двумя
## указателями, что стоят рядом ($A333 и $A334).
const START_0F := [0x70, 0x04, 0x70, 0x05, 0x70, 0x06, 0x73, 0x07,
		0x10, 0x08, 0x10, 0x09, 0x10, 0x0A, 0x10, 0x0B, 0x10, 0x0C,
		0x10, 0x0D, 0x00, 0x00, 0x50, 0x0F, 0x40, 0x10, 0xA0, 0x0F,
		0xA0, 0x10]


## $A309.
func _mind_0f(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _wake_0f(n, s)
		1: _hatch_0f(n, s)
		2: _run_0f(n, s)


## $A312 -- напарник входит в тот же ум со второго хода.
func _mind_47(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _hatch_0f(n, s)
		1: _run_0f(n, s)


## $A319 -- встать на восемь вбок и на одну вверх и отсчитать своё до старта;
## младшие три бита места разводят соседок по разным кадрам.
func _wake_0f(n: int, s: PackedByteArray) -> void:
	nudge_side(s, 0x00, 0x08)                          # $C936
	nudge_down(s, 0x00, 0xFF)                          # $C930
	s[F_SELF] = ((n & 0x07) + START_0F[s[F_LIFE]]) & 0xFF
	s[F_STATE] += 1                                    # $C966


## $A351 -- срок вышел: родить напарника, раздать обоим новую жизнь и взять
## первое колено дорожки.
func _hatch_0f(n: int, s: PackedByteArray) -> void:
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] != 0:
		return
	s[F_ANG] = 0x20                                    # $BE98
	if s[F_TYPE] != 0x47:                              # $A35B
		var c: int = make_child(s, 0x00, 0x00, 0x47)   # $C8DF
		if c < 0:
			clear(n)                                   # $A38A
			return
		var life: int = START_0F[s[F_LIFE] + 1]        # $A334
		s[F_LIFE] = life
		var b: PackedByteArray = slots[c]
		b[F_LIFE] = life
		b[F_SELF] = 0x61                               # $A37C
		slots[c] = b
	_rail_pick(s)                                      # $A15A
	_place_0f(s)                                       # $A3D0
	s[F_STATE] += 1                                    # $C966


## $A38D -- ход.  Дорожка, что вывернулась ($0610 со старшим битом), для этой
## площадки значит конец: она уходит.
func _run_0f(n: int, s: PackedByteArray) -> void:
	if s[F_KEEP2] >= 0x80:                             # $A390
		clear(n)                                       # $C810
		return
	# $A392 -- $0165 и $0166 держат звук на одну площадку в кадр; полей не
	# трогают.
	step_both(s)                                       # $C8F1
	s[F_PUSH] = (s[F_PUSH] - 1) & 0xFF                 # $A3AC
	if s[F_PUSH] == 0:
		s[F_KEEP] = (s[F_KEEP] + 1) & 0xFF             # $A3B1
		_rail_step_leg(s)                              # $A169
	if s[F_TYPE] == 0x0F:                              # $A3B7
		held = 0                                       # $0164
		ride_apply(s, 0x07, 0xF1)                      # $BF26
	s[F_ANG] = (s[F_ANG] - 1) & 0xFF                   # $A3CA
	if s[F_ANG] != 0:
		return
	_place_0f(s)                                       # $A3D0


## $A3D0 -- где стоит клетка, что площадка кладёт под себя, и куда она встанет
## в следующий раз.  Пятнадцать вверх и восемь влево от самой площадки; шаг --
## ровно клетка в ту сторону, куда площадка идёт.  Напарник свою клетку не
## переставляет: он гасит ту, что уже помнит.
func _place_0f(s: PackedByteArray) -> void:
	var y: int = (((s[F_YHI] << 8) | s[F_Y]) - 0x0F) & 0xFFFF
	var x: int = (((s[F_XHI] << 8) | s[F_X]) - 0x08) & 0xFFFF
	var here: bool = not _off_place(y, x)              # $A4F8
	if here and s[F_TYPE] != 0x0F:                     # $A3F7
		s[F_ANG] = 0x20                                # $A3FC
		ridden = [x & 0xFF, y & 0xFF]
		# $A3EB ($C8A9) и $A457 -- напарник гасит клетку и стирает её
		# четыре плитки.  На картридже это две записи, у нас одна.
		_paint_0f(x, y, [0x00, 0x00], [0x00, 0x00])
		return
	s[F_ANG] = 0x20                                    # $BE98
	if (s[F_VX] | s[F_VXFR]) == 0:                     # $A409
		var down: int = 0xF0 if s[F_VY] >= 0x80 else 0x10
		var lift: int = -1 if s[F_VY] >= 0x80 else 0
		y = (((s[F_YHI] + lift) << 8) + s[F_Y] + down) & 0xFFFF
		x = (s[F_XHI] << 8) | s[F_X]                   # $A4CD
	else:
		var side: int = 0xF0 if s[F_VX] >= 0x80 else 0x10
		var lift: int = -1 if s[F_VX] >= 0x80 else 0
		x = (((s[F_XHI] + lift) << 8) + s[F_X] + side) & 0xFFFF
		y = (s[F_YHI] << 8) | s[F_Y]                   # $A4C1
	y = (y - 0x0F) & 0xFFFF                            # $A4D9
	x = (x - 0x08) & 0xFFFF
	ridden = [x & 0xFF, y & 0xFF]
	# $A457 -- и кладёт свои четыре плитки на клетку впереди себя.  Картридж
	# ставит клетку твёрдой ($A3F4, $C8AC) на том месте, где площадка стоит
	# сейчас, а рисует на шаг вперёд, так что передняя клетка у него нарисована,
	# но ещё не твёрдая.  Здесь плитки и есть местность, поэтому она твердеет
	# вместе с рисунком -- на один заход ($20 ходов) раньше картриджа, и только
	# передняя клетка.
	if not _off_place(y, x):                           # $A46D
		var pair: Array = TILES_0F[0] if lvl.stage == 0x04 else TILES_0F[1]
		_paint_0f(x, y, pair[0], pair[1])


## $A4B5 и $A4BB -- чем площадка себя рисует: две плитки поверху и две понизу.
## Четвёртый этап берёт первую пару, все остальные -- вторую ($A462: `LDA $53 /
## CMP #$04`).  Третья пара -- нули, ею стирает напарник.
const TILES_0F := [
		[[0x5E, 0x5F], [0x60, 0x61]],
		[[0x65, 0x66], [0x67, 0x68]],
]


## $A478 и $A48B -- положить клетку туда, куда её посчитали.  Место здесь
## экранное, как и всюду у вещей, а карта в движке своя на всю область, так что
## вид прибавляется тем же способом, что и у выбиваемого блока ($8AF0).
func _paint_0f(x: int, y: int, top: Array, bot: Array) -> void:
	var sx: int = x & 0xFF
	var sy: int = y & 0xFF
	if lvl.vertical:
		lvl.paint_cell(sx, Pb2Level.map_row(_drawn_view(), sy), top, bot)
	else:
		lvl.paint_cell(cam + sx, sy - VIEW_TOP, top, bot)


## $A4F8 -- клетка на виду: оба старших байта нули и вниз не дальше $BF.
func _off_place(y: int, x: int) -> bool:
	if (y >> 8) != 0:
		return true
	if (y & 0xFF) >= 0xBF:
		return true
	return (x >> 8) != 0


## --- Выстрел висящей вещи ($3F, $B49F в банке 11) --------------------------
##
## Падает, а упав, расползается по земле четырьмя шагами и пропадает.  Оба
## хода расползания -- общие ($8279 и $82A8 в банке 10), и картридж зовёт их,
## подменив на время свой тип на $33, чтобы они не подали голос.

## $82EB -- четыре шага, каждый вбок и вниз, оба со знаком.
const CRAWL_3F := [[0x00, 0xFC], [0xFC, 0x08], [0x08, 0x00], [0xFC, 0xFC]]


func _mind_3f(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _wake_3f(s)
		1: _fall_3f(n, s)
		2: _crawl_3f(n, s)


func _wake_3f(s: PackedByteArray) -> void:
	s[F_MARK] = 0x02                                   # $C9A2
	start_anim(s, 0x25)                                # $BEAD
	s[F_STATE] += 1                                    # $C966


## $B4B2 -- падать не быстрее четырёх точек за ход.  Сравнение здесь без
## знака, так что скорость вверх тоже попала бы под этот предел; вверх этот
## выстрел не ходит, и так и оставлено.
func _fall_3f(n: int, s: PackedByteArray) -> void:
	add_speed_down(s, 0x40)                            # $C90C
	if s[F_VY] >= 0x04:                                # $B4BA
		set_speed_down(s, 0x04, 0x00)                  # $BEB9 00 04
	if ground_turn_clear(n, s, 0x00, 0x00) < 0x80:     # $BECB 00 00
		mark_target(n)                                 # $C9D2
		step_anim(s)                                   # $C8EE
		step_both(s)
		return
	_start_crawl(s)                                    # $8279
	s[F_MARK] = 0x80                                   # $C9AB
	s[F_STATE] = 2                                     # $C972


## $8279 (банк 10) -- встать на месте и завести отсчёт первого шага.
func _start_crawl(s: PackedByteArray) -> void:
	start_anim(s, 0x01)                                # $C83A
	s[F_COUNT] = 0x10
	s[F_SELF] = 0x00
	set_speed_side(s, 0x00, 0x00)                      # $C906
	set_speed_down(s, 0x00, 0x00)                      # $C909
	_crawl_noise(s)                                    # $8294
	s[F_STATE] += 1                                    # $C966


## $8294 и $82D6 (банк 10) -- голос шага.  Тот самый, из-за которого картридж
## на время подменяет тип на $33: два места спрашивают об этом одно и то же, и
## оба молчат и при чужом типе, и когда в $0610 что-то лежит.
func _crawl_noise(s: PackedByteArray) -> void:
	if s[F_TYPE] == 0x33 or s[F_KEEP2] != 0:
		return
	Pb2Sound.want(0x24)                                # $82A2, $82E4


## $82A8 (банк 10) -- шаг раз в шестнадцать ходов; после четвёртого ход
## кончается, и $B4F5 убирает то, что осталось.
func _crawl_step(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
	if s[F_COUNT] != 0:
		step_anim(s)                                   # $C837
	else:
		var step: Array = CRAWL_3F[s[F_SELF]]          # $82B5
		_shift_by(s, step[0], step[1])                 # $8A28
		s[F_SELF] += 1
		if s[F_SELF] == 0x04:                          # $82CA
			s[F_STATE] += 1                            # $C966
		else:
			s[F_COUNT] = 0x10
			start_anim(s, 0x01)                        # $C83A
			_crawl_noise(s)                            # $82D6


func _crawl_3f(n: int, s: PackedByteArray) -> void:
	_crawl_step(s)
	if s[F_STATE] != 0x02:                             # $B4F5
		clear(n)                                       # $C810


## $8A28 (банк 10) -- сдвинуть на два числа со знаком, оба байта места.
func _shift_by(s: PackedByteArray, side: int, down: int) -> void:
	var x: int = ((s[F_XHI] << 8) | s[F_X]) + _signed(side)
	s[F_X] = x & 0xFF
	s[F_XHI] = (x >> 8) & 0xFF
	var y: int = ((s[F_YHI] << 8) | s[F_Y]) + _signed(down)
	s[F_Y] = y & 0xFF
	s[F_YHI] = (y >> 8) & 0xFF


## --- Рубильник ($0D, $8B4F в банке 10) -------------------------------------
##
## Один на всю игру, в области 5:1.  Его запись ($049A) называет, какой из
## восьми битов $3B он держит: поднят -- рубильника уже нет, опущен -- он
## стоит и ждёт, пока его собьют.  Собьют -- через $40 ходов бит выворачивается
## и рубильник уходит.  Восемь байтов $BE36 -- те же, что и $AF54.
func _mind_0d(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_MARK] = 0x80                               # $C9AB
		if (MASK_36[s[F_LIFE]] & broken) != 0:         # $8B5E, $3B
			clear(n)                                   # $C810
			return
		s[F_SELF] = 0x40                               # $8B62
		s[F_STATE] += 1                                # $C966
		return
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF
	if s[F_SELF] != 0:
		return
	Pb2Sound.want(0x41)                                # $8B75 -- он сработал
	broken = broken ^ MASK_36[s[F_LIFE]]               # $8B7F
	clear(n)                                           # $C810


## $8B86 (bank 10) -- the one of its kind, and it is not a thing that fights.
##
## It stands in area 4:3 and it is the break in the middle of the stage.  On
## the first half ($AD nought) it is only a picture; when the man walks off
## the left of it the game takes the pad away, walks him out itself, and shows
## the scene between the halves ($18 := 6).  The level is then built again
## with $AD one, and the same record is a door instead.
##
## `work/re/pb2_minds.md`, "Ум $0E".
func _mind_0e(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_MARK] = 0x80                               # $C9AB
		if phase == 0:
			# $8B92 -- $46 := $10 as well, which is only which kilobyte of
			# tiles it is drawn from.
			s[F_KIND] = 0xF8
			s[F_STATE] += 1                            # $C966
			return
		# $8B9E -- on the second half it puts out the door and goes.
		for k in range(FIRST_PLACED, SLOTS):           # $C86A
			if slots[k][F_TYPE] == 0:
				slots[k][F_TYPE] = 0x04
				slots[k][F_X] = 0x10
				slots[k][F_Y] = 0x80
				break
		clear(n)                                       # $C810
		return
	# $8BB7 -- while he is still to the right of $90 the game holds him
	# walking left; once he is past it, the half of the stage is over.
	if slots[0][F_X] >= 0x90:
		take_pad = true
		return
	phase = 1                                          # $AD := 1
	interlude = true                                   # $18 := 6


# --- The door at the end of an area -----------------------------------
#
# Bank 10, $8542.  Fifty-two records in the game and the one type without
# which nothing goes anywhere: it is what carries the stage from area to
# area and, at the end, to the boss.  See work/re/pb2_level_flow.md.


## $8542 -- six steps: stand there, wait to be touched, decide where the
## touching leads, open, and close again behind him.
func _mind_04(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _wake_04(n, s)
		1: pass                                        # $8449 -- $B5A5 wakes it
		2: _leave_04(s)
		3: _open_04(s)
		4: _count_04(s)
		5: _shut_04(n, s)


## $8551 -- a door with a life in its record is only there while the stage is
## unfinished; walked again after the stage is beaten, it is not there at all.
## The rest is the box the hero has to touch and where the door is drawn.
func _wake_04(n: int, s: PackedByteArray) -> void:
	if s[F_LIFE] != 0 and (STAGE_BIT[lvl.stage] & cleared) != 0:
		clear(n)                                       # $C810
		return
	s[F_MARK] = 0x10                                   # a box eight by eight
	s[F_KEEP] = lvl.door_hi                            # $8587[$53][2*$9C]
	s[F_KEEP2] = lvl.door_lo
	s[F_STATE] += 1                                    # $C966


## $85FD -- he has touched it.  From here the level is no longer being played:
## it is leaving.  Three sorts of area and the first of the sixth stage have
## no next area to make ready, and their doors go straight to the closing.
func _leave_04(s: PackedByteArray) -> void:
	playing = 4                                        # $27 := 4
	slots[0][F_BITS] = slots[0][F_BITS] & 0x7F         # $042C
	frozen = 1                                         # $2A := 1
	if lvl.stage == 5 and area == 0:
		s[F_KIND] = 0                                  # $863A
		_start_shut_04(s)
		return
	if lvl.kind == 0x06 or lvl.kind == 0x09 or lvl.kind == 0x04:
		_start_shut_04(s)                              # $863F
		return
	# $8629 -- the door out of the last area of a stage leads to the boss, and
	# the walk's tune is hushed here so that the boss's own can start clean.
	# $D6C0 sets carry when the area after this one is past the end of the
	# walk; the stage it reads is $53, not the one being played.
	if Pb2Level.walk_count(came) == area + 1:          # $C8D0 -> $D6C0
		Pb2Sound.hush()                                # $8634
	s[F_STATE] += 1                                    # $C966


## $863F -- twenty-two steps of closing and nothing before them.
func _start_shut_04(s: PackedByteArray) -> void:
	s[F_PUSH] = 0x20
	s[F_STATE] = 5


## $864A -- one row of the doorway a frame in four, and the place it is drawn
## at walks a row backwards on every second row, wrapping once from the foot of
## one screen to the head of the next.  Eight rows in all, counted in $05E4.
func _open_04(s: PackedByteArray) -> void:
	s[F_PUSH] = (s[F_PUSH] + 1) & 0xFF
	# $8650 -- the grinding of the door, once every eight; the row itself is
	# laid every four, so the two counts are not the same one.
	if (s[F_PUSH] & 0x07) == 0:
		Pb2Sound.want(0x32)                            # $8656
	if (s[F_PUSH] & 0x03) != 0:
		return
	if (s[F_COUNT] & 1) != 0 and s[F_COUNT] != 7:      # $8686
		var lo: int = s[F_KEEP2] - 0x20
		var hi: int = s[F_KEEP] - (1 if lo < 0 else 0)
		lo = lo & 0xFF
		hi = hi & 0xFF
		if hi == 0x1F and lo == 0xE0:                  # $86AD
			hi = 0x23
			lo = 0xA0
		s[F_KEEP] = hi
		s[F_KEEP2] = lo
	s[F_COUNT] = (s[F_COUNT] + 1) & 0xFF
	s[F_STATE] += 1                                    # $C966


## $86D2 -- eight rows and it stops; anything less and it goes round again.
func _count_04(s: PackedByteArray) -> void:
	if s[F_COUNT] == 8:
		s[F_PUSH] = 0x20
		s[F_STATE] += 1                                # $C966
		return
	s[F_STATE] = 3


## $86E7 -- thirty-two frames of closing, and then the level is told to build
## itself again.  The next area is the one after this, unless this was the last
## one walked: then the stage's boss room is what opens.
func _shut_04(n: int, s: PackedByteArray) -> void:
	s[F_PUSH] = (s[F_PUSH] - 1) & 0xFF
	if s[F_PUSH] != 0:
		return
	live = 6                                           # $1A := 6
	area += 1                                          # INC $9C
	if area == Pb2Level.walk_count(came):              # $C894
		boss = 1                                       # $79 := 1
		phase = 2                                      # $AD := 2
		area = 0 if came == 5 else came
	clear(n)                                           # $C810


# --- The way to the boss ----------------------------------------------
#
# Bank 10, $840A.  One record at the end of each of the first four stages.
# Where the door of type $04 carries the walk from area to area, this one is
# the end of the walk: it stands the hero still, draws a way in above him and
# hands the stage over to the boss's room.


## $840A -- six steps, the same shape as the door: stand there, wait to be
## touched, take hold of him, draw, count, and hand over.
func _mind_03(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:
		0: _wake_03(n, s)
		1: pass                                        # $8449 -- $B5A5 wakes it
		2: _hold_03(s)
		3: _draw_03(s)
		4: _count_03(s)
		5: _hand_03(n, s)


## $8419 -- not there at all on a stage already beaten; otherwise the box he
## has to touch and, kept in its own fields, where the way in is drawn.
func _wake_03(n: int, s: PackedByteArray) -> void:
	if (STAGE_BIT[lvl.stage] & cleared) != 0:          # $BE36,Y AND $56
		clear(n)                                       # $C810
		return
	s[F_MARK] = 0x10                                   # a box eight by eight
	var vram: Array = Pb2Level.boss_door(lvl.stage)    # $843D[2*$53]
	s[F_KEEP] = int(vram[0])
	s[F_KEEP2] = int(vram[1])
	s[F_STATE] += 1                                    # $C966


## $844A -- he has touched it.  The level stops being played, he is stood
## exactly where the record stands and put into the pose he holds while the
## way opens; the count of rows drawn starts at nought.
func _hold_03(s: PackedByteArray) -> void:
	playing = 4                                        # $27 := 4
	slots[0][F_BITS] = slots[0][F_BITS] & 0x7F         # $042C
	slots[0][F_KIND] = 0x04                            # $0442 -- the pose
	slots[0][F_X] = s[F_X]                             # $0508 := $0508,X
	s[F_COUNT] = 0                                     # $05E4,X
	Pb2Sound.hush()                                    # $846C
	Pb2Sound.want(0x2C)                                # $8471 -- the way opens
	s[F_STATE] += 1                                    # $C966


## $8477 -- sixteen rows of the way in, all in one frame, and then sixteen
## frames of waiting before the next lot.
func _draw_03(s: PackedByteArray) -> void:
	s[F_COUNT] = (s[F_COUNT] + 1) & 0xFF               # INC $05E4,X
	s[F_PUSH] = 0x10                                   # $0626,X
	s[F_STATE] += 1                                    # $C966


## $84D0 -- after the second lot he is let out of the pose again; after the
## fourth the waiting is over.  Between them the sixteen frames run down.
func _count_03(s: PackedByteArray) -> void:
	if s[F_COUNT] == 2:
		slots[0][F_KIND] = 0                           # $0442 := 0
	if s[F_COUNT] == 4:
		s[F_STATE] += 1                                # $C966
		return
	s[F_PUSH] = (s[F_PUSH] - 1) & 0xFF
	if s[F_PUSH] == 0:
		s[F_STATE] = 3


## $84F1 -- the level is told to build itself again, and what it builds is the
## boss's room: the sixth stage, six areas along from this one.
func _hand_03(n: int, s: PackedByteArray) -> void:
	live = 6                                           # $1A := 6
	boss = 1                                           # $79 := 1
	area = came + 6                                    # $9C := $53 + 6
	clear(n)                                           # $C810


# --- What he throws ---------------------------------------------------
#
# $A17A and $A563 in bank 9, and the tables at $A84D..$A945.  Places one to
# three are his and his alone: nothing the level puts out ever gets one, the
# button fills them, and a wall, the edge of the level or his own hand coming
# back empties them again.  See work/re/pb2_weapons.md.
#
# It runs inside his own step -- $8E23 throws and $8E26 moves what was thrown
# -- so both come before the touch sweep at $CF08, and a blade let go this
# step can cut this step.


## $A3D9 -- a free place for a new throw, or minus one.  Only the first three
## places are counted, and he may have one more in the air than $99 says.
func free_shot_slot() -> int:
	var out := 0
	for k in range(1, 4):                              # $A3E0
		if slots[k][F_TYPE] != 0:
			out += 1
	if out > extra:                                    # $A3F2
		return -1
	for k in range(1, SLOTS):                          # $A3F8
		if slots[k][F_TYPE] == 0:
			return k
	return -1


## $A247 -- how long he held the button, in four steps.  The three marks are
## the world's own, and $54 is counted up elsewhere ($D23A).
func charge_tier(hold: int) -> int:
	var mark: Array = hold_mark[power]
	if hold < mark[1]:
		return 0
	if hold < mark[2]:
		return 1
	if hold < mark[3]:
		return 2
	return 3


## $A226 -- a new throw takes its numbers.  `pose` is the second answer of
## $A403, which the cartridge keeps in his own $0458, and `tier` is $08.
func fire(k: int, dir: int, pose: int, tier: int) -> void:
	var h: PackedByteArray = slots[0]
	var s: PackedByteArray = slots[k]
	s[F_SELF] = dir                                    # $A229
	s[F_BITS] = h[F_BITS] & 0x60                       # $A231
	# $A235 -- while that mark of his is up the picture of him is the wrong
	# way round, and what he throws is turned back to match.
	if (h[F_MARK] & 0x20) != 0:
		s[F_BITS] = s[F_BITS] ^ 0x40
	_place_shot(k, pose)                               # $A4FD
	# $A25E -- a throw aimed downwards out of the crouch is turned along the
	# ground instead when there is floor in the way of it.
	if pose == 0x01 and dir >= 0x06:
		var off: int = 0x06 if dir == 0x06 else 0xFA
		if ground(slots[k], off, 0x0C) >= 0x80 or _in_solid(off, 0x0C):
			slots[k][F_SELF] = dir - 0x06              # $A288
	if suit != 0:                                      # $A291
		_beam_born(k, tier)
	else:
		_blade_born(k, tier)


## $A4FD -- where it comes out of him: up by the pose's own step, and along by
## it too, turned about when he faces left.  The 1/256ths of the place are not
## written, and the place was wiped when the last throw in it died, so they
## are nought.
func _place_shot(k: int, pose: int) -> void:
	var h: PackedByteArray = slots[0]
	var s: PackedByteArray = slots[k]
	var y: int = (((h[F_YHI] << 8) | h[F_Y]) + _signed(spawn_dy[pose])) & 0xFFFF
	s[F_YHI] = y >> 8
	s[F_Y] = y & 0xFF
	var dx: int = spawn_dx[pose]
	if (h[F_BITS] & 0x40) != 0:                        # $A526
		dx = (-dx) & 0xFF
	var x: int = (((h[F_XHI] << 8) | h[F_X]) + _signed(dx)) & 0xFFFF
	s[F_XHI] = x >> 8
	s[F_X] = x & 0xFF


## $AC57 -- is that point, taken from where he stands, inside one of the boxes
## the level itself declared solid this frame?
func _in_solid(side_off: int, down_off: int) -> bool:
	if solids.is_empty():                              # $011F
		return false
	var h: PackedByteArray = slots[0]
	var x: int = (((h[F_XHI] << 8) | h[F_X]) + _signed(side_off)) & 0xFFFF
	var col: int = x & 0xFF
	if (x >> 8) != 0:                                  # $AC6D
		col = 0x00 if (x >> 8) >= 0x80 else 0xFF
	var y: int = (((h[F_YHI] << 8) | h[F_Y]) + _signed(down_off)) & 0xFFFF
	var row: int = y & 0xFF
	if (y >> 8) != 0:
		row = 0x00 if (y >> 8) >= 0x80 else 0xFF
	# $ACB4 counts down, so the last of them is met first; the answer is only
	# yes or no, so the order makes no odds.
	for b in solids:
		if col >= int(b[0]) and col <= int(b[1]) \
				and row >= int(b[2]) and row <= int(b[3]):
			return true
	return false


## $A298 -- the blade that comes back.  Which of the two it is is $A2's to say
## and both are thrown the same way.
func _blade_born(k: int, tier: int) -> void:
	var s: PackedByteArray = slots[k]
	if second != 0:                                    # $A29C
		s[F_BITS] = s[F_BITS] | 0x02
	s[F_TYPE] = second + 1                             # $A2A6
	start_anim(s, 0x08)                                # $A2A9 -> $C83A
	# $A2AE -- how hard: which blade it is, how far it has been raised ($55)
	# and how long he held the button all have a say.
	var mag: int = throw[s[F_TYPE] - 1][power][tier]
	var neg: int = (-mag) & 0xFFFF
	var dir: int = s[F_SELF]
	var vx := 0
	if dir != 0x02 and dir != 0x03:                    # $A2E1
		vx = neg if (dir & 1) != 0 else mag
	s[F_VX] = vx >> 8
	s[F_VXFR] = vx & 0xFF
	var vy := 0
	if dir >= 0x02:                                    # $A307
		vy = mag if (dir >= 0x06 or dir == 0x03) else neg
	s[F_VY] = vy >> 8
	s[F_VYFR] = vy & 0xFF
	_halve_in_water(k)                                 # $A358
	# $A33E -- thrown straight up with a ceiling over him, it starts at the
	# ceiling and not at his hand.  Only the low byte of the place is written.
	if dir == 0x02 and (slots[0][F_HOLD] & 0x40) == 0:
		if ground(slots[k], 0x00, 0xE3) >= 0x80:
			slots[k][F_Y] = (slots[0][F_Y] + 0xE3) & 0xFF
	# $A338 -- and he has thrown it.  All four roads through $A33E arrive
	# here, so the request stands unconditional, big fork over it or not.
	Pb2Sound.want(0x1A)


## $A37F -- the beam a suit fires.  One picture and one speed for each of the
## eight ways, and a life in frames out of the world's own row.
func _beam_born(k: int, tier: int) -> void:
	var s: PackedByteArray = slots[k]
	s[F_TYPE] = 0x03
	s[F_COUNT] = 0x00                                  # $A386
	var d: int = s[F_SELF]
	s[F_KIND] = beam_tile[d]                           # $A38C
	var v: Array = beam_v[d]
	s[F_VXFR] = v[0]
	s[F_VX] = v[1]
	s[F_VYFR] = v[2]
	s[F_VY] = v[3]
	_halve_in_water(k)                                 # $A3AA
	s = slots[k]
	s[F_HOLD] = beam_life[power][tier]                 # $A3BD
	# $A3C2 -- and water takes two frames of that life as well.
	if (slots[0][F_HOLD] & 0x40) != 0 and suit != 0x02:
		s[F_HOLD] = (s[F_HOLD] - 2) & 0xFF
	Pb2Sound.want(0x22)                                # $A3D3 -- the beam


## $A358 -- water takes half the speed off what he throws, unless the suit
## that swims is on.  The mark it leaves is read again every step.
func _halve_in_water(k: int) -> void:
	if (slots[0][F_HOLD] & 0x40) == 0:                 # $A35B
		return
	if suit == 0x02:                                   # $A35F
		return
	var s: PackedByteArray = slots[k]
	s[F_KEEP] = 0x01                                   # $A363
	var v: int = _asr16((s[F_VY] << 8) | s[F_VYFR])
	s[F_VY] = v >> 8
	s[F_VYFR] = v & 0xFF
	v = _asr16((s[F_VX] << 8) | s[F_VXFR])
	s[F_VX] = v >> 8
	s[F_VXFR] = v & 0xFF


## $A368 and the pairs like it -- one shift right with the sign kept.
static func _asr16(v: int) -> int:
	return ((v >> 1) | (v & 0x8000)) & 0xFFFF


## $FEE0 -- and takes it back, which $D733 does for every slot it empties.
func unmark_target(n: int) -> void:
	if n < FIRST_PLACED:                               # $FEEC
		marks &= ~(1 << ((n - FIRST_LIVE) & 0x07)) & 0xFF
	else:
		marks2 &= ~(1 << ((n - FIRST_LIVE) & 0x07)) & 0xFF


## $FEC0 ($C9D2) -- a thing marks itself as something the satellites may go
## for.  Slots six to thirteen have their bit in $0117, fourteen to twenty-one
## in $0118, and the bit is the slot counted from six.
func mark_target(n: int) -> void:
	if n < FIRST_PLACED:                               # $FEC0
		marks |= 1 << ((n - FIRST_LIVE) & 0x07)
	else:
		marks2 |= 1 << ((n - FIRST_LIVE) & 0x07)


## $A945 (bank 9, stub $8E12) -- the two satellites of the fourth suit.  They
## are slots four and five, they belong to no record and have no type of their
## own: only a picture, a place and a state.  $8E2C runs this in the hero's own
## frame, after his step and before $8E32 wipes the marks.
func orbit() -> void:
	if suit != 0x04:                                   # $9A
		# $A94B -- out of the suit and they go, but only once.
		if slots[4][F_KIND] == 0:                      # $0446
			return
		clear(4)                                       # $C810
		clear(5)
		return
	if slots[4][F_KIND] == 0:                          # $A95A
		_make_orbit()                                  # $AA86
	_orbit_one(4)                                      # $A962
	_orbit_one(5)


## $AA86 -- born a third of a turn apart, each already standing where its own
## angle says, and both wearing the ninth run of pictures.
func _make_orbit() -> void:
	_place_orbit(4, 0x18)
	_place_orbit(5, 0xE8)


## $AA94 -- put one down.
func _place_orbit(n: int, ang: int) -> void:
	var s: PackedByteArray = slots[n]
	s[F_KEEP] = ang                                    # $05FA
	var at: Array = _orbit_place(s)                    # $AAB3
	s[F_X] = at[0]
	s[F_XHI] = at[1]
	s[F_Y] = at[2]
	s[F_YHI] = at[3]
	# $C891 ($E2D8) -- $E2D5 with the first store stepped over: the run is
	# laid out in the thing but its number is not kept, because the satellite
	# names the run afresh on every turn ($A96E).
	var run: Dictionary = anims[0x09]
	s[F_HOLD] = int(run["hold"])
	s[F_KIND] = int(run["first"])
	s[F_STEP] = 0


## $AAB3 -- where the satellite belongs this turn: round him, at the angle its
## own count has reached, on an ellipse as wide as $05FA and as tall as $0610
## -- which is nought, so the walk is flat -- and sixteen points above him.
## Answers [x, xhi, y, yhi].
func _orbit_place(s: PackedByteArray) -> Array:
	var off: Array = around(s[F_COUNT], s[F_KEEP], s[F_KEEP2])
	var h: PackedByteArray = slots[0]
	var side: int = off[0]
	var x: int = h[F_X] + side
	var xhi: int = (h[F_XHI] + (0xFF if side >= 0x80 else 0x00) + (x >> 8)) & 0xFF
	var down: int = (off[1] - 0x10) & 0xFF             # $AAD8
	var y: int = h[F_Y] + down
	var yhi: int = (h[F_YHI] + (0xFF if down >= 0x80 else 0x00) + (y >> 8)) & 0xFF
	return [x & 0xFF, xhi, y & 0xFF, yhi]


## $A968 -- one satellite's turn.
func _orbit_one(n: int) -> void:
	var s: PackedByteArray = slots[n]
	s[F_COUNT] = (s[F_COUNT] + 1) & 0xFF               # $05E4
	_orbit_sweep(n, s)                                 # $AAED
	step_anim_into(s, 0x09)                            # $C88E
	match s[F_STATE]:                                  # $A973
		0: _orbit_round(n, s)
		1: _orbit_chase(n, s)
		2: _orbit_rest(n, s)
		3: _orbit_home(n, s)


## $AAED -- what it touches, it takes: any marked thing standing within
## thirteen points of it both ways is gone.  Neither side counts if it is off
## the screen, which the high bytes of a place say.
func _orbit_sweep(n: int, s: PackedByteArray) -> void:
	if (s[F_XHI] | s[F_YHI]) != 0:                     # $AAED
		return
	_orbit_sweep_eight(FIRST_LIVE, marks, s[F_X], s[F_Y])
	_orbit_sweep_eight(FIRST_PLACED, marks2, s[F_X], s[F_Y])


## $AB12 -- eight slots, one bit each, lowest bit first.
func _orbit_sweep_eight(first: int, mask: int, x: int, y: int) -> void:
	for i in range(8):
		if (mask & (1 << i)) == 0:                     # $AB18
			continue
		var t: PackedByteArray = slots[first + i]
		if (t[F_XHI] | t[F_YHI]) != 0:                 # $AB1C
			continue
		if _gap(t[F_X], x) >= 0x0D:                    # $AB24
			continue
		if _gap(t[F_Y], y) >= 0x0D:                    # $AB34
			continue
		clear(first + i)                               # $C810


## $AB24 and $AB34 -- how far apart two bytes are, whichever is the greater.
static func _gap(a: int, b: int) -> int:
	var d: int = (a - b) & 0xFF
	return d if a >= b else ((-d) & 0xFF)


## $AB4D -- the two satellites split the marked things between them: the even
## slot takes the bits of $55, the odd one the bits of $AA.  The first byte is
## tried before the second, and whichever answered is kept -- $0626 for the
## near eight, $063C for the far eight.  Answers what it found.
func _orbit_pick(n: int, s: PackedByteArray) -> int:
	var half: int = 0xAA if (n & 1) != 0 else 0x55     # $AB6A
	var a: int = marks & half                          # $AB51
	if a != 0:
		s[F_PUSH] = a                                  # $0626
		return a
	a = marks2 & half                                  # $AB59
	if a != 0:
		s[F_ANG] = a                                   # $063C
		return a
	return 0


## $A98B -- state nought: walk the ellipse, and take the first marked thing
## that turns up.
func _orbit_round(n: int, s: PackedByteArray) -> void:
	if _orbit_pick(n, s) != 0:                         # $AB4D
		_orbit_go(s)                                   # $A9A8
		return
	var at: Array = _orbit_place(s)                    # $AAB3
	s[F_X] = at[0]
	s[F_XHI] = at[1]
	s[F_Y] = at[2]
	s[F_YHI] = at[3]


## $A9A8 -- set off after what was picked.
func _orbit_go(s: PackedByteArray) -> void:
	s[F_STATE] = 0x01                                  # $058C
	set_speed_side(s, 0x00, 0x00)                      # $C906
	set_speed_down(s, 0x00, 0x00)                      # $C909


## $A9B6 -- state one: the chase.  What it was going for is looked at again
## every turn, because a thing that has gone leaves its bit down; when nothing
## it held is left it stands still for a space of $20 turns.  The aim is laid
## down on every other turn, and which turn that is depends on the slot, so
## the two satellites never do it together.
func _orbit_chase(n: int, s: PackedByteArray) -> void:
	s[F_PUSH] = s[F_PUSH] & marks                      # $A9B6
	s[F_ANG] = s[F_ANG] & marks2
	if (s[F_ANG] | s[F_PUSH]) == 0:                    # $A9CB
		s[F_STATE] = (s[F_STATE] + 1) & 0xFF           # $A9F2
		s[F_SELF] = 0x20                               # $05CE
		return
	if ((n ^ frame) & 0x01) == 0:                      # $A9CD
		var t: PackedByteArray = slots[_orbit_first(s)]
		_orbit_aim(s, t[F_X], t[F_Y], t[F_XHI], t[F_YHI])
	step_both(s)                                       # $C8F1


## $AB89 -- the lowest bit still standing, counted as a slot.  The near eight
## are looked at first and answer six upward; the far eight, when the near
## byte is empty, answer six upward as well and not fourteen -- the cartridge
## starts the count over and does not put the eight back.  Kept as it is.
func _orbit_first(s: PackedByteArray) -> int:
	var y: int = FIRST_LIVE
	var m: int = s[F_PUSH]
	if m == 0:                                         # $AB8E
		m = s[F_ANG]
	for i in range(8):
		if (m & (1 << i)) != 0:
			return (y + i) & 0xFF
		# $AB96 -- nothing found in eight tries and the count walks on; the
		# two bytes are never both empty here, so it never comes to that.
	return y


## $AB6C -- point the speed straight at a place, flat out.
func _orbit_aim(s: PackedByteArray, x: int, y: int, xhi: int, yhi: int) -> void:
	var a: Array = _halve16(s[F_XHI], s[F_X], xhi, x)  # $C8B5 -> $F690
	var b: Array = _halve16(s[F_YHI], s[F_Y], yhi, y)
	set_speed_at(s, 0x3F, _atan(a[0], b[0], a[1], b[1]))


## $A9FB -- state two: stand where the chase left it until the count runs out,
## unless something new turns up in the meantime.
func _orbit_rest(n: int, s: PackedByteArray) -> void:
	if _orbit_pick(n, s) != 0:                         # $AB4D
		_orbit_go(s)
		return
	s[F_SELF] = (s[F_SELF] - 1) & 0xFF                 # $05CE
	if s[F_SELF] != 0:
		return
	s[F_STATE] = (s[F_STATE] + 1) & 0xFF               # $AA06
	set_speed_side(s, 0x00, 0x00)                      # $C906
	set_speed_down(s, 0x00, 0x00)                      # $C909


## $AA12 -- state three: back to him.  Once it is within twenty-four points of
## where the ellipse says it belongs, both ways, it takes the walk up again.
func _orbit_home(n: int, s: PackedByteArray) -> void:
	if _orbit_pick(n, s) != 0:                         # $AB4D
		_orbit_go(s)
		return
	var at: Array = _orbit_place(s)                    # $AAB3
	if (_near16(at[1], at[0], s[F_XHI], s[F_X])
			and _near16(at[3], at[2], s[F_YHI], s[F_Y])):
		s[F_STATE] = 0x00                              # $AA72
		return
	if ((n ^ frame) & 0x01) == 0:                      # $AA78
		_orbit_aim(s, at[0], at[2], at[1], at[3])
	step_both(s)                                       # $C8F1


## $AA2A -- two places, both bytes of each, no further apart than $18.
static func _near16(hi0: int, lo0: int, hi1: int, lo1: int) -> bool:
	var a: int = (hi0 << 8) | lo0
	var b: int = (hi1 << 8) | lo1
	var d: int = (a - b) & 0xFFFF
	if a < b:                                          # $AA37, the borrow
		d = (-d) & 0xFFFF
	return d < 0x18


## $A563 -- every throw of his gets its turn, between his own step and the
## sweep that says what it touched.
func shots_turn() -> void:
	for k in range(1, FIRST_LIVE):
		var t: int = slots[k][F_TYPE]
		if t == 0:
			continue
		if t == 0x03:                                  # $A573
			_beam_step(k)
		else:
			_blade_step(k)


## $A57A -- one step of the blade: the picture, the whirr, the wall, the move,
## the gain, and then whatever the way it was thrown makes of it.
func _blade_step(k: int) -> void:
	var s: PackedByteArray = slots[k]
	step_anim(s)                                       # $C837
	# $A57D -- his own place keeps no type, so the whirr counts its frames
	# there; every tenth is a sound ($1A).
	whirr = (whirr + 1) & 0xFF
	if whirr == 0x0A:
		whirr = 0
		Pb2Sound.want(0x1A)                            # $A58C
	if ground(s, 0x00, 0x00) >= 0x80:                  # $A591
		if terrain_strike.is_valid():
			terrain_strike.call(s[F_X], s[F_Y])
		clear(k)
		return
	if not _shot_move(k):                              # $A59C -> $A7B9
		return
	s = slots[k]
	# $A59F -- the eight of its own kind, or the sixteen it shares with the
	# second blade once it has turned about, and then the way it was thrown.
	var dir: int = s[F_SELF]
	var a: Array = accel[(0x10 if dir >= 0x80 else s[F_TYPE] * 8) + (dir & 0x7F)]
	var ax: int = (a[1] << 8) | a[0]
	var ay: int = (a[3] << 8) | a[2]
	if s[F_KEEP] != 0:                                 # $A5CA
		ax = _asr16(ax)
		ay = _asr16(ay)
	var v: int = (((s[F_VX] << 8) | s[F_VXFR]) + ax) & 0xFFFF
	s[F_VX] = v >> 8
	s[F_VXFR] = v & 0xFF
	v = (((s[F_VY] << 8) | s[F_VYFR]) + ay) & 0xFFFF
	s[F_VY] = v >> 8
	s[F_VYFR] = v & 0xFF
	match dir & 0x7F:                                  # $A606 -> $CA0B
		0x00: _blade_out(k, false)                     # $A619
		0x01: _blade_out(k, true)                      # $A646
		0x02: _blade_straight(k)                       # $A691
		0x03: _blade_down(k)                           # $A671
		0x04: _blade_turn(k, false)                    # $A69A
		0x05: _blade_turn(k, true)                     # $A6B0
		0x06: _blade_turn(k, false)                    # $A6C4
		0x07: _blade_turn(k, true)                     # $A6D9


## $A619 and $A646 -- thrown along the ground.  It flies out for as long as
## its speed is still the way it was thrown; once the gain has turned that
## speed about it starts looking for him, and when he is the other side of it
## it turns about outright and comes home fast.
func _blade_out(k: int, left: bool) -> void:
	if not _blade_returning(k, left):
		return
	if not _aim_shot(k):                               # $A764
		return
	if not _blade_returning(k, left):
		return
	if not _home_down(k):                              # $A701
		return
	var s: PackedByteArray = slots[k]
	if left:
		if s[F_VX] >= 0x80:                            # $A660
			return
		if aim_side < 0x80:                            # $A665
			return
		_turn_shot(k, 0x04, 0x80)
	else:
		if s[F_VX] < 0x80:                             # $A633
			return
		if aim_side == 0 or aim_side >= 0x80:          # $A638
			return
		_turn_shot(k, 0xFC, 0x81)


## $A619 and $A653 -- has it turned about yet?  Either the mark of a throw
## already sent home, or a speed that is no longer the way it was thrown.
func _blade_returning(k: int, left: bool) -> bool:
	var s: PackedByteArray = slots[k]
	if s[F_SELF] >= 0x80:
		return true
	return s[F_VX] < 0x80 if left else s[F_VX] >= 0x80


## $A69A, $A6B0, $A6C4 and $A6D9 -- thrown at a slant.  These four never take
## the step down; they wait for the gain to turn the speed about and then go
## straight home.
func _blade_turn(k: int, left: bool) -> void:
	var s: PackedByteArray = slots[k]
	if left:
		if s[F_VX] >= 0x80:
			return
	elif s[F_VX] < 0x80:
		return
	if not _aim_shot(k):
		return
	if left:
		if aim_side < 0x80:
			return
		_turn_shot(k, 0x04, 0x80)
	else:
		if aim_side == 0 or aim_side >= 0x80:
			return
		_turn_shot(k, 0xFC, 0x81)


## $A691 -- thrown straight up: look for him and take the step across.
func _blade_straight(k: int) -> void:
	if not _aim_shot(k):
		return
	_move_side(k)


## $A671 -- thrown straight down.  While that mark of his is up and he is
## falling, it rides down with him, and if that carries it off the screen it
## is gone.
func _blade_down(k: int) -> void:
	var h: PackedByteArray = slots[0]
	if (h[F_MARK] & 0x01) != 0 and h[F_VY] < 0x80:     # $A671
		var s: PackedByteArray = slots[k]
		var v: int = s[F_YFR] + h[F_VYFR]
		s[F_YFR] = v & 0xFF
		v = s[F_Y] + h[F_VY] + (v >> 8)
		s[F_Y] = v & 0xFF
		if (v >> 8) != 0:                              # $A68F
			clear(k)
			return
	if not _aim_shot(k):
		return
	_move_side(k)


## $A6EC -- turn about outright: a new way, a whole speed across, no speed
## down, and half a point of each in the 1/256ths.
func _turn_shot(k: int, vx: int, dir: int) -> void:
	var s: PackedByteArray = slots[k]
	s[F_VX] = vx
	s[F_SELF] = dir
	s[F_VY] = 0x00
	s[F_VXFR] = 0x80
	s[F_VYFR] = 0x80


## $A764 -- how far off he is and which way to go for him.  Two steps come out
## of it, one down and one across, and when he is near in both the throw has
## come home: the place is emptied and the step it was in the middle of is
## thrown away with it.
func _aim_shot(k: int) -> bool:
	var s: PackedByteArray = slots[k]
	var h: PackedByteArray = slots[0]
	var far := 0
	aim_up = 0
	aim_side = 0
	var t: int = (h[F_Y] - 0x10) & 0xFF                # $A76C
	var d: int = (t - s[F_Y]) & 0xFF
	if d != 0:
		if ((d + 0x10) & 0xFF) >= 0x21:                # $A77B
			far += 1
	t = (h[F_Y] - 0x1C) & 0xFF                         # $A781
	d = (t - s[F_Y]) & 0xFF
	if d != 0:
		aim_up = 0x02 if t >= s[F_Y] else 0xFE
	d = (h[F_X] - s[F_X]) & 0xFF                       # $A795
	if d != 0:
		aim_side = 0x02 if h[F_X] >= s[F_X] else 0xFE
		if ((d + 0x0A) & 0xFF) >= 0x15:                # $A7A9
			far += 1
	if far == 0:                                       # $A7AF
		clear(k)
		return false
	return true


## $A701 -- one step of the way back to him down the screen, and then, while
## that mark of his is up, a quarter of his own speed down on top of it.
##
## The cartridge weighs the carry of the first step against the wrong high
## byte -- the one across the level, not the one down it -- and it is left as
## it stands: a throw still alive has nought in both.
func _home_down(k: int) -> bool:
	var s: PackedByteArray = slots[k]
	var sign: int = 0xFF if aim_up >= 0x80 else 0x00
	var v: int = s[F_Y] + aim_up
	s[F_Y] = v & 0xFF
	var hi: int = sign + s[F_XHI] + (v >> 8)           # $A710
	if (hi & 0xFF) != 0:
		clear(k)                                       # $A748
		return false
	if (slots[0][F_MARK] & 0x01) == 0:                 # $A715
		return true
	var carry: int = hi >> 8
	sign = 0xFF if slots[0][F_VY] >= 0x80 else 0x00
	# $A72B -- three bytes shifted right twice through the carry that add
	# left behind: the sign, the whole points and the 1/256ths.
	var b: Array = [sign, slots[0][F_VY], slots[0][F_VYFR]]
	for _round in range(2):
		for i in range(3):
			var out: int = b[i] & 1
			b[i] = (b[i] >> 1) | (carry << 7)
			carry = out
	# $A735 -- the 1/256ths are added for the carry they make and nothing
	# else; where they land the cartridge never keeps.
	v = b[2] + s[F_YFR]
	v = b[1] + s[F_Y] + (v >> 8)
	s[F_Y] = v & 0xFF
	if ((sign + s[F_YHI] + (v >> 8)) & 0xFF) != 0:     # $A742
		clear(k)
		return false
	return true


## $A74D -- the step across, and off the level it is gone.
func _move_side(k: int) -> bool:
	var s: PackedByteArray = slots[k]
	var sign: int = 0xFF if aim_side >= 0x80 else 0x00
	var v: int = s[F_X] + aim_side
	s[F_X] = v & 0xFF
	if ((sign + s[F_XHI] + (v >> 8)) & 0xFF) != 0:     # $A75E
		clear(k)
		return false
	return true


## $A7B9 -- move by its own speed, across and down, and off the level it is
## gone.  Neither high byte is written back; both are nought while it lives.
func _shot_move(k: int) -> bool:
	var s: PackedByteArray = slots[k]
	var sign: int = 0xFF if s[F_VY] >= 0x80 else 0x00
	var v: int = s[F_YFR] + s[F_VYFR]
	s[F_YFR] = v & 0xFF
	v = s[F_Y] + s[F_VY] + (v >> 8)
	s[F_Y] = v & 0xFF
	if ((sign + s[F_YHI] + (v >> 8)) & 0xFF) != 0:     # $A7D2
		clear(k)
		return false
	sign = 0xFF if s[F_VX] >= 0x80 else 0x00
	v = s[F_XFR] + s[F_VXFR]
	s[F_XFR] = v & 0xFF
	v = s[F_X] + s[F_VX] + (v >> 8)
	s[F_X] = v & 0xFF
	if ((sign + s[F_XHI] + (v >> 8)) & 0xFF) != 0:     # $A7F0
		clear(k)
		return false
	return true


## $A7FB -- one step of the beam: it gains speed the way it was fired, moves,
## and counts down the life it was born with.
func _beam_step(k: int) -> void:
	var s: PackedByteArray = slots[k]
	var a: Array = beam_a[s[F_SELF]]
	var ax: int = (a[1] << 8) | a[0]
	var ay: int = (a[3] << 8) | a[2]
	if s[F_KEEP] != 0:                                 # $A812
		ax = _asr16(ax)
		ay = _asr16(ay)
	var v: int = (((s[F_VX] << 8) | s[F_VXFR]) + ax) & 0xFFFF
	s[F_VX] = v >> 8
	s[F_VXFR] = v & 0xFF
	v = (((s[F_VY] << 8) | s[F_VYFR]) + ay) & 0xFFFF
	s[F_VY] = v >> 8
	s[F_VYFR] = v & 0xFF
	step_both(s)                                       # $C8E8 -> $FA08
	s[F_HOLD] = (s[F_HOLD] - 1) & 0xFF                 # $A84C
	if s[F_HOLD] == 0:
		clear(k)                                       # $A852



# ------------------------------------------------------- what bosses throw
#
# Six little minds that only ever come out of a boss's room.  They are
# ordinary things of the level's own table and not part of the boss's shell,
# so they live here with the rest of the minds.


## $932E (bank 10) -- what the boss that flies drops.  It falls, and where it
## lands it turns into the crawl of type $26 -- unless it is in a boss's room,
## and it always is, and then $B4D0 has it burst instead.
func _mind_25(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_MARK] = 0x02                               # $C9A2
		s[F_KIND] = 0x4E                               # $BE6E 4E
		set_speed_down(s, 0x01, 0x00)                  # $BEB9 00 01
		s[F_STATE] += 1                                # $C966
		return
	if ground_turn_clear(n, s, 0x00, 0x04) >= 0x80:    # $BECB 04 00
		if boss != 0:                                  # $79
			_splash_boss(s)                            # $B4D0
			return
		snap_down(s)                                   # $C981
		s[F_TYPE] = 0x26                               # $936C
		s[F_LIFE] = 0xFF                               # $BE5A FF
		s[F_MARK] = 0x01
		start_anim(s, 0x16)                            # $BEAD 16
		s[F_SELF] = 0x80                               # $BE75 80
		Pb2Sound.want(0x27)                            # $937D -- он упал
		s[F_STATE] = 1                                 # $C96F
		return
	add_speed_down(s, 0x24)                            # $C90C
	if s[F_VY] == 0x04:                                # $934E
		set_speed_down(s, 0x04, 0x00)                  # $BEB9 00 04
	mark_target(n)                                     # $C9D2
	step_down(s)                                       # $C8F4


## $B4D0 (bank 11) -- a thing that ends its life in a boss's room wears type
## $33 for as long as it takes to start the crawl and then becomes $3F, which
## is the burst; the type it wore in between is what picks the pictures.
func _splash_boss(s: PackedByteArray) -> void:
	s[F_TYPE] = 0x33
	_start_crawl(s)                                    # $8279
	s[F_TYPE] = 0x3F
	s[F_MARK] = 0x80                                   # $C9AB
	Pb2Sound.want(0x1C)                                # $B4E2 -- the burst
	s[F_STATE] = 2                                     # $C972


## $BC89 (bank 11) -- what the four bosses at the end of a stage throw.  It
## looks the way it flies, and once it has come to rest it creeps six steps
## down the wall it settled against before it is done with.
func _mind_44(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_MARK] = 0x02                               # $C9A2
		start_anim(s, 0x33)                            # $BEAD 33
		face_by_speed(s)                               # $C993
		s[F_STATE] += 1                                # $C966
		return
	step_anim(s)                                       # $C837
	mark_target(n)                                     # $C9D2
	if (s[F_VY] | s[F_VYFR]) == 0 and s[F_SELF] < 0x06:    # $BCA1
		s[F_SELF] = (s[F_SELF] + 1) & 0xFF
		nudge_down(s, 0x00, 0x01)                      # $C930
	ground_or_die(n, s)                                # $C8EB


## $9B6A (bank 10) -- the one shot the boss that fades throws.  Below a
## certain line it tells the boss that it has him, which is what the boss
## waits for before it opens the fan.
func _mind_4b(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_LIFE] = 0xFF                               # $BE5A FF
		s[F_MARK] = 0x01
		s[F_KIND] = 0xF2                               # $BE6E F2
		s[F_STATE] += 1                                # $C966
		return
	step_both(s)                                       # $C8F1
	if s[F_Y] < 0x96:                                  # $9B80
		return
	slots[int(cfg_boss["slot"])][F_GROUND] = 0x02      # $0677
	clear(n)                                           # $C810


## $9B8D (bank 10) -- and the six of the fan, which only fly until they meet
## something solid.
func _mind_4c(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_MARK] = 0x02                               # $C9A2
		start_anim(s, 0x3E)                            # $BEAD 3E
		s[F_STATE] += 1                                # $C966
		return
	step_anim(s)                                       # $C837
	mark_target(n)                                     # $C9D2
	ground_or_die(n, s)                                # $C8EB


## $AC2D (bank 11) -- the two arms of the boss the hero stands on.  Each
## keeps to its own half of the room -- which half is the number its maker
## put in $05CE -- walking back and forth, and every so often it stops and
## lets something go.
func _mind_4d(_n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:                                  # $C97E
		0:
			s[F_LIFE] = 0x08                           # $BE5A 08
			s[F_MARK] = 0x01
			s[F_Y] = 0x26                              # $AC3A
			s[F_X] = 0x55 if s[F_SELF] == 0 else 0xAD
			_walk_4d(s)                                # $ACAF
			s[F_STATE] += 1                            # $C966
		1:
			s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
			if s[F_COUNT] == 0:
				s[F_COUNT] = 0x30                      # $BE7C 30
				s[F_STATE] += 1                        # $C966
				return
			step_side(s)                               # $C8F7
			# $AC59 -- the near arm turns at $18 and $78, the far one at
			# $88 and $E8, so that the two never cross.
			var turn := false
			if s[F_SELF] == 0:
				if s[F_VX] >= 0x80:
					turn = s[F_X] < 0x18               # $AC6B
				else:
					turn = s[F_X] >= 0x78              # $AC66
			else:
				if s[F_VX] < 0x80:
					turn = s[F_X] >= 0xE8              # $AC7D
				else:
					turn = s[F_X] < 0x88               # $AC78
			if turn:
				flip_speed_side(s)                     # $C91E
		2:
			s[F_COUNT] = (s[F_COUNT] - 1) & 0xFF
			if s[F_COUNT] == 0:
				s[F_STATE] -= 1                        # $C969
				_walk_4d(s)                            # $ACAF
				return
			if s[F_COUNT] == 0x14:                     # $AC94
				make_child(s, 0x02, 0x06, 0x21)        # $C8DF
			step_anim(s)                               # $C837


## $ACAF -- a fresh walk: how long it lasts is nine to sixteen sixteens of a
## frame, and which way it starts is the die again.
func _walk_4d(s: PackedByteArray) -> void:
	start_anim(s, 0x3D)                                # $BEAD 3D
	var r: int = random()                              # $C939
	s[F_COUNT] = (((r & 0x07) + 0x09
			+ (1 if rng_carry else 0)) << 4) & 0xFF
	set_speed_side_facing(s, 0xFF, 0x80)               # $BEC5 80 FF
	if (random() & 0x01) != 0:                         # $ACC6
		flip_speed_side(s)                             # $C91E


## $9AB2 (bank 10) -- the two arms of the first boss, which do not walk at
## all: they go round it.  Each frame the angle is put on by $0880 -- the low
## half in $05E4 and the high half in $05CE, which is the angle itself -- and
## the place is read off the ellipse $F245 draws round wherever the boss is.
##
## They go out with the boss: when place fifteen is no longer its type, or it
## has begun to die, or its meter has fallen below the line.
func _mind_4f(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_LIFE] = 0x7F                               # $BE5A 7F
		s[F_MARK] = 0x01
		start_anim(s, 0x35)                            # $BEAD 35
		s[F_STATE] += 1                                # $C966
	var b: PackedByteArray = slots[int(cfg_boss["slot"])]
	if b[F_TYPE] != 0x50 or b[F_STATE] >= 0x03 \
			or s[F_LIFE] < 0x6F:                       # $9AC2
		make_burst(n)                                  # $C9C0
		return
	if s[F_STUN] == 0 and (s[F_YHI] | s[F_XHI]) == 0:
		_crush_4f(n, s)                                # $9AE4
	# $9B2B -- the angle, sixteen bits of it, put on by $0880 a frame.
	var t: int = s[F_COUNT] + 0x80
	s[F_COUNT] = t & 0xFF
	s[F_SELF] = (s[F_SELF] + 0x08 + (t >> 8)) & 0xFF
	var off: Array = around(s[F_SELF], 0x00, 0xEC)     # $C88B
	var x: int = ((b[F_XHI] << 8) | b[F_X]) + _signed(off[0])
	s[F_X] = x & 0xFF
	s[F_XHI] = (x >> 8) & 0xFF
	var y: int = ((b[F_YHI] << 8) | b[F_Y]) + _signed(off[1])
	s[F_Y] = y & 0xFF
	s[F_YHI] = (y >> 8) & 0xFF


## $9AE4 -- and on the way round they sweep the first three places clear of
## anything small enough to be crushed.
func _crush_4f(_n: int, s: PackedByteArray) -> void:
	for k in range(1, 4):                              # $9AF0
		var o: PackedByteArray = slots[k]
		if o[F_TYPE] == 0 or o[F_TYPE] >= 0x04:        # $9AF7
			continue
		if abs(o[F_X] - s[F_X]) >= 0x15:               # $9B06
			continue
		if abs(o[F_Y] - s[F_Y]) >= 0x15:               # $9B15
			continue
		clear(k)                                       # $C810


## $9383 (bank 10) -- and what it turns into: a crawl along the ground that
## holds its pose until the pictures reach the last of them, and then counts
## itself out.
func _mind_26(n: int, s: PackedByteArray) -> void:
	match s[F_STATE]:                                  # $C97E
		0:
			# $936A -- the same frame $25 ends on, kept because the table
			# reaches it as a state of its own.
			s[F_TYPE] = 0x26
			s[F_LIFE] = 0xFF                           # $BE5A FF
			s[F_MARK] = 0x01
			start_anim(s, 0x16)                        # $BEAD 16
			s[F_SELF] = 0x80                           # $BE75 80
			Pb2Sound.want(0x27)                        # $937D
			s[F_STATE] = 1                             # $C96F
		1:
			if s[F_KIND] != 0x51:                      # $938F
				step_anim(s)                           # $C837
				return
			start_anim(s, 0x17)                        # $BEAD 17
			s[F_STATE] += 1                            # $C966
		2:
			s[F_SELF] = (s[F_SELF] - 1) & 0xFF
			if s[F_SELF] == 0:
				clear(n)                               # $C810
				return
			step_anim(s)                               # $C837


## $AC0D -- heavy projectile: it bursts when its initial health changes.
func _mind_46(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_LIFE] = int(small_shot_cfg["heavy_life"])
		s[F_MARK] = int(small_shot_cfg["trail_mark"])
		s[F_KIND] = int(small_shot_cfg["heavy_pic"])
		s[F_STATE] += 1
		return
	if s[F_LIFE] != int(small_shot_cfg["heavy_life"]):
		make_burst(n)
		return
	mark_target(n)
	ground_or_die(n, s)


## $B652 -- accelerating missile, ending at the edge or in $B487's burst.
func _mind_3d(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_MARK] = int(small_shot_cfg["bullet_mark"])
		start_anim(s, int(small_shot_cfg["missile_anim"]))
		face_by_speed(s)
		s[F_STATE] += 1
		return
	var left: bool = (s[F_BITS] & 0x40) != 0 # $FD54's carry
	if s[F_XHI] != 0:
		if (left and s[F_XHI] >= 0x80) or (not left and s[F_XHI] < 0x80):
			clear(n)
			return
		var speed: Array = small_shot_cfg["missile_left" if left else "missile_right"]
		set_speed_side(s, int(speed[1]), int(speed[0]))
	if left:
		sub_speed_side(s, int(small_shot_cfg["missile_accel"]))
	else:
		add_speed_side(s, int(small_shot_cfg["missile_accel"]))
	# $B68B -> $C8EE/$FA05: animate, then move on both axes.
	step_anim(s)
	step_both(s)
	mark_target(n)
	_wall_3b(n, s)


## $9A6F -- bullet that becomes a ground flame against a lower wall.
func _mind_48(n: int, s: PackedByteArray) -> void:
	if s[F_STATE] == 0:
		s[F_MARK] = int(small_shot_cfg["bullet_mark"])
		s[F_KIND] = int(small_shot_cfg["flame_pic"])
		s[F_STATE] += 1
		return
	if ground_turn_clear(n, s, 0, 0) < 0x80:
		mark_target(n)
		step_both(s)
		return
	var side: int = int(small_shot_cfg["flame_right" if s[F_VX] >= 0x80 else "flame_left"])
	if s[F_VY] >= 0x80 or ground_turn_clear(n, s, side, 0) < 0x80:
		clear(n)
		return
	snap_down(s)
	s[F_STATE] = 0
	_mind_26(n, s) # $936A: the shared native flame initializer.
	s[F_SELF] = int(small_shot_cfg["flame_ticks"])
