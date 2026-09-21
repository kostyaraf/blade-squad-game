#!/usr/bin/env python3
"""Э3.8 acceptance, part one: every stand of Э1..Э3 run in a row.

Each of the earlier stages was accepted on its own stand and on its own day.
This runs all of them again, one after another, out of the state the tree is
in now, and puts the numbers side by side.  A stage is accepted for good only
when its stand still says nought here.

The stands share one scratch and one emulator, so they are run one at a time,
never two at once.  The whole of what each puts out is kept under
`work/tmp/accept/` -- the verdict line alone is printed.

Run with no arguments it runs them all.  `--only=hud,flow` runs the named few;
`--list` only says what there is.
"""
import os
import re
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
LOGS = os.path.join(ROOT, 'work', 'tmp', 'accept')

# name, stage it belongs to, script, arguments.
STANDS = [
    ('engine',     'Э1',   'verify_engine.py',     []),
    ('pb2',        'Э1',   'verify_pb2.py',        []),
    ('sprites',    'Э2',   'verify_sprites.py',    []),
    ('oam',        'Э2',   'verify_oam.py',        []),
    ('player',     'Э2',   'verify_player.py',     ['--all-areas', '--random=14', '--seed=101']),
    ('flow',       'Э3.1', 'verify_flow.py',       []),
    ('spawns',     'Э3.2', 'verify_spawns.py',     ['--random=3']),
    ('weapons',    'Э3.3', 'verify_weapons.py',    ['--all-areas', '--random=3']),
    ('water',      'Э3.2', 'verify_water.py',      []),
    ('orbit',      'Э3.4', 'verify_orbit.py',      []),
    ('hud',        'Э3.7', 'verify_hud.py',        ['--all-areas']),
    ('hudscreen',  'Э3.7', 'verify_hud_screen.py', ['--all-areas']),
    ('run',        'Э3.8', 'verify_run.py',        []),
    ('solplayer',  'Э4.1', 'verify_sol_player.py', []),
    ('solboard',   'Э4.7', 'verify_sol_board.py',  []),
    ('solover',    'Э4.8', 'verify_sol_over.py',   []),
    ('solname',    'Э4.9', 'verify_sol_name.py',   []),
    ('soltest',    'Э4.10', 'verify_sol_test.py',  []),
    ('solstrip',   'Э4.11', 'verify_sol_strip.py', []),
    ('solclear',   'Э4.12', 'verify_sol_clear.py', []),
    ('solend',     'Э4.13', 'verify_sol_end.py', []),
    ('solbare',    'Э4.14', 'verify_sol_bare.py', []),
    ('solpanels',  'Э4.15', 'verify_sol_panels.py', []),
    ('solflow',    'Э4.5', 'verify_sol_flow.py',   []),
    ('solscript',  'Э4.5', 'verify_sol_script.py', []),
    ('solsat',     'Э4.1', 'verify_sol_sat.py',    []),
    ('solweapon',  'Э4.2', 'verify_sol_weapon.py', []),
    ('solspawns',  'Э4.3', 'verify_sol_spawns.py', []),
    ('solhands',   'Э4.17', 'verify_sol_hands.py', []),
    ('solblows',   'Э4.18', 'verify_sol_blows.py', []),
    ('soldeaths',  'Э4.3', 'verify_sol_deaths.py', []),
    ('solpunch',   'Э4.19', 'verify_sol_punch.py', []),
    ('soldraw',    'Э4.20', 'verify_sol_draw.py',  []),
    ('solpair',    'Э4.21', 'verify_sol_pair.py',  []),
    ('solstates',  'Э4.5', 'verify_sol_states.py', []),
    ('solminds',   'Э4.3', 'verify_sol_minds.py',  []),
    ('solshots',   'Э4.3', 'verify_sol_shots.py',  []),
    ('solkinds',   'Э4.3', 'verify_sol_shotkinds.py', []),
    ('solbehav',   'Э4.3', 'verify_sol_behaviours.py', []),
    ('solcrates',  'Э4.4', 'verify_sol_crates.py', []),
    ('solcamera',  'Э4.1', 'verify_sol_camera.py', []),
    ('sollong',    'Э4.22', 'verify_sol_long.py',  []),
    ('solrun',     'Э4.6', 'verify_sol_run.py',    []),
    ('pb3floor',   'Э5.1', 'verify_pb3_floor.py',  []),
    ('pb3pair',    'Э5.2', 'verify_pb3_pair.py',   []),
    ('pb3pick',    'Э5.3', 'verify_pb3_pick.py',   []),
    ('pb3hits',    'Э5.4', 'verify_pb3_hits.py',   []),
    ('pb3gear',    'Э5.5', 'verify_pb3_gear.py',   []),
    ('pb3list',    'Э5.6', 'verify_pb3_list.py',   []),
    ('pb3run',     'Э5.7', 'verify_pb3_run.py',    []),
    ('sound',      'Э6.1', 'verify_sound.py',      []),
    ('apu',        'Э6.2', 'verify_apu.py',        []),
    ('sndplay',    'Э6.3.1', 'verify_snd_play.py', []),
    ('solnoise',   'Э6.3.2', 'verify_sol_noise.py', []),
    ('pb2noise',   'Э6.3.3', 'verify_pb2_noise.py', ['--random=2']),
    ('pb2hero',    'Э6.3.4', 'verify_pb2_hero.py', ['--random=2', '--suits=0,1,3']),
    ('pb2arms',    'Э6.3.5', 'verify_pb2_arms.py', ['--gear=plain,power-3,suit-2']),
    ('pb2bar',     'Э6.3.6', 'verify_pb2_bar.py', []),
    ('pb2wave',    'Э6.3.6', 'verify_pb2_wave.py', []),
    ('pb2take',    'Э6.3.6', 'verify_pb2_take.py', []),
    ('pb2menu',    'Э6.3.7', 'verify_pb2_menu.py', []),
    ('pb2flow',    'Э6.3.8', 'verify_pb2_flow.py', []),
]

# Every stand ends on a line that counts what differs.  Two shapes are in use:
# "N of M <things> differ" and, where what is counted is pixels of a picture,
# "worst frame: N pixels".
COUNT = re.compile(r'^(\d+) of (\d+) ([^,;]+?) differ')
WORST = re.compile(r'^worst frame: (\d+) pixels')
NOTHING = re.compile(r'^0 of 0 ')


def verdict(text):
    """The last line of a stand that says how much differed, and how much.

    Returns (bad, line) -- bad is None when the stand said nothing that can be
    read as a verdict, which is itself a failure.
    """
    bad = None
    line = ''
    for row in text.splitlines():
        m = COUNT.match(row)
        if m:
            bad, line = int(m.group(1)), row.strip()
            continue
        m = WORST.match(row)
        if m:
            bad, line = int(m.group(1)), row.strip()
    return bad, line


def run(name, script, args):
    os.makedirs(LOGS, exist_ok=True)
    path = os.path.join(LOGS, name + '.txt')
    began = time.time()
    # The log of a run that was killed has to go, and not just be written
    # over: a stand of the killed run may still be alive, holding the same
    # path open at its own offset, and its writes would land past the end of
    # the new log.  The verdict is read off the end of the file, so a tail
    # like that is read as this run's answer.  Unlinking leaves the old
    # writer with an inode nobody can see.
    if os.path.exists(path):
        os.unlink(path)
    # Straight into the log rather than into a pipe, so that a stand three
    # quarters of an hour long can be watched while it runs.
    with open(path, 'w') as f:
        r = subprocess.run([sys.executable, '-u', os.path.join(HERE, script)]
                           + args, stdout=f, stderr=subprocess.STDOUT,
                           text=True, cwd=ROOT)
    text = open(path).read()
    took = time.time() - began
    bad, line = verdict(text)
    # A stand that finds a difference exits non-zero, and that is its verdict,
    # not a fall.  Only a run that put out no verdict at all has really fallen
    # over, and then the exit code is all there is to say.
    if bad is None:
        return None, 'exit %d -- see %s' % (r.returncode, path), took
    # "0 of 0 differ" is not a pass: the stand was given no work to do.
    if bad == 0 and NOTHING.match(line):
        return None, 'nothing was run -- %s' % line, took
    return bad, line, took


def main():
    picked = [s[0] for s in STANDS]
    for a in sys.argv[1:]:
        if a == '--list':
            for name, stage, script, args in STANDS:
                print('%-10s %-5s %s %s' % (name, stage, script, ' '.join(args)))
            return 0
        if a.startswith('--only='):
            picked = a.split('=')[1].split(',')
    ran = bad = 0
    for name, stage, script, args in STANDS:
        if name not in picked:
            continue
        n, line, took = run(name, script, args)
        ran += 1
        if n is None:
            bad += 1
            print('%-10s %-5s FAILED  %s' % (name, stage, line))
        else:
            if n:
                bad += 1
            print('%-10s %-5s %-7s %-52s %5.0f s'
                  % (name, stage, 'ok' if n == 0 else 'DIFFERS', line, took))
        sys.stdout.flush()
    print('%d of %d stands differ' % (bad, ran))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
