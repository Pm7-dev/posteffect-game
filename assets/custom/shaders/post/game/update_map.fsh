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

    // Load key locations and colors from map image
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

    if(dataCoord.y == KEY_ROW + 1) {

        // exit early if keys are already loaded
        int loaded = int(decodeFloat(getData(DataSampler, KEY_ROW, KEYS_LOADED_INDEX)));
        if(loaded == 1) {
            fragColor = texture(DataSampler, texCoord);
            return;
        }
        vec4 loadedKeyColor = getData(DataSampler, KEY_ROW, dataCoord.x);
        ivec2 loadedKeyCoordinates = decodeMapCoord(loadedKeyColor);
        fragColor = getMapData(MapSampler, loadedKeyCoordinates.y, loadedKeyCoordinates.x);
        return;
    }

    // Exit if past map section
    if(dataCoord.y >= MAP_DATA_ROW + 128) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }


    if(dataCoord.y == PLAYER_DATA_ROW) {
        // TODO: also check for door & key here so you can remove the key from the player inventory.
        // otherwise you might be able to avoid blitting after this pass so you can do it in the update player pass.
    }

    // Exit if before map section
    if(dataCoord.y < MAP_DATA_ROW) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }

    int initialized = int(decodeFloat(getData(DataSampler, GAME_META_ROW, GAME_INITIALIZED_INDEX)));
    int index = getIndex(texCoord) - MAP_DATA_ROW * MEMORY_PAGE_SIZE;
    if(initialized == 1.0) {

        int keysLoaded = int(decodeFloat(getData(DataSampler, KEY_ROW, KEYS_LOADED_INDEX)));
        if(keysLoaded > 0.5) {
            vec4 color = texture(DataSampler, texCoord);
            ivec4 icolor = getIntegerColor(color);
            if(icolor.a == 150) {
                fragColor = vec4(0.0, 0.0, 0.0, 0.0);
                return;
            }
        }

        // Return if no block targeted
        if(decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, LOOKING_AT_WALL_INDEX)) < 0.5) {
            fragColor = texture(DataSampler, texCoord);
            return;
        }

        // Make sure this index is the faced block
        ivec2 playerFacing = decodeMapCoord(getData(DataSampler, PLAYER_DATA_ROW, COORDS_FACING_INDEX));
        ivec2 translated = translateMapCoordToDataCoord(playerFacing);
        if(getDataCoords(texCoord) != translated) {
            fragColor = texture(DataSampler, texCoord);
            return;
        }

        float actionInput = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, ACTION_INDEX));
        if(actionInput > 0.5) {
            vec4 color = texture(DataSampler, texCoord);
            ivec4 icolor = getIntegerColor(color);
            if(isDoor(icolor)) {
                fragColor = vec4(0.0, 0.0, 0.0, 0.0);
                return;
            }
        }

        
        fragColor = texture(DataSampler, texCoord);
        return;
    } 

    fragColor = texture(DataSampler, texCoord);
}
