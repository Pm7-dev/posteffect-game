#version 330

#moj_import <custom:game_globals.glsl>

// Data Storage Layout for rows and idexes.
#define GAME_META_ROW 0 // One row for game metadata 
#define GAME_INITIALIZED_INDEX 0
#define LAST_GAME_TIME_INDEX 1

#define PLAYER_DATA_ROW 1 // One row for player data (inputs, position, and inventory)
#define MOVEMENT_INDEX 0
#define ROTATION_INDEX 1
#define ACTION_INDEX 2 // jump?
#define PLAYER_X_INDEX 3
#define PLAYER_Y_INDEX 4
#define PLAYER_DIRECTION_INDEX 5
#define COORDS_FACING_INDEX 6 // use the map coordinate thing
#define PLAYER_HEALTH_INDEX 7 //may go unused
#define INVENTORY_INDEX 8 // and beyond

#define MAP_DATA_ROW 2 // 128 rows for storing the map data

#define KEY_ROW 130 // 2 rows for storing item pickup locations (color [vec4] and mapCoord [ivec2])

#define RAYCAST_ROW 132 // 12 rows for storing raycast hit locations (x [float], y [float], and color [vec4])

#define ENEMY_ROW 144 // 4 rows for storing enemy information (type [float], x [float], y [float], health [float], )



// Specific colors for interpretation by map storage. 
#define PLAYER_SPAWN ivec4(0, 0, 0, 200)
#define WALL_BRICK ivec4(127, 42, 33, 255)
#define WALL_WOOD ivec4(85, 35, 17, 255)
#define WALL_STONE ivec4(134, 136, 136, 255)
#define WALL_DIRT ivec4(107, 76, 62, 255)
#define WALL_DOOR ivec4(0, 0, 0, 255) // Anything else with this opacity will be seen as a door.
// Anything with opacity 150 will be seen as a key.
//TODO: enemy types
ivec4 getIntegerColor(vec4 color) { // returns a color as an ivec4 with range 0-255
    return ivec4(int(color.r*255.0), int(color.g*255.0), int(color.b*255.0), int(color.a*255.0));
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
    int y = bits & 0xFFFF;
    int x = (bits >> 16) & 0xFFFF;
    return ivec2(x, y);
}
 
vec4 getData(sampler2D page, int row, int column) {
    return texture(page, vec2(float(column)/MEMORY_PAGE_SIZE, float(row)/MEMORY_PAGE_SIZE));
}
vec4 getData(sampler2D page, int row, int column, int offset) {
    row += offset/MEMORY_PAGE_SIZE;
    column += offset%MEMORY_PAGE_SIZE;
    return getData(page, row, column);
}
vec4 getData(sampler2D page, int index) {
    int row = index/MEMORY_PAGE_SIZE;
    int column = index%MEMORY_PAGE_SIZE;
    return getData(page, row, column);
}
int getIndex(vec2 texCoord) {
    return int(floor((texCoord.x*MEMORY_PAGE_SIZE)) + int((MEMORY_PAGE_SIZE * floor(texCoord.y*MEMORY_PAGE_SIZE))));
}
ivec2 getDataCoords(vec2 texCoord) {
    int index = getIndex(texCoord);
    int row = index/MEMORY_PAGE_SIZE;
    int column = index%MEMORY_PAGE_SIZE;
    return ivec2(column, row);
}
ivec2 translateMapCoordToDataCoord(ivec2 mapCoord) {
    mapCoord.y += MAP_DATA_ROW;
    if(mapCoord.y%2==1) {
        mapCoord.x+=MAP_SIZE; 
    }
    mapCoord.y /= 2;
    return mapCoord;
}
ivec2 translateDataCoordToMapCoord(ivec2 dataCoord) {
    dataCoord.y *= 2;
    if(dataCoord.x >= MAP_SIZE) {
        dataCoord.x -= MAP_SIZE;
        dataCoord.y += 1;
    }
    return dataCoord;
}


vec4 getMapData(sampler2D MapSampler, int row, int column) {
    return texture(MapSampler, vec2(float(column)/MAP_SIZE, float(row)/MAP_SIZE));
}
vec4 getMapData(sampler2D MapSampler, int index) {
    int row = index/MAP_SIZE;
    int column = index%MAP_SIZE;
    return getMapData(MapSampler, row, column);
}
