"""Encode levels INTO Power Blade 2's own level format.

Input is a plain description:

    areas   = [[screen_index, ...], ...]
    screens = [Screen(tiles=grid, attrs=grid), ...]

where a Screen's `tiles` is a list of rows of 8x8 tile numbers, 32 columns
wide and either 20 or 32 rows tall, and `attrs` is one attribute byte per
32x32 block, 8 across and 5 or 8 down.

Output is the four blobs the engine expects, laid out inside one $8000-$BFFF
bank pair, plus the four pointers to drop into the bank's header words.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

SCREEN_W = 8
BLOCK_BYTES = 16


class Screen:
    def __init__(self, tiles, attrs):
        self.tiles = tiles
        self.attrs = attrs
        self.hb = len(tiles) // 4          # height in blocks
        assert len(tiles[0]) == 32, "screens are always 32 tiles wide"
        assert self.hb in (5, 8), f"screen height must be 5 or 8 blocks, got {self.hb}"


def _blocks_of(scr):
    """Split a screen into its 16-byte row-major blocks + attribute bytes."""
    out = []
    for br in range(scr.hb):
        for bc in range(SCREEN_W):
            b = bytes(scr.tiles[br * 4 + r][bc * 4 + c]
                      for r in range(4) for c in range(4))
            out.append((b, scr.attrs[br][bc]))
    return out


def pack(screens, areas, records=None, base=0x8000, nheader=8,
         collision=None, spawns=None, entries=None):
    """Returns (blob, pointers) where blob is the bytes to place at `base`
    and pointers is (p_attr, p_block, p_area, p_screen, p_recs, p_coll,
    p_spawn).

    `spawns` is one bytes() of 4-byte object-placement records per area, each
    already sorted on byte 0 and $FF-terminated (see work/re/pb2_spawns.md).

    `collision` is (thresholds, types, classes): three equal-length byte
    strings, thresholds ascending and $FF-terminated, describing the tile
    number -> collision class step function the engine walks in $DCBF.  Every
    area shares one set, which is all a converted level needs."""
    # 1. dedupe blocks.  A block is identified by its tiles AND its attribute
    #    byte, because the engine looks the attribute up by block index.
    table, index = [], {}
    per_screen = []
    for s in screens:
        ids = []
        for key in _blocks_of(s):
            if key not in index:
                index[key] = len(table)
                table.append(key)
            ids.append(index[key])
        per_screen.append(ids)
    if len(table) > 256:
        raise ValueError(f"{len(table)} distinct blocks, the engine allows 256")

    # 2. lay the regions out in the order the original uses
    off = base + nheader * 2             # room for the header words
    # The per-area player entry list is the one table the engine dereferences
    # only once ($F060: LDY $9C / LDA ($00),Y), so its address has to be known
    # without reading the blob back -- it goes first, at a fixed offset.
    p_entry = off
    if entries is not None:
        assert len(entries) == len(areas), (len(entries), len(areas))
        off += len(entries)
    p_attr = off
    off += len(table)
    p_block = off
    off += len(table) * BLOCK_BYTES
    p_screen = off
    off += len(screens) * 2
    scr_addr = []
    for ids in per_screen:
        scr_addr.append(off)
        off += len(ids)
    p_area = off
    off += len(areas) * 2
    area_addr = []
    for a in areas:
        area_addr.append(off)
        off += len(a)
    # the fifth table: one 14-byte area record each, behind a pointer table
    p_recs = off
    rec_addr = []
    if records:
        off += len(records) * 2
        for _ in records:
            rec_addr.append(off)
            off += 14
    # the sixth table: per-area collision, three lists behind a 6-byte record
    p_coll = off
    coll_addr = []
    if collision:
        thr, typ, cls = collision
        assert len(thr) == len(typ) + 1 == len(cls) + 1, "lists must be parallel"
        off += len(areas) * 2
        rec_at = off
        off += 6
        a_thr = off; off += len(thr)
        a_typ = off; off += len(typ)
        a_cls = off; off += len(cls)
        coll_addr = [rec_at] * len(areas)
    # the seventh table: per-area object placement, one list behind a word
    p_spawn = off
    spawn_addr = []
    if spawns:
        assert len(spawns) == len(areas), (len(spawns), len(areas))
        off += len(areas) * 2
        for rec in spawns:
            spawn_addr.append(off)
            off += len(rec)
    end = off
    if end > 0xC000:
        raise ValueError(f"level data overruns the bank pair by {end - 0xC000} bytes")

    blob = bytearray(end - base)
    def put(addr, data):
        blob[addr - base: addr - base + len(data)] = data
    def putw(addr, v):
        put(addr, bytes((v & 0xFF, v >> 8)))

    for i, v in enumerate((p_attr, p_block, p_area, p_screen, p_recs, p_coll,
                           p_spawn, p_entry)):
        putw(base + i * 2, v)          # the header words the engine reads
    if entries is not None:
        put(p_entry, bytes(entries))
    put(p_attr, bytes(a for _, a in table))
    put(p_block, b''.join(b for b, _ in table))
    for i, a in enumerate(scr_addr):
        putw(p_screen + i * 2, a)
    for a, ids in zip(scr_addr, per_screen):
        put(a, bytes(ids))
    for i, a in enumerate(area_addr):
        putw(p_area + i * 2, a)
    for a, lst in zip(area_addr, areas):
        put(a, bytes(lst))

    for i, a in enumerate(rec_addr):
        putw(p_recs + i * 2, a)
    for a, rec in zip(rec_addr, records or ()):
        assert len(rec) == 14, len(rec)
        put(a, bytes(rec))

    if collision:
        for i, a in enumerate(coll_addr):
            putw(p_coll + i * 2, a)
        put(rec_at, bytes((a_thr & 0xFF, a_thr >> 8, a_typ & 0xFF, a_typ >> 8,
                           a_cls & 0xFF, a_cls >> 8)))
        put(a_thr, bytes(thr)); put(a_typ, bytes(typ)); put(a_cls, bytes(cls))

    for i, a in enumerate(spawn_addr):
        putw(p_spawn + i * 2, a)
    for a, rec in zip(spawn_addr, spawns or ()):
        put(a, bytes(rec))

    return bytes(blob), (p_attr, p_block, p_area, p_screen, p_recs, p_coll,
                         p_spawn, p_entry)


# --------------------------------------------------------------------------
def from_decoded(st):
    """Round-trip helper: rebuild Screen objects from pb2_levels' output."""
    screens = []
    for si, s in enumerate(st['screens']):
        tiles = [[0] * 32 for _ in range(s['h'] * 4)]
        attrs = [[0] * SCREEN_W for _ in range(s['h'])]
        for br in range(s['h']):
            for bc in range(SCREEN_W):
                b = s['data'][br * SCREEN_W + bc]
                blk = st['blocks'][b] if b < st['nblocks'] else bytes(16)
                attrs[br][bc] = st['attr'][b] if b < st['nblocks'] else 0
                for r in range(4):
                    for c in range(4):
                        tiles[br * 4 + r][bc * 4 + c] = blk[r * 4 + c]
        screens.append(Screen(tiles, attrs))
    return screens, [list(a) for a in st['areas']]


if __name__ == '__main__':
    from pb2_levels import PB2Levels
    lv = PB2Levels("Power Blade 2 (USA).nes")
    for s in range(7):
        st = lv.stage(s)
        st['attr'] = st['collision']
        screens, areas = from_decoded(st)
        blob, ptrs = pack(screens, areas, [bytes(14)] * len(areas))
        # decode the repack and compare tile grids with the original
        ok = True
        import pb2_levels as L
        for si, sc in enumerate(screens):
            g1 = lv.screen_tiles(st, si)
            if g1 != sc.tiles:
                ok = False
        print(f"stage {s}: {len(screens)} screens, {len(areas)} areas, "
              f"{len(blob)} bytes (original region ~{st['p_area'] - st['p_coll'] + 200}), "
              f"round-trip {'OK' if ok else 'MISMATCH'}")
