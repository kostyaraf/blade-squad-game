#!/usr/bin/env python3
"""Measure the building blocks of every level of both games.

    python3 work/hybrid/patterns.py            # tables (markdown) to stdout
    python3 work/hybrid/patterns.py --img      # + schematic maps in docs/hybrid/img
    python3 work/hybrid/patterns.py --json F   # raw numbers

Everything is read from game/data (the extractor output), see levelgrid.py.
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import levelgrid as LG  # noqa: E402

# PB2 spawn types that are not enemies (pb2_spawns.md 5.1, pb2_objects.gd).
PB2_ITEM = {0x02}
PB2_FLOW = {0x03, 0x04, 0x05, 0x06, 0x0D, 0x0E}
PB2_TERRAIN_OBJ = {0x09: 'falling platform', 0x0A: 'rail platform',
                   0x0B: 'swing grip', 0x0C: 'breakable block'}
PB2_SPAWNER = {0x1B, 0x1E, 0x2F}          # nest, hatch, opener
PB2_NAMES = {
    0x07: 'shuttle up/down', 0x08: 'shuttle sideways', 0x10: 'circler',
    0x12: 'swimmer-drifter', 0x13: 'turret (sits, shoots)', 0x15: '?15',
    0x17: 'walker that drops', 0x19: 'shuttle on count', 0x1A: '?1A',
    0x1B: 'nest', 0x1D: 'walker that stops to shoot', 0x1E: 'hatch',
    0x20: 'thrower', 0x22: 'hanging spitter', 0x23: 'floor/ceiling swapper',
    0x24: 'stand-off spitter', 0x27: '?27', 0x29: '?29', 0x2B: 'twin',
    0x2C: 'runner-grabber', 0x2F: 'opener (spawns $33)', 0x36: 'chain head',
    0x37: 'diver', 0x38: 'big grabber', 0x39: 'jumper', 0x3A: 'swimmer',
    0x3C: 'hopper-spitter', 0x3E: 'flier dropper', 0x40: 'hovering gunner',
    0x42: 'returner', 0x0F: '?0F',
}
# Sol object types (sol_enemy_types.md 2).  Markers/triggers are not enemies.
SOL_MARKER = {0x00, 0x01, 0x07, 0x14}
SOL_TRAP = {0x25: 'falling crusher', 0x1E: 'periodic dropper',
            0x1F: 'ceiling dropper', 0x27: 'flame jet', 0x20: 'blower R',
            0x21: 'blower L', 0x29: 'bombardier'}
SOL_NAMES = {
    0x02: 'weak walker', 0x03: 'flyer above', 0x04: 'fixed shooter',
    0x06: 'tall robot', 0x13: 'fighter', 0x16: 'melee soldier',
    0x17: 'gun soldier', 0x18: 'gun soldier 2', 0x19: 'thrower',
    0x1B: 'span patroller', 0x1D: 'armoured robot', 0x22: 'wall gun R',
    0x23: 'wall gun L', 0x24: 'turret', 0x26: 'animated prop',
    0x28: 'slow brute', 0x2C: 'robot beast', 0x2D: 'hopper',
}
# Sol stage chains (script writes the next stage into $55,
# game/src/sol_script.gd p(0x55, N); boss stages have no objects).
SOL_CHAINS = [[0, 8], [1, 2, 13], [3, 9, 18], [4, 5, 17], [6, 7, 12],
              [10, 11, 14], [15, 16, 19]]
SOL_BOSS = {8, 12, 13, 14, 17, 18, 19}


def runs(row, pred):
    out, n = [], 0
    for ch in row + '\0':
        if pred(ch):
            n += 1
        elif n:
            out.append(n); n = 0
    return out


def census(cells):
    c = {}
    for r in cells:
        for ch in r:
            c[ch] = c.get(ch, 0) + 1
    return c


def pits_horizontal(cells):
    """Gaps in the floor of a one-screen-tall strip: columns where nothing
    in the bottom two rows holds the hero (solid, ladder, belt)."""
    h = len(cells)
    w = len(cells[0])
    holds = set('#H><c')
    col = ''
    for x in range(w):
        ok = any(cells[y][x] in holds for y in range(max(0, h - 3), h))
        col += '#' if ok else ' '
    return runs(col, lambda ch: ch == ' ')


def ledge_steps(cells):
    """Height changes of the walkable surface, column to column (cells)."""
    h = len(cells)
    tops = []
    for x in range(len(cells[0])):
        t = None
        for y in range(h):
            if cells[y][x] in '#><c' and (y == 0 or cells[y - 1][x] not in '#><c'):
                t = y  # lowest-most surface would be the last; take highest
                break
        tops.append(t)
    ups = [tops[i] - tops[i + 1] for i in range(len(tops) - 1)
           if tops[i] is not None and tops[i + 1] is not None and tops[i] > tops[i + 1]]
    return ups


def pb2_metrics():
    out = []
    for st in range(7):
        n = LG.pb2_area.__defaults__  # noqa
        idx = LG.load(os.path.join(LG.DATA, 'pb2', 'levels', 'index.json'))
        areas = idx['stages'][st]['areas']
        d = LG.load(os.path.join(LG.DATA, 'pb2', 'levels', 'stage%d.json' % st))
        for ar in range(areas):
            g = LG.pb2_area(st, ar, d)
            cen = census(g['cells'])
            sp = g['spawns']
            enemies = [s for s in sp if s['type'] not in PB2_ITEM | PB2_FLOW
                       and s['type'] not in PB2_TERRAIN_OBJ]
            items = [s for s in sp if s['type'] in PB2_ITEM]
            tobj = [s for s in sp if s['type'] in PB2_TERRAIN_OBJ]
            pits = pits_horizontal(g['cells']) if not g['vertical'] else []
            ladders = sum(len(runs(''.join(r[x] for r in g['cells']), lambda c: c == 'H'))
                          for x in range(g['w']))
            spikes = sum(len(runs(r, lambda c: c == '^')) for r in g['cells'])
            out.append({
                'id': 'p%d.%d' % (st, ar), 'stage': st, 'area': ar,
                'boss_room': st == 6,
                'axis': 'V' if g['vertical'] else 'H', 'screens': g['screens'],
                'w': g['w'], 'h': g['h'], 'kind': g['kind'],
                'enemies': len(enemies), 'items': len(items),
                'terrain_objs': len(tobj),
                'enemy_types': sorted({s['type'] for s in enemies}),
                'tobj_types': sorted({s['type'] for s in tobj}),
                'per_screen': round(len(enemies) / g['screens'], 2),
                'solid': cen.get('#', 0), 'ladder_cells': cen.get('H', 0),
                'ladders': ladders, 'spike_cells': cen.get('^', 0),
                'spike_runs': spikes, 'water': cen.get('~', 0),
                'belts': cen.get('>', 0) + cen.get('<', 0),
                'flow': cen.get('=', 0), 'pits': len(pits),
                'pit_max': max(pits) if pits else 0,
                'cells': g['cells'], 'spawns': sp,
            })
    return out


def sol_metrics():
    out = []
    for st in range(20):
        g = LG.sol_stage(st)
        if g is None:
            continue
        cen = census(g['cells'])
        en = [o for o in g['objects'] if o['type'] not in SOL_MARKER
              and o['type'] not in SOL_TRAP]
        traps = [o for o in g['objects'] if o['type'] in SOL_TRAP]
        rooms = g['rooms']
        rs = {(r[0], r[1]) for r in rooms}
        hor = sum(1 for (x, y) in rs if (x + 1, y) in rs)
        ver = sum(1 for (x, y) in rs if (x, y + 1) in rs)
        crates = cen.get('c', 0)
        out.append({
            'id': 's%d' % st, 'stage': st, 'boss': st in SOL_BOSS,
            'rooms': len(rooms), 'w': g['w'], 'h': g['h'],
            'links_h': hor, 'links_v': ver,
            'enemies': len(en), 'traps': len(traps),
            'per_room': round(len(en) / len(rooms), 2),
            'enemy_types': sorted({o['type'] for o in en}),
            'trap_types': sorted({o['type'] for o in traps}),
            'solid': cen.get('#', 0), 'hurt': cen.get('^', 0),
            'water': cen.get('~', 0), 'belts': cen.get('>', 0) + cen.get('<', 0),
            'nets': cen.get('n', 0), 'crates': crates, 'flow': cen.get('=', 0),
            'cells': g['cells'], 'objects': g['objects'], 'origin': g['origin'],
        })
    return out


def md_pb2(rows):
    print('| уровень | ось | экранов | врагов | на экран | предметы | площадки/блоки | ямы (макс., кл.) | шипы (кл.) | лестниц | вода | ленты | типы врагов |')
    print('|---|---|---|---|---|---|---|---|---|---|---|---|---|')
    for r in rows:
        print('| %s%s | %s | %d | %d | %.2f | %d | %d | %d (%d) | %d | %d | %d | %d | %s |' % (
            r['id'], ' (босс)' if r['boss_room'] else '', r['axis'], r['screens'],
            r['enemies'], r['per_screen'], r['items'], r['terrain_objs'],
            r['pits'], r['pit_max'], r['spike_cells'], r['ladders'],
            r['water'], r['belts'],
            ' '.join('%02X' % t for t in r['enemy_types'])))


def md_sol(rows):
    print('| этап | комнат | гориз./верт. связей | врагов | на комнату | ловушки | шипы/огонь (кл.) | вода | ленты | сетки | кубики | типы врагов |')
    print('|---|---|---|---|---|---|---|---|---|---|---|---|')
    for r in rows:
        print('| %s%s | %d | %d / %d | %d | %.2f | %d | %d | %d | %d | %d | %d | %s |' % (
            r['id'], ' (босс)' if r['boss'] else '', r['rooms'], r['links_h'],
            r['links_v'], r['enemies'], r['per_room'], r['traps'], r['hurt'],
            r['water'], r['belts'], r['nets'], r['crates'],
            ' '.join('%02X' % t for t in r['enemy_types'])))


def summary(pb2, sol):
    print('\n## Сводка по стадиям PB2 (без комнат боссов)\n')
    print('| стадия | комнат | экранов | врагов | врагов/экран | ям | шипов (кл.) | вертикальных комнат |')
    print('|---|---|---|---|---|---|---|---|')
    for st in range(6):
        a = [r for r in pb2 if r['stage'] == st]
        scr = sum(r['screens'] for r in a)
        en = sum(r['enemies'] for r in a)
        print('| %d | %d | %d | %d | %.2f | %d | %d | %d |' % (
            st + 1, len(a), scr, en, en / scr, sum(r['pits'] for r in a),
            sum(r['spike_cells'] for r in a), sum(1 for r in a if r['axis'] == 'V')))
    print('\n## Сводка по районам Solbrain (цепочки этапов)\n')
    print('| цепочка | комнат | врагов | врагов/комнату | ловушек | шипы (кл.) | кубики |')
    print('|---|---|---|---|---|---|---|')
    by = {r['stage']: r for r in sol}
    for ch in SOL_CHAINS:
        a = [by[s] for s in ch if s in by]
        rooms = sum(r['rooms'] for r in a if not r['boss'])
        en = sum(r['enemies'] for r in a)
        print('| %s | %d | %d | %.2f | %d | %d | %d |' % (
            ' → '.join(map(str, ch)), rooms, en, en / max(rooms, 1),
            sum(r['traps'] for r in a), sum(r['hurt'] for r in a),
            sum(r['crates'] for r in a)))


COLORS = {'.': (16, 16, 24), ' ': (0, 0, 0), '#': (120, 120, 130),
          'H': (220, 180, 40), '^': (230, 40, 40), '~': (40, 90, 220),
          '>': (60, 200, 90), '<': (60, 200, 90), '=': (80, 160, 200),
          'n': (200, 100, 220), 'c': (190, 120, 60), '?': (255, 0, 255)}


def draw(cells, marks, path, scale=4):
    from PIL import Image, ImageDraw
    h, w = len(cells), len(cells[0])
    img = Image.new('RGB', (w * scale, h * scale))
    d = ImageDraw.Draw(img)
    for y, row in enumerate(cells):
        for x, ch in enumerate(row):
            d.rectangle([x * scale, y * scale, x * scale + scale - 1, y * scale + scale - 1],
                        fill=COLORS.get(ch, (255, 0, 255)))
    for (x, y, col) in marks:
        d.ellipse([x * scale - 3, y * scale - 3, x * scale + 3, y * scale + 3], fill=col)
    img.save(path)


def images(pb2, sol):
    outdir = os.path.join(LG.ROOT, 'docs', 'hybrid', 'img')
    os.makedirs(outdir, exist_ok=True)
    for r in pb2:
        if r['id'] not in ('p0.0', 'p0.1', 'p2.3', 'p4.2', 'p5.6'):
            continue
        marks = []
        for s in r['spawns']:
            if r['axis'] == 'H':
                x, y = s['along'], s['across'] // 16
            else:
                x, y = s['across'] // 16, s['along']
            col = (255, 255, 255) if s['type'] in PB2_ITEM else \
                (255, 160, 0) if s['type'] in PB2_FLOW else (255, 60, 200)
            marks.append((x, y, col))
        draw(r['cells'], marks, os.path.join(outdir, '%s.png' % r['id'].replace('.', '_')))
    for r in sol:
        if r['id'] not in ('s0', 's3', 's10', 's15'):
            continue
        ox, oy = r['origin']
        marks = []
        for o in r['objects']:
            col = (90, 90, 90) if o['type'] in SOL_MARKER else \
                (255, 160, 0) if o['type'] in SOL_TRAP else (255, 60, 200)
            marks.append(((o['x'] - ox) // 16, (o['y'] - oy) // 16, col))
        draw(r['cells'], marks, os.path.join(outdir, '%s.png' % r['id']), scale=2)


def main():
    pb2 = pb2_metrics()
    sol = sol_metrics()
    if '--json' in sys.argv:
        f = sys.argv[sys.argv.index('--json') + 1]
        strip = lambda rs: [{k: v for k, v in r.items() if k not in ('cells', 'spawns', 'objects')} for r in rs]
        json.dump({'pb2': strip(pb2), 'sol': strip(sol)}, open(f, 'w'), indent=1)
    print('## Power Blade 2, по комнатам\n')
    md_pb2(pb2)
    print('\n## Solbrain, по этапам\n')
    md_sol(sol)
    summary(pb2, sol)
    if '--img' in sys.argv:
        images(pb2, sol)


if __name__ == '__main__':
    main()
