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
const RAISE := 0x1D         # $E520 -- raise the stage named in $55
const ASK := 0x24           # $D79F -- CONTINUE?
const ASKING := 0x25        # $D7C2 -- and what waits there
const RIDE := 0x2C          # $E9D2 -- the view lifted before he arrives
const RIDING := 0x2D        # $E9E3 -- and the wait while it settles
const BORN := 0x3E          # $CB96 -- he is put together out of four pieces
const BORNING := 0x3F       # $CC77 -- and they fly in

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

## True once a mode this does not port is reached, with its number in `stuck`.
var stuck := -1


## One picture: $C9B4.  `host` is what holds the stage itself and must answer
## `flow_raise(stage)`, `flow_play()`, `flow_hero()`, `flow_view()` and
## `flow_table()`; `main.gd` does.
func step(host) -> void:
	match mode:
		PLAY:
			host.flow_play()
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
			_pick()
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


## $E520 -- the screen is blanked, both nametables are wiped and the stage
## named in $55 is read in ($E708 reads its record, $E788 puts every spawn back
## and $E7A0 empties the hero); then he is put together.
##
## The blanking and the wiping are the console's and are not ported; what the
## stage is raised out of is `data/sol/levels/stageN.json`, which is the same
## record $E708 reads.
func _raise(host) -> void:
	host.flow_raise(stage)
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
	SolSprites.reset(t, tick)                     # $CA9A -> $C72D
	if piece_x[0] == p.x:                         # $CC7B, both bytes at once
		if z2e != 0:
			noise = z2e                           # $CC8F
		# $CC94 -- and the one that is let out where the four met.
		var pool = host.flow_pool()
		if pool != null:
			pool.hatch(p.x, p.y, 0x3F)
		mode = PLAY                               # $CC9F
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
		z57 = (z57 - 1) & 0xFF                    # $CCCC, which stops the walk
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


## $DAE3, mode $19 -- the stage picked is on its way in.  Stage nought is the
## one the game opens on and has no screen of its own, so it is raised at once;
## every other one is announced first, which is a screen and is not ported.
func _pick() -> void:
	mode = RAISE
	if stage != 0:
		stuck = PICK                              # $DAFB, the screen


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
