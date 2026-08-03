#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>

uniform sampler2D DataSampler;

in vec2 texCoord;

out vec4 fragColor;

void main(){
    ivec2 dataCoord = getDataCoords(texCoord);
    if(dataCoord.y != GAME_META_ROW) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }

    if(dataCoord.x == GAME_INITIALIZED_INDEX) {
        fragColor = encodeFloat(1.0);
        return;
    }

     if(dataCoord.x == LAST_GAME_TIME_INDEX) {
        fragColor = encodeFloat(GameTime);
        return;
    }

    fragColor = texture(DataSampler, texCoord);
}
