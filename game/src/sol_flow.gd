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
const CLEAR := 0x1B         # $E09C -- AREA x CLEARED, and the plates of it
const PAYING := 0x1C        # $E117 -- and what the clearing owes paid out

## The end of the game.  $9FF8 in bank eight is the one door into it and it
## opens on $4C; from there the modes run one into the next and nothing else
## reaches any of them.  ($1E, $1F, $20, $21 stand in the table of modes and
## are the same code over again, but nothing anywhere puts any of the four on
## $02, so the game cannot stand in them.)
const END_PAY := 0x4C       # $E33A -- what the whole game paid
const END_SUN := 0x4D       # $E421 -- and the sun coming up behind it
const STAFF := 0x4E         # $E3E7 -- the ground the names are shown over
const END_WALK := 0x4F      # $E42F -- the man walked in front of it
const END_HOLD := 0x50      # $E456 -- and standing where he stopped
const END_TURN := 0x51      # $E463 -- turned to face the names
const END_WAIT := 0x52      # $E474
const END_DOWN := 0x53      # $E486 -- the names taken down into the dark
const END_LAST := 0x54      # $E494
## $E4E9 and $E515 -- the names themselves, typed over the black.  $22 wipes
## both boards and takes twenty of $D481; $23 is the twenty one steps of $8836
## in bank twelve, which read the stream of bank six.
const CREDIT_PAL := 0x22
const CREDIT := 0x23
## $D79F -- TEST MODE, the maker's own menu, opened by sixteen buttons in a row
## on the title.  Its nine lines are the two tests and seven stages, and those
## seven are the only door in the game to the rooms the bosses stand in.
const TEST_LAY := 0x24      # $D79F -- the menu drawn
const TEST_MENU := 0x25     # $D7C2 -- and walked
const TEST_BACK := 0x26     # $D842 -- straight back to the menu
const BGM := 0x2A           # $D863 -- BGM TEST drawn
const BGM_WAIT := 0x2B      # $D880 -- and walked
const SOUND := 0x33         # $D8C7 -- the sound test drawn
const SOUND_WAIT := 0x34    # $D8E4 -- and walked
## $CA7D..$CA91 and $D930 -- a stage named and asked for, and nothing else.
const STAGE_STUB := [0x30, 0x41, 0x42, 0x48, 0x49, 0x4A, 0x4B]
const RIDE := 0x2C          # $E9D2 -- the view lifted before he arrives
# $CAA0 -- the way out of one stage into the next inside the same area.  The
# five run into one another: the record of the stage $55 names is read in, the
# view is pushed along and ridden back ($36 is the same $E9D2 as $2C), the
# hero walks in while it does, and the colours are taken down and brought back.
const DOOR := 0x35
const DOOR_RIDE := 0x36     # $E9D2 again
const DOOR_WALK := 0x37     # $CAC6
const DOOR_OUT := 0x38      # $CB78
const DOOR_END := 0x39      # $CB85
## $CB62, $CB68 and $CB6E -- how long each of the six steps of the walk in
## lasts, and the picture it is drawn with, whole and hurt.
const DOOR_WAIT := [0x06, 0x05, 0x08, 0x06, 0x05, 0x08]
const DOOR_PICS := [0xA0, 0xA2, 0xA4, 0xA8, 0xAA, 0xA6]
const DOOR_HURT := [0xDE, 0xE0, 0xE2, 0xE6, 0xE8, 0xE4]
## $CB03 and $CAFF -- and the one he stands in once he is where he was.
const DOOR_STILL := 0x64
const DOOR_STILL_HURT := 0xDA
## $CB0A -- how far he walks in a picture, in sixteenths.
const DOOR_STEP := 0x18
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

## $D1D1 -- the table the title's twenty colours are copied out of.  It is
## named here and not only drawn, because the screen after it takes fewer than
## thirty two and what it leaves alone is this table written out ($C6E9).
const TITLE_TABLE := 0xD499

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

## $DBD6 and $DD48 -- the man below the board, in two pictures, and the
## pointer that stands over the frame picked.
const MAN := 0x0E
const MARK := 0x0B
## $E9D5 -- how far the view is pushed along, and $E9DE -- over how many
## pictures it is walked back.
const RIDE_LIFT := 0x2000
const RIDE_WAIT := 0x41
## $CCCF and $EA02 -- and how far it is walked back each of them.
const RIDE_STEP := 0x0080

## $97BC and $97C0 -- where a death with no try left goes.  $0D is set when
## TEST MODE is drawn and is what decides between the two: once the maker's own
## menu has been opened, dying goes back to it.
const DEATH_ASK := TEST_LAY
const DEATH_OVER := OVER

## $D6CA and $D77E -- the five high scores, shown and then waited on; $DA02 --
## what CONTINUE goes through on its way back to the stage.
const BEST := 0x0E
const BEST_WAIT := 0x0F
const AGAIN := 0x47

## $D4AD and what follows it -- the typing of a name into BEST 5.  The asking
## is reached from seven modes, and each of the two that matter carries its own
## three along: $43 goes on to $44, $45, $46 and then the opening, $55 to $56,
## $57, $58 and then the lamp.
const TOP_ASK := 0x43       # $D4AD -- did this game beat the lowest of five?
const NAME_SLIDE := 0x44    # $D6A5 -- the five lines slide in from the side
const NAME_PICK := 0x45     # $D525 -- and three letters are typed
const NAME_DONE := 0x46     # $D648 -- and held for a while
const TOP_ASK_END := 0x55   # the same four, reached from the end of the game
const NAME_SLIDE_END := 0x56
const NAME_PICK_END := 0x57
const NAME_DONE_END := 0x58
const LAMP := 0x59          # $D631 -- the screen walked out
const LAMP_WAIT := 0x5A     # $D63B -- and the game begun again


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
var z2d := 0                # $2D -- which stages are done with, a bit each
## $05C5 and $05C6:$05C7 where there is no pool to hold them -- see `_suits`.
var z05c5 := 0
var z05c6 := 0
var z05ab := 0              # $05AB -- how long STAGE SELECT waits to pick
## $05FD..$05FF -- what this game has scored, and $075B..$077F -- the five
## counts BEST 5 shows, the biggest last.  $072B..$074F are the three letters
## of each name.  The reset fills both out of $E545 and $E536.
var score := 0
var best_scores: Array = SolOver.first_scores()
var best_names: Array = SolOver.first_names()
## $0752 and $0753 -- the two the GAME OVER screen counts its asking by: while
## $0753 stands the first press of START is swallowed, and $0752 says whether
## the asking is over.
var z0752 := 0
var z0753 := 0

## $F1 -- the second noise asked for, the one a screen makes for itself.  Kept
## like $F0 and not made.
var noise2 := 0

## $0740, $0750 and $0760 -- the eight bands the beam is cut into: how many
## lines each is, which page it shows, and how far along it stands.  The engine
## does not cut the beam; what it keeps is the numbers, because the modes that
## type a name move them and are judged by them.
var z0740 := PackedByteArray([0, 0, 0, 0, 0, 0, 0, 0])
var z0750 := PackedByteArray([0, 0, 0, 0, 0, 0, 0, 0])
var z0760 := PackedByteArray([0, 0, 0, 0, 0, 0, 0, 0])

## $75 -- what the beam's counter is set to.
var z75 := 0
## $72, $73 and $74 -- how far the ending has walked the view, and the place
## and the count $8AE9 works out of it for the beam to be cut at.  Nothing here
## cuts the beam; what is kept is the numbers, because the sunrise is judged by
## them.
var z72 := 0
var z73 := 0
var z74 := 0
var z76 := 0                # $76 and $77 -- what $E37D leaves standing
var z77 := 0
## $060C -- the satellite's own slot, which is what the bonus at the end of the
## game pays for.  The pool holds it while a stage is played; a walk that
## stands on a screen and nothing else has no pool, so the flow holds it.
var z060c := 0

## $58 -- how far into the maker's own code he is on the title, and how many of
## the beat's lines are still to be read at the end of the game.
var z58 := 0
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
## Which of the two kilobytes a new screen carries over from the one standing
## instead of wiping, a bit apiece.  $C5DC wipes $2000 and $2400, and where the
## two boards are mirrored across those are the same kilobyte, so the other one
## is never touched at all -- which is how the ending's names stand over what
## the bonus screen left behind.
var screen_keep := 0
## Whether the mode wiped both boards without laying a screen over them, which
## is what $C5C9 on its own comes to ($E4E9 does it and then types the names
## straight onto the black).
var screen_wipe := false
## $0780 -- the places the beam's own stop reads while the names are typed.
## Nothing here cuts the beam; the pool is kept because the step that fills it
## is what says when that step is over.
var z0780 := PackedByteArray()
## $80:$81 and $82:$83 -- where the man stands while the names are typed, in
## sixteenths of a pixel, and $05A4, $05B4, $05B5, $05A6, $05A7 -- the little
## walk he is doing.  The ending is the one place in the game where the hero's
## own machinery runs with no hero behind it.
var man_x := 0
var man_y := 0
var man_pose := 0           # $05B5
var man_t := 0              # $05A4
var man_i := 0              # $05B4
var man_pic_lo := 0         # $05A6
var man_pic_hi := 0         # $05A7
## $90:$91 while the names are typed -- which row of the board the three
## blanking records of $8975 are written at next.
var credit_at := 0
## $70 -- which trick the beam is running this picture, which $FBDB settles at
## the top of it out of the $7D the picture before left.
var z70 := 0


## $0720/$0730 and $0740/$0750 -- the four pieces, and $0717..$0747 -- where
## the view stood when they were set going, which they are drawn against.
var piece_x := PackedInt32Array([0, 0, 0, 0])
var piece_y := PackedInt32Array([0, 0, 0, 0])
var home_x := 0
var home_y := 0
## $07E0 -- the stage's own fourth bank of tiles, put away while the arrival
## borrows it.
var kept_bank := 0

## $00 -- the count $C72D hands the sprite table, raised at $FADE every
## picture the console is not held on.  BEST 5 counts its waiting by the low
## two of it, so it is kept here and raised with $0C.
var tick := 0
## A stand that hands the cartridge's own $00 over for every picture sets
## this, because $00 stands still while the console is held ($6E) and nothing
## in the engine holds it.
var tick_held := false

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
## $0720, $0730 and $0740 -- where the walk in is going, which of its six
## steps is up and how long that step has left.  The cartridge keeps them in
## weapon slot nought's own x and y: nothing walks the weapons while the
## passage runs, so it borrows them, and the same three bytes stand for the
## bands of the beam in the modes that type a name.
var door_to := 0
var door_step := 0
var door_left := 0


## One picture: $C9B4.  `host` is what holds the stage itself and must answer
## `flow_raise(stage)`, `flow_play()`, `flow_hero()`, `flow_view()`,
## `flow_table()` and `flow_tune_end()`; `main.gd` does.
func step(host) -> void:
	clock = (clock + 1) & 0xFF
	# $FADE -- the other count of pictures, raised in the same breath as $0C
	# and only while $6E is clear.  Nothing in the engine stops the picture,
	# so it is raised every turn unless a stand is handing it over.
	if not tick_held:
		tick = (tick + 1) & 0xFF
	match mode:
		PLAY:
			host.flow_play()
		MAKER:
			_maker()
		CHOOSE:
			_choose()
		TITLE:
			_title(host)
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
		RIDE, DOOR_RIDE:
			_ride(host)
		DOOR:
			_door(host)
		DOOR_WALK:
			_door_walk(host)
		DOOR_OUT:
			_door_out(host)
		DOOR_END:
			_door_end(host)
		RIDING:
			_riding(host)
		BORN:
			_born(host)
		BORNING:
			_borning(host)
		PICK:
			_pick(host)
		CHOSEN:
			_chosen(host)
		AREA:
			_area(host)
		CLEAR:
			_area_clear(host)
		PAYING:
			_area_pay(host)
		END_PAY:
			_end_pay(host)
		END_SUN:
			_end_sun(host)
		STAFF:
			_end_staff(host)
		END_WALK:
			_end_walk(host)
		END_HOLD:
			_end_hold(host)
		END_TURN:
			_end_turn(host)
		END_WAIT:
			_end_wait(host)
		END_DOWN:
			_end_down(host)
		END_LAST:
			_end_last(host)
		CREDIT_PAL:
			_credit_pal(host)
		CREDIT:
			_credits(host)
		TEST_LAY:
			_test_lay(host)
		TEST_MENU:
			_test_menu(host)
		TEST_BACK:
			mode = TEST_LAY                       # $D842
		BGM:
			_test_draw(host, true)
		BGM_WAIT:
			_test_wait(host, true)
		SOUND:
			_test_draw(host, false)
		SOUND_WAIT:
			_test_wait(host, false)
		0x30, 0x41, 0x42, 0x48, 0x49, 0x4A, 0x4B:
			_test_stage()
		OVER:
			_over(host)
		OVER_WAIT:
			_over_wait(host)
		AGAIN:
			_again(host)
		TOP_ASK, TOP_ASK_END:
			_top_ask(host)
		NAME_SLIDE, NAME_SLIDE_END:
			_name_slide(host)
		NAME_PICK, NAME_PICK_END:
			_name_pick(host)
		NAME_DONE, NAME_DONE_END:
			_name_done(host)
		LAMP:
			_lamp()
		LAMP_WAIT:
			_lamp_wait(host)
		BEST:
			_best(host)
		BEST_WAIT:
			_best_wait(host)
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
		mode = BEST                               # $D194 -- four $0E
		return
	mode = TITLE


## $D19D, mode $04 -- the title.  $D1BD blanks the picture, takes the four
## kilobytes it is drawn out of, draws screen $0A and hands the colours over;
## screen $3B is the words under the mark.  Then the game is put back to the
## start: no stage, no tries spent, the plain suit.
func _title(host) -> void:
	_no_sprites(host)                             # $D1BD -- $C5C9, $C618 $0C
	_screen("title", 0x04, 0x06)                  # $D1BD -- $C925 A=4 Y=6
	# $C6E9 -- the title's colours are written straight into $0100 out of a
	# table of the mode's own, and with them the pace of eight and every level
	# put back to nought.  Whoever draws hands the scene's own thirty two over,
	# because they are that table written out.
	pal_direct = true
	fade.name_table(SolFlow.TITLE_TABLE)          # $D1D1 -- $20:$21 on it
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
	mode = TEST_LAY                               # $D243 -- TEST MODE
	z05a0 = TEST_LAY
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
	screen_keep = 0
	chr = PackedInt32Array()
	_chr(a, y)


## $CA9A -- the top of a screen's picture: the sprite table put back to empty
## and one picture of the walk the colours are on.
func _ca9a(host) -> void:
	# $C72D reads $00 and not $0C: the two are raised in the same breath but
	# they are not the same count, and what the table is handed is $00.
	SolSprites.reset(host.flow_table(), tick)     # $C72D
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


## $CAA0, mode $35 -- the way out of a stage into the next one of the same
## area.  The stage's own script writes it -- $9398 is one of the six that do
## -- after putting the stage it wants into $55.
##
## The record of that stage is read in ($E69B), and only that: the screen is
## not wiped and he is not put together out of four pieces, because he is
## already standing.  What is done to him is that he is pushed back to the
## nearest sixteen pixels along, and the four modes that follow walk him the
## rest of the way in while the view rides.
func _door(host) -> void:
	_ca9a(host)                                   # $CAA0
	if fade.kind != 0:                            # $CAA3 -- $26
		return
	# $55 is the stage the script asked for, and the pool is where the engine
	# keeps it.
	var pool = host.flow_pool()
	if pool != null:
		stage = pool.stage
	host.flow_door(stage)                         # $CAA7 -- $E69B
	mode = DOOR_RIDE                              # $CAAA -- INC $02
	var h = host.flow_hero()
	door_to = (h.x >> 8) & 0xFF                   # $CAAC
	h.x = h.x & 0xF0FF                            # $CAB3 -- $81 &= $F0
	# $CAB5 -- bank $0C and $8019, which is $934C: the hero's own slot of the
	# pool wiped.
	var np = host.flow_pool()
	if np != null:
		np.sat_clear()
	door_left = 0x01                              # $CABF
	door_step = 0x01


## $CADF -- one picture of the walk in.  He is drawn where he stands, with the
## high nibble of each half of the place dropped, and walks a step and a half
## a picture until the sixteen he was pushed back by are made up.
func _door_draw(host) -> void:
	_ca9a(host)                                   # $CADF
	var h = host.flow_hero()
	var t = host.flow_table()
	var pool = host.flow_pool()
	if h == null:
		return
	if h.shield != 0:                             # $CAE2 -- $05C8
		var c: int = int(SolSprites.shine[(clock >> 1) & 0x03])
		fade.out[0x12] = c                        # $CAF0
		if pool != null:
			pool.z0112 = c
	var pic: int
	if ((h.x >> 8) & 0xFF) == door_to:            # $CAF3 -- he is back
		pic = DOOR_STILL_HURT if h.hurt != 0 else DOOR_STILL
	else:
		h.x = (h.x + DOOR_STEP) & 0xFFFF          # $CB07
		door_left = (door_left - 1) & 0xFF        # $CB12
		if door_left == 0:
			door_step = (door_step + 1) & 0x07    # $CB18
			if door_step == 0x06:
				door_step = 0
			door_left = int(DOOR_WAIT[door_step]) # $CB29
		pic = int(DOOR_HURT[door_step] if h.hurt != 0
				else DOOR_PICS[door_step])
	# $CB43 -- the place with the high nibble of each half dropped, which is
	# what the view has already been walked to.
	SolSprites.picture(pic, 0x00, h.x & 0x0FFF, h.y & 0x0FFF, t)


## $CAC6, mode $37 -- the ride back, with the walk in drawn over it.  $E9E3
## ends by putting nought on the mode; here that is not the stage being played
## but the colours being taken down.
func _door_walk(host) -> void:
	_door_draw(host)                              # $CAC6
	_riding(host)                                 # $CAC9 -- $E9E3
	if mode != PLAY:                              # $CACC
		return
	fade.ask(0x05, 0xFF)                          # $CAD4 -- $F86D
	fade.at_pace(8)                               # $CAD7 -- $F861
	mode = DOOR_OUT                               # $CADA


## $CB78, mode $38 -- and once they are down, brought back at four.
func _door_out(host) -> void:
	_door_draw(host)                              # $CB78
	if fade.kind != 0:                            # $CB7B
		return
	fade.at_pace(4)                               # $CB7F -- $F865
	mode = DOOR_END                               # $CB82


## $CB85, mode $39 -- nothing is drawn any more; when the colours have come
## back the stage is played.
func _door_end(_host) -> void:
	fade.tick()                                   # $CB85 -- $F806
	if fade.kind == 0:                            # $CB88
		mode = PLAY                               # $CB8C


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
	z05ab = 0xFE                                  # $DB27 -- $05AB
	fade.ask(0xFE, 0xFE)                          # $DB2C -- $F849, A still $FE
	fade.run()
	# $DB34 -- which of the two noises is asked for turns on $2D, which the
	# sound code keeps for itself and is not ported; what a stage that is not
	# the last asks for is $0C.
	noise = 0x0C
	scroll_y = 0xEF                               # $DB43 -- $0B, which $C535 writes


## $DBAE, mode $1A -- STAGE SELECT.  The board comes up the screen out of $0B,
## a picture drops into each of the five frames in turn, and then either the
## game picks the next stage itself -- which is what it does while there are
## stages left undone -- or, once all five are done with, the player picks.
##
## $2D is which stages are done with, a bit apiece, and $DD7D asks whether all
## five are.  Nothing in the port sets it yet: the end of a stage is the
## stage's own script, and no script is ported, so the port always plays the
## half of this the game plays on the way to the next stage.
func _chosen(host) -> void:
	SolBoard.load_data()
	_ca9a(host)                                   # $DBAE
	# $DD65 -- while a stage is left undone the whole picture is tinted, by
	# putting three bits of $0C into $09, the byte the picture unit is shown.
	# The engine has no such byte and the tint is not ported.
	var t = host.flow_table()
	# $DBB7 -- the man below the board, at $80 across and $B0 down plus an
	# eighth of how far the board still has to come; which of his two pictures
	# is drawn turns on $0C.
	SolSprites.plain(MAN + ((clock >> 1) & 1), 0x00,
			0x80, (0xB0 + (scroll_y >> 3)) & 0xFF, t)
	if z4f != 0:                                  # $DBDF -- already picking
		_board_run(host)
		return
	if _all_done():                               # $DBE3 -- $DD7D
		# Every stage done with: the board picks for itself, over a wait the
		# cartridge keeps in $05AB.  While one is left the player picks, and
		# the walk falls straight through to the START below.
		if (clock & 0x01) != 0:                   # $DBE8
			_board_wait(host)
			return
		z05ab = (z05ab - 1) & 0xFF                # $DBED
		if z05ab != 0:
			_board_wait(host)
			return
		z05ab = (z05ab + 1) & 0xFF                # $DBF2
		if scroll_y == 0:
			_board_run(host)
			return
	if (host.flow_pad_new() & Pad.START) == 0:    # $DBF9
		_board_wait(host)
		return
	if scroll_y == 0:                             # $DBFF
		# $DC1B -- START on a stage already done with does nothing at all.
		if ((z2d >> z4c) & 1) == 0:
			_board_run(host)
		else:
			_board_mark(host)
		return
	if scroll_y >= 0x20 and not _all_done():      # $DC03 and $DC07
		fade.ask_more(0x06, 0xE0)                 # $DC0C -- $DCE5
		scroll_y = 0x20                           # $DC11
	_board_mark(host)                             # $DC15


## $DD7D -- whether every one of the five stages is done with.
func _all_done() -> bool:
	return (z2d & 0x1F) == 0x1F


## $DC28 and $DC47 -- the picking itself, once it has been set off.  $4F counts
## it: the five frames are written over one at a time, then the tune is changed
## and the colours walked, and at the end the mode goes on to the flash.  Once
## every stage is done with the count only moves one picture in sixty four and
## the whole thing is a good deal slower; while one is left it moves every
## picture and the walk is over in a fifth of the turns.
func _board_run(host) -> void:
	var done := _all_done()
	if done and (clock & 0x3F) != 0:              # $DC2D
		return
	var pic := (z4c + 1) & 0xFF                   # $DC33 and $DC47
	z4f = (z4f + 1) & 0xFF
	if z4f < 0x06:                                # $DC3A and $DC4E
		z4d = pic                                 # $DC5D
		_board_write(host, z4f, pic)
		return
	if not done and z4f == 0x06:                  # $DC52
		noise = 0x0F                              # $DC62
		_board_names()
		return
	if z4f == (0x0A if done else 0x20):           # $DC40 and $DC56
		fade.at_pace(8)                           # $DC6D -- $F861
		fade.ask(0x03, 0x08)                      # $F86D 3/8
		return
	if z4f >= (0x0E if done else 0xC0):           # $DC44 and $DC5A
		mode = AREA                               # $DC77


## $DD1B -- the names above the board, which is the table at $8340 walked in
## over the seven palettes the board itself is not drawn in.
func _board_names() -> void:
	fade.name_table(0x8340)                       # $E9B1 A=$40 Y=$83
	fade.ask_more(0x06, 0x17)                     # $DD22


## $DC80 -- nothing asked for.  While the board is still coming up there is
## nothing to do but walk it; once it is up, and while a stage is left to pick,
## the pad moves the pointer about the five.
func _board_wait(host) -> void:
	if scroll_y != 0:                             # $DC80
		_board_mark(host)
		return
	if _all_done():                               # $DC84
		z4e = 0x06                                # $DC89 -- the sixth of $DD5E
		_board_mark(host)
		return
	var hit: int = host.flow_pad_new()            # $DC8F
	var by := 0
	if (hit & Pad.SELECT) != 0:                   # $DC91
		by = 1
	elif (hit & Pad.RIGHT) != 0:                  # $DC9B
		by = 1
	elif (hit & Pad.LEFT) != 0:                   # $DCA0
		by = -1
	elif (hit & Pad.DOWN) != 0:                   # $DCA5
		by = 3
	elif (hit & Pad.UP) != 0:                     # $DCAA
		by = -3
	else:
		_board_mark(host)
		return
	var to: int = (z4e + by) & 0xFF               # $DCB1
	if to < 0x06:
		z4e = to
	_board_mark(host)


## $DCBB -- which frame the pointer is on, which stage that is, and one step of
## the board's walk up the screen.
func _board_mark(host) -> void:
	z4c = int(SolBoard.pick[z4e])                 # $DCBD
	stage = int(SolBoard.stage[z4c])              # $DCC2
	z2e = 0                                       # $DCC7
	if scroll_y == 0:                             # $DCCB
		_board_fill(host)
		return
	var was := scroll_y
	scroll_y = (scroll_y - 1) & 0xFF              # $DCCF
	if was == 0xEF:                               # $DCD1
		fade.ask_more(0x06, 0xE0)                 # $DCE5
	elif was == 0x20:                             # $DCD9
		fade.at_pace(4)                           # $DCDD -- $F865
		fade.ask_more(0x06, 0x0F)


## $DCEE -- the board is up, and the five frames fill one at a time: a step of
## the colours, then a frame, then a step again.
func _board_fill(host) -> void:
	if z4d == 0x05:                               # $DCEE
		_board_pointer(host)
		return
	if fade.kind != 0:                            # $DCF4 -- one at a time
		return
	if fade.pace != 0x01:                         # $DCF8
		fade.at_pace(1)                           # $DCFE
		fade.ask_more(0x03, 0x07)                 # $DD02
		return
	z4d = (z4d + 1) & 0xFF                        # $DD0D
	_board_write(host, z4d, z4d)
	if z4d == 0x05:                               # $DD17
		_board_names()


## $DD2D -- the pointer over the frame it stands on, blinking every other pair
## of pictures.  Once every stage is done with there is nothing left to pick
## and no pointer is drawn.
func _board_pointer(host) -> void:
	if _all_done():                               # $DD2D
		return
	if (clock & 0x02) != 0:                       # $DD32
		return
	SolSprites.forward(MARK, 0x00, int(SolBoard.mark_x[z4e]),
			int(SolBoard.mark_y[z4e]), host.flow_table())


## $DD84 -- one frame written over.  $DDDE looks at $2D by way of $4D: a frame
## whose stage is done with is given the empty picture instead of its own.
func _board_write(host, n: int, pic: int) -> void:
	if z4d > 0 and ((z2d >> (z4d - 1)) & 1) != 0:
		pic = 0
	SolBoard.write(host, n, pic)


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


## $D79F, modes $10, $11 and $24 -- TEST MODE laid out: the picture blanked,
## the four kilobytes it is drawn out of taken, screen $19 drawn and twenty
## colours of the mode's own written straight in.  $0D is set here, and dying
## with no try left reads it: once the menu has been opened, a death goes back
## to it instead of to GAME OVER.
func _test_lay(host) -> void:
	# $D79F -- $C5C9, which writes the thirty two black and then puts every
	# one of the sixty four sprites out of the picture.  The black does not
	# stand: $C6E9 below writes the table that was standing back over it.
	_no_sprites(host)                             # $C5CF -- $C618 with $0C
	_screen("test", 0x00, 0x02)                   # $D7A2 -- $D81F, $D7A9
	z0d = SolTest.screen()                        # $D7A5, which dying reads
	z2e = 0                                       # $D7AF -- $DAD8
	z4c = 0
	z4d = 0
	z4e = 0
	z4f = 0
	mode = TEST_MENU                              # $D7B1
	z59 = (z59 + 1) & 0xFF                        # $D7B3
	# $D7B7 -- $C6E9 with X = $13: twenty out of the table at $D485 and the
	# twenty first as the backdrop, so nine of the thirty two are left as the
	# title wrote them.  The screen's own are not taken.
	pal_direct = false
	fade.take(SolTest.table(), SolTest.menu_n())
	z7d = 0                                       # $D7BC -- $E105


## $D7C2, mode $25 -- the menu walked.  SELECT steps the cursor down the nine
## lines and round again, START takes the line it stands on.
func _test_menu(host) -> void:
	var t = host.flow_table()
	t.oam[0] = 0xF7                               # $D7C2 -- the cursor away
	var pad: int = host.flow_pad_new()            # $D7C7 -- $C882
	if (pad & Pad.START) != 0:                    # $D7CA
		# $D7D0 -- $C5C9, which is not only the thirty two written black:
		# $C5DA wipes both name tables as well, so the board stands empty
		# until whatever the line leads to lays its own.
		fade.blank()
		screen = ""
		mode = SolTest.goes(z4c)                  # $D7D8 -- $D816
	elif (pad & Pad.SELECT) != 0:                 # $D7DF
		noise2 = 0x02                             # $D7E5 -- $F1
		z4c += 1
		if z4c >= SolTest.lines():                # $D7ED
			z4c = 0
	# $D7F5 -- and the cursor put back, on the line it now stands on.  It is
	# put back even on the turn the line was taken.
	t.oam[0] = SolTest.cursor_y(z4c)
	t.oam[3] = SolTest.cursor_x()
	t.oam[1] = SolTest.cursor_tile()
	t.oam[2] = 0x00


## $CA7D..$CA91 and $D930, modes $30, $41, $42 and $48..$4B -- a stage named
## and asked for.  Seven of the nine lines of the menu are nothing else.
func _test_stage() -> void:
	stage = SolTest.stage_of(mode)                # $CA91 -- $55
	mode = RAISE                                  # $1D


## $E09C, mode $1B -- AREA CLEARED.  The screen is laid, what the game has
## scored is written into it, the eight bands the beam is cut into are set up,
## and the mode walks straight on to the paying out below.
func _area_clear(host) -> void:
	# $D81F -- the four kilobytes the screen is drawn out of; $C5C9 -- the
	# thirty two written black, every sprite put out of the picture and both
	# boards wiped.
	fade.blank()                                  # $E09F -> $C5C9 -> $C5B0
	_no_sprites(host)                             # $C5CC -- $C618 with $0C
	_screen("cleared", 0x00, 0x02)                # $D81F, then $EF8C A=$15
	scroll_x = 0                                  # $C578 -- $0A and $0B
	scroll_y = 0
	# $E0C3 -- $E237 lays the ground and the plate of the area, and $E0C6 the
	# second plate on top of those.  The laying wipes the board, so the count
	# is written after it here and not before it as in the cartridge.
	host.flow_relay([SolOver.clear_screen()] + SolOver.plate(stage)
			+ [SolOver.clear_plate(stage)])
	# $E0A7 -- $EC5D turns what the game has scored into six digits and $EF84
	# writes them at $21D0.
	SolOver.write(host, int(SolOver.clear_at()[0]), score)
	mode = PAYING                                 # $E0D2 -- INC $02
	z4c = 0                                       # $E0D4 -- $DAD8
	z4d = 0
	z4e = 0
	z4f = 0
	fade.name_table(0x8320)                       # $E0D7 -- $E9B1 A=$20 Y=$83
	# $E0DE -- $F83D on its own, which is not $C6E9's $F861 and $F83D: every
	# level back to nought and the table written out there, at whatever pace
	# was standing.
	for i in range(8):
		fade.level[i] = 0
	fade.ask(SolFade.ONCE, SolFade.ONCE)
	fade.run()
	z7d = 0x3F                                    # $E0E1 -- $E10A
	z75 = 0x3C
	# $C618 with bit seven -- the whole of $0700 is wiped bar eleven places in
	# every sixteen below $0780, which is what leaves the five lines of BEST 5
	# and the tries left standing and takes the two GAME OVER counts its asking
	# by.
	z0752 = 0
	z0753 = 0
	# $E0E4 -- and then the eight bands: how many lines each is out of $E100,
	# the first page, and nothing along.
	var bands: Array = SolOver.clear_bands()
	for i in range(8):
		z0740[i] = int(bands[i])
		z0750[i] = 1
		z0760[i] = 0
	noise = 0x08                                  # $E0F9 -- $F0


## $E117, mode $1C -- and what the clearing owes paid out.  $4D says which of
## nine steps it stands on, and $E11C is the table of the nine.  Every step
## but the last writes the three counts into the screen again ($E28C) and
## walks the band the writing stands in along ($E255); which of the two comes
## first is the step's own business, and so is whether it does both.
func _area_pay(host) -> void:
	match z4d:
		0, 6:                                     # $E12E
			_pay_draw(host)
			_pay_tick()
			_pay_bands()
		1:                                        # $E17C
			# The tune the clearing is played to, waited out.  No tune is
			# made here, so the host says at once that it is over; a walk
			# that wants the cartridge's own waiting says when.
			if host.flow_tune_end():
				z4d += 1
			_pay_draw(host)
			_pay_tick()
		2:                                        # $E185
			_pay_bonus(host)
			_pay_draw(host)
			_pay_tick()
		3, 5:                                     # $E173
			z4c = (z4c - 1) & 0xFF
			if z4c == 0:
				z4d += 1
			_pay_draw(host)
			_pay_tick()
		4:                                        # $E1C3
			_pay_suits(host)
			_pay_draw(host)
			_pay_tick()
		7:                                        # $E1E8
			fade.ask(SolFade.DOWN, 0xFF)          # $F86D A=$01 Y=$FF
			z4d += 1
			_pay_draw(host)
		8:                                        # $E1F4
			_pay_end(host)


## $E134 -- the seven bands that move: the even ones eight points along and
## the odd ones eight points back, which is what slides the two halves of the
## writing apart.  The fifth is left alone because $E255 walks that one, and
## it is the one the counts are written in.  $E15D then puts eight on $4C, and
## the step is over when that comes round -- two and thirty pictures.
func _pay_bands() -> void:
	for i in range(7, -1, -1):
		if i == 4:
			continue
		if (i & 0x01) == 0:
			var up: int = z0760[i] + 0x08
			z0760[i] = up & 0xFF
			if up > 0xFF:
				z0750[i] = (z0750[i] + 1) & 0xFF
		else:
			var down: int = z0760[i] - 0x08
			z0760[i] = down & 0xFF
			if down < 0:
				z0750[i] = (z0750[i] - 1) & 0xFF
	var n: int = z4c + 0x08
	z4c = n & 0xFF
	if n > 0xFF:
		z4c = 0x80
		z4d += 1


## $E255 -- the fifth band, one point along every fourth picture.
func _pay_tick() -> void:
	if (clock & 0x03) != 0:
		return
	z0760[4] = (z0760[4] + 1) & 0xFF
	if z0760[4] == 0:
		z0750[4] = (z0750[4] + 1) & 0xFF


## $E185, step two -- what is still to be paid handed over to the count, ten a
## picture while more than a page of it is left and one a picture after that.
## When there is none left the step is over and the next waits $80 pictures.
func _pay_bonus(host) -> void:
	var owed: int = owed_of(host)
	if owed == 0:
		z4c = SolOver.pay_wait()                  # $E18D
		z4d += 1
		return
	var by: int = SolOver.pay_one()               # $E196
	if (owed >> 8) != 0:
		by = SolOver.pay_ten()
	set_owed_of(host, (owed - by) & 0xFFFF)         # $E1A1
	score = (score + by) & 0xFFFFFF               # $E1AF -- $E3D3 A=by Y=0
	if (clock & 0x07) == 0:                       # $E1B6
		noise2 = 0x04


## $E1C3, step four -- and the suits still on him, one every sixteenth picture
## and $012C on the count for each.
func _pay_suits(host) -> void:
	var left: int = suits_of(host)
	if left == 0:
		z4c = SolOver.pay_wait()                  # $E1C8
		z4d += 1
		return
	if (tick & 0x0F) != 0:                        # $E1D1 -- $00 and not $0C
		return
	noise2 = 0x04                                 # $E1D7
	set_suits_of(host, left - 1)
	score = (score + SolOver.pay_suit()) & 0xFFFFFF


## $E1F4, the last step -- the picture walked down to black, and at the bottom
## of it the bit of $2D that says this area is done with.
func _pay_end(host) -> void:
	fade.tick()                                   # $F806
	if fade.kind != 0:                            # $E1F7 -- $26
		# $E1FB -- $05F0, which says the queue of writing is empty.  The
		# engine writes into the board straight and keeps no queue.
		_pay_tick()
		return
	screen = ""                                   # $E203 -- $C578 and $C5DA
	scroll_x = 0
	scroll_y = 0
	z7d = 0                                       # $E206 -- $E105
	# $E20F -- the area the stage belongs to, through the same $E223 the plate
	# came from.  The first area is the one the game opens on: it sets no bit
	# and names the stage that follows outright.  Every other one turns its
	# bit on in $2D, which is what STAGE SELECT reads and what says the game
	# is over when all five stand.
	var area: int = SolOver.area_of(stage)
	if area == 0:
		stage = 0x01                              # $E264
	else:
		z2d |= 1 << (area - 1)                    # $E27F
	mode = PICK                                   # $19


## $E33A, mode $4C -- the game is over and won.  The bonus is worked out and
## added to the count, screen $39 is laid over a board wiped to sky, and the
## view is put where the sunrise starts from.
func _end_pay(host) -> void:
	scroll_x = 0                                  # $C578 -- $0A and $0B
	scroll_y = 0
	fade.blank()                                  # $C5B0
	# $E39D -- a thousand for every try left, a thousand for as many as the
	# satellite stands past a multiple of eight, ten thousand for finishing,
	# and a hundred thousand more where GAME OVER and TEST MODE were never
	# seen.  $59 is what says so.
	score = (score + SolEnd.bonus(lives, sat_of(host), z59 == 0)) & 0xFFFFFF
	_no_sprites(host)                             # $E343 -- $C618 with $0C
	# $E350 wipes both boards with $0F and $E353 the second back to nought,
	# which the scene carries as its own wipe; $E35F then lays screen $39.
	var pair: Array = SolEnd.chr_pair()           # $E356 -- $C925
	_screen("bonus", int(pair[0]), int(pair[1]))
	z4c = 0                                       # $E362 -- $DAD8
	z4d = 0x04                                    # $E365
	z4e = 0
	z4f = 0
	fade.take(SolEnd.one("bonus_table"), 0x20)    # $E36B -- $C6E9 with X = $1F
	# $E370 -- $05BC, $05BD and $05F8 are the beam's own and are not kept.
	z77 = 0
	z76 = 0x03                                    # $E37D
	z75 = 0xA8
	z72 = SolEnd.one("sun_from")                  # $E385
	for i in range(8, 0x10):                      # $E38E -- $0108..$010F
		fade.out[i] = 0x0F
	mode = END_SUN                                # $E398 -- INC $02


## $E421, mode $4D -- the sun comes up behind the count.  $4F says which of
## twenty one steps of $89A4 in bank twelve it stands on; the tiles it is drawn
## out of are turned over every sixteenth picture ($E4DD).
func _end_sun(_host) -> void:
	# $FBDB -- which trick the beam is running this picture was settled at the
	# top of it, out of the $7D the picture before left; so a trick asked for
	# now is not run until the next one.
	var split: bool = z70 == SolEnd.one("sun_trick")
	fade.tick()                                   # $F806
	match z4f:
		0:                                        # $89D3
			z7d = SolEnd.one("sun_trick")
			z4d = 0
			z4f += 1
			_sun_split()
		1:                                        # $89E0 -- a whole page held
			z4d = (z4d - 1) & 0xFF
			if z4d == 0:
				z4d = 0x01
				z4f += 1
		2:                                        # $8A6E
			_sun_row(0, 0x04)
		3:                                        # $8A53
			_sun_row(1, 0x04)
		4:                                        # $8A57
			_sun_row(2, 0x04)
		5:                                        # $8A5B
			_sun_row(3, 0x04)
		6:                                        # $8A5F
			_sun_row(4, 0x04)
		7:                                        # $8A63
			_sun_row(5, 0x04)
		8:                                        # $8A01
			noise = 0x0E
			fade.at_pace(0x20)
			z4f += 1
			fade.ask(0x06, 0x0C)
		9:                                        # $8A39
			_sun_row(6, 0xA0)
		10:                                       # $8A47
			_sun_walk(7, 0x40)
		11:                                       # $8A43
			_sun_walk(6, 0x40)
		12:                                       # $8A33
			_sun_walk(5, 0x40)
		13:                                       # $8A2F
			_sun_walk(4, 0x40)
		14:                                       # $8A2B
			_sun_walk(3, 0x40)
		15:                                       # $8A27
			_sun_walk(2, 0x40)
		16:                                       # $8A23
			_sun_walk(1, 0x40)
		17:                                       # $8A1F -- LDY #$00 and then
			# BNE, which never branches: what is taken is the three under it,
			# so the last of the eight is the second row over again and the
			# first is never reached at all on the way down.
			_sun_walk(1, 0x40)
		18:                                       # $8A14
			z4d = (z4d - 1) & 0xFF
			if z4d == 0:
				z4e = 0
				z4f += 1
		19:                                       # $89EB
			fade.at_pace(0x08)
			z4f += 1
			fade.ask(SolFade.DOWN, 0xFF)
		20:                                       # $89FA
			if fade.kind == 0:
				mode = STAFF                      # INC $02
	if split:
		# $C1DA -- what the beam's own stop leaves standing: it writes the
		# address it was handed and takes the one this picture worked out for
		# the next, the two halves the other way about.
		z77 = z73
		z76 = z74
	z70 = z7d
	_end_chr()


## $E4DD -- the second pair of kilobytes turned over every sixteenth picture,
## which is what makes the sky flicker.
func _end_chr() -> void:
	var pair: Array = SolEnd.chr_pair()
	var y: int = int(pair[1]) + (0x04 if (clock & 0x10) != 0 else 0)
	chr = PackedInt32Array([int(pair[0]), int(pair[0]) + 1, y, y + 1])


## $8A70 and $8A75 -- one row of the sunrise: three colours into $0101..$0103
## and three into $0105..$0107, held for as long as $4D says and then `next`
## pictures put on it for the row that follows.
func _sun_row(row: int, next: int) -> void:
	_sun_split()
	_sun_paint(row, next)


## $8A35 and $8A4B -- the same, with the view walked on a point first.
func _sun_walk(row: int, next: int) -> void:
	_sun_move()
	_sun_paint(row, next)


func _sun_paint(row: int, next: int) -> void:
	var two: Array = SolEnd.sun(row)
	for i in range(3):
		fade.out[0x01 + i] = int(two[0][i])       # $8A76
		fade.out[0x05 + i] = int(two[1][i])       # $8A88
	z4d = (z4d - 1) & 0xFF                        # $8A9B
	if z4d == 0:
		z4d = next
		z4f += 1


## $8ADA -- the view a point along every other picture, and $9E is as far as it
## goes.
func _sun_move() -> void:
	z72 = (z72 + (clock & 0x01)) & 0xFF
	if z72 >= SolEnd.one("sun_stop"):
		z72 = SolEnd.one("sun_top")
	_sun_split()


## $8AE9 -- where the beam is cut and what is shown below the cut, both worked
## out of the view.  The engine does not cut the beam; it keeps the three so
## that the sunrise can be judged against the cartridge.
func _sun_split() -> void:
	z75 = (((z72 & 0x07) ^ 0x07) + SolEnd.one("sun_line")) & 0xFF
	var v: int = (z72 & 0xF8) << 2
	z73 = v & 0xFF
	z74 = ((v >> 8) + 0x08) & 0xFF


## $E3E7, mode $4E -- the ground the names are shown over.  Both boards are
## wiped, screen $3A goes on, the thirty two of $8020 are walked up out of
## black, and the man is put down at $20 across.
func _end_staff(host) -> void:
	scroll_x = 0                                  # $C5C9 -- $C578
	scroll_y = 0
	fade.blank()                                  # $C5B0
	_no_sprites(host)                             # $C618 with $0C
	var pair: Array = SolEnd.chr_pair()           # $E3EA -- $C925
	_screen("staff", int(pair[0]), int(pair[1]))  # $E3F1 -- $EF8C A = $3A
	z4c = 0                                       # $E3F6 -- $DAD8
	z4d = 0
	z4e = 0
	z4f = 0
	z7d = 0                                       # $E3F9 -- and $A000 across
	# $C5DC wipes $2000 and $2400 under the mirroring $4C left standing, which
	# is across: both of those are the first kilobyte, so the second keeps
	# whatever the bonus screen wrote into it and is only turned back into
	# view by the $A000 above.
	screen_keep = 0x02
	z4c = SolEnd.one("walk_from")                 # $E3FE
	fade.count = fade.pace                        # $E404 -- $25 = $28
	# $E40C -- $E9B1 names $8020 and $CC43 copies it into $0790 and points the
	# walk at the copy, which is the same thirty two either way.
	fade.name_table(SolEnd.one("staff_table"))
	fade.dark()                                   # $E412 -- $F84F
	fade.ask(0x06, 0x0F)                          # $E415 -- $F86D
	mode = END_WALK                               # $E41C -- INC $02


## $E42F, mode $4F -- he walks in a point every other picture.  The names come
## up when he reaches $40 and the walk is over at $B8.
func _end_walk(host) -> void:
	z4f = SolEnd.walk_pic(0)                      # $E42F
	var at: int = (z4c + (clock & 0x01)) & 0xFF   # $E433
	if at == SolEnd.one("walk_ask"):
		fade.ask(0x06, 0xFF)                      # $E43F -- $F86D
	if at >= SolEnd.one("walk_end"):
		z4d = SolEnd.hold(0)                      # $E44B
		mode = END_HOLD
	z4c = at                                      # $E451
	_end_tail(host)


## $E456, mode $50 -- a hold of $C0 pictures with him standing where he stopped.
func _end_hold(host) -> void:
	z4d = (z4d - 1) & 0xFF
	if z4d == 0:
		z4d = SolEnd.hold(1)                      # $E45A
		mode = END_TURN
	_end_tail(host)


## $E463, mode $51 -- he turns to face the names, and $60 pictures more.
func _end_turn(host) -> void:
	z4f = SolEnd.walk_pic(1)                      # $E463
	z4d = (z4d - 1) & 0xFF
	if z4d == 0:
		z4d = 0                                   # $E46B -- a whole page to come
		mode = END_WAIT
	_end_tail(host)


## $E474, mode $52 -- the page, at the end of which the names begin to go down.
func _end_wait(host) -> void:
	z4d = (z4d - 1) & 0xFF
	if z4d == 0:
		z4e = 0                                   # $E478
		z05ab = SolEnd.one("ramp_wait")           # $E47C
		mode = END_DOWN
	z4f = SolEnd.walk_pic(2)                      # $E4A5
	_end_tail(host)


## $E486, mode $53, which is $80D3 in bank six -- three rows of colours out of
## $8138, one every eighth picture, and that is the names going down.  When the
## three are written $05AB is counted out a point every other picture: at $C0
## the last line is typed, and at nought the walk down is asked for.
func _end_down(host) -> void:
	if z4d == SolEnd.one("ramp_last"):            # $80D5
		if z05ab == SolEnd.one("ramp_say_at"):    # $80F1
			_end_say(host, SolEnd.one("ramp_say"))
		if (clock & 0x01) != 0:                   # $80FA
			z05ab = (z05ab - 1) & 0xFF
			if z05ab == 0:
				fade.ask(SolFade.DOWN, 0xFF)      # $8104
				mode = END_LAST                   # $810C
	else:
		z4e = (z4e + 1) & 0xFF                    # $80D9
		if (z4e & 0x07) == 0:
			_end_ramp(z4d)                        # $810F
			z4d = (z4d + 3) & 0xFF                # $80E7
	# $E49F -- the man is still drawn, but neither the walk of the colours nor
	# the turning over of the tiles is asked for again this picture.
	z4f = SolEnd.walk_pic(2)
	_end_man(host)


## $E494, mode $54 -- the walk down waited out, and then the names themselves.
func _end_last(host) -> void:
	fade.tick()                                   # $F806
	if fade.kind == 0:                            # $E497
		mode = CREDIT_PAL                         # $E49B -- $02 = $22
	z4f = SolEnd.walk_pic(2)                      # $E49F
	_end_man(host)


## $810F -- one row of the ramp written into eight of the thirty two, which is
## every palette but the backdrop of each.
func _end_ramp(row: int) -> void:
	var three: Array = SolEnd.ramp(row)
	for k in range(three.size()):
		var one: Array = three[k]
		for i in range(3):
			fade.out[k * 4 + 1 + i] = int(one[i])
			fade.table[k * 4 + 1 + i] = int(one[i])


## $8270 and $E28C together -- one of the twenty six lines written into the
## board where its own record says it goes.  The cartridge lays the record in
## $0301 and the picture unit writes it out between pictures; nothing reads it
## back, so the engine writes it straight.
func _end_say(host, i: int) -> void:
	var one: Dictionary = SolEnd.line(i)
	if one.is_empty():
		return
	var at: int = int(one["at"])
	var tiles: Array = one["tiles"]
	for k in range(tiles.size()):
		host.flow_poke(at + k, int(tiles[k]))


## $E4A9 -- a picture of the walk of the colours, the tiles turned over, and
## then the man.
func _end_tail(host) -> void:
	fade.tick()                                   # $F806
	_end_chr()                                    # $E4DD
	_end_man(host)


## $E4AF -- the sprite table put back to empty and the man laid into it at $4C
## across and $80 down, out of whichever picture the mode left on $4F.
func _end_man(host) -> void:
	var t = host.flow_table()
	SolSprites.reset(t, tick)                     # $C72D -- $00
	t.oam[0] = 0xF7                               # $E4B4
	t.fwd = 0                                     # $E4BA -- $6C
	SolSprites.plain((SolEnd.one("walk_page") << 8) | z4f, 0x00,
			z4c, SolEnd.one("walk_y"), t)         # $E4D6 -- $F3F9


## $E4E9, mode $22 -- both boards wiped and twenty of $D481 taken, which is the
## black the names are typed onto.
func _credit_pal(host) -> void:
	scroll_x = 0                                  # $C5C9 -- $C578
	scroll_y = 0
	fade.blank()                                  # $C5B0
	_no_sprites(host)                             # $C618 with $0C
	screen_wipe = true                            # $C5DC -- both boards nought
	_chr(0x00, 0x02)                              # $E4EC -- $D81F
	# $E4F1 -- $C6E9 with X = $13, which is twenty of the thirty two; the
	# other twelve are left as the screen before them wrote them.
	fade.take(SolEnd.one("credit_table"), SolEnd.one("credit_n"))
	z4c = 0                                       # $E4F6 -- $DAD8
	z4d = 0
	z4e = 0
	z4f = 0
	z7d = 0                                       # $E4F9
	z75 = 0x4E                                    # $E508
	z73 = 0x08
	z74 = 0xF7
	z0780.resize(0x80)                            # $E4FE -- $C618 with $80
	for i in range(0x80):
		z0780[i] = 0
	mode = CREDIT                                 # $E503 -- INC $02


## $E515, mode $23, which is the twenty one steps of $8836 in bank twelve --
## the names typed out one beat at a time.  A beat is five bytes of the stream
## in bank six and then one byte for every line it shows; the man walks in from
## the right while it stands, and when the stream runs out the game goes on to
## where a high score is typed in.
func _credits(host) -> void:
	_ca9a(host)                                   # $E515 -- $CA9A
	match z4f:
		0:                                        # $88DD
			scroll_y = 0x08
			z4c = 0
			z7d = 0
			z4f += 1
		1:                                        # $88EA
			man_t = 0                             # $B7AC
			man_i = 0
			_credit_beat()                        # $8180
		2:                                        # $88F1
			z58 = (z58 - 1) & 0xFF
			if z58 == 0:
				# The last beat names no picture at all, and that is the end
				# of the stream.
				if (man_pic_lo | (man_pic_hi & 0x1F)) != 0:
					z4f += 1
				else:
					z4f = 0x0D
			_credit_line(host)                    # $8269
		3:                                        # $88AD -- he walks home
			man_x = (man_x - SolEnd.one("man_step")) & 0xFFFF
			if (man_x >> 8) < SolEnd.one("man_home"):
				z4f += 1
			_credit_man(host)
		4:                                        # $889E -- and stands there
			if z05ab == 0:
				z4f += 1
			else:
				_man_pose(z05ab)                  # $8806 -- $B7BA
				if man_t == 0xFF:
					z4f += 1
			_credit_man(host)
		5:                                        # $891D
			z7d = SolEnd.one("staff_trick")
			_credit_man(host)
			_credit_bar()
		6:                                        # $8913
			_credit_man(host)
			z4c = (z4c - 1) & 0xFF
			if z4c == 0:
				z4f += 1
		7:                                        # $8943
			_credit_man(host)
			if (clock & 0x01) == 0:
				scroll_y = (scroll_y - 1) & 0xFF
				if scroll_y == 0:
					z4f += 1
		8:                                        # $8952
			for i in range(0x80):
				z0780[i] = 0
			z4c = 0xA0
			z4f += 1
		9:                                        # $8963 -- and straight on
			credit_at = SolEnd.erase_at()
			_credit_erase(host)
		10:                                       # $8975
			_credit_erase(host)
		11:                                       # $8916
			z4c = (z4c - 1) & 0xFF
			if z4c == 0:
				z4f += 1
		12:                                       # $890E -- and the next beat
			z4f = 0
		13:                                       # $8865
			chr[2] = 0x06                         # $41
			chr[3] = 0x07
			z4f += 1
			fade.ask(SolFade.DOWN, 0xFF)          # $882B
		14, 16:                                   # $887E
			if fade.kind == 0:
				z4f += 1
		15:                                       # $886D
			scroll_x = 0xFF
			scroll_y = 0
			z4f += 1
			fade.ask(0x05, 0xFF)
		17, 19:                                   # $8885
			z05ab = (z05ab - 1) & 0xFF
			if z05ab == 0:
				z4f += 1
		18:                                       # $888D
			z05ab = (z05ab - 1) & 0xFF
			if z05ab == 0:
				# $F8 -- the tune brought to a stop, which is the driver's own
				# and is not made here.
				z4f += 1
		20:                                       # $8899
			mode = TOP_ASK_END


## $8180 in bank six -- five bytes of the stream: the picture the man wears,
## the walk he does, which colours the beat is in and how many lines it shows.
func _credit_beat() -> void:
	var s: Array = SolEnd.stream()
	var y: int = z4e
	z4e = (z4e + 5) & 0xFF
	man_pic_lo = int(s[y])                        # $05A6
	man_pic_hi = int(s[y + 1])                    # $05A7
	z05ab = int(s[y + 2])                         # $05AB -- the walk
	z58 = int(s[y + 4])
	man_x = SolEnd.one("man_x")                   # $819F -- $81 and $80
	man_y = SolEnd.one("man_y")                   # $81A3 -- $83 and $82
	z4f += 1
	# $81AF -- the three the beat names, and then the three that are the same
	# whatever it names.  The first lands on $011D for every beat but the last,
	# because every one of them is three past a multiple of four.
	var pal: int = int(s[y + 3])
	_credit_hues((pal & 0x03) << 2, pal >> 2)
	var fixed: Array = SolEnd.beat_fixed()
	for k in range(3):
		_credit_hues(k * 4, int(fixed[k]))


## $81D1 -- three of the thirty two written out of $81E4.
func _credit_hues(x: int, y: int) -> void:
	var three: Array = SolEnd.beat_pal(y)
	for i in range(3):
		fade.out[0x11 + x + i] = int(three[i])


## $8269 -- one byte of the stream, which is one of the twenty six lines.
func _credit_line(host) -> void:
	var s: Array = SolEnd.stream()
	var i: int = int(s[z4e])
	z4e = (z4e + 1) & 0xFF
	_end_say(host, i)


## $88C0 and $944D -- the man where he stands, out of whichever picture the
## walk arrived at.  Facing the other way is the picture next door, not a mark.
func _credit_man(host) -> void:
	var id: int = man_pic_lo | ((man_pic_hi & 0x1F) << 8)
	if id == 0:
		return
	if (man_pic_hi & 0x80) != 0:                  # $05B2 -- $9458
		id = (id + 1) & 0xFFFF
	SolSprites.picture(id, 0x00, man_x, man_y, host.flow_table())


## $891D -- the pool the beam's own stop reads, filled a place at a time: $10
## more every picture, and when a place comes round to the top the next pair is
## begun.  Twelve pairs of them and the step is over.
func _credit_bar() -> void:
	var at: int = z4c
	var v: int = int(z0780[at]) + 0x10
	if v > 0xFF:
		v = 0xFF
		z4c = (z4c + 2) & 0xFF
		if z4c >= 0x18:
			z4f += 1
	z0780[at] = v
	z0780[at + 1] = v


## $8963 and $8975 -- three rows of twenty blanks a picture, six of them over
## the two pictures the step takes, which is a beat wiped off the board.
func _credit_erase(host) -> void:
	for _k in range(3):
		for x in range(SolEnd.one("erase_n")):
			host.flow_poke(credit_at + x, 0)
		credit_at = (credit_at + SolEnd.one("erase_step")) & 0xFFFF
	z4f += 1


## $B7BA -- the little walk the state itself wears.  Asking for the one already
## running changes nothing; asking for another starts it at its first step.
func _man_pose(id: int) -> void:
	if id != man_pose:
		man_pose = id                             # $B7BF
		man_t = 0                                 # $B7B1
		man_i = 0
	_man_reel(man_pose)


## $B7CE -- one picture of it.  A step whose length is $FF never ends, and the
## walk is a ring: running off the end comes back to the first step.
func _man_reel(id: int) -> void:
	SolSprites.load_data()
	if man_t != 0:                                # $B7D7
		if man_t == 0xFF:
			return
		man_t -= 1
		if man_t != 0:
			return
	var book: Array = SolSprites.scripts
	if id >= book.size():
		return
	var steps: Array = book[id]
	if steps.is_empty():
		return
	if man_i >= steps.size():
		man_i = 0                                 # $B837
	var one: Array = steps[man_i]
	man_t = int(one[0])
	man_pic_lo = int(one[1])
	man_pic_hi = int(one[2])
	man_i += 1


## $E28C -- the three counts written into the screen, which every step but the
## last does once a picture: what the game has scored at $21D0, the suits
## still on him at $2250 and what is still to be paid at $220F.
func _pay_draw(host) -> void:
	var at: Array = SolOver.clear_at()
	var rows: Array = [SolOver.score_tiles(score),
			SolOver.suit_bar(suits_of(host)),
			SolOver.owed_tiles(owed_of(host))]
	for k in range(3):
		var row: Array = rows[k]
		for i in range(row.size()):
			host.flow_poke(int(at[k]) + i, int(row[i]))


## $05C5 and $05C6:$05C7 -- how many suits are still on him and what is still
## to be paid.  The cartridge has one cell for each; the engine has two homes
## for the first, because the hero holds it and the pool is handed a copy of it
## every picture a stage is played ($CDBB).  So the suits are the hero's and
## the paying is the pool's, and a walk that stands on a screen and nothing
## else -- which has neither -- leaves both with the flow.
func sat_of(host) -> int:
	var pool = host.flow_pool()
	return int(pool.id[SolPlayer.SAT]) if pool != null else z060c


func set_sat_of(host, v: int) -> void:
	var pool = host.flow_pool()
	if pool != null:
		pool.id[SolPlayer.SAT] = v
	else:
		z060c = v


func suits_of(host) -> int:
	var p = host.flow_hero()
	return p.suit if p != null else z05c5


func set_suits_of(host, v: int) -> void:
	var p = host.flow_hero()
	if p != null:
		p.suit = v
	else:
		z05c5 = v


func owed_of(host) -> int:
	var pool = host.flow_pool()
	return pool.hero_bonus if pool != null else z05c6


func set_owed_of(host, v: int) -> void:
	var pool = host.flow_pool()
	if pool != null:
		pool.hero_bonus = v
	else:
		z05c6 = v


## $D847 -- the number a test stands on, written into the board as two digits,
## and the same number taken as the second pair of kilobytes the screen is
## drawn out of.
func _test_number(host) -> void:
	var n: int = z4c & 0x7F
	_chr(chr[0], n)                               # $D84B -- $41
	var at: int = SolTest.number_at()
	host.flow_poke(at, SolOver.digits(n / 10)[5])
	host.flow_poke(at + 1, SolOver.digits(n % 10)[5])


## $D863 and $D8C7, modes $2A and $33 -- the two tests drawn: BGM TEST on
## screen $1B and the sound test on screen $2F.
func _test_draw(host, bgm: bool) -> void:
	_no_sprites(host)                             # $D863 -- $C5C9
	_screen("bgm" if bgm else "sound", 0x00, 0x02)
	z2e = 0                                       # $DAD8
	z4c = 0
	z4d = 0
	z4e = 0
	z4f = 0
	_test_number(host)                            # $D847
	mode = (mode + 1) & 0xFF                      # $D875
	# $D876 -- $C6E9 with X = $0F: sixteen out of the same table and the
	# seventeenth as the backdrop.
	pal_direct = false
	fade.take(SolTest.table(), SolTest.test_n())


## $D880 and $D8E4, modes $2B and $34 -- a test walked.  A and B walk the
## number, SELECT asks for what it names, START goes back to the menu.
func _test_wait(host, bgm: bool) -> void:
	var pad: int = host.flow_pad_new()            # $D883 -- $C882
	if (pad & Pad.START) != 0:
		mode = TEST_LAY                           # $D889
		return
	if (pad & (Pad.A | Pad.B)) != 0:              # $D88E
		if (pad & Pad.A) != 0:
			z4c = (z4c + 1) & 0xFF                # $D896
		else:
			z4c = (z4c - 1) & 0xFF                # $D89B -- $FF goes round
		if z4c >= (SolTest.bgm_n() if bgm else SolTest.sound_n()):
			z4c = 0                               # $D8A3
		_screen("bgm" if bgm else "sound", 0x00, 0x02)   # $D8A7 -- $C5C9
		_test_number(host)
		pal_direct = false                        # $D8B2 -- $C6E9 X = $0F
		fade.take(SolTest.table(), SolTest.test_n())
	if (pad & Pad.SELECT) != 0:                   # $D8BC
		if bgm:
			noise = z4c                           # $D8C2 -- $F0
		else:
			noise2 = z4c                          # $D926 -- $F1


## $D974, mode $14 -- no tries left.  The screen is drawn, the two counts are
## written into it, and the plate of the stage the game was left in is laid
## over the ground $E237 draws under it.
func _over(host) -> void:
	fade.blank()                                  # $D974 -- $C5C9
	_no_sprites(host)                             # $C5CC -- $C618 with $0C
	z2e = 0                                       # $D97C
	if z59 != 0xFF:                               # $D97E -- it stops at $FF
		z59 += 1
	noise = 0x09                                  # $D986
	screen = "over"                               # $D98A -- $EF8C A=$14
	chr = PackedInt32Array()
	mode = OVER_WAIT                              # $D9BB
	# $D9BF -- $C6E9 X=$1F: the thirty two are written straight, which is the
	# screen's own.  It is said before the screen is laid, because the laying
	# is what hands them over.
	pal_direct = true
	fade.full()
	# $E237 draws the ground and one of thirteen plates.  In the cartridge
	# both go into the queue behind the counts; here the laying wipes the
	# board, so it goes first and the counts are written over it.
	host.flow_relay([0x14] + SolOver.plate(stage))
	# $D98D -- the top of the five, and $D9AA -- what this game scored.
	SolOver.write(host, SolOver.over_score_at(), int(best_scores[4]))
	SolOver.write(host, SolOver.over_best_at(), score)
	z4c = 0                                       # $D9C4 -- $DAD8
	z4d = 0
	z4e = 0
	z4f = 0
	z7d = 0x3F                                    # $D9C7 -- $E10A
	z0752 = 1                                     # $D9D9
	z0753 = 1
	lives = 0x02                                  # $D9E3 -- $071C


## $DA52, mode $15 -- GAME OVER waited on.  A cursor stands beside one of the
## two lines, SELECT moves it, and START takes it.
func _over_wait(host) -> void:
	var hit: int = host.flow_pad_new()
	if z0753 != 0:                                # $DA58
		# The press that brought the screen up must not be read as the answer
		# to it: the first START seen is swallowed and the asking begins.
		if (hit & Pad.START) == 0:                # $DA61
			return
		z0752 = 0                                 # $DA73
		z0753 = 0
		return
	if (hit & Pad.START) == 0:                    # $DA68
		if (hit & Pad.SELECT) != 0:               # $DAB0
			noise2 = 0x02                         # $DAB6 -- $F1
			z4d = (z4d + 1) & 0xFF
		_over_mark(host)                          # $DABC
		return
	if z0752 != 0:                                # $DA6E
		z0752 = 0
		z0753 = 0
		return
	if (z4d & 0x01) == 0:                         # $DA7C -- CONTINUE
		mode = AGAIN                              # $DAA1
		noise = 0x0F                              # $DAA3
		z4d = 0x80                                # $DAAB
		return
	z2d = 0                                       # $DA83 -- END: the game over
	z05a0 = 0
	stage = 0
	z7d = 0                                       # $DA8C -- $E105
	screen = ""                                   # $DA8F -- $C578 and $C5DA
	noise = 0x10                                  # $DA95
	mode = TOP_ASK                                # $DA9C -- the asking


## $C618 with bit two set -- every one of the sixty four sprites put out of
## the picture.  The screens that ask for it do so once and then leave the
## table alone, so what is written into it afterwards stands.
func _no_sprites(host) -> void:
	var t = host.flow_table()
	for i in range(256):
		t.oam[i] = 0xF7


## $DABC -- the cursor, which is one sprite: beside CONTINUE or beside END.
func _over_mark(host) -> void:
	var t = host.flow_table()
	t.oam[4] = 0x80 if (z4d & 0x01) == 0 else 0x90
	t.oam[5] = 0x1B
	t.oam[6] = 0x00
	t.oam[7] = 0x60


## $DA02, mode $47 -- CONTINUE taken.  $4D counts down from $80 while the
## chosen line blinks, and at the end the stage is raised again.
func _again(host) -> void:
	z4d = (z4d - 1) & 0xFF                        # $DA05
	if z4d != 0:
		if (z4d & 0x07) == 0:                     # $DA4A
			z0752 = (z0752 + 1) & 0xFF
		_over_mark(host)
		return
	lives = 0x02                                  # $DA0B -- $F8B9
	score = 0                                     # and $F8EC with it
	if stage == 0x08:                             # $DA0E
		stage = 0
		mode = RAISE                              # $DA32 -- $1D
	elif (z2d & 0x1F) != 0x1F:                    # $DA18
		mode = PICK                               # $DA36 -- $19
	else:
		if stage != 0x10:                         # $DA20
			stage = 0x10 if stage == 0x13 else 0x0F
		mode = RAISE                              # $DA32
	z7d = 0                                       # $DA3A -- $E105
	screen = ""                                   # $DA3D -- $C578 and $C5DA
	noise = 0x10                                  # $DA3E


## $D6CA, mode $0E -- BEST 5: the five counts and the five names, the biggest
## at the top.  The plate of the stage goes on it as well.
func _best(host) -> void:
	fade.blank()                                  # $D6D0 -- $C5C9
	_no_sprites(host)                             # $C5CC -- $C618 with $0C
	screen = "best"                               # $D6D6 -- $EF8C A=$12
	chr = PackedInt32Array()
	# $D6DE -- one on from whatever asked, which is $0F after BEST 5 itself
	# and $44 or $56 after the asking that types a name.
	mode = (mode + 1) & 0xFF
	# $D6E5 -- the thirty two stand at $83C0 in bank ten, and $C6E9 both
	# copies them out and leaves $20:$21 on them, so the walk that puts the
	# screen out again ($59) has them to walk from.
	fade.name_table(0x83C0)
	pal_direct = true                             # $D6E0 -- $C6E9 X=$1F
	fade.full()
	host.flow_relay([0x12] + SolOver.plate(stage))    # $D6DB -- $E237
	# $D6E7 -- $ED02 puts the five in order, the biggest last, which is the
	# line at the top.  The name goes with its count: the cartridge swaps all
	# six bytes at once.  Its own walk is kept as it is -- for every place
	# from the last down, everything below it that is not smaller changes
	# places with it.
	for x in range(4, -1, -1):
		for y in range(x, -1, -1):
			if y == x:
				continue
			if int(best_scores[y]) < int(best_scores[x]):
				continue
			var sc = best_scores[y]
			best_scores[y] = best_scores[x]
			best_scores[x] = sc
			var nm = best_names[y]
			best_names[y] = best_names[x]
			best_names[x] = nm
	var at: Array = SolOver.best_at()
	var names: Array = SolOver.name_at()
	for y in range(5):                            # $D6EC and $D728
		SolOver.write(host, int(at[y]), int(best_scores[y]))
		SolOver.write_name(host, int(names[y]), best_names[y])
	z7d = 0x3F                                    # $D760 -- $E10A


## $D77E, mode $0F -- BEST 5 waited on: any button, or $4C run out, and the
## opening goes round again.
func _best_wait(host) -> void:
	if (host.flow_pad_new() & 0xF0) == 0:         # $D784
		if (tick & 0x03) != 0:                    # $D78A -- $00
			return
		z4c = (z4c - 1) & 0xFF                    # $D790
		if z4c != 0:
			return
	z05a0 = (z05a0 + 1) & 0xFF                    # $D794
	z7d = 0                                       # $D797 -- $E105
	mode = CHOOSE                                 # $D79A


## $D4AD, modes $09..$0D, $43 and $55 -- did this game beat the lowest of the
## five?  If it did, the count goes in and three letters are typed for it; if
## not, the opening comes round again.
func _top_ask(host) -> void:
	if score < int(best_scores[0]):               # $D4AD -- $075B less $05FF
		if mode == TOP_ASK_END:                   # $D4D2
			mode = LAMP                           # $D4D6
			return
		lives = 0x02                              # $D4DA -- $F8B9
		score = 0                                 # and $F8EC with it
		mode = CHOOSE                             # $D4DD
		return
	best_scores[0] = score                        # $D4E2 -- the lowest is taken
	best_names[0] = [0, 0, 0]                     # $D4F4
	# $D4FF -- $D6D0, which is BEST 5 whole: the screen, the plate, the five
	# put in order and written out, and $02 one on.
	_best(host)
	_name_bands(host)                             # $D502 -- $D681
	# $D505 -- the line the new count landed on is the one whose last letter
	# is nought, and it is looked for from the bottom up.
	var y := 4
	while y > 0 and int(best_names[y][2]) != 0:
		y -= 1
	z4d = y                                       # $D50F
	z4c = 0
	z4e = 0
	z4f = 0
	host.flow_lay_more(SolOver.name_screen(y))    # $D51B -- $EF8C A = $34 + Y
	noise = 0x0D                                  # $D51E


## $D681 -- the beam cut into eight bands for the panel: each band as many
## lines as the table says, every one showing the other page, and every one
## still off the side.  $C618 with $80 wipes the page the five lines are kept
## on first, all but the columns the five themselves stand in.
func _name_bands(host) -> void:
	z75 = 0x4F                                    # $D681
	z7d = 0x54                                    # $D685
	z0752 = 0                                     # $D689 -- $C618 with $80
	z0753 = 0
	var eight: Array = SolOver.split()            # $D690
	for x in range(8):
		z0740[x] = int(eight[x])
		z0750[x] = 0xFF
		z0760[x] = 0


## $D672 -- the fifth band slides by itself, one point every fourth picture.
func _band_five() -> void:
	if (clock & 0x03) != 0:                       # $D672
		return
	z0760[5] = (z0760[5] + 1) & 0xFF              # $D678 -- $0765
	if z0760[5] == 0:
		z0750[5] = (z0750[5] + 1) & 0xFF          # $D67D -- $0755


## $D615 and $D619 -- the two banks the letters are drawn out of.  $D525 turns
## them over every fourth picture and $D648 every picture.
func _letters_bank(i: int) -> void:
	var two: Array = SolOver.blink_at(i)
	fade.out[0x0A] = int(two[0])                  # $D61F -- $010A
	fade.out[0x0B] = int(two[1])                  # $D625 -- $010B


## $D6A5, modes $44 and $56 -- the five lines slide in, one after another,
## sixteen points at a time.
func _name_slide(_host) -> void:
	_letters_bank((clock >> 2) & 0x03)            # $D6A5 -- $D615
	var x: int = z4e                              # $D6A8
	if (z0750[x] & 0x01) != 0:                    # $D6AA -- the bit the ROR
		var n: int = z0760[x] + 0x10              # $D6B0 -- $0F and the carry
		z0760[x] = n & 0xFF
		if n > 0xFF:                              # $D6B8 -- all the way in
			z0750[x] = (z0750[x] + 1) & 0xFF
			z4e += 1
			if z4e == 5:                          # $D6C1
				mode = (mode + 1) & 0xFF
	_band_five()                                  # $D6C7


## $D5D6 -- the cursor beside the letter being typed, which shows for sixteen
## pictures out of thirty two.
func _name_mark(host) -> void:
	_letters_bank((clock >> 2) & 0x03)            # $D5D6 -- $D615
	var t = host.flow_table()
	t.oam[4] = 0xF8                               # $D5D9
	if (clock & 0x10) != 0:                       # $D5DE
		return
	t.oam[4] = SolOver.mark_y(z4d)                # $D5E6
	t.oam[7] = SolOver.mark_x(z4c)                # $D5EC
	t.oam[5] = SolOver.mark_tile()                # $D5F6
	t.oam[6] = 0x00                               # $D5FB


## $D525, modes $45 and $57 -- three letters typed.  UP and DOWN walk the
## alphabet, A takes the letter, B goes back one.
func _name_pick(host) -> void:
	SolSprites.reset(host.flow_table(), tick)     # $D525 -- $C72D
	_band_five()                                  # $D528
	_name_mark(host)                              # $D52B
	var hit: int = host.flow_pad_new()            # $D52E -- $C882
	if (hit & Pad.UP) != 0:                       # $D531
		z4f = (z4f - 1) & 0xFF
	if (hit & Pad.DOWN) != 0:                     # $D539
		z4f = (z4f + 1) & 0xFF
	if z4c != 0 and (hit & Pad.B) != 0:           # $D541 -- one back
		z4c -= 1
		z4f = SolOver.letter_place(int(best_names[z4d][z4c]))
	if (hit & Pad.A) != 0:                        # $D55E -- and one on
		z4c += 1
		noise2 = 0x0D
		if z4c == 3:                              # $D56A -- all three typed
			noise2 = 0x0E
			z4c = 0
			mode = (mode + 1) & 0xFF
			return
	if z4f >= 0x80:                               # $D579 -- past the first
		z4f = SolOver.letter_blank()
	elif z4f >= SolOver.letter_n():               # $D57D -- past the last
		z4f = 0
	# $D594 -- the letter is written into the screen every other picture, and
	# kept in the name every one.
	if (clock & 0x01) != 0:
		host.flow_poke(int(SolOver.name_at()[z4d]) + z4c,
				SolOver.letter_tile(z4f))
	best_names[z4d][z4c] = SolOver.letter_byte(z4f)


## $D648, modes $46 and $58 -- the name stands for a while and the screen is
## done with.
func _name_done(host) -> void:
	_band_five()                                  # $D648
	_letters_bank(clock & 0x03)                   # $D64B -- $D619 by $0C whole
	host.flow_table().oam[4] = 0xF8               # $D650
	z4c = (z4c - 1) & 0xFF                        # $D655
	if z4c != 0:
		return
	z7d = 0                                       # $D659 -- $E105
	if mode == NAME_DONE_END:                     # $D65E
		mode = LAMP
	else:
		lives = 0x02                              # $D666 -- $F8B9
		score = 0
		mode = CHOOSE
	noise = 0x10                                  # $D66D


## $D631, mode $59 -- the screen walked out to black.
func _lamp() -> void:
	fade.ask(SolFade.DOWN, SolFade.ONCE)          # $D631 -- $F86D
	mode = (mode + 1) & 0xFF                      # $D638


## $D63B, mode $5A -- and once it is out, the game begins again from the top.
func _lamp_wait(host) -> void:
	if fade.kind != 0:                            # $D63B
		fade.tick()                               # $D645 -- $F806
		return
	fade.blank()                                  # $D63F -- $C59C
	_restart(host)                                # $D642 -- $F97F


## $F97F -- the game begun again without the console being turned off: what a
## game leaves behind is cleared, the five lines are not.
func _restart(host) -> void:
	stage = 0                                     # $F981
	z2d = 0
	scroll_x = 0                                  # $F985 -- $0A and $0B
	scroll_y = 0
	lives = 0x02                                  # $F98F -- $F8B9
	score = 0
	z4c = 0                                       # $D13E -- $D162
	mode = MAKER                                  # $D153
	screen = ""
	host.flow_relay([])


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
