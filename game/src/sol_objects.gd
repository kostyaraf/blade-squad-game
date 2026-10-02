extends RefCounted
class_name SolObjects

## Solbrain's objects: the sixteen slots, who gets into them and who leaves.
##
## The cartridge keeps the pool as columns, not as records: every field is a
## page of sixteen bytes and a slot is an index into all of them at once.  It
## is kept that way here, because the slot number is what the rest of the game
## passes around and a record would have to be unpacked back into it anyway.
##
## Two things decide the life of a slot.  A twelve-by-twelve ring of cells
## sixty four pixels across, read at $8059, says an object may come in only
## from just outside the picture; the same ring read at $CE44 says it goes away
## again the moment it is that far out.  And a byte per spawn id at $0560 makes
## sure the same object is not born twice.
##
## `work/re/sol_objects.md` says where each piece came from.

const SLOTS := 16               # $0600..$060F
const LAST_SPAWNED := 0x0B      # $AEF9 -- the stage's own list only reaches here
const MARKS := 64               # $0560..$059F, a byte per spawn id
const SHOTS := 16               # $0780..$078F, the second pool
const WEAPONS := 16             # $0700..$070F, the third
const WALKED := 8               # $B168 -- but only these eight are ever walked
const SAT := 0x0C               # the satellite keeps slot twelve of the pool
const BLAST := 0x0D             # and its bang is put into slot thirteen

## $8059 / $CE44 -- the ring, three screens across and three down, in cells of
## 64 px.  Only rows 3..8 are ever looked at, so that is all the data holds.
const RING_COLS := 12
const FIRST_ROW := 3
const LAST_ROW := 8
const FIRST_CELL := 0x24        # 12 * FIRST_ROW
const END_CELL := 0x6C          # 12 * (LAST_ROW + 1)

## Which way a thing is allowed to come in from, once the two bits of the
## record have been rolled up ($AEDF).
const ANY := 0
const FROM_LEFT := 1
const FROM_RIGHT := 2           # and from below: the bottom row says 2 as well
const FROM_ABOVE := 3

## $05A2 -- past this the hero is in a cutscene and nothing is let in.
const HERO_BUSY := 0x12

var level: SolLevel

# The pool, column by column, under the names the cartridge gave the pages.
var id := PackedByteArray()         # $0600: spawn id, bit6 "never leaves"
var x := PackedInt32Array()         # $00A0 lo / $00B0 hi
var y := PackedInt32Array()         # $00C0 lo / $00D0 hi
var mind := PackedByteArray()       # $0650: which behaviour runs
var pic_lo := PackedByteArray()     # $0660
var pic_hi := PackedByteArray()     # $0670
var face := PackedByteArray()       # $0680: bit7 set means looking left
var a := PackedByteArray()          # $0610
var b := PackedByteArray()          # $0620
var c := PackedByteArray()          # $0630
var d := PackedByteArray()          # $0640
var kind := PackedByteArray()       # $0690
var anim_a := PackedByteArray()     # $06A0
var anim_b := PackedByteArray()     # $06B0
var left := PackedByteArray()       # $06C0: frames left
var frame := PackedByteArray()      # $06D0: which step of the walk
var cool := PackedByteArray()       # $06E0: frames since it was last hit
var life := PackedByteArray()       # $06F0

var mark := PackedByteArray()       # $0560: 0 gone for good, bit7 out already

# The other pool: what things throw at the hero.  Sixteen slots of its own,
# walked by $B2E9 of bank three before the objects are walked at all, with its
# own table of behaviours.  `work/re/sol_shots.md` says what each one does.
var s_kind := PackedByteArray()     # $0780: behaviour, bit7 "still flying"
var s_x := PackedInt32Array()       # $0790 lo / $07A0 hi
var s_y := PackedInt32Array()       # $07B0 lo / $07C0 hi
var s_a := PackedByteArray()        # $07D0
var s_b := PackedByteArray()        # $07E0
var s_life := PackedByteArray()     # $07F0
var shots_skipped := {}             # behaviours not read out of the ROM yet

# And the third: what the hero's own satellite throws.  Sixteen slots at $0700
# of which $B168 walks only the first eight, with a table of behaviours of its
# own.  `work/re/sol_weapons.md` says what each one does.
var w_kind := PackedByteArray()     # $0700: behaviour, bit7 "still flying"
var w_x := PackedInt32Array()       # $0710 lo / $0720 hi
var w_y := PackedInt32Array()       # $0730 lo / $0740 hi
var w_vx := PackedByteArray()       # $0750
var w_vy := PackedByteArray()       # $0760
var w_pen := PackedByteArray()      # $0770: how much it can still go through
var weapons_skipped := {}
var sat_skipped := {}

## Э7.5 -- what this pool's third walk drew this picture, written down in the
## level's own numbers instead of the screen's, so that it can be laid out
## again from another view.  Only a guest of another game's level needs it and
## only he turns it on: his pool is stepped with the view pretended to stand on
## him (Э5.7), so everything the drawing measured is measured from a view the
## picture has not got, and unlike the satellite's the drawing here cannot
## simply be done again -- it lives inside the behaviour that moved the thing.
## An entry is [x, y, left tile, right tile, left mark, right mark], and a
## right tile below nought means there was one sprite and not two.
var w_keep := false
var w_drew: Array = []

# Where it is on the screen, in whole pixels, filled by the frame walk.
var at_x := PackedInt32Array()      # $5C:$5D
var at_y := PackedInt32Array()      # $5E:$5F

# The scroll bookkeeping the spawner leans on.
var due := 0                        # $05EC: a scan has been asked for
## $05FD:$05FE:$05FF -- the three bytes of the score, lowest byte last.  The
## only thing in this module that touches them is $A8C6, which adds five for a
## wall broken with a fist.
var z5ff := 0
var col_due := 0                    # $37: a column of background is queued
var row_due := 0                    # $36: a row of it is
var seen_x := 0                     # $05E0:$05E1
var seen_y := 0                     # $05E2:$05E3
var room := 0                       # $05EB

# What a mind is handed and what it leaves behind: the cartridge's own scratch
# bytes, kept under their own addresses because the minds are ported literally.
var z50 := 0                        # $50:$51 -- the step along, signed
var z52 := 0                        # $52:$53 -- the step down, signed
var z90 := 0                        # $90:$91
var z92 := 0                        # $92:$93
var z94 := 0                        # $94
var z95 := 0                        # $95
var carry := 1                      # the C flag, which $AE30 reads without setting
var hero_x := 0                     # $80:$81
var hero_y := 0                     # $82:$83
var clock := 0                      # $0C -- one up every frame
var noise := 0                      # $0E -- the hash of the RAM $CD57 stirs
var six := 0                        # $06 -- the other stirred byte
var z7f := 0                        # $7F -- how far the stage's own script is
## $26 of the object's own set of bytes -- what it is waiting on before it goes
## on.  It is not the $26 the screens use: that one is the walk of the colours
## ($F86D, ported in `SolFade`) and shares nothing with this but the name.
var z26 := 0
## $0399:$039B -- the three numbers of the tile set the screen is next owed.
## Only the first is ever read back ($B966 asks whether the world is already
## the other way up), so only the first has anything leaning on it.
var z399 := 0
var z39a := 0
var z39b := 0
var push := 0                       # $05A8:$05A9 -- what a belt does to the hero
var wants := 0                      # $05F7 -- what an object asks the hero for
var score := 0                      # $05FD..$05FF
var cam_x := 0                      # $30:$31
var cam_y := 0                      # $32:$33
var hero_vx := 0                    # $05B6:$05B7
# $05B8:$05B9 -- his own falling.  The pool has to hold it because the
# carrying map's own answer ($D065) takes the ride out of it and puts the
# sinking back in, and that is a thing the pool does to him, not he to
# himself.
var hero_vy := 0
var hero_face := 0                  # $05B2 -- bit 7 set means he looks left
var z34 := 0                        # $34 -- how fast a carrying map drags down
var z7c := 0                        # $7C -- which piece of rubble comes next
var z75 := 0                        # $75 -- the height a lift keeps for the rest
# $74 -- how far the blanking is to move that height before the next picture.
# The stage's own script works it out ($AA46 is one that does) and $C3E0 pays
# it, both outside anything the pool does, so a stand hands it over.
var z74 := 0
# $72 -- how far the hero's feet sink into the line the lift keeps.  It is the
# stage's own script's again ($A8D4, $A933, $ABC4 and $A6DE all write it once
# and nothing writes it twice), and $D032 is the only thing that reads it.
var z72 := 0
var z58 := 0                        # $58 -- how many are still on the ride
var hero_suit := 0                  # $05C5 -- which suit is on
var hero_flags := 0                 # $05CB
var hero_state := 0                 # $05A2 -- what the hero is busy with
var hero_timer := 0                 # $05A3 -- how long the state has left
var hero_pic_lo := 0                # $05A6 -- the picture he is drawn from
var hero_pic_hi := 0                # $05A7
var hero_fuel := 0                  # $05AF -- what the wire has left
var hero_pose := 0                  # $05B5 -- the walk the state itself asks
var hero_step_t := 0                # $05A4 -- how far into that walk he is
var z5ab := 0                       # $05AB -- the burst of the doubled weapon
var hero_rise := 0                  # $05AD:$05AE -- the fall he has built up
var hero_ground := 0                # $05CD -- what he is standing on, which
                                    #          the turning puts back to plain
var hero_jump := 0                  # $05E8 -- and the three numbers a jump
var hero_grav := 0                  # $05E9    is made of, which the one that
var hero_hold_max := 0              # $05EA    turns the world over rewrites
var hero_hurt := 0                  # $05C2 -- frames of being left alone
var hero_shield := 0                # $05C8
var z5fa := 0                       # $05FA -- set while the stage is ending
var pad_new := 0                    # $04 -- what was pressed this picture
## The Y register, as far as anything outside a routine can see it.  $C12E,
## which every $C051 goes through, opens with STY $90 and so writes the Y of
## the moment over the low byte of $90 before it swaps banks.  Two places
## notice: $A802, whose $90 is gone altogether, and $8E44, which is handed the
## hero's own place in $90 by $8043 a few instructions earlier and reads the
## register back as the low byte of it.  So the angle a thing takes to the
## hero is not quite the angle to the hero.
var y_reg := 0
var stage := 0                      # $55 -- which stage is up
var zf8 := 0                        # $F8 -- what the game is to be put to next
var map_kind := 0                   # $70 -- $3C is the stage that is all water
var z9f := 0                        # $9F -- the step a behaviour wants its
                                    # shot to take along, before $80FD turns
                                    # it round for the side the thing faces
var z9d := 0                        # $9D -- what the last probe left over
var z5f0 := 0                       # $05F0 -- the map owes the screen a redraw
## $54 and $88..$8F -- the hero's own box.  It is built once a picture, at
## $80DE, before the pool is walked at all, so every slot is laid over the same
## one.
var hero_box_flags := 0             # $54
var hero_bx := 0                    # $88:$89
var hero_by := 0                    # $8A:$8B
var hero_bw := 0                    # $8C:$8D
var hero_bh := 0                    # $8E:$8F
## Э5.4 -- a hero of the other game standing in this stage.  He is carried in
## a `SolPlayer` of his own that nothing ever steps: the touch reads a dozen
## numbers off the hero and writes back three, and this is where they live, so
## no field of him is named twice.  `guest_box` is the five numbers above,
## worked out by his own game, because his picture means nothing to $8A19.
## Nothing there means nobody is there.  See `work/re/pb3_hits.md`.
var guest: SolPlayer = null
var guest_box: Array = []
## Э5.7 -- and more than one of them, as `[SolPlayer, box]`, for when neither
## of a pair's two heroes came from the game the stage did.  The one named
## above stays what it is: it is what Э5.4's stand hands over.
var more_guests: Array = []
## Э5.8 -- and what a guest of this stage is carrying.  One entry a guest,
## `[arms, spend]`: `arms` is what of his is in the air, each one
## `[x, y, reach, power]` in this stage's own sixteenths, and
## `spend.call(j, cost)` tells his own game what the thing cost arm `j` --
## the same number $8731 takes off $0770 for a gun of this stage's own.
## Stepping them is not this pool's: they are his, and they are stepped where
## he is.  See `work/re/pb3_arms.md`.
var guest_arms: Array = []
## $60..$68 -- and the box of the thing whose turn it is.
var z60 := 0                        # $60, what touching it means
var z61 := 0                        # $61:$62
var z63 := 0                        # $63:$64
var z65 := 0                        # $65:$66
var z67 := 0                        # $67:$68
## $9C:$9D and $9E:$9F, and $9B beside them.  $84B0 builds a grown copy of the
## thing's box there and $84CD reads it; the cartridge writes it over the same
## bytes $81B7 used a moment earlier, which is safe because $8244 has already
## read them by the time $83E2 runs.
var zg_x := 0
var zg_y := 0
var zg9b := 0
## The carry standing at the end of all that.  $CFE8 walks straight on from
## $CF96 and $81B7 without a SEC anywhere, so the first compare the hero's own
## pool makes reads one sixteenth further back when this is clear.  Every exit
## that can reach $869C sets it.
var z_c := 0
var z9c := 0                        # $9C, which side the overlap came from
## $A1AD -- the slot's whole turn is over, touching and all.  The cartridge
## throws away two returns there, and the second of them is $81A8, so $81A9
## never asks whether the thing has touched anybody.
var quit_turn := false
## $05C3 -- how long until the satellite is born.  A finished combination
## sets it to $80; it counts down, the satellite is made at $30, and until
## it is under $31 the whole pool stands still.
var born_wait := 0
## $05C4 -- the three letters that have been picked up, a pair of bits each.
var letters := 0
var hero_bonus := 0                 # $05C6:$05C7 -- points still to be counted
## The hero himself, because being touched writes back into him.  A stand that
## has no hero simply never touches anything.
var hero: SolPlayer = null

## Э4.5 -- where the two flat pools put their sprites, or nothing at all.  A
## stand that runs the pool for the numbers alone hands no table over and then
## none of the drawing happens; the live game hands one over every picture.
var table: SolSprites.Table = null
## $02 -- the flow, when a whole game is being run and not one stage.  $97A7
## hands it the death.
var flow: SolFlow = null
## $0112 -- the third colour of the sprites' first set, which the shimmer of
## the shield walks ($969E).  The pool keeps its own copy, because a stand
## that runs a stage alone has no table of colours to walk; with a flow to
## hand, the flow's table is the one the console shows.
var z0112 := 0
## $56 -- what a panel took, and has not been taken off the bonus yet.  $CDE3
## takes one off both every picture, so a price is paid a point at a time.
var z56 := 0
var skipped := {}                   # which behaviours have not been read yet


## $934C, which $8019 of the twelfth bank is the door to -- the hero's own
## slot of the pool, number twelve, wiped.  The way out of a stage calls it
## once, so that nothing the stage just left is still standing in him.
func sat_clear() -> void:
	cool[0x0C] = 0xFF                   # $934C -- $06EC
	id[0x0C] = id[0x0C] & 0x7F          # $9351 -- $065C
	a[0x0C] = 0                         # $9359 -- $062C
	b[0x0C] = 0                         # $063C
	c[0x0C] = 0                         # $064C
	kind[0x0C] = 0                      # $069C
	left[0x0C] = 0                      # $06CC
	frame[0x0C] = 0                     # $06DC
	anim_a[0x0C] = 0                    # $06AC
	anim_b[0x0C] = 0                    # $06BC
	pic_lo[0x0C] = 0                    # $066C
	pic_hi[0x0C] = 0                    # $067C


## $96A7 -- what the shimmer writes, kept both places at once.
func shine_to(v: int) -> void:
	z0112 = v
	if flow != null:
		flow.fade.out[0x12] = v

var _types: Array
var _anims: Array
var _anims3: Array
var _anims1: Array
var _anim_base := {}                ## $801C -- where each set's table stands
var _anim_ptrs := {}                ## $8038 -- where each id's steps stand
var hatch_paint: Dictionary
var _hatch: PackedByteArray
var _hatch2: PackedByteArray
var _steps: PackedByteArray
var _arctan: PackedByteArray
var _born: PackedByteArray
var _gone: PackedByteArray
var _room_group: PackedByteArray
var _groups: Dictionary
## $8A19, $91B5 and $CFF1 -- what a picture does when it is touched, the box
## it does it with, and which behaviours are only tested every other picture.
var _hit_pic: Array
var _hit_box: Array
var _hit_slow: PackedByteArray
## $895C -- and the same again for the other pool, read with the shot's own
## behaviour when the shots are laid over one of the hero's four slots.
var _hand_slow: PackedByteArray
## $8759 -- read with the satellite's own behaviour: which of the hero's eight
## weapon slots are laid over a thing, and in what order.
var _slot_order: PackedByteArray
## $9060 -- fifteen rings of sixteen, the quarter circle $8FF6 turns an angle
## into a step with.
var _aim: PackedByteArray
## $AEBD's twenty two rows: which slot to try first, how much it goes
## through, its two speeds and its four sets of starting offsets.
var weapon_table: Dictionary
## $A5C1, $AE5F, $ADEF and the rest: what the hero's own four slots are
## driven by.
var sat_table: Dictionary

## $880A -- one byte a behaviour, the noise it makes when it is struck.
var _noise := PackedByteArray()


func _init(lvl: SolLevel) -> void:
	level = lvl
	var t: Dictionary = Nes._load_json("%s/sol/objects.json" % Nes.DATA)
	_types = t["types"]
	_anims = t["anims"]
	_anims3 = t["anims3"]
	_anims1 = t["anims1"]
	_anim_base = t["anim_base"]
	_anim_ptrs = t["anim_ptrs"]
	_hatch = PackedByteArray(t["hatch"])
	hatch_paint = t["hatch_paint"]
	_hatch2 = PackedByteArray(t["hatch2"])
	_steps = PackedByteArray(t["steps"])
	_arctan = PackedByteArray(t["arctan"])
	_noise = PackedByteArray(t["noise"])
	var h: Dictionary = Nes._load_json("%s/sol/hits.json" % Nes.DATA)
	_hit_pic = h["pic"]
	_hit_box = h["box"]
	_hit_slow = PackedByteArray(h["slow"])
	_hand_slow = PackedByteArray(h["hand"])
	_slot_order = PackedByteArray(h["order"])
	_aim = PackedByteArray(Nes._load_json("%s/sol/aim.json" % Nes.DATA)["ring"])
	weapon_table = Nes._load_json("%s/sol/weapon.json" % Nes.DATA)
	sat_table = Nes._load_json("%s/sol/sat.json" % Nes.DATA)
	_born = PackedByteArray(t["born"])
	_gone = PackedByteArray(t["gone"])
	_room_group = lvl.room_group
	_groups = lvl.object_groups
	for arr in [id, mind, pic_lo, pic_hi, face, a, b, c, d, kind,
			anim_a, anim_b, left, frame, cool, life]:
		arr.resize(SLOTS)
	for arr in [s_kind, s_a, s_b, s_life]:
		arr.resize(SHOTS)
	s_x.resize(SHOTS)
	s_y.resize(SHOTS)
	for arr in [w_kind, w_vx, w_vy, w_pen]:
		arr.resize(WEAPONS)
	w_x.resize(WEAPONS)
	w_y.resize(WEAPONS)
	x.resize(SLOTS)
	y.resize(SLOTS)
	at_x.resize(SLOTS)
	at_y.resize(SLOTS)
	raise()


## $E788 -- what a stage starts with: every spawn id still to come, no slot
## taken.
func raise() -> void:
	mark.resize(MARKS)
	mark.fill(1)
	for i in range(SLOTS):
		id[i] = 0


## $EC44 / $EC2B -- the camera has moved; if it has crossed a half-block the
## background owes a column or a row, and that is what later asks for a scan.
func scrolled(cam_x: int, cam_y: int) -> void:
	if ((cam_x ^ seen_x) & 0x80) != 0:
		seen_x = cam_x & 0xFFFF
		col_due = 0xFF
	if ((cam_y ^ seen_y) & 0x80) != 0:
		seen_y = cam_y & 0xFFFF
		row_due = 0xFF


## $FB22 / $FB5F -- the top of the frame, where what the background owes is
## paid and turned into the ask for a scan.  The column is paid first and the
## row after it, so a frame that owes both ends up asking on the row.
func drew() -> void:
	if col_due != 0:
		due = col_due
		col_due = 0
	if row_due != 0:
		due = row_due
		row_due = 0


## $93B5 -- which room the middle of the picture is in.
func room_of(cam_x: int, cam_y: int) -> int:
	var col: int = (((cam_x >> 8) + 8) & 0xFF) >> 4
	var row: int = (((cam_y >> 8) + 8) & 0xFF) & 0xF0
	return (row + col) & 0xFF


## $8059 / $CE44 -- which cell of the ring a place falls in, or -1 for one
## nowhere near the picture.  `floor_cam` is the $CE44 habit of dropping the
## camera's sixteenths before subtracting; the spawner does not.
func _cell(ox: int, oy: int, cam_x: int, cam_y: int, floor_cam: bool) -> int:
	var cx: int = (cam_x & 0xFFF0) if floor_cam else cam_x
	var cy: int = (cam_y & 0xFFF0) if floor_cam else cam_y
	var dx: int = ((ox - cx) >> 8) & 0xFF
	dx = (dx + 0x10) & 0xFF
	if dx >= 0x30:
		return -1
	var dy: int = ((oy - cy) >> 8) & 0xFF
	dy = (dy + 0x10) & 0xFF
	if dy >= 0x30:
		return -1
	var n: int = (dy & 0xFC) * 3 + (dx >> 2)
	if n < FIRST_CELL or n >= END_CELL:
		return -1
	return n


## $AE69 -- the whole scan: one frame's worth of "is anything from this room
## standing just outside the picture".
func scan(cam_x: int, cam_y: int, hero_x: int, hero_state: int) -> void:
	if due == 0:
		return
	if (col_due | row_due) != 0:
		return
	if hero_state >= HERO_BUSY:
		return
	due = 0
	if room >= _room_group.size():
		return
	var g: int = _room_group[room]
	if g == 0xFF:
		return
	var key := str(g)
	if not _groups.has(key):
		return
	var recs: Array = _groups[key]
	for r in recs:
		var ox: int = int(r["x"])
		var oy: int = int(r["y"])
		var n := _cell(ox, oy, cam_x, cam_y, false)
		if n < 0:
			continue                    # $8093 -- nowhere near the picture
		var side: int = _born[n - FIRST_CELL]
		if side >= 0x80 or side == 0:
			continue
		var gate: int = int(r["gate"])
		if gate != ANY and gate != side:
			continue
		_place(int(r["kind"]), int(r["param"]), ox, oy, hero_x)


## $AEF7 -- find a free slot, cross the spawn id off, and fill the slot in.
func _place(spawn_id: int, type_id: int, ox: int, oy: int, hero_x: int) -> void:
	for s in range(LAST_SPAWNED, -1, -1):
		if id[s] != 0:
			continue
		var m: int = mark[spawn_id]
		if m == 0 or (m & 0x80) != 0:
			# He is dead for good, or he is already out; either way nobody is
			# born, and the cartridge keeps walking the slots all the same.
			continue
		mark[spawn_id] = m | 0x80
		_fill(s, spawn_id, type_id, ox, oy, hero_x)
		return


## $AF20 -- a slot, from the record's place and the type's nine bytes.
func _fill(s: int, spawn_id: int, type_id: int, ox: int, oy: int,
		hero_x: int) -> void:
	id[s] = spawn_id
	x[s] = ox & 0xFFFF
	y[s] = oy & 0xFFFF
	var t: Dictionary = _types[type_id]
	mind[s] = int(t["mind"])
	pic_lo[s] = int(t["pic_lo"])
	pic_hi[s] = int(t["pic_hi"])
	a[s] = int(t["a"])
	b[s] = int(t["b"])
	c[s] = int(t["c"])
	d[s] = int(t["d"])
	kind[s] = int(t["kind"])
	life[s] = int(t["life"])
	# $AF8E -- which way it looks is which side of it the hero is on, and the
	# cartridge keeps only the high byte of the difference, sign and all.
	face[s] = ((hero_x - ox) >> 8) & 0xFF
	frame[s] = 0
	left[s] = 0
	anim_a[s] = 0
	anim_b[s] = 0
	cool[s] = 0xFF


## $CE44 -- where the slot sits on the screen, and whether it is still near
## enough to keep.  Answers false when the slot has been taken away.
func _keep(s: int, cam_x: int, cam_y: int) -> bool:
	var cx: int = cam_x & 0xFFF0
	var cy: int = cam_y & 0xFFF0
	at_x[s] = _signed((x[s] - cx) & 0xFFFF)
	at_y[s] = _signed((y[s] - cy) & 0xFFFF)
	if (id[s] & 0x40) != 0:
		return true                     # $CE4B -- this one never leaves
	var n := _cell(x[s], y[s], cam_x, cam_y, true)
	if n >= 0 and _gone[n - FIRST_CELL] < 0x80:
		return true
	# $CEC5 -- put the spawn id back so the same thing can come round again.
	mark[id[s] & 0x3F] &= 0x7F
	id[s] = 0
	return false


## $BD80 -- the first of the two animation ids.  Reaching a step that is held
## for ever puts the id back to nothing.
func anim_first(s: int, n: int, set := 4) -> void:
	if anim_a[s] != n:
		anim_a[s] = n
		frame[s] = 0
		left[s] = 0
	_tick(s, anim_a[s], set)
	# $BD98 -- the tail compares what is left against $FF, and the carry that
	# comparison makes is read by whatever adds next.
	carry = 1 if left[s] == 0xFF else 0
	if left[s] == 0xFF:
		anim_reset(s)


## $BD9D -- the first id is dropped and the walk starts over.
func anim_reset(s: int) -> void:
	anim_a[s] = 0
	frame[s] = 0
	left[s] = 0


## $BDAB -- the second one.  It has no tail of its own, but all but two of the
## seventy six places that want it go through $99D9, which puts $80E0 on the
## end: the compare of what is left against $FF, whose carry is read by
## whatever adds next ($9797 is one such).  So the tail is here, and the two
## that want it bare ($8985 and $904B) say so.
func anim_second(s: int, n: int, set := 4, tail := true) -> void:
	if anim_b[s] != n:
		anim_b[s] = n
		frame[s] = 0
		left[s] = 0
	_tick(s, anim_b[s], set)
	if tail:
		carry = 1 if left[s] == 0xFF else 0     # $99DE -> $80E0


## $BDBD -- one picture of the walk: a hold of $FF stays where it is, anything
## else counts down and steps on when it runs out.
func _tick(s: int, n: int, set := 4) -> void:
	var h: int = left[s]
	if h == 0:
		_advance(s, n, set)
		return
	if h == 0xFF:
		return
	left[s] = h - 1
	if left[s] == 0:
		_advance(s, n, set)


## $8026 in bank 12 -- the next step of the walk, and a step whose hold is
## nothing means start the walk again.  $9A picks the set: four for the
## things in the pool, three for the handful that ask for it by name, one
## for everything in the hero's own four slots.
func _advance(s: int, n: int, set := 4) -> void:
	var book: Array = _anims if set == 4 else (_anims3 if set == 3 else _anims1)
	if n >= book.size():
		return
	var steps: Array = book[n]
	if steps.is_empty():
		return
	# $802D and $8038 -- the set's own table and the id's step list are left
	# standing in $90:$91 and $92:$93, and whoever looks next reads them as
	# numbers of its own: $9BCF asks $B0AE for a look a picture down and
	# however far along the low byte of $90 happens to say.
	var key: String = str(set)
	z90 = int(_anim_base[key])
	var ptrs: Array = _anim_ptrs[key]
	if n < ptrs.size():
		z92 = int(ptrs[n])
	if frame[s] >= steps.size():
		frame[s] = 0
	var st: Array = steps[frame[s]]
	left[s] = int(st[0])
	pic_lo[s] = int(st[1])
	pic_hi[s] = int(st[2])
	# $8E1F reads the step three bytes at a time and leaves Y just past it.
	y_reg = (frame[s] * 3 + 2) & 0xFF
	frame[s] = (frame[s] + 1) & 0xFF


## $CF26 -- the slot into the sprite table.  The hero has already been laid out
## by the time this runs, and the slots go from the last down to the first.
func _draw(s: int, t: SolSprites.Table) -> void:
	if pic_lo[s] == 0 and pic_hi[s] == 0:
		return
	if cool[s] == 0x10:
		return                          # $CF3A -- the blink of being hit
	var mark := 0
	if (mind[s] & 0x80) == 0 and cool[s] < 0x10:
		mark = cool[s] & 3              # $CF43 -- the colour flickers
	var pic: int = pic_lo[s] | pic_hi[s] << 8
	if (face[s] & 0x80) != 0:
		pic += 1                        # $CF64 -- the other way round
	SolSprites.picture(pic, mark, at_x[s], at_y[s], t)


## $CE1D -- one frame of the pool, from the last slot down to the first.  Each
## slot is tested for the picture, drawn, and only then given its own mind:
## that is the order $CE26 keeps, and it is why a thing is drawn where it was
## rather than where it is about to be.
func step(view_x: int, view_y: int, t: SolSprites.Table = null) -> void:
	cam_x = view_x
	cam_y = view_y
	for s in range(LAST_SPAWNED, -1, -1):
		if id[s] == 0:
			continue
		if not _keep(s, view_x, view_y):
			continue
		# $CE30 -- one more frame since it was last hit, and it stops at $FF
		# rather than rolling over into "just hit".
		if cool[s] != 0xFF:
			cool[s] += 1
		if t != null:
			_draw(s, t)
		SolMinds.run(self, s)


## The two bytes of arithmetic the minds lean on.  The carry is kept because
## $AE30 subtracts without setting it first and so answers one less when the
## last sum before it did not carry.
func _sbc(p: int, q: int) -> int:
	var r: int = p - q - (1 - carry)
	carry = 1 if r >= 0 else 0
	return r & 0xFF


func _adc(p: int, q: int) -> int:
	var r: int = p + q + carry
	carry = 1 if r > 0xFF else 0
	return r & 0xFF


## $AE30 -- how far the slot is from the hero along, as a number with no sign.
## $94 keeps the sign.  Answers the high byte, which is whole pixels.
func far_x(s: int) -> int:
	var lo: int = _sbc(x[s] & 0xFF, hero_x & 0xFF)
	var hi: int = _sbc((x[s] >> 8) & 0xFF, (hero_x >> 8) & 0xFF)
	z94 = hi
	if hi >= 0x80:
		var l2: int = _sbc(0, lo)
		hi = _sbc(0, hi)
		lo = l2
	z90 = lo | hi << 8
	return hi


## $AE5E -- the same, down.  $95 keeps the sign.
func far_y(s: int) -> int:
	var lo: int = _sbc(y[s] & 0xFF, hero_y & 0xFF)
	var hi: int = _sbc((y[s] >> 8) & 0xFF, (hero_y >> 8) & 0xFF)
	z95 = hi
	if hi >= 0x80:
		var l2: int = _sbc(0, lo)
		hi = _sbc(0, hi)
		lo = l2
	z92 = lo | hi << 8
	return hi


## $8FF6 in bank 12 -- a heading and a speed become a step along and a step
## down.  The table is a quarter circle read twice, once each way round.
func spin(dir: int, speed: int) -> void:
	var i: int = (dir & 0x0F) + speed
	var p: int = _steps[i & 0xFF]
	# $900D -- a quarter that lands on a corner has nothing in the other
	# direction at all, and the table is not read a second time for it.
	var q: int = 0
	if (i & 0x0F) != 0:
		q = _steps[(((i - 1) ^ 0x0F) & 0xFF)]
	var along: int = p
	var down: int = q
	if (dir & 0x10) != 0:
		along = q
		down = p
	z90 = along
	z92 = down
	var quad: int = dir & 0x30
	if quad == 0x10 or quad == 0x20:
		z90 = _neg(z90)
	if quad == 0x30 or quad == 0x20:
		z92 = _neg(z92)


## $8070 -- and the two are taken over as this picture's step.
func heading(dir: int, speed: int) -> void:
	spin(dir, speed)
	z50 = z90
	z52 = z92


## $9054 / $9048 -- nothing less the step, kept as two bytes.
static func _neg(v: int) -> int:
	var lo: int = (0x100 - (v & 0xFF)) & 0xFF
	if lo == 0:
		return 0
	return lo | 0xFF00


## $8066 -- the slot's own heading, at the slowest of the speeds.
func step_of(s: int) -> void:
	heading(a[s], 0)


## $813F -- the step is taken, and $813A first turns the slot to face it.
func move(s: int) -> void:
	carry = 0
	var lo: int = _adc(x[s] & 0xFF, z50 & 0xFF)
	var hi: int = _adc((x[s] >> 8) & 0xFF, (z50 >> 8) & 0xFF)
	x[s] = lo | hi << 8
	carry = 0
	lo = _adc(y[s] & 0xFF, z52 & 0xFF)
	hi = _adc((y[s] >> 8) & 0xFF, (z52 >> 8) & 0xFF)
	y[s] = lo | hi << 8


func move_facing(s: int) -> void:
	face[s] = (z50 >> 8) & 0xFF         # $813A
	move(s)


## $B2BB -- the fall: `n` is added to the sixteen bits of $0630:$0640 and what
## is there is added to the step down.  Once it is no longer rising it is held
## at the fastest the game lets a thing fall.
func fall(s: int, n: int) -> void:
	carry = 0
	var lo: int = _adc(n, c[s])
	var hi: int = _adc(d[s], 0)
	if hi < 0x80:
		hi = 0
		if lo >= 0x80:
			lo = 0x80
	c[s] = lo
	d[s] = hi
	carry = 0
	var zl: int = _adc(c[s], z52 & 0xFF)
	var zh: int = _adc(d[s], (z52 >> 8) & 0xFF)
	z52 = zl | zh << 8


## $B08F / $B097 -- the step along is set and turned round for a slot that is
## looking left, which is also what the look ahead is measured from.
func step_facing(s: int, n: int) -> void:
	z50 = n
	if (face[s] & 0x80) != 0:
		carry = 1
		var lo: int = _sbc(0, z50 & 0xFF)
		var hi: int = _sbc(0, (z50 >> 8) & 0xFF)
		z50 = lo | hi << 8


## $8179 -- a step of `n` along, turned round when the slot faces left.
func step_along(s: int, n: int) -> void:
	z50 = n
	if (face[s] & 0x80) != 0:
		carry = 1
		var lo: int = _sbc(0, z50 & 0xFF)
		var hi: int = _sbc(0, (z50 >> 8) & 0xFF)
		z50 = lo | hi << 8


## $8118 -- face the hero, and answer the sign byte.
func face_hero(s: int) -> int:
	far_x(s)
	face[s] = z94
	return z94


## $818F -- the step down is turned round.
func flip_down() -> void:
	carry = 1
	var lo: int = _sbc(0, z52 & 0xFF)
	var hi: int = _sbc(0, (z52 >> 8) & 0xFF)
	z52 = lo | hi << 8


## $8B9E -- a small number, one or two either way, is added to the slot's own
## pair of speed bytes $0630:$0640.
func nudge(s: int, n: int) -> void:
	var hi: int = 0xFF if (n & 0x80) != 0 else 0x00
	carry = 0
	c[s] = _adc(n & 0xFF, c[s])
	d[s] = _adc(hi, d[s])


## $8B8A -- the pair becomes this frame's step along.
func speed_to_step(s: int) -> void:
	z50 = c[s] | d[s] << 8


## $AB10 -- a behaviour lets something out of itself.  The free slot is looked
## for from eleven downwards, and if there is none the answer is $FF.
## `top` is where the look for a free slot starts: eleven for everything the
## game calls $AB10 with, but $8418 hands $AAFA a seven of its own.
func hatch(px: int, py: int, tpl: int, top := 0x0B) -> int:
	var f := -1
	for i in range(top, -1, -1):
		if id[i] == 0:
			f = i
			break
	if f < 0:
		return 0xFF
	x[f] = px & 0xFFFF
	y[f] = py & 0xFFFF
	id[f] = 0x80
	mind[f] = _hatch[tpl]
	pic_lo[f] = _hatch[tpl + 1]
	pic_hi[f] = _hatch[tpl + 2]
	a[f] = _hatch[tpl + 3]
	b[f] = _hatch[tpl + 4]
	c[f] = _hatch[tpl + 5]
	d[f] = _hatch[tpl + 6]
	kind[f] = _hatch[tpl + 7]
	life[f] = _hatch[tpl + 8]
	carry = 1                           # $AB5B -- which way the new one looks
	_sbc(hero_x & 0xFF, x[f] & 0xFF)
	face[f] = _sbc((hero_x >> 8) & 0xFF, (x[f] >> 8) & 0xFF)
	frame[f] = 0
	left[f] = 0
	anim_a[f] = 0
	anim_b[f] = 0
	cool[f] = 0xFF                      # $80D4
	return f


## $AAF1 -- and the usual way in: the new thing starts where the old one is.
func hatch_here(s: int, tpl: int) -> int:
	return hatch(x[s], y[s], tpl)


## $AA9E -- one page along to the right and one down from the old one.
func hatch_right(s: int, tpl: int) -> int:
	return hatch(x[s] + 0x0100, y[s] + 0x0100, tpl)


## $AAA9 -- and the same to the left.
func hatch_left(s: int, tpl: int) -> int:
	return hatch(x[s] - 0x0100, y[s] + 0x0100, tpl)


## $8C83 -- the other way of letting something out, and the only one that
## counts upward: the free slot is looked for from nought to eleven, and the
## nine bytes come from a table of their own.  Everything else about it is as
## $AB10 has it.
func hatch_up(px: int, py: int, tpl: int) -> int:
	var f := -1
	for i in range(0x0C):
		if id[i] == 0:
			f = i
			break
	if f < 0:
		return 0xFF
	x[f] = px & 0xFFFF
	y[f] = py & 0xFFFF
	id[f] = 0x80
	mind[f] = _hatch2[tpl]
	pic_lo[f] = _hatch2[tpl + 1]
	pic_hi[f] = _hatch2[tpl + 2]
	a[f] = _hatch2[tpl + 3]
	b[f] = _hatch2[tpl + 4]
	c[f] = _hatch2[tpl + 5]
	d[f] = _hatch2[tpl + 6]
	kind[f] = _hatch2[tpl + 7]
	life[f] = _hatch2[tpl + 8]
	carry = 1                           # $8CF5 -- which way the new one looks
	_sbc(hero_x & 0xFF, x[f] & 0xFF)
	face[f] = _sbc((hero_x >> 8) & 0xFF, (x[f] >> 8) & 0xFF)
	frame[f] = 0
	left[f] = 0
	anim_a[f] = 0
	anim_b[f] = 0
	cool[f] = 0xFF                      # $8D0E
	return f


## $810D -- face the hero, but only when he is a whole picture away or more;
## nearer than that the slot keeps what it had.  Answers the facing either way.
func face_hero_far(s: int) -> int:
	far_x(s)
	if ((z90 >> 8) & 0xFF) == 0:
		return face[s]
	face[s] = z94
	return z94


## $9050 -- a behaviour says "do not take me away yet" by raising bit 6 of the
## slot, and it says it while the hero is within seven pictures.
func hold_on(s: int) -> void:
	var keep: int = 0x00 if ((z90 >> 8) & 0xFF) >= 0x07 else 0x40
	if keep != 0 and (noise & 0x3F) == 0:
		kind[s] = (kind[s] + 1) & 0xFF
	id[s] = (id[s] & 0xBF) | keep


## $9D0A -- the step along is set from the heading byte $0610 rather than the
## facing, and what lies that way is looked at.  Something solid stops the step
## and marks the slot.
func step_and_look(s: int, n: int) -> int:
	z50 = n                             # $9D0A
	var neg: bool = (a[s] & 0x80) != 0  # $9D1C
	if neg:
		carry = 1                       # $8181
		z50 = _neg16(z50)
	var p: Array = _b189(s, neg, 0x0080, 0x0040)
	var r: int = _d010(int(p[0]), int(p[1]))
	if r >= 0x80:                       # $9D33
		kind[s] = kind[s] | 0x80
		z50 = 0                         # $812C
	return r


## $80BF -- the mind is told the thing is finished.
func finish(s: int) -> void:
	mind[s] = mind[s] | 0x80


## A behaviour that has not been read yet.  It is counted rather than guessed
## at, so the acceptance can name what is still owed.
## $BE0F -- one place of the stage is hit.  Nothing is broken on a picture the
## background already owes a row or a column ($36/$37): there is no room left
## in the blanking for it.  What is hit is read out of the stage as it was
## written, not as it is shown, because it is the written number the mark is
## kept by.
##
## Only what stops something can be broken: the low nibble nought and four go
## through untouched, the rest give way.  Whether that shows is another
## matter -- a plain wall loses only what it stopped, a crate loses its face
## as well.
func smash(mx: int, my: int) -> int:
	if row_due != 0 or col_due != 0:
		return 0                        # $BE13
	z90 = (mx & 0xFF) << 8              # $BE1B -- the low bytes are dropped
	z92 = (my & 0xFF) << 8
	var m: int = level.raw_at((mx & 0xFF) << 4, (my & 0xFF) << 4)
	if m < 0:
		return 0xFF
	var n: int = level.props[m] & 0x0F  # $BE2C
	if n < 0x0C and (n & 0x03) == 0:
		return 0xFF                     # $BE18
	level.smash(m)                      # $BE36
	z5f0 = 0xFF                         # $BEE7
	return 0xFF


## $BF0B -- a whole burst of them: pairs of offsets in cells, counted from the
## slot's own, until $80 closes the list.
func smash_list(s: int, list: Array) -> int:
	if row_due != 0 or col_due != 0:
		return 0                        # $BF0F
	var i := 0
	while list[i] != 0x80:              # $BF17
		var mx: int = (list[i] + ((x[s] >> 8) & 0xFF)) & 0xFF
		var my: int = (list[i + 1] + ((y[s] >> 8) & 0xFF)) & 0xFF
		i += 2
		smash(mx, my)
	return 0xFF                         # $BF37


## $B9CD -- the harder question the hero's own punch asks of the stage: not
## "may this give way" but "is this worth punching at all".  A place gives way
## only where what it stops is under twelve and its bottom two bits are two or
## three, and nothing gives way at all on a picture the background still owes a
## row or a column.  The answer is those two bits ($60), or a negative number
## where nothing was broken.
func break_wall(px: int, py: int) -> int:
	if row_due != 0 or col_due != 0:
		return -1                       # $B9D1
	z90 = px & 0xFF00                   # $B9D6 -- the low bytes are dropped
	z92 = py & 0xFF00
	var m: int = level.raw_at(((px >> 8) & 0xFF) << 4, ((py >> 8) & 0xFF) << 4)
	if m < 0:
		return -1
	var v: int = level.props[m] & 0x1F  # $B9E7
	if v >= 0x0C:
		return -1                       # $B9EB
	z60 = v & 0x03                      # $B9F7
	if z60 < 0x02:
		return -1                       # $B9FB
	if not level.whole(m):
		return -1                       # $BA01
	level.smash(m)                      # $BA0F
	z5f0 = 0xFF                         # $BAEB
	return z60


## $BA15 -- the panels' own "may this give way", which is not the punch's
## $B9CD: here a place gives way where what it stops is twelve or more, or
## where its bottom two bits are not both nought, and a place already broken
## is broken again without complaint.  Nothing gives way at all on a picture
## the background still owes a row or a column.
##
## What the cartridge does beside breaking it is the screen's: the colours of
## the two cells and the pair of $E28C records that carry the new tiles.  That
## is the same machinery $B9CD leaves out here (Э4.4), and for the same
## reason: the engine draws the map from the mark itself.
func break_panel(px: int, py: int) -> void:
	if row_due != 0 or col_due != 0:
		return                          # $BA1B
	var m: int = level.raw_at(((px >> 8) & 0xFF) << 4, ((py >> 8) & 0xFF) << 4)
	if m < 0:
		return
	var v: int = level.props[m] & 0x0F  # $BA32
	if v < 0x0C and (v & 0x03) == 0:
		return                          # $BA1E -- no place here at all
	level.smash(m)                      # $BA4C
	z5f0 = 0xFF                         # $BAEB


func missed(m: int, done: bool) -> void:
	var key := "%02X%s" % [m, "-dead" if done else ""]
	skipped[key] = int(skipped.get(key, 0)) + 1


## And the same for the pool of shots, counted apart from the objects.
func missed_shot(m: int, done: bool) -> void:
	var key := "%02X%s" % [m, "-dead" if done else ""]
	shots_skipped[key] = int(shots_skipped.get(key, 0)) + 1


## And the same for the pool the satellite throws into.
func missed_weapon(m: int, done: bool) -> void:
	var key := "%02X%s" % [m, "-dead" if done else ""]
	weapons_skipped[key] = int(weapons_skipped.get(key, 0)) + 1


## $A594 -- and the same for the fourteen the hero's own slots are walked by.
func missed_sat(m: int) -> void:
	var key := "%02X" % m
	sat_skipped[key] = int(sat_skipped.get(key, 0)) + 1


## And an entry of bank six that has not been read either.
func missed_stage(n: int) -> void:
	var key := "stage%02X" % n
	shots_skipped[key] = int(shots_skipped.get(key, 0)) + 1


## $8E44 in bank 12 -- which way the slot lies from the hero, as a heading.
## Answers $FF when the two are on top of each other or too far apart to say.
func angle_to_hero(s: int) -> int:
	return angle_to(s, hero_x, hero_y)


## $804B -- the same, but the height is the caller's own, not the hero's.
func angle_to(s: int, tx: int, ty: int) -> int:
	# $C12E -- and the low byte of the place asked after is the Y of whoever
	# asked, not the byte $8043 put there.  See `y_reg`.
	return angle_between(x[s], y[s], (tx & 0xFF00) | y_reg, ty)


## $8E44 itself, over two places neither of which need be a slot.
func angle_between(px: int, py: int, tx: int, ty: int) -> int:
	var p := PackedInt32Array([px & 0xFF, (px >> 8) & 0xFF,
			py & 0xFF, (py >> 8) & 0xFF])
	carry = 1
	var ax: int = _sbc(p[0], tx & 0xFF)
	var bx: int = _sbc(p[1], (tx >> 8) & 0xFF)
	var turn := 0
	if carry == 0:
		# $8E55 -- and $8FD2 turns straight round where the high byte has no
		# sign on it, so a pair that borrowed and yet reads positive is left
		# as it stands.  The quarter of the turn is counted either way.
		if (bx & 0x80) != 0:
			var t: int = _neg16(ax | bx << 8)
			ax = t & 0xFF
			bx = (t >> 8) & 0xFF
		turn = 2
	carry = 1
	var ay: int = _sbc(p[2], ty & 0xFF)
	var by: int = _sbc(p[3], (ty >> 8) & 0xFF)
	if carry == 0:
		if (by & 0x80) != 0:                # $8FE6
			var t: int = _neg16(ay | by << 8)
			ay = t & 0xFF
			by = (t >> 8) & 0xFF
		turn += 1
	if turn != 0 and turn != 3:
		var t0 := ax
		var t1 := bx
		ax = ay
		bx = by
		ay = t0
		by = t1
	var base: int = [0x00, 0x30, 0x10, 0x20][turn]
	if (ax | bx | ay | by) == 0:
		return 0xFF
	# $8E99 -- both lengths are doubled until the longer of them fills the top
	# nibble, so that the table below is read at the best resolution there is.
	# The doubling comes before the test, so a pair that was long enough
	# already is doubled once too often and the answer comes back "cannot
	# say".  That is how a thing a long way off is refused an angle at all.
	var dx: int = ax | bx << 8
	var dy: int = ay | by << 8
	var guard := 0
	while true:
		dx = (dx << 1) & 0xFFFF
		dy = (dy << 1) & 0xFFFF
		guard += 1
		if (((dx >> 8) | (dy >> 8)) & 0xFF) >= 0x10 or guard >= 32:
			break
	var hx: int = (dx >> 8) >> 1
	var hy: int = (dy >> 8) >> 1
	if hx >= 0x10 or hy >= 0x10:
		return 0xFF
	return (_arctan[((hy << 4) + (hx & 0x0F)) & 0xFF] + base) & 0xFF


## $802B -- the heading is turned one step toward the hero.
func turn_toward_hero(s: int) -> void:
	turn_step(s, angle_to_hero(s))


## $802E -- one step of the heading toward an angle already worked out.
func turn_step(s: int, want: int) -> void:
	carry = 1
	var d: int = _sbc(want, a[s]) & 0x3F
	carry = 1 if d >= 0x20 else 0
	var step: int = 0x00 if d >= 0x20 else 0xFF
	a[s] = _adc(step, a[s])


## $D09C -- what the stage has at a place, in the hero's own words.
func probe(px: int, py: int) -> int:
	return (level.collision_at((px & 0xFFFF) >> 4, (py & 0xFFFF) >> 4) << 3) & 0xFF


## $B13F -- what is behind the slot's feet.  The offset along is turned round,
## because $B13F hands $B189 the facing the other way about.
func probe_behind(s: int, ox: int, oy: int) -> int:
	var p: Array = _b189(s, ((face[s] ^ 0xFF) & 0x80) != 0, ox, oy)
	return probe_point(int(p[0]), int(p[1]))    # $C00C


## $B151 -- and what is above it, at a given height.  The place along is the
## slot's own, copied whole; only the height is taken away, and that with a SEC
## of its own, so nothing here leans on the carry walking in.
func probe_above(s: int, oy: int) -> int:
	carry = 1                           # $B15B
	var q: Array = _sub2(y[s], oy, carry)
	carry = int(q[1])
	return probe_point(x[s], int(q[0]))         # $C00C


## $B170 -- what lies ahead, looked at only every other picture, and offset by
## the hero's own speed ($D010).  Answers nothing on the picture it sits out.
## The ROR at $B173 is what asks: the bit it rolls out is the answer, and it is
## left standing in the carry, so the look below always walks in with one.
func probe_ahead(s: int, ox: int, oy: int) -> int:
	if ((s ^ clock) & 1) == 0:
		carry = 0                       # $B176
		return 0
	carry = 1                           # $B174
	return probe_fwd(s, ox, oy)


## $B186 + $D032 -- what lies ahead of the slot's own facing, every picture and
## without the hero's speed in it.  The leftover here is the low byte of the
## height looked at, not of the place along.
func probe_at(s: int, ox: int, oy: int) -> int:
	var p: Array = _b189(s, (face[s] & 0x80) != 0, ox, oy)
	return probe_point(int(p[0]), int(p[1]))


## $D032 itself -- the map at a plain place, whoever is asking.  The shots ask
## it too ($B8E5), with no offset at all.
func probe_point(px: int, py: int) -> int:
	if map_kind == 0x3C:
		# $D03B -- on the carrying map the lift itself is the ground, and it
		# is solid from its own line down to a whole picture below it.
		carry = 0
		var sl: int = _adc((z75 << 4) & 0xFF, cam_y & 0xFF)
		var sh: int = _adc((z75 >> 4) & 0x0F, (cam_y >> 8) & 0xFF)
		carry = 1
		var dl: int = _sbc(py & 0xFF, sl)
		var d: int = _sbc((py >> 8) & 0xFF, sh)
		if carry != 0 and d == 0:
			# $D065 -- how far into the lift's own line he has come is taken
			# off his falling, and what the lift sinks by ($72) put back on.
			carry = 1
			z9d = dl
			var lo: int = _sbc(hero_vy & 0xFF, z9d)
			var hi: int = (hero_vy >> 8) & 0xFF
			if carry == 0:
				hi = (hi - 1) & 0xFF        # $D076
			carry = 0                       # $D079
			lo = _adc(lo, z72)
			if carry != 0:
				hi = (hi + 1) & 0xFF        # $D084
			hero_vy = (hi << 8) | lo
			z9d = 0
			return 0x80
	z9d = py & 0xFF                     # $D08F
	return probe(px, py)


## $B179 -- the same look ahead as $B170, but taken every picture.
func probe_fwd(s: int, ox: int, oy: int) -> int:
	var p: Array = _b189(s, (face[s] & 0x80) != 0, ox, oy)
	return _d010(int(p[0]), int(p[1]))          # $C00F


## $B189 -- the place the look is taken at, in the slot's own two halves.  The
## way the slot faces picks the sign: away from it is a take-away with a SEC of
## its own, toward it an add that is handed the carry the caller left standing,
## because there is no CLC in front of it.  The height below is a CLC add, and
## the carry it leaves is the one $D010 goes on to add the hero's speed with.
func _b189(s: int, neg: bool, ox: int, oy: int) -> Array:
	var px: int
	if neg:
		carry = 1                       # $B18B
		px = int(_sub2(x[s], ox, carry)[0])
	else:
		px = int(_add2(x[s], ox, carry)[0])     # $B19B -- no CLC
	var q: Array = _add2(y[s], oy, 0)           # $B1A7
	carry = int(q[1])
	return [px, int(q[0])]


## $D010 -- the same place, with the hero's own speed added along.  On a
## carrying map nothing is looked at at all: the answer is the map's own
## number.  The add has no CLC, and the carry it takes is the one the ask
## about that map left.
func _d010(px: int, py: int) -> int:
	if map_kind == 0x3C:
		return map_kind                 # $D014
	# $D012 -- the compare just above is what the add takes its carry from,
	# not whatever the caller was holding.
	carry = 1 if map_kind >= 0x3C else 0
	var r: Array = _add2(px, hero_vx, carry)    # $D016 -- no CLC of its own
	z9d = int(r[0]) & 0xFF              # $D01D
	return probe(int(r[0]), py)         # $D09C


## $8FD2 and $8FE4 -- nought take away the pair.  Both begin with a SEC of
## their own ($8FD6, $8FE8), so the borrow is never the caller's; every place
## that jumps in here is written as though it were, and one of them ($8E55)
## reaches it with the borrow of the very subtraction that asked for the
## negating still down.
func _neg16(v: int) -> int:
	carry = 1
	var lo: int = _sbc(0, v & 0xFF)
	var hi: int = _sbc(0, (v >> 8) & 0xFF)
	return lo | hi << 8


static func _signed(v: int) -> int:
	return v - 0x10000 if v >= 0x8000 else v


# ---------------------------------------------------------------------------
# Touching.  Every picture in the game -- the hero's and everything else's --
# carries two bytes in bank eight's table at $8A19: what touching it means and
# which of the boxes at $91B5 it is.  A box is where it starts from the thing's
# own place and how big it is, in sixteenths of a pixel.
#
# The hero's box is built before the pool is walked ($CDBE); each thing's is
# built as its turn comes ($C02A), and the two are then laid over one another
# ($C02D).  What the cartridge does with a hit is in `work/re/sol_hits.md`.
# ---------------------------------------------------------------------------

const NO_BOX := [0, 0, 0, 0]


## $814C -- the two bytes a picture carries and the box they lead to.  A
## picture numbered past the end of the table has none: the cartridge would
## read whatever stands after it, and nothing the game draws is that high.
func _hit_of(pic: int) -> Array:
	if pic < 0 or pic >= _hit_pic.size():
		return [0, NO_BOX]
	var e: Array = _hit_pic[pic]
	return [int(e[0]), _hit_box[int(e[1])]]


## Э5.4 -- every shape of thing the sweep can ever be asked about, one for
## each pair of a box and a meaning that some picture wears: what a stand
## needs to try them all without guessing which stage puts out which.  Each is
## a picture that wears the pair, the meaning, which box it is, and the box.
## $8A19's first byte of a picture's pair: what touching that picture means.
## Э5.8 asks it of a guest's own pool, because that is where his satellite's
## and his punch's pictures live.
func meaning_of(pic: int) -> int:
	return int(_hit_of(pic)[0])


func hit_kinds() -> Array:
	var seen := {}
	var out: Array = []
	for p in range(_hit_pic.size()):
		var e: Array = _hit_pic[p]
		if int(e[0]) == 0:
			continue
		var k: int = (int(e[0]) << 8) | int(e[1])
		if seen.has(k):
			continue
		seen[k] = true
		out.append([p, int(e[0]), int(e[1]), _hit_box[int(e[1])]])
	return out


## Two bytes added, and the carry the add leaves, because the boxes are built
## with the carry chained from one pair to the next the way the cartridge
## chains it.
func _add2(p: int, q: int, c: int) -> Array:
	var lo: int = (p & 0xFF) + (q & 0xFF) + c
	var hi: int = ((p >> 8) & 0xFF) + ((q >> 8) & 0xFF) + ((lo >> 8) & 1)
	return [((hi & 0xFF) << 8) | (lo & 0xFF), (hi >> 8) & 1]


## And two taken away.  The carry is the borrow the 6502 keeps: one means
## there was none.
func _sub2(p: int, q: int, c: int) -> Array:
	var lo: int = (p & 0xFF) - (q & 0xFF) - (1 - c)
	var cl: int = 1 if lo >= 0 else 0
	var hi: int = ((p >> 8) & 0xFF) - ((q >> 8) & 0xFF) - (1 - cl)
	return [((hi & 0xFF) << 8) | (lo & 0xFF), 1 if hi >= 0 else 0]


func _ge2(p: int, q: int) -> bool:
	return (p & 0xFFFF) >= (q & 0xFFFF)


## $80DE -- the hero's box, in front of the whole pool walk.
func hero_box() -> void:
	hero_box_flags = 0
	if hero == null:
		return
	# $8133 -- his picture, and the one next door when he looks left.
	var pic: int = hero.pic_lo | (hero.pic_hi << 8)
	if pic != 0 and hero.face_left:
		pic += 1
	var got: Array = _hit_of(pic & 0xFFFF)
	var box: Array = got[1]
	hero_box_flags = int(got[0])
	hero_bw = int(box[2])
	hero_bh = int(box[3])
	var r: Array = _add2(int(box[0]), hero.x, 0)
	hero_bx = r[0]
	if (hero.flags & 0x80) != 0:
		# $810D -- hung upside down, the box grows the other way from his feet.
		var u: Array = _sub2(hero.y, int(box[1]), r[1])
		hero_by = _sub2(u[0], hero_bh, u[1])[0]
	else:
		hero_by = _add2(int(box[1]), hero.y, r[1])[0]


## $CF96 -- the box of the thing whose turn it is.  False when its picture has
## none, and then nothing else is asked at all.
func touch_box(s: int) -> bool:
	var pic: int = pic_lo[s] | (pic_hi[s] << 8)
	if (face[s] & 0x80) != 0:
		pic += 1
	var got: Array = _hit_of(pic & 0xFFFF)
	z60 = int(got[0])
	if z60 == 0:
		return false
	# $817B -- and the box put where the thing itself stands.
	var box: Array = got[1]
	var r: Array = _add2(int(box[0]), x[s], 0)
	z61 = r[0]
	r = _add2(int(box[1]), y[s], r[1])
	z63 = r[0]
	z65 = int(box[2])
	z67 = int(box[3])
	# $CFB5 -- the way back out of $CF96 goes through the bank change at $C998,
	# whose last sum is "this bank plus one" and never carries, so whatever the
	# adds above left is thrown away and $CFBA is entered with it clear.
	z_c = 0
	return true


## $CFBA -- the hero laid over the thing.  A behaviour the table at $CFF1 marks
## is only tested on every other picture, and which picture depends on the slot
## as well, so the sixteen of them are spread over the two.
func touch(s: int) -> void:
	_lay(s)
	# Э5.4 -- and the other game's hero over the same thing, in the same
	# picture and in the same order, out of the same six numbers.  His box is
	# handed over rather than built, because $8A19 has no picture of his.
	var over: Array = []
	if guest != null and guest_box.size() == 5:
		over.append([guest, guest_box])
	for g in more_guests:
		over.append(g)
	if not over.is_empty():
		var was: SolPlayer = hero
		var was_box: Array = [hero_box_flags, hero_bx, hero_by,
				hero_bw, hero_bh]
		for g in over:
			var box: Array = g[1]
			hero = g[0]
			hero_box_flags = int(box[0])
			hero_bx = int(box[1])
			hero_by = int(box[2])
			hero_bw = int(box[3])
			hero_bh = int(box[4])
			_lay(s)
		hero = was
		hero_box_flags = int(was_box[0])
		hero_bx = int(was_box[1])
		hero_by = int(was_box[2])
		hero_bw = int(was_box[3])
		hero_bh = int(was_box[4])
	weapons_hit(s)                      # $CFE8
	# Э5.8 -- and what the guests are carrying, over the same thing and beside
	# this stage's own guns, because that is what they are.  It has to be here
	# and not below: $84B0 grows the thing's box in place and leaves it grown.
	arms_hit(s)
	hurt_slots(s)                       # $CFEB


## $CFBA -- the hero himself laid over the thing.
func _lay(s: int) -> void:
	# Three things keep the hero from being laid over the thing: a box of his
	# own that is nought ($CFC5), a behaviour the table marks on the wrong
	# picture ($CFD6), and no suit left ($CFDB).  None of the three reaches
	# past $CFE0: what he has already thrown is laid over it anyway.
	var lay: bool = hero != null and hero_box_flags != 0
	if lay and (hero_box_flags & 0x80) == 0 \
			and _hit_slow[mind[s] & 0x7F] != 0 \
			and ((s ^ clock) & 0x01) != 0:
		# $CFD2 -- and the roll that asked is what leaves the carry standing.
		z_c = 1
		lay = false
	if lay and hero.suit != 0:
		_overlap(s)                     # $CFDD


## $81B7 -- the two boxes laid over one another.  $9C and $9D say which way he
## came at it; what the touch then does is $8244.
func _overlap(s: int) -> void:
	z9c = 0
	z9d = 0
	var p: Array
	if _ge2(hero_bx, z61):
		# $81CB -- the far side of the thing, and one further along than it is
		# because the compare before this left its carry standing.
		p = _add2(z61, z65, 1)
		if _ge2(hero_bx, p[0]):
			# $81E1 -- the one way out of here that leaves the carry standing.
			z_c = 1
			return
	else:
		# $81E4 -- and one short of its near side, by the hero's own width.
		p = _sub2(z61, hero_bw, 0)
		if not _ge2(hero_bx, p[0]):
			z_c = 0                     # $81F8
			return
	if _ge2(hero_by, z63):
		p = _add2(z63, z67, 1)
		# $8210 -- the carry that add left is the borrow this takes with.
		p = _sub2(p[0], hero_by, p[1])
		if p[1] == 0:
			z_c = 0                     # $821A
			return
		z9c = 1
	else:
		p = _sub2(z63, hero_bh, 0)
		p = _sub2(hero_by, p[0], p[1])
		if p[1] == 0:
			z_c = 0                     # $8238
			return
		z9d = 1
	_react(s)


## $8244 -- what the touch comes to.  The top bit makes it something to pick
## up; without it the thing hurts, and how much depends on the suit.
##
## $821E and $823C are counts, which leave the carry alone, so everything from
## here on is entered with it standing.
func _react(s: int) -> void:
	if (z60 & 0x80) != 0:
		_pick_up(s)
		return
	var dmg: int
	if (z60 & 0x40) != 0:
		# $824A -- these hurt for one, and only where they name no other
		# amount at all.
		if (z60 & 0x0F) != 0:
			z_c = 1                     # $824E, and nothing has touched it
			return
		dmg = 1
	elif hero.hurt != 0 and (z60 & 0x20) != 0:
		dmg = 1                         # $8259 -- the suit takes one, no more
	else:
		dmg = z60 & 0x0F
	_hurt_hero(s, dmg)


## $833C -- the hero is touched by a thing.  In the suit he wears the thing
## down first, and only then does the blow itself land.
func _hurt_hero(s: int, dmg: int) -> void:
	if hero.hurt != 0:
		# $8343 -- a thing hit in the last eight pictures is not hit again.
		if cool[s] < 0x08:
			z_c = 0                     # $8348
			return
		_wear(s, 1)                     # $83BC
	blow(dmg)                           # $8354


## $8354 -- the blow itself, whatever threw it.  A shot that has reached the
## hero jumps straight in here ($88F0) with one.
func blow(dmg: int) -> void:
	if hero.hurt != 0:
		if hero.timer < 0x20:
			z_c = 0                     # $835E
			return
		# $8360 -- a step of the suit, and the low three bits back on.  The
		# compare above left the carry standing, so this is a plain take-away.
		var left: int = hero.hurt - 0x10
		hero.hurt = (left | 0x07) if left >= 0 else 0x02
		hero.timer = 0
		z_c = 1 if left >= 0 else 0     # $8363
		return
	# $8377 -- no suit, and then it costs him his own life.
	if hero.suit == 0:
		# $837A -- and nothing between $8244 and here has touched the carry.
		z_c = 1
		return
	if hero.timer < 0x70:
		z_c = 0                         # $8381
		return
	if hero.shield != 0:
		hero.shield -= 1                # $8388
	SolSound.want_noise = 0x0A          # $8394 -- $F1
	hero.timer = 0
	# $839D -- anything of eight or more takes one instead and puts him in the
	# water, which is how the deep places drown him.
	var d: int = dmg & 0x0F
	if d >= 0x08:
		d = 1
		hero.swim = 1
	z_c = 1 if hero.suit >= d else 0    # $83B0
	hero.suit = hero.suit - d if hero.suit >= d else 0


## $8866 -- what has been thrown at the hero, laid over him.  $CDCC asks this
## once a picture, before the shots have moved and before the pool is walked at
## all, and only while the hero is old enough to be hurt ($05A3 >= $70).  The
## first slot that reaches him ends the walk, so no more than one shot lands.
func shots_hit_hero() -> void:
	_shots_hit_current_hero()
	# Guests use the same $8866 sweep and consume the same projectiles.
	# As with touch(), preserve the native hero and his box after each sweep.
	var over: Array = more_guests.duplicate()
	if guest != null and guest_box.size() == 5:
		over.push_front([guest, guest_box])
	if over.is_empty():
		return
	var was: SolPlayer = hero
	var box_before: Array = [hero_box_flags, hero_bx, hero_by, hero_bw, hero_bh]
	for g in over:
		var box: Array = g[1]
		hero = g[0]
		hero_box_flags = int(box[0])
		hero_bx = int(box[1])
		hero_by = int(box[2])
		hero_bw = int(box[3])
		hero_bh = int(box[4])
		_shots_hit_current_hero()
	hero = was
	hero_box_flags = int(box_before[0])
	hero_bx = int(box_before[1])
	hero_by = int(box_before[2])
	hero_bw = int(box_before[3])
	hero_bh = int(box_before[4])


func _shots_hit_current_hero() -> void:
	if hero == null or hero_box_flags == 0 or hero.timer < 0x70:
		return
	# $CDC8's compare is the last thing to touch the carry before the walk,
	# and it left it standing.
	var c := 1
	for i in range(SHOTS - 1, -1, -1):
		if (s_kind[i] & 0x80) == 0:
			continue                    # $886B
		var r: Array = _shot_on_hero(i, c)
		c = int(r[1])
		if not bool(r[0]):
			continue
		# $8876 -- it has given what it had, and stops flying.
		if s_life[i] <= 1:
			s_kind[i] = s_kind[i] & 0x7F
			s_a[i] = 0
			s_life[i] = 0
		else:
			s_life[i] -= 1
		# $8890 -- and a hero already hurt is heard again for it.
		if hero.hurt != 0:
			SolSound.want_noise = 0x33  # $8895 -- $F1
		return


## $889F -- one shot laid over the hero's box.  The shot is a point: only the
## hero's own width and height are asked about.  Every compare here is a
## subtraction that takes the carry the one before it left, so the box reads
## one further along and one further down than its numbers say.
func _shot_on_hero(i: int, c: int) -> Array:
	var r: Array = _sub2(s_x[i], hero_bx, c)
	if r[1] == 0:
		return [false, r[1]]            # $88A9
	var p: Array = _add2(hero_bx, hero_bw, r[1])
	r = _sub2(s_x[i], p[0], p[1])
	if r[1] == 1:
		return [false, r[1]]            # $88C1
	r = _sub2(s_y[i], hero_by, r[1])
	if r[1] == 0:
		return [false, r[1]]            # $88CD
	p = _add2(hero_by, hero_bh, r[1])
	r = _sub2(p[0], s_y[i], p[1])
	if r[1] == 0:
		return [false, r[1]]            # $88E5
	if hero.suit == 0:
		return [false, r[1]]            # $88EA
	blow(1)                             # $88F0 -> $8354
	return [true, r[1]]


## $88F6 and $8918 -- the same pool, laid over one of the hero's own four slots
## instead of over him.  $A51E asks this for each of the four once a picture,
## so the satellite, its bang, the swung weapon and his punch can all be shot
## out of the air.
##
## The box is not the picture's.  It is a square $0101 across reaching from
## $80 back of the slot's own point, built by hand at $88F6, so a shot within
## about half a screen of the satellite counts as touching it.
##
## The carry standing when the box is built is whatever the slot's own
## behaviour left: $A516 to $A51E and the bank change under it touch nothing,
## so it walks straight in from $A56A.  Measured on the stand it is clear, and
## a clear one reaches one sixteenth further back -- the near edge is at $81
## and not $80.  The borrow the sideways pair leaves then runs on into the
## other, which is one subtraction of four bytes and not two of two.
func shots_hit_thing(s: int) -> void:
	var r: Array = _sub2(x[s], 0x0080, 0)
	var bx: int = r[0]
	r = _sub2(y[s], 0x0080, r[1])
	var by: int = r[0]
	var c: int = r[1]
	for i in range(SHOTS - 1, -1, -1):
		if (s_kind[i] & 0x80) == 0:
			continue                        # $891D
		# $8924 -- three noughts and then the code itself, the same trick as
		# $CFF1, so all but the first three behaviours are asked about every
		# other picture -- and which one depends on the shot's own slot.
		if _hand_slow[s_kind[i] & 0x7F] != 0:
			if ((i ^ clock) & 0x01) != 0:
				continue
			# $8930 -- and the roll that asks the question is itself what
			# leaves the carry for the compares below.  Getting here at all
			# means it came out clear, so the box reads one sixteenth further
			# back than it does for a shot that skipped the question.
			c = 0
		var hit: Array = _shot_on_thing(s, i, bx, by, c)
		c = int(hit[1])
		if not bool(hit[0]):
			continue
		# $893C -- it has given what it had, and stops flying.
		if s_life[i] <= 1:
			s_kind[i] = s_kind[i] & 0x7F
			s_a[i] = 0
			s_life[i] = 0
		else:
			s_life[i] -= 1
		return


## $895F -- one shot laid over that square, and what it costs the slot.  The
## compares thread their carry the way $889F's do.
##
## Two of its answers are worth naming.  A slot already on its way out (bit 7
## of its behaviour) swallows the shot and loses nothing; and a slot whose
## last point of life is taken while it is not the satellite answers nought,
## so the shot that finished it goes on flying.
func _shot_on_thing(s: int, i: int, bx: int, by: int, c: int) -> Array:
	var r: Array = _sub2(s_x[i], bx, c)
	if r[1] == 0:
		return [false, r[1]]                # $8969
	var p: Array = _add2(bx, 0x0101, r[1])
	r = _sub2(s_x[i], p[0], p[1])
	if r[1] == 1:
		return [false, r[1]]                # $8981
	r = _sub2(s_y[i], by, r[1])
	if r[1] == 0:
		return [false, r[1]]                # $898D
	p = _add2(by, 0x0101, r[1])
	r = _sub2(p[0], s_y[i], p[1])
	if r[1] == 0:
		return [false, r[1]]                # $89A5
	if (mind[s] & 0x80) != 0:
		return [true, r[1]]                 # $8A13
	# $89AC -- and a picture that carries no meaning at all is not touched.
	var pic: int = pic_lo[s] | pic_hi[s] << 8
	if _hit_of(pic)[0] == 0:
		return [false, r[1]]                # $89CB
	cool[s] = 0                             # $89CF
	if life[s] >= 1:
		life[s] -= 1                        # $89F6
		# $89FD -- the satellite is the only one that makes a sound of it.
		if s == SolSat.FIRST:
			SolSound.want_noise = 0x33      # $89FD -- $F1
		return [true if s == SolSat.FIRST else life[s] != 0, r[1]]
	# $89DC -- it had nothing left, and this is the end of it.
	a[s] = 0
	if s == SolSat.FIRST:
		b[s] = 0x20                         # $89E5
		SolSound.want_noise = 0x0A          # $89EA -- $F1
		id[s] = 0xFF                        # $89EE
	else:
		id[s] = 0                           # $89F0
	return [true, r[1]]


## $869C -- the hero's own eight weapon slots, the pool at $0700, laid over
## the thing whose turn it is.  $CFE8 asks this once the thing's box is built
## and the hero himself has been laid over it, and only where the box says the
## thing can be hurt at all.
##
## Which slots are asked, and in what order, is the satellite's business: its
## behaviour number reads $8759.  Nought asks all eight from the top down,
## seven five three one and then six four two nought; one asks half of them,
## and $0C -- the plain count of pictures -- picks which half; two and up asks
## a third set that begins five four one and then runs into the other half.
##
## That last one is the cartridge's own slip and is kept as it stands.  $86D2
## loads nought into the index and then branches on "not nought", which can
## never be taken, so it falls into $86D6 instead of testing slot nought: the
## seven that follow are asked and slot nought never is.
##
## Every chosen slot is asked whatever the ones before it answered -- $8726 is
## called and its answer thrown away -- so one shot stopping does not save the
## thing from the next.
func weapons_hit(s: int) -> void:
	# $CFE4 -- the caller's own gate, and then $869C's two.
	if (z60 & 0x80) != 0 or (z60 & 0x3F) == 0:
		return
	if (z60 & 0x20) != 0:
		return                          # $86A0
	if (mind[s] & 0x80) != 0:
		return                          # $86A4 -- it is already finished
	if id[SAT] == 0:
		return                          # $86A9 -- and he has no satellite
	var order: Array
	var c: int = z_c
	var which: int = _slot_order[mind[SAT] & 0x7F]
	if which == 0:
		order = [7, 5, 3, 1, 6, 4, 2, 0]                # $8701
	else:
		# $86BE and $86E9 -- the roll that asks which picture it is is also
		# what the compares below subtract with, so for these two rows the
		# carry walking into $876D is the bottom bit of the picture count and
		# not the one $CFBA walked in with.
		c = clock & 0x01
		if which == 1:
			# $86E9 -- one picture the odd four, the next the even four.
			order = [6, 4, 2, 0] if c != 0 else [7, 5, 3, 1]
		else:
			# $86BE, and the slip at $86D4 below it.
			order = [7, 6, 3, 2] if c != 0 else [5, 4, 1, 7, 6, 3, 2]
	for i in order:
		c = _weapon_slot(s, int(i), c)


## Э5.8 -- a guest's weapons laid over the same thing.  $869C's own three
## gates, $876D's box and $87BC's wear; what differs is only that the place,
## the reach and the strength come as numbers, because a guest's weapon has no
## picture this stage can read.
##
## The carry is not threaded through it.  There is no cartridge that ever did
## this, so there is nothing to be faithful to, and the stage's own guns keep
## their exact road untouched.
func arms_hit(s: int) -> void:
	if guest_arms.is_empty():
		return
	if (z60 & 0x80) != 0 or (z60 & 0x3F) == 0:
		return                          # $869C -- picked up, or hurts for none
	if (z60 & 0x20) != 0:
		return                          # $86A0
	if (mind[s] & 0x80) != 0:
		return                          # $86A4 -- it is already finished
	var n: int = z60 & 0x0F
	for g in guest_arms:
		var arms: Array = g[0]
		var spend: Callable = g[1]
		for j in range(arms.size()):
			var a: Array = arms[j]
			if a.size() != 4:
				continue
			if not _arm_on_thing(s, int(a[0]), int(a[1]), int(a[2])):
				continue
			# $87BA -- a thing hit in the last nine pictures is touched but
			# not hurt, and the shot is spent on it all the same.
			if cool[s] >= 0x09:
				_wear(s, int(a[3]))     # $87BC, which is $83BC written out
			if spend.is_valid():
				spend.call(j, n)
			if (mind[s] & 0x80) != 0:
				return


## $876D with the shot's numbers handed in: the shot is a point, grown by what
## it reaches, and the thing is the box.
func _arm_on_thing(s: int, ax: int, ay: int, reach: int) -> bool:
	var lo_x: int = (z61 - reach) & 0xFFFF
	var lo_y: int = (z63 - reach) & 0xFFFF
	var w: int = z65 + reach * 2
	var h: int = z67 + reach * 2
	if ((ax - lo_x) & 0xFFFF) > w:
		return false
	if ((ay - lo_y) & 0xFFFF) > h:
		return false
	return true


## $8726 -- one weapon slot laid over the thing, and what the touch costs the
## shot.  A shot goes through as much as $0770 says it can and no further; what
## the thing takes off it is the low four bits of the box's own meaning, so a
## thing that hurts for four also stops four of a shot's worth.
func _weapon_slot(s: int, i: int, c: int) -> int:
	if (w_kind[i] & 0x80) == 0:
		return c                        # $8729 -- nothing flying in that slot
	var r: Array = _weapon_on_thing(s, i, c)
	if not bool(r[0]):
		return int(r[1])
	# $8731 -- and here the carry is thrown away and made afresh.
	var n: int = z60 & 0x0F
	var left: int = w_pen[i] - n
	if left <= 0:
		# $8741 -- it has gone through as much as it could and stops flying.
		w_kind[i] = w_kind[i] & 0x7F
		w_vx[i] = 0
		w_pen[i] = 0
	else:
		w_pen[i] = left                 # $8750
	return 1 if left >= 0 else 0


## $876D -- the shot is a point and the thing is the box; the six compares
## thread their carry the way $81B7's do.
##
## A thing hit in the last nine pictures is touched but not hurt -- $06E0
## counts up from the last blow -- and the shot is spent on it all the same.
func _weapon_on_thing(s: int, i: int, c: int) -> Array:
	var r: Array = _sub2(w_x[i], z61, c)
	if r[1] == 0:
		return [false, r[1]]            # $8777
	var p: Array = _add2(z61, z65, r[1])
	r = _sub2(w_x[i], p[0], p[1])
	if r[1] == 1:
		return [false, r[1]]            # $878F
	r = _sub2(w_y[i], z63, r[1])
	if r[1] == 0:
		return [false, r[1]]            # $879B
	p = _add2(z63, z67, r[1])
	r = _sub2(p[0], w_y[i], p[1])
	if r[1] == 0:
		return [false, r[1]]            # $87B3
	if cool[s] < 0x09:
		# $87BA -- and the compare that said so is what the carry is left at.
		return [true, 0]
	_wear(s, 1)                         # $87BC, which is $83BC written out
	_87f2(s)                            # $87D9
	# The carry $87F2 leaves is thrown away at $8731 either way.
	return [true, 1]


## $87F2 -- the noise a thing makes when it is struck.
##
## The behaviour picks the byte out of $880A; nought means it makes none.  A
## $2E already standing in $F1 is left where it is, so whatever wrote that
## this picture is not shouted down.
func _87f2(s: int) -> void:
	if SolSound.want_noise == 0x2E:         # $87F6
		return
	var v: int = _noise[mind[s] & 0x3F]     # $87FA, $8800
	if v != 0:                              # $8803
		SolSound.want_noise = v             # $8805


## $83E2 -- the hero's own four slots $0C..$0F laid over the thing.  $CFEB asks
## this last of all, after his body ($81B7) and his eight shots ($869C).
##
## The box the four are asked about is not the thing's own.  $84B0 pulls its
## origin back eight pixels each way and adds sixteen to both sides -- and it is
## asked *twice*: once before the punch and the satellite, and again before
## slots thirteen and fourteen, which therefore see a box sixteen pixels wider
## and taller still.  The growth is written back onto $65 and $67 themselves and
## stands until the next picture builds them afresh.
##
## Each of the four has to be there ($0600), and to have been left alone for at
## least twelve pictures ($06E0, its own count since it was last hit, which
## $A502 walks up), before it is asked at all.  The punch
## is asked first and is the only one a thing to pick up can reach; the other
## three are skipped outright while the hero is still smarting ($05C2).
func hurt_slots(s: int) -> void:
	# $83E4 -- something to pick up goes on whatever its low bits say; anything
	# else has to hurt for something or there is nothing to do.
	if (z60 & 0x80) == 0 and (z60 & 0x0F) == 0:
		return                          # $83EA
	var c: int = _grow_box(z_c)         # $83EC
	var r: Array
	if id[0x0F] != 0:
		var ge: bool = cool[0x0F] >= 0x0C
		c = 1 if ge else 0              # $83F7 -- a CMP, so it settles it
		if ge and (z60 & 0x20) == 0:
			# $8401 -- a thing that hurts for one whatever it says is never
			# laid over the punch.
			r = _slot_on_thing(s, 0x0F, c)
			c = int(r[1])
			if int(r[0]) != 0:
				_slot_took(s, 0x0F)     # $8406
				return
	# $8408 -- and the other three are his only while he is on his feet.
	if hero_hurt != 0 or (z60 & 0x80) != 0:
		return
	if id[SAT] != 0:
		var ge2: bool = cool[SAT] >= 0x0C
		c = 1 if ge2 else 0             # $8419
		if ge2:
			r = _slot_on_thing(s, SAT, c)
			c = int(r[1])
			if int(r[0]) != 0:
				_slot_took(s, SAT)      # $8422
				return
	c = _grow_box(c)                    # $8424 -- and grown a second time
	for i in [0x0D, 0x0E]:
		if id[i] == 0:
			continue                    # $8427, $843A
		var ge3: bool = cool[i] >= 0x0C
		c = 1 if ge3 else 0             # $842F, $8442
		if not ge3:
			continue
		r = _slot_on_thing(s, i, c)
		c = int(r[1])
		if int(r[0]) != 0:
			_slot_took(s, i)            # $8438, $844B
			return


## $84B0 -- the thing's box grown in place.  The origin is taken away with
## whatever carry walked in, which is why it is worth threading; the two sizes
## are grown by a plain INC on their high halves, so by $0100 a time and with
## no carry of their own.
func _grow_box(c: int) -> int:
	var r: Array = _sub2(z61, 0x0080, c)
	zg_x = int(r[0])
	r = _sub2(z63, 0x0080, int(r[1]))
	zg_y = int(r[0])
	z65 = (z65 & 0xFF) | ((((z65 >> 8) + 1) & 0xFF) << 8)
	z67 = (z67 & 0xFF) | ((((z67 >> 8) + 1) & 0xFF) << 8)
	return int(r[1])


## $84CD -- one of the four laid over the grown box.  Unlike the shots, all four
## compares are CMPs, so only the last one -- the far edge along the ground --
## carries anything in from the add above it.
##
## It answers nought for a miss, and the carry it leaves is read again by the
## second $84B0, which is why the misses give theirs back.
func _slot_on_thing(s: int, i: int, c: int) -> Array:
	zg9b = 0                            # $84CD
	var r: Array = _sub2(x[i], zg_x, 1)
	if r[1] == 0:
		return [0, r[1]]                # $84DB
	var p: Array = _add2(zg_x, z65, r[1])
	r = _sub2(x[i], p[0], 1)            # $84E9
	if r[1] == 1:
		return [0, r[1]]                # $84F3
	r = _sub2(y[i], zg_y, 1)            # $84F5
	if r[1] == 0:
		return [0, r[1]]                # $84FF
	# $8501 -- three edges passed, and the slot is marked as having got that
	# far whether or not the fourth lets it through.
	zg9b = 0xFF
	p = _add2(zg_y, z67, r[1])
	r = _sub2(p[0], y[i], p[1])         # $850F
	if r[1] == 0:
		return [0, r[1]]                # $851B
	return _slot_touched(s, i, int(r[1]))


## $853B -- the four boxes met, and what that means.
func _slot_touched(s: int, i: int, c: int) -> Array:
	if (z60 & 0x80) != 0:
		return _slot_pick_up(s, i)      # $851E
	if (z60 & 0x40) != 0:
		# $8541 -- a thing that only hurts a hero out of his suit.
		if (z60 & 0x0F) == 0:
			return [0xFF, c]            # $8547
		_slot_mark(i)                   # $854A
		var ge: bool = mind[i] >= 0x0A
		c = 1 if ge else 0              # $8550
		if not ge:
			return [0, c]               # $8556
	if (z60 & 0x20) != 0:
		return [0xFF, c]                # $855B
	_slot_mark(i)                       # $855D
	if cool[s] < 0x08:
		# $8563 -- hit in the last eight pictures, so touched but not hurt.
		return [0xFF, 0]
	return _slot_blow(s, i, 1)          # $8567


## $849E -- the slot is marked as having touched something: bit seven always,
## and bit six as well when the box was passed far enough for $8501 to run.
func _slot_mark(i: int) -> void:
	id[i] = (id[i] | (zg9b & 0x40) | 0x80) & 0xFF


## $851E -- a thing to pick up met one of the four.  What it does is the low
## four bits of its own meaning read as an index into the little table of
## addresses at $852C, which $8025 -- the jump the cartridge keeps at the foot
## of bank eight -- reaches by pulling its own return address off the stack.
##
## A slot whose behaviour is below ten cannot pick anything up, and the answer
## it gives back is that behaviour itself, not nought, so anything from one to
## nine still counts as a touch.
func _slot_pick_up(s: int, i: int) -> Array:
	var ge: bool = mind[i] >= 0x0A
	if not ge:
		return [mind[i], 0]             # $8523 -> $853A, the RTS below the table
	# $8027 -- and the ASL that indexes the table is what clears the carry.
	match z60 & 0x0F:
		0x00:
			return [0, 0]               # $853A again
		0x03:
			kind[s] = 0x02              # $82AE
			return [0x02, 0]
		0x04:
			_puff(s, i)                 # $85EF
			return [0xFF, 0]
		0x05:
			mind[s] = 0x09              # $85F8
			return _slot_blow(s, i, 0)
		0x06:
			mind[s] = 0x08              # $85FC
			return _slot_blow(s, i, 0)
	# $85F5 -- one and two, and everything above six, which the table does not
	# reach at all.
	return [0, 0]


## $8567 -- the slot hurts the thing.  How much for is the first byte of its
## own picture's pair in $8A19, the same table the boxes themselves come from,
## so a picture that means nothing takes nothing off.
func _slot_blow(s: int, i: int, c: int) -> Array:
	var pic: int = pic_lo[i] | pic_hi[i] << 8
	var n: int = _hit_of(pic)[0]
	if n == 0:
		# $8586 -- and the carry is the one the address sum left, which for
		# every picture the game really has is clear.
		return [0, _pic_sum_carry(pic)]
	if i == 0x0F and hero_shield != 0 and hero_hurt == 0:
		n = (n << 1) & 0xFF             # $8598 -- the punch counts double
	cool[s] = 0                         # $859A
	mind[s] = mind[s] & 0xBF            # $859F -- and this one puts bit six out
	var leftv: int = life[s] - n        # $85A7
	if leftv <= 0:
		_done(s)                        # $85B4
		leftv = 0
	life[s] = leftv                     # $85B9
	# $85BC -- every slot but the hero's own goes straight to the noise; his
	# is shoved first, and is heard only where the shove came out at nought.
	if i == 0x0F:
		if hero == null or hero.ground != SolPlayer.GROUND_ICE:
			return [0xFF, c]            # $85C5
		# $85C0 -- on ice a punch shoves him, and by twice as much when it is
		# worth two.  The ASL that asks which way he faces is also the carry
		# the sum below adds in, so the shove towards the left is one bigger.
		var step: int = 0xF0 if n >= 0x02 else 0xF8
		var k := 0
		if (hero_face & 0x80) != 0:
			step = 0x10 if n >= 0x02 else 0x08
			k = 1
		var v: int = (hero.speed + step + k) & 0xFF
		hero.speed = v - 0x100 if v >= 0x80 else v
		if v != 0:
			return [0xFF, c]            # $85E7
	_87f2(s)                            # $85E9
	return [0xFF, c]


## $8578 -- the carry the sum "$8A19 plus twice the picture" leaves.  Nothing
## reads the sum itself here; only $85F5 gives the carry back.
func _pic_sum_carry(pic: int) -> int:
	var sh: int = (pic << 1) & 0xFFFF
	var lo: int = (sh & 0xFF) + 0x19 + ((pic >> 15) & 1)
	var hi: int = ((sh >> 8) & 0xFF) + 0x8A + ((lo >> 8) & 1)
	return (hi >> 8) & 1


## $844E -- the slot that touched the thing, and what the touch costs it.  How
## much it loses is the low four bits of the thing's meaning, but anything from
## eight up costs one and no more.
func _slot_took(s: int, i: int) -> void:
	if z60 == 0:
		return                          # $8450
	if (z60 & 0x80) != 0:
		# $8495 -- a thing to pick up is only ever marked on the punch.
		if i == 0x0F:
			cool[i] = 0
			_slot_mark(i)
		return
	cool[i] = 0                         # $8456
	# $8459 -- the hero's own slot alone, and only where nothing has asked for
	# a noise already this picture.
	if i == 0x0C and SolSound.want_noise == 0:
		SolSound.want_noise = 0x33      # $8461 -- $F1
	var n: int = z60 & 0x0F
	if n >= 0x08:
		n = 0x01                        # $846D
	var leftv: int = life[i] - n        # $8471
	if leftv > 0:
		life[i] = leftv                 # $8491
		return
	a[i] = 0                            # $847B
	if i == SAT:
		b[i] = 0x20                     # $8484
		id[i] = 0xFF
	else:
		id[i] = 0                       # $848B


## $8604 -- a thing picked up by the fourth kind leaves a puff behind: the
## topmost free slot of the twelve takes the *thing's* own place, a behaviour of
## ten and a life of ten, and the thing itself is turned round.
func _puff(s: int, i: int) -> void:
	var j := 11
	while j >= 0 and id[j] != 0:
		j -= 1                          # $860D
	if j < 0:
		return                          # $8610
	anim_a[j] = 0
	anim_b[j] = 0
	left[j] = 0
	frame[j] = 0
	pic_lo[j] = 0
	pic_hi[j] = 0
	mind[j] = 0x0A                      # $8625
	life[j] = 0x0A
	kind[j] = 0x20                      # $862D
	x[j] = x[s]                         # $8632, read with the thing's own index
	y[j] = y[s]
	cool[j] = 0x80                      # $8646
	id[j] = 0x80
	face[s] = face[s] ^ 0xFF            # $864E -- and the thing looks the other way
	c[j] = 0xB0                         # $8656
	d[j] = 0xFF
	b[j] = 0xFF                         # $8660
	SolSound.want_noise = 0x0D          # $8663 -- $F1
	a[j] = 0x01                         # $8667
	# $866C -- and where the slot's own picture is worth two or more, the puff
	# is thrown the other way instead.
	if _hit_of(pic_lo[i] | pic_hi[i] << 8)[0] >= 0x02:
		a[j] = 0x02                     # $868F
		c[j] = 0xC0


## $83BC -- the thing loses what the hero's own body took off it.
func _wear(s: int, n: int) -> void:
	cool[s] = 0
	mind[s] = mind[s] | 0x40
	if life[s] > n:
		life[s] -= n
		return
	life[s] = 0
	_done(s)                            # $8850


## $8850 -- the thing is finished off: its walk is thrown away with it.
func _done(s: int) -> void:
	if (mind[s] & 0x80) != 0:
		return
	mind[s] = mind[s] | 0x80
	left[s] = 0
	frame[s] = 0
	a[s] = 0


## $8266 -- something to pick up.  The low three bits say which of the six, and
## nought means it is not one after all.
func _pick_up(s: int) -> void:
	# Four of the six end by putting the thing away ($8290 sets bit seven of
	# its behaviour), and $869C turns round at $86A4 on that, so what the carry
	# is left at matters only for $82AE, $82B4 and $8336 -- and none of the
	# three touches it.
	z_c = 1
	match z60 & 0x07:
		0x01: _worth(s, 0x05)           # $827E
		0x02: _worth(s, 0x14)           # $8299
		0x03: kind[s] = 0x02            # $82AE
		0x04: pass                      # $82B4 -- nothing at all
		0x05: _suit(s, 0x01, 0x04, 0x10)    # $82B5
		0x06: _suit(s, 0x02, 0x08, 0x20)    # $82F3


## $827E and $8299 -- the two that are only worth points.
func _worth(s: int, n: int) -> void:
	SolSound.want_noise = 0x0F          # $827E/$8299 -- $F1
	hero_bonus = (hero_bonus + n) & 0xFFFF
	mind[s] = mind[s] | 0x80            # $8290


## $82B5 and $82F3 -- one letter picked up.  $05C4 holds three pairs of bits,
## a pair to a letter, and the pick-up belongs to the first pair still empty;
## when all three are full the slot is simply let go instead.
func _suit(s: int, one: int, two: int, three: int) -> void:
	var bit := one
	var which := 0
	if (letters & 0x03) != 0:
		which = 1
		bit = two
		if (letters & 0x0C) != 0:
			which = 2
			bit = three
			if (letters & 0x30) != 0:
				id[s] = 0               # $8336
				return
	SolSound.want_noise = 0x10          # $82DA/$8318 -- $F1
	b[s] = letters | bit             # $82DE
	if which != 2:
		w_kind[0x0C + which] = int(sat_table["letter_blink"][0]) # $82EB/$8329
	a[s] = 0xFF                         # $832E
	mind[s] = mind[s] | 0x80


# ---------------------------------------------------------------------------
# Angles.  $8FF6 in bank twelve, reached through $C078, is the one place in the
# game where a direction becomes a step.


## $8FF6 -- the step for an angle.  `ring` is what $90 held on the way in: the
## sixteen-byte ring to read, which is how far the step reaches.
func aim(ang: int, ring: int) -> Array:
	var k: int = ((ang & 0x0F) + ring) & 0xFF
	var one: int = _aim[k] if k < _aim.size() else 0
	var two := 0
	if (k & 0x0F) != 0:
		var j: int = ((k - 1) & 0xFF) ^ 0x0F
		two = _aim[j] if j < _aim.size() else 0
	var dx: int
	var dy: int
	if (ang & 0x10) == 0:
		dx = one                        # $9005
		dy = two
	else:
		dy = one                        # $901C
		dx = two
	match ang & 0x30:
		0x10:
			dx = (-dx) & 0xFFFF         # $9054
		0x20:
			dx = (-dx) & 0xFFFF
			dy = (-dy) & 0xFFFF
		0x30:
			dy = (-dy) & 0xFFFF         # $9048
	return [dx, dy]
