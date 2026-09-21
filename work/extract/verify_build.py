#!/usr/bin/env python3
"""Э7.1 acceptance: the exported build must answer what the sources answer.

Every other stand in this project runs the engine out of its own folder, with
the editor's own copy of the data beside it.  A build is not that: exporting
**changes the files**.  A file the editor imports travels as what the importer
made of it and not as itself, and a file nothing imports does not travel at
all unless the preset was told to carry it.  Both games read their data as
files -- `FileAccess` for the fifty-eight JSON, `Image.load_from_file` for the
two tile sheets -- so both of those ways of losing a file are ways of losing
this port.

What is compared is therefore the build against the sources, on the two
harnesses that between them touch everything the build could have lost:

* `--choose=`, which is text and reads `screens.json` and `objects.json`;
* `--select=`, which is a picture and reads the tile sheet as well.

Nothing here is compared against the cartridge.  That has been done already,
by the stands of Э3.10b and Э6.3.9; what is asked here is only whether the
build is the same engine.
"""
import filecmp
import glob
import json
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402
import verify_select as SEL                                  # noqa: E402

# The one target this machine can actually run.  The other two presets are
# exported by the same command and are not run here: a build that cannot be
# started cannot be compared, and saying otherwise would be a lie.
PRESET = 'macOS'

# Which project is exported and run against.  It is `game/`, and it is an
# argument only so that a change can be tried on a copy before it is put in.
GAME = V.GAME


def export(d):
    """The build, out of the same project the stands run from.

    What lands inside the bundle is named after the project and not after the
    preset, so it is looked for rather than spelled out.
    """
    out = os.path.join(d, 'pb3.app')
    r = subprocess.run([V.GODOT, '--headless', '--path', GAME,
                        '--export-release', PRESET, out],
                       capture_output=True, text=True)
    holds = os.path.join(out, 'Contents', 'MacOS')
    found = sorted(glob.glob(os.path.join(holds, '*'))) if \
        os.path.isdir(holds) else []
    if not found:
        sys.stderr.write(r.stdout[-4000:] + r.stderr[-4000:])
        return None
    return found[0]


def said(binary, args, render=False):
    """One run, and what it put out."""
    head = ([binary] if binary else
            [V.GODOT, '--path', GAME])
    if render:
        head += ['--rendering-driver', 'opengl3', '--resolution', '256x240',
                 '--quit-after', '600']
    else:
        head += ['--headless']
    r = subprocess.run(head + ['--'] + list(args),
                       capture_output=True, text=True, timeout=V.ENGINE_WAIT)
    return r.stdout, r.stderr, r.returncode


def lines(text):
    """The run's own lines, without the engine's greeting."""
    out = []
    for ln in text.split('\n'):
        ln = ln.rstrip()
        if not ln or ln.startswith('Godot Engine') or ln.startswith('--'):
            continue
        out.append(ln)
    return out


# (name, the config handed to --choose=)
CHOICES = [
    ('still', {'stage': 0, 'cleared': 0x00, 'owned': 0,
               'frames': [{'hit': 0}] * 40}),
    ('cleared', {'stage': 3, 'cleared': 0x0F, 'owned': 0,
                 'frames': [{'hit': 0}] * 40}),
    ('ride', {'stage': 0, 'cleared': 0x00, 'owned': 0,
              'frames': [{'hit': 0}] * 8 + [{'hit': 1}] * 4
              + [{'hit': 0}] * 120}),
]

# The pictures, as `verify_select` spells a scene: cleared:owned:rot, then the
# buttons, then which pictures to shoot and where to put them.
SHOTS = [
    ('still', 0, '0:0:%d,-:40,2+30,%s' % (SEL.ROT, '%s')),
    ('cleared', 3, '15:0:%d,-:40,2+30,%s' % (SEL.ROT, '%s')),
]


def check_text(binary, d):
    """The text harness, both ways round."""
    bad = judged = 0
    for name, cfg in CHOICES:
        path = os.path.join(d, 'c.json')
        open(path, 'w').write(json.dumps(cfg))
        mine, _, code = said(binary, ['--choose=' + path])
        theirs, _, code2 = said(None, ['--choose=' + path])
        a, b = lines(mine), lines(theirs)
        if code or code2 or not b or a != b:
            bad += 1
            print('    %-9s DIFF  build %d lines (exit %d), sources %d '
                  '(exit %d)' % (name, len(a), code, len(b), code2))
            for i, (x, y) in enumerate(zip(a, b)):
                if x != y:
                    print('        line %d  build %r  sources %r'
                          % (i, x, y))
                    break
        else:
            judged += len(b)
            print('    %-9s ok    %d lines' % (name, len(b)))
    return bad, judged


def check_pictures(binary, d):
    """The picture harness, both ways round."""
    bad = judged = 0
    for name, stage, spec in SHOTS:
        mine_at = os.path.join(d, 'b_' + name)
        theirs_at = os.path.join(d, 's_' + name)
        told = {}
        for who, at in ((binary, mine_at), (None, theirs_at)):
            out, err, code = said(who, [('--select=' + spec) % at,
                                        '--stage=%d' % stage], render=True)
            told['build' if who else 'sources'] = (out, err, code)
        for pic in (2, 30):
            a = '%s_%d.png' % (mine_at, pic)
            b = '%s_%d.png' % (theirs_at, pic)
            if not os.path.exists(a) or not os.path.exists(b):
                bad += 1
                who = 'build' if not os.path.exists(a) else 'sources'
                print('    %-9s DIFF  picture %d: the %s drew nothing'
                      % (name, pic, who))
                out, err, code = told[who]
                print('        it left off %d, and said:' % code)
                for ln in (out + err).strip().split('\n')[-6:]:
                    print('        %s' % ln.rstrip())
                continue
            if not filecmp.cmp(a, b, shallow=False):
                bad += 1
                print('    %-9s DIFF  picture %d differs' % (name, pic))
            else:
                judged += 1
                print('    %-9s ok    picture %d' % (name, pic))
    return bad, judged


def main():
    global GAME
    for a in sys.argv[1:]:
        if a.startswith('--game='):
            GAME = a.split('=', 1)[1]
    d = pb2_trace.P.scratch('build')
    try:
        print('exporting %s...' % PRESET)
        sys.stdout.flush()
        binary = export(d)
        if binary is None:
            print('the build was not made')
            print('1 of 1 builds differ from the sources')
            return 1
        print('the build is %s' % binary)
        bad = judged = 0
        print('text:')
        n, j = check_text(binary, d)
        bad += n
        judged += j
        print('pictures:')
        n, j = check_pictures(binary, d)
        bad += n
        judged += j
        print('%d lines and pictures judged' % judged)
        print('%d of %d runs differ from the sources'
              % (bad, len(CHOICES) + 2 * len(SHOTS)))
        return 1 if bad else 0
    finally:
        pb2_trace.P.sweep(d)


if __name__ == '__main__':
    sys.exit(main())
