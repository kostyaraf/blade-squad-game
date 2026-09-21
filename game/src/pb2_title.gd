extends RefCounted
class_name Pb2Title

## $ED7B -- the screen Power Blade 2 opens on.
##
## The reading is in `work/re/pb2_level_flow.md`.  It is the nought-th of the
## nine screens of bank fifteen and the only one of them that lives in that
## bank itself, without a jump into pair nought; the step inside it is $19, as
## everywhere else in this game.
##
## Four steps and nothing more: the screen goes up, it waits, it is lived on,
## and it goes out.  What the port carries here is all four of them, the caret
## and the two requests for sound; the picture is the stream the cartridge
## plays, taken out of `screens.json` like every other flat screen.

## $CB2B -- two streams: nought out of the fixed bank fills both pages, and
## four lays the picture over the first of them.  The numbers are already
## doubled, which is how $CB4C reads them.
const WIPE := 0x00
const SCREEN := 0x04
## $ED9D -> $803E with A = 0.
const PALETTE := 0
## $ED85 -- $42/$43, the background's two kilobytes each, number doubled.
const BG := [0x26, 0x27]
## $ED8C, $ED93 -- $44/$45 and $46/$47.  This screen sets all four, unlike the
## screen a stage is picked on, which leaves the last two alone.
const SPR := [0x00, 0x01, 0x10, 0x10]

## One page, and the whole of it: the title stands still and nothing scrolls.
const WIDTH := 32
const HEIGHT := 30

## $EEED -- where down the screen the caret goes, by the row it stands on.
const CARET_Y := [0x7A, 0x82]
## $EEE2, $EEE7 -- and it stands in the one place, whichever row it is on.
const CARET_X := 0x80
const CARET_KIND := 0x5A
## The caret is the nought-th place and nothing else is on the screen.
const CARET_SLOT := 0

## $19 -- which of the screen's four steps is running.
const RAISE := 0
const WAIT := 1
const LIVE := 2
const LEAVE := 3

## $EDA3 and $EED0 -- the count the screen waits out and the one it is lived
## on with, low byte first: $EED4 writes both of them.
const FIRST_WAIT := [0x80, 0x00]
const LIVE_WAIT := [0x00, 0x01]
## $EDFB -- and the going out writes the low byte alone, leaving the high one
## wherever the standing stopped, because $EE12 counts the low one down by
## itself and never borrows.
const LEAVE_WAIT := 0x80

## $EE1A -- and the row that was taken blinks out of the other table of
## streams, the one $CCBC queues: stream nought is START and stream one is
## CONTINUE, which is to say one stream to a row, numbered by $22 itself.
## $EE14 -- bit three of the count says which of the two pictures is up, so it
## turns over every eight, and $CCE7 draws the stream with its tiles set to
## nought when the number handed over came out negative.
const BLINK_BIT := 0x08

## $EDDE -- the caret was moved.
const MOVED_SOUND := 0x39
## $EE04 -- START was taken and the game is his.
const TAKEN_SOUND := 0x29

## $48 -- the pad as the cartridge orders it.
const START := 0x10
const SELECT := 0x20
## $EDE9 -- and the three that send him somewhere else entirely.  They are
## read out of $4B, which is the *second* player's held buttons ($EBCC writes
## $48,X and $4A,X for X of nought and one), so the way out through the code
## takes two pads: START on the first and these three on the second.
const CHEAT := 0x80 | 0x40 | 0x02

## $18 -- which screen it leaves for, by the row that was taken.  Nought is
## $8009 = $859D, the screen a stage is picked on; one is $8018 = $9672, the
## screen a password is typed on, which this port does not have -- see
## `work/re/pb2_level_flow.md`.
const GOES_TO := [3, 2]
## $EE0C -- and where A+B+LEFT on START goes instead.
const CHEAT_TO := 0x08
## $EDB0 -> $EEB0 -- nobody pressed anything for long enough, and INC $18
## takes it to the screen next along, which is $EE31: the game showing itself
## off.  It is a screen and not a row, so no row leads to it.
const BORED_TO := 1

var page_image: Image
var palette := PackedByteArray()
var banks: Array = []             ## the four kilobytes of background
var spr_banks: Array = []         ## and the four of sprites
var slots: Array = []             ## the twenty-two places, for Pb2Sprites

var step_no := RAISE              ## $19
var row := 0                      ## $22 -- which row the caret stands on
var low := 0                      ## $52
var high := 0                     ## $53
var taken := -1                   ## the screen it settled for, once it has

var _doc: Dictionary
## The page as it stands, kept because the going out changes a word of it.
var _page := PackedByteArray()


func _init() -> void:
	_doc = Nes._load_json(Nes.DATA + "/pb2/screens.json")
	banks = [BG[0] * 2, BG[0] * 2 + 1, BG[1] * 2, BG[1] * 2 + 1]
	spr_banks = [SPR[0], SPR[1], SPR[2], SPR[3]]
	_paint()
	_place()
	# $EDA3 -- the screen is up, and step one waits it out.
	low = FIRST_WAIT[0]
	high = FIRST_WAIT[1]
	step_no = WAIT


## $ED9D and $EDA0 -- the picture, once: the wipe and then the title over it.
func _paint() -> void:
	# The page itself, because the going out changes a word of it and every
	# picture is drawn from it: a row of bytes is a value here, so what is
	# filled in is the field and not a copy of it.
	_page.resize(0x400)
	for which in [WIPE, SCREEN]:
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
				for i in range(t.size()):
					_page[o + i] = int(t[i])
	page_image = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	for ty in range(HEIGHT):
		for tx in range(WIDTH):
			_draw(ty * WIDTH + tx)
	palette = PackedByteArray(_doc["palettes"][PALETTE])


## One cell of the page onto the picture: the tile, and the two bits of colour
## the quarter of the block it stands in gives it.
func _draw(o: int) -> void:
	var tx: int = o % WIDTH
	var ty: int = o / WIDTH
	var at: int = _page[0x3C0 + (ty / 4) * 8 + tx / 4]
	var quad: int = ((ty % 4) / 2) * 2 + ((tx % 4) / 2)
	page_image.set_pixel(tx, ty,
			Color8(_page[o], (at >> (quad * 2)) & 3, 0, 255))


## $CCBC -- one queued stream played onto the page.  `blank` is the high bit of
## the number the cartridge handed over: the address is kept and the tiles go
## out as nought, which is how the blinking takes a word away again.
func _queue(which: int, blank: bool) -> void:
	for b in _doc["queued"][which]["blocks"]:
		var at: int = int(b["addr"])
		# Only the first page is shown, and every stream this screen plays is
		# on it; a stream that were not would be a stream for another screen.
		if at < 0x2000 or at >= 0x2400:
			continue
		var t: Array = b["tiles"]
		for i in range(t.size()):
			var o: int = at - 0x2000 + i
			_page[o] = 0 if blank else int(t[i])
			_draw(o)


## $EED9 -- the caret, which is a place with nothing thinking behind it: three
## fields written and the type ($0400) never set at all.
func _place() -> void:
	slots = []
	for i in range(Pb2Objects.SLOTS):
		var one := PackedByteArray()
		one.resize(Pb2Objects.FIELDS)
		slots.append(one)
	_caret()


func _caret() -> void:
	var one: PackedByteArray = slots[CARET_SLOT]
	one[Pb2Objects.F_Y] = CARET_Y[row]
	one[Pb2Objects.F_X] = CARET_X
	one[Pb2Objects.F_KIND] = CARET_KIND


## $EEEF -- and the caret taken away again.
func _unplace() -> void:
	var one: PackedByteArray = slots[CARET_SLOT]
	one[Pb2Objects.F_Y] = 0
	one[Pb2Objects.F_X] = 0
	one[Pb2Objects.F_KIND] = 0


## $EEBF -- the two-byte countdown, and whether it is still going.  The high
## byte is taken down only when the low one is about to borrow, which is what
## $EEC7 does.
func _counting() -> bool:
	if (low | high) == 0:
		return false
	if low == 0:
		high -= 1
	low = (low - 1) & 0xFF
	return true


## One picture of the screen.  `pad` is $48 as the cartridge keeps it -- the
## first player's newly pressed -- and `two` is $4B, the second player's held.
##
## What comes back is the screen it leaves for ($18), or -1 while it stays.
func step(pad: int, two: int = 0) -> int:
	match step_no:
		WAIT:
			# $EDB6 -- the wait runs out, and then the screen is lived on.
			if not _counting():
				step_no = LIVE
				low = LIVE_WAIT[0]
				high = LIVE_WAIT[1]
		LIVE:
			return _live(pad, two)
		LEAVE:
			return _leave()
	return -1


## $EDC5 -- the screen while it is lived on.
func _live(pad: int, two: int) -> int:
	# $EDC8 -- nobody pressed anything for long enough, and the game shows
	# itself off instead.  That screen is $EE31, which is $18 one on.
	if not _counting():
		_over()
		return BORED_TO
	if (pad & SELECT) != 0:
		# $EDD0 -- the caret walks between the two rows and nowhere else.
		row = (row + 1) & 0x01
		_caret()
		low = LIVE_WAIT[0]                             # $EDDB
		high = LIVE_WAIT[1]
		Pb2Sound.want(MOVED_SOUND)                     # $EDDE
	if (pad & START) == 0:
		return -1
	if (two & CHEAT) == CHEAT:
		# $EE09 -- A and B and LEFT held on the second pad while START goes
		# down on the first, and it goes elsewhere.
		Pb2Sound.hush()
		_over()
		return CHEAT_TO
	low = LEAVE_WAIT                                   # $EDFB
	step_no = LEAVE
	Pb2Sound.hush()                                    # $EE01
	Pb2Sound.want(TAKEN_SOUND)                         # $EE04
	return -1


## $EE12 -- the row that was taken blinks, and then the screen goes out.
func _leave() -> int:
	# $EE12 -- the count is read before it is spent, so the first picture of
	# the going out is drawn with $80, whose third bit is nought: the word is
	# there, and it is the blanking that comes second.
	_queue(row, (low & BLINK_BIT) != 0)
	low = (low - 1) & 0xFF
	if low != 0:
		return -1
	_unplace()                                         # $EEEF
	taken = GOES_TO[row]                               # $EE26
	_over()
	return taken


func _over() -> void:
	step_no = RAISE
