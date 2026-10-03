extends RefCounted
class_name Pb2Turn

## $CEF0 -- one picture of a Power Blade 2 area, in the cartridge's own order.
##
## This order used to live in the mode that draws the game, which was fine
## while that mode was the only thing that ever played an area.  Э5.7 puts a
## second hero into the same area, and the order he is played by has to be the
## same one: two copies of it drift apart, and the copy is what would be under
## test.  So it is a class of its own now, and the mode calls it.
##
## Nothing of the order changed in the move.  What stayed with the mode is
## what the console does after the game has run -- the sprite table, the three
## colours a suit brings with it -- and what the end of a picture means, which
## is the mode's business and not the picture's: the ways a picture can end
## are named here and handed back.

## The picture ran and the area goes on.
const NONE := 0
## $1A := 6 -- something told the level to build itself again; the door at the
## end of an area is what usually does it.
const NEXT_AREA := 1
## $18 := 6 -- the scene between the two halves of the fifth stage.
const INTERLUDE := 2
## $A17A -- no health left, or no time left, and he dies either way.
const DIED := 3
## The suits' menu, or the wearing out of the one he has on, is holding the
## level still: the picture did not run at all.
const HELD := 4

var level: Pb2Level
var world: Pb2Objects
var hero: Pb2Player
var view: Pb2Camera
var status: Pb2Status

## $53 -- the stage the hero walked in from, which a boss room does not change.
var came := 0
## How far the view slid last picture: what the scan of what it uncovered
## needs, and what the hero is shifted back by.
var slid := 0
## Э5.7 -- the two places a second hero changes this order, and the only two.
##
## A pair's view follows the middle of two heroes and not one, so the pair has
## already slid it at the top of its own picture ($CF11) and says so with
## `slid_already`; and the pair steps both heroes and decides from both where
## the view goes next, so it hands that in as `walk` ($CF3B, $CF41 and the
## mirroring after them).  Everything above and below the two is the one order
## and not a copy of it.  Left empty -- which is what the single game leaves
## them -- the order is exactly what it was.
var slid_already := false
## The slide of the picture before, as $CF0E reads it when a pair slid first.
var scan_slid := 0
## SPB2-04.  Recordings made before the fix replay with this off (`exact_scan`
## false in their file); everything live has it on.
static var exact_scan := true
var walk: Callable = Callable()
## A suit changed its colours, and three of them have to be laid over sprite
## palette one.  The mode does that, and the mode clears this.
var repaint := false
## PB3 may own this exact status and have advanced it with the shared gear.
var external_status := false
var external_play := true
var prepared_play := true


func _init(lvl: Pb2Level, w: Pb2Objects, h: Pb2Player, v: Pb2Camera,
		st: Pb2Status) -> void:
	level = lvl
	world = w
	hero = h
	view = v
	status = st


## One step of the game, in the cartridge's own order ($CEF0).
func status_context() -> void:
	status.life = world.slots[0][Pb2Objects.F_LIFE]
	# $53 is the stage the hero walked in from, not the table the room was
	# built out of: a boss room is the seventh table and no stage at all.
	status.stage = came
	# $CEEC and $CA3A -- what the clock has to know: whose room this is, and
	# whether the level is standing still.
	status.boss = world.boss
	status.area = world.area
	status.frozen = world.frozen != 0


## Status runs before the pair camera or either actor can move.
func prepare(pressed: int) -> bool:
	if not external_status:
		status_context()
		if pressed & Pad.SELECT:
			status.spend_life_tank()
	# Pad already keeps the console's own order of the eight, so what it
	# reports is what $48 would hold.
	prepared_play = external_play if external_status else status.step(pressed)
	# $27 -- the level's things write it as well as read it: the boss's meter
	# puts it out of play while it fills and back into play when it is full.
	world.playing = status.mode
	world.slots[0][Pb2Objects.F_LIFE] = status.life
	world.suit = status.suit
	world.power = status.power_level
	world.second = status.second_blade
	world.extra = status.extra_shot
	if status.repaint:
		status.repaint = false
		repaint = true
	if status.clear_shots:
		# $D768 -- what he had in the air belonged to the suit he was wearing.
		status.clear_shots = false
		for k in range(1, Pb2Objects.FIRST_LIVE):
			world.clear(k)
	return prepared_play


func step(held: int, pressed: int, prepared: bool = false) -> int:
	world.pad_held = held                         # $4A: this frame, before contact
	if not prepared:
		prepare(pressed)
	if not prepared_play:
		return HELD
	world.frame = (world.frame + 1) & 0xFF          # $0110
	world.step_colour(status.menu != 0)             # $BF32
	world.status = status
	# $CF00 -- how long the button has been down.
	hero.step_charge(world.frame)
	# $CF08 -- what touches what.
	world.contact()
	# $CF0E -- what the view has uncovered since the last step.
	if slid_already and exact_scan:
		# The pair slid the view at the top of its picture: $CF0E must see the
		# view as it stood before that slide and the slide of the picture
		# before, or what it puts out stands one slide too far over.
		world.scan(view.pos, scan_slid, slid)
		scan_slid = slid
	else:
		world.scan(view.pos, slid)
	# $CF11 -- the view follows him.
	if not slid_already:
		view.drive()
		slid = view.shift
	world.cam = view.pos
	# $CF14 -- the view slid, so everything standing on it slid back.
	world.shift(view.shift)
	# $CF1C -- every thing gets its turn.
	world.turns()
	status.mode = world.playing
	# $1A := 6 -- something has told the level to build itself again.  The
	# door at the end of an area is what usually does it.
	if world.live == 6:
		return NEXT_AREA
	# $18 := 6 -- the scene between the two halves of the fifth stage.  There
	# is nothing to show here yet, so it is over at once and the same area is
	# built again with $AD one, where the same record is a door ($B0D7).
	if world.interlude:
		return INTERLUDE
	# $802F -- once a door has set $2A only the door kinds ($03, $04) take
	# their turn; he is the thing in slot 0 and waits with the rest, so his
	# own step ($8E1D..$8E52: throws, move, $A17A, satellites) is not run.
	# Falling into the door of p5.0 he stops where he touched it (NPB2-20).
	if world.frozen != 0:
		world.push_x = 0
		world.push_y = 0
		world.solids = []
		world.claimed = 0
		world.marks = 0
		world.marks2 = 0
		return NONE
	# $8E26 -- what is already in the air moves first, and only then does
	# $8E29 let go of the next one; $8E2C moves him after both.
	world.shots_turn()
	hero.shift = view.shift
	hero.held = world.held
	hero.suit = world.suit
	# $011F and $0120..$0150, $063C and $0652 -- what the level worked out
	# about him during the turns of the things.  The two pushes are bytes with
	# a sign in them and his own step reads them as numbers.
	hero.solids = world.solids
	hero.push_x = world.push_x - 256 if world.push_x > 127 else world.push_x
	hero.push_y = world.push_y - 256 if world.push_y > 127 else world.push_y
	if walk.is_valid():
		walk.call(world.take_pad, shots_out(), world.extra)
	else:
		# $8BBE -- the break in the middle of the fifth stage takes the pad
		# away and holds it towards the left itself ($48 := 0, $4A := 2).
		if world.take_pad:
			hero.step(Pad.LEFT, 0, view.pos, shots_out(), world.extra)
		else:
			hero.step(held, pressed, view.pos,
					shots_out(), world.extra)
		view.decide(((hero.y if level.vertical else hero.x) >> 8) & 0xFF)
		_mirror_hero()
	# $8E2C -- the fourth suit's two satellites take their turn last of all,
	# after his step has moved him, because the ellipse they walk is measured
	# from where he stands now.
	world.orbit()
	# $8E32..$8E52 -- everything the level said about him this frame ends with
	# his step; the head of the next sweep would wipe it again anyway.
	world.push_x = 0
	world.push_y = 0
	world.solids = []
	world.claimed = 0
	# $8E4C and $8E4F -- and so do the marks the things left for the
	# satellites, which is why a thing has to set its bit on every turn.
	world.marks = 0
	world.marks2 = 0
	# $A17A -- no health left, or no time left, and he dies either way.
	if world.slots[0][Pb2Objects.F_LIFE] == 0 or status.out_of_time:
		return DIED
	return NONE


func shots_out() -> int:
	var n := 0
	for k in range(1, Pb2Objects.FIRST_LIVE):
		if world.slots[k][Pb2Objects.F_TYPE] != 0:
			n += 1
	return n


func _mirror_hero() -> void:
	mirror(world, hero)


## $CF41 -- his numbers into the pool his own throws live in.  Э5.8 asks it of
## a guest's own pool as well: a blade of his looks for him there ($A764), and
## a throw takes its place off the same row ($A4FD).
static func mirror(world: Pb2Objects, hero: Pb2Player) -> void:
	var s: PackedByteArray = world.slots[0]
	s[Pb2Objects.F_KIND] = hero.pose
	s[Pb2Objects.F_BITS] = (s[Pb2Objects.F_BITS] & ~0x40) \
			| (0x40 if hero.face_left else 0)
	s[Pb2Objects.F_X] = (hero.x >> 8) & 0xFF
	s[Pb2Objects.F_XHI] = (hero.x >> 16) & 0xFF
	s[Pb2Objects.F_Y] = (hero.y >> 8) & 0xFF
	s[Pb2Objects.F_YHI] = (hero.y >> 16) & 0xFF
	# $0534:$054A -- how fast he is falling.  A blade thrown straight down
	# rides down with him ($A671 reads it), so it has to be in the table.
	#
	# It is a picture behind what the cartridge reads there, and cannot yet be
	# anything else: the cartridge moves him ($8E20), then sweeps what he has
	# thrown ($8E26), then changes his fall speed again ($8E29 -> $91EF), and
	# here his whole picture is one call.  Splitting him in two belongs with
	# the rest of the step's order and is left for later.
	s[Pb2Objects.F_VY] = (hero.vy >> 8) & 0xFF
	s[Pb2Objects.F_VYFR] = hero.vy & 0xFF
	# $0416 outright.  `Pb2Player.state` is that byte and nothing else: every
	# place the cartridge writes it -- $9E26 with the state ($8EBE $00/$04,
	# $8F89 $08/$05, $8FF5 $10/$07, $A000 $01/$08, $94A6 $04/$10 and the rest),
	# $8EC1 while he swings, $A21A when a throw begins, $99C1 when it ends --
	# has a line of its own in the hero's module.  The sweep reads it for his
	# box ($B2C1, bits three and four), for whether something has hold of him
	# (bits five and six), for whether he is off the ground (bit nought, which
	# a blade thrown down rides on) and for his pose ($BA44 counts the noughts
	# under it), so it is handed over whole rather than rebuilt bit by bit.
	s[Pb2Objects.F_MARK] = hero.state
