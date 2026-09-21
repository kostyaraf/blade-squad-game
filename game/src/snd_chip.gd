extends RefCounted
class_name SndChip

## The console's sound chip, the same one twice.
##
## Э6.1 proved the two drivers: on every picture the port writes into
## `$4000`..`$4017` exactly the bytes the cartridge writes.  What those bytes
## mean is this file's business.  Five voices share one output:
##
##     $4000..$4003  square one, with a sweep that can slide its pitch
##     $4004..$4007  square two, the same but its sweep subtracts one less
##     $4008..$400B  triangle, sixteen steps up and sixteen down, no loudness
##     $400C..$400F  noise, a fifteen-bit ring whose bottom bit is the sound
##     $4010..$4013  DMC, a recorded sample read a bit at a time
##     $4015         which voices are let through; $4017 the frame counter
##
## The chip is written twice over: here, and in `work/tools/nesemu.c`.  That
## is on purpose.  `work/extract/verify_apu.py` runs a cartridge in the
## emulator, which writes both the tape of register writes (cycle, address,
## byte) and its own wave; the engine is then handed the same tape, puts the
## same bytes on the same cycles, and must produce the same wave, sample for
## sample.  Two readings of the hardware agreeing byte for byte is the proof;
## one reading agreeing with itself would not be.
##
## One sample is taken every fortieth processor cycle, which at 1789773 Hz is
## 44744.325 Hz.  The mixer is not a sum: two squares at full loudness are
## quieter than twice one square, and the three remaining voices share a
## second curve of their own.  Both curves are tabulated at boot.
##
## Speed.  The emulator steps every cycle; the engine cannot afford to, so it
## steps in stretches instead, and a stretch ends at whatever comes first --
## the next sample, the next tick of the frame counter, or the next register
## write.  Inside a stretch nothing that a counter looks at can change, so
## "how many times would this counter have fired in k cycles" is one division
## and the answer is the same one the emulator would have counted out.

const SND_EVERY := 40             ## cycles between samples
const RATE := 44744               ## 1789773 / 40, rounded down

const DUTY := [
	[0, 1, 0, 0, 0, 0, 0, 0],
	[0, 1, 1, 0, 0, 0, 0, 0],
	[0, 1, 1, 1, 1, 0, 0, 0],
	[1, 0, 0, 1, 1, 1, 1, 1],
]
const TRI := [
	15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
]
const NOISE_TBL := [
	4, 8, 16, 32, 64, 96, 128, 160, 202, 254, 380, 508, 762, 1016, 2034, 4068,
]
const DMC_TBL := [
	428, 380, 340, 320, 286, 254, 226, 214, 190, 160, 142, 128, 106, 84, 72, 54,
]
const LENGTH := [
	10, 254, 20, 2, 40, 4, 80, 6, 160, 8, 60, 10, 14, 12, 26, 14,
	12, 16, 24, 18, 48, 20, 96, 22, 192, 24, 72, 26, 16, 28, 32, 30,
]

## The cycles of the frame counter at which a quarter or a half happens, and
## at which it starts over.  $4017 bit 7 picks the row.
const EVENTS4 := [7457, 14913, 22371, 29828, 29829, 29830]
const EVENTS5 := [7457, 14913, 22371, 37281, 37282]

# --- the frame counter -------------------------------------------------
var ctr := 0
var mode := 0                     ## $4017 bit 7: 0 = four steps, 1 = five
var irq_inhibit := 0
var reset_delay := 0

# --- the length counters, one per voice ($4015 bits 0..3) --------------
var length := [0, 0, 0, 0]
var halt := [0, 0, 0, 0]
var enable := 0

# --- the three envelopes: square one, square two, noise ----------------
var env_start := [0, 0, 0, 0]
var env_div := [0, 0, 0, 0]
var env_decay := [0, 0, 0, 0]
var env_const := [0, 0, 0, 0]
var env_loop := [0, 0, 0, 0]
var env_vol := [0, 0, 0, 0]

# --- the two squares ---------------------------------------------------
var p_period := [0, 0]
var p_count := [0, 0]
var p_seq := [0, 0]
var p_duty := [0, 0]
var sw_on := [0, 0]
var sw_period := [0, 0]
var sw_negate := [0, 0]
var sw_shift := [0, 0]
var sw_div := [0, 0]
var sw_reload := [0, 0]

# --- the triangle ------------------------------------------------------
var t_period := 0
var t_count := 0
var t_seq := 0
var t_lin := 0
var t_lin_reload := 0
var t_lin_flag := 0

# --- the noise ---------------------------------------------------------
var n_period := 0
var n_count := 0
var n_shift := 1
var n_mode := 0

# --- the sample voice --------------------------------------------------
var d_rate := 0
var d_count := 0
var d_level := 0
var d_addr := 0xC000
var d_len := 1
var d_cur := 0xC000
var d_left := 0
var d_buf := 0
var d_full := 0
var d_sr := 0
var d_bits := 8
var d_silence := 1
var d_loop := 0
var d_rom := PackedByteArray()    ## the bank fixed at $C000
var d_base := 0xC000

# --- the output --------------------------------------------------------
var odd := 0                      ## the second half of a chip cycle
var div := SND_EVERY
var out := PackedByteArray()      ## the wave, s16le mono
var out_n := 0                    ## how much of it is written

static var _pulse_mix: Array = []
static var _tnd_mix: Array = []


func _init(dmc_rom: PackedByteArray = PackedByteArray()) -> void:
	d_rom = dmc_rom
	if _pulse_mix.is_empty():
		_pulse_mix.resize(31)
		_pulse_mix[0] = 0.0
		for i in range(1, 31):
			_pulse_mix[i] = 95.52 / (8128.0 / float(i) + 100.0)
		_tnd_mix.resize(203)
		_tnd_mix[0] = 0.0
		for i in range(1, 203):
			_tnd_mix[i] = 163.67 / (24329.0 / float(i) + 100.0)


## Everything the console clears when it is turned on.
func reset() -> void:
	ctr = 0
	mode = 0
	irq_inhibit = 0
	reset_delay = 0
	length = [0, 0, 0, 0]
	halt = [0, 0, 0, 0]
	enable = 0
	env_start = [0, 0, 0, 0]
	env_div = [0, 0, 0, 0]
	env_decay = [0, 0, 0, 0]
	env_const = [0, 0, 0, 0]
	env_loop = [0, 0, 0, 0]
	env_vol = [0, 0, 0, 0]
	p_period = [0, 0]
	p_count = [0, 0]
	p_seq = [0, 0]
	p_duty = [0, 0]
	sw_on = [0, 0]
	sw_period = [0, 0]
	sw_negate = [0, 0]
	sw_shift = [0, 0]
	sw_div = [0, 0]
	sw_reload = [0, 0]
	t_period = 0
	t_count = 0
	t_seq = 0
	t_lin = 0
	t_lin_reload = 0
	t_lin_flag = 0
	n_period = 0
	n_count = 0
	n_shift = 1
	n_mode = 0
	d_rate = 0
	d_count = 0
	d_level = 0
	d_addr = 0xC000
	d_len = 1
	d_cur = 0xC000
	d_left = 0
	d_buf = 0
	d_full = 0
	d_sr = 0
	d_bits = 8
	d_silence = 1
	d_loop = 0
	odd = 0
	div = SND_EVERY
	out = PackedByteArray()
	out_n = 0


# ------------------------------------------------------------------
# what the processor writes
# ------------------------------------------------------------------

## One write to `$4000`..`$4017`.  `$4009`, `$400D` and the two holes at
## `$4014`/`$4016` are not the chip's and are swallowed here, exactly as the
## console swallows them: both drivers reach them through `STA $4000,X`.
func write(a: int, v: int, cycle: int = 0) -> void:
	match a:
		0x4000, 0x4004:
			var i := 0 if a == 0x4000 else 1
			halt[i] = 1 if (v & 0x20) != 0 else 0
			p_duty[i] = v >> 6
			env_loop[i] = halt[i]
			env_const[i] = 1 if (v & 0x10) != 0 else 0
			env_vol[i] = v & 0x0F
		0x4001, 0x4005:
			var i := 0 if a == 0x4001 else 1
			sw_on[i] = 1 if (v & 0x80) != 0 else 0
			sw_period[i] = (v >> 4) & 7
			sw_negate[i] = 1 if (v & 0x08) != 0 else 0
			sw_shift[i] = v & 7
			sw_reload[i] = 1
		0x4002, 0x4006:
			var i := 0 if a == 0x4002 else 1
			p_period[i] = (p_period[i] & 0x700) | v
		0x4003, 0x4007:
			var i := 0 if a == 0x4003 else 1
			p_period[i] = (p_period[i] & 0xFF) | ((v & 7) << 8)
			p_seq[i] = 0
			env_start[i] = 1
			if (enable & (1 << i)) != 0:
				length[i] = LENGTH[v >> 3]
		0x4008:
			halt[2] = 1 if (v & 0x80) != 0 else 0
			t_lin_reload = v & 0x7F
		0x400A:
			t_period = (t_period & 0x700) | v
		0x400B:
			t_period = (t_period & 0xFF) | ((v & 7) << 8)
			t_lin_flag = 1
			if (enable & 0x04) != 0:
				length[2] = LENGTH[v >> 3]
		0x400C:
			halt[3] = 1 if (v & 0x20) != 0 else 0
			env_loop[3] = halt[3]
			env_const[3] = 1 if (v & 0x10) != 0 else 0
			env_vol[3] = v & 0x0F
		0x400E:
			n_mode = 1 if (v & 0x80) != 0 else 0
			n_period = NOISE_TBL[v & 0x0F] - 1
		0x400F:
			env_start[3] = 1
			if (enable & 0x08) != 0:
				length[3] = LENGTH[v >> 3]
		0x4010:
			d_loop = 1 if (v & 0x40) != 0 else 0
			d_rate = DMC_TBL[v & 0x0F] - 1
		0x4011:
			d_level = v & 0x7F
		0x4012:
			d_addr = 0xC000 + v * 64
		0x4013:
			d_len = v * 16 + 1
		0x4015:
			enable = v & 0x1F
			for i in 4:
				if (v & (1 << i)) == 0:
					length[i] = 0
			if (v & 0x10) != 0:
				if d_left == 0:
					d_cur = d_addr
					d_left = d_len
			else:
				d_left = 0
		0x4017:
			mode = 1 if (v & 0x80) != 0 else 0
			irq_inhibit = 1 if (v & 0x40) != 0 else 0
			# The console takes three or four cycles to act on this, and which
			# it takes turns on whether the write landed on an odd cycle.  The
			# tape carries the cycle, so the port can tell.
			reset_delay = 4 if (cycle & 1) != 0 else 3
		_:
			pass


# ------------------------------------------------------------------
# the frame counter
# ------------------------------------------------------------------

func _quarter() -> void:
	for i in [0, 1, 3]:
		if env_start[i] != 0:
			env_start[i] = 0
			env_decay[i] = 15
			env_div[i] = env_vol[i]
		elif env_div[i] == 0:
			env_div[i] = env_vol[i]
			if env_decay[i] > 0:
				env_decay[i] -= 1
			elif env_loop[i] != 0:
				env_decay[i] = 15
		else:
			env_div[i] -= 1
	if t_lin_flag != 0:
		t_lin = t_lin_reload
	elif t_lin > 0:
		t_lin -= 1
	if halt[2] == 0:
		t_lin_flag = 0


## Where the sweep would put the period.  Square one subtracts one more than
## square two does, and that one byte is the whole difference between them.
func _sweep_target(i: int) -> int:
	var c: int = p_period[i] >> sw_shift[i]
	if sw_negate[i] != 0:
		return p_period[i] - c - (1 if i == 0 else 0)
	return p_period[i] + c


func _half() -> void:
	for i in 4:
		if halt[i] == 0 and length[i] > 0:
			length[i] -= 1
	for i in 2:
		var t := _sweep_target(i)
		if sw_div[i] == 0 and sw_on[i] != 0 and sw_shift[i] != 0 \
				and p_period[i] >= 8 and t <= 0x7FF:
			p_period[i] = 0 if t < 0 else t
		if sw_div[i] == 0 or sw_reload[i] != 0:
			sw_div[i] = sw_period[i]
			sw_reload[i] = 0
		else:
			sw_div[i] -= 1


## Is the very next cycle one the frame counter does something on?
func _event_next() -> bool:
	var e: Array = EVENTS5 if mode != 0 else EVENTS4
	return e.has(ctr + 1)


## How many cycles may pass with the frame counter doing nothing.  The next
## cycle is not one of its own -- `_event_next()` is asked first -- so this is
## at least one, and it stops the stretch short of the cycle that is.
func _to_event() -> int:
	var e: Array = EVENTS5 if mode != 0 else EVENTS4
	var best := 1 << 30
	for c in e:
		var d: int = c - ctr
		if d > 0 and d < best:
			best = d
	return best - 1


## The frame counter, one cycle, exactly as the console counts it.
func _frame_one() -> void:
	if reset_delay > 0:
		reset_delay -= 1
		if reset_delay == 0:
			ctr = 0
			if mode != 0:
				_quarter()
				_half()
	ctr += 1
	if mode == 0:
		match ctr:
			7457: _quarter()
			14913: _quarter(); _half()
			22371: _quarter()
			29829: _quarter(); _half()
			29830: ctr = 0
	else:
		match ctr:
			7457: _quarter()
			14913: _quarter(); _half()
			22371: _quarter()
			37281: _quarter(); _half()
			37282: ctr = 0


# ------------------------------------------------------------------
# the counters
# ------------------------------------------------------------------

var _left := 0
var _fires := 0

## A counter that counts down from `c`, fires at nought and reloads to `p`,
## run for `k` cycles at once.  What is wanted is how many times it fired and
## where it stands afterwards, and both are arithmetic.
func _adv(c: int, p: int, k: int) -> void:
	if k <= c:
		_left = c - k
		_fires = 0
		return
	var r := k - c - 1
	var per := p + 1
	_fires = 1 + r / per
	_left = p - (r % per)


## The sample voice fetches its next byte the moment its buffer is empty, and
## it fetches it through a read that costs the processor nothing -- on the
## console that read steals cycles, and stealing them here would move what
## Э3..Э5 have already accepted.
func _dmc_fill() -> void:
	if d_full == 0 and d_left > 0:
		var off := d_cur - d_base
		d_buf = d_rom[off] if off >= 0 and off < d_rom.size() else 0
		d_full = 1
		d_cur = 0x8000 if d_cur == 0xFFFF else d_cur + 1
		d_left -= 1
		if d_left == 0 and d_loop != 0:
			d_cur = d_addr
			d_left = d_len


func _timers(k: int) -> void:
	# the triangle counts the processor's own cycles
	_adv(t_count, t_period, k)
	t_count = _left
	if _fires > 0 and t_lin > 0 and length[2] > 0:
		t_seq = (t_seq + _fires) & 31

	# the noise ring has to be turned one notch at a time: what it shifts in
	# is made out of what it already holds
	_adv(n_count, n_period, k)
	n_count = _left
	for _i in _fires:
		var b: int = (n_shift ^ (n_shift >> 6 if n_mode != 0 else n_shift >> 1)) & 1
		n_shift = (n_shift >> 1) | (b << 14)

	# the sample voice.  The fetch happens after the timer of the same cycle,
	# so a stretch that opens on a firing fetches after that firing and not
	# before it.
	if d_count != 0:
		_dmc_fill()
	_adv(d_count, d_rate, k)
	var df := _fires
	d_count = _left
	for _i in df:
		if d_silence == 0:
			if (d_sr & 1) != 0:
				if d_level <= 125:
					d_level += 2
			elif d_level >= 2:
				d_level -= 2
		d_sr >>= 1
		d_bits -= 1
		if d_bits == 0:
			d_bits = 8
			if d_full != 0:
				d_silence = 0
				d_sr = d_buf
				d_full = 0
			else:
				d_silence = 1
		_dmc_fill()

	# the two squares count every second cycle
	var ps := (k + odd) >> 1
	odd = (odd + k) & 1
	for i in 2:
		_adv(p_count[i], p_period[i], ps)
		p_count[i] = _left
		if _fires > 0:
			p_seq[i] = (p_seq[i] + _fires) & 7


# ------------------------------------------------------------------
# the mixer
# ------------------------------------------------------------------

func _pulse_out(i: int) -> int:
	if length[i] == 0 or p_period[i] < 8 or _sweep_target(i) > 0x7FF:
		return 0
	if DUTY[p_duty[i]][p_seq[i]] == 0:
		return 0
	return env_vol[i] if env_const[i] != 0 else env_decay[i]


func _noise_out() -> int:
	if length[3] == 0 or (n_shift & 1) != 0:
		return 0
	return env_vol[3] if env_const[3] != 0 else env_decay[3]


## Room for a run of a known length, so the wave is not grown a byte at a
## time.  Without it the wave still comes out right, only slower.
func reserve(samples: int) -> void:
	out.resize(samples * 2)
	out_n = 0


## The wave as far as it has been written.
func wave() -> PackedByteArray:
	return out.slice(0, out_n)


func _emit() -> void:
	var v: float = _pulse_mix[_pulse_out(0) + _pulse_out(1)] \
		+ _tnd_mix[3 * TRI[t_seq] + 2 * _noise_out() + d_level]
	var s := int(round(v * 32767.0))
	if s > 32767:
		s = 32767
	if s < -32768:
		s = -32768
	if out_n + 2 <= out.size():
		out[out_n] = s & 0xFF
		out[out_n + 1] = (s >> 8) & 0xFF
	else:
		out.append(s & 0xFF)
		out.append((s >> 8) & 0xFF)
	out_n += 2


# ------------------------------------------------------------------
# running
# ------------------------------------------------------------------

## `n` processor cycles, in as few stretches as the state allows.  Each
## stretch stops at whatever comes first: the next tick of the frame counter
## or the next sample.
func run(n: int) -> void:
	while n > 0:
		if reset_delay > 0 or _event_next():
			_frame_one()
			_timers(1)
			div -= 1
			if div == 0:
				div = SND_EVERY
				_emit()
			n -= 1
			continue
		var k := n
		var f := _to_event()
		if f < k:
			k = f
		if div < k:
			k = div
		ctr += k
		_timers(k)
		div -= k
		if div == 0:
			div = SND_EVERY
			_emit()
		n -= k
