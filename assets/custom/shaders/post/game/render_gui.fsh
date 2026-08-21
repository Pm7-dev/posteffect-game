#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>

uniform sampler2D DataSampler;
uniform sampler2D MinecraftSampler;
uniform sampler2D KeySampler;

in vec2 texCoord;

out vec4 fragColor;

void main(){

    // // test
    // if(texCoord.y > 0.5) {
    //     int index = int(floor(texCoord.x*INVENTORY_SPACE));
    //     fragColor = mix(getData(DataSampler, PLAYER_DATA_ROW, INVENTORY_INDEX+index), texture(MinecraftSampler, texCoord), 0.5);
    //     return;
    // } else {
    //     int index = int(floor(texCoord.x*INVENTORY_SPACE));
    //     ivec2 pointer = decodePointer(getData(DataSampler, PLAYER_DATA_ROW, INVENTORY_POINTER_INDEX+index));
    //     //TODO: I think these are all pointing to index 0 or 1 or smth???? try outputting raw color when past y 0.9 or smth
    //     if(texCoord.y < 0.2) {
    //         fragColor = texture(DataSampler, texCoord / 3);
    //         return;
    //     }
    //     if(pointer == ivec2(-1, -1)) {
    //         fragColor = mix(vec4(0.0), texture(MinecraftSampler, texCoord), 0.5);
    //     }
    //     fragColor = mix(getData(DataSampler, pointer.y, pointer.x), texture(MinecraftSampler, texCoord), 0.5);
    //     return;
    // }
    

    int index = int(floor(texCoord.y * 20));
    if(texCoord.x < 0.15) {
        ivec2 pointer = decodePointer(getData(DataSampler, PLAYER_DATA_ROW, INVENTORY_POINTER_INDEX + index));
        if(pointer == ivec2(-1, -1)) {
            fragColor = texture(MinecraftSampler, texCoord);
            return;
        }
        fragColor = getData(DataSampler, pointer.y, pointer.x);
        return;
    }

    fragColor = texture(MinecraftSampler, texCoord);
}
