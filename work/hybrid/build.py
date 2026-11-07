#!/usr/bin/env python3
"""Build PB3 hybrid levels from their text sources.

    python3 work/hybrid/build.py            # every work/hybrid/src/h*.json
    python3 work/hybrid/build.py --check    # build + print the reach check

A source (work/hybrid/src/hN.json) is a chain of segments; each segment is a
level of one of the two games and runs under that game's own rules
(docs/hybrid/authoring.md).

  pb2 segment  {"game": "pb2", "donor": {"stage", "area"}, "legend",
                "screens": [{"copy": donor screen id} | {"rows": 5 x 8 chars}],
                "spawns": [...]}
               The donor area gives blocks, palettes, tiles, terrain, enemy
               sprite banks and the code-level identity (stage/area numbers
               the cartridge code asks).  Only screens and spawns are new.
               A legend value that is a list alternates by block column, the
               way the donor's own floors and ceilings alternate two blocks.
  sol segment  {"game": "sol", "stage": N} -- an existing Solbrain stage.

Output: game/data/pb3/hybrid/index.json and one hN_K.json per pb2 segment,
in the donor's own stage format, read by Pb2Level(stage, area, file).
"""
import copy
import glob
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import levelgrid as LG  # noqa: E402

OUT = os.path.join(LG.DATA, 'pb3', 'hybrid')

# Movement envelope for the reach check, in 16-px cells.  Both heroes must be
# able to do every move, so the smaller of the two is used (levels.md
# "почему проходимо"):  Nova jumps 62 px high and ~48 px across from a walk;
# PB3 gives Solbrain the same 64-px step on Power Blade maps (GAP-10).
REACH = {'up': 3, 'across': 3}
SUPPORT = set('#><')
OPEN = set('.=H')


def build_pb2(seg, name):
    st, ar = seg['donor']['stage'], seg['donor']['area']
    d = LG.load(os.path.join(LG.DATA, 'pb2', 'levels', 'stage%d.json' % st))
    out = copy.deepcopy(d)
    legend = seg['legend']
    donor = d['areas'][ar]
    h = int(d['screens'][int(donor['screens'][0])]['h'])
    ids = []
    for sc in seg['screens']:
        if 'copy' in sc:
            ids.append(int(sc['copy']))
            continue
        rows = sc['rows']
        assert len(rows) == h and all(len(r) == 8 for r in rows), rows
        blocks = []
        for r in rows:
            for c, ch in enumerate(r):
                v = legend[ch]
                blocks.append(int(v[c % len(v)] if isinstance(v, list) else v))
        out['screens'].append({'w': 8, 'h': h, 'blocks': blocks})
        ids.append(len(out['screens']) - 1)
    # the door screen keeps its place relative to the donor's last screen,
    # so the door's nametable address and the camera's last page still hold
    assert len(ids) % 2 == len(donor['screens']) % 2, 'door screen parity'
    a = out['areas'][ar]
    a['screens'] = ids
    a['cam_last'] = len(ids) - 1
    a['spawns'] = sorted(seg['spawns'], key=lambda s: s['along'])
    path = os.path.join(OUT, name)
    with open(path, 'w') as f:
        json.dump(out, f, separators=(',', ':'))
    return out, {'game': 'pb2', 'stage': st, 'area': ar,
                 'file': 'pb3/hybrid/' + name}


def stands(g, x, y):
    c = g['cells']
    if not (0 <= x < g['w'] and 1 <= y < g['h'] - 1):
        return False
    return c[y][x] in OPEN and c[y - 1][x] in OPEN and c[y + 1][x] in SUPPORT


def reach(g, start, goal_x):
    """Breadth-first over standing cells; True if column goal_x is reached."""
    seen = {start}
    todo = [start]
    while todo:
        x, y = todo.pop()
        if abs(x - goal_x) <= 3:
            return True, len(seen)
        nxt = []
        # a jump: up to `up` cells higher, `across` cells away; falling
        # further down carries the hero one more cell across per cell down
        for dy in range(-REACH['up'], g['h']):
            span = REACH['across'] + max(0, dy)
            for dx in range(-span, span + 1):
                nx, ny = x + dx, y + dy
                if stands(g, nx, ny):
                    nxt.append((nx, ny))
        for p in nxt:
            if p not in seen:
                seen.add(p)
                todo.append(p)
    return False, len(seen)


def check_pb2(data, seg):
    g = LG.pb2_area(seg['stage'], seg['area'], data)
    a = data['areas'][seg['area']]
    sx = (int(a['cam_screen']) * 256 + int(a['start']['x'])) // 16
    sy = (int(a['start']['y']) - 16) // 16
    door = [s for s in a['spawns'] if s['type'] == 4][0]['along']
    ok, n = reach(g, (sx, sy), door)
    print('\n'.join(g['cells']))
    pits = sum(1 for x in range(g['w'])
               if all(g['cells'][y][x] not in SUPPORT for y in range(g['h'] - 3, g['h'])))
    print('start (%d,%d) door x=%d reachable=%s standing cells=%d pits=%d screens=%d enemies=%d'
          % (sx, sy, door, ok, n, pits, len(a['screens']),
             sum(1 for s in a['spawns'] if s['type'] > 6)))
    return ok


def main():
    os.makedirs(OUT, exist_ok=True)
    levels = []
    ok = True
    for src in sorted(glob.glob(os.path.join(HERE, 'src', 'h*.json'))):
        base = os.path.splitext(os.path.basename(src))[0]
        s = LG.load(src)
        segs = []
        for k, seg in enumerate(s['segments']):
            if seg['game'] == 'pb2':
                data, ref = build_pb2(seg, '%s_%d.json' % (base, k))
                if '--check' in sys.argv:
                    print('== %s segment %d' % (base, k))
                    ok = check_pb2(data, ref) and ok
                segs.append(ref)
            else:
                segs.append({'game': 'sol', 'stage': int(seg['stage'])})
        levels.append({'name': s['name'], 'segments': segs})
    with open(os.path.join(OUT, 'index.json'), 'w') as f:
        json.dump({'levels': levels}, f, indent=1)
    print('built %d hybrid level(s)' % len(levels))
    sys.exit(0 if ok else 1)


if __name__ == '__main__':
    main()
