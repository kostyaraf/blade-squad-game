extends RefCounted
class_name SolCamera
## Э4.1 -- where the view stands in Solbrain, $F1EA across and $F24B down.
##
## The view does not chase the hero: it decides, once a picture, whether he has
## walked out of a band kept in the middle of the screen, and if he has, it
## moves by *his* speed, not by the distance between them.  So the band is held
## only as long as he keeps moving, and a hero stopped dead leaves the view
## where it was.
##
## Everything here is in sixteenths of a pixel, like his own place, so a screen
## across is $1000 and a screen down is $0F00.  Both numbers are the game's
## own, written in the code as `#$10` and `#$0F` against the high byte.
##
## The two ends of the stage come out of its own record ($E72D..$E741, the four
## high bytes), and the band across is written in flat at $E6B3: seven high
## bytes from the left edge of the band to the screen's left, one more to its
## right.  Down, the band is not stored at all -- $F352 writes six and eight in
## by hand.

const SCREEN_X := 0x10           # $F239, $F306 -- a screen across, high byte
const SCREEN_Y := 0x10           # $F2C3, $F39A -- what the clamp takes off
const VIEW_Y := 0x0F             # $F3AA -- and what the band down is worth
const BAND_LEFT := 7             # $05E4, set at $E6B3
const BAND_WIDTH := 1            # $05E5, set at $E6B8
const BAND_TOP := 6              # $F352
const BAND_BOTTOM := 8           # $F357, six plus two
const WIDE_ENOUGH := 0x11        # $F2E7 -- narrower than this and it never moves
const TALL_ENOUGH := 0x14        # $F37B
const RIDE := 0x3C               # $70, the kind of map that carries him down
const RIDE_WAIT := 0x30          # $F256

var x := 0                       # $30:$31
var y := 0                       # $32:$33
var want := 0                     # $05D8, one signed byte: which way it may go
var x_min := 0                   # $38:$39
var x_end := 0                   # $3A:$3B
var y_min := 0                   # $3C:$3D
var y_end := 0                   # $3E:$3F
var map_kind := 0                # $70
var hold := 0                    # $05C3
var fall := 0                    # $34, how fast the carrying map takes him down


func _init(level: SolLevel) -> void:
	if level == null:
		return
	x_min = int(level.camera["x_min"])
	x_end = int(level.camera["x_end"])
	y_min = int(level.camera["y_min"])
	y_end = int(level.camera["y_end"])


## $E70C..$E728 -- where it stands when the stage is raised: the low byte
## nothing, the high byte the hero's rounded down to a whole room.
func place(hero_x: int, hero_y: int) -> void:
	x = (hero_x & 0xF000)
	y = (hero_y & 0xF000)


## One picture of the view, in the order the game runs it: across first.
func step(vx: int, vy: int, hero_x: int, hero_y: int) -> void:
	_across(vx, hero_x)
	_down(vy, hero_y)


# ---- across ---------------------------------------------------------------

## $F1EA
func _across(vx: int, hero_x: int) -> void:
	_look_across(hero_x)
	if want == 0:
		return
	var hi: int = (vx & 0xFFFF) >> 8
	if (want & 0x80) == 0:
		# He is out to the right, so the view follows only while he is
		# actually going that way.
		if ((want ^ hi) & 0x80) != 0:
			return
		x = (x + vx) & 0xFFFF
		if x < x_min:
			x = x_min
		return
	if ((want ^ hi) & 0x80) != 0:
		return
	x = (x + vx) & 0xFFFF
	# $F22F -- and the other end, but only when it is overshot by less than
	# a screen; further than that and the number is left alone.
	if x < x_end:
		return
	if ((x - x_end) >> 8) <= SCREEN_X:
		x = (x_end - (SCREEN_X << 8)) & 0xFFFF


## $F2C8 -- is he outside the band, and which side.
func _look_across(hero_x: int) -> void:
	want = 0
	var left: int = BAND_LEFT
	var right: int = (BAND_LEFT + BAND_WIDTH) & 0xFF
	if ((x_end - x_min) & 0xFFFF) >> 8 < WIDE_ENOUGH:
		return
	# Against the left end the band is dropped: there is nowhere further to go.
	var edge: int = (x_min - 0x100) & 0xFFFF
	if x < edge or ((x - edge) & 0xFFFF) >> 8 == 0:
		left = 0
	if ((x_end - (SCREEN_X << 8)) & 0xFFFF) < x:
		right = SCREEN_X
	if ((x + (left << 8)) & 0xFFFF) >= hero_x:
		want = 0xFF
		return
	if hero_x >= ((x + (right << 8)) & 0xFFFF):
		want = 1


# ---- down -----------------------------------------------------------------

## $F24B
func _down(vy: int, hero_y: int) -> void:
	if map_kind == RIDE:
		# The one kind of map that carries him: the view goes up on its own,
		# and the hero's own speed has no say in it.
		if hold != 0 and hold < RIDE_WAIT:
			_clamp_bottom()
			return
		var lo: int = (y & 0xFF) - fall
		y = (y & 0xFF00) | (lo & 0xFF)
		if lo < 0:
			y = (y - 0x100) & 0xFFFF
		_clamp_bottom()
		return
	_look_down(hero_y)
	if want == 0:
		return
	var hi: int = (vy & 0xFFFF) >> 8
	if (want & 0x80) == 0:
		if ((want ^ hi) & 0x80) != 0:
			return
		y = (y + vy) & 0xFFFF
		_clamp_top()
		return
	if ((want ^ hi) & 0x80) != 0:
		return
	y = (y + vy) & 0xFFFF
	_clamp_bottom()


## $F2AC -- overshot the bottom by up to a screen and it is pulled back; by
## more than that and the other end has the last word instead.
func _clamp_bottom() -> void:
	if y < y_end:
		_clamp_top()
		return
	if ((y - y_end) >> 8) > SCREEN_Y:
		_clamp_top()
		return
	y = (y_end - (SCREEN_Y << 8)) & 0xFFFF


## $F285
func _clamp_top() -> void:
	if y < y_min:
		y = y_min


## $F352
func _look_down(hero_y: int) -> void:
	want = 0
	var top: int = BAND_TOP
	var bottom: int = BAND_BOTTOM
	if ((y_end - y_min) & 0xFFFF) >> 8 < TALL_ENOUGH:
		return
	var edge: int = (y_min - 0x100) & 0xFFFF
	if y < edge or ((y - edge) & 0xFFFF) >> 8 == 0:
		top = 0
	if ((y_end - (SCREEN_Y << 8)) & 0xFFFF) < y:
		bottom = VIEW_Y
	if ((y + (top << 8)) & 0xFFFF) >= hero_y:
		want = 0xFF
		return
	# $F3CA -- the borrow going in is whatever the add above left, and the
	# add is the only thing that ever sets it.  So the test is a step tighter
	# than its brother across, and tighter still when the high byte wraps.
	var sum: int = (y >> 8) + bottom
	var q: int = (y & 0xFF) | ((sum & 0xFF) << 8)
	if q < hero_y + (1 if sum <= 0xFF else 0):
		want = 1
