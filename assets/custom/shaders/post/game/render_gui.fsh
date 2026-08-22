#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>

uniform sampler2D MinecraftSampler;
uniform sampler2D DataSampler;
uniform sampler2D OverlaySampler;
uniform vec2 MinecraftSize;

in vec2 texCoord;

out vec4 fragColor;

float sdfCircle(float x, float y, vec2 uv) {
    return distance(uv, vec2(x, y));
}

void main(){
    vec2 uv = gl_FragCoord.xy / ScreenSize.y;

    float slotSize = (1.0/INVENTORY_SPACE);
    float radius = (1.0/INVENTORY_SPACE) * 0.4;
    int index = int(texCoord.y * INVENTORY_SPACE);
    float dist = sdfCircle(0.01+radius, (slotSize/2.)+(slotSize * index), uv);
    if(dist < radius) {
        ivec2 pointer = decodePointer(getData(DataSampler, PLAYER_DATA_ROW, INVENTORY_POINTER_INDEX + index));
        if(pointer != ivec2(-1, -1)) {
            fragColor = getData(DataSampler, pointer.y, pointer.x);
            return;
            
        } else {
            if(dist > radius-.005) {
                fragColor = vec4(1.);
                return;
            }
        }
        
    }

    vec4 overlayColor = texture(OverlaySampler, texCoord);
    fragColor = mix(texture(MinecraftSampler, texCoord), overlayColor, overlayColor.a);
    // fragColor = vec4(uv.x, uv.y, 0.0, 1.0);
}
