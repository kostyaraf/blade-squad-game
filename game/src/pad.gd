extends RefCounted
class_name Pad

## One player's controller, read the way the console read it: eight buttons,
## and for each of them whether it is down and whether it went down this frame.

const A := 0x80
const B := 0x40
const SELECT := 0x20
const START := 0x10
const UP := 0x08
const DOWN := 0x04
const LEFT := 0x02
const RIGHT := 0x01

var held: int = 0
var pressed: int = 0          # newly down this frame
## A stand has no keys, so it hands the word over instead of pressing it:
## anything but -1 is read in place of the console's own two reads.  What is
## handed over is taken as the console would have reported it, cleaned up
## already -- a stand that hands left and right at once is saying the
## cartridge saw both, which it could not.
var handed: int = -1
var _keys: Dictionary
var _device: int


func _init(keys: Dictionary, device: int) -> void:
	_keys = keys
	_device = device


func poll() -> void:
	if handed >= 0:
		pressed = handed & ~held
		held = handed
		return
	var now := 0
	for bit in _keys:
		if Input.is_key_pressed(_keys[bit]):
			now |= bit
	if _device >= 0 and Input.get_connected_joypads().has(_device):
		if Input.is_joy_button_pressed(_device, JOY_BUTTON_A): now |= A
		if Input.is_joy_button_pressed(_device, JOY_BUTTON_X): now |= B
		if Input.is_joy_button_pressed(_device, JOY_BUTTON_BACK): now |= SELECT
		if Input.is_joy_button_pressed(_device, JOY_BUTTON_START): now |= START
		if Input.is_joy_button_pressed(_device, JOY_BUTTON_DPAD_UP): now |= UP
		if Input.is_joy_button_pressed(_device, JOY_BUTTON_DPAD_DOWN): now |= DOWN
		if Input.is_joy_button_pressed(_device, JOY_BUTTON_DPAD_LEFT): now |= LEFT
		if Input.is_joy_button_pressed(_device, JOY_BUTTON_DPAD_RIGHT): now |= RIGHT
		var ax := Input.get_joy_axis(_device, JOY_AXIS_LEFT_X)
		var ay := Input.get_joy_axis(_device, JOY_AXIS_LEFT_Y)
		if ax < -0.5: now |= LEFT
		if ax > 0.5: now |= RIGHT
		if ay < -0.5: now |= UP
		if ay > 0.5: now |= DOWN
	# The console cannot report left and right at once; neither do we, because
	# both games lean on that when they read the stick.
	if (now & LEFT) != 0 and (now & RIGHT) != 0:
		now &= ~RIGHT
	if (now & UP) != 0 and (now & DOWN) != 0:
		now &= ~DOWN
	pressed = now & ~held
	held = now


static func player_one() -> Pad:
	return Pad.new({
		A: KEY_X, B: KEY_Z, SELECT: KEY_SHIFT, START: KEY_ENTER,
		UP: KEY_UP, DOWN: KEY_DOWN, LEFT: KEY_LEFT, RIGHT: KEY_RIGHT,
	}, 0)


static func player_two() -> Pad:
	return Pad.new({
		A: KEY_APOSTROPHE, B: KEY_SEMICOLON, SELECT: KEY_TAB, START: KEY_Q,
		UP: KEY_W, DOWN: KEY_S, LEFT: KEY_A, RIGHT: KEY_D,
	}, 1)
