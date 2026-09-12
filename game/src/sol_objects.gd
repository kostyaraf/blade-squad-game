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

# Where it is on the screen, in whole pixels, filled by the frame walk.
var at_x := PackedInt32Array()      # $5C:$5D
var at_y := PackedInt32Array()      # $5E:$5F

# The scroll bookkeeping the spawner leans on.
var due := 0                        # $05EC: a scan has been asked for
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
var stage := 0                      # $55 -- which stage is up
var map_kind := 0                   # $70 -- $3C is the stage that is all water
var z9d := 0                        # $9D -- what the last probe left over
var skipped := {}                   # which behaviours have not been read yet

var _types: Array
var _anims: Array
var _anims3: Array
var _hatch: PackedByteArray
var _steps: PackedByteArray
var _arctan: PackedByteArray
var _born: PackedByteArray
var _gone: PackedByteArray
var _room_group: PackedByteArray
var _groups: Dictionary


func _init(lvl: SolLevel) -> void:
	level = lvl
	var t: Dictionary = Nes._load_json("%s/sol/objects.json" % Nes.DATA)
	_types = t["types"]
	_anims = t["anims"]
	_anims3 = t["anims3"]
	_hatch = PackedByteArray(t["hatch"])
	_steps = PackedByteArray(t["steps"])
	_arctan = PackedByteArray(t["arctan"])
	_born = PackedByteArray(t["born"])
	_gone = PackedByteArray(t["gone"])
	_room_group = lvl.room_group
	_groups = lvl.object_groups
	for arr in [id, mind, pic_lo, pic_hi, face, a, b, c, d, kind,
			anim_a, anim_b, left, frame, cool, life]:
		arr.resize(SLOTS)
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
## nothing means start the walk again.
func _advance(s: int, n: int, set := 4) -> void:
	var book: Array = _anims if set == 4 else _anims3
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
func missed(m: int, done: bool) -> void:
	var key := "%02X%s" % [m, "-dead" if done else ""]
	skipped[key] = int(skipped.get(key, 0)) + 1


## $8E44 in bank 12 -- which way the slot lies from the hero, as a heading.
## Answers $FF when the two are on top of each other or too far apart to say.
func angle_to_hero(s: int) -> int:
	return angle_to(s, hero_x, hero_y)


## $804B -- the same, but the height is the caller's own, not the hero's.
func angle_to(s: int, tx: int, ty: int) -> int:
	var p := PackedInt32Array([x[s] & 0xFF, (x[s] >> 8) & 0xFF,
			y[s] & 0xFF, (y[s] >> 8) & 0xFF])
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
	var dx: int = ax | bx << 8
	var dy: int = ay | by << 8
	var guard := 0
	while (((dx >> 8) | (dy >> 8)) & 0xFF) < 0x10 and guard < 32:
		dx = (dx << 1) & 0xFFFF
		dy = (dy << 1) & 0xFFFF
		guard += 1
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
	var py: int = y[s] + oy
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
