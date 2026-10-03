extends RefCounted
class_name Pb3Pair

## Э5.2 -- two heroes in one level, under one view.
##
## Э5.1 made a level answer both games; this makes one picture of a level hold
## both heroes at once.  Three things had to be decided, and each is decided
## the way the games themselves already decide it, not invented:
##
## **Whose view.**  The level's own game's.  A Power Blade 2 area is driven by
## `Pb2Camera` ($D924, $D3B8), a Solbrain stage by `SolCamera` ($F1EA, $F24B).
## Neither is changed; they are simply asked about a point that is not a hero.
##
## **What that point is.**  The middle of the two.  Each camera already takes
## one place and answers "is he outside the band"; handed the middle, it keeps
## the middle in the band, which is what the band is for.  Solbrain's view
## also wants a speed, because it follows by *his* speed and not by the gap
## ($F1EA); the middle's own speed -- where it is now less where it was -- is
## that number, and it is a whole number of sixteenths like his.
##
## **Where a hero is.**  The two games keep their heroes in different frames:
## Solbrain's place ($80:$81, $82:$83) is the level's, in sixteenths of a
## pixel, sixteen pixels above his feet; Power Blade's ($0300, $0320) is the
## screen's, in two-hundred-fifty-sixths, at his feet.  Everything here is
## said once, in the level's own pixels at the hero's feet, and `world_of` and
## `place_at` are the only two places that know the difference.
##
## The edge of the screen is what holds the two together.  The view follows
## the middle, so a hero reaches an edge only when the two are more than a
## screen apart, and then he is held at it -- along the ways the view can
## move, and no other, because across a way the view cannot move the edge is
## the level's own business and holding him there would be fighting the floor.

## Which game the level came from.
const PB2 := 0
const SOL := 1

## How near the edge of the screen a hero may come, in pixels.  He is sixteen
## across, so this is his shoulder against the edge.
const EDGE := 8
## And how tall he is.  Nothing is held by this -- downwards the floors hold
## him -- but it is what says whether a place is one the view can ever bring
## to the screen with his head on it (`_pb3_band` in the mode).
const HEAD := 24

## The band the view keeps the middle of them in, said in pixels of the
## screen and measured at the feet.  Power Blade's two are its own ($D404 and
## $D406); Solbrain's are its own as well ($E6B3 across, $F352 down), but its
## view measures from sixteen pixels above the feet, so both of those are said
## here sixteen lower.
const PB2_BAND_X := [0x70, 0x90]
const PB2_BAND_Y := [0x60, 0x68]
const SOL_BAND_X := [0x70, 0x80]
const SOL_BAND_Y := [0x70, 0x90]

var game := PB2
## The level as each hero's own game asks it -- one of the two is a borrowed
## class from Э5.1, and which one depends on where the level came from.
var pb2v: Pb2Level
var solv: SolLevel
## The same object as `pb2v` when the level is a Solbrain stage, and nothing
## when it is not: only the borrowed class has a window to move.
var down: SolAsPb2
## A Power Blade area's own view.  In a Solbrain stage one is still kept,
## because a Power Blade hero reads the map through it, but it is led by the
## number below rather than by anything it decided itself.
var eye: Pb2Camera
var sol_eye: SolCamera

## Per hero: which game he came from, and the one of these two that he is.
var who: Array[int] = []
var pb2: Array = []
var sol: Array = []
var things: Array = []
## A hero whose feet have gone out of the bottom of the level.  One of these
## does not end the picture: the other is still playing.
var gone: Array[bool] = []
## The pad as it stood last picture, so that a Power Blade hero is told what
## was newly pressed: $C882 keeps the picture before and $8EC1 needs the edge
## to start him walking.  Solbrain's hero keeps his own copy ($94A5).
var last_pad: Array[int] = []

## How far the view slid since the heroes last took a picture, in pixels.
var slid := Vector2i.ZERO
## $60 of a Solbrain view, which the cartridge has no name for: how far it was
## asked at the end of the last picture to slide at the start of this one.
var sol_pending := Vector2i.ZERO
## The Solbrain view the heroes last measured themselves against, in pixels.
## A stage script ($A835/$A867 and others) may move the view after the heroes
## took their picture; that motion belongs to the next `slid`, not to nobody.
var sol_seen := Vector2i(-1, -1)
## $75 as the Power Blade heroes last stood on it, -1 off the carrying map.
var ride_seen := -1
## The middle of the two as it stood at the end of the last picture, in
## sixteenths, at the height Solbrain's own view is measured from.
var started := false

## How many pictures a hero was held at an edge, and how many times holding
## him there would have put him inside something solid and so was not done.
var held_in := 0
var could_not := 0
## How far each of them was moved by the edge this picture, so that a walk can
## tell a fall from a shove.
var shoved: Array[Vector2i] = []
## And where each of them stood at the end of the last picture, in the level's
## own pixels: the view is given a speed, and this is what it is worked out
## from.
var was_at: Array[Vector2i] = []

## Which record the level came from, which the level itself does not keep.
var stage := 0
var area := 0
## $53 -- the stage the hero walked in from, which is not always the table the
## room was built out of: the boss rooms are the seventh table and belong to no
## stage of their own, so walking into one leaves $53 where it was ($86F0 and
## $84F6 touch $79 and $9C and not $53).  A record stood up cold was walked
## into from nowhere, so a boss room is given the first stage and the clock has
## a number to read.
var came := 0


# ---- Э5.7: the level's own game, running under the two of them ------------

## Whether the level's own things are running at all.  Э5.2 to Э5.6 walk two
## heroes through an empty level and nothing else; `begin(spots, true)` is what
## opens it.
var flowing := false
## The things of the level.  They belong to the level and not to a hero: one
## area has one pool of them however many heroes walk in it, and only the game
## the level came from has one here.
var host_pb2: Pb2Objects = null
var host_sol: SolObjects = null
var host_script: SolScript = null
var host_fade: SolFade = null
var host_table: SolSprites.Table = null
var host_status: Pb2Status = null
## The order of one picture: the level's own, $CEF0 or $CDB3, and the very
## same class the single game plays.
var turn_pb2: Pb2Turn = null
var turn_sol: SolTurn = null
## Which of the two heroes stands in the one place the level's own game keeps
## for a hero ($0400 in a Power Blade area, $80 in a Solbrain stage), and below
## nought when neither of them came from that game: then the place is held by a
## hero nothing ever steps, which is how both cartridges are told there is
## nobody in it ($B23D reads no life left, $CFDB reads no suit).
var host := -1
var spare_pb2: Pb2Player = null
var spare_sol: SolPlayer = null
## Everyone who is not that one is a guest of the level (Э5.4).  Per hero:
## his row in a Power Blade pool, or the `SolPlayer` a Solbrain pool reads him
## through, and the entry in the pool that carries his box.
var guest_row: Array = []
var guest_sol: Array = []
var guest_at: Array = []
## A pool of his own game, borrowed.  Э5.7 wanted it only to work out the box
## his own game gives him -- his picture means nothing to the other game's
## tables -- and Э5.8 keeps his weapons in it as well.
var guest_pool: Array = []
## Э5.8 -- what each of them is carrying, said in the level's own numbers.  One
## list a hero, the same list all the way through so that the pool it is handed
## to keeps looking at the live one; each entry `[x, y, reach, power]`.
var arms: Array = []
## And where each of those came from in his own pool, so that what the level
## says a thing cost it can be taken off the right thing: `[which pool, slot]`,
## where the pool is nought for what he throws and one for his own four.
var arms_from: Array = []
## How many pictures a guest had anything of his own in the air, and how many
## times one of those reached a thing of the level.  Nothing in the pair reads
## them; they are what a stand counts by.
var arms_flying := 0
var arms_landed := 0
## What the last picture ended as, in `Pb2Turn`'s words.
var ended := 0
## The pads of the picture being played, because the order calls back into
## here to step the heroes and has no pads of its own to hand over.
var pads_now: Array = []
## Enabled by the playable session; isolated cartridge stands keep their
## original inputs. A dead host must not block a surviving guest's script.
var live_session := false
## A Solbrain guest borrows the native ladder controller only while on a
## PB2 ladder. Speeds, mounting and dismounting come from $94A9/$A003.
var climbers: Dictionary = {}


## Break RefCounted cycles when the session leaves an area. The callbacks
## point back to this pair, and a Solbrain hero and pool own each other.
func release() -> void:
	if turn_pb2 != null:
		turn_pb2.walk = Callable()
	if turn_sol != null:
		turn_sol.walk = Callable()
	if host_pb2 != null:
		host_pb2.guest_arms.clear()
	if host_sol != null:
		host_sol.guest_arms.clear()
		host_sol.hero = null
	for pool in things:
		if pool != null:
			pool.terrain_strike = Callable()
	for p in sol:
		if p != null:
			p.pool = null
	for pool in guest_pool:
		if pool != null:
			pool.hero = null
			pool.stage_pool = null
	if spare_sol != null:
		spare_sol.pool = null


## `kinds` is one of `PB2`/`SOL` a hero, in the order their pads come.
func _init(from: int, st: int, ar: int, kinds: Array) -> void:
	game = from
	stage = st
	area = ar
	# $84FE/$86F7 keep $53 while $79 selects the boss table. A menu
	# entry has no preceding door, so recover its stage from that table.
	came = ar % Pb2Objects.BOSS_STAGE if game == PB2 and st == Pb2Objects.BOSS_STAGE else st
	if game == PB2:
		var src := Pb2Level.new(st, ar)
		pb2v = src
		solv = Pb2AsSol.new(src)
		eye = Pb2Camera.new(pb2v)
	else:
		var src := SolLevel.new(st)
		solv = src
		down = SolAsPb2.new(src)
		pb2v = down
		sol_eye = SolCamera.new(solv)
		eye = Pb2Camera.new(pb2v)
	for one in kinds:
		var k: int = one if one is int else (SOL if String(one) == "sol"
				else PB2)
		who.append(k)
		last_pad.append(0)
		arms.append([])
		arms_from.append([])
		shoved.append(Vector2i.ZERO)
		was_at.append(Vector2i.ZERO)
		gone.append(false)
		if k == PB2:
			var w := Pb2Objects.new(pb2v)
			var p := Pb2Player.new(pb2v)
			p.world = w
			things.append(w)
			pb2.append(p)
			sol.append(null)
		else:
			var p := SolPlayer.new(solv)
			things.append(null)
			pb2.append(null)
			sol.append(p)


# ---- where the screen is --------------------------------------------------

## The level pixel shown at the left of the screen.
func view_x() -> int:
	if game == SOL:
		return (sol_eye.x >> 4) & 0xFFFF
	return 0 if pb2v.vertical else eye.pos


## Which line of the level a line of the screen shows.
##
## A Power Blade area that scrolls downwards is the one place this is not a
## sum: the console keeps the level in pages of two hundred and forty lines
## and reads it in pages of two hundred and fifty six, and $F52C mends the
## difference as it reads.  `Pb2Level.map_row` is that mending.
func line_at(sy: int) -> int:
	if game == PB2:
		if pb2v.vertical:
			return Pb2Level.map_row(eye.pos, sy)
		# A sideways area is one screen tall and the top sixteen lines of the
		# screen are the bar, so the map begins at line sixteen of the screen.
		return sy - Pb2Objects.VIEW_TOP
	return (sol_eye.y >> 4) + sy


## A line of the map counted straight down from the top, with the sixteen
## empty lines at the foot of every page left out.  This is the numbering the
## view of an area that scrolls downwards keeps ($66:$67, low byte to two
## hundred and forty).
static func _flat(map_row: int) -> int:
	return (map_row >> 8) * 240 + mini(map_row & 0xFF, 239)


## And the other way about.
func screen_line(ly: int) -> int:
	if game == PB2 and pb2v.vertical:
		var sy: int = ly - eye.pos
		if line_at(sy) != ly:
			sy -= 16
		return sy
	return ly - line_at(0)


# ---- where a hero is ------------------------------------------------------

func _map_y(y: int) -> int:
	return (solv as Pb2AsSol).map_y(y) if game == PB2 else y


func _hero_y(y: int) -> int:
	return (solv as Pb2AsSol).hero_y(y) if game == PB2 else y


## His feet, in the level's own pixels.
func world_of(i: int) -> Vector2i:
	if who[i] == SOL:
		var p: SolPlayer = sol[i]
		return Vector2i((p.x >> 4) & 0xFFFF,
				_map_y(((p.y >> 4) & 0xFFFF) + SolPlayer.FOOT_DY / 16))
	var q: Pb2Player = pb2[i]
	return Vector2i(view_x() + ((q.x >> 8) & 0xFF),
			line_at((q.y >> 8) & 0xFF))


## Put him there, his feet on that pixel.
func place_at(i: int, w: Vector2i) -> void:
	if who[i] == SOL:
		var p: SolPlayer = sol[i]
		p.place(w.x << 4, (_hero_y(w.y) - SolPlayer.FOOT_DY / 16) << 4)
		# $948D -- under two and thirty the pad does not reach him at all
		# ($94A5), and `place` puts the count back to nought.  He is meant to
		# be already standing here, not to have just arrived.
		p.timer = 0xFF
		return
	var q: Pb2Player = pb2[i]
	q.place(w.x - view_x(), screen_line(w.y), view_x())


## Where he is on the screen, his feet.
func screen_of(i: int) -> Vector2i:
	var w: Vector2i = world_of(i)
	return Vector2i(w.x - view_x(), screen_line(w.y))


## Where his feet are, said in lines that run on without a gap.  A vertical
## Power Blade area leaves the last sixteen lines of every page of the map
## empty, so two map lines cannot be taken from one another and two of these
## can: this is the number to measure a fall or a distance with.
func flat_of(i: int) -> Vector2i:
	var w: Vector2i = world_of(i)
	if game == PB2 and pb2v.vertical:
		return Vector2i(w.x, _flat(w.y))
	return w


## Э5.6 -- where the level itself puts a hero when it opens, said in the
## level's own pixels at his feet.
##
## A Solbrain stage says it outright: $E520 raises the stage out of a record
## and the record holds the place ($80:$83, sixteen pixels above his feet).  A
## Power Blade area says it on the screen instead ($0300 and $0320), which is
## only half the answer: the view the area opens with ($D3B8) is the other
## half.  A fresh `Pb2Camera` already stands where the area opens, so the two
## halves are put together by the same pair of sums every other place in this
## class is read through -- and that matters twice over, because a sideways
## area keeps the top sixteen lines of the screen for the bar and a downward
## one counts its view in pages of two hundred and forty while its map is laid
## out in pages of two hundred and fifty six.  Asked before `begin`, which is
## the only time it means anything.
func home() -> Vector2i:
	if game == SOL:
		return Vector2i(solv.start.x >> 4,
				(solv.start.y >> 4) + SolPlayer.FOOT_DY / 16)
	return Vector2i(view_x() + pb2v.start_x, line_at(pb2v.start_y))


## Whether a hero standing with his feet on that pixel is standing in
## something.  What the level says, and nothing of the pair's own.
func standing(w: Vector2i) -> bool:
	return not _solid(w)


## Э5.6 -- whether there is anything under that pixel at all, asked straight
## down its own column to the foot of the level.  Neither game promises it:
## one Power Blade area opens over water with no floor beneath it anywhere in
## that column, and a hero put there sinks out of the level because that is
## what the level says happens there.  The list has to be able to tell that
## apart from a hero the engine dropped, so the level is asked outright.
func ground_under(w: Vector2i) -> bool:
	var y: int = w.y
	var bottom: int = solv.height_tiles * 8
	while y < bottom:
		if _solid(Vector2i(w.x, y)):
			return true
		y += 8
	return false


## Where each of them stood when the picture ended, for the next picture's
## sums.
func _remember() -> void:
	for i in range(who.size()):
		was_at[i] = flat_of(i)


# ---- the picture ----------------------------------------------------------

## Put both of them down and set the view around them.
##
## Э5.7 -- `flow` raises the level's own game round them as well: its things,
## its order and, in a Solbrain stage, its script.  Left off, the level is
## empty and only the two of them and the view move, which is what Э5.2 to
## Э5.6 walk.
func begin(spots: Array, flow: bool = false) -> void:
	# The view first, so that the middle of them is the middle of the screen,
	# and then the two: a Power Blade hero's place is read off the view.
	var mid := Vector2i.ZERO
	for s in spots:
		mid += Vector2i(s)
	mid /= spots.size()
	if game == SOL:
		# $E70C rounds the view down to a whole room, which is what raising a
		# stage wants; putting two down in the middle of one wants the middle
		# of them in the middle of the screen instead, and the stage's own two
		# ends ($E72D) are what stops it going too far.
		sol_eye.x = clampi((mid.x << 4) - 0x800, sol_eye.x_min,
				maxi(sol_eye.x_min, sol_eye.x_end - 0x1000))
		sol_eye.y = clampi((mid.y << 4) - 0x780, sol_eye.y_min,
				maxi(sol_eye.y_min, sol_eye.y_end - 0x1000))
		# Those two ends are the ones the view is *driven* between ($E72D);
		# the raise itself does not consult them at all -- $E70C simply
		# rounds the hero down to a whole room -- and the third stage begins
		# below its own bottom end, so keeping to the ends there would leave
		# the place the stage puts a hero off the screen.  Where that
		# happens the cartridge's own raise is taken instead.
		if mid.x < (sol_eye.x >> 4) or mid.x >= (sol_eye.x >> 4) + 0x100:
			sol_eye.x = (mid.x << 4) & 0xF000
		if mid.y < (sol_eye.y >> 4) or mid.y >= (sol_eye.y >> 4) + 0xF0:
			sol_eye.y = (mid.y << 4) & 0xF000
		sol_seen = Vector2i(sol_eye.x >> 4, sol_eye.y >> 4)
		_led_by_sol()
	elif pb2v.vertical:
		# The view of an area that scrolls downwards is counted in pages of
		# two hundred and forty lines while the map is laid out in pages of
		# two hundred and fifty six with the last sixteen of each left empty,
		# so the middle of the screen is not simply the middle line less a
		# hundred and twenty: the two numberings have to be gone between.
		var flat: int = clampi(_flat(mid.y) - 0x78, 0,
				maxi(0, pb2v.cam_limit_page * 240 + pb2v.cam_limit_low))
		eye.place(flat / 240, flat % 240, 0, 0)
	else:
		var want: int = clampi(mid.x - 0x80, 0,
				maxi(0, pb2v.width_tiles * 8 - 0x100))
		eye.place(want >> 8, want & 0xFF, 0, 0)
	for i in range(spots.size()):
		place_at(i, Vector2i(spots[i]))
	_remember()
	started = true
	flowing = flow
	if flowing:
		_raise_flow()


## Э5.7 -- the level's own game, raised round the two of them.
##
## One pool of things, belonging to the level and not to a hero, stepped by the
## level's own order -- the very class the single game plays, with the two
## places a second hero changes handed in (`Pb2Turn.walk`, `SolTurn.walk`).
##
## Whichever of the two came from the game the level did stands in the one
## place that game keeps for a hero; every other is a guest of it (Э5.4).  When
## neither came from it the place is held by a hero nothing ever steps, with no
## health in a Power Blade area ($B23D) and no suit in a Solbrain stage
## ($CFDB), which is how each cartridge is told there is nobody there.
func _raise_flow() -> void:
	for i in range(who.size()):
		guest_row.append(null)
		guest_sol.append(null)
		guest_at.append(null)
		guest_pool.append(null)
		if who[i] == game and host < 0:
			host = i
	if game == PB2:
		host_pb2 = Pb2Objects.new(pb2v)
		host_status = Pb2Status.new()
		host_pb2.status = host_status
		host_pb2.came = came
		if stage == Pb2Objects.BOSS_STAGE:
			host_pb2.boss = 1 # $84FE/$86F7: the door has set $79.
		host_pb2.suit = host_status.suit
		host_pb2.power = host_status.power_level
		host_pb2.second = host_status.second_blade
		host_pb2.extra = host_status.extra_shot
		# $CE45 -- an area opened on its own is the top of a stage as far as
		# the clock is concerned.
		host_status.restart_time(came, 0)
		# The area has just opened, so everything already on the screen comes
		# out at once rather than waiting for the view to move ($E3F3).
		host_pb2.fill = 1
		host_pb2.slots[0][Pb2Objects.F_TYPE] = 0x01
		host_pb2.slots[0][Pb2Objects.F_LIFE] = 0
		if host >= 0:
			# His own pool was only ever a place for his own sums to live; in
			# a room with things in it there is one pool and it is this one.
			var q: Pb2Player = pb2[host]
			q.world = host_pb2
			things[host] = host_pb2
			host_pb2.slots[0][Pb2Objects.F_LIFE] = 0x10
		else:
			spare_pb2 = Pb2Player.new(pb2v)
			spare_pb2.world = host_pb2
		turn_pb2 = Pb2Turn.new(pb2v, host_pb2,
				pb2[host] if host >= 0 else spare_pb2, eye, host_status)
		turn_pb2.slid_already = true
		turn_pb2.walk = _walk_pb2
		turn_pb2.came = came
	else:
		host_sol = SolObjects.new(solv)
		host_script = SolScript.new()
		host_table = SolSprites.Table.new()
		# $C01B/$C030: flat projectiles draw through the pool, not step(t).
		host_sol.table = host_table
		for i in range(4):
			host_table.banks[i] = solv.spr_banks[i]
		# $C72D never wipes the first eight entries: that corner of the table
		# belongs to the strip.
		for i in range(0, SolSprites.FWD_START, 4):
			host_table.oam[i] = SolSprites.HIDDEN
		# $E788 gave it an empty pool and every spawn still to come; what is
		# left is where the view stands and that the first picture owes a scan.
		host_sol.seen_x = sol_eye.x
		host_sol.seen_y = sol_eye.y
		host_sol.col_due = 0xFF
		host_sol.row_due = 0xFF
		host_sol.stage = stage
		host_sol.room = host_sol.room_of(sol_eye.x, sol_eye.y)
		if host >= 0:
			host_sol.hero = sol[host]
			sol[host].pool = host_sol
		else:
			spare_sol = SolPlayer.new(solv)
			spare_sol.suit = 0
			host_sol.hero = spare_sol
		turn_sol = SolTurn.new(host_sol.hero, host_sol, sol_eye, host_script,
				host_table, null)
		turn_sol.slid_already = true
		turn_sol.walk = _walk_sol
	for i in range(who.size()):
		if i == host:
			continue
		if who[i] == SOL:
			# A pool of his own game.  It began as something only ever
			# asked what box his picture gives him ($80DE); Э5.7 gave it a
			# step of its own, so that what he throws flies.
			guest_pool[i] = SolObjects.new(solv)
			# Э7.5 -- and what it throws has to be written down as it is
			# drawn: his pool is stepped with a pretended view, so the only
			# way onto the picture is to lay it out again afterwards.
			guest_pool[i].w_keep = true
			# ITM-01 -- what he breaks out of the stage is the stage's.
			guest_pool[i].stage_pool = host_sol
		if game == PB2:
			var row := Pb2Objects.empty_row()
			row[Pb2Objects.F_LIFE] = 0x10
			guest_row[i] = row
			guest_at[i] = [row, [0x0F, 6, 13], 0, 0, false]
			host_pb2.more_guests.append(guest_at[i])
			host_pb2.guest_arms.append([arms[i], _arm_spent.bind(i)])
		else:
			var carrier := SolPlayer.new(solv)
			carrier.suit = _health_sol(i)
			carrier.timer = 0xFF
			guest_sol[i] = carrier
			guest_at[i] = [carrier, [0x01, 0, 0, 0x10, 0x10]]
			host_sol.more_guests.append(guest_at[i])
			host_sol.guest_arms.append([arms[i], _arm_spent.bind(i)])
	_mirror_them()


## One picture of both of them and of the view.
## An equipment refill owned by any participant freezes the shared world.
var force_hold := false

func step(pads: Array) -> void:
	pads_now = pads
	ended = Pb2Turn.NONE
	if turn_pb2 != null:
		turn_pb2.came = came
		var held: int = int(pads[host]) if host >= 0 else 0
		var hit: int = held & ~last_pad[host] if host >= 0 else 0
		var ready: bool = turn_pb2.prepare(hit)
		if not ready or force_hold:
			ended = Pb2Turn.HELD
			latch_input(pads)
			return
	elif force_hold:
		ended = Pb2Turn.HELD
		latch_input(pads)
		return
	# $D924 -- a Power Blade area slides by what was decided last picture,
	# before anybody moves.  A Solbrain stage moved at the end of the last
	# picture instead, because its view is worked out from where the hero
	# ended up ($F1EA runs after him); either way, what the view did since
	# they last looked is `slid`, and a Power Blade hero slides back by it.
	# The view slides first, by what was decided at the end of the last
	# picture -- $D924 for Power Blade, and the same split kept for Solbrain
	# so that everybody in the picture is measured against one view.
	if game == PB2:
		eye.drive()
		slid = Vector2i(eye.shift, 0) if not pb2v.vertical \
				else Vector2i(0, eye.shift)
	else:
		var was_eye := Vector2i(sol_eye.x >> 4, sol_eye.y >> 4)
		if sol_seen.x >= 0:
			was_eye = sol_seen
		_sol_move(sol_pending)
		sol_pending = Vector2i.ZERO
		slid = Vector2i((sol_eye.x >> 4) - was_eye.x,
				(sol_eye.y >> 4) - was_eye.y)
		sol_seen = Vector2i(sol_eye.x >> 4, sol_eye.y >> 4)
		_led_by_sol()
	pads_now = pads
	ended = Pb2Turn.NONE
	if turn_pb2 != null:
		turn_pb2.slid = slid.y if pb2v.vertical else slid.x
		turn_pb2.came = came
		var held: int = int(pads[host]) if host >= 0 else 0
		var hit: int = held & ~last_pad[host] if host >= 0 else 0
		# $B5B7/$B5BC belong to the actor touching the gate. Refresh before
		# contact, so P2 cannot borrow P1's UP or use last frame's buttons.
		for i in range(who.size()):
			if guest_at[i] == null:
				continue
			guest_at[i][3] = int(pads[i])
			guest_at[i][4] = _pb2_gate_ready(i)
		ended = turn_pb2.step(held, hit, true)
		# With nobody of this game in the room the empty place at $0400 has no
		# health, and $A17A reads that as a death.  It is not one: the two who
		# are really here are guests, and how they end is asked of them.
		if host < 0 and ended == Pb2Turn.DIED:
			ended = Pb2Turn.NONE
	elif turn_sol != null:
		if host_fade != null:
			_sol_fade_tick()
		_stand_in()
		turn_sol.step(int(pads[host]) if host >= 0 else 0)
	else:
		_walk_them()
	for i in range(who.size()):
		if live_session and who[i] == PB2 and (pb2[i].dead or _off_foot(i)):
			gone[i] = true
		if live_session and game == PB2 and who[i] == SOL:
			var p: SolPlayer = sol[i]
			var feet: int = (p.y >> 4) + 16
			for dx in [-6, 5]:
				for dy in [0, -4, -14, -30]:
					if p.bridge_compact and dy < -14:
						continue
					if (solv as Pb2AsSol).hurts_at((p.x >> 4) + dx, feet + dy):
						gone[i] = true
		if not _sol_departing(i) and world_of(i).y >= solv.height_tiles * 8:
			gone[i] = true


## $A17A..$A191 -- a Power Blade hero whose feet are off the foot of the
## screen is dead: $04B0 one or more screens down, or $04C6 at $C7 or past it
## (a negative $04B0 still reaches the $C7 test).  On a sideways map this is
## the pit; in an area that climbs by itself ($2E) it is the screen leaving
## him behind.  Without it the safety clamp below pins him at line $EF for
## ever (NPB-03, p0.5).
func _off_foot(i: int) -> bool:
	if game != PB2 or pb2[i] == null:
		return false
	var hi: int = (pb2[i].y >> 16) & 0xFF
	if hi != 0 and hi < 0x80:
		return true
	return ((pb2[i].y >> 8) & 0xFF) >= 0xC7


## The controller is polled even when world motion is paused. A held jump
## must not become a fresh jump when the refill/menu releases the world.
func latch_input(pads: Array) -> void:
	for i in range(who.size()):
		last_pad[i] = int(pads[i])
		if who[i] == SOL:
			sol[i].pad_held = int(pads[i])


## Where the hero nobody steps stands, when the stage has no hero of its own in
## it.
##
## $CF11 asks the stage where he is, because a stage puts its things out round
## him ($E3F3 reads $80 along with the corner of the view), so with nobody there
## the stage would put nothing out at all.  He is stood in the middle of the two
## who really are there -- the same middle the view follows, and for the same
## reason: it is the one place in the room that belongs to both of them.  He
## still has no suit, so nothing ever touches him ($CFDB).
func _stand_in() -> void:
	if host >= 0 and (not live_session or not gone[host]):
		return
	if spare_sol == null:
		spare_sol = SolPlayer.new(solv)
	if live_session:
		spare_sol.pool = host_sol
		turn_sol.hero = spare_sol
		host_sol.hero = spare_sol
		turn_sol.script_proxy = true
	# $AC1C hands the actor to $96FF. Keep that native animation alive:
	# replacing it with a fresh standing proxy would stall the boss entrance.
	if live_session and spare_sol.state == 0x11:
		spare_sol.suit = 8
		return
	var mid := Vector2i.ZERO
	var n := 0
	for i in range(who.size()):
		if gone[i]:
			continue
		mid += _sol_script_feet(i)
		n += 1
	if n == 0:
		return
	mid /= n
	spare_sol.place(mid.x << 4, (mid.y - SolPlayer.FOOT_DY / 16) << 4)
	# $A87C and other exits require a living script actor. Contact still
	# uses the real guest mirrors; SolTurn clears this after the script.
	spare_sol.suit = 8 if live_session else 0
	if live_session:
		var grounded := true
		for i in range(who.size()):
			if not gone[i] and who[i] == PB2:
				grounded = grounded and pb2[i].sub in [Pb2Player.SUB_GROUND,
						Pb2Player.SUB_CROUCH, Pb2Player.SUB_LANDED]
		spare_sol.state = SolPlayer.ST_GROUND if grounded else SolPlayer.ST_AIR
		# $AB6A checks the native standing picture, not merely coordinates.
		spare_sol._pose(0x00 if grounded else 0x06)


## A script's standing height is measured from the support surface. Native
## Nova rests one pixel above it; Solbrain's $82:$83 position is 16 pixels
## above it. Convert the anchor here, without moving art or collision boxes.
## $A294/$A98C/$ADF4 and other entrances compare an exact standing row.
func _sol_script_feet(i: int) -> Vector2i:
	var feet := world_of(i)
	if who[i] == PB2 and pb2[i].sub in [Pb2Player.SUB_GROUND,
			Pb2Player.SUB_CROUCH, Pb2Player.SUB_LANDED]:
		feet.y += 1
	return feet


## The two of them and the view, which is where the level's own order calls
## back into ($CF3B for a Power Blade area, $91B5 for a Solbrain stage).
## `take_pad`, `shots` and `extra` are the three things a Power Blade area
## tells its own hero at $CF3B and has no way of telling a guest; a level with
## no order running has none of them.
func _walk_them(take_pad: bool = false, shots: int = 0,
		extra: int = 0, hold: int = 0) -> void:
	var pads: Array = pads_now
	for i in range(who.size()):
		shoved[i] = Vector2i.ZERO
		if gone[i]:
			continue
		if live_session and game == SOL and i != host and (hold == 0 or hold >= 0x30):
			# $948D normally advances this in the hero's own step. The contact
			# proxy does not move, but must recover from $8354's hit cooldown.
			guest_sol[i].timer = mini(255, guest_sol[i].timer + 1)
		if live_session and game == PB2 and host_pb2 != null:
			_supply_surfaces(i)

		if who[i] == SOL:
			# Solbrain's hero works out for himself what was newly pressed
			# ($C882 keeps the picture before), so he is handed the pad whole.
			#
			# $91AC -- and in his own stage, while the wait for a satellite is
			# between one and $2F, $9477 is not called at all.  A guest of the
			# stage waits with it: the wait is the stage's and not his own.
			if live_session and game == PB2 and _sol_traversal(i, int(pads[i])):
				pass
			elif game == SOL and hold != 0 and hold < 0x30:
				sol[i].skip(int(pads[i]))
			else:
				var before := Vector2i(sol[i].x, sol[i].y)
				sol[i].step(int(pads[i]))
				if live_session and game == PB2:
					_sweep_sol(sol[i], before, int(pads[i]))
			# Э5.8 -- and then his own weapons, because that is the order his
			# own game keeps them in: he moves at $91B5, what he threw at
			# $B168, and his own four at $9156.
			if flowing and i != host:
				_arms_turn_sol(i, int(pads[i]))
			continue
		var q: Pb2Player = pb2[i]
		q.combo_slide = live_session
		q.net_enabled = live_session and game == SOL
		var v: Pb2Objects = things[i]
		v.cam = eye.pos
		# Э5.8 -- and his, in his own game's order the other way about: what
		# is already in the air moves first ($8E26) and he moves after it
		# ($8E2C).  The area's own hero has had both done for him by the
		# order itself.
		if flowing and i != host:
			_arms_turn_pb2(i)
		if game == PB2 and pb2v.vertical:
			q.shift = slid.y
			q.shift_y = 0
		else:
			q.shift = slid.x
			q.shift_y = slid.y
		if game == SOL:
			# $D065/$D079 -- the lift carries whoever stands on its line:
			# the view rose by `slid` and the line moved by what $75 did, so
			# a hero on it ($A126, only while he stands) goes with both.
			q.push_y = 0
			if down.ride_line >= 0 and ride_seen >= 0:
				q.push_y = host_sol.z75 - ride_seen + slid.y
		var held: int = int(pads[i])
		var hit: int = held & ~last_pad[i]
		last_pad[i] = held
		# $8BBE -- the break in the middle of the fifth stage takes the pad
		# away from whoever the area's own hero is and holds it towards the
		# left itself.  A guest is left his own pad: the break is a thing the
		# area does to its hero, and a guest has no part in it.
		if i == host and take_pad:
			q.step(Pad.LEFT, 0, eye.pos, shots, extra)
		elif i == host:
			q.step(held, hit, eye.pos, shots, extra)
		else:
			q.step(held, hit, eye.pos, 0, 0)
			if live_session and game == SOL and q.touched_sol_hazard:
				# $9FA5: use Solbrain's terrain damage and native grace timer.
				guest_sol[i]._wound()
			# $CF41 -- and his numbers into his own pool, where a blade of his
			# looks for him when it turns round ($A764).
			if flowing:
				Pb2Turn.mirror(v, q)
	if game == SOL:
		ride_seen = host_sol.z75 if down.ride_line >= 0 else -1
	_drive_view()
	_hold_them_in()
	_mirror_them()


## The foreign map has thin ledges that fall between Solbrain's two side
## probes ($A411). Sweep the whole standing body so a jump cannot start with
## his chest inside a ledge. One substep is at most one pixel, in integers.
##
## Crouched, the body is his own crouching box ($80DE: middle ten above his
## feet, ten each way), so its top is twenty above his feet, not thirty-two.
## A PB2 hero crouches under a low ledge on a lift (p0.4); so must he.
const SOL_STANDING_DY := [-15, -8, 0, 8, 15]
const SOL_CROUCHED_DY := [-4, 0, 8, 15]

func _sol_clear(h: SolPlayer, at: Vector2i) -> bool:
	var body: Array = SOL_CROUCHED_DY if h.state == SolPlayer.ST_CROUCH \
			else SOL_STANDING_DY
	for dx in [-5, 0, 5]:
		for dy in body:
			var p := at + Vector2i(dx, dy) * 16
			if solv.collision_at(p.x >> 4, p.y >> 4) >= Pb2AsSol.SOLID:
				return false
			for b in h.bridge_solids:
				if p.x >= b[0] and p.x <= b[1] and p.y >= b[2] and p.y <= b[3]:
					return false
	return true


func _sweep_sol(h: SolPlayer, before: Vector2i, pad: int) -> void:
	if not _sol_clear(h, before):
		return
	var wanted := Vector2i(h.x, h.y)
	var at := before
	for axis in range(2):
		var remaining: int = wanted[axis] - at[axis]
		# Wrapped coordinates are an exit, not a 4096-pixel sweep.
		if absi(remaining) > 256:
			return
		while remaining != 0:
			var delta: int = clampi(remaining, -16, 16)
			var next := at
			next[axis] += delta
			if not _sol_clear(h, next):
				if axis == 0:
					h.vx = 0
					h.speed = 0
				else:
					h.vy = 0
					h.rise = 0
					if delta > 0:
						h._settle(pad)
				break
			at = next
			remaining -= delta
	h.x = at.x
	h.y = at.y


## $B91C exposes both the box and the motion of a platform to every guest.
## A native hero's push cannot be reused: each player can ride a different one.
func _platform_boxes() -> Array:
	var boxes: Array = host_pb2.solids.duplicate()
	for surface in host_pb2.guest_surfaces:
		if not boxes.has(surface[0]):
			boxes.append(surface[0])
	return boxes


func _supply_surfaces(i: int) -> void:
	var boxes := _platform_boxes()
	var carry := Vector2i.ZERO
	var feet: Vector2i = screen_of(i)
	for surface in host_pb2.guest_surfaces:
		var box: Array = surface[0]
		var dx: int = surface[1]
		var dy: int = surface[2]
		if i != host and feet.x >= int(box[0]) - dx - 5 and feet.x <= int(box[1]) - dx + 5 \
				and absi(feet.y - (int(box[2]) - dy)) <= 1:
			carry = Vector2i(dx, dy)
	if who[i] == PB2:
		pb2[i].solids = boxes
		if i != host:
			pb2[i].push_x = carry.x
			pb2[i].push_y = carry.y
	else:
		var h: SolPlayer = sol[i]
		h.bridge_solids.clear()
		for box in boxes:
			h.bridge_solids.append([(view_x() + int(box[0])) << 4,
					((view_x() + int(box[1]) + 1) << 4) - 1,
					_hero_y(line_at(int(box[2]))) << 4, ((_hero_y(line_at(int(box[3]))) + 1) << 4) - 1])
		h.push_x = carry.x << 4
		if climbers.has(i):
			var q: Pb2Player = climbers[i]
			q.push_x = carry.x
			q.push_y = carry.y
		else:
			h.y += carry.y << 4


## PB3 traversal bridge: $94A9 ladders and $9036 slides use the native
## level's probes and ROM speeds, while Solbrain keeps his own art/weapons.
func _sol_traversal(i: int, pad: int) -> bool:
	var h: SolPlayer = sol[i]
	var was_sliding := h.bridge_slide
	h.bridge_compact = false
	h.bridge_frame = -1
	h.bridge_slide = false
	if h.state >= 0x0C:
		climbers.erase(i)
		return false
	var q: Pb2Player = climbers.get(i)
	var hit: int = pad & ~h.pad_held
	if q == null:
		if (pad & (Pad.UP | Pad.DOWN)) == 0:
			return false
		q = Pb2Player.new(pb2v)
		var s: Vector2i = screen_of(i)
		q.place(s.x, s.y, eye.pos)
		q.face_left = h.face_left
		if host_pb2 != null:
			q.solids = _platform_boxes()
		if (pad & Pad.DOWN) != 0 and (hit & Pad.A) != 0 and h.state in [SolPlayer.ST_GROUND, SolPlayer.ST_CROUCH, SolPlayer.ST_LAND]:
			# Solbrain's feet are on the surface; Nova stands one pixel above.
			q.y -= 256
			if not q._floor_solid(8) or not q._slide_wanted():
				return false
			q._crouch_start()
			q._slide_start()
		elif (pad & Pad.UP) != 0 and q._class_byte(s.x,
				s.y + int(q.cfg["ladder_air"])) == 1:
			q._ladder_hold()
		elif (pad & Pad.DOWN) == 0 or not q._ladder_grab():
			return false
		climbers[i] = q
		h.bridge_climb_distance = 0
	else:
		q.shift = slid.y if pb2v.vertical else slid.x
	if host_pb2 != null:
		q.solids = _platform_boxes()
	var previous_y: int = q.y
	var previous_sub: int = q.sub
	q.step(pad & ~Pad.B, hit & ~Pad.B, eye.pos)
	h.x = ((view_x() << 4) + (q.x >> 4)) & 0xFFFF
	var low: bool = q.sub in [Pb2Player.SUB_SLIDE, Pb2Player.SUB_CROUCH]
	h.y = ((_hero_y(line_at((q.y >> 8) & 0xFF)) << 4)
			+ ((q.y & 0xFF) >> 4) - SolPlayer.FOOT_DY + (16 if low else 0)) & 0xFFFF
	h.face_left = q.face_left
	h.vx = 0
	h.vy = 0
	h.skip(pad)
	# $948D still ages arrival/hit flashing while the borrowed controller runs.
	# Freezing an odd timer here could hide him for the entire ladder climb.
	h.timer = mini(255, h.timer + 1)
	if low:
		h.state = SolPlayer.ST_CROUCH
		h._pose(0x03)
		h.bridge_compact = true
		h.bridge_slide = q.sub == Pb2Player.SUB_SLIDE and q.vx != 0
		h.bridge_slide_ticks = h.bridge_slide_ticks + 1 if was_sliding else 0
		var slide_art: Dictionary = SolSprites.traversal_art().animations.slide
		var enter_ticks: int = int(slide_art.enter_ticks)
		if not h.bridge_slide:
			h.bridge_frame = int(slide_art.rest)
		elif h.bridge_slide_ticks < enter_ticks:
			h.bridge_frame = int(slide_art.first)
		else:
			h.bridge_frame = int(slide_art.loop_first) + ((h.bridge_slide_ticks - enter_ticks) / int(slide_art.loop_ticks)) % int(slide_art.loop_count)
	elif q.sub in [Pb2Player.SUB_LADDER, Pb2Player.SUB_LADDER_ON,
			Pb2Player.SUB_LADDER_OFF, Pb2Player.SUB_LADDER_MID]:
		# PB3 art follows actual travel, reversing on descent. Remove camera
		# displacement and exclude the native mount/dismount position snaps.
		var climb_art: Dictionary = SolSprites.traversal_art().animations.climb
		var stride: int = int(climb_art.pixels_per_frame) << 8
		var cycle: int = int(climb_art.count) * stride
		if previous_sub == Pb2Player.SUB_LADDER and q.sub == Pb2Player.SUB_LADDER:
			var travelled: int = q.y - previous_y + (q.shift_y << 8)
			if pb2v.vertical:
				travelled += q.shift << 8
			h.bridge_climb_distance = posmod(h.bridge_climb_distance - travelled, cycle)
		h.bridge_frame = int(climb_art.first) + h.bridge_climb_distance / stride
		h._pose(0) # Give _picture a valid base even when mounting at spawn.
	h._picture()
	if q.sub not in [Pb2Player.SUB_LADDER, Pb2Player.SUB_LADDER_ON,
			Pb2Player.SUB_LADDER_OFF, Pb2Player.SUB_LADDER_MID,
			Pb2Player.SUB_SLIDE, Pb2Player.SUB_CROUCH]:
		climbers.erase(i)
		h.bridge_frame = -1
		h.bridge_slide = false
		h.vx = _signed16(q.vx) >> 4
		h.vy = _signed16(q.vy) >> 4
		h.state = SolPlayer.ST_GROUND if q.sub == Pb2Player.SUB_GROUND else SolPlayer.ST_AIR
		if q.sub == Pb2Player.SUB_GROUND:
			# Native Nova rests one pixel above the surface; Solbrain probes
			# at the surface itself. Without this, his step-off skips the lip.
			h.y += 16
			h.rise = 0
			h._pose(0)
	return true


## $CF3B -- where a Power Blade area calls back in.
func _walk_pb2(take_pad: bool, shots: int, extra: int) -> void:
	_walk_them(take_pad, shots, extra)


## $91B5 -- and where a Solbrain stage does, with the wait a satellite leaves
## behind it ($91AC).
func _walk_sol(hold: int) -> void:
	if turn_sol.script_proxy and spare_sol.state == 0x11:
		spare_sol.suit = 8
		spare_sol.step(0)
		spare_sol.suit = 0
	var saved_pads := pads_now
	if live_session and host_script.controls_locked:
		pads_now = []
		pads_now.resize(who.size())
		pads_now.fill(0)
	_walk_them(false, 0, 0, hold)
	pads_now = saved_pads
	# $91C0 -- and the stage's own hero into the table, where the order has it,
	# before the pools go in.  A guest is drawn by his own game and not here.
	if host >= 0 and not gone[host]:
		var h: SolPlayer = sol[host]
		SolSprites.hero(h, (h.x - sol_eye.x) & 0xFFFF,
				(h.y - sol_eye.y) & 0xFFFF, host_table)


## $CA9A / $F806: palette requests are a clock used by room scripts too.
## Running the existing native fade lets $ACCE observe completion normally.
func _sol_fade_tick() -> void:
	host_fade.kind = host_sol.z26
	host_fade.mask = host_script.g(0x27)
	for i in range(8):
		var v: int = host_script.g(0x05BA + i)
		host_fade.level[i] = v - 256 if v >= 128 else v
	var ptr: int = host_script.w(0x20, 0x21)
	if ptr >= 0x100 and ptr + 32 <= host_script.m.size():
		host_fade.table = host_script.m.slice(ptr, ptr + 32)
	elif SolFade.tables.has("%04X" % ptr):
		host_fade.name_table(ptr)
	host_fade.tick()
	host_sol.z26 = host_fade.kind
	host_script.p(0x26, host_fade.kind)
	host_script.p(0x27, host_fade.mask)
	for i in range(8):
		host_script.p(0x05BA + i, host_fade.level[i])


## Everyone in the room said in the numbers the level's own game keeps a hero
## in: the one at $0400 (or $80) by his own game's mirroring, and the rest as
## guests of it (Э5.4).
##
## It is done at the end of the picture and not at the start of the next one
## because that is where the cartridge does it ($CF41, after his step), and
## because what reads it -- the sweep at $B23D, the laying at $CFBA -- runs
## before the step of the picture after.
func _mirror_them() -> void:
	if not flowing:
		return
	_harvest()
	if turn_pb2 != null:
		if host >= 0 and (not live_session or not gone[host]):
			turn_pb2._mirror_hero()
		elif live_session:
			_pb2_living_target()
	for i in range(who.size()):
		if i == host:
			continue
		if game == PB2:
			_guest_into_pb2(i)
		else:
			_guest_into_sol(i)
		# Э5.8 -- and what he is carrying, beside what he is.
		_arms_of(i)


## Translate Solbrain's idle/grounded condition for $B5B7 without changing
## his combat box or combat state. A climb, slide or punch is not standing.
func _pb2_gate_ready(i: int) -> bool:
	if gone[i]:
		return false
	if who[i] == PB2:
		return pb2[i].state == 0
	var hero: SolPlayer = sol[i]
	return hero.state == SolPlayer.ST_GROUND and hero.scripted == 0 \
			and not hero.bridge_slide and not climbers.has(i)


## Native AI reads $0508/$04C6 even when nobody occupies Nova's own slot.
## Keep that non-colliding slot aimed at a living guest, never the origin.
func _pb2_living_target() -> void:
	host_pb2.guest_drawn = false
	for i in range(who.size()):
		if gone[i]:
			continue
		var at: Vector2i = screen_of(i)
		var row: PackedByteArray = host_pb2.slots[0]
		row[Pb2Objects.F_X] = at.x & 255
		row[Pb2Objects.F_Y] = at.y & 255
		row[Pb2Objects.F_XHI] = 0
		row[Pb2Objects.F_YHI] = 0
		# Health stays zero: contact and pickups use the actual guest mirror.
		row[Pb2Objects.F_LIFE] = 0
		host_pb2.guest_drawn = true
		return


## Э5.4 -- what the level took off a guest this picture, said back in his own
## game's numbers.  The level struck the mirror, because the mirror is all the
## level can see of him; the mirror is written out of his own health every
## picture, so whatever is missing from it is the blow.
func _harvest() -> void:
	for i in range(who.size()):
		if i == host or gone[i]:
			continue
		if game == PB2:
			var row: PackedByteArray = guest_row[i]
			if row == null:
				continue
			var lost: int = _health_pb2(i) - row[Pb2Objects.F_LIFE]
			if lost <= 0:
				continue
			if who[i] == PB2:
				var s: PackedByteArray = things[i].slots[0]
				s[Pb2Objects.F_LIFE] = maxi(0,
						s[Pb2Objects.F_LIFE] - lost)
			else:
				sol[i].suit = maxi(0, sol[i].suit - hurt_to_sol(lost))
			continue
		var carrier: SolPlayer = guest_sol[i]
		if carrier == null:
			continue
		var took: int = _health_sol(i) - carrier.suit
		if took <= 0:
			continue
		if who[i] == SOL:
			sol[i].suit = maxi(0, sol[i].suit - took)
		else:
			var s: PackedByteArray = things[i].slots[0]
			s[Pb2Objects.F_LIFE] = maxi(0, s[Pb2Objects.F_LIFE] - took)
			if pb2[i].sub == Pb2Player.SUB_NET:
				pb2[i]._step_off(0)


## A guest of a Power Blade area: twenty nine bytes of $0400's shape, his feet
## where the screen has them, and the box his own game gives him.
func _guest_into_pb2(i: int) -> void:
	var row: PackedByteArray = guest_row[i]
	if row == null:
		return
	var s: Vector2i = screen_of(i)
	row[Pb2Objects.F_X] = s.x & 0xFF
	row[Pb2Objects.F_Y] = s.y & 0xFF
	row[Pb2Objects.F_XHI] = 0
	row[Pb2Objects.F_YHI] = 0
	row[Pb2Objects.F_LIFE] = _health_pb2(i)
	if gone[i]:
		row[Pb2Objects.F_LIFE] = 0
	# Contact reads both the native state and this actor's equipment.
	row[Pb2Objects.F_MARK] = pb2[i].state if who[i] == PB2 else 0
	guest_at[i][2] = pb2[i].suit if who[i] == PB2 else 0
	guest_at[i][1] = _box_pb2(i)


## And of a Solbrain stage: the `SolPlayer` the pool reads him through, and the
## corner and size of his box in the stage's own sixteenths ($88..$8F).
func _guest_into_sol(i: int) -> void:
	var carrier: SolPlayer = guest_sol[i]
	if carrier == null:
		return
	carrier.suit = 0 if gone[i] else _health_sol(i)
	var b: Array = _box_pb2(i) if who[i] == PB2 else _box_own_sol(i)
	var up: int = int(b[0])
	var half_w: int = int(b[1])
	var half_h: int = int(b[2])
	var f: Vector2i = world_of(i)
	guest_at[i][1] = [0x01,
			((f.x - half_w) << 4) & 0xFFFF,
			((f.y - up - half_h) << 4) & 0xFFFF,
			(half_w * 2 + 1) << 4, (half_h * 2 + 1) << 4]


## His box in whole pixels: how far above his feet the middle of it lies, and
## its two halves.  A Power Blade hero has his own game's ($B2C1); a Solbrain
## hero's comes off his picture ($80DE), which only his own game can read, so
## a pool of his own game is kept beside him to be asked.
func _box_pb2(i: int) -> Array:
	if who[i] == PB2:
		var row := Pb2Objects.empty_row()
		row[Pb2Objects.F_MARK] = pb2[i].state
		return Pb2Objects.own_box(row)
	return _box_own_sol(i)


func _box_own_sol(i: int) -> Array:
	if sol[i].bridge_compact:
		return [7, 6, 7]
	var pool: SolObjects = guest_pool[i]
	pool.hero = sol[i]
	pool.hero_box()
	if pool.hero_box_flags == 0:
		return [0x0F, 6, 13]
	var half_w: int = (pool.hero_bw >> 4) / 2
	var half_h: int = (pool.hero_bh >> 4) / 2
	# $82:$83 stands sixteen pixels above his feet, and this is how far the
	# middle of the box stands above them.
	var dy: int = ((pool.hero_by - sol[i].y + 0x8000) & 0xFFFF) - 0x8000
	return [16 - (dy >> 4) - half_h, half_w, half_h]


# ---- Э5.8: what a guest is carrying ---------------------------------------

## One picture of a Power Blade guest's own weapons, in his own pool.
##
## $8E26 -- what is already in the air moves before he does, and $CF00 counts
## how long the button has been held before either.  The area's own hero gets
## both from the order itself ($CEF0); a guest has no order of his own, so the
## two lines of it he needs are here.
## PB3 rule: Nova's weapons may break exactly the cells Solbrain can punch.
## Solbrain owns the map changes, debris, drops and sound ($B933/$B9CD).
func _break_sol_terrain(sx: int, sy: int) -> void:
	if host_sol != null:
		SolSat.break_at(host_sol, (view_x() + sx) << 4, line_at(sy) << 4)


func _arms_turn_pb2(i: int) -> void:
	var w: Pb2Objects = things[i]
	w.frame = (w.frame + 1) & 0xFF
	pb2[i].step_charge(w.frame)
	w.shots_turn()


## And one picture of a Solbrain guest's, in the pool Э5.7 already keeps beside
## him.  The stage's own hero has this done for him at $B168 and $9156; a guest
## has the same three lines here, with the numbers those three read handed over
## first ($CDB3's own head).
##
## The mirror is one way only.  What his weapons would say back to him -- the
## wire winding him in, the ride his satellite paces -- is his own game telling
## him something, and a guest of another level is not told it.
func _arms_turn_sol(i: int, pad: int) -> void:
	var pool: SolObjects = guest_pool[i]
	if pool == null:
		return
	var h: SolPlayer = sol[i]
	pool.clock = (pool.clock + 1) & 0xFF
	pool.noise = (pool.noise * 5 + 0x3D) & 0xFF
	pool.six = pad
	pool.pad_new = pad & ~last_pad[i]
	last_pad[i] = pad
	if game == SOL:
		pool.cam_x = sol_eye.x
		pool.cam_y = sol_eye.y
		pool.map_kind = sol_eye.map_kind
	else:
		var w: Vector2i = world_of(i)
		pool.cam_x = (w.x - 0x80) << 4
		pool.cam_y = (_hero_y(w.y) - 0x78) << 4
	SolTurn.hero_into(pool, h)
	# $B862 -- one step of a handful of his animations strikes, and what it
	# strikes with goes into slot fifteen.
	if h.punch >= 0:
		SolSat.strike(pool, h.punch, h.punch_x, h.punch_y)
		h.punch = -1
	SolSat.letters(pool)                # $923B
	SolWeapon.step(pool)                # $B168
	SolSat.step(pool)                   # $9156


## What he is carrying, written out fresh into the list the level's pool is
## holding.  Done where his body's mirror is done and for the same reason: the
## sweep of the next picture reads it before anybody has moved again.
func _arms_of(i: int) -> void:
	var out: Array = arms[i]
	var from: Array = arms_from[i]
	out.clear()
	from.clear()
	if gone[i]:
		return
	if who[i] == PB2:
		_arms_of_pb2(i, out, from)
	else:
		_arms_of_sol(i, out, from)
	if not out.is_empty():
		arms_flying += 1


## His blades and beams: places one to five of his own pool, said as this level
## counts places.  One off the screen is not asked about, which is $B5EA's own
## rule for the area's own.
func _arms_of_pb2(i: int, out: Array, from: Array) -> void:
	var w: Pb2Objects = things[i]
	for k in range(1, Pb2Objects.FIRST_LIVE):
		var s: PackedByteArray = w.slots[k]
		var t: int = s[Pb2Objects.F_TYPE]
		if t == 0 or t >= w.shot_size.size():
			continue
		if (s[Pb2Objects.F_XHI] | s[Pb2Objects.F_YHI]) != 0:
			continue
		out.append(_arm_from_pb2(s[Pb2Objects.F_X], s[Pb2Objects.F_Y],
				w.shot_size[t], w.shot_power[t]))
		from.append([0, k])


## His gun and his own four.  The eight at $0700 are points that take one off a
## thing ($87BC); the four at $0C..$0F reach eight pixels further than the
## thing's own box because $84B0 grows it by that much before they are asked --
## and twice that for the two that are asked after the second growth -- and
## take off what their own picture means ($8567).
func _arms_of_sol(i: int, out: Array, from: Array) -> void:
	var pool: SolObjects = guest_pool[i]
	if pool == null:
		return
	for k in range(SolObjects.WALKED):
		if (pool.w_kind[k] & 0x80) == 0:
			continue                    # $8729 -- nothing flying there
		out.append(_arm_from_sol(pool.w_x[k], pool.w_y[k], 0, 1))
		from.append([0, k])
	var h: SolPlayer = sol[i]
	if live_session and game == PB2 and h.bridge_slide:
		# PB3 rule requested by the user: a moving slide strikes low targets.
		# Same three damage points as Nova's suit tackle ($B39E); normal
		# projectile armour, breakable-block and enemy hit-grace rules apply.
		var feet := screen_of(i)
		out.append([feet.x + (-10 if h.face_left else 10), feet.y - 7, 6, 3])
		from.append([2, -1]) # A body strike spends neither satellite nor ammo.
	for k in range(SolSat.FIRST, SolSat.LAST + 1):
		if pool.id[k] == 0 or (pool.id[k] & 0x80) != 0:
			continue                    # $83F7 -- nothing in the slot
		if pool.cool[k] < 0x0C:
			continue                    # left alone twelve pictures, or not
		if k != 0x0F and h.hurt != 0:
			continue                    # $8408 -- his only while he stands
		var n: int = pool.meaning_of(pool.pic_lo[k] | pool.pic_hi[k] << 8)
		if n == 0:
			continue                    # $8586 -- a picture meaning nothing
		if k == 0x0F and h.shield != 0 and h.hurt == 0:
			n = (n << 1) & 0xFF         # $8598 -- the punch counts double
		var reach: int = 0x100 if (k == 0x0D or k == 0x0E) else 0x80
		out.append(_arm_from_sol(pool.x[k], pool.y[k], reach, n))
		from.append([1, k])


## A place of a Power Blade pool -- the screen, in whole pixels -- said in the
## numbers of whichever level is running.
func _arm_from_pb2(sx: int, sy: int, reach: int, power: int) -> Array:
	if game == PB2:
		return [sx, sy, reach, power]
	return [(view_x() + sx) << 4, line_at(sy) << 4, reach << 4, power]


## And a place of a Solbrain pool -- the level, in sixteenths -- the same way.
func _arm_from_sol(wx: int, wy: int, reach: int, power: int) -> Array:
	if game == SOL:
		return [wx, wy, reach, power]
	return [((wx >> 4) & 0xFFFF) - view_x(),
			screen_line(_map_y((wy >> 4) & 0xFFFF)), reach >> 4, power]


## Э5.8 -- the level says what that thing cost arm `j` of his, and his own game
## is what takes it off.  $8731 for the eight he throws into and $844E for his
## own four; a Power Blade blade is spent on nothing at all, which is why
## nothing here touches one.
func _arm_spent(j: int, cost: int, i: int) -> void:
	arms_landed += 1
	if who[i] == PB2:
		return
	var pool: SolObjects = guest_pool[i]
	if pool == null or j >= arms_from[i].size():
		return
	var src: Array = arms_from[i][j]
	if int(src[0]) == 2:
		return
	var k: int = int(src[1])
	if int(src[0]) == 0:
		# $8731 -- it goes through as much as $0770 says and no further.
		var left: int = pool.w_pen[k] - cost
		if left <= 0:
			pool.w_kind[k] = pool.w_kind[k] & 0x7F
			pool.w_vx[k] = 0
			pool.w_pen[k] = 0
		else:
			pool.w_pen[k] = left
		return
	# $844E -- and one of his own four pays out of its own life, with anything
	# from eight up costing one and no more.
	if cost == 0:
		return
	pool.cool[k] = 0
	var n: int = 0x01 if cost >= 0x08 else cost
	var leftv: int = pool.life[k] - n
	if leftv > 0:
		pool.life[k] = leftv
		return
	pool.a[k] = 0
	if k == SolObjects.SAT:
		pool.b[k] = 0x20
		pool.id[k] = 0xFF
	else:
		pool.id[k] = 0


## His health, in the numbers of the game the level came from.  A Power Blade
## area counts sixteen ($049A) and a Solbrain stage eight ($05C5), and Э5.4
## says how one is said in the other.
func _health_pb2(i: int) -> int:
	if who[i] == PB2:
		return things[i].slots[0][Pb2Objects.F_LIFE]
	return mini(0x10, hurt_to_pb2(sol[i].suit))


func _health_sol(i: int) -> int:
	if who[i] == SOL:
		return sol[i].suit
	return mini(0x10, things[i].slots[0][Pb2Objects.F_LIFE])


## Whether the picture goes on: one of them gone is not the end of it.
func alive() -> bool:
	for g in gone:
		if not g:
			return true
	return false


## The view of a screen that has two heroes on it.
##
## Neither cartridge has this problem: each view belongs to one hero and goes
## where he goes.  Three things have to be true of a view that belongs to two,
## and they are done in that order because each is worth less than the one
## before it.
##
## First the middle of them is kept in the band the game itself keeps a hero
## in.  That is what makes the view feel like the game's own and not like a
## new one: the same idling in the middle, the same lean in the direction of
## travel.
##
## Then it is pulled, if it has to be, so that neither of them is off the
## screen, because a hero the screen has lost is a hero nobody can play.
##
## When the two are further apart than a screen there is no place that holds
## both.  The view then stands halfway between the two places that would each
## hold one, which shares the overflow evenly and, unlike going after
## whichever of them is worse off, does not swing back and forth every
## picture.
##
## Last, it may not travel further in one picture than the game allows it.
func _drive_view() -> void:
	var allow: Vector2i = _allowance()
	var across: Array[int] = []
	var down: Array[int] = []
	for i in range(who.size()):
		if gone[i] or _sol_departing(i):
			continue
		var f: Vector2i = flat_of(i)
		across.append(f.x)
		down.append(f.y)
	if across.is_empty():
		slid = Vector2i.ZERO
		sol_pending = Vector2i.ZERO
		_remember()
		return
	# $A4BB (NSB-04) -- while a room script holds the heroes ($9E73 clears
	# $06/$04) it walks $30/$31 itself, a sixteenth of a screen a picture,
	# until the boss column is under the hero.  The native view only follows
	# a hero who moves ($F1EA), and a held one does not, so the walk stands;
	# the pair's band would pull it back every picture and the step never ends.
	if game == SOL and live_session and host_script != null \
			and host_script.controls_locked:
		sol_pending = Vector2i.ZERO
		_remember()
		return
	var mid := Vector2i.ZERO
	for k in range(across.size()):
		mid += Vector2i(across[k], down[k])
	mid /= across.size()
	if game == SOL:
		var here := Vector2i(sol_eye.x >> 4, sol_eye.y >> 4)
		sol_pending = Vector2i(
				_aim(here.x, mid.x, across, SOL_BAND_X[0], SOL_BAND_X[1],
						EDGE, 0x100 - EDGE, allow.x, sol_eye.x_min >> 4,
						(sol_eye.x_end - (SolCamera.SCREEN_X << 8)) >> 4),
				_aim(here.y, mid.y, down, SOL_BAND_Y[0], SOL_BAND_Y[1],
						HEAD, 0xF0, allow.y, sol_eye.y_min >> 4,
						(sol_eye.y_end - (SolCamera.SCREEN_Y << 8)) >> 4))
	elif pb2v.vertical:
		_ask_pb2(_aim(_flat(eye.pos), mid.y, down, PB2_BAND_Y[0],
				PB2_BAND_Y[1], HEAD, 0xF0, allow.y, 0,
				pb2v.cam_limit_page * 240 + pb2v.cam_limit_low),
				PB2_BAND_Y, allow.y)
	else:
		_ask_pb2(_aim(eye.pos, mid.x, across, PB2_BAND_X[0], PB2_BAND_X[1],
				EDGE, 0x100 - EDGE, allow.x, 0,
				(pb2v.cam_limit_page << 8) | 0xFF), PB2_BAND_X, allow.x)
	_remember()


## Where the view should stand along one axis, and how far that is from where
## it stands now.  The three wants above, in order, and then the allowance.
## `stop_lo` and `stop_hi` are the two ends of the level: they come last and
## beat everything, because past them there is no picture to show.  A Power
## Blade view stops itself ($D99E, $DAAB); a Solbrain one only stops itself in
## the direction its own hero was walking ($F1EA clamps against the near end
## when he is out to the right and against the far one when he is out to the
## left), so a view driven by two has to be told.
static func _aim(now: int, mid: int, them: Array[int], near: int, far: int,
		lo: int, hi: int, allow: int, stop_lo: int, stop_hi: int) -> int:
	var want: int = now
	var seen: int = mid - now
	if seen > far:
		want = now + (seen - far)
	elif seen < near:
		want = now + (seen - near)
	# The lowest of them may not be below `hi` and the highest may not be
	# above `lo`; each of those is a place the view may not be past.
	var first: int = -0x40000000
	var last: int = 0x40000000
	for p in them:
		first = maxi(first, p - hi)
		last = mini(last, p - lo)
	want = clampi(want, first, last) if first <= last else (first + last) / 2
	want = clampi(want, stop_lo, maxi(stop_lo, stop_hi))
	return clampi(want - now, -allow, allow)


## How far the view may travel in one picture: the five Power Blade allows it
## ($0116), or as fast as the faster of the two is going, which is what
## Solbrain allows its own ($F24B).  The pair wants the larger of the two --
## a hero falling faster than five would be left further behind every picture
## and the edge would have to shove him.
func _allowance() -> Vector2i:
	var a := Vector2i(Pb2Camera.ALLOWANCE, Pb2Camera.ALLOWANCE)
	for i in range(who.size()):
		if gone[i]:
			continue
		# His own speed and not how far he seems to have got: a Power Blade
		# hero is kept as a place on the screen, so the view moving moves him
		# too, and an allowance read off that would grow itself.
		if who[i] == SOL:
			var p: SolPlayer = sol[i]
			a.x = maxi(a.x, absi(_signed16(p.vx)) >> 4)
			a.y = maxi(a.y, absi(_signed16(p.vy)) >> 4)
		else:
			var q: Pb2Player = pb2[i]
			a.x = maxi(a.x, absi(_signed16(q.vx)) >> 8)
			a.y = maxi(a.y, absi(_signed16(q.vy)) >> 8)
	return a


## Ask a Power Blade view to move by so much next picture.  $D3B8 is told
## where on the screen the thing it follows is and works the distance out
## itself, so it is told a place just so far past the band.
func _ask_pb2(d: int, band: Array, allow: int) -> void:
	eye.decide(band[1] + d if d > 0 else (band[0] + d if d < 0 else band[0]),
			allow)


## Move a Solbrain view by so many pixels, through its own code, so that the
## ends of the stage ($F285, $F2AC) and the maps that carry it along ($F24B)
## keep the last word.  It only ever moves by the speed of what it follows, so
## it is handed the speed that is wanted and a hero placed far enough outside
## the band to ask for it.
func _sol_move(d: Vector2i) -> void:
	var hx: int = sol_eye.x + (0x1100 if d.x > 0 else (0 if d.x < 0 else 0x780))
	var hy: int = sol_eye.y + (0x1100 if d.y > 0 else (0 if d.y < 0 else 0x700))
	sol_eye.step((d.x << 4) & 0xFFFF, (d.y << 4) & 0xFFFF,
			mini(0xFFFF, hx), mini(0xFFFF, hy))


## A Solbrain stage's view, said again in the numbers a Power Blade hero reads
## the map through: the page across, and the window downwards that his own
## game never has to say out loud (Э5.1, `SolAsPb2.cam_y`).
func _led_by_sol() -> void:
	eye.pos = (sol_eye.x >> 4) & 0xFFFF
	down.cam_y = (sol_eye.y >> 4) + Pb2Objects.VIEW_TOP
	# $D04E -- on the carrying map the ground is the lift's line, $75 lines
	# under the top of the view.
	down.ride_line = (sol_eye.y >> 4) + host_sol.z75 \
			if host_sol != null and sol_eye.map_kind == SolCamera.RIDE else -1


## $AC1C -> $96FF: scripted departure can cross the screen and wrap Y.
## It must not steer the shared camera or enter ordinary fall/crush checks.
func _sol_departing(i: int) -> bool:
	return live_session and game == SOL and who[i] == SOL \
			and sol[i].state == 0x11 and host_script.controls_locked


## Nobody is let off the screen.
##
## Across, an edge behaves like a wall: walking into it is the same thing as
## walking into the side of a cell, and holding him there moves him along a
## way he was already being stopped.  This is how every game that puts two on
## one screen holds them together.
##
## Downwards it is not a nicety but a necessity, and the reason is the Power
## Blade hero's own arithmetic: his place ($0320) is one byte of the screen,
## so a hero who falls past the bottom of it does not go below the screen, he
## comes round the top of it.  In his own game that cannot happen -- the view
## is his alone and never falls more than a few lines behind -- and with two
## it can, so the bottom of the screen has to hold him.  It is the wrap that
## is held off and nothing more: a hero whose feet are on the screen at all is
## left alone, because at the top and the bottom of a level the view has
## nowhere further to go and standing there is not being lost.
##
## A hold that cannot be made is the end of him.  Being pressed by the edge of
## the screen into something solid is being crushed, and the six Power Blade
## areas that carry their own view ($2E) are where it happens: the view goes
## on without him whatever he does, and if he neither keeps up nor has
## anywhere to be pushed, the level has him.  It is the same end as falling
## out of the bottom -- the other one plays on -- and it has to be an end
## rather than nothing at all, because a Power Blade hero left off the screen
## does not stay off it: his place is one byte and it comes round the top.
func _hold_them_in() -> void:
	for i in range(who.size()):
		# $AC1C -> $96FF deliberately takes Solbrain off screen. The
		# shared-camera safety clamp must not crush/reposition this actor.
		if _sol_departing(i):
			continue
		if gone[i]:
			continue
		var s: Vector2i = screen_of(i)
		if live_session and world_of(i).y >= solv.height_tiles * 8:
			# A fall out of the map must be consumed before screen clamping
			# pins him at its last pixel forever.
			gone[i] = true
			continue
		var push := Vector2i(clampi(s.x, EDGE, 0x100 - EDGE) - s.x,
				clampi(s.y, 0, 0xEF) - s.y)
		if push == Vector2i.ZERO:
			continue
		held_in += 1
		var w: Vector2i = world_of(i)
		if _solid(w + push):
			could_not += 1
			gone[i] = true
			continue
		shoved[i] = push
		_shove(i, push)


## Move him by so many pixels and take away what speed he had that way.
func _shove(i: int, by: Vector2i) -> void:
	if who[i] == SOL:
		var p: SolPlayer = sol[i]
		p.x = (p.x + (by.x << 4)) & 0xFFFF
		p.y = (p.y + (by.y << 4)) & 0xFFFF
		if by.x != 0:
			p.vx = 0
			p.speed = 0
		if by.y != 0:
			p.vy = 0
		return
	var q: Pb2Player = pb2[i]
	q.x = (q.x + (by.x << 8)) & 0xFFFF
	q.y = (q.y + (by.y << 8)) & 0xFFFF
	if by.x != 0:
		q.vx = 0
	if by.y != 0:
		q.vy = 0


## Is that pixel inside something, asked in the level's own terms.
func _solid(w: Vector2i) -> bool:
	return solv.collision_at(w.x, _hero_y(w.y) - 8) >= Pb2AsSol.SOLID


## Э5.4 -- a blow struck in one game's numbers, said in the other's.
##
## Nothing in either cartridge says how: neither ever saw the other's things.
## The two healths are not even the same size -- the Power Blade hero has
## sixteen ($049A, put there by $D05D) and the Solbrain hero eight ($05C5,
## which is his suit as well -- so this is a decision, and it is made the only
## way that keeps a blow a blow: the share of his health it took, rounded up,
## and never nought unless it was nought to start with.  A touch that costs
## the one hero a sixteenth costs the other an eighth and not nothing at all.
## See `work/re/pb3_hits.md`.
static func hurt_to_sol(d: int) -> int:
	return 0 if d <= 0 else maxi(1, (d * 8 + 15) / 16)


## And back the other way.
static func hurt_to_pb2(d: int) -> int:
	return 0 if d <= 0 else maxi(1, (d * 16 + 7) / 8)


static func _signed16(v: int) -> int:
	v &= 0xFFFF
	return v - 0x10000 if v >= 0x8000 else v
