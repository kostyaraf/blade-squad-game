extends RefCounted
class_name Pb2Flow

## The tunes of the level's own flow: bank 14, $CE25, $CF42, $CF9F, $CFF7 and
## $D017.
##
## The cartridge keeps the flow in one byte, $1A, and a table of twelve entries
## at $CDD3 that says what each step of it does ($CA0B jumps through it).  Five
## of those steps ask the driver for something, and what they ask for is the
## only part of them this class holds:
##
##     2, 7, 11, 12   the stage's own tune               $CE25
##     6, 11          the one area with a tune of its own $CF42
##     6, 12          a boss's room                      $CF9F
##     8              he died                            $CFF7
##     10             and then be quiet                  $D017
##
## The port has no $1A.  Its flow is `main.gd` -- `_start_play`, `_next_area`,
## `_die` -- and the steps are collapsed into those, so what is ported here is
## not the machine but the five requests and the state each of them is gated
## on: the stage $53, the area $9C, which half of the stage $AD, and whether
## this is a boss's room $79.
##
## Every one of them hushes first ($EC0C), because a tune asked for over a
## tune that is still playing keeps whichever of the two is worth more
## ($80AC), and the flow wants the new one whatever it is worth.


## $CE3F -- one tune for each of the six stages.
const STAGE_TUNE := [0x3C, 0x3D, 0x3E, 0x3F, 0x40, 0x41]
## $CFAA -- one for each of the ten boss rooms, and only the sixth is its own.
const BOSS_TUNE := [0x46, 0x46, 0x46, 0x46, 0x46, 0x3B, 0x46, 0x46, 0x46, 0x46]
## $CE32 -- the last stage's nought-th area is the last boss, and he has a tune
## the stage does not.
const LAST_BOSS_TUNE := 0x13
## $CF55 -- the fourth stage's third area, first half, and nowhere else.
const SPECIAL_TUNE := 0x42
## $CFFD -- he died.
const DEATH_TUNE := 0x2B
## $CE28 and $CF6F -- the stage the two exceptions are on.
const LAST_STAGE := 5
## $D7E9 -- two areas to a stage: where the first half of it begins again and
## where the second does.  For the four stages that have a middle the first of
## the pair is the middle itself, which is what $D7FD says as well.
const HALF_AREA := [0x04, 0x06, 0x03, 0x07, 0x02, 0x06,
					0x04, 0x06, 0x03, 0x09, 0x00, 0x0D]
## $D7FD -- how far along each stage its middle is; the last two have none.
const MIDDLE_AREA := [0x04, 0x03, 0x02, 0x04, 0x00, 0x00]
## $E5B1 -- one bit of $56 for each stage, which is the suit that stage keeps.
const STAGE_BIT := [0x01, 0x02, 0x04, 0x08, 0x10, 0x20]


## $CE25 -- the stage's own tune, which is asked for at the top of a stage
## (step 2), when the stage is built again (7), when a life is spent (11) and
## when the game is continued (12).
static func stage_tune(stage: int, area: int) -> void:
	Pb2Sound.hush()                                    # $CE25
	# $CE28 -- the last stage's nought-th area is the last boss's room, and it
	# is the one area that does not take its stage's tune.
	if stage == LAST_STAGE and area == 0:
		Pb2Sound.want(LAST_BOSS_TUNE)                  # $CE34
		return
	Pb2Sound.want(STAGE_TUNE[stage])                   # $CE3C


## $CF9F -- a boss's room, picked by the area and not by the stage: nine of the
## ten rooms are the same tune and the sixth is its own.
static func boss_tune(area: int) -> void:
	Pb2Sound.hush()                                    # $CF9F
	Pb2Sound.want(BOSS_TUNE[area])                     # $CFA7


## $CF42 -- the area was built again (step 6), or a life was spent (11).  Two
## tunes can come of it: the one area that has its own, and then the room of a
## boss if that is what was built.
static func area_again(stage: int, area: int, phase: int, boss: int) -> void:
	# $CF42 -- the fourth stage's third area, and only its first half.
	if stage == 4 and area == 3 and phase == 0:
		Pb2Sound.hush()                                # $CF52
		Pb2Sound.want(SPECIAL_TUNE)                    # $CF57
	_boss_gate(stage, area, boss)


## $CF6B -- the tail the two steps that build an area share, which asks for a
## boss's tune only if a boss's room is what was built.  On the last stage the
## rooms that count are the nought-th and the fifth; the areas between them are
## the walk to the last boss and keep the stage's tune.
static func _boss_gate(stage: int, area: int, boss: int) -> void:
	if boss == 0:                                      # $CF6B
		return
	if stage == LAST_STAGE and area != 0 and area != 5:
		return                                         # $CF7B
	boss_tune(area)                                    # $CF7D


## $CFF7 -- step 8: he died.  The whole of the step's sound is the one tune,
## and the game then sits on step 9 until the dying is over.
static func died() -> void:
	Pb2Sound.hush()                                    # $CFFA
	Pb2Sound.want(DEATH_TUNE)                          # $CFFF


## $D017 -- step 10: the dying is over, but the tune of it is not, and the step
## holds the game still until $C8 -- the driver's first track -- has run out.
## Then it is hushed, and step 11 spends the life.
static func mourned() -> void:
	Pb2Sound.hush()                                    # $D01C


## $D7AB -- where a spent life puts him, which the tunes of step 11 are read
## from and not from the area he died in.  It answers [area, half].
##
## In the later half of a stage he goes to that half's own area ($D7E9); in the
## first half he goes back to the top of the stage, unless he had got past the
## middle of it and owns the suit that is kept there -- then the middle is
## where he starts, and the stage is in its later half from then on.
static func life_area(stage: int, area: int, phase: int, owned: int) -> Array:
	# $D7AF -- two areas to a stage, and $AD picks which: one is the first
	# half's own and two and above the second's.
	if phase != 0:
		return [HALF_AREA[stage * 2 + (0 if phase == 1 else 1)], phase]
	# $D7C7 -- the last two stages have no middle to go back to.
	if stage == 4 or stage == 5:
		return [0, 0]
	# $D7CF -- the bit of this stage in what he has found ($56), and how far
	# along the stage the middle is.
	if (STAGE_BIT[stage] & owned) == 0:
		return [0, 0]
	if area < MIDDLE_AREA[stage]:                      # $D7D8
		return [0, 0]
	return [MIDDLE_AREA[stage], 1]                     # $D7DD -> $D7F5


## $D022 -- step 11: the life is spent, the area is opened again and $79 is put
## back ($D02E), so the room of a boss is never what a spent life builds.  The
## area the tunes are read from is the one the life starts at ($D7AB), which is
## not the one he died in.
static func life_spent(stage: int, area: int, phase: int,
		owned: int) -> Array:
	var to: Array = life_area(stage, area, phase, owned)   # $D060
	stage_tune(stage, int(to[0]))                      # $D066
	area_again(stage, int(to[0]), int(to[1]), 0)       # $D069 -- $79 is nought
	return to


## $CFB4 -- step 12: the game was continued ($B0D7 gives back four lives).  The
## stage's tune, and then the same tail the sixth step ends with -- so a boss's
## room asks for its own tune, and the one area with a tune of its own does not
## get it, because step 12 comes in below that gate ($CF5A).
static func continued(stage: int, area: int, boss: int) -> void:
	stage_tune(stage, area)                            # $CFB4
	_boss_gate(stage, area, boss)                      # $CFB7 -> $CF5A


## $CFBA -- step 7: the stage was built again, which asks for the stage's tune
## and nothing else: it comes in at $CFC0, below both gates.
static func stage_again(stage: int, area: int) -> void:
	stage_tune(stage, area)                            # $CFCF
