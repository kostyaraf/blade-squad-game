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

var _types: Array
var _born: PackedByteArray
var _gone: PackedByteArray
var _room_group: PackedByteArray
var _groups: Dictionary


func _init(lvl: SolLevel) -> void:
	level = lvl
	var t: Dictionary = Nes._load_json("%s/sol/objects.json" % Nes.DATA)
	_types = t["types"]
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
		var side: int = -1 if n < 0 else _born[n - FIRST_CELL]
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


## $CE1D -- one frame of the pool, from the last slot down to the first.
func step(cam_x: int, cam_y: int) -> void:
	for s in range(LAST_SPAWNED, -1, -1):
		if id[s] == 0:
			continue
		if not _keep(s, cam_x, cam_y):
			continue
		# $CE30 -- one more frame since it was last hit, and it stops at $FF
		# rather than rolling over into "just hit".
		if cool[s] != 0xFF:
			cool[s] += 1


static func _signed(v: int) -> int:
	return v - 0x10000 if v >= 0x8000 else v
