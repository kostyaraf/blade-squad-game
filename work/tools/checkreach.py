"""Walk every converted area with reach.Band and report the ones that are shut.

Areas are entered from the left, so the test is: stand the player at the first
column and see whether the exit -- or, for the last area, the far right edge --
is among the metatiles he can get to."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sol2pb2, reach

PB2_EXIT = sol2pb2.PB2_EXIT


def band_of(st, run, off):
    top = run[0][1] * 16 + off * 2
    cols = [rx * 16 + k for rx, ry in run for k in range(16)]

    def solid(c, r):
        return sol2pb2.solid_at(st, cols[c], top + r)
    return reach.Band(solid, len(cols), 10)


def exit_cell(spawns):
    for i in range(0, len(spawns) - 1, 4):
        if spawns[i + 1] == PB2_EXIT:
            return spawns[i] // 1, spawns[i + 2]
    return None


def check(stage, verbose=True):
    st, screens, areas, bands = sol2pb2.convert(stage)
    bad = []
    for i, (run, off, kind) in enumerate(zip(st.pb3_runs, bands, st.pb3_kinds)):
        vert = kind == 'v'
        b = sol2pb2.vert_grid(st, run) if vert else band_of(st, run, off)
        got = sol2pb2.vert_entry(b) if vert else sol2pb2.entry_cell(b)
        if got is None:
            bad.append((i, 'no floor to stand on'))
            continue
        seen = b.reachable(*got)
        ex = exit_cell(st.pb3_spawns[i])
        if ex is None:                          # last area: just want the far end
            far = (b.h - 2) if vert else (b.w - 2)
            ok = any((r if vert else c) >= far for c, r in seen)
            what = 'far end'
        elif vert:
            er = ex[0]
            ok = any(abs(r - er) <= 1 for c, r in seen)
            what = 'exit at row %d' % er
        else:
            ec = ex[0]
            ok = any(abs(c - ec) <= 1 for c, r in seen)
            what = 'exit at col %d' % ec
        rooms_in = len({(r // 15 if vert else c // 16) for c, r in seen})
        thin = rooms_in < len(run)
        if verbose:
            print(f"  area {i:2d} {'V' if vert else 'h'} {len(run)} rooms band {off}  "
                  f"{len(seen):4d} cells  {rooms_in}/{len(run)} rooms  "
                  f"{what}: {'ok' if ok else 'BLOCKED'}{'  THIN' if thin else ''}")
        if not ok or thin:
            bad.append((i, what))
    return bad


if __name__ == '__main__':
    stages = [int(x) for x in sys.argv[1:]] or [0, 1, 2, 3, 4, 5, 6, 13, 15]
    total = shut = 0
    for s in stages:
        print(f"solbrain stage {s}")
        bad = check(s)
        total += len(sol2pb2.convert(s)[0].pb3_runs); shut += len(bad)
    print(f"\n{total - shut}/{total} areas walkable")
