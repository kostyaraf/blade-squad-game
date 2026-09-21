extends RefCounted
class_name Pb3Gear

## Э5.5 -- one bar for the two of them, and everything on it from the start.
##
## Three things had to be decided and each is named here rather than buried.
##
## **The bar is Power Blade's, and it is Power Blade's own class.**  Only one
## of the two games keeps a bar at all ($A0 with $9E behind it), so there was
## nothing to reconcile: the other game simply joins it.  Nothing about the
## wearing is rewritten -- each player is given a `Pb2Status` of his own and
## it does the whole of $CDB8 for him.  What is *his* stays his: the fraction
## a suit wears away at ($85:$86) belongs to the suit and two suits do not
## share it.  What is shared is the two numbers the cells live in, copied into
## each player before he is stepped and copied back out after, in the order
## the players come.  A second player therefore finds the bar as the first
## left it, which is what a shared bar means.
##
## **Everything is on it from the start.**  $D259 walks only the suits $56
## says he owns; here $56 is every one of them, so the ring is the whole five
## and plain Nova, which never had a bit, is still in it.  Solbrain's eight
## are not found by picking up letters either: the menu names them straight
## out of the same table $92CD reads ($8xxx `combos` and `weapon_of`), so what
## a player ends up holding is a satellite the cartridge could itself have
## given him, and not a new kind of thing.
##
## **What a Solbrain gun costs.**  Its own game charges it nothing by the
## picture: the satellite is not worn down, it is shot down.  $9347 gives it
## sixteen of life and whatever reaches it takes that off.  Sixteen is also
## how many cells the Power Blade bar holds (`cap_energy`), so a hit on the
## satellite costs one cell, one for one, and no number has to be invented
## between the two scales.  When the bar is dry each of them ends the way his
## own game ends him: $D312 takes the suit off, and $9347 without the life is
## how the satellite is taken away.
##
## `work/re/pb3_gear.md` has the reading behind it.

const PB2 := Pb3Pair.PB2
const SOL := Pb3Pair.SOL

## $D259's ring: plain Nova and the four he can own.
const SUITS := 5
## $92CD's eight combinations, which are the eight satellites.
const GUNS := 8

## Pad bits, the same in both games.
const START := 0x10
const UP := 0x08
const DOWN := 0x04

## Per player: which game he is, and the `Pb2Status` that does his wearing.
var who: Array[int] = []
var st: Array = []
## Which of the eight a Solbrain player is holding, one to eight; nought is
## none at all.
var gun: Array[int] = []
## Whether his side of the menu is open, and the pad as it stood last picture.
var open: Array[bool] = []
var last_pad: Array[int] = []

## The one bar.  $A0 and $9E, and nobody's but everybody's.
var energy := 0
var tanks := 0

## $D31D -- a change of suit empties what he has thrown.  One a player, put
## back by whoever keeps his table of things.
var clear_shots: Array[bool] = []

var _sat: Dictionary


func _init(kinds: Array, energy_: int = 16, tanks_: int = 0) -> void:
	energy = energy_
	tanks = tanks_
	_sat = Nes._load_json(Nes.DATA + "/sol/sat.json")
	for one in kinds:
		var k: int = one if one is int else (SOL if String(one) == "sol"
				else PB2)
		who.append(k)
		open.append(false)
		last_pad.append(0)
		clear_shots.append(false)
		gun.append(1 if k == SOL else 0)
		var s := Pb2Status.new()
		# $56 -- every suit at once, which is the whole of Э5.5 on this side.
		for m in s.cfg["own_mask"]:
			s.owned |= int(m)
		# The clock is the level's and not the gear's, and it is stopped by
		# leaving it nothing to count: $CA3A turns back the moment $52/$53
		# are both nought, which is where `Pb2Status` starts them.
		#
		# The other way of saying it -- the last stage's nought-th area,
		# which is how $CEEC is told a stage has no clock -- cannot be used
		# here, because $D0AC shuts the menu on exactly that triple, and a
		# bar that offers everything from the start is the whole of Э5.5.
		# The stand walks the menu out itself, and that is how it was found.
		st.append(s)


## One picture for each of them, in the order they come.  `hits` is what each
## newly pressed this picture, which is what $D0A6 and $D259 both read.
func step(hits: Array) -> void:
	for i in range(who.size()):
		var hit: int = int(hits[i]) if i < hits.size() else 0
		var s: Pb2Status = st[i]
		# The bar as the one before him left it.
		s.energy = energy
		s.tanks = tanks
		if who[i] == SOL:
			_gun_menu(i, hit, s)
		else:
			s.step(hit)
			if s.clear_shots:
				clear_shots[i] = true
				s.clear_shots = false
		energy = s.energy
		tanks = s.tanks


## The Solbrain side of the menu.  There is no cartridge for it -- his game
## never had one -- so it is the Power Blade menu's own shape: START opens and
## shuts it, UP and DOWN walk the ring, and the ring is the eight.
func _gun_menu(i: int, hit: int, s: Pb2Status) -> void:
	if (hit & START) != 0:
		open[i] = not open[i]
		return
	if not open[i]:
		return
	if (hit & UP) != 0:
		gun[i] = 1 if gun[i] >= GUNS else gun[i] + 1
	elif (hit & DOWN) != 0:
		gun[i] = GUNS if gun[i] <= 1 else gun[i] - 1


## $9347 -- something reached his satellite and took `n` off its sixteen.  The
## bar is the sixteen, so it is the bar that pays.  What is left of the blow
## once the bar is empty is dropped, the way a suit that has already come off
## is not taken off twice.
func hurt_gun(i: int, n: int) -> void:
	if who[i] != SOL or gun[i] == 0 or n <= 0:
		return
	var took: int = mini(n, energy)
	energy -= took
	if energy != 0:
		return
	if tanks != 0:
		# $D2FD -- a spare tank is drunk, and the same one for both of them.
		tanks -= 1
		energy = int((st[i] as Pb2Status).cfg["refill_tank"])
		return
	gun[i] = 0                              # $9347 with nothing to give


## Which suit a Power Blade player is wearing, and which gun a Solbrain one is
## holding.  Nought either way is none.
func pick(i: int) -> int:
	if who[i] == SOL:
		return gun[i]
	return (st[i] as Pb2Status).suit


## Put the chosen gun into a pool of things, as $92CD's own two numbers: which
## of the eight combinations it was, and what that combination gives.  A gun of
## nought takes the satellite away instead, which is $9347 without the life.
func arm(pool: SolObjects, i: int) -> void:
	if who[i] != SOL or pool == null:
		return
	var at: int = gun[i] - 1
	if at < 0:
		SolSat.lose(pool)               # $9359 and $A4FD, his own game's door
		return
	pool.mind[SolObjects.SAT] = at
	pool.id[SolObjects.SAT] = int(_sat["weapon_of"][at])
	pool.life[SolObjects.SAT] = 0x10


## Whether his side of the menu is open.  For a Power Blade player that is
## $4D; for a Solbrain one it is the same thing kept here.
func menu_open(i: int) -> bool:
	if who[i] == SOL:
		return open[i]
	return (st[i] as Pb2Status).menu != 0
