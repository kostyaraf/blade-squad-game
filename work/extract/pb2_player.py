#!/usr/bin/env python3
"""Export the hero's body and his numbers, straight out of the cartridge.

Nothing here is typed in by hand: every constant is read from the address the
code reads it from, so if the ROM says the jump is five pixels a frame, so does
the file.  `work/re/pb2_player.md` says where each address came from.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import ROM_PB2, outdir, write_json                   # noqa: E402

BANK = 0x2000


def bank(rom, n):
    return rom[16 + n * BANK: 16 + (n + 1) * BANK]


def s8(v):
    return v - 256 if v > 127 else v


def s16(v):
    return v - 0x10000 if v & 0x8000 else v


def export():
    rom = open(ROM_PB2, 'rb').read()
    b8, b9 = bank(rom, 8), bank(rom, 9)

    def a8(addr, n=1):
        return b8[addr - 0x8000: addr - 0x8000 + n]

    def a9(addr, n=1):
        return b9[addr - 0xA000: addr - 0xA000 + n]

    # --- the body -------------------------------------------------------
    # $AEBD/$AEEC: one pointer per pose into a list of probe offsets.  A wall
    # check reads it as [half width, row, row, row]; a floor or ceiling check
    # reads the same bytes as [row, left, right].
    n = 0x2F
    ptr = [a9(0xAEEC + i)[0] * 256 + a9(0xAEBD + i)[0] for i in range(n)]
    starts = sorted(set(ptr)) + [0xAF81]
    body = {}
    for lo, hi in zip(starts, starts[1:]):
        body['%04X' % lo] = [s8(x) for x in a9(lo, hi - lo)]
    poses = ['%04X' % p for p in ptr]

    # --- the animations -------------------------------------------------
    # $B072/$B08A: 24 little scripts.  Byte 0 is how many frames a pose is
    # held; then the poses, until $FF (start over), $FE (stop here) or $FD
    # (stop, and the byte after it is the pose to end on).
    aptr = [a9(0xB08A + i)[0] * 256 + a9(0xB072 + i)[0] for i in range(24)]
    astop = sorted(set(aptr)) + [0xB117]
    anims = {}
    for lo in sorted(set(aptr)):
        hi = min(e for e in astop if e > lo)
        anims['%04X' % lo] = list(a9(lo, hi - lo))

    # $B514/$B51A: one list of feeling-points per kind of stance
    pptr = [a9(0xB51A + i)[0] * 256 + a9(0xB514 + i)[0] for i in range(6)]

    out = dict(
        anim_index=['%04X' % p for p in aptr],
        anims=anims,
        # $A4EE: which animation each weapon swings
        weapon_anim=list(a9(0xA4EE, 16)),
        # where each pose's body description lives
        body_index=poses,
        body=body,
        # $A0CA / $A0FA: hold a direction and you reach one pixel a frame
        walk_speed=s16(a9(0xA0CD)[0] * 256 + a9(0xA0CE)[0]),
        walk_step=s16(a9(0xA0CF)[0] * 256 + a9(0xA0D0)[0]),
        # $A0C0 and $A0B6: coming down from a faster speed
        brake_slow=s16(a9(0xA0C5)[0] * 256 + a9(0xA0C6)[0]),
        brake_fast=s16(a9(0xA0BB)[0] * 256 + a9(0xA0BC)[0]),
        # $A074: nothing held
        friction=s16(a9(0xA079)[0] * 256 + a9(0xA07A)[0]),
        # $9FE2 / $9FDB
        jump_speed=s16(a8(0x9FE5)[0] * 256 + a8(0x9FE3)[0]),
        step_off_speed=s16(a8(0x9FDE)[0] * 256 + a8(0x9FDC)[0]),
        # $91F3 and $920B
        gravity=a8(0x91F4)[0],
        gravity_released=a8(0x920C)[0],
        # $9236 / $922A
        fall_max=a8(0x923B)[0] * 256,
        fall_max_slow=a8(0x922B)[0] * 256,
        # $904D / $9057: the slide
        slide_speed=s16(a8(0x9050)[0] * 256 + a8(0x9051)[0]),
        slide_step=s16(a8(0x9052)[0] * 256 + a8(0x9053)[0]),
        slide_decay=s16(a8(0x9052)[0] * 256 + a8(0x9053)[0]),
        # $8FEC: the slide starts at a set speed and has a set distance
        slide_start=[s16(a9(0xAF81)[0] * 0 + b8[0x1032 + i] * 256 + b8[0x102E + i])
                     for i in range(4)],
        slide_distance=[b8[0x102C + i] * 256 for i in range(2)],
        # $9146/$9150: coming out of a slide he sheds three quarters of a pixel
        slide_brake=b8[0x1155] * 256 + b8[0x1156],
        # $90A1: under a low ceiling the slide is given eight more pixels
        slide_retry=b8[0x10A2] * 256,
        # $AFD7: landing puts his feet on the last row of a sixteen pixel cell
        snap_down=[s8(x) for x in a9(0xAFD7, 16)],
        # $AFF7: standing up out of a slide puts him on the far side of the
        # cell instead -- the ceiling that made him slide is above him
        snap_stand=[s8(x) for x in a9(0xAFF7, 16)],
        # $AF91/$AF99: the same trick sideways, into and out of a wall
        snap_right=[s8(x) for x in a9(0xAFD7, 16)],
        snap_left=[s8(x) for x in a9(0xAFE7, 16)],
        # The ladder.  $A003 lets go of the ground when both points just under
        # his feet are ladder; then he is set down, waits, and is set down
        # again, and only then does he begin to climb ($945F).  Coming off the
        # top he is lifted twice the same way ($94FF, $9477).
        ladder_probe=[[s8(a9(0xA006)[0]), s8(a9(0xA004)[0])],
                      [s8(a9(0xA011)[0]), s8(a9(0xA00F)[0])]],
        ladder_mount=s16(a9(0xA01F)[0] * 256 + a9(0xA020)[0]),
        ladder_mount_wait=a9(0xA022)[0],
        ladder_step=s16(a8(0x946A)[0] * 256 + a8(0x946B)[0]),
        ladder_top_lift=s16(a8(0x9510)[0] * 256 + a8(0x9511)[0]),
        ladder_top_wait=a8(0x9513)[0],
        ladder_off_lift=s16(a8(0x9482)[0] * 256 + a8(0x9483)[0]),
        ladder_pose=a8(0x9518)[0],
        # $94C0 and $94CA: up and down, each a limit and a step towards it
        ladder_up=[s16(a8(0x94C3)[0] * 256 + a8(0x94C4)[0]),
                   s16(a8(0x94C5)[0] * 256 + a8(0x94C6)[0])],
        ladder_down=[s16(a8(0x94CD)[0] * 256 + a8(0x94CE)[0]),
                     s16(a8(0x94CF)[0] * 256 + a8(0x94D0)[0])],
        # $94DE: letting go of a ladder with the jump button is a small hop
        ladder_jump=s16(a8(0x94E1)[0] * 256 + a8(0x94DF)[0]),
        # $94F1 and $94FF: how far above him the ladder has to go on -- the
        # first says he is still on it at all, the second that its top is not
        # yet in reach
        ladder_hold=s8(a8(0x94F2)[0]),
        # $93C7: and how far above him one has to be for him to catch it out
        # of the air
        ladder_air=s8(a8(0x93C8)[0]),
        ladder_top=s8(a8(0x9500)[0]),
        # $9442: a fall longer than this lands hard
        hard_landing=a8(0x9443)[0],
        # $F5A9: what the two collision bits mean
        class_bytes=[0x00, 0x01, 0x80, 0x02],
        # $B4D6: which set of feeling-points a pose uses, and $B520: the sets
        # themselves -- eight points down each side of him, from his feet to
        # the top of his head, which is how the game knows he is in water.
        probe_set=list(a9(0xB4D6, 0x40)),
        probe_index=['%04X' % p for p in pptr],
        probes={'%04X' % p: [[s8(a9(p + i * 2)[0]), s8(a9(p + i * 2 + 1)[0])]
                             for i in range(8)] for p in sorted(set(pptr))},
        # $B4AF: water carries him up, and takes half his speed for it.  The
        # two numbers are the push while he is already going up and the push
        # while he is coming down; both stop at the same speed.
        swim_up=[s16(a9(0xB4CB)[0] * 256 + a9(0xB4CC)[0]),
                 s16(a9(0xB4D3)[0] * 256 + a9(0xB4D4)[0])],
        swim_limit=s16(a9(0xB4C9)[0] * 256 + a9(0xB4CA)[0]),
        # $B47C..$B494: the moving floors, with him and against him
        belt=[s16(a9(0xB47F)[0] * 256 + a9(0xB480)[0]),
              s16(a9(0xB48B)[0] * 256 + a9(0xB48C)[0]),
              s16(a9(0xB491)[0] * 256 + a9(0xB492)[0]),
              s16(a9(0xB49D)[0] * 256 + a9(0xB49E)[0])],
        # $B462: what he sinks into swallows him a fraction of a pixel a frame
        sink=s16(a9(0xB465)[0] * 256 + a9(0xB466)[0]),
        drown_y=a9(0xB46B)[0],
        # where the level sits on the screen
        view_top=0x10, view_bottom=0xB0,
        screen_left=0x10, screen_right=0xF1,
    )
    d = outdir('pb2')
    size = write_json(os.path.join(d, 'player.json'), out)
    print('player.json  %d poses, %d bodies, %d bytes'
          % (len(poses), len(body), size))
    for k in ('walk_speed', 'walk_step', 'friction', 'jump_speed', 'gravity', 'brake_slow', 'brake_fast', 'slide_step',
              'gravity_released', 'fall_max', 'slide_speed', 'hard_landing'):
        print('  %-18s %s' % (k, out[k]))


if __name__ == '__main__':
    export()
