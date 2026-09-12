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
		0x0A:
			_85dc(o, s)
		0x7F:
			_84ff(o, s)
		0x82:
			_84bc(o, s)
		0x8E:
			_8094(o, s)
		0x91:
			_84ca(o, s)
		_:
			o.missed_stage(n)


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
	SolShots.place(o, s, i, dx, 0xFF50, c)          # $84FB -> $86AB
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
		c = SolShots.place(o, s, i, RING_X[n], RING_Y[n], c)
		SolShots.put(o, i, 0x87)            # $8669


## $8094, entry $8E -- three bytes off the little table at $80A9 into
## $011D:$011F, which is where the picture is drawn from.  Nothing of the two
## pools is touched, so there is nothing here to keep.
static func _8094(_o: SolObjects, _s: int) -> void:
	pass


## $84FF, entry $7F -- every other picture, one bubble somewhere along the top
## of the thing, the stirred byte choosing both how far along and how fast.
static func _84ff(o: SolObjects, s: int) -> void:
	if (o.clock & 0x01) == 0:
		return                              # $8502
	var i: int = SolShots.free_slot(o)      # $8504
	if i < 0:
		return
	o.s_kind[i] = 0x03                      # $8509
	o.s_life[i] = 0x03
	o.carry = 1                             # what $8502 left standing
	o.s_b[i] = o._adc(o.noise & 0x3F, 0x81)
	o.carry = 1                             # $851A SEC
	var bx: int = (o.x[s] & 0xFF) \
			| (o._sbc((o.x[s] >> 8) & 0xFF, 0x01) << 8)
	var ylo: int = o.y[s] & 0xFF            # $8525
	o.carry = 0                             # $852A CLC
	o.s_y[i] = ylo | (o._adc((o.y[s] >> 8) & 0xFF, 0x01) << 8)
	var along: int = ((o.noise & 0x1F) << 4) & 0xFFFF   # $8536
	o.carry = 0                             # the last ROL leaves it down
	var lo: int = o._adc(along & 0xFF, bx & 0xFF)
	o.s_x[i] = lo | (o._adc((bx >> 8) & 0xFF, (along >> 8) & 0xFF) << 8)


## $85DC, entry $0A -- three at once, at three speeds.
static func _85dc(o: SolObjects, s: int) -> void:
	_85e8(o, s, 0x10)
	_85e8(o, s, 0x20)
	_85e8(o, s, 0x30)


## $85E8 -- one of the three.  $847D puts the speed in with the sign the side
## it faces wants, and leaves in the carry which side that was.
static func _85e8(o: SolObjects, s: int, n: int) -> void:
	var i: int = SolShots.free_slot(o)      # $85EA
	if i < 0:
		return
	var c: int = (o.face[s] >> 7) & 1       # $847D ASL
	if c == 1:
		o.s_a[i] = n
	else:
		o.carry = 0
		o.s_a[i] = o._sbc(0x01, n)          # $8485
		c = o.carry
	o.carry = c                             # $85F6
	o.s_x[i] = (o.x[s] & 0xFF) \
			| (o._adc((o.x[s] >> 8) & 0xFF, 0x00 if c == 1 else 0xFF) << 8)
	var ylo: int = o._adc(o.y[s] & 0xFF, 0x80)          # $8613
	o.s_y[i] = ylo | (o._adc((o.y[s] >> 8) & 0xFF, 0x00) << 8)
	SolShots.put(o, i, 0x8C)                # $8621
	o.s_b[i] = 0xA0                         # $8626


## $8782 -- how far below the head each link of the tail hangs, read by the
## clock a half-step at a time and mirrored back up again.
const TAIL := [0x00, 0x08, 0x10, 0x18, 0x18, 0x20, 0x20, 0x20,
		0x20, 0x20, 0x20, 0x20, 0x18, 0x18, 0x10, 0x08]


## $86C8 -- the tail.  $921C in bank 2 is the only mind that asks for it, and
## it does not go through $8081: $C07E jumps straight at the first entry of the
## table.  Link nought takes a step of its own; every other link is hung off
## the head, a quarter turn further round for each, and the head's own heading
## picks which of three pictures the whole tail wears.
static func chain(o: SolObjects, s: int) -> void:
	if o.kind[s] == 0x00:
		_8748(o, s)                             # $870C
		_872a(o, o.a[s], 0xE0)                  # $8723
		_8712(o)
		o.move(s)                               # $848D
		return
	o.face[s] = o.face[0]                       # $873E
	o.y[s] = o.y[0]
	o.x[s] = o.x[0]
	var sp: int = o.a[0] & 0xF0                 # $86D9
	o.carry = 1
	o.a[s] = o._sbc(o.a[s], 0x04)               # $86E1
	_872a(o, o.a[s], sp)                        # $86E9
	_8712(o)                                    # $86EC
	o.move(s)                                   # $848D
	var p := 0x1E                               # $86F2
	if o.a[0] < 0xD0:
		p = 0x20
		if o.a[0] < 0xB0:
			p = 0x22
	o.pic_lo[s] = p                             # $8708


## $8748 -- the link is put where the head is, and a little below or above it.
static func _8748(o: SolObjects, s: int) -> void:
	var t: int = o.clock >> 1
	var d: int = TAIL[t & 0x0F]
	if (t & 0x10) != 0:
		o.carry = 1                             # $8754
		var lo: int = o._sbc(o.y[0] & 0xFF, d)
		o.y[s] = lo | o._sbc((o.y[0] >> 8) & 0xFF, 0x00) << 8
	else:
		o.carry = 0                             # $8765
		var lo2: int = o._adc(o.y[0] & 0xFF, d)
		o.y[s] = lo2 | o._adc((o.y[0] >> 8) & 0xFF, 0x00) << 8
	o.face[s] = o.face[0]                       # $8773
	o.x[s] = o.x[0]


## $872A -- the step, four times over: $C07B is the same $8FF6 the rest of the
## game reads, and both halves are shifted up twice after it.
static func _872a(o: SolObjects, dir: int, speed: int) -> void:
	o.spin(dir, speed)                          # $C07B
	o.z90 = (o.z90 << 2) & 0xFFFF               # $872D
	o.z92 = (o.z92 << 2) & 0xFFFF               # $8735


## $8712 -- and the step is taken over as this picture's own.
static func _8712(o: SolObjects) -> void:
	o.z50 = o.z90
	o.z52 = o.z92
