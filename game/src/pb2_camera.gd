extends RefCounted
class_name Pb2Camera

## Where the view is and how it follows him -- $D924, $D976 and $D3B8.
##
## The console keeps the view in two bytes, $66 and $67, and in a level that
## scrolls downwards the low one counts to two hundred and forty, not to two
## hundred and fifty six: a page of the view is exactly a screen.  The map,
## though, is laid out in pages of two hundred and fifty six with the last
## sixteen lines left empty, so keeping the pair as one number and stepping over
## those sixteen lines when reading the map ($F52C) comes to the same thing and
## is easier to hold in the head.

var vertical: bool
var pos := 0                 ## $66:$67 as one number
var shift := 0               ## $94 -- how far it slid this frame
var pending := 0             ## $60 -- how far it still has to slide, with a sign
var limit_page := 0          ## $59
var limit_low := 0           ## $5A

# $D404 and $D406: the band on the screen he is kept in.  Sideways first,
# downwards second.  ($D408 holds the same near edge one less, because the
# cartridge subtracts it with the carry clear.)
const FAR := [0x90, 0x68]
const NEAR := [0x70, 0x60]


## $0116 -- how far the view may travel in one frame.  $8E17 gives it five
## every time the hero is updated; only the states where he is clinging to
## something give it one, and those are not his own yet.
const ALLOWANCE := 5


func _init(level: Pb2Level) -> void:
	vertical = level.vertical
	pos = (level.cam_start_page << 8) | level.cam_start_low
	limit_page = level.cam_limit_page
	limit_low = level.cam_limit_low


## Where the recording found it, for the acceptance check.
func place(page: int, low: int, still_to_go: int) -> void:
	pos = (page << 8) | low
	pending = still_to_go


## $D924 -- slide by what was decided last frame, a pixel at a time.
func drive() -> void:
	shift = 0
	while pending != 0:
		if pending < 0:
			if not _back():
				break
			pending += 1
		else:
			if not _forward():
				break
			pending -= 1


## $D3B8 -- decide how far to slide next frame.  He is kept between the near
## edge of the band and the far one, and the view cannot outrun what the game
## allows it this frame ($0116).
func decide(screen_pos: int, allowance: int = ALLOWANCE) -> void:
	var i: int = 1 if vertical else 0
	if screen_pos >= FAR[i]:
		pending = min(screen_pos - FAR[i], allowance)
	elif screen_pos >= NEAR[i]:
		pending = 0
	else:
		pending = max(screen_pos - NEAR[i], -allowance)


func _forward() -> bool:
	var page: int = pos >> 8
	var low: int = pos & 0xFF
	if vertical:
		# $DAAB: both halves have to match before it stops.
		if low == limit_low and page == limit_page:
			return false
		low += 1
		if low == 0xF0:
			page += 1
			low = 0
	else:
		# $D99E: sideways only the page is looked at.
		if page == limit_page:
			return false
		low += 1
		if low == 0x100:
			page += 1
			low = 0
	pos = (page << 8) | low
	shift += 1
	return true


func _back() -> bool:
	if pos == 0:
		return false
	var page: int = pos >> 8
	var low: int = (pos & 0xFF) - 1
	if low < 0:
		low = 0xEF if vertical else 0xFF
		page -= 1
		if page < 0:
			page = 0
			low = 0
	pos = (page << 8) | low
	shift -= 1
	return true
