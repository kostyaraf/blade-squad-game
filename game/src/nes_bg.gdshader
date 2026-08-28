shader_type canvas_item;
render_mode unshaded;

// Draws a picture the way the console does: a map of tile numbers, a sheet of
// tiles that are four colours deep, and a palette that says what those four
// colours are right now.  Nothing is baked, so a palette change shows up on
// the next frame -- which is what the games use for flashing and for water.
//
// Over the background go the sixty-four sprites of the console's own table,
// read straight out of $0200 as the engine filled it: y, tile, attributes, x.
// Power Blade 2 runs the console in its tall-sprite mode, so a sprite is eight
// wide and sixteen down and the lowest bit of its tile number says which half
// of the tile memory it comes out of.  The console draws no more than eight
// sprites on a line and takes them in the order they stand in the table, which
// is why the game shuffles where in the table it writes them and why what is
// drawn flickers when there is too much of it: both are kept here.

uniform sampler2D sheet : filter_nearest;      // tiles, one colour index per pixel
uniform sampler2D map : filter_nearest;        // R = tile number, G = palette
uniform sampler2D palette : filter_nearest;    // 32 x 1, the colours in force
uniform sampler2D oam : filter_nearest;        // 64 x 1: R = y, G = tile, B = attr, A = x

uniform vec2 scroll = vec2(0.0);               // world pixel at the top left
uniform vec2 map_size = vec2(1.0);             // the map, in tiles
uniform vec2 sheet_size = vec2(1024.0, 512.0); // the sheet, in pixels
uniform int banks[8];                          // the eight 1 KB banks: four for the
                                               // background, four for the sprites
uniform float sheet_tiles_w = 128.0;
uniform float view_top = 0.0;      // the lines the level owns
uniform float view_bottom = 240.0;
uniform bool sprites_on = false;

int tile_colour(int bank, int index, int px, int py) {
    int idx = bank * 64 + index;
    vec2 sp = vec2(float(idx % int(sheet_tiles_w)) * 8.0 + float(px),
                   float(idx / int(sheet_tiles_w)) * 8.0 + float(py));
    return int(texelFetch(sheet, ivec2(sp), 0).r * 255.0 / 85.0 + 0.5);
}

void fragment() {
    // Outside the level's window is the status bar's business.
    bool outside = FRAGCOORD.y < view_top || FRAGCOORD.y >= view_bottom;
    vec2 world = floor(scroll + FRAGCOORD.xy);
    vec2 cell = floor(world / 8.0);
    int bg_c = 0;
    if (outside) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else if (cell.x < 0.0 || cell.y < 0.0 || cell.x >= map_size.x || cell.y >= map_size.y) {
        COLOR = texelFetch(palette, ivec2(0, 0), 0);   // outside the level: backdrop
    } else {
        vec4 m = texelFetch(map, ivec2(cell), 0);
        int tile = int(m.r * 255.0 + 0.5);
        int pal = int(m.g * 255.0 + 0.5);
        ivec2 inner = ivec2(mod(world, 8.0));
        bg_c = tile_colour(banks[tile / 64], tile % 64, inner.x, inner.y);
        // Colour zero of every palette is the same backdrop colour, exactly as
        // the console wires it.
        int slot = bg_c == 0 ? 0 : pal * 4 + bg_c;
        COLOR = texelFetch(palette, ivec2(slot, 0), 0);
    }
    int here_x = int(FRAGCOORD.x);
    int here_y = int(FRAGCOORD.y);
    int on_line = 0;
    for (int i = 0; sprites_on && !outside && i < 64; i++) {
        vec4 o = texelFetch(oam, ivec2(i, 0), 0);
        // The console puts a sprite one line below the number in the table.
        int line = here_y - (int(o.r * 255.0 + 0.5) + 1);
        if (line < 0 || line >= 16) {
            continue;
        }
        on_line++;
        if (on_line > 8) {
            break;                       // eight to a line and no more
        }
        int col = here_x - int(o.a * 255.0 + 0.5);
        if (col < 0 || col >= 8) {
            continue;
        }
        int attr = int(o.b * 255.0 + 0.5);
        int tile = int(o.g * 255.0 + 0.5);
        int fine = (attr & 0x80) != 0 ? 15 - line : line;
        int index = (tile & 0xFE) + (fine >= 8 ? 1 : 0);
        int bank = banks[((tile & 1) != 0 ? 4 : 0) + index / 64];
        int c = tile_colour(bank, index % 64,
                (attr & 0x40) != 0 ? 7 - col : col, fine & 7);
        if (c == 0) {
            continue;                    // see-through, and the one behind shows
        }
        // The one in front is the one that stands earlier in the table, so the
        // first opaque pixel found is the answer and the rest are not looked at.
        if ((attr & 0x20) == 0 || bg_c == 0) {
            COLOR = texelFetch(palette, ivec2(16 + (attr & 3) * 4 + c, 0), 0);
        }
        break;
    }
}
