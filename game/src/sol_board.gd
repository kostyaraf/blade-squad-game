extends RefCounted
class_name SolBoard

## The board STAGE SELECT is played on, and what is written into it.
##
## Mode $19 ($DAE3) draws screen $13 -- five empty frames and the man below
## them -- and mode $1A ($DBAE) walks it up the screen out of $0B and then
## fills the frames one at a time.  Filling one is $DD84: six bytes of colour
## and six rows of eight tiles, all of it out of tables in the two banks the
## game always has.  `data/sol/board.json` is those tables; `sol_board.py`
## takes them out of the cartridge and `work/re/sol_flow.md` says how the mode
## uses them.
##
## Which picture a frame gets is not the frame's own number: $DDDE looks at
## $2D, the stages already done with, and a frame whose stage is done with is
## written back to nought, which is the empty frame.

## $DD52 and $DD4C -- where the pointer stands on each frame.
static var mark_x: Array = []
static var mark_y: Array = []
## $DD5E -- which frame the pointer is on; $DD58 -- which stage that frame is.
static var pick: Array = []
static var stage: Array = []
## $DDEF -- the two places a frame's colour goes, and how many bytes each
## takes; $DE27 -- where its tiles go.
static var attr_at: Array = []
static var attr_wide: Array = []
static var tiles_at: Array = []
## $DE35 -- where in the colour table a picture's six bytes begin; $DF17 three
## at a time and $DF2F two at a time.
static var attr_off: Array = []
static var attr3: Array = []
static var attr2: Array = []
## $E037 and the six after it -- six rows of eight tiles apiece.
static var art: Array = []
static var wide := 8
static var tall := 6


static func load_data() -> void:
	if not art.is_empty():
		return
	var j: Dictionary = Nes._load_json(Nes.DATA + "/sol/board.json")
	mark_x = j["mark_x"]
	mark_y = j["mark_y"]
	pick = j["pick"]
	stage = j["stage"]
	attr_at = j["attr_at"]
	attr_wide = j["attr_wide"]
	tiles_at = j["tiles_at"]
	attr_off = j["attr_off"]
	attr3 = j["attr3"]
	attr2 = j["attr2"]
	art = j["art"]
	wide = int(j["wide"])
	tall = int(j["tall"])


## $DD84 -- one frame written: `n` which frame, `pic` which picture.  The
## cartridge hands both through the queue at $0300 and the picture unit empties
## it at the top of the next picture; here they go straight into the board,
## which is the same thing a picture later.
static func write(host, n: int, pic: int) -> void:
	load_data()
	# $DEB3 -- the colour first, two places of it, out of whichever of the two
	# tables the frame's own byte asks for.
	var w: int = int(attr_wide[n])
	var src: Array = attr3 if w == 3 else attr2
	var k: int = int(attr_off[pic])
	for a in attr_at[n]:
		for i in range(w):
			host.flow_poke(int(a) + i, int(src[k]))
			k += 1
	# $DE64 -- then the tiles, a row of eight every thirty two.
	var block: Array = art[pic]
	var at: int = int(tiles_at[n])
	for row in range(tall):
		for col in range(wide):
			host.flow_poke(at + col, int(block[row * wide + col]))
		at += 0x20
