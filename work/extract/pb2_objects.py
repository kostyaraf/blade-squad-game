#!/usr/bin/env python3
"""Export the tables that decide how an object leaves the screen.

Two things stand between a thing being in the table and getting a turn: the
class it belongs to for the purpose of being thrown away, and the margins that
class allows it past the edge.  Both are plain tables in bank 10; see section
10 of work/re/pb2_spawns.md.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import outdir, write_json, TOOLS                     # noqa: E402
sys.path.insert(0, TOOLS)
import pb2_spawns                                                # noqa: E402

NTYPES = 90                 # $8212 is exactly 90 bytes long
# $E5B1 in the fixed bank: which bit of $2B/$2C a collectable answers to.
# $E534 masks the record's top nibble with $0F and indexes this, so sixteen
# bytes are read even though only the first eight are bits.
PICKUP_BITS = 0xE5B1
NPICKUP = 16
# $8401 in bank 10: which picture a collectable wears.  $83F2 masks the record's
# third byte with $0F and indexes this; the run ends at $8409, which is the RTS
# the mind jumps to, so there are eight.
PICKUP_PIC = 0x8401
NPICKUP_PIC = 8
CLASSES = 0x8212
MARGINS = 0x820A            # four pairs: how far past the left / right edge

# The runs of pictures a thing walks through.  $E2D5 switches to bank pair 6/7
# and reads the table's address out of $802D there, so the table is in bank 6,
# not in the bank the mind itself lives in.  It is a table of words, and the
# first word is the address of the first record, so the count is the distance
# between them halved.
ANIM_PTR = 0x802D
# A record is three bytes -- last step, how many frames a step is held, the
# picture of the first step -- and the pictures of the rest follow it in order.
# When the top bit of the first byte is set the record is four, and the fourth
# says which run of offsets ($E39C in the fixed bank) the pictures come from
# instead.
ANIM_OFFSETS = 0xE39C

# Tables the minds read straight out of their own bank.
SWING = 0x9D72      # $19: how long it walks one way, by the record's nibble
SPIN_LO = 0x9EE1    # $10: eight turning speeds, low byte
SPIN_HI = 0x9EE9    # and high
TRIG = 0xF301       # $F2E6: a quarter turn of cosine, 65 entries
SNAP = 0xFD31       # $FD1D: how far to shift to sit on a tile's floor line
AIM = 0xF64F        # $F637: the same quarter turn again, but scaled to $20
ATAN = 0xF783       # $F6E2: how far round from the start of an eighth
OCTANT = 0xF76F     # $F746: where each eighth starts, and which way it runs
QUARTER = 0xF77F    # $F76B: the four corners, where the sides are equal

# --- Касание героя и вещи.  Всё в банке 7; см. work/re/pb2_contact.md. ---
# $B44F: насколько выше $04C6 лежит середина вещи по высоте, со знаком.
MIDDLE = 0xB44F
# $B3EF: сколько здоровья снимает с героя каждый тип.
HURT = 0xB3EF
# $B768: короб вещи.  Для типов меньше $50 -- слово в $B7DC, по нему пара
# байт (полуширина, полувысота).  Для $50 и выше -- слово в $B7A4, и там уже
# три пары: короб большой вещи меняется с её ходом ($5F).
BOX_LOW = 0xB7DC
# Банк 9, «вещи, на которые герой встаёт».  $BA44 берёт короб героя по счёту
# позы: указатели $BAEE/$BAF9 и одиннадцать записей за ними, а $BAE6 -- $011A
# по тому же счёту.  $B98A и $B990 -- то, чем $B91C выбирает ответный ход:
# шесть смещений по прошлой стороне и пять блоков по тридцать шесть.
HERO_BOX_PTR_LO, HERO_BOX_PTR_HI, HERO_BOX_N = 0xBAEE, 0xBAF9, 11
HERO_BLOCK = 0xBAE6
RIDE_BEFORE, RIDE_BEFORE_N = 0xB98A, 6
RIDE_ACTION, RIDE_ACTION_N = 0xB990, 180
BOX_HIGH = 0xB7A4
BOX_SPLIT = 0x50
NBOSS = 10                  # $50..$59
BOSS_PHASES = 3
# $B721 -- сила выстрела по его типу, $B725 -- половина его короба.
SHOT_POWER = 0xB721
SHOT_SIZE = 0xB725
NSHOT = 4
# $B717 -- в какое состояние переходит большая вещь, когда её убили.
BIG_DEATH = 0xB717
NBIG_DEATH = 10
# $B73C -- типы, которые оставляют после себя единицу в $05FA.
LEAVES_ONE = 0xB73C
NLEAVES = 11
# $B764 -- типы, номер записи которых дописывают к списку в $0172.
WRITTEN_DOWN = 0xB764
NWRITTEN = 4

# $814A / $8152 -- the eight class handlers, and what each of them checks.
# The two checks are not "along the level" and "across" it: whichever way the
# level runs, one reads the pair of bytes that hold the place across the screen
# ($04F2 / $0508) and the other the pair that hold it down the screen ($04B0 /
# $04C6).  A number names a pair in `cull_margin`; the words are the special
# rules:
#   'none'  -- never thrown away                             ($8148)
#   'page'  -- gone the moment either high byte is not zero   ($8172)
#   'drop'  -- $81BD: below the screen at once, above it 32 points of grace
#   'floor' -- $81EF: as 'drop', and also gone at $D0 while still on screen
CLASS_RULES = [
    dict(handler=0x815A, horiz=0, vert='drop'),
    dict(handler=0x8162, horiz=2, vert='drop'),
    dict(handler=0x816A, horiz=0, vert=0),
    dict(handler=0x8148, horiz='none', vert='none'),
    dict(handler=0x8172, horiz='page', vert='page'),
    dict(handler=0x817E, horiz=0, vert=2),
    dict(handler=0x8186, horiz=4, vert='floor'),
    dict(handler=0x818E, horiz=6, vert=6),
]


def anims(rom):
    """Every run of pictures, as {last, hold, first} and, for the long ones,
    the list of offsets that stands in for a plain run."""
    b6 = rom.bank(6)
    b7 = rom.bank(7)
    b15 = rom.bank(15)

    def byte(a):
        return b6[a - 0x8000] if a < 0xA000 else b7[a - 0xA000]

    def word(a):
        return byte(a) | (byte(a + 1) << 8)

    table = word(ANIM_PTR)
    count = (word(table) - table) // 2
    out = []
    for i in range(count):
        a = word(table + 2 * i)
        last = byte(a)
        rec = dict(last=last & 0x7F, hold=byte(a + 1), first=byte(a + 2))
        if last & 0x80:
            # $E374: the fourth byte picks a run of offsets, and the picture is
            # the first plus the offset of the step -- so the steps need not be
            # one after another.  The run is as long as the record has steps.
            which = byte(a + 3)
            lo = ANIM_OFFSETS - 0xE000 + 2 * which
            at = b15[lo] | (b15[lo + 1] << 8)
            rec['steps'] = list(b15[at - 0xE000:
                                    at - 0xE000 + (last & 0x7F) + 1])
        out.append(rec)
    return out


def export():
    rom = pb2_spawns.Rom()
    b10 = rom.bank(10)
    b11 = rom.bank(11)
    b15 = rom.bank(15)
    b7 = rom.bank(7)
    b9 = rom.bank(9)

    def at9(a, n):
        return list(b9[a - 0xA000:a - 0xA000 + n])

    def word9(a):
        return b9[a - 0xA000] | (b9[a - 0xA000 + 1] << 8)

    def at7(a, n):
        return list(b7[a - 0xA000:a - 0xA000 + n])

    def word7(a):
        return b7[a - 0xA000] | (b7[a - 0xA000 + 1] << 8)

    # Короб каждого типа.  Меньше $50 -- одна пара; $50 и выше -- три,
    # по ходу большой вещи.
    boxes = []
    for t in range(NTYPES):
        if t < BOX_SPLIT:
            boxes.append([at7(word7(BOX_LOW + 2 * t), 2)])
        else:
            p = word7(BOX_HIGH + 2 * (t - BOX_SPLIT))
            boxes.append([at7(p + 2 * i, 2) for i in range(BOSS_PHASES)])
    pickup = list(b15[PICKUP_BITS - 0xE000:PICKUP_BITS - 0xE000 + NPICKUP])
    classes = list(b10[CLASSES - 0x8000:CLASSES - 0x8000 + NTYPES])
    margins = list(b10[MARGINS - 0x8000:MARGINS - 0x8000 + 8])
    runs = anims(rom)
    d = outdir('pb2')
    size = write_json(os.path.join(d, 'objects.json'), dict(
        # $826C-$83E9: killed enemy -> burst -> optional pickup -> expiry.
        death=dict(drop_table=list(b10[0x369:0x389]),
                   drop_pic=list(b10[0x389:0x38F]),
                   drop_item=list(b10[0x38F:0x395]),
                   drop_mask=b10[0x301], lifetime=b10[0x396],
                   head_probe=b10[0x3A7], gravity=b10[0x3D7],
                   fall_limit=b10[0x3DC], fall_speed=b10[0x3E0],
                   max_extra=b10[0x34C], max_second=b10[0x355],
                   max_power=b10[0x35E]),
        # $9C68/$9D79 and shared mark helpers $FD7A/$BE5A.
        small_shots=dict(bullet_mark=b15[0x1D7B], bullet_pic=b10[0x1C73],
                         trail_life=b10[0x1D81], trail_mark=b15[0x1D77],
                         trail_anim=b10[0x1D85], trail_ticks=b10[0x1D89],
                         trail_parent=b10[0x1D99], aimed_pic=rom.bank(11)[0x8A3]),
        # $A71F: hatchling movement, wall probes and terminal explosion.
        hatchling=dict(life=b11[0x72D], anim=b11[0x731], speed=list(b11[0x738:0x73A]),
                       spawn_wall=list(b11[0x73D:0x740]), floor_probe=list(b11[0x750:0x752]),
                       walk_wall=list(b11[0x78E:0x791]), gravity=b11[0x775],
                       fall_limit=b11[0x77D], burst_ticks=b11[0x799], burst_anim=b11[0x79B]),
        cull_class=classes,
        # Read in pairs, one pair per Y of 0, 2, 4 and 6.  Off the near side
        # a thing is kept while its low byte is >= the first of the pair; off
        # the far side, while the low byte is < the second.
        cull_margin=margins,
        cull_rules=CLASS_RULES,
        # $E5B1: which bit of $2B / $2C a collectable answers to.  Only the
        # first eight are bits; the rest is whatever follows in the bank, and
        # is carried across because $E534 can reach it.
        pickup_bit=pickup,
        pickup_pic=list(b10[PICKUP_PIC - 0x8000:
                            PICKUP_PIC - 0x8000 + NPICKUP_PIC]),
        anims=runs,
        # $9D72, read by the low nibble of the record's byte.  Only a few of
        # the sixteen are ever asked for; the rest is whatever follows in the
        # bank, and is carried across because the nibble can reach it.
        swing=list(b10[SWING - 0x8000:SWING - 0x8000 + 16]),
        # $9EE1 and $9EE9: how fast the one that circles turns, by the low
        # three bits of the record's byte.  The pair is one signed number.
        spin_lo=list(b10[SPIN_LO - 0x8000:SPIN_LO - 0x8000 + 8]),
        spin_hi=list(b10[SPIN_HI - 0x8000:SPIN_HI - 0x8000 + 8]),
        # $F301: sixty-five points of a quarter turn.  The first two are never
        # read -- $F2E6 answers the whole length for those -- but they are
        # kept so the table is indexed as the cartridge indexes it.
        trig=list(b15[TRIG - 0xE000:TRIG - 0xE000 + 65]),
        # $FD31, read by the low four bits of where a thing stands down the
        # screen: the shift that puts it on the floor line of its own tile.
        snap=list(b15[SNAP - 0xE000:SNAP - 0xE000 + 16]),
        # $F64F: the quarter turn $F5BA uses to point a speed at an angle.
        # Shorter than $F301 because the answer is sixteen bits, not eight.
        aim=list(b15[AIM - 0xE000:AIM - 0xE000 + 65]),
        # $F783 and its two little brothers: the arctangent $F6E2 aims
        # by.  The big one is read by the eight-bit share of the shorter
        # side in the longer, the small ones by which eighth of the turn
        # the two signs and the comparison between them fall in.
        atan=list(b15[ATAN - 0xE000:ATAN - 0xE000 + 256]),
        octant=list(b15[OCTANT - 0xE000:OCTANT - 0xE000 + 16]),
        quarter=list(b15[QUARTER - 0xE000:QUARTER - 0xE000 + 4]),
        # $B44F: середина вещи по высоте -- $04C6 минус это, со знаком.
        middle=at7(MIDDLE, NTYPES),
        # $B3EF: сколько снимает с героя касание этого типа.
        hurt=at7(HURT, NTYPES),
        # $B768: полуширина и полувысота.  У больших вещей три пары.
        box=boxes,
        # $B721 и $B725: сила выстрела и половина его короба, по его типу.
        shot_power=at7(SHOT_POWER, NSHOT),
        shot_size=at7(SHOT_SIZE, NSHOT),
        # $B717: состояние, в которое уходит убитая большая вещь.
        big_death=at7(BIG_DEATH, NBIG_DEATH),
        # $B73C и $B764: два списка типов, которые смерть читает.
        leaves_one=at7(LEAVES_ONE, NLEAVES),
        written_down=at7(WRITTEN_DOWN, NWRITTEN),
        # $BA44 (банк 9): короб героя -- слева, справа, сверху, снизу от его
        # места, со знаком.  Запись выбирает счёт позы, а указатели их уже
        # разложили в его порядке.
        hero_box=[at9(b9[HERO_BOX_PTR_LO - 0xA000 + i]
                      | (b9[HERO_BOX_PTR_HI - 0xA000 + i] << 8), 4)
                  for i in range(HERO_BOX_N)],
        # $BAE6 -- $011A по тому же счёту: поза героя, умноженная на 36.
        hero_block=at9(HERO_BLOCK, 8),
        # $B98A -- сдвиг по стороне, с которой герой был в вещи в прошлый
        # раз, и $B990 -- сам выбор ответного хода, пять блоков по тридцать
        # шесть: $011A + $B98A[прошлая] + новая.
        ride_before=at9(RIDE_BEFORE, RIDE_BEFORE_N),
        ride_action=at9(RIDE_ACTION, RIDE_ACTION_N),
    ))
    print('%d types, %d classes, %d runs of pictures, %d bytes'
          % (NTYPES, len(set(classes)), len(runs), size))


if __name__ == '__main__':
    export()
