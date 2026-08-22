extends RefCounted
class_name Clock

## The console's frame, kept honest.
##
## An NTSC machine draws 60.0988 frames a second, and both games count time in
## frames: how long a jump lasts, how fast a shot flies, when a platform turns
## round.  Tying that to whatever the monitor happens to do would make the
## games run at the wrong speed on most screens, so the logic gets its own
## clock and the screen just shows the latest state.

const HZ := 60.0988138974405
const STEP := 1.0 / HZ
const MAX_CATCHUP := 5          # after a stall, skip ahead rather than crawl

var _acc: float = 0.0
var frame: int = 0


## How many logic steps to run for the time that has passed.
func tick(delta: float) -> int:
	_acc += delta
	var n := 0
	while _acc >= STEP and n < MAX_CATCHUP:
		_acc -= STEP
		n += 1
		frame += 1
	if _acc >= STEP:
		_acc = 0.0             # gave up catching up; drop the backlog
	return n
