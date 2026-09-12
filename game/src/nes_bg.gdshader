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

// A screen outside a level -- the title, GAME OVER, the picking of a stage --
// is drawn out of more than one set of tiles: the cartridge counts the lines
// as the beam goes down and swaps the background's four banks part way, which
// is how the title has its own letters under the mark.  `band_at` is the first
// line of each band, in order, and `band_bank` its four banks; a band whose
// first line is past the screen is not there.  With `bands_on` off nothing of
// this is looked at and `banks` is the whole answer, which is what a level
// wants.
uniform bool bands_on = false;
uniform int band_at[4];
uniform int band_bank[16];
uniform float view_top = 0.0;      // the lines the level owns
uniform float view_bottom = 240.0;
uniform bool sprites_on = false;

// The picture unit is told where the picture stands once a frame, and a game
// may tell it again half way down: the screen a stage is picked on scrolls its
// sky and leaves its road standing.  Above `split_at` the picture stands where
// `scroll` says and below it where `scroll2` does; a level never asks, so the
// line is put out of reach.
uniform float split_at = 1000.0;
uniform vec2 scroll2 = vec2(0.0);

// Outside a stage the picture rides over the console's own two kilobytes of
// name map put up four times, and it comes back round at the far edge: the
// city the change is watched on slides a whole screen and a half sideways.  A
// level does not wrap and leaves this at nought.
uniform vec2 wrap = vec2(0.0);

// $2001 bits one and two -- the console can be told to leave the leftmost
// eight points of the screen alone, and then what shows there is the backdrop.
// The screen a stage is picked on is drawn that way.
uniform float clip_left = 0.0;

// Below the level is the status bar, which the console shows by handing the
// picture unit a different address in the middle of the frame.  It is its own
// little map -- thirty-two by eight -- drawn out of its own four banks.
uniform sampler2D bar : filter_nearest;        // R = tile, G = palette
uniform bool bar_on = false;
uniform int bar_banks[4];

// Which of the background's four banks stands on this line.
int bg_bank(int which, int line) {
    if (!bands_on) {
        return banks[which];
    }
    int pick = 0;
    for (int i = 1; i < 4; i++) {
        if (band_at[i] <= line && band_at[i] > band_at[pick]) {
            pick = i;
        }
    }
    return band_bank[pick * 4 + which];
}

int tile_colour(int bank, int index, int px, int py) {
    int idx = bank * 64 + index;
    vec2 sp = vec2(float(idx % int(sheet_tiles_w)) * 8.0 + float(px),
                   float(idx / int(sheet_tiles_w)) * 8.0 + float(py));
    return int(texelFetch(sheet, ivec2(sp), 0).r * 255.0 / 85.0 + 0.5);
}

void fragment() {
    // Outside the level's window is the status bar's business.
    bool outside = FRAGCOORD.y < view_top || FRAGCOORD.y >= view_bottom;
    vec2 world = floor((FRAGCOORD.y < split_at ? scroll : scroll2)
                       + FRAGCOORD.xy);
    if (wrap.x > 0.0) {
        world = mod(mod(world, wrap) + wrap, wrap);
    }
    vec2 cell = floor(world / 8.0);
    int bg_c = 0;
    if (outside) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
        if (bar_on && FRAGCOORD.y >= view_bottom) {
            ivec2 c = ivec2(int(FRAGCOORD.x) / 8,
                            (int(FRAGCOORD.y) - int(view_bottom)) / 8);
            if (c.y < 8) {
                vec4 m = texelFetch(bar, c, 0);
                int tile = int(m.r * 255.0 + 0.5);
                int pal = int(m.g * 255.0 + 0.5);
                int cc = tile_colour(bar_banks[tile / 64], tile % 64,
                        int(FRAGCOORD.x) % 8, (int(FRAGCOORD.y)) % 8);
                COLOR = texelFetch(palette, ivec2(cc == 0 ? 0 : pal * 4 + cc, 0), 0);
            }
        }
    } else if (cell.x < 0.0 || cell.y < 0.0 || cell.x >= map_size.x || cell.y >= map_size.y) {
        COLOR = texelFetch(palette, ivec2(0, 0), 0);   // outside the level: backdrop
    } else {
        vec4 m = texelFetch(map, ivec2(cell), 0);
        int tile = int(m.r * 255.0 + 0.5);
        int pal = int(m.g * 255.0 + 0.5);
        ivec2 inner = ivec2(mod(world, 8.0));
        bg_c = tile_colour(bg_bank(tile / 64, int(FRAGCOORD.y)), tile % 64,
                inner.x, inner.y);
        // Colour zero of every palette is the same backdrop colour, exactly as
        // the console wires it.
        int slot = bg_c == 0 ? 0 : pal * 4 + bg_c;
        COLOR = texelFetch(palette, ivec2(slot, 0), 0);
    }
    int here_x = int(FRAGCOORD.x);
    int here_y = int(FRAGCOORD.y);
    int on_line = 0;
    // The console draws its sprites over the whole of the picture and not
    // only over the level's window: while he arrives the four pieces come in
    // across the bottom sixteen lines, which are the strip's.
    for (int i = 0; sprites_on && i < 64; i++) {
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
    if (FRAGCOORD.x < clip_left) {
        COLOR = texelFetch(palette, ivec2(0, 0), 0);
    }
}
