# PB3 Switch homebrew

The shipping files are `build/switch/switch/PB3/PB3.nro` and `PB3.pck`.
They target homebrew on Switch (including Kefir/Atmosphere); this is not an
official Nintendo SDK build. Hardware execution has not been tested.

The adapter generates a **separate Godot 3.5.3 project** from Godot 4 sources.
It preserves integer vectors with `NXVec`, reference semantics and integer
coercion of packed arrays, callbacks, static storage, image access and shader
uniforms. Godot 3 cannot handle the original circular static class references,
so constants are exported using Godot 4 and other scripts are loaded through
a cache. Only interactive main-scene functions are retained in the export.
The main game source is not modified. This converter is project-specific.

Tools: [Homebrodot 3.5.3+switch+vita](https://github.com/Homebrodot/Godot/releases/tag/3.5.3%2Bswitch%2Bvita).
The downloaded `macos-editor.zip` SHA-256 is
`ade8d1b725a4f3cc3a91431d015696cfb6f108057c0e783a260a3dc5c1f5ae05`;
`switch-template.tpz` is
`1445e0f0c068fb3e8234e16d790fff958ec0fbfbc2fa65efc8049fa449cf4ff0`.
Templates are installed in Godot's `templates/3.5.3.stable` directory.
The editor is `build/switch-tools/editor/godot.osx.opt.tools.64`.

## Rebuild on this Mac

Run from the repository root. For the exact delivered version, retain
`build/switch-source`, the immutable source snapshot used during validation.
Use `game` instead of `build/switch-source` to convert the current game;
regenerate the constants from the **same** source directory first.

```sh
/Applications/Godot_mono.app/Contents/MacOS/Godot --headless \
  --path build/switch-source --script ../../work/switch/dump_constants.gd \
  -- --output="$PWD/build/switch-tools/constants.json"
python3 work/switch/convert.py --source build/switch-source
cp work/switch/export_presets.cfg build/switch-project/export_presets.cfg
build/switch-tools/editor/godot.osx.opt.tools.64 --path build/switch-project \
  --export 'Switch Homebrew' ../switch/switch/PB3/PB3.nro
```

On a clean project, open the generated project once with `--editor` to register
its script classes and import resources before export. The exporter also scans
resources. Keep generated files under `build/`; do not commit downloaded engines
or generated project sources.

## Validation

`entries.gd` exercises 83 entry points with Nova, Solbrain and a mixed pair,
30 ticks each (ending a run early if it returns to the list). Run it with the
Godot 3 editor against `build/switch-project`. To run the identical probe under
Godot 4, replace `to_json(` with `JSON.stringify(` and use the original source
snapshot. Compare parsed `TRACE:` JSON lines, not formatted text.

For the rebuilt main c1ce69e on 2026-10-04: 7422 frame records matched exactly: world/fixed-point positions,
velocities, actor states and session events. The earlier snapshot's 960-frame probe also
matched. `visual.gd` checks interactive scenes and writes a screenshot under
`user://`; pass `-- --mode=pb2`, `sol`, or `pb3`. An earlier snapshot's Solbrain screenshot
matched Godot 4 pixel for pixel; the current build's PB3 scene was rendered
and the packed scene was launched without script or shader errors. The packed PCK was also run from `/tmp`, outside
the source project. These checks do not establish full level playthrough or
performance on Switch.

Known limitation: the supplied Switch template calls `padConfigureInput(1, ...)`.
The game retains its co-op logic, but a second physical controller requires a
rebuilt template and hardware validation. Godot reports existing resource leaks
when some Solbrain scenes exit, also observed in the original Godot 4 project.

Third-party engine notices are in `licenses/`; the UI font and its license are
in `fonts/`. The delivered ZIP includes those notices and Russian launch guidance.

Current source snapshot: `build/switch-source-current`, created from Git main
commit c1ce69e (not pending WIP). Delivered archive: `build/PB3-Switch-v0.1.0.zip`.
Checks on 2026-10-04 returned code 0 without SCRIPT ERROR.
