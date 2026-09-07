extends RefCounted
class_name Pb2Status

## What the game keeps about the man rather than about the level -- the suits.
##
## Four routines, and between them they are the whole of it:
##
##   $D0A6  START opens the pause menu, and START again either closes it or
##          begins the change into the suit he chose.
##   $D259  while it is open, UP and DOWN walk the ring of suits he owns.
##   $D2BE  a suit worn wears out: a fraction a frame off $85:$86, a cell off
##          $A0 when that runs under, a spare tank when the cells run out, and
##          the suit itself when the tanks do.
##   $B4CD  and the eight little routines that fill any of it back up.
##
## `work/re/pb2_suits.md` is the reading behind all of it.

## $27 -- what the game is doing.  Three is playing; the other three that
## matter here are the two refills and the change of suit.
const PLAY := 3
const REFILL_LIFE := 5
const REFILL_ENERGY := 6
const CHANGE := 7

## Pad bits as the cartridge orders them ($48).
const START := 0x10
const UP := 0x08
const DOWN := 0x04

var cfg: Dictionary

var mode := PLAY             ## $27
var suit := 0                ## $9A -- which suit he wears, nought for none
var owned := 0               ## $56 -- which he has found
var energy := 0              ## $A0 -- the suit's bar, up to sixteen
var tanks := 0               ## $9E -- spare suit energy
var life_tanks := 0          ## $9D -- spare health, which is not the suit's
var lives := 2               ## $9F
var drain_hi := 0            ## $85
var drain_lo := 0            ## $86
var menu := 0                ## $4D -- the pause menu is open
var came_in := 0             ## $AF -- the suit he opened the menu wearing
var chr_bank := 0x11         ## $45 -- the thousand bytes he is drawn from
var refill_life := 0         ## $2F
var refill_energy := 0       ## $30
var clock := 0               ## $1C -- the frame count the refills tick on
var stage := 0               ## $53
## Set whenever the suit changes, so that the picture knows to look again.
var repaint := true
## $D768 -- the change of suit empties the five slots his throws live in.
## Whoever keeps the table of things does it and puts this back.
var clear_shots := false


func _init() -> void:
	var f := FileAccess.open("res://data/pb2/status.json", FileAccess.READ)
	cfg = JSON.parse_string(f.get_as_text())


## One frame of it, in the cartridge's own order ($CDB8 onwards).  True means
## the level is to be stepped after this; false that it is not -- the menu
## freezes everything, and so do the two refills and the change of suit.
func step(hit: int) -> bool:
	clock = (clock + 1) & 0xFF
	_menu(hit)
	if menu != 0:
		# $CDC2: with the menu open only one of two things happens.
		if mode == CHANGE:
			_change()
		else:
			_cycle(hit)
		return false
	if mode == CHANGE:
		_change()
		return false
	if mode == REFILL_LIFE or mode == REFILL_ENERGY:
		_refill()
		return false
	_drain()                                # $CEFD
	# $8003 -- the level's own frame runs for anything under five.  Four is
	# the boss's meter filling: the hero still walks and the things still
	# get their turn, only the suit is not worn down and the menu is shut.
	return mode < REFILL_LIFE


## $D0A6 -- START, both ways round.
func _menu(hit: int) -> void:
	if mode == CHANGE:
		return
	if menu != 0:
		if not (hit & START):
			return
		# $D0DF: coming back to the suit he came in with is no change at all,
		# and neither is nothing to nothing.
		if suit == came_in:
			menu = 0
			return
		came_in = suit
		mode = CHANGE
		repaint = true
		clear_shots = true                  # $D0FE
		return
	if not (hit & START):
		return
	menu = 1
	came_in = suit


## $D259 -- UP for the next suit he owns, DOWN for the one before.  Index
## nought has no bit of its own and is always reachable, so plain Nova is
## always one of the choices.
func _cycle(hit: int) -> void:
	if mode != PLAY:
		return
	if energy == 0 and tanks == 0:
		return                              # $D25F: an empty suit has no menu
	if owned == 0:
		return
	var mask: Array = cfg["own_mask"]
	if hit & UP:
		var y: int = suit + 1
		while y < 5 and (owned & int(mask[y])) == 0:
			y += 1
		_wear(0 if y >= 5 else y)
	elif hit & DOWN:
		var y: int = (4 if suit == 0 else suit - 1)
		while y > 0 and (owned & int(mask[y])) == 0:
			y -= 1
		_wear(y)


## $D28C -- put one on: the suit, the tiles he is drawn from, and the picture.
func _wear(n: int) -> void:
	suit = n
	chr_bank = int(cfg["chr_plain"] if n == 0 else cfg["chr_suit"])
	repaint = true


## $F02B -- the change itself.  On the cartridge it waits for the fanfare to
## finish; here there is nothing to wait for, so it is over at once.
func _change() -> void:
	menu = 0
	mode = PLAY
	_wear(suit)


## $D2BE -- what wearing one costs.
func _drain() -> void:
	if mode == REFILL_ENERGY:
		return
	if suit == 0:
		return
	if energy == 0 and tanks == 0:
		return
	if energy != 0:
		var rate: int = int(cfg["drain"][suit - 1])
		var v: int = ((drain_hi << 8) | drain_lo) - rate
		if v >= 0:
			drain_hi = (v >> 8) & 0xFF
			drain_lo = v & 0xFF
			return
		# $D2ED: it ran under, so the pair is wound up again and a cell goes
		var reload: int = int(cfg["drain_reload"])
		drain_hi = (reload >> 8) & 0xFF
		drain_lo = reload & 0xFF
		energy -= 1
		if energy != 0:
			return
	# $D2FD: out of cells.  A spare tank is drunk if there is one.
	if tanks != 0:
		tanks -= 1
		refill_energy = int(cfg["refill_tank"])
		mode = REFILL_ENERGY
		return
	# $D312: and if there is not, the suit comes off.
	suit = 0
	chr_bank = int(cfg["chr_plain"])
	repaint = true
	clear_shots = true                      # $D31D


## $EFE1 and $F007 -- a cell every fourth frame until the bar is full or the
## pickup has given all it had.
func _refill() -> void:
	if (clock & (int(cfg["refill_every"]) - 1)) != 0:
		return
	if mode == REFILL_LIFE:
		if life >= int(cfg["cap_life"]):
			_done()
			return
		life += 1
		refill_life -= 1
		if refill_life == 0:
			_done()
	else:
		if energy >= int(cfg["cap_energy"]):
			_done()
			return
		energy += 1
		refill_energy -= 1
		if refill_energy == 0:
			_done()


func _done() -> void:
	mode = PLAY
	refill_life = 0
	refill_energy = 0


## $049A of his own place.  The table of things owns it, so it is lent here.
var life := 0x10
## $55, $A2 and $99 -- the blade's own three.  The table of things reads them
## when he throws; they are kept here because it is $B4CD that fills them.
var power_level := 0
var second_blade := 0
var extra_shot := 0


## $B4CD -- what a collectable gives him.  The subtype is the low nibble of the
## record's third byte.  A cap already reached is worth nothing at all: the
## thing is gone, and he is no better off.
func take(what: int) -> void:
	match what & 0x0F:
		0:                                  # $B503 -- health
			if life < int(cfg["cap_life"]):
				refill_life = int(cfg["refill_life"])
				mode = REFILL_LIFE
		1:                                  # $B51B -- suit energy
			if energy < int(cfg["cap_energy"]):
				refill_energy = int(cfg["refill_energy"])
				mode = REFILL_ENERGY
		2:                                  # $B532 -- a spare health tank
			if life_tanks < int(cfg["cap_life_tank"]):
				life_tanks += 1
		3:                                  # $B547 -- a spare suit tank
			if tanks < int(cfg["cap_energy_tank"]):
				tanks += 1
		4:                                  # $B58A -- the suit capsule
			owned ^= int(cfg["stage_bit"][stage & 7])
		5:                                  # $B55C -- the second blade
			if second_blade < int(cfg["cap_second"]):
				second_blade += 1
		6:                                  # $B569 -- the blade raised
			if power_level < int(cfg["cap_power"]):
				power_level += 1
		7:                                  # $B57C -- one more throw at once
			if extra_shot < int(cfg["cap_extra"]):
				extra_shot += 1


## $EE5D -- SELECT spends one spare health tank to fill the health bar.  It is
## not the suit menu, though it looks like it; the suits are on START.
func spend_life_tank() -> bool:
	if life_tanks == 0 or life >= int(cfg["cap_life"]):
		return false
	life_tanks -= 1
	refill_life = int(cfg["cap_life"])
	mode = REFILL_LIFE
	return true


## $D8E4 -- the three colours sprite palette one is given, which is the whole
## of what tells one suit from another.
func palette() -> Array:
	return cfg["suit_palette"][suit]
