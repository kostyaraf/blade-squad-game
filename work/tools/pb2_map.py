#!/usr/bin/env python3
"""The exported levels, read back the way the physics reads them.

The engine gets its map from game/data; so should anything that wants to ask
"where in this area can a man stand?", which is what puts the hero somewhere
sensible when a test opens an area the game would never have opened there.
"""
import json
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                    '..', '..'))
DATA = os.path.join(ROOT, 'game', 'data', 'pb2', 'levels')
CLASS_BYTES = [0x00, 0x01, 0x80, 0x02]


class Area:
    def __init__(self, stage, area):
        d = json.load(open(os.path.join(DATA, 'stage%d.json' % stage)))
        a = d['areas'][area]
        self.vertical = bool(a['vertical'])
        self.cls = a['terrain_class']
        screens = a['screens']
        first = d['screens'][screens[0]]
        sh = first['h'] * 4
        if self.vertical:
            self.w, self.h = 32, sh * len(screens)
        else:
            self.w, self.h = 32 * len(screens), sh
        self.tiles = [[0] * self.w for _ in range(self.h)]
        for n, si in enumerate(screens):
            sc = d['screens'][si]
            ox = 0 if self.vertical else n * 32
            oy = n * sh if self.vertical else 0
            for br in range(sc['h']):
                for bc in range(8):
                    blk = d['blocks'][sc['blocks'][br * 8 + bc]]
                    for r in range(4):
                        for c in range(4):
                            self.tiles[oy + br * 4 + r][ox + bc * 4 + c] = \
                                blk[r * 4 + c]

    def klass(self, px, py):
        """The byte the physics sees at this map pixel."""
        tx = (px >> 4) << 1
        ty = (py >> 4) << 1
        if tx < 0 or ty < 0 or tx >= self.w or ty >= self.h:
            return 0x80
        return CLASS_BYTES[self.cls[self.tiles[ty][tx]]]

    @staticmethod
    def map_row(cam, sy):
        """Which map line a screen line shows: see Pb2Level.map_row."""
        if (cam & 0xFF) + sy >= 0xF0:
            return cam + sy + 16
        return cam + sy

    def screen_y(self, map_y, cam, top=16, bottom=176):
        """The line of the screen a map row shows on, or None if it is off."""
        for sy in range(top, bottom):
            if self.map_row(cam, sy) == map_y:
                return sy
        return None

    def on_screen(self, px, py, cam):
        """Where a map pixel shows on screen, if it shows at all."""
        if self.vertical:
            sy = self.screen_y(py, cam)
            sx = px
        else:
            sy = py + 16
            sx = px - cam
            if not 16 <= sy < 176:
                sy = None
        if sy is None or not 0x18 <= sx <= 0xE8:
            return None
        return sx, sy

    def spots_on_screen(self, cam):
        """Every place in view where the hero could be dropped and just stand,
        the middle of the screen first, so that there is room around him.

        One spot is not enough: an area may have a hazard or a waking enemy
        right where the middle of the screen falls, and there the hero is hurt
        while he stands, which makes the area look unplayable when it is only
        the spot that is bad.  The caller walks this list until one holds.
        """
        out = []
        for px, py in self.standing_spots(0, self.h * 8):
            pos = self.on_screen(px, py, cam)
            if pos is None:
                continue
            out.append((abs(pos[0] - 128) + abs(pos[1] - 96), pos))
        out.sort(key=lambda it: it[0])
        return [pos for _, pos in out]

    def spot_on_screen(self, cam):
        """Somewhere in view where the hero can be dropped and just stand."""
        all_of_them = self.spots_on_screen(cam)
        return all_of_them[0] if all_of_them else None

    def picture(self, y0=0, y1=None):
        y1 = self.h * 8 if y1 is None else y1
        out = []
        for py in range(y0, y1, 16):
            out.append('%4d %s' % (py, ''.join(
                {0x00: '.', 0x01: '=', 0x80: '#', 0x02: '!'}[self.klass(px, py)]
                for px in range(0, self.w * 8, 16))))
        return '\n'.join(out)

    def standing_spots(self, top, bottom):
        """Map pixels a man could be standing on, within a band of rows.

        A spot is the bottom line of an empty cell with a solid cell under it,
        and with room on both sides so that nothing about him starts inside a
        wall.
        """
        out = []
        for cy in range(top // 16, bottom // 16):
            for cx in range(1, self.w // 2 - 1):
                px, py = cx * 16 + 8, cy * 16 + 15
                if self.klass(px, py) or not (self.klass(px, py + 1) & 0x80):
                    continue
                if self.klass(px - 8, py) or self.klass(px + 8, py):
                    continue
                if self.klass(px, py - 16) or self.klass(px, py - 32):
                    continue
                out.append((px, py))
        return out
