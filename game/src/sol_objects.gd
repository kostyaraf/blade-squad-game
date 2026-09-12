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
var z26 := 0                        # $26 -- what the screen is still owed
var push := 0                       # $05A8:$05A9 -- what a belt does to the hero
var wants := 0                      # $05F7 -- what an object asks the hero for
var score := 0                      # $05FD..$05FF
var cam_x := 0                      # $30:$31
var cam_y := 0                      # $32:$33
var hero_vx := 0                    # $05B6:$05B7
var hero_face := 0                  # $05B2 -- bit 7 set means he looks left
var z34 := 0                        # $34 -- how fast a carrying map drags down
var z75 := 0                        # $75 -- the height a lift keeps for the rest
var z58 := 0                        # $58 -- how many are still on the ride
var hero_suit := 0                  # $05C5 -- which suit is on
var hero_flags := 0                 # $05CB
var hero_state := 0                 # $05A2 -- what the hero is busy with
var hero_timer := 0                 # $05A3 -- how long the state has left
var hero_pic_lo := 0                # $05A6 -- the picture he is drawn from
var hero_pic_hi := 0                # $05A7
var hero_fuel := 0                  # $05AF -- what the wire has left
var z5ab := 0                       # $05AB -- the burst of the doubled weapon
var hero_hurt := 0                  # $05C2 -- frames of being left alone
var hero_shield := 0                # $05C8
var z5fa := 0                       # $05FA -- set while the stage is ending
var pad_new := 0                    # $04 -- what was pressed this picture
## The Y register as the animation walk leaves it.  $C051 saves Y in $90
## before it swaps banks and so destroys what the caller put there; $A802 is
## the one place that notices.
var y_reg := 0
var stage := 0                      # $55 -- which stage is up
var zf8 := 0                        # $F8 -- what the game is to be put to next
var map_kind := 0                   # $70 -- $3C is the stage that is all water
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
## $60..$68 -- and the box of the thing whose turn it is.
var z60 := 0                        # $60, what touching it means
var z61 := 0                        # $61:$62
var z63 := 0                        # $63:$64
var z65 := 0                        # $65:$66
var z67 := 0                        # $67:$68
var z9c := 0                        # $9C, which side the overlap came from
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
var skipped := {}                   # which behaviours have not been read yet

var _types: Array
var _anims: Array
var _anims3: Array
var _anims1: Array
var _hatch: PackedByteArray
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
## $9060 -- fifteen rings of sixteen, the quarter circle $8FF6 turns an angle
## into a step with.
var _aim: PackedByteArray
## $AEBD's twenty two rows: which slot to try first, how much it goes
## through, its two speeds and its four sets of starting offsets.
var weapon_table: Dictionary
## $A5C1, $AE5F, $ADEF and the rest: what the hero's own four slots are
## driven by.
var sat_table: Dictionary


func _init(lvl: SolLevel) -> void:
	level = lvl
	var t: Dictionary = Nes._load_json("%s/sol/objects.json" % Nes.DATA)
	_types = t["types"]
	_anims = t["anims"]
	_anims3 = t["anims3"]
	_anims1 = t["anims1"]
	_hatch = PackedByteArray(t["hatch"])
	_steps = PackedByteArray(t["steps"])
	_arctan = PackedByteArray(t["arctan"])
	var h: Dictionary = Nes._load_json("%s/sol/hits.json" % Nes.DATA)
	_hit_pic = h["pic"]
	_hit_box = h["box"]
	_hit_slow = PackedByteArray(h["slow"])
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


## $BDAB -- the second one, which has no such tail.
func anim_second(s: int, n: int, set := 4) -> void:
	if anim_b[s] != n:
		anim_b[s] = n
		frame[s] = 0
		left[s] = 0
	_tick(s, anim_b[s], set)


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
func hatch(px: int, py: int, tpl: int) -> int:
	var f := -1
	for i in range(0x0B, -1, -1):
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
	z50 = n
	if (a[s] & 0x80) != 0:
		carry = 1
		var lo: int = _sbc(0, z50 & 0xFF)
		var hi: int = _sbc(0, (z50 >> 8) & 0xFF)
		z50 = lo | hi << 8
	var px: int = (x[s] - 0x0080) if (a[s] & 0x80) != 0 else (x[s] + 0x0080)
	if map_kind == 0x3C:
		return 0
	px += hero_vx                       # $D010
	z9d = px & 0xFF
	var r: int = probe(px, y[s] + 0x0040)
	if r >= 0x80:
		kind[s] = kind[s] | 0x80
		z50 = 0
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
	return angle_between(x[s], y[s], tx, ty)


## $8E44 itself, over two places neither of which need be a slot.
func angle_between(px: int, py: int, tx: int, ty: int) -> int:
	var p := PackedInt32Array([px & 0xFF, (px >> 8) & 0xFF,
			py & 0xFF, (py >> 8) & 0xFF])
	carry = 1
	var ax: int = _sbc(p[0], tx & 0xFF)
	var bx: int = _sbc(p[1], (tx >> 8) & 0xFF)
	var turn := 0
	if carry == 0:
		var t: int = _neg16(ax | bx << 8)
		ax = t & 0xFF
		bx = (t >> 8) & 0xFF
		turn = 2
	carry = 1
	var ay: int = _sbc(p[2], ty & 0xFF)
	var by: int = _sbc(p[3], (ty >> 8) & 0xFF)
	if carry == 0:
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
	var px: int = (x[s] + ox) if (face[s] & 0x80) != 0 else (x[s] - ox)
	var py: int = y[s] + oy
	z9d = py & 0xFF                     # $D08F
	return probe(px, py)


## $B151 -- and what is above it, at a given height.
func probe_above(s: int, oy: int) -> int:
	var py: int = y[s] - oy
	z9d = py & 0xFF
	return probe(x[s], py)


## $B170 -- what lies ahead, looked at only every other picture, and offset by
## the hero's own speed ($D010).  Answers nothing on the picture it sits out.
func probe_ahead(s: int, ox: int, oy: int) -> int:
	if ((s ^ clock) & 1) == 0:
		return 0
	if map_kind == 0x3C:
		return map_kind                 # $D014 -- the carrying map says nothing
	var px: int = (x[s] - ox) if (face[s] & 0x80) != 0 else (x[s] + ox)
	px += hero_vx                       # $D018
	z9d = px & 0xFF
	return probe(px, y[s] + oy)


## $B186 + $D032 -- what lies ahead of the slot's own facing, every picture and
## without the hero's speed in it.  The leftover here is the low byte of the
## height looked at, not of the place along.
func probe_at(s: int, ox: int, oy: int) -> int:
	var px: int = (x[s] - ox) if (face[s] & 0x80) != 0 else (x[s] + ox)
	return probe_point(px, y[s] + oy)


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
		_sbc(py & 0xFF, sl)
		var d: int = _sbc((py >> 8) & 0xFF, sh)
		if carry != 0 and d == 0:
			z9d = 0
			return 0x80
	z9d = py & 0xFF                     # $D08F
	return probe(px, py)


## $B179 -- the same look ahead as $B170, but taken every picture.
func probe_fwd(s: int, ox: int, oy: int) -> int:
	if map_kind == 0x3C:
		return map_kind
	var px: int = (x[s] - ox) if (face[s] & 0x80) != 0 else (x[s] + ox)
	px += hero_vx
	z9d = px & 0xFF
	return probe(px, y[s] + oy)


func _neg16(v: int) -> int:
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
	z63 = _add2(int(box[1]), y[s], r[1])[0]
	z65 = int(box[2])
	z67 = int(box[3])
	return true


## $CFBA -- the hero laid over the thing.  A behaviour the table at $CFF1 marks
## is only tested on every other picture, and which picture depends on the slot
## as well, so the sixteen of them are spread over the two.
func touch(s: int) -> void:
	if hero == null or hero_box_flags == 0:
		return
	if (hero_box_flags & 0x80) == 0 and _hit_slow[mind[s] & 0x7F] != 0 \
			and ((s ^ clock) & 0x01) != 0:
		return
	if hero.suit == 0:
		return
	_overlap(s)
	# $CFE8 and $CFEB -- the hero's own shots against the thing ($869C) and
	# what his sub-weapons do ($83E2).  Neither pool is ported yet.


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
			return
	else:
		# $81E4 -- and one short of its near side, by the hero's own width.
		p = _sub2(z61, hero_bw, 0)
		if not _ge2(hero_bx, p[0]):
			return
	if _ge2(hero_by, z63):
		p = _add2(z63, z67, 1)
		# $8210 -- the carry that add left is the borrow this takes with.
		p = _sub2(p[0], hero_by, p[1])
		if p[1] == 0:
			return
		z9c = 1
	else:
		p = _sub2(z63, hero_bh, 0)
		p = _sub2(hero_by, p[0], p[1])
		if p[1] == 0:
			return
		z9d = 1
	_react(s)


## $8244 -- what the touch comes to.  The top bit makes it something to pick
## up; without it the thing hurts, and how much depends on the suit.
func _react(s: int) -> void:
	if (z60 & 0x80) != 0:
		_pick_up(s)
		return
	var dmg: int
	if (z60 & 0x40) != 0:
		# $824A -- these hurt for one, and only where they name no other
		# amount at all.
		if (z60 & 0x0F) != 0:
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
			return
		_wear(s, 1)                     # $83BC
	blow(dmg)                           # $8354


## $8354 -- the blow itself, whatever threw it.  A shot that has reached the
## hero jumps straight in here ($88F0) with one.
func blow(dmg: int) -> void:
	if hero.hurt != 0:
		if hero.timer < 0x20:
			return                      # $8359
		# $8360 -- a step of the suit, and the low three bits back on.
		var left: int = hero.hurt - 0x10
		hero.hurt = (left | 0x07) if left >= 0 else 0x02
		hero.timer = 0
		return
	# $8377 -- no suit, and then it costs him his own life.
	if hero.suit == 0 or hero.timer < 0x70:
		return
	if hero.shield != 0:
		hero.shield -= 1                # $8388
	hero.timer = 0
	# $839D -- anything of eight or more takes one instead and puts him in the
	# water, which is how the deep places drown him.
	var d: int = dmg & 0x0F
	if d >= 0x08:
		d = 1
		hero.swim = 1
	hero.suit = hero.suit - d if hero.suit >= d else 0


## $8866 -- what has been thrown at the hero, laid over him.  $CDCC asks this
## once a picture, before the shots have moved and before the pool is walked at
## all, and only while the hero is old enough to be hurt ($05A3 >= $70).  The
## first slot that reaches him ends the walk, so no more than one shot lands.
func shots_hit_hero() -> void:
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
	match z60 & 0x07:
		0x01: _worth(s, 0x05)           # $827E
		0x02: _worth(s, 0x14)           # $8299
		0x03: kind[s] = 0x02            # $82AE
		0x04: pass                      # $82B4 -- nothing at all
		0x05: _suit(s, 0x01, 0x04, 0x10)    # $82B5
		0x06: _suit(s, 0x02, 0x08, 0x20)    # $82F3


## $827E and $8299 -- the two that are only worth points.
func _worth(s: int, n: int) -> void:
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
	b[s] = letters | bit             # $82DE
	if which != 2:
		pass                            # $82EB -- $070C,Y, the weapon's own
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
