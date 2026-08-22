shader_type canvas_item;
render_mode unshaded;

// Draws a background the way the console does: a map of tile numbers, a sheet
// of tiles that are four colours deep, and a palette that says what those four
// colours are right now.  Nothing is baked, so a palette change shows up on
// the next frame -- which is what the games use for flashing and for water.

uniform sampler2D sheet : filter_nearest;      // tiles, one colour index per pixel
uniform sampler2D map : filter_nearest;        // R = tile number, G = palette
uniform sampler2D palette : filter_nearest;    // 32 x 1, the colours in force

uniform vec2 scroll = vec2(0.0);               // world pixel at the top left
uniform vec2 map_size = vec2(1.0);             // the map, in tiles
uniform vec2 sheet_size = vec2(1024.0, 512.0); // the sheet, in pixels
uniform int banks[4];                          // which 64-tile bank each quarter uses
uniform float sheet_tiles_w = 128.0;
uniform float view_top = 0.0;      // the lines the level owns
uniform float view_bottom = 240.0;

void fragment() {
    // Outside the level's window is the status bar's business.
    bool outside = FRAGCOORD.y < view_top || FRAGCOORD.y >= view_bottom;
    vec2 world = floor(scroll + FRAGCOORD.xy);
    vec2 cell = floor(world / 8.0);
    if (outside) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else if (cell.x < 0.0 || cell.y < 0.0 || cell.x >= map_size.x || cell.y >= map_size.y) {
        COLOR = texelFetch(palette, ivec2(0, 0), 0);   // outside the level: backdrop
    } else {
        vec4 m = texelFetch(map, ivec2(cell), 0);
        int tile = int(m.r * 255.0 + 0.5);
        int pal = int(m.g * 255.0 + 0.5);
        int idx = banks[tile / 64] * 64 + (tile % 64);
        vec2 inner = mod(world, 8.0);
        vec2 sp = vec2(float(idx % int(sheet_tiles_w)) * 8.0 + inner.x,
                       float(idx / int(sheet_tiles_w)) * 8.0 + inner.y);
        float c = texelFetch(sheet, ivec2(sp), 0).r * 255.0;
        int ci = int(c / 85.0 + 0.5);
        // Colour zero of every palette is the same backdrop colour, exactly as
        // the console wires it.
        int slot = ci == 0 ? 0 : pal * 4 + ci;
        COLOR = texelFetch(palette, ivec2(slot, 0), 0);
    }
}
