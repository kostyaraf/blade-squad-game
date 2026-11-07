"""Read the exported level data of both games into one simple cell grid.

A cell is 16x16 px in both games (the unit both physics engines read).  Each
cell gets one of a small set of kinds, so the two games can be measured and
drawn with the same ruler:

    .  air          #  solid          H  ladder (PB2)     ^  hurts/kills
    ~  water        >  belt right     <  belt left        =  current/flow
    n  net (Sol)    c  crate/alt (Sol, breakable or switchable)

Sources (no guessing, see the docs quoted next to each rule):
  PB2  game/data/pb2/levels/stageN.json, the same unfolding as
       game/src/pb2_level.gd (_build, terrain_at, class_byte): a cell is what
       the top-left 8x8 tile of the cell says.
  Sol  game/data/sol/levels/stageN.json, the same unfolding as
       game/src/sol_level.gd; collision = props & 0x1F (sol_level_format.md
       4.5), classes read off sol_player.md 4 and sol_as_pb2.gd.
"""
import json
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
DATA = os.path.join(ROOT, 'game', 'data')


def load(path):
    with open(path) as f:
        return json.load(f)


# ---------------------------------------------------------------- PB2

PB2_TERRAIN = {0x00: '.', 0x01: 'H', 0x02: '^', 0x03: '~', 0x04: '~',
               0x05: '=', 0x06: '=', 0x80: '#', 0x87: '>', 0x88: '<'}


def pb2_area(stage, area, data=None):
    """Return dict(w, h, cells[list of str rows], spawns, meta) in cells."""
    d = data or load(os.path.join(DATA, 'pb2', 'levels', 'stage%d.json' % stage))
    a = d['areas'][area]
    screens = a['screens']
    all_screens = d['screens']
    blocks = d['blocks']
    vertical = int(a['vertical']) != 0
    sh = int(all_screens[int(screens[0])]['h']) * 4
    if vertical:
        wt, ht = 32, sh * len(screens)
    else:
        wt, ht = 32 * len(screens), sh
    tiles = [[0] * wt for _ in range(ht)]
    for n, si in enumerate(screens):
        sc = all_screens[int(si)]
        ox = 0 if vertical else n * 32
        oy = n * sh if vertical else 0
        for br in range(int(sc['h'])):
            for bc in range(8):
                b = int(sc['blocks'][br * 8 + bc])
                blk = blocks[b] if b < len(blocks) else [0] * 16
                for r in range(4):
                    for c in range(4):
                        tiles[oy + br * 4 + r][ox + bc * 4 + c] = int(blk[r * 4 + c])
    terrain = a['terrain']
    cls = a['terrain_class']
    rows = []
    for cy in range(ht // 2):
        row = ''
        for cx in range(wt // 2):
            t = tiles[cy * 2][cx * 2]
            k = PB2_TERRAIN.get(int(terrain[t]), '?')
            # class $02 also hurts even when terrain says nothing (class_byte)
            if k == '.' and int(cls[t]) == 3:
                k = '^'
            row += k
        rows.append(row)
    return {'game': 'pb2', 'stage': stage, 'area': area, 'vertical': vertical,
            'w': wt // 2, 'h': ht // 2, 'cells': rows, 'spawns': a['spawns'],
            'screens': len(screens), 'kind': int(a.get('kind', 1)),
            'start': a['start'], 'tiles': tiles}


# ---------------------------------------------------------------- Sol

def sol_kind(c, crate):
    """One Solbrain collision code (props & 0x1F) to a cell kind."""
    if c in (0x16, 0x17):
        return '>' if c == 0x16 else '<'       # $963D belts, sol_as_pb2.gd
    if (c & 0x1C) in (0x04, 0x1C):
        return 'n'                             # net_at(), $A043/$A065
    if c >= 0x10:
        if c & 0x08:
            return '^'                         # solid that hurts, $A3B0
        return 'c' if crate else '#'
    if (c & 0x0C) == 0x08:
        return '^'                             # bit 3 = damage, $A1A1
    if c == 0x0D:
        return '~'                             # water, sol_as_pb2.gd table
    if (c & 0x0C) == 0x0C:
        return '='                             # other $0C..$0F: current/none
    return 'c' if crate else '.'


def sol_stage(stage, data=None):
    d = data or load(os.path.join(DATA, 'sol', 'levels', 'stage%d.json' % stage))
    props = d['props']
    alt = d['alt']
    rooms = d['rooms']
    screens = d['screens']
    blocks = d['blocks']
    used = []
    for ry in range(16):
        for rx in range(16):
            v = rooms[ry][rx] if ry < len(rooms) and rx < len(rooms[ry]) else None
            if v is None or int(v) == 0 or int(v) >= len(screens):
                continue
            if ry == 0:
                continue                       # row 0 is padding (sol_level.gd)
            used.append((rx, ry, int(v)))
    if not used:
        return None
    x0 = min(u[0] for u in used); x1 = max(u[0] for u in used)
    y0 = min(u[1] for u in used); y1 = max(u[1] for u in used)
    W, H = (x1 - x0 + 1) * 16, (y1 - y0 + 1) * 16
    grid = [[' '] * W for _ in range(H)]
    for rx, ry, s in used:
        scr = screens[s]
        for br in range(8):
            for bc in range(8):
                blk = blocks[int(scr[br][bc])]
                for hx in range(2):
                    for hy in range(2):
                        m = int(blk[hx * 2 + hy])
                        crate = (props[m] & 0x20) != 0
                        shown = int(alt[m]) if crate else m
                        c = props[shown] & 0x1F if crate else props[m] & 0x1F
                        k = sol_kind(c, crate)
                        grid[(ry - y0) * 16 + br * 2 + hy][(rx - x0) * 16 + bc * 2 + hx] = k
    objs = []
    rg = {int(k): int(v) for k, v in d['room_objects'].items()}
    for room, g in rg.items():
        for o in d['object_groups'].get(str(g), []):
            objs.append({'room': room, 'type': o['param'], 'id': o['kind'], 'gate': o['gate'],
                         'x': o['x'] >> 4, 'y': o['y'] >> 4})
    # an object list shared by several rooms is spawned once per room entered;
    # count unique (x, y, type) so a shared group is not counted twice
    seen = set(); uniq = []
    for o in objs:
        key = (o['type'], o['x'], o['y'])
        if key not in seen:
            seen.add(key); uniq.append(o)
    return {'game': 'sol', 'stage': stage, 'w': W, 'h': H,
            'cells': [''.join(r) for r in grid], 'rooms': used,
            'origin': (x0 * 256, y0 * 256), 'objects': uniq,
            'start': (d['start']['x'] >> 4, d['start']['y'] >> 4)}
