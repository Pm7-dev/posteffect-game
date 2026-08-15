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

    // Exit if past map section
    if(dataCoord.y >= MAP_DATA_ROW + 128) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }

    int initialized = int(decodeFloat(getData(DataSampler, GAME_META_ROW, GAME_INITIALIZED_INDEX)));

    if(dataCoord.y == PLAYER_DATA_ROW) {
        // TODO: also check for door & key here so you can remove the key from the player inventory.
        // otherwise you might be able to avoid blitting after this pass so you can do it in the update player pass.
    }

    // Exit if before map section
    if(dataCoord.y < MAP_DATA_ROW) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }

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
            // Remove the block from the map
            fragColor = vec4(0.0, 0.0, 0.0, 0.0);
        } else {
            fragColor = texture(DataSampler, texCoord);
        }

        return;
    } 
}
