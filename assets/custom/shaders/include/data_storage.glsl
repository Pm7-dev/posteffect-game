#version 330

#moj_import <custom:game_globals.glsl>
#moj_import <minecraft:globals.glsl>

// Data Storage Layout for rows and idexes.
#define GAME_META_ROW 0 // One row for game metadata 
#define GAME_INITIALIZED_INDEX 0
#define LAST_GAME_TIME_INDEX 1
#define END_SCREEN_INDEX 2 // 0 for none, 1 for win, 2 for loss.

#define PLAYER_DATA_ROW 1 // One row for player data (inputs, position, and inventory)
#define MOVEMENT_INDEX 0
#define ROTATION_INDEX 1
#define ACTION_INDEX 2 // jump?
#define PLAYER_X_INDEX 3
#define PLAYER_Y_INDEX 4
#define PLAYER_DIRECTION_INDEX 5
#define COORDS_FACING_INDEX 6 // use the map coordinate thing
#define LOOKING_AT_WALL_INDEX 7 // either 1.0 or 0.0
#define PLAYER_HEALTH_INDEX 8 // plr health from 0-100
#define DAMAGE_DEBOUNCE_INDEX 9
#define INVENTORY_INDEX 10 // inv
#define INVENTORY_POINTER_INDEX (INVENTORY_INDEX + INVENTORY_SPACE) // An ordered list that points to the inventory indices
#define INVENTORY_REMOVE_FLAG_INDEX (INVENTORY_POINTER_INDEX + INVENTORY_SPACE) // 1.0 if the inventory has been updated and a key needs to be removed from the map, 0.0 if not

#define MAP_DATA_ROW 2 // 128 rows for storing the map data

#define KEY_ROW 130 // 4 rows for storing item pickup information (mapCoord [ivec2], color [vec4], relativeRot [float], and relativeDist [float])
#define KEYS_LOADED_INDEX MEMORY_PAGE_SIZE-1 // 1.0 if keys have been loaded from the map image, 0.0 if not

#define RAYCAST_ROW 134 // 12 rows for storing raycast hit locations (x [float], y [float], and color [vec4])

#define ENEMY_ROW 146 // 5 rows for storing enemy information (originalLoc [ivec2], x [float], y [float], rotation [float], and relativeDist [float])
#define ENEMIES_LOADED_INDEX MEMORY_PAGE_SIZE-1 // 1.0 if keys have been loaded from the map image, 0.0 if not



// Specific colors for interpretation by map storage. 
#define PLAYER_SPAWN ivec4(0, 0, 0, 200)
#define WALL_BRICK ivec4(127, 42, 33, 255)
#define WALL_WOOD ivec4(85, 35, 17, 255)
#define WALL_STONE ivec4(134, 136, 136, 255)
#define WALL_DIRT ivec4(107, 76, 62, 255)
#define WALL_WIN ivec4(255, 255, 0, 255) // yellow win wall
#define WALL_WIN_ALT ivec4(250, 255, 0, 255) // secret ending
#define WALL_DOOR ivec4(0, 0, 0, 255) // Anything else with this opacity will be seen as a door.
// Anything with opacity 150 will be seen as a key.
#define ENEMY_COLOR ivec4(255, 0, 0, 100) // color on map pinge for enemies
ivec4 getIntegerColor(vec4 color) { // returns a color as an ivec4 with range 0-255
    return ivec4(int(round(color.r*255.0)), int(round(color.g*255.0)), int(round(color.b*255.0)), int(round(color.a*255.0)));
}
bool isDoor(ivec4 color) {
    if(abs(color.a-WALL_DOOR.a) <= 1) {
        if(color == WALL_BRICK || color == WALL_WOOD || color == WALL_STONE || color == WALL_DIRT) {
            return false;
        }
        return true;
    }
    return false;
}
bool closeEnoughRGBA(ivec4 c1, ivec4 c2) {
    return abs(c1.r-c2.r) <= 1 &&
    abs(c1.g-c2.g) <= 1 &&
    abs(c1.b-c2.b) <= 1 &&
    abs(c1.a-c2.a) <= 1;
}
bool closeEnoughRGB(ivec4 c1, ivec4 c2) {
    return abs(c1.r-c2.r) <= 1 &&
    abs(c1.g-c2.g) <= 1 &&
    abs(c1.b-c2.b) <= 1;
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

// Encodes an ivec2 into four float rgba values.
// A fully zero pixel is reserved as the invalid sentinel and decodes to (-1, -1).
vec4 encodeMapCoord(ivec2 coord) {
    if (coord == ivec2(-1, -1)) {
        return vec4(0.0);
    }

    // Reserve 0 as invalid, so offset valid coords by +1.
    int x = coord.x + 1;
    int y = coord.y + 1;

    // Pack into 16 bits each, leaving 0x00000000 reserved as the sentinel.
    int bits = ((x & 0xFFFF) << 16) | (y & 0xFFFF);
    return splitToRGBA(bits);
}

// Decodes an ivec2 from four float rgba values.
ivec2 decodeMapCoord(vec4 rgba) {
    if (rgba == vec4(0.0)) {
        return ivec2(-1, -1);
    }

    int bits = combineToBits(rgba);
    int x = (bits >> 16) & 0xFFFF;
    int y = bits & 0xFFFF;

    return ivec2(x - 1, y - 1);
}

// alternate names
vec4 encodePointer(ivec2 address) {
    return encodeMapCoord(address);
}
ivec2 decodePointer(vec4 rgba) {
    return decodeMapCoord(rgba);
}
 



vec4 getData(sampler2D page, int row, int column) {
    return texelFetch(page, ivec2(column, row), 0);
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
    if(mapCoord.y%2==1) {
        mapCoord.x+=MAP_SIZE; 
    }
    mapCoord.y = mapCoord.y/2 + MAP_DATA_ROW;
    return mapCoord;
}
ivec2 translateDataCoordToMapCoord(ivec2 dataCoord) {
    dataCoord.y = (dataCoord.y - MAP_DATA_ROW) * 2;
    if(dataCoord.x >= MAP_SIZE) {
        dataCoord.x -= MAP_SIZE;
        dataCoord.y += 1;
    }
    return dataCoord;
}


vec4 getMapData(sampler2D MapSampler, int row, int column) {
    return texelFetch(MapSampler, ivec2(column, row), 0);
}
vec4 getMapData(sampler2D MapSampler, int index) {
    int row = index/MAP_SIZE;
    int column = index%MAP_SIZE;
    return getMapData(MapSampler, row, column);
}







float getDeltaTime(sampler2D DataSampler) {
    float lastGameTime = decodeFloat(getData(DataSampler, GAME_META_ROW, LAST_GAME_TIME_INDEX));
    float delta = GameTime - lastGameTime; // Change in GameTime since the last frame update
    while(delta < 0) delta += 1.0; // if GameTime loops back to 0, prevent the animation from going back.
    float deltaTime = delta * 1200.0; // 1 GameTime is 20 minutes, which is 1200 seconds
    if(deltaTime > 0.15) deltaTime = 0.15; // Cap deltaTime to prevent large jumps in time
    return deltaTime;
}