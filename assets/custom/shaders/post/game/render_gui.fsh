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
    int index = int(floor(texCoord.y * INVENTORY_SPACE));
    if(texCoord.x < 0.1) {
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
