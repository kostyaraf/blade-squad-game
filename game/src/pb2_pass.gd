extends RefCounted
class_name Pb2Pass

## $9672 -- the screen a password is typed on, pair nought.
##
## The reading is in `work/re/pb2_password.md`.  Twelve places with an octal
## digit in each, a caret between them, and on START a verdict: either the
## game starts with what the password named, or the screen says no and comes
## up again empty.
##
## The screen has fourteen steps in $19, and only six of them are typing:
## nought raises it, one is typed on, two counts out and three leaves, and
## twelve and thirteen are the same two after a password that was refused.
## The other eight are the same screen the other way about -- the game naming
## a password back to the player (Э7.7).  Four raises it, five puts the caret
## up, six is chosen on, seven acts on the choice, eight lays the field out,
## nine writes the twelve digits, ten stands until START and eleven leaves for
## the title screen.  Nothing but the end of the game reaches them: $D050 asks
## how many lives are left and $D090 puts this screen up at its fourth step.

## $9693 -- the two streams: nought fills both pages and $16 lays the screen
## over the first of them.  The numbers are already doubled ($CB4C).
const WIPE := 0x00
## $42/$43 and $44..$47 -- the four kilobytes of background and the four of
## sprites, out of `password.json` so that nothing here is typed by hand.

## One page and the whole of it: the screen stands still.
const WIDTH := 32
const HEIGHT := 30

## $19 -- the steps this port carries, numbered as the cartridge numbers them.
const RAISE := 0
const TYPING := 1
const COUNT := 2
const LEAVE := 3
const NO_COUNT := 12
const NO_BACK := 13
## $9760..$981A -- and the eight of the showing half.
const SHOW_RAISE := 4
const SHOW_WAIT := 5
const SHOW_PICK := 6
const SHOW_ACT := 7
const SHOW_FIELD := 8
const SHOW_DIGITS := 9
const SHOW_HOLD := 10
const SHOW_DONE := 11

## $9723 -- how long the screen stands after a password that was taken, and
## $96F2 -- after one that was refused.
const GOOD_WAIT := 0x32
const BAD_WAIT := 0x40

## $48 -- the pad as the cartridge orders it.  The screen reads six of the
## eight and START before any of them.
const START := 0x10
const RIGHT := 0x01
const LEFT := 0x02
const DOWN := 0x04
const UP := 0x08
const B := 0x40
const A := 0x80
## $9848 -- and the one button only the showing half reads.
const SELECT := 0x20

## $96B9 -- the screen is up, $990F -- the caret walked, $98E7/$98FC -- a digit
## was turned, $96EA -- the password was refused, $9713 -- it was taken.
const UP_SOUND := 0x43
const MOVED_SOUND := 0x39
const TURNED_SOUND := 0x1D
const NO_SOUND := 0x31
const YES_SOUND := 0x28
## $977E -- the showing screen going up, and $97CD -- the row of it that shows
## no password at all.
const SHOW_SOUND := 0x48
const BACK_SOUND := 0x29

## $96ED -- the queued stream the refusal writes over the middle row of the
## field, which is stream seven of the table at $CD28.
const NO_STREAM := 7
## $9784 and $97AC -- and the two the showing half writes: the words of the
## screen over an empty page, and the two rows the choice is made on.
const SHOW_STREAM := 9
const PICK_STREAM := 8

## $9745 and $974F -- where the screen goes once the password was taken: the
## screen a stage is picked on, or, with all five stages behind him, the one
## after it.
const GOES_TO := 3
const GOES_TO_ALL := 4
## $9707 -- and the stage the game is started at, by the same test.
const ALL_DONE := 0x1F
const STAGE_ALL := 5
## $9822 -- and where the showing half leaves for, which is $18 := 0: the
## title screen, with everything this screen carried put back to nought.
const SHOWN_GOES_TO := 0
## $9788 -- what the raising of the showing half leaves in $50.  It is the
## wait the row that shows no password walks out through: $97D8 puts $19 to
## two and never touches $50, so the count that runs down there is this one.
const PICK_WAIT := 1

## $80E1 -- the fade takes a step every sixteenth picture and nothing on the
## fifteen between.
const FADE_EVERY := 0x0F
const DARK := 0x0F

var page_image: Image
var palette := PackedByteArray()
var banks: Array = []
var spr_banks: Array = []
var slots: Array = []

var step_no := TYPING             ## $19
var spot := 0                     ## $51 -- which place the caret is at
var wait := 0                     ## $50
var choice := 0                   ## $4F -- which of the two rows is chosen
var clock := 0                    ## $1C -- the console's own count of pictures

## $0690..$069B -- the twelve digits as they stand on the screen, and
## $0680..$068B -- the same field laid out, which is where the password is
## really read.  Both are kept because both are what the cartridge keeps: the
## verdict works in them and leaves them changed whichever way it went.
var field := PackedByteArray()
var laid := PackedByteArray()
## $06A0..$06A5 -- the code, the four bytes that have to be nought, and the
## sum.
var found := PackedByteArray()

## $5B and $56 -- what the password said, once one has been taken.  Both stand
## at nought until then, which is where the switch being turned on left them
## ($C9E1 wipes $48..$EF) and where step eleven puts them back.
var cleared := 0
var suits := 0
var stage := 0                    ## $53
var area := 0                     ## $9C
var taken := -1
## $9749 -- and which step of that screen it is entered at, because the screen
## a stage is picked on is not entered at its first.
var next_step := 0

var _doc: Dictionary
var _pass: Dictionary
var _page := PackedByteArray()


## `show` is the other half: the game naming a password back instead of the
## player typing one in.  What it names is handed in, because the screen has
## nothing of its own to name -- $5B and $56 are the game's.
##
## Either half raises itself here, one picture sooner than the cartridge does:
## the picture before a raising is spent on nothing but the step number, and
## this port has no picture to spend on that.
func _init(show := false, cleared_ := 0, suits_ := 0) -> void:
	_doc = Nes._load_json(Nes.DATA + "/pb2/screens.json")
	_pass = Nes._load_json(Nes.DATA + "/pb2/password.json")
	var bg: Array = _pass["bg"]
	banks = [int(bg[0]) * 2, int(bg[0]) * 2 + 1,
			int(bg[1]) * 2, int(bg[1]) * 2 + 1]
	var sp: Array = _pass["spr"]
	spr_banks = [int(sp[0]), int(sp[1]), int(sp[2]), int(sp[3])]
	field.resize(int(_pass["places"]))
	laid.resize(int(_pass["places"]))
	found.resize(6)
	if show:
		cleared = cleared_                         # $5B
		suits = suits_                             # $56
		_show_raise()
		return
	_raise()


## $9693 -- the screen put up, which is also what the going back after a
## refusal does: the picture, the colours, an empty field and the caret at the
## first place.
func _raise() -> void:
	_paint()
	_place()
	spot = 0                                       # $96BC
	for i in range(field.size()):                  # $99F7
		field[i] = 0
	for i in range(laid.size()):                   # $99EB
		laid[i] = 0
	for i in range(found.size()):
		found[i] = 0
	Pb2Sound.hush()                                # $96AF
	Pb2Sound.want(UP_SOUND)                        # $96B2
	_caret()                                       # $9914
	step_no = TYPING


## $96AC and $96A7 -- the wipe and then the screen over it, and the colours
## record $803E is handed.
## `with_screen` is false where $C882 is called and $C84C is not: the raising
## of the showing half leaves the page filled and writes its words into it out
## of the queue instead.  `with_colours` is false where $803E is not called
## either: $97E1 raises the field screen while the screen is dark and leaves it
## dark, and it is the twelfth digit that lights it up again ($9807).
func _paint(with_screen := true, with_colours := true) -> void:
	_page.resize(0x400)
	for i in range(_page.size()):
		_page[i] = 0
	var draw: Array = [WIPE]
	if with_screen:
		draw.append(int(_pass["screen"]))
	for which in draw:
		for s in _doc["screens"]:
			if int(s["x"]) != which:
				continue
			for b in s["blocks"]:
				var at: int = int(b["addr"])
				# The wipe fills both pages; only the first is shown.
				if at >= 0x2400:
					continue
				var o: int = at - 0x2000
				var t: Array = b["tiles"]
				for k in range(t.size()):
					_page[o + k] = int(t[k])
	page_image = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	for ty in range(HEIGHT):
		for tx in range(WIDTH):
			_draw(ty * WIDTH + tx)
	if with_colours:
		_colours()


## $803E -- the colours record $15, which both halves are handed.
func _colours() -> void:
	palette = PackedByteArray(_doc["palettes"][int(_pass["palette"])])


## One cell of the page onto the picture: the tile, and the two bits of colour
## the quarter of the block it stands in gives it.
func _draw(o: int) -> void:
	var tx: int = o % WIDTH
	var ty: int = o / WIDTH
	var at: int = _page[0x3C0 + (ty / 4) * 8 + tx / 4]
	var quad: int = ((ty % 4) / 2) * 2 + ((tx % 4) / 2)
	page_image.set_pixel(tx, ty,
			Color8(_page[o], (at >> (quad * 2)) & 3, 0, 255))


## $9940 -- one place drawn: the digit is two tiles across and two down, and
## the second row is a whole name-table row further on.  The cartridge puts it
## in the queue at $0300 for the next blank to push out; here it goes onto the
## page, which is the same thing one picture sooner.
func _digit(i: int) -> void:
	var tiles: Array = _pass["digit"][field[i]]
	var at: int = int(_pass["where"][i])
	var step: int = int(_pass["where_step"])
	for half in range(2):
		var o: int = at + half * step - 0x2000
		for k in range(2):
			_page[o + k] = int(tiles[half * 2 + k])
			_draw(o + k)


## $9914 -- the caret, which is the nought-th place with nothing thinking
## behind it: three fields written and $0400 never set at all.
func _place() -> void:
	slots = []
	for i in range(Pb2Objects.SLOTS):
		var one := PackedByteArray()
		one.resize(Pb2Objects.FIELDS)
		slots.append(one)


func _caret() -> void:
	var one: PackedByteArray = slots[0]
	one[Pb2Objects.F_KIND] = int(_pass["caret_kind"])
	one[Pb2Objects.F_X] = int(_pass["caret_x"][spot])
	one[Pb2Objects.F_Y] = int(_pass["caret_y"][spot])


## $C813 = $D746 -- every place wiped, which is what the refusal does once it
## has said no.
func _wipe() -> void:
	for one in slots:
		for i in range(one.size()):
			one[i] = 0


## One picture of the screen.  `pad` is $48, the first player's newly pressed.
##
## What comes back is the screen it leaves for ($18), or -1 while it stays.
func step(pad: int) -> int:
	# $CD5A -- the console's own count, which the fade steps by.
	clock = (clock + 1) & 0xFF
	match step_no:
		RAISE:
			# $9693 -- the screen put up, which is a picture of its own: the
			# step before it only puts $19 back to nought, and the raising
			# runs on the picture after.
			_raise()
		TYPING:
			_typing(pad)
		COUNT, NO_COUNT:
			# $972A -- DEC $50 and nothing else until it runs out.
			wait = (wait - 1) & 0xFF
			if wait == 0:
				step_no += 1
		LEAVE:
			# $9732 -- and out, once the screen has gone dark.
			if _fade():
				return _out()
		NO_BACK:
			# $9835 -- the same wait for the dark, and then $19 := 0, which
			# is the raising all over again on the picture after this one.
			if _fade():
				step_no = RAISE
		SHOW_WAIT:
			_show_wait()
		SHOW_PICK:
			_show_pick(pad)
		SHOW_ACT:
			_show_act()
		SHOW_FIELD:
			# $97E1 -- nothing at all until the screen has gone dark.
			if _fade():
				_show_field()
		SHOW_DIGITS:
			_show_digit()
		SHOW_HOLD:
			# $9810 -- and it stands here as long as it is looked at.
			if (pad & START) != 0:
				step_no = SHOW_DONE
		SHOW_DONE:
			# $981A -- the same dark again, and then the title screen.
			if _fade():
				return _show_out()
	return -1


## $9760 -- the showing screen put up.  There is no screen out of $CBCC here at
## all: $C882 fills both pages and everything that stands on the first of them
## is the queued stream, which is why the raising takes no $C84C.
##
## Step four is the step $D096 writes, so nothing in this class reaches
## `SHOW_RAISE` -- it is raised in the making, the way the typing half is.
func _show_raise() -> void:
	_paint(false)                                  # $9772 and $C882
	_place()                                       # $D098 = $D746
	Pb2Sound.hush()                                # $977B
	Pb2Sound.want(SHOW_SOUND)                      # $977E
	_queue(SHOW_STREAM)                            # $9784
	wait = PICK_WAIT                               # $9788
	choice = 0                                     # $979E
	step_no = SHOW_WAIT


## $97A7 -- the two rows the choice is made on, and the caret on the first of
## them.
##
## The cartridge waits here for $C8, which is the queue emptying into a
## blanking; this port's queue goes onto the page as it is asked for, so there
## is nothing to wait for and this is the picture after the raising.
func _show_wait() -> void:
	_queue(PICK_STREAM)                            # $97AC
	_show_caret()                                  # $985D
	step_no = SHOW_PICK


## $985D -- the caret of the showing half.  It is a different picture from the
## typing one ($5A and not $59), it stands at one place along, and which of the
## two rows it is on is $4F.  Its thinking field is left alone here too.
func _show_caret() -> void:
	var one: PackedByteArray = slots[0]
	one[Pb2Objects.F_KIND] = int(_pass["shown_kind"])
	one[Pb2Objects.F_X] = int(_pass["shown_x"])
	one[Pb2Objects.F_Y] = int(_pass["shown_y"][choice])


## $983F -- the choosing.  $48 is shifted five times for START and once more
## for SELECT, so only one of the two can be the newly pressed one.
func _show_pick(pad: int) -> void:
	if (pad & START) != 0:                         # $9846
		step_no = SHOW_ACT
	elif (pad & SELECT) != 0:                      # $9849
		Pb2Sound.want(MOVED_SOUND)                 # $984F
		choice ^= 1                                # $9856
		_show_caret()


## $97BA -- what was chosen.  The lower row shows the password; the upper one
## leaves the way a password that was taken leaves, through the same wait and
## the same step three.
func _show_act() -> void:
	Pb2Sound.hush()                                # $97BE or $97CA
	if choice != 0:
		for i in range(laid.size()):               # $99EB
			laid[i] = 0
		for i in range(field.size()):              # $99F7
			field[i] = 0
		for i in range(found.size()):
			found[i] = 0
		step_no = SHOW_FIELD
		return
	# $97CD -- and out.  $50 is not written here: what runs down is the one
	# the raising left ($9788), which is why it is a wait of one.
	Pb2Sound.want(BACK_SOUND)
	choice = 0                                     # $97D6
	step_no = COUNT                                # $97D8


## $97E1 -- the field screen raised, dark, and the password put together on it.
func _show_field() -> void:
	_paint(true, false)                            # $C882 and $16 over it
	_place()                                       # $C813 = $D746
	spot = 0                                       # $97F1
	_pack()                                        # $9A1C
	step_no = SHOW_DIGITS


## $97FC -- one digit a picture, and on the twelfth the colours again, which is
## what lights the screen back up after $97E1 left it dark.
func _show_digit() -> void:
	_digit(spot)                                   # $9872 -> $9940
	spot += 1                                      # $97FF
	if spot < field.size():                        # $9803
		return
	_colours()                                     # $9807
	step_no = SHOW_HOLD


## $9A1C -- the password put together, which is the verdict run backwards and
## through the same tables.  The cartridge has two copies of this, one for the
## code $1F and one for every other, and they are byte for byte the same
## ($9A25 and $9A58).
##
## The seven places the code and the suits do not live in stay nought, and so
## do the four bytes of score: this game never fills them, which is why the
## verdict refuses a password whose score is not nought ($9D6C).
func _pack() -> void:
	laid[7] = (cleared & 0x03) << 1                # $9A26
	laid[9] = (cleared & 0x0C) >> 1                # $9A2D
	laid[11] = (cleared & 0x10) >> 2               # $9A35
	laid[8] = (suits & 0x03) << 1                  # $9A3F
	laid[10] = (suits & 0x0C) >> 1                 # $9A47
	_sum_in()                                      # $9A8A
	_shuffle()                                     # $9B21
	_shift()                                       # $9AE9


## $9A8A -- the sum of all twelve, laid into the low bit of the last six
## places.  Those low bits are all nought when it is taken, which is why it is
## the same sum $9C2B works out with them masked away.
##
## The sum itself is kept in $00 here and not in $06A5, where the verdict
## leaves it: the two halves of the codec do not share that cell.
func _sum_in() -> void:
	var s := 0
	for v in laid:
		s = (s + v) & 0xFF
	for i in range(5):
		laid[6 + i] |= (s >> i) & 1
	laid[11] |= (s & 0x60) >> 5


## $9B21 -- the shuffle: the i-th place of the screen is the perm[i]-th of the
## laid-out field, which is $9BFC read the other way about.
func _shuffle() -> void:
	var perm: Array = _pass["perm_odd"] if cleared == ALL_DONE \
			else _pass["perm"][cleared & 0x0F]
	for i in range(field.size()):
		field[i] = laid[int(perm[i])]


## $9AE9 -- and the offset of each place put on, which $9B09 takes off again.
func _shift() -> void:
	var off: Array = _pass["offset"]
	for i in range(field.size()):
		field[i] = (field[i] + int(off[i])) & 0x07


## $981A -- and out.  $18 := 0 is the title screen, and the game starts over:
## everything this screen carried goes back to nought, including the stages
## and the suits it has just named.
##
## Four more cells it puts back the port has nowhere for -- $2B, $2C, $57 and
## the $1A, $27 and $98 of the row that showed nothing ($97D2) -- because they
## belong to the level the game was playing and not to this screen.
func _show_out() -> int:
	cleared = 0                                    # $9826
	suits = 0                                      # $9828
	stage = 0                                      # $9830
	_wipe()                                        # $C813
	taken = SHOWN_GOES_TO
	next_step = 0
	return taken


## $96CE -- the screen while it is typed on.
func _typing(pad: int) -> void:
	if (pad & START) != 0:
		_verdict()
		return
	_buttons(pad)


## $987A -- the six buttons the field is walked and turned with, in the order
## the cartridge shifts them out of $48.  Only one of them can be the newly
## pressed one this picture, because the shifts stop at the first that is.
func _buttons(pad: int) -> void:
	var last: int = field.size() - 1
	if (pad & RIGHT) != 0:                             # $9891
		spot = 0 if spot == last else spot + 1
		_walked()
	elif (pad & LEFT) != 0:                            # $98A3
		spot = last if spot == 0 else spot - 1
		_walked()
	elif (pad & DOWN) != 0:                            # $98B3
		# The step down is four, and off the bottom it is four more and the
		# low nibble kept, which is the same row one place further along.
		spot += 4
		if spot >= field.size():
			spot = (spot + 4) & 0x0F
		_walked()
	elif (pad & UP) != 0:                              # $98CD
		spot -= 4
		if spot < 0:
			spot = ((spot & 0xFF) & 0x0F) - 4
		_walked()
	elif (pad & B) != 0:                               # $98E5
		Pb2Sound.want(TURNED_SOUND)
		field[spot] = (field[spot] - 1) & 0x07
		_digit(spot)
	elif (pad & A) != 0:                               # $98FA
		Pb2Sound.want(TURNED_SOUND)
		field[spot] = (field[spot] + 1) & 0x07
		_digit(spot)


## $990F -- the caret walked: heard, and then put where it now stands.
func _walked() -> void:
	Pb2Sound.want(MOVED_SOUND)
	_caret()


## $96D7 -- START, and the password is judged.
func _verdict() -> void:
	# $96D7 -- the caret's picture goes out before the judging, and its other
	# two fields are left standing.
	slots[0][Pb2Objects.F_KIND] = 0
	if not _good():
		# $96E1 -- the press is forgotten, the screen says no over the middle
		# row of the field, and after $40 pictures it goes dark and comes back.
		Pb2Sound.hush()
		Pb2Sound.want(NO_SOUND)
		_queue(NO_STREAM)
		wait = BAD_WAIT
		step_no = NO_COUNT
		_wipe()
		return
	# $96FD -- and taken: what it said, and where the game starts.
	_unpack()
	stage = STAGE_ALL if cleared == ALL_DONE else 0    # $9700
	area = 0                                           # $970C
	Pb2Sound.hush()
	Pb2Sound.want(YES_SOUND)                           # $9713
	var one: PackedByteArray = slots[0]                # $9718
	one[Pb2Objects.F_X] = 0
	one[Pb2Objects.F_Y] = 0
	one[Pb2Objects.F_KIND] = 0
	wait = GOOD_WAIT
	step_no = COUNT


## $CCBC -- one queued stream onto the page.  The refusal is the one stream
## this screen plays, and it stands until the screen is put up again.
func _queue(which: int) -> void:
	for b in _doc["queued"][which]["blocks"]:
		var at: int = int(b["addr"])
		if at < 0x2000 or at >= 0x2400:
			continue
		var t: Array = b["tiles"]
		for i in range(t.size()):
			var o: int = at - 0x2000 + i
			_page[o] = int(t[i])
			_draw(o)


## $9A03 -- the verdict itself.  Five things in order, and the first that
## fails is the answer; everything it does to the field it leaves done,
## because that is what the cartridge leaves behind it too.
func _good() -> bool:
	_unshift()                                         # $9B09
	_lay_out()                                         # $9BC4
	if not _sum_agrees():                              # $9C2B
		return false
	if not _noughts():                                 # $9CCF
		return false
	return _spare_is_nought()                          # $9D6C


## $9B09 -- the offset of each place taken off the digit standing there.  It is
## written back into the field, so a password once judged is no longer the
## password that was typed.
func _unshift() -> void:
	var off: Array = _pass["offset"]
	for i in range(field.size()):
		field[i] = (field[i] - int(off[i])) & 0x07


## $9BC4 -- the code, which is read out of three places of the field before
## the shuffle is known, and then the shuffle itself.
func _lay_out() -> void:
	var c: int = ((field[8] & 6) >> 1) | ((field[6] & 6) << 1) \
			| ((field[11] & 4) << 2)
	found[0] = c
	var perm: Array = _pass["perm_odd"] if c == ALL_DONE \
			else _pass["perm"][c & 0x0F]
	for i in range(field.size()):
		laid[int(perm[i])] = field[i]


## $9C2B -- the sum, which is taken over the bits of the field that do not
## carry the sum themselves, and then found again in the low bits of the last
## six places.
func _sum_agrees() -> bool:
	var s := 0
	for i in range(6):
		s = (s + laid[i]) & 0xFF
	for i in range(6, 11):
		s = (s + (laid[i] & 6)) & 0xFF
	s = (s + (laid[11] & 4)) & 0xFF
	found[5] = s
	for i in range(5):
		if ((s >> i) & 1) != (laid[6 + i] & 1):
			return false
	return ((s & 0x60) >> 5) == (laid[11] & 3)


## $9CCF -- what a password is not allowed to say.  With all five stages
## behind him seven pieces of the field have to be nought; otherwise the fifth
## bit of the code cannot stand on its own.
func _noughts() -> bool:
	if found[0] != ALL_DONE:
		return (found[0] & 0x10) == 0
	return (laid[0] & 2) == 0 and (laid[1] & 6) == 0 \
			and (laid[2] & 6) == 0 and (laid[3] & 2) == 0 \
			and (laid[4] & 2) == 0 and (laid[5] & 6) == 0 \
			and (laid[6] & 4) == 0


## $9D6C -- and the four bytes the field has room for and this game never
## fills: the score.  All four have to come out nought.
func _spare_is_nought() -> bool:
	if found[0] == ALL_DONE:
		_spare_all()                                   # $9E52
	else:
		_spare_some()                                  # $9DAA
	return found[1] == 0 and found[2] == 0 and found[3] == 0 \
			and found[4] == 0


## $9DAA -- the score as it is packed when not every stage is behind him.
func _spare_some() -> void:
	found[1] = (((laid[0] & 6) >> 1) | ((laid[1] & 6) << 1)
			| ((laid[2] & 6) << 3) | ((laid[3] & 4) << 4)) & 0xFF
	found[3] = (((laid[6] & 6) >> 1) | ((laid[5] & 6) << 1)
			| ((laid[4] & 6) << 3) | ((laid[3] & 2) << 5)) & 0xFF
	found[2] = ((laid[0] & 1) | ((laid[1] & 1) << 1)
			| ((laid[2] & 1) << 2)) & 0xFF
	found[4] = ((laid[3] & 1) | ((laid[4] & 1) << 1)
			| ((laid[5] & 1) << 2)) & 0xFF


## $9E52 -- and as it is packed when every one of them is.
func _spare_all() -> void:
	found[1] = ((laid[0] & 4) << 5) & 0xFF
	found[3] = ((laid[4] & 4) << 5) & 0xFF
	found[2] = ((laid[0] & 1) | ((laid[1] & 1) << 1)
			| ((laid[2] & 1) << 2) | ((laid[3] & 4) << 1)) & 0xFF
	found[4] = ((laid[3] & 1) | ((laid[4] & 1) << 1)
			| ((laid[5] & 1) << 2) | ((laid[6] & 2) << 2)) & 0xFF


## $9D12 -- what the password said: which stages are behind him and which
## suits he has found.  The score is the four bytes above, and they are nought
## or the password would not have been taken at all.
func _unpack() -> void:
	cleared = found[0]
	suits = ((laid[8] & 6) >> 1) | ((laid[10] & 6) << 1)


## $80D9 -- the screen going dark, a step every sixteenth picture.  A colour
## already at $0F is left alone; otherwise $80EE keeps the two bits of
## brightness and throws the hue away ($29 30), and what is left either loses
## $10 or, if there was no brightness to lose, goes straight to $0F.  So the
## first step of the fade greys the whole screen and the steps after it only
## darken: $37 goes $20, $10, $0F and not $27, $17, $07.
##
## It is done when all thirty-two are $0F, which is what $8106 answers, and
## that is asked before the count is looked at, so the picture the fade
## finishes on is not the picture it is done on.
func _fade() -> bool:
	var done := true
	for i in range(palette.size()):
		if palette[i] != DARK:
			done = false
			break
	if done:
		return true
	if (clock & FADE_EVERY) != 0:
		return false
	for i in range(palette.size()):
		var v: int = palette[i]
		if v == DARK:
			continue
		palette[i] = ((v & 0x30) - 0x10) if (v & 0x30) != 0 else DARK
	return false


## $9737 -- the screen it leaves for, once it has gone dark, and the step of
## that screen it is entered at.
##
## Two things it does here the port has nowhere to put: $9F := 2 and
## $049A := $10, which belong to the screen a stage is picked on ($859D) and
## not to this one.  They are a debt of Э3.10b along with the rest of that
## screen.
func _out() -> int:
	if cleared == ALL_DONE:
		taken = GOES_TO_ALL                            # $974F
		next_step = 0
	else:
		taken = GOES_TO                                # $9745
		next_step = 0x14                               # $9749
	return taken
