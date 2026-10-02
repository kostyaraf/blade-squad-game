# Solbrain traversal artwork

Edit `slide.aseprite` and `climb.aseprite` in Aseprite. Their indexed palette is
the ordinary native Solbrain palette. The separate body-part layers are editable.
`native-reference.aseprite` and `nova-reference.aseprite` contain extracted
reference poses, not replacement gameplay assets.

From the repository root:

```sh
/Applications/Aseprite.app/Contents/MacOS/aseprite -b --script work/art/export_traversal.lua
/Applications/Aseprite.app/Contents/MacOS/aseprite -b --script work/art/preview_traversal.lua
python3 work/extract/verify_pb3_sol_moves.py
python3 work/extract/verify_pb3_playthrough.py
```

`author_traversal.lua` records the initial construction, and overwrites the
masters when explicitly run. Do not run it after manual edits unless replacing
those edits is intended. Normal updates export the saved `.aseprite` files.

Slide: 32×16, origin (16,16). Ladder: 24×48, origin (12,40), with transparent
padding. The taller canvas permits raised arms without shortening the torso or
moving the native head/feet anchors. Runtime hitboxes remain independent of art.

The ladder phase advances every four world pixels, reverses on descent and holds
when stationary. Mount/dismount coordinate snaps do not advance the phase.
Visual review files are in `docs/qa/solbrain-animation/`.
