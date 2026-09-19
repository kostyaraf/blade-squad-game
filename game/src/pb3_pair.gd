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


## `kinds` is one of `PB2`/`SOL` a hero, in the order their pads come.
func _init(from: int, stage: int, area: int, kinds: Array) -> void:
	game = from
	if game == PB2:
		var src := Pb2Level.new(stage, area)
		pb2v = src
		solv = Pb2AsSol.new(src)
		eye = Pb2Camera.new(pb2v)
	else:
		var src := SolLevel.new(stage)
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

## His feet, in the level's own pixels.
func world_of(i: int) -> Vector2i:
	if who[i] == SOL:
		var p: SolPlayer = sol[i]
		return Vector2i((p.x >> 4) & 0xFFFF,
				(((p.y >> 4) & 0xFFFF) + SolPlayer.FOOT_DY / 16))
	var q: Pb2Player = pb2[i]
	return Vector2i(view_x() + ((q.x >> 8) & 0xFF),
			line_at((q.y >> 8) & 0xFF))


## Put him there, his feet on that pixel.
func place_at(i: int, w: Vector2i) -> void:
	if who[i] == SOL:
		var p: SolPlayer = sol[i]
		p.place(w.x << 4, (w.y - SolPlayer.FOOT_DY / 16) << 4)
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


## Where each of them stood when the picture ended, for the next picture's
## sums.
func _remember() -> void:
	for i in range(who.size()):
		was_at[i] = flat_of(i)


# ---- the picture ----------------------------------------------------------

## Put both of them down and set the view around them.
func begin(spots: Array) -> void:
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


## One picture of both of them and of the view.
func step(pads: Array) -> void:
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
		_sol_move(sol_pending)
		sol_pending = Vector2i.ZERO
		slid = Vector2i((sol_eye.x >> 4) - was_eye.x,
				(sol_eye.y >> 4) - was_eye.y)
		_led_by_sol()
	for i in range(who.size()):
		shoved[i] = Vector2i.ZERO
		if gone[i]:
			continue
		if who[i] == SOL:
			# Solbrain's hero works out for himself what was newly pressed
			# ($C882 keeps the picture before), so he is handed the pad whole.
			sol[i].step(int(pads[i]))
			continue
		var q: Pb2Player = pb2[i]
		var w: Pb2Objects = things[i]
		w.cam = eye.pos
		if game == PB2 and pb2v.vertical:
			q.shift = slid.y
			q.shift_y = 0
		else:
			q.shift = slid.x
			q.shift_y = slid.y
		var held: int = int(pads[i])
		var hit: int = held & ~last_pad[i]
		last_pad[i] = held
		q.step(held, hit, eye.pos, 0, 0)
	_drive_view()
	_hold_them_in()
	for i in range(who.size()):
		if world_of(i).y >= solv.height_tiles * 8:
			gone[i] = true


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
		if gone[i]:
			continue
		var f: Vector2i = flat_of(i)
		across.append(f.x)
		down.append(f.y)
	if across.is_empty():
		slid = Vector2i.ZERO
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
		if gone[i]:
			continue
		var s: Vector2i = screen_of(i)
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
	return solv.collision_at(w.x, w.y - 8) >= Pb2AsSol.SOLID


static func _signed16(v: int) -> int:
	v &= 0xFFFF
	return v - 0x10000 if v >= 0x8000 else v
