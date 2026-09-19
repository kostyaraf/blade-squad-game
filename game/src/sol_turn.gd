extends RefCounted
class_name SolTurn

## $CDB3 -- one picture of a Solbrain stage, in the cartridge's own order.
##
## The same move as `Pb2Turn`, and for the same reason: the order used to live
## in the mode that draws the game, and Э5.7 needs a second hero played by the
## very same order rather than by a copy of it.  What stayed behind in the mode
## is the drawing, and what the flow makes of a stage that has ended; what came
## here is the picture itself, together with the three small pieces of it other
## stands ask for on their own -- the strip along the foot of the screen, the
## bonus counting down, and the hero's numbers going into the pool.

var hero: SolPlayer
var pool: SolObjects
var view: SolCamera
## `script` is a word the engine keeps for itself, so the stage's own script is
## `script_`.
var script_: SolScript
var table: SolSprites.Table
var flow: SolFlow

## $06 of the picture before: how the hero is told what was newly pressed.
var pad_was := 0

## Э5.7 -- the two places a second hero changes this order, and the only two.
##
## A pair's view follows the middle of two heroes and not one, so the pair has
## already moved it by the time the order runs ($CD9C) and says so with
## `slid_already`; and the pair takes both heroes' steps and puts both into the
## table, so it hands that in as `walk` ($91B5 and $91C0).  Everything above
## and below the two is the one order and not a copy of it.  Left empty --
## which is what the single game leaves them -- the order is what it was.
var slid_already := false
var walk: Callable = Callable()


func _init(h: SolPlayer, po: SolObjects, v: SolCamera, sc: SolScript,
		t: SolSprites.Table, f: SolFlow) -> void:
	hero = h
	pool = po
	view = v
	script_ = sc
	table = t
	flow = f


## One step of the game, in the cartridge's own order ($CDB3).
func step(held: int) -> void:
	# $0C simply counts pictures.  $0E is the hash $CD57 stirs out of the whole
	# of RAM and is not ported (`work/re/sol_minds.md` says what it wants);
	# what stands in for it is a counter of its own, so what leans on it --
	# which way a flyer turns, which thing refuses to be carried off -- is not
	# the cartridge's answer but is at least not always the same one.
	pool.clock = (pool.clock + 1) & 0xFF
	pool.noise = (pool.noise * 5 + 0x3D) & 0xFF
	# $06 is the buttons the hero is handed; only a stage's own script ever
	# wipes it, and no script is ported, so it is the pad as read.
	pool.six = held
	pool.pad_new = held & ~pad_was
	pad_was = held
	# $C72D -- a picture starts with an empty table: both ends are put back
	# where they start, which moves on by $50 every time so that the sprite
	# the console drops on a crowded line is a different one each picture.
	SolSprites.reset(table, pool.clock)
	pool.drew()
	if not slid_already:
		view.step(hero.vx, hero.vy, hero.x, hero.y)
	pool.born_wait = view.hold
	pool.map_kind = view.map_kind
	hero.map_kind = view.map_kind
	pool.z34 = view.fall
	pool.cam_x = view.x
	pool.cam_y = view.y
	# $CDB3 -- the stage's own script, which is also where his breath and the
	# bubbles it leaves come from ($A7B0): the script calls them, so nothing
	# here does.
	script_.run(pool, hero, view, table, flow)
	pool.scrolled(view.x, view.y)
	pool.room = pool.room_of(view.x, view.y)
	hero_into(pool, hero)
	pool.scan(view.x, view.y, hero.x, hero.state)        # $CDBB
	pool.hero_box()                                      # $CDBE
	pool.shots_hit_hero()                                # $CDCC
	# $9163 -- being hit puts an aura round him, one of sixteen pictures by
	# how much of the hurt is left.  It is drawn before he moves.
	if hero.hurt != 0:
		SolSprites.picture(0x14 + ((hero.hurt >> 3) & 0x0F), 0,
				0x0080, 0x0018, table)
	if walk.is_valid():
		walk.call(view.hold)
	else:
		# $91AC -- while the wait for a satellite is between one and $2F he
		# does not move at all: $9477 is simply not called.
		if view.hold == 0 or view.hold >= 0x30:
			hero.step(held)                                 # $91B5
		else:
			hero.skip(held)
		# $91C0 -- where he is, counted from the corner of the view.  He goes
		# into the table here, before the pools do, exactly as the cartridge
		# has it.
		SolSprites.hero(hero, (hero.x - view.x) & 0xFFFF,
				(hero.y - view.y) & 0xFFFF, table)
	# $91DD -- the strip along the foot of the screen.
	strip(pool.hero_suit, pool.clock, pool.hero_bonus, table)
	hero_into(pool, hero)
	# $B862 -- one step of a handful of his animations strikes, and what it
	# strikes with goes into slot fifteen while he is still the one running.
	if hero.punch >= 0:
		SolSat.strike(pool, hero.punch, hero.punch_x, hero.punch_y)
		hero.punch = -1
	SolSat.letters(pool)                                 # $923B
	view.hold = pool.born_wait
	hero.state = pool.hero_state
	hero.fuel = pool.hero_fuel
	hero.burst = pool.z5ab
	SolWeapon.step(pool)                                 # $B168
	SolSat.step(pool)                                    # $9156
	# $AD45 writes back into $05B2, which he reads again next picture.
	hero.face = pool.hero_face
	SolShots.step(pool)                                  # $CDDA
	# $B984 -- the shot that turns the world over writes his own numbers.
	hero.flags = pool.hero_flags
	hero.rise = pool.hero_rise - 0x10000 \
			if pool.hero_rise >= 0x8000 else pool.hero_rise
	hero.ground = pool.hero_ground
	hero.jump = pool.hero_jump
	hero.gravity = pool.hero_grav
	hero.hold_max = pool.hero_hold_max
	pool.step(view.x, view.y, table)         # $CDDD
	# $D065 again: the carrying map answers the pool's own looks and writes
	# his falling while it does, so it comes back out of the pool.
	hero.vy = pool.hero_vy - 0x10000 if pool.hero_vy >= 0x8000 else pool.hero_vy
	tick_bonus(pool)                                     # $CDE3
	# $05AF is one byte of memory and not two: a mind that writes it -- $847E,
	# which is what ends his arriving -- writes what he reads next picture, so
	# it is taken back out of the pool after the pool has run and not before.
	hero.fuel = pool.hero_fuel


static func strip(suit: int, clock: int, bonus: int,
		t: SolSprites.Table) -> void:
	# $91E5 -- under the third suit the mark blinks; from the third up it is
	# steady.
	var y: int = suit
	if y < 0x03 and (clock & 0x04) != 0:
		y = 0                                            # $91F2
	# $91FB -- $C009, which is $F3F0: whole pixels and the forward walk, not
	# the divider $CF73 goes through.  The mark stands at sixteen across and
	# two hundred down, on the screen and not in the level.
	SolSprites.forward(y + 2, 0, 0x10, 0xC8, t)
	if (clock & 0x01) != 0:
		return                                           # $9201
	# $9203 -- what is still to be paid, shown ten times over: four figures of
	# it and a nought that is always a nought ($9236).
	var fig := SolSprites.figures(bonus)
	for i in range(5):
		var at: int = (1 + i) * 4
		t.oam[at] = 0xD0                                 # $9222
		t.oam[at + 1] = 0x81 if i == 4 else fig[2 + i]
		t.oam[at + 2] = 0x01                             # $922E
		t.oam[at + 3] = (i * 8 + 0x18) & 0xFF            # $9227


static func tick_bonus(pool: SolObjects) -> void:
	if pool.z56 == 0:
		return
	pool.z56 -= 1
	pool.hero_bonus = (pool.hero_bonus - 1) & 0xFFFF


static func hero_into(pool: SolObjects, p: SolPlayer) -> void:
	pool.hero_x = p.x
	pool.hero_y = p.y
	pool.hero_vx = p.vx
	pool.hero_vy = p.vy & 0xFFFF
	pool.hero_face = p.face
	pool.hero_suit = p.suit
	pool.hero_flags = p.flags
	pool.hero_state = p.state
	pool.hero_timer = p.timer
	pool.hero_pic_lo = p.pic_lo
	pool.hero_pic_hi = p.pic_hi
	pool.hero_fuel = p.fuel
	pool.hero_pose = p.pose
	pool.hero_step_t = p.step_t
	pool.hero_rise = p.rise & 0xFFFF
	pool.hero_ground = p.ground
	pool.hero_jump = p.jump
	pool.hero_grav = p.gravity
	pool.hero_hold_max = p.hold_max
	pool.hero_hurt = p.hurt
	pool.hero_shield = p.shield
	pool.z5ab = p.burst
