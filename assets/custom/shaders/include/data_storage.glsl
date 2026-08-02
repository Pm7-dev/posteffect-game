#moj_import <custom:game_globals.glsl>

#version 330

// Encodes a float into four float rgba values
vec4 encodeFloat(float timestamp) {
    int bits = floatBitsToInt(timestamp);
    return splitToRGBA(bits);
}

// Decodes a float from four float rgba values.
float decodeFloat(vec4 rgba) {
    int bits = combineToBits(rgba);
    return intBitsToFloat(bits);
}

// Encodes an ivec2 into four float rgba values
vec4 encodeMapCoordinate(ivec2 coord) {
    int bits = coord.x & 0xFFFF;
    bits <<= 16;
    bits |= (coord.y & 0xFFFF);
    return splitToRGBA(bits);
}

// Decodes an ivec2 from four float rgba values.
ivec2 decodeMapCoordinate(vec4 rgba) {
    int bits = combineToBits(rgba);
    int y = rgba & 0xFFFF;
    int x = (rgba >> 16) & 0xFFFF;
    return ivec2(x, y);
}

// Splits a 32-bit integer into a vec4 of four floats.
vec4 splitToRGBA(int bits) {
    int r = (bits >> 24) & 0xFF;
    int g = (bits >> 16) & 0xFF;
    int b = (bits >> 8) & 0xFF;
    int a = bits & 0xFF;

    return vec4(r / 255.0, g / 255.0, b / 255.0, a / 255.0);
}

// Combines a vec4's channels into a 32-bit integer.
int combineToBits(vec4 rgba) {
    int r = int(round(rgba.r * 255.0));
    int g = int(round(rgba.g * 255.0));
    int b = int(round(rgba.b * 255.0));
    int a = int(round(rgba.a * 255.0));

    int bits = (r & 0xFF) << 24;
    bits |= (g & 0xFF) << 16;
    bits |= (b & 0xFF) << 8;
    bits |= (a & 0xFF);

    return bits;
}
 
vec4 getData(sampler2D page, int index) {
    int row = index/MEMORY_PAGE_SIZE;
    int column = index%MEMORY_PAGE_SIZE;
    return getData(page, row, column);
}

vec4 getData(sampler2D page, int row, int column, int offset) {
    row += index/MEMORY_PAGE_SIZE;
    column += index%MEMORY_PAGE_SIZE;
    return getData(page, row, column;)
}

vec4 getData(sampler2D page, int row, int column) {
    return texture(page, vec2(float(column)/MEMORY_PAGE_SIZE, float(row)/MEMORY_PAGE_SIZE));
}

// One row for game metadata 
#define GAME_META_ROW 0

// One row for player data (inputs, position, and inventory)
#define PLAYER_DATA_ROW 1

// 128 rows for storing the map data
#define MAP_DATA_ROW 2

// 2 rows for storing item pickup locations (color [vec4] and mapCoord [ivec2])
#define KEY_ROW 130

// 12 rows for storing raycast hit locations (x [float], y [float], and color [vec4])
#define RAYCAST_ROW 132

// 4 rows for storing enemy information (type [float], x [float], y [float], health [float], )
#define ENEMY_ROW 144







