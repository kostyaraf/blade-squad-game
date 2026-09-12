extends RefCounted
class_name SolFlow

## What the game is doing this picture: the byte $02 and the ninety four things
## it can name.
##
## $F9CC calls $C9B4 once a picture, and $C9B4 does nothing but look $02 up in
## the table at $C9C1 and jump there.  Mode $00 is the stage being played and is
## the whole of the rest of the Solbrain port; the modes here are the ones that
## carry the game into a stage, out of it and back in again after a death.
##
## What is ported is what the modes do to the game's own state -- which mode
## comes next, which stage, how many tries are left, where the four pieces he
## arrives as are.  What is not ported is what they do to the console: the
## screen blanked and the two nametables wiped ($C578/$C5DA), the letters of
## GAME OVER and CONTINUE written into the background ($EC6C/$D9F1), the tune
## asked for ($F86D/$EF8C).  Those belong to the strip and the screens, which
## are their own debt; every place one of them stood is marked.
##
## The chain the cartridge walks from the switch being turned on, read off a
## run of the cartridge itself:
##
##     $00 $01 $03 $04 $05   the maker, the title, the tale
##     $12 $5C $5D           the telling
##     $06 $07 $3A $3B $3C $3D $5B   picking a stage
##     $19 $1D $3E $3F $00   the stage raised, he arrives, and it is played
##
## and after he is killed, with a try left:
##
##     $00 $1D $3E $3F $00
##
## `work/re/sol_flow.md` is the whole account.


## The modes this ports.
const PLAY := 0x00          # $CD57 -- one picture of a stage
const OVER := 0x14          # $D974 -- no tries left
const OVER_WAIT := 0x15     # $DA52 -- and what waits there
const PICK := 0x19          # $DAE3 -- the stage picked, on the way in
const CHOSEN := 0x1A        # $DBAE -- STAGE SELECT, the five and the one
const AREA := 0x32          # $DB4A -- the mark of the one picked flashed up
const RAISE := 0x1D         # $E520 -- raise the stage named in $55
const ASK := 0x24           # $D79F -- CONTINUE?
const ASKING := 0x25        # $D7C2 -- and what waits there
const RIDE := 0x2C          # $E9D2 -- the view lifted before he arrives
const RIDING := 0x2D        # $E9E3 -- and the wait while it settles
## $CC33 -- the sixteen the sprites are drawn in while he arrives.  They are
## not the stage's: $CB96 writes them over the sprite half of the table itself
## ($07A0), so the walk that brings the background back up leaves them be.
const ARRIVE_PAL := [0x0F, 0x01, 0x28, 0x30, 0x0F, 0x0F, 0x21, 0x30,
		0x0F, 0x06, 0x27, 0x38, 0x0F, 0x06, 0x27, 0x29]

const BORN := 0x3E          # $CB96 -- he is put together out of four pieces
const BORNING := 0x3F       # $CC77 -- and they fly in

## And the screens on the way in, which are the same $02 walked in order.
const MAKER := 0x01         # $D157 -- the first mode the reset leaves behind
const CHOOSE := 0x03        # $D176 -- the title, or the scores, or the demo
const TITLE := 0x04         # $D19D -- the title drawn
const TITLE_WAIT := 0x05    # $D1E3 -- and waited on
const TALE_HOLD := 0x12     # $D95A -- the pause after START
const TALE_HOLD2 := 0x13    # and its twin in the table
const TALE := 0x5C          # $D262 -- the tale drawn
const TELLING := 0x5D       # $D291 -- and typed out a letter at a time
const SELECT := 0x06        # $D2AC -- the city he is called to
const SELECT_ROLL := 0x07   # $D2FB -- which slides under him
const TURN_A := 0x3A        # $D358 -- the change, in four parts
const TURN_B := 0x3B        # $D3A9
const TURN_C := 0x3C        # $D3C1
const TURN_D := 0x3D        # $D3F4
const INTO := 0x5B          # $D45C -- and in he goes

## $D252 -- sixteen buttons that open TEST MODE, pressed one after another on
## the title: A A A A B B B B A B A B A B A B.
const CODE := [0x80, 0x80, 0x80, 0x80, 0x40, 0x40, 0x40, 0x40,
		0x80, 0x40, 0x80, 0x40, 0x80, 0x40, 0x80, 0x40]

## $D44B -- the change itself: how many pictures each drawing of him is held
## for and which drawing it is, to a byte with bit seven set.  Past the end the
## last drawing is left standing and shown every other picture.
const TURN_PICS := [0x40, 0x00, 0x06, 0x08, 0x08, 0x0A,
		0x06, 0x0C, 0x02, 0x00, 0x04, 0x0E, 0x04, 0x00, 0x04, 0x10, 0xFF]
## $D437 and $D435 -- where on the screen he is drawn, in whole pixels: $F3F9
## is not the door that divides by sixteen, so what it is handed is pixels.
const TURN_Y := 0x60

## $CC2B and $CC2F -- where the four pieces start, in whole pages away from
## him, and $CD43..$CD4F -- how far each moves every picture.
const PIECE_X0 := [-0x1200, 0x1200, -0x1200, 0x1200]
const PIECE_Y0 := [-0x1200, -0x1200, 0x1200, 0x1200]
const PIECE_VX := [0x0040, -0x0040, 0x0040, -0x0040]
const PIECE_VY := [0x0040, 0x0040, -0x0040, -0x0040]
## $CD53 -- the picture each of the four is drawn as.  $CD3E hands $F461 a $02
## in Y, and Y is the high half of the number of the picture, not a mark: what
## is asked for is $022E and not $2E.
const PIECE_PIC := [0x022E, 0x022F, 0x0230, 0x0231]
## $E9D5 -- how far the view is pushed along, and $E9DE -- over how many
## pictures it is walked back.
const RIDE_LIFT := 0x2000
const RIDE_WAIT := 0x41
## $CCCF and $EA02 -- and how far it is walked back each of them.
const RIDE_STEP := 0x0080

## $97BC and $97C0 -- where a death with no try left goes.  $0D is set the
## first time CONTINUE is offered and is what decides between the two.
const DEATH_ASK := ASK
const DEATH_OVER := OVER


var mode := RAISE           # $02
var stage := 0              # $55 -- which stage, and $E520 raises it
var lives := 0              # $071C -- tries left
var z03 := 0                # $03 -- a picture count the arriving uses
var z57 := 0                # $57 -- and the flag that stops it counting twice
var z2e := 0                # $2E -- the tune the stage is played to
var z0d := 0                # $0D -- set once CONTINUE has been offered
var z59 := 0                # $59 -- how many screens have been shown
var z4c := 0                # $4C -- what is picked on a screen that asks
var noise := 0              # $F0 -- the noise asked for, kept but not made
var clock := 0              # $0C -- pictures, which the screens count by
## The thirty two colours and the walk they are on ($26, $27, $05BA and the
## rest).  Two modes wait for a walk to be over ($3C for the white flash and
## $5B for the fade out), so it is not decoration: it is what times them.
var fade := SolFade.new()
## True while the colours were written by the mode itself ($C6E9, which is how
## the title does it) and not walked towards out of a table of bank ten.
var pal_direct := false
var z4d := 0                # $4D -- a second clock the screens keep
var z4e := 0                # $4E -- how long the drawing of him is held
var z4f := 0                # $4F -- and which drawing it is
var z58 := 0                # $58 -- how far into the maker's own code he is
var z05a0 := 0              # $05A0 -- how many times round the opening has gone
var z7d := 0                # $7D -- which of the beam's own tricks is asked for
## $C160 -- while the title stands, the beam is stopped part way down and the
## pair of kilobytes the row of words is drawn out of is swapped for a blank
## one while the third bit of $4C is set.  That is how PUSH START blinks: on
## the title $4C is counted down every fourth picture, so the words go once in
## sixteen; after START it is counted down every picture, so they flash four
## on and four off.
var blank := false

## Which screen the picture shows.  Empty is the stage itself; every other
## value is a scene of `data/sol/scenes.json`, and whoever draws reads it.
var screen := ""
## $0A and $0B -- where the picture stands.
var scroll_x := 0
var scroll_y := 0
## $C925 -- the four kilobytes the background is drawn out of, when a mode has
## asked for something other than the scene's own.  Empty is the scene's.
var chr := PackedInt32Array()


## $0720/$0730 and $0740/$0750 -- the four pieces, and $0717..$0747 -- where
## the view stood when they were set going, which they are drawn against.
var piece_x := PackedInt32Array([0, 0, 0, 0])
var piece_y := PackedInt32Array([0, 0, 0, 0])
var home_x := 0
var home_y := 0
## $07E0 -- the stage's own fourth bank of tiles, put away while the arrival
## borrows it.
var kept_bank := 0

## $00 -- the count $C72D hands the sprite table.  Nothing here makes it; what
## runs a whole game sets it every picture, and the stand hands over the
## cartridge's own.
var tick := 0

## $8037 in bank four -- the words of the tale, typed one at a time.  How long
## mode $5D stands is how long this takes.
var tale := SolTale.new()

## $E520 -- raising a stage wipes both of the console's boards, and what puts
## them back is the writing of a column at a time as the view walks; the view
## is two pages out and walks the whole way back over $3F, so by the time the
## stage is played the board is whole again.  The writing itself is not ported
## -- the engine holds the whole stage as one map -- so what is kept is that
## until then there is nothing on the board but the backdrop.
var wiped := false

## True once a mode this does not port is reached, with its number in `stuck`.
var stuck := -1


## One picture: $C9B4.  `host` is what holds the stage itself and must answer
## `flow_raise(stage)`, `flow_play()`, `flow_hero()`, `flow_view()` and
## `flow_table()`; `main.gd` does.
func step(host) -> void:
	clock = (clock + 1) & 0xFF
	match mode:
		PLAY:
			host.flow_play()
		MAKER:
			_maker()
		CHOOSE:
			_choose()
		TITLE:
			_title()
		TITLE_WAIT:
			_title_wait(host)
		TALE_HOLD, TALE_HOLD2:
			_tale_hold()
		TALE:
			_tale()
		TELLING:
			_telling(host)
		SELECT:
			_select()
		SELECT_ROLL:
			_select_roll(host)
		TURN_A:
			_turn_a(host)
		TURN_B:
			_turn_b(host)
		TURN_C:
			_turn_c(host)
		TURN_D:
			_turn_d(host)
		INTO:
			_into(host)
		RAISE:
			_raise(host)
		RIDE:
			_ride(host)
		RIDING:
			_riding(host)
		BORN:
			_born(host)
		BORNING:
			_borning(host)
		PICK:
			_pick(host)
		AREA:
			_area(host)
		ASK:
			_ask()
		ASKING:
			_asking(host)
		OVER:
			_over()
		OVER_WAIT:
			_over_wait(host)
		_:
			stuck = mode


## $D157, mode $01 -- the first thing the reset leaves behind.  All it does is
## put the beam's own trick away and go on.
func _maker() -> void:
	z7d = 0                                       # $E105
	mode = CHOOSE


## $D176, mode $03 -- what the opening shows this time round.  $05A0 counts the
## times round: one in four is the five high scores, one in four is the same
## again, and the other two are the title.  (The table at $D194 is four $0E,
## so the second of those two is the scores as well.)
func _choose() -> void:
	var n: int = z05a0 & 0x03
	if n == 1 or n == 3:
		mode = 0x0E                               # BEST 5, which is not ported
		stuck = 0x0E
		return
	mode = TITLE


## $D19D, mode $04 -- the title.  $D1BD blanks the picture, takes the four
## kilobytes it is drawn out of, draws screen $0A and hands the colours over;
## screen $3B is the words under the mark.  Then the game is put back to the
## start: no stage, no tries spent, the plain suit.
func _title() -> void:
	_screen("title", 0x04, 0x06)                  # $D1BD -- $C925 A=4 Y=6
	# $C6E9 -- the title's colours are written straight into $0100 out of a
	# table of the mode's own, and with them the pace of eight and every level
	# put back to nought.  Whoever draws hands the scene's own thirty two over,
	# because they are that table written out.
	pal_direct = true
	fade.full()
	z7d = 0x13                                    # $D1D5
	mode = TITLE_WAIT                             # $D1A5
	z4c = 0                                       # $DAD8
	z4d = 0
	z4e = 0
	z4f = 0
	z58 = 0                                       # $D1AA
	z59 = 0
	z0d = 0
	stage = 0
	lives = 0x02                                  # $F8B9


## $D1E3, mode $05 -- the title waited on.  START begins the game; nothing
## pressed for long enough starts the demo instead; and the maker's own code
## opens TEST MODE.
func _title_wait(host) -> void:
	_code(host)
	if (clock & 0x03) == 0:
		z4c = (z4c - 1) & 0xFF                    # $D1EF
	# $C160 -- the beam reads $4C while the picture is being drawn, and the
	# picture this turn belongs to is drawn over the next one, so what says
	# whether the words are there is the $4C the next turn will hold.
	blank = ((z4c - (1 if ((clock + 1) & 0x03) == 0 else 0)) & 0x04) != 0
	if (host.flow_pad_new() & Pad.START) != 0:    # $D1F1
		z4c = 0x80                                # $D216
		noise = 0x03
		z05a0 = TALE_HOLD
		mode = TALE_HOLD
		return
	if host.flow_pad() != 0:                      # $D1F7 -- a button held puts
		z4d = 0                                   # the demo off again
	if (clock & 0x03) != 0:
		return
	z4d = (z4d - 1) & 0xFF                        # $D205
	if z4d != 0:
		return
	z05a0 = (z05a0 + 1) & 0xFF                    # $D209 -- and round again
	z7d = 0
	mode = CHOOSE


## $D226 -- sixteen buttons in a row on the title open the maker's own menu.
## What is compared is the whole of what is held, so a button held along with
## the right one breaks the row.
func _code(host) -> void:
	if host.flow_pad_new() == 0:                  # $D226
		return
	var held: int = host.flow_pad()
	if held == 0:
		return
	if CODE[z58] != held:                         # $D233
		z58 = 0
		return
	z58 += 1
	if z58 != 0x10:                               # $D23B
		return
	noise = 0x11                                  # $D23F
	mode = ASK                                    # $D243 -- TEST MODE
	z05a0 = ASK
	z7d = 0
	z58 = 0


## $D95A, modes $12 and $13 -- the title held for a moment after START, and
## then the picture wiped and the tale set up.
func _tale_hold() -> void:
	z4c = (z4c - 1) & 0xFF
	blank = ((z4c - 1) & 0x04) != 0               # $C160, a turn ahead
	if z4c != 0:
		return
	blank = false
	tale.rewind()                                 # $D963 -> $803A
	screen = ""                                   # $C578 and $C5DA -- wiped
	mode = TALE


## $D262, mode $5C -- the tale drawn.
func _tale() -> void:
	_screen("tale", 0x16, 0x0A)                   # $C925 A=$16 Y=$0A
	mode = TELLING
	pal_direct = false
	fade.blank()                                  # $D262 -> $C5C9 -> $C5B0
	fade.name_table(0x8500)                       # $D277 -- $E9B1 A=0 Y=$85
	fade.ask(SolFade.HOME, 0xFF)                  # $D27E
	z4d = 0                                       # $8055 -- the telling begins
	z7d = 0
	scroll_x = 0
	scroll_y = 0
	noise = 0x0C


## $D291, mode $5D -- and told.  What tells it is $8037 in bank four, which
## types one letter of $80F9 into the board every eighth picture and one every
## picture while a button is held; when the stream runs out $57 is set and the
## mode ends, so the tale stands for exactly as long as the typing takes.
func _telling(host) -> void:
	_ca9a(host)
	tale.step(clock, host.flow_pad(), host)       # $8037
	if not tale.done:                             # $D29D -- $57
		return
	noise = 0x10                                  # $D2A3
	mode = SELECT


## $D2AC, mode $06 -- the city he is called to.  Two screens make it, and from
## here to the stage the board does not change again: everything the change
## does it does with colours, with the four kilobytes of tiles, and with him.
func _select() -> void:
	_screen("select", 0x10, 0x12)                 # $C925 A=$10 Y=$12
	mode = SELECT_ROLL
	noise = 0x0A
	pal_direct = false
	fade.name_table(0x8280)                       # $D2D1 -- $E9B1 A=$80 Y=$82
	fade.dark()                                   # $D2D8 -- black to begin with
	fade.at_pace(0x02)                            # $D2DB
	fade.ask(SolFade.HOME, 0xFF)                  # $D2EA
	z4c = 0x20
	z4d = 0x40
	z7d = 0
	scroll_x = 0
	scroll_y = 0


## $D2FB, mode $07 -- and the city slides under him: thirty two pictures of it
## walking two points at a time, then sixty four of it standing still.
func _select_roll(host) -> void:
	_ca9a(host)
	scroll_x = (scroll_x - 2) & 0xFF              # $D2FE
	z4c = (z4c - 1) & 0xFF
	if z4c != 0:
		return
	scroll_x = (scroll_x + 2) & 0xFF              # $D309 -- put back, and the
	z4c = 1                                       # count with it, so the walk
	fade.out[0x0F] = 0x30                         # stops where it stood
	z4d = (z4d - 1) & 0xFF
	if z4d != 0:
		return
	fade.name_table(0x82A0)                       # $D331
	fade.dark()                                   # $D338
	fade.ask(SolFade.HOME, 0xFF)                  # $D33B
	_chr(0x14, 0x16)                              # $D342
	mode = TURN_A
	z4c = 0
	scroll_x = 0
	scroll_y = 0xEF                               # $D353


## $D358, mode $3A -- the first part of the change: three of the colours are
## flashed, one after another, and held flashing for a hundred and twenty
## eight pictures.
func _turn_a(host) -> void:
	_ca9a(host)
	z4c = (z4c + 1) & 0xFF
	var c: int = 0x31 if (clock & 1) != 0 else 0x1F
	if z4c >= 0x20:
		fade.out[0x02] = c
	if z4c >= 0x30:
		fade.out[0x06] = c
	if z4c >= 0x40:
		fade.out[0x0A] = c
	if z4c != 0x80:
		return
	fade.name_table(0x8280)                       # $D381
	fade.dark()                                   # $D388
	fade.ask(SolFade.HOME, 0xFF)                  # $D38B
	_chr(0x10, 0x12)                              # $D392
	z4c = 0x20
	mode = TURN_B
	scroll_x = 0xC0                               # $D39F
	scroll_y = 0


## $D3A9, mode $3B -- thirty two pictures, and then the screen is walked out to
## white, four pictures a step.  Eight steps of four is the thirty two the next
## mode waits out: the flash is the clock.
func _turn_b(host) -> void:
	_ca9a(host)
	z4c = (z4c - 1) & 0xFF
	if z4c != 0:
		return
	fade.ask(SolFade.UP, 0xFF)                    # $D3B0
	mode = TURN_C
	fade.at_pace(4)                               # $D3B9 -- $F865
	z4c = 0x10


## $D3C1, mode $3C -- the white held.  Nothing moves until the walk out to
## white is over, and then sixteen more pictures, and then the screen is walked
## back down towards a table of its own.
func _turn_c(host) -> void:
	_ca9a(host)
	if fade.kind != 0:
		return
	z4c = (z4c - 1) & 0xFF
	if z4c != 0:
		return
	fade.ask(SolFade.HOME, 0xFF)                  # $D3CC
	fade.name_table(0x82C0)                       # $D3D3
	_chr(0x10, 0x12)
	z4c = 0x70                                    # $D3E1 -- and where he stands
	z4d = 0
	z4e = 1
	scroll_x = 0x50
	mode = TURN_D


## $D3F4, mode $3D -- he changes.  Every eighth picture the city walks one
## point back and he walks one point on, and between them the table at $D44B
## says which drawing of him is up.
func _turn_d(host) -> void:
	var t = host.flow_table()
	_ca9a(host)
	if (clock & 0x07) == 0:
		scroll_x = (scroll_x - 1) & 0xFF          # $D3FD
		z4c = (z4c + 1) & 0xFF
		if scroll_x == 0x30:
			fade.ask(SolFade.DOWN, 0xFF)          # $D407 -- out to black
			mode = INTO
			return
	if z4e >= 0x80:                               # $D413 -- past the end of the
		if (clock & 1) != 0:                      # table, and then he is shown
			return                                # every other picture
	else:
		z4e = (z4e - 1) & 0xFF
		if z4e == 0:
			z4e = TURN_PICS[z4d]                  # $D421
			if z4e >= 0x80:
				return
			z4f = TURN_PICS[z4d + 1]
			z4d += 2
	SolSprites.plain(0x0200 | z4f, 0x00, z4c, TURN_Y, t)


## $D45C, mode $5B -- and in he goes, once the screen has gone out to black.
func _into(host) -> void:
	_ca9a(host)
	if fade.kind != 0:
		return
	noise = 0x10
	mode = PICK
	z7d = 0
	fade.at_pace(4)                               # $D479
	screen = ""
	chr = PackedInt32Array()


## $C5C9 and $C925 together: the picture blanked, the board wiped, the scene
## drawn on it and the four kilobytes it is drawn out of taken.
func _screen(name: String, a: int, y: int) -> void:
	screen = name
	chr = PackedInt32Array()
	_chr(a, y)


## $CA9A -- the top of a screen's picture: the sprite table put back to empty
## and one picture of the walk the colours are on.
func _ca9a(host) -> void:
	SolSprites.reset(host.flow_table(), clock)    # $C72D
	fade.tick()                                   # $F806


## $C925 -- two two-kilobyte halves, which is four one-kilobyte banks.  A scene
## the mode asks for nothing other than is left to its own, because a scene may
## swap banks part way down the picture and a pair cannot say that.
func _chr(a: int, y: int) -> void:
	chr = PackedInt32Array([a, a + 1, y, y + 1])


## $E520 -- the screen is blanked, both nametables are wiped and the stage
## named in $55 is read in ($E708 reads its record, $E788 puts every spawn back
## and $E7A0 empties the hero); then he is put together.
##
## The blanking and the wiping are the console's and are not ported; what the
## stage is raised out of is `data/sol/levels/stageN.json`, which is the same
## record $E708 reads.
func _raise(host) -> void:
	host.flow_raise(stage)
	# $F872 -- the thirty two the stage is drawn in are copied into $0790 and
	# that is what the walk reads from there on; $F8AD puts six pictures
	# between one step of a walk and the next, and $F83D writes the table out
	# once at the level it stands at, which is nought.
	fade.table = PackedByteArray(host.flow_palette())
	for i in range(8):                            # $F83D
		fade.level[i] = 0
	fade.at_pace(6)                               # $F8AD
	fade.ask(SolFade.ONCE, SolFade.ONCE)
	fade.run()
	wiped = true                                  # $E520 -- both boards wiped
	# $E776 -- a stage whose record names the tune already playing does not ask
	# for it again.
	z2e = host.flow_tune()
	mode = BORN


## $E9D2, mode $2C -- the view is pushed two pages along and $41 pictures are
## put on the clock for it to walk back over.  It ends in `INC $02`, so which
## mode follows is whichever asked: $2C leads to $2D and $3E to $3F.
func _ride(host) -> void:
	var v = host.flow_view()
	v.x = (v.x + RIDE_LIFT) & 0xFFFF              # $E9D3, the high byte alone
	z03 = RIDE_WAIT                               # $E9DE
	mode = (mode + 1) & 0xFF                      # $E9E0


## $E9E3, mode $2D -- and one of those pictures.  The stage is not stepped;
## only the view walks, and when the clock runs out the stage is played.
func _riding(host) -> void:
	z03 = (z03 - 1) & 0xFF
	if z03 != 0:
		var v = host.flow_view()
		v.x = (v.x - RIDE_STEP) & 0xFFFF          # $EA02
		return
	if z2e != 0:
		noise = z2e                               # $E9F7
	mode = PLAY


## $CB96, mode $3E -- he is not walked into a stage, he is put down in it: four
## pieces are set going from a page and a half out on each diagonal and he
## stands still in state $12 until they meet on him.
func _born(host) -> void:
	var p = host.flow_hero()
	var v = host.flow_view()
	# $CB96 -- a hit still on him when he died is let run all the way out.
	if p.hurt != 0:
		p.hurt |= 0x07
	# $CBA0 -- the four kilobytes the arrival is drawn out of are not the
	# stage's, so the stage's are put away in two bytes of the shot pool
	# nothing is using and $9766 fetches them back when it is over.
	var t = host.flow_table()
	kept_bank = t.banks[3]                        # $CBA5 -> $07E0
	t.banks[3] = 0x0E                             # $CBAA
	# $CBB1 -- the arrival itself is an object like any other: record $B4 of
	# the hatching table, let out where he stands.  It is what runs $05AF
	# down, and until that is nought $9741 will not let him move.
	var pool = host.flow_pool()
	if pool != null:
		pool.hatch(p.x, p.y, 0xB4)
	p.state = 0x12                                # $CBB6
	p.fuel = 0x12                                 # $CBBB
	# $CBC1 -- the background's sixteen colours are written black outright and
	# the sprites' are the arrival's own, which go into the table as well so
	# nothing writes over them later.  $CBD6 puts the background's four levels
	# at the bottom and the sprites' at nought, and it is the background alone
	# that $CCC5 walks back up when the pieces have nearly met.
	for i in range(16):
		fade.out[i] = 0x0F                        # $CBC3
		fade.out[16 + i] = ARRIVE_PAL[i]          # $CBC8
		fade.table[16 + i] = ARRIVE_PAL[i]        # $CBCE -> $07A0
	for i in range(4):
		fade.level[i] = SolFade.DARK              # $CBD6
		fade.level[4 + i] = 0                     # $CBDD
	z57 = 0                                       # $CBE4
	for i in range(4):                            # $CC0D
		piece_x[i] = (p.x + PIECE_X0[i]) & 0xFFFF
		piece_y[i] = (p.y + PIECE_Y0[i]) & 0xFFFF
	home_x = v.x                                  # $CBF6
	home_y = v.y
	_ride(host)                                   # $CC0A -> $E9D2, which
	                                              # walks $02 on to $3F


## $CC77, mode $3F -- one picture of them flying in.  The first piece arriving
## on him is what ends it, and the count $2C put up is what walks the view back
## down while they do.
func _borning(host) -> void:
	var p = host.flow_hero()
	var t = host.flow_table()
	# $CA9A -- the table put back to empty and one picture of the walk the
	# colours are on.  The count $C72D is handed is $00, which a whole game
	# keeps itself, and not the $0C the screens are counted by.
	SolSprites.reset(t, tick)                     # $C72D
	fade.tick()                                   # $F806
	if piece_x[0] == p.x:                         # $CC7B, both bytes at once
		if z2e != 0:
			noise = z2e                           # $CC8F
		# $CC94 -- and the one that is let out where the four met.
		var pool = host.flow_pool()
		if pool != null:
			pool.hatch(p.x, p.y, 0x3F)
		mode = PLAY                               # $CC9F
		wiped = false                             # the board is whole again
		for i in range(3, -1, -1):                # $CCA1
			_piece_draw(i, t)
		return
	for i in range(3, -1, -1):                    # $CCDD
		piece_x[i] = (piece_x[i] + PIECE_VX[i]) & 0xFFFF
		piece_y[i] = (piece_y[i] + PIECE_VY[i]) & 0xFFFF
		_piece_draw(i, t)                         # $CCEA falls into $CD10
	if z57 != 0:
		return                                    # $CCB3
	z03 = (z03 - 1) & 0xFF
	if z03 == 0:
		# $CCC5 -- the background alone is walked home out of the black it was
		# put in, and $57 stops the view where it stands.
		fade.ask(SolFade.HOME, 0x0F)
		z57 = (z57 - 1) & 0xFF                    # $CCCC
		return
	var v = host.flow_view()
	v.x = (v.x - RIDE_STEP) & 0xFFFF              # $CCCF


## $CD10 -- one piece, drawn against where the view stood when they were set
## going and not against where it stands now.
func _piece_draw(i: int, t: SolSprites.Table) -> void:
	# $CD14 empties $9E, so nothing of the picture is turned over.
	SolSprites.picture(PIECE_PIC[i], 0x00,
			(piece_x[i] - home_x) & 0xFFFF,
			(piece_y[i] - home_y) & 0xFFFF, t)


## $DAE3, mode $19 -- the stage picked is on its way in.  The four kilobytes
## the screen is drawn out of and the two the marks are drawn out of are taken
## whatever follows.  Stage nought is the one the game opens on and has no
## screen of its own, so it is raised at once; every other one is announced.
func _pick(host) -> void:
	_chr(0x08, 0x5E)                              # $DAE7 -- $C925 A=$08 Y=$5E
	var t = host.flow_table()
	t.banks[0] = 0x5C                             # $DAEA -- $42
	t.banks[2] = 0x70                             # $DAEE -- $44
	if stage == 0:                                # $DAF2
		mode = RAISE                              # $DAF6
		return
	fade.blank()                                  # $DAFB -> $C5C9 -> $C5B0
	screen = "stages"                             # $DAFE -- $EF8C screen $13
	mode = CHOSEN                                 # $DB03 -- $02 up one
	z4c = 0                                       # $DB05 -- $DAD8
	z4d = 0
	z4e = 0
	z4f = 0
	fade.name_table(0x8360)                       # $DB08 -- $E9B1 A=$60 Y=$83
	for i in range(8):                            # $DB0F
		fade.level[i] = SolFade.DARK
	fade.at_pace(8)                               # $DB19 -- $F861
	for i in range(3):                            # $DB1C -- $05BA..$05BC
		fade.level[i] = SolFade.BRIGHT
	fade.ask(0xFE, 0xFE)                          # $DB2C -- $F849, A still $FE
	fade.run()
	# $DB34 -- which of the two noises is asked for turns on $2D, which the
	# sound code keeps for itself and is not ported; what a stage that is not
	# the last asks for is $0C.
	noise = 0x0C
	scroll_y = 0xEF                               # $DB43 -- $0B, which $C535 writes


## $DB4A, mode $32 -- the mark of the stage picked flashed up, which is what
## STAGE SELECT goes on to.  $4C counts every picture and picks what is drawn
## on it at $80,$B0; at $20 the colours are sent away, and once they have gone
## the board is wiped and the stage raised.
func _area(host) -> void:
	_ca9a(host)                                   # $DB4A -- $CA9A
	z4c = (z4c + 1) & 0xFF                        # $DB4D
	var pics: Array
	if z4c < 0x08:                                # $DB51
		pics = [0x10]
	elif z4c < 0x10:                              # $DB55
		pics = [0x11, 0x13]
	elif z4c < 0x18:                              # $DB59
		pics = [0x12, 0x13]
	elif z4c < 0x20:                              # $DB5D
		pics = [0x13]
	else:
		if z4c == 0x20:                           # $DB61
			fade.ask(SolFade.DOWN, 0xFF)          # $DB63 -- $F86D 1/$FF
		elif fade.kind == 0:                      # $DB6C -- $26 has run out
			screen = ""                           # $DB70 -- $C578 and $C5DA
			noise = 0x10                          # $DB7E
			mode = RAISE                          # $DB82
			return
		pics = [0x13]
	var t = host.flow_table()
	for p in pics:                                # $DB9B -- $F3E5, $90 and $92
		SolSprites.plain(p, 0x00, 0x80, 0xB0, t)


## $D79F, mode $24 -- CONTINUE?, and $D7C2, mode $25 -- waiting on it.  The
## letters are not ported; what is kept is that the offer is remembered in $0D,
## so a second death with no tries left ends the game instead of asking again.
func _ask() -> void:
	z0d = 0x19                                    # $D7A5
	z2e = 0                                       # $D7AF
	z59 = (z59 + 1) & 0xFF                        # $D7B3
	z4c = 0
	mode = ASKING


func _asking(host) -> void:
	var pad: int = host.flow_pad_new()
	if (pad & Pad.SELECT) != 0:                   # $D7DF
		z4c += 1                                  # $D7E9
		if z4c >= 0x09:
			z4c = 0                               # $D7F1
		return
	if (pad & Pad.START) == 0:
		return
	# $D7D8 -- what each of the nine lines on the screen leads to.  Only the
	# first is ported: the game is taken up again from the stage it was left
	# in, with the tries put back.
	if z4c == 0:
		lives = 0x02
		mode = RAISE
		return
	stuck = ASKING


## $D974, mode $14 -- no tries left, and $DA52, mode $15 -- waiting there.  The
## screen is not ported; pressing START starts the game again.
func _over() -> void:
	z2e = 0                                       # $D97C
	z59 = (z59 + 1) & 0xFF                        # $D97E
	noise = 0x09                                  # $D986
	mode = OVER_WAIT


func _over_wait(host) -> void:
	if (host.flow_pad_new() & Pad.START) == 0:
		return
	lives = 0x02
	z0d = 0
	stage = 0
	mode = RAISE


## $97A7 -- the hero's last state, which is where a stage is left from.  It is
## called by `sol_player.gd` once the dying is over.
func died() -> void:
	noise = 0x10                                  # $97CF
	if lives != 0:
		lives = (lives - 1) & 0xFF                # $97C4
		z2e = 0                                   # $97C9
		mode = RAISE
		return
	mode = DEATH_ASK if z0d != 0 else DEATH_OVER
