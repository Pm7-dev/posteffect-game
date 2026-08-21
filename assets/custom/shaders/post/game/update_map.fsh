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


    if(dataCoord.y == PLAYER_DATA_ROW) {

        if(dataCoord.x >= INVENTORY_INDEX && dataCoord.x < INVENTORY_INDEX + INVENTORY_SPACE) {
            int initialized = int(decodeFloat(getData(DataSampler, GAME_META_ROW, GAME_INITIALIZED_INDEX)));
            if(initialized == 0) {
                fragColor = texture(DataSampler, texCoord);
                return;
            }

            float actionInput = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, ACTION_INDEX));
            if(actionInput > 0.5) {

                ivec2 playerFacing = decodeMapCoord(getData(DataSampler, PLAYER_DATA_ROW, COORDS_FACING_INDEX));
                ivec2 translated = translateMapCoordToDataCoord(playerFacing);
                vec4 color = getData(DataSampler, translated.y, translated.x);
                ivec4 icolor = getIntegerColor(color);
                if(isDoor(icolor)) {
                    vec4 currentInventoryColor = texture(DataSampler, texCoord);

                    // make sure no other color before this should be used up this frame
                    for(int i=INVENTORY_INDEX; i< dataCoord.x; i++) {
                        vec4 prevColor = getData(DataSampler, PLAYER_DATA_ROW, i);
                        if(prevColor.rgb == currentInventoryColor.rgb) {
                            fragColor = texture(DataSampler, texCoord);
                            return;
                        }
                    }

                    ivec4 icurrentInventoryColor = getIntegerColor(currentInventoryColor);
                    if(icolor.rgb == icurrentInventoryColor.rgb) {
                        fragColor = vec4(0.0);
                        return;
                    }
                }
            }
            
        }

        
    }

    // Exit if before map section
    if(dataCoord.y < MAP_DATA_ROW) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }

    int initialized = int(decodeFloat(getData(DataSampler, GAME_META_ROW, GAME_INITIALIZED_INDEX)));
    int index = getIndex(texCoord) - MAP_DATA_ROW * MEMORY_PAGE_SIZE;
    if(initialized == 1.0) {

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

                // make sure player has a key for this door.
                for(int i=INVENTORY_INDEX; i<INVENTORY_INDEX+INVENTORY_SPACE; i++) {
                    vec4 invColor = getData(DataSampler, PLAYER_DATA_ROW, i);
                    if(invColor.rgb == color.rgb) {
                        fragColor = vec4(0.0, 0.0, 0.0, 0.0);
                        return;
                    }
                }
            }
        }

        
        fragColor = texture(DataSampler, texCoord);
        return;
    } 

    fragColor = texture(DataSampler, texCoord);
}
