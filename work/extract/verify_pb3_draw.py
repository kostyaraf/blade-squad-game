#!/usr/bin/env python3
"""Э7.5 acceptance: one picture with two games drawn into it.

There is nothing to compare this against.  Each cartridge drew its own things
out of its own sheet with its own colours and never met another game's hero,
so the hybrid picture is the port's own and no recording of it exists.  What
is written down here is therefore not a difference but a **promise**, and
every promise is judged by pictures taken out of the engine itself.

The reading is `work/re/pb3_draw.md`.  In short: the background, its colours
and its four banks are the level's own, whole; what is doubled is the sprites
-- the guest brings his own sheet, his own four sprite banks, his own game's
colours and a table of his own, and the shader draws that table in a second
pass behind the level's.

The eight promises
------------------
1. **The host is drawn by his own game, over his own background.**  The same
   level, the same view and the level's own table are handed to the road the
   single game is drawn by (Э1..Э4, accepted), and the two pictures must come
   out the same point for point.  A window, a place for the view, a bank or a
   colour the mode got wrong shows up here at once.
2. **The guest is drawn by his own game.**  His sheet is the other game's, his
   four sprite banks are his own game's and not the level's, the sprite half
   of his colours is his own game's, and the background half of it is the
   level's -- checked on all eighty three records, not only the photographed
   ones.  And he is really there: his pass marks points the background alone
   does not have.
3. **The second pass draws a table exactly as the first pass would.**  The
   guest's own table is photographed twice over a background that is not
   there: once through the second pass, and once handed to the first pass with
   his sheet, his colours and his banks in the level's place.  The two must be
   the same point for point.
4. **The level's own table is in front.**  Photographed in colours that cannot
   be mistaken: the level's marks white, the guest's blue, no background to
   hide behind.  Every white point of the two-table picture is white in the
   level's own, every blue point is blue in the guest's own and not white in
   the level's, and there is nothing else in it.
5. **Each table keeps its own eight to a line.**  The console draws eight of a
   table to a line and drops the rest, and each of the two tables here counts
   its own eight.  A record whose level fills a line with more than eight is
   photographed on purpose: if the two tables shared one queue the guest would
   vanish from those lines and promise four would break there.
6. **The road reaches.**  Every one of the eighty three records is raised from
   the list, played ninety pictures with both pads walking, and both tables
   have something on the picture at the end of it.
7. **Both heroes are on the picture.**  The level's own pass marks points the
   background alone does not have, and so does the guest's.
8. **What the guest throws is on the picture too.**  A Solbrain guest's pool is
   stepped with the view pretended to stand on him (Э5.7) and what it throws
   draws itself inside the behaviour that moved it, so the beams are written
   down as they are drawn and laid out again from the right view.  Every
   record with a Solbrain guest must have something of his in the air at some
   point of its walk, and the photographed one is taken twice -- with the
   beams in his table and with them left out -- and the two must differ.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import sol_probe as P                                            # noqa: E402
import verify_sol_player as V                                    # noqa: E402

# How many pictures each record is played for.  The pilot is Э5.8's own and is
# not on trial here; ninety pictures is long enough for both heroes to be off
# the ground they started on and for the level's own things to be about.
FRAMES = 90

RECORDS = 63 + 20

# The two games' sheets, by the name the engine prints.
SHEETS = {'p': 'pb2', 's': 'sol'}

# The two marked pieces are two colours each and no more -- the mark and the
# backdrop -- and which colour is which is read off the pictures themselves
# rather than written down here: the engine sets $30 over the level's own
# table and $12 over the guest's, and what a PNG of the picture gives back for
# those is the screen's business, not this stand's.

# The pieces of one picture, each a file: the background alone, the level's
# own table over it, the guest's table over it, both, the guest's table over
# no background at all, the same handed to the first pass, the single game's
# own road, and the three marked pieces promise four is read from.
PIECES = ['bare', 'host', 'guest', 'both', 'flat', 'swap', 'solo']
FRONT = ['host', 'guest', 'both']
# And the pair promise eight is read from, which only a record with a Solbrain
# guest is asked for: a Power Blade guest is gathered out of his own pool with
# everything he has thrown already in it, and there is nothing to lay out
# again.
ARMS = ['with', 'without']


def run(cfg, path, shots):
    """The engine walked over the list, and what it printed."""
    open(path, 'w').write(json.dumps(cfg))
    cmd = [V.GODOT, '--path', V.GAME]
    if shots:
        cmd += ['--rendering-driver', 'opengl3', '--resolution', '256x240']
    else:
        cmd += ['--headless']
    cmd += ['--', '--pb3draw=' + path]
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=3600)
    except subprocess.TimeoutExpired:
        sys.stderr.write('the engine never stopped\n')
        return {}
    out = {}
    for line in r.stdout.split('\n'):
        f = line.strip().split()
        if not f:
            continue
        if f[0] == 'rec' and len(f) == 23:
            out.setdefault(f[1], {})['rec'] = f
        elif f[0] in ('banks', 'paint') and len(f) == 5:
            out.setdefault(f[1], {})[f[0]] = (f[2], f[4])
        elif f[0] == 'arms' and len(f) == 4:
            out.setdefault(f[1], {})['arms'] = (int(f[2]), int(f[3]))
    if not out:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return out


def words(text):
    """A row of numbers the engine printed as one hex word."""
    return [int(text[i:i + 2], 16) for i in range(0, len(text), 2)]


def load(path):
    from PIL import Image
    img = Image.open(path).convert('RGB')
    return img.load(), img.size


def differ(a, b):
    """How many points of two pictures are not the same colour."""
    x, sx = load(a)
    y, sy = load(b)
    if sx != sy:
        return sx[0] * sx[1]
    return sum(1 for j in range(sy[1]) for i in range(sy[0])
               if x[i, j] != y[i, j])


def marks(a, b):
    """How many points the second picture has that the first has not."""
    x, sx = load(a)
    y, sy = load(b)
    return sum(1 for j in range(sy[1]) for i in range(sy[0])
               if x[i, j] != y[i, j])


def tally(path):
    """Which colours a picture is made of, and how much of each."""
    x, size = load(path)
    out = {}
    for j in range(size[1]):
        for i in range(size[0]):
            out[x[i, j]] = out.get(x[i, j], 0) + 1
    return out


def mark_of(path):
    """The backdrop of a marked piece and the mark on it, in that order.

    A marked piece is drawn with no background at all, so it has exactly two
    colours in it: the backdrop, which is most of it, and the mark.  A piece
    with any other number of colours is a piece the marking did not reach,
    and it is handed back as such.
    """
    seen = sorted(tally(path).items(), key=lambda p: -p[1])
    if len(seen) != 2:
        return None, None
    return seen[0][0], seen[1][0]


def front(host, guest, both):
    """Promise four, read off the three marked pieces.

    Returns (broken, hidden, white, blue) -- how many points break the rule,
    how many points of the guest's the level's own table took from him, and
    how much each of them marked.  A piece that is not two colours, or two
    marks that cannot be told apart, breaks it whole.
    """
    back, white = mark_of(host)
    back2, blue = mark_of(guest)
    h, size = load(host)
    g, _ = load(guest)
    t, _ = load(both)
    if white is None or blue is None or back != back2 or white == blue:
        return size[0] * size[1], 0, 0, 0
    broken = hidden = n_white = n_blue = 0
    for j in range(size[1]):
        for i in range(size[0]):
            mine = h[i, j] == white
            his = g[i, j] == blue
            n_white += 1 if mine else 0
            n_blue += 1 if his else 0
            hidden += 1 if mine and his else 0
            want = white if mine else (blue if his else back)
            if t[i, j] != want:
                broken += 1
    return broken, hidden, n_white, n_blue


def pick(rows):
    """Which records to photograph, out of what the walk over all of them said.

    One of each host game, one downward Power Blade area -- it counts its
    pages differently and the view is handed over differently -- and the two
    records whose tables crowd a line the most, which is what promise five is
    read from.
    """
    def line(r, which):
        return int(rows[r]['rec'][19 if which else 18])

    want = []
    for kind in ('p', 's'):
        flat = [r for r in sorted(rows) if r[0] == kind
                and rows[r]['rec'][11] == '0']
        if flat:
            want.append(flat[0])
    tall = [r for r in sorted(rows) if rows[r]['rec'][11] == '1']
    if tall:
        want.append(tall[0])
    for kind in ('p', 's'):
        same = [r for r in sorted(rows) if r[0] == kind]
        if same:
            want.append(max(same, key=lambda r: line(r, False)))
    out = []
    for r in want:
        if r not in out:
            out.append(r)
    return out


def shots_for(records, rows, into):
    """Where every piece of every photographed record goes."""
    out = {}
    for r in records:
        one = {p: os.path.join(into, '%s_%s.png' % (r, p)) for p in PIECES}
        one['front'] = {p: os.path.join(into, '%s_f%s.png' % (r, p))
                        for p in FRONT}
        if rows[r]['rec'][9] == 'sol':
            one['noarm'] = {p: os.path.join(into, '%s_a%s.png' % (r, p))
                            for p in ARMS}
        out[r] = one
    return out


def main():
    scratch = P.scratch('pb3draw')
    broken = []
    try:
        path = os.path.join(scratch, 'draw.json')
        rows = run({'frames': FRAMES}, path, False)
        if len(rows) != RECORDS:
            print('the engine raised %d records of the %d'
                  % (len(rows), RECORDS))
            return 1
        # Promise six, and the half of promise two that needs no photograph.
        stopped = []
        wrong = []
        quiet = []
        for r in sorted(rows):
            rec = rows[r]['rec']
            if rec[2] != 'up' or rec[3] != '1' or rec[13] != str(FRAMES):
                stopped.append(r)
                continue
            if rec[15] == '0' or rec[16] == '0':
                stopped.append(r)
                continue
            # Promise eight, over the whole walk: a Solbrain guest throws, and
            # what he throws is laid into his table.
            if rec[9] == 'sol' and (rec[21] == '0' or rec[22] == '0'):
                quiet.append(r)
            mine, his = rows[r]['banks']
            one, other = rows[r]['paint']
            bad = []
            if rec[9] != SHEETS['s' if r[0] == 'p' else 'p']:
                bad.append('the guest draws out of %s' % rec[9])
            if words(mine)[:4] != words(his)[:4]:
                bad.append('two backgrounds: %s and %s' % (mine, his))
            if words(mine)[4:] == words(his)[4:]:
                bad.append('one set of sprite banks: %s' % mine)
            if words(one)[:16] != words(other)[:16]:
                bad.append('two sets of background colours')
            if words(one)[16:28] == words(other)[16:28]:
                bad.append('one set of sprite colours')
            if words(one)[28:] != words(other)[28:]:
                bad.append('the fourth sprite palette is not shared')
            if bad:
                wrong.append((r, bad))
        for r in stopped[:5]:
            print('    %s' % ' '.join(rows[r]['rec']))
        for r, bad in wrong[:5]:
            print('    %s: %s' % (r, '; '.join(bad)))
        for r in quiet[:5]:
            print('    %s: nothing of the guest was ever in the air' % r)
        if stopped:
            broken.append('the road reaches')
        if wrong:
            broken.append('the guest is drawn by his own game')
        if quiet:
            broken.append('what the guest throws is on the picture')
        print('%d records raised, played %d pictures each, %d never came up '
              'or stopped short, %d were handed the wrong half of a picture'
              % (len(rows), FRAMES, len(stopped), len(wrong)))

        # And the five promises that are read off photographs.
        want = pick(rows)
        shots = shots_for(want, rows, scratch)
        shot = run({'frames': FRAMES, 'records': want, 'shots': shots},
                   path, True)
        solo = same = order = hid = flat = 0
        crowded = 0
        # Promise eight, off the photographs: how many records were taken
        # twice, and how many points the beams are worth over all of them.
        armed = beams = 0
        for r in want:
            one = shots[r]
            missing = [p for p in PIECES if not os.path.exists(one[p])]
            missing += [p for p in FRONT
                        if not os.path.exists(one['front'][p])]
            missing += [p for p in ARMS if 'noarm' in one
                        and not os.path.exists(one['noarm'][p])]
            if missing:
                print('    %s: no picture of %s' % (r, ', '.join(missing)))
                broken.append('the pictures were taken')
                continue
            n_solo = differ(one['solo'], one['host'])
            n_same = differ(one['flat'], one['swap'])
            n_host = marks(one['bare'], one['host'])
            n_guest = marks(one['bare'], one['guest'])
            n_both = marks(one['bare'], one['both'])
            bad_order, hidden, white, blue = front(
                one['front']['host'], one['front']['guest'],
                one['front']['both'])
            seen = set()
            for p in FRONT:
                seen |= set(tally(one['front'][p]))
            line = int(rows[r]['rec'][18])
            print('    %-6s solo %d, pass %d, order %d, level %d points, '
                  'guest %d, both %d, hidden %d, line %d'
                  % (r, n_solo, n_same, bad_order, n_host, n_guest, n_both,
                     hidden, line))
            solo += n_solo
            same += n_same
            order += bad_order
            hid += hidden
            if not n_host or not n_guest or not n_both:
                flat += 1
            if len(seen) != 3:
                print('    %s: the three marked pieces have %d colours '
                      'between them, not three' % (r, len(seen)))
                order += 1
            if line > 8 and blue and not bad_order:
                crowded += 1
            if 'noarm' in one:
                waited, laid = shot.get(r, {}).get('arms', (0, 0))
                n_arms = differ(one['noarm']['without'], one['noarm']['with'])
                print('    %-6s had something in the air on %s of the %d '
                      'pictures, %s sprites of it altogether; the piece taken '
                      '%d pictures on had %d of them in it, worth %d points'
                      % (r, rows[r]['rec'][21], FRAMES, rows[r]['rec'][22],
                         waited, laid, n_arms))
                armed += 1
                beams += n_arms
                if not n_arms:
                    broken.append('what the guest throws is on the picture')
        if solo:
            broken.append('the host is drawn by his own game')
        if same:
            broken.append('the second pass draws what the first would')
        if order:
            broken.append('the host is in front')
        if flat:
            broken.append('both heroes are on the picture')
        if not crowded:
            broken.append('each table keeps its own eight')
        if not armed:
            broken.append('what the guest throws is on the picture')
        print('%d records photographed in %d pieces each (%d of them in two '
              'more): %d points differ from the single game\'s own road, %d '
              'between the two passes, %d break the order, %d of the guest '
              'were taken from him by the level\'s own table'
              % (len(want), len(PIECES) + len(FRONT), armed, solo, same,
                 order, hid))
        print('%d of the photographed records fill a line with more than '
              'eight of the level\'s own and keep the guest all the same'
              % crowded)
        print('%d of them were taken twice over, with what the guest had '
              'thrown and without: %d points of the two are the beams'
              % (armed, beams))
        # A promise can be broken in more than one place -- promise eight is
        # read both off the walk and off the photographs -- and it is still
        # one promise.
        broken = list(dict.fromkeys(broken))
        for why in broken:
            print('BROKEN: %s' % why)
        print('%d of 8 promises break the promise' % len(broken))
        return 1 if broken else 0
    finally:
        P.sweep(scratch)


if __name__ == '__main__':
    sys.exit(main())
