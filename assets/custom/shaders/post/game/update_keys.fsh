#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>

uniform sampler2D DataSampler;
uniform sampler2D MapSampler;

in vec2 texCoord;

out vec4 fragColor;

void main(){
    ivec2 dataCoord = getDataCoords(texCoord);

    // I have no clue why this has to be here. If you in the future are reading this and can figure out how the heck the key update pass is affecting the enemy data, I applaud you.
    if(dataCoord.y >= ENEMY_ROW && dataCoord.y < ENEMY_ROW+5) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }

    // reset the inventory remove flag to 0
    if(dataCoord.y == PLAYER_DATA_ROW && dataCoord.x == INVENTORY_REMOVE_FLAG_INDEX) {
        fragColor = encodeFloat(0.0);
        return;
    }

    // Load key locations from map image
    if(dataCoord.y == KEY_ROW) { // KEY_ROW stores location, while KEY_ROW+1 stores color

        // exit early if keys are already loaded
        int loaded = int(decodeFloat(getData(DataSampler, KEY_ROW, KEYS_LOADED_INDEX)));
        if(loaded == 1) {
            fragColor = texture(DataSampler, texCoord);
            return;
        }

        bool found = false;
        int foundX = -1;
        int foundY = -1;
        for(int row = 0; row < MAP_SIZE; row++) {
            for(int col = 0; col < MAP_SIZE; col++) {
                vec4 color = getMapData(MapSampler, row, col);
                ivec4 icolor = getIntegerColor(color);
                if(icolor.a == 150) { // alpha 150 is the key color
                    found = true;
                    ivec2 coords = ivec2(col, row);
                    int index=0;
                    while(index<dataCoord.x) {
                        vec4 loadedKeyColor = getData(DataSampler, KEY_ROW, index);
                        ivec2 loadedKeyCoordinates = decodeMapCoord(loadedKeyColor);
                        if(loadedKeyCoordinates == coords) {
                            found = false;
                            break;
                        }
                        index++;
                    }
                    if(found) {
                        foundX = col;
                        foundY = row;
                        break;
                    }
                }
                if(found) {
                    break;
                }
            }
        }
        if(dataCoord.x == KEYS_LOADED_INDEX) {
            if(found) {
                fragColor = encodeFloat(0.0);
            } else {
                fragColor = encodeFloat(1.0);
            }
        } else {
            if(found) {
                fragColor = encodeMapCoord(ivec2(foundX, foundY));
            } else {
                fragColor = vec4(0.0, 0.0, 0.0, 0.0);
            }
        }
        return;
    }

    // Load key colors from map image
    if(dataCoord.y == KEY_ROW + 1) {

        // If keys are already loaded, check for item pickup.
        int loaded = int(decodeFloat(getData(DataSampler, KEY_ROW, KEYS_LOADED_INDEX)));
        if(loaded == 1) {

            float removeFlag = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, INVENTORY_REMOVE_FLAG_INDEX));
            if(removeFlag > 0.5) {
                float dist = decodeFloat(getData(DataSampler, KEY_ROW+3, dataCoord.x));
                if(dist < PICKUP_RADIUS) {
                    fragColor = vec4(0.0);
                    return;
                }
            }

            fragColor = texture(DataSampler, texCoord);
            return;
        }
        vec4 loadedKeyColor = getData(DataSampler, KEY_ROW, dataCoord.x);
        ivec2 loadedKeyCoordinates = decodeMapCoord(loadedKeyColor);
        if(loadedKeyCoordinates == ivec2(-1, -1)) {
            fragColor = texture(DataSampler, texCoord);
            return;
        }
        fragColor = getMapData(MapSampler, loadedKeyCoordinates.y, loadedKeyCoordinates.x);
        return;

        fragColor = encodeMapCoord(loadedKeyCoordinates);
        return;
    }

    // Load the relative rotations
    if(dataCoord.y == KEY_ROW + 2) {
        float playerRot = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_DIRECTION_INDEX));
        vec2 playerPos = vec2(
            decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_X_INDEX)), 
            decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_Y_INDEX))
        );
        ivec2 mapCoord = decodeMapCoord(getData(DataSampler, KEY_ROW, dataCoord.x));
        if(mapCoord == ivec2(-1, -1)) {
            fragColor = texture(DataSampler, texCoord);
            return;
        }
        vec2 coords = vec2(mapCoord.x + 0.5, mapCoord.y + 0.5) - playerPos;
        float angle = atan(coords.y, coords.x);
        float dist = mod(playerRot-angle+PI, 2*PI) - PI;
        fragColor = encodeFloat(dist);
        return;
    }

    // Load the relative distances
    if(dataCoord.y == KEY_ROW + 3) {
        vec2 playerPos = vec2(
            decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_X_INDEX)), 
            decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_Y_INDEX))
        );
        ivec2 mapCoord = decodeMapCoord(getData(DataSampler, KEY_ROW, dataCoord.x));
        if(mapCoord == ivec2(-1, -1)) {
            fragColor = texture(DataSampler, texCoord);
            return;
        }
        vec2 coords = vec2(mapCoord.x + 0.5, mapCoord.y + 0.5) - playerPos;
        fragColor = encodeFloat(length(coords));
        return;
    }

    if(dataCoord.y >= MAP_DATA_ROW && dataCoord.y <= MAP_DATA_ROW + MAP_SIZE) {
        int keysLoaded = int(decodeFloat(getData(DataSampler, KEY_ROW, KEYS_LOADED_INDEX)));
        if(keysLoaded == 1.0) {
            vec4 color = texture(DataSampler, texCoord);
            ivec4 icolor = getIntegerColor(color);
            if(icolor.a == 150) {
                fragColor = vec4(0.0, 0.0, 0.0, 0.0);
                return;
            }
        }
    }

    fragColor = texture(DataSampler, texCoord);
}
