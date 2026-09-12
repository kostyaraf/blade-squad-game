extends RefCounted
class_name SolStage

## Bank six: the behaviours that did not fit beside the others.
##
## A mind in bank 2 or 3 that needs one of these does not call it directly --
## bank 6 is not in the window at the time.  It loads the low byte of the entry
## into A and jumps to $8081 in bank 2, which puts $80<A> into $90:$91 and hands
## it to $C081; the fixed bank swaps banks 6 and 7 in and jumps through the
## pointer.  Every entry is a `JMP` in the little table that starts at $8004, so
## what the mind is really naming is one of ten routines.
##
## Bank 6 keeps its own copies of the two shot-pool helpers -- $84A8 for the
## free slot and $84B3 for taking it -- which behave exactly as $ADBA and $907B
## do; they are not repeated here.
##
## `work/re/sol_shots.md` lists which entry each mind asks for.


## $8081 (bank 2) -> $C081 -> the entry `n` of the table at the top of bank 6.
static func call_at(o: SolObjects, s: int, n: int) -> void:
	match n:
		0x07:
			_862c(o, s)
		0x7C:
			_8553(o, s)
		0x82:
			_84bc(o, s)
		0x91:
			_84ca(o, s)
		_:
			o.missed_stage(n)


## $86AB -- the new shot starts at the thing's own place plus $90:$93, with the
## carry the caller left standing.  What the last add leaves is handed back,
## because $862C runs sixteen of these in a row on it.
static func _place(o: SolObjects, s: int, i: int, dx: int, dy: int,
		c: int) -> int:
	var r: Array = o._add2(o.x[s], dx, c)
	o.s_x[i] = r[0]
	r = o._add2(o.y[s], dy, r[1])
	o.s_y[i] = r[0]
	return r[1]


## $84D8 -- the slot that both $84BC and $84CA start from: half a page to the
## side the thing is facing and one page up.  The side is the top bit of $0680,
## and the same bit is left in the carry, which is what $86AB then adds with.
static func _84d8(o: SolObjects, s: int) -> int:
	var i: int = SolShots.free_slot(o)      # $84A8
	if i < 0:
		return -1
	var dx := 0x0050                        # $84E2
	var c: int = (o.face[s] >> 7) & 1       # $84E8 ASL
	if c == 0:
		o.s_a[i] = 0x40                     # $84EC
	else:
		o.s_a[i] = 0xC0                     # $84F0
		dx = 0xFF50
	_place(o, s, i, dx, 0xFF50, c)          # $84FB -> $86AB
	return i


## $84BC, entry $82 -- one that falls back towards the ground.
static func _84bc(o: SolObjects, s: int) -> void:
	var i: int = _84d8(o, s)
	if i < 0:
		return
	SolShots.put(o, i, 0x0A)                # $84BF
	o.s_b[i] = 0x02                         # $84C4


## $84CA, entry $91 -- the same place, but it flies.
static func _84ca(o: SolObjects, s: int) -> void:
	var i: int = _84d8(o, s)
	if i < 0:
		return
	SolShots.put(o, i, 0x8B)                # $84CD
	o.s_b[i] = 0x20                         # $84D2


## $8553, entry $7C -- one page to the side it faces and two pages up.
static func _8553(o: SolObjects, s: int) -> void:
	var i: int = SolShots.free_slot(o)      # $8557
	if i < 0:
		return
	var c: int = (o.face[s] >> 7) & 1       # $855F ASL
	o.s_a[i] = 0x3C if c == 1 else 0xBC     # $8566
	o.carry = c
	o.s_x[i] = (o.x[s] & 0xFF) \
			| (o._adc((o.x[s] >> 8) & 0xFF, 0x00 if c == 1 else 0xFF) << 8)
	o.carry = 0                             # $8586 CLC
	o.s_y[i] = (o.y[s] & 0xFF) \
			| (o._adc((o.y[s] >> 8) & 0xFF, 0xFE) << 8)
	SolShots.put(o, i, 0x84)                # $8593
	o.s_b[i] = 0x04                         # $8598


# $8673 / $866F -- the step along and the step down of each of the sixteen, and
# $8687:$869B / $8683:$8697 the place each starts from: a ring round the thing.
const RING_A := [0x30, 0x2C, 0x22, 0x12, 0x00, 0xEE, 0xDE, 0xD4,
		0xD0, 0xD4, 0xDE, 0xEE, 0x00, 0x12, 0x22, 0x2C]
const RING_B := [0x00, 0x12, 0x22, 0x2C, 0x30, 0x2C, 0x22, 0x12,
		0x00, 0xEE, 0xDE, 0xD4, 0xD0, 0xD4, 0xDE, 0xEE]
const RING_X := [0xFE80, 0xFE9D, 0xFEF0, 0xFF6D, 0x0000, 0x0092, 0x010F, 0x0162,
		0x0180, 0x0162, 0x010F, 0x0092, 0x0000, 0xFF6D, 0xFEF0, 0xFE9D]
const RING_Y := [0x0000, 0xFF6D, 0xFEF0, 0xFE9D, 0xFE80, 0xFE9D, 0xFEF0, 0xFF6D,
		0x0000, 0x0092, 0x010F, 0x0162, 0x0180, 0x0162, 0x010F, 0x0092]


## $862C, entry $07 -- sixteen at once, a whole ring of them, laid out from the
## four tables.  The carry runs on from one to the next, because nothing between
## two turns of the loop puts it back.
static func _862c(o: SolObjects, s: int) -> void:
	var c := 1                              # what the callers leave standing
	for n in range(0x0F, -1, -1):
		var i: int = SolShots.free_slot(o)  # $8657 -> $84A8
		if i < 0:
			continue                        # $866E
		o.s_a[i] = RING_A[n]                # $865C
		o.s_b[i] = RING_B[n]
		c = _place(o, s, i, RING_X[n], RING_Y[n], c)
		SolShots.put(o, i, 0x87)            # $8669
