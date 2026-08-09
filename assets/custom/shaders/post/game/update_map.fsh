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
        fragColor = texture(DataSampler, texCoord);

        ivec2 playerFacing = decodeMapCoordinate(getData(DataSampler, PLAYER_DATA_ROW, COORDS_FACING_INDEX));
        ivec2 translated = translateMapCoordToDataCoord(playerFacing);
        vec4 color = getData(DataSampler, translated.y, translated.x);

        //TODO: if color is door, if action is pressed, if inventory has key, set sampler to zero

        return;
    } 
}
