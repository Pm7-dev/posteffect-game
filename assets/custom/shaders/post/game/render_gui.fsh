#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>

uniform sampler2D MinecraftSampler;
uniform sampler2D DataSampler;
uniform sampler2D OverlaySampler;
uniform sampler2D WinScreenSampler;
uniform sampler2D LoseScreenSampler;
uniform sampler2D SecretScreenSampler;
uniform vec2 MinecraftSize;

in vec2 texCoord;

out vec4 fragColor;

float sdfCircle(float x, float y, vec2 uv) {
    return distance(uv, vec2(x, y));
}

void main(){
    int endScreen = int(round(decodeFloat(getData(DataSampler, GAME_META_ROW, END_SCREEN_INDEX))));
    if(endScreen == 1) {
        fragColor = texture(WinScreenSampler, vec2(texCoord.x, 1-texCoord.y));
        return;
    } else if(endScreen == 2) {
        fragColor = texture(LoseScreenSampler, vec2(texCoord.x, 1-texCoord.y));
        return;
    } else if(endScreen == 3) {
        fragColor = texture(SecretScreenSampler, vec2(texCoord.x, 1-texCoord.y));
        return;
    }

    vec2 uv = gl_FragCoord.xy / ScreenSize.y;


    if(texCoord.x < 0.5) {
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
    } else {
        float paddingY = 0.05;
        float paddingX = paddingY * (ScreenSize.y/ScreenSize.x);
        if(texCoord.x > 0.7 - paddingX && texCoord.x < 1.0- paddingX) {
            if(texCoord.y > 0.98 - paddingY && texCoord.y < 1.0- paddingY) {
                float pos = texCoord.x - (0.7 - paddingX);
                pos /= 0.3;
                pos *= 100;
                float health = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_HEALTH_INDEX));
                if(health >= pos) {
                    fragColor = vec4(1.0);
                } else {
                    fragColor = vec4(0.2);
                }
                return;
            }

        }
    }

    vec4 overlayColor = texture(OverlaySampler, texCoord);
    fragColor = mix(texture(MinecraftSampler, texCoord), overlayColor, overlayColor.a);
    // fragColor = vec4(uv.x, uv.y, 0.0, 1.0);
}
