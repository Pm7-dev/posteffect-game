#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>
#moj_import <custom:render_globals.glsl>

uniform sampler2D DataSampler;
uniform sampler2D MinecraftSampler;
uniform sampler2D KeySampler;

in vec2 texCoord;

out vec4 fragColor;

// for recoloring sprites
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 getAnimationOffset() {
    int frame = int(round(GameTime * 14000)) % 8;
    if(frame < 4) {
        return vec2(frame * 0.25, 0.0);
    } else {
        return vec2((frame - 4) * 0.25, 0.5);
    }
}

void main(){
    float playerRot = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_DIRECTION_INDEX));
    vec2 playerPos = vec2(
        decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_X_INDEX)), 
        decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_Y_INDEX))
    );
    int rayIndex = int(texCoord.x * SCREEN_WIDTH);
    int row = (rayIndex / MEMORY_PAGE_SIZE) + RAYCAST_ROW;
    int index = rayIndex % MEMORY_PAGE_SIZE;
    vec2 rayPos = vec2(decodeFloat(getData(DataSampler, row+4, index)), decodeFloat(getData(DataSampler, row+8, index)));
    float dist = distance(rayPos, playerPos);
    float offsetFromMid = texCoord.x - 0.5;
    float rotOffset = offsetFromMid * radians(FOV);
    float fixedDist = dist * cos(rotOffset);

    bool found = false;
    float closestDistance = 0.0;
    vec4 color = vec4(0.0);

    vec2 currentAnimationOffset = getAnimationOffset();

    for(int i=0; i<MEMORY_PAGE_SIZE-1; i++) {

        ivec2 mapCoord = decodeMapCoord(getData(DataSampler, KEY_ROW, i));
        if(mapCoord == ivec2(-1, -1)) {
            continue;
        }
        
        float dist = decodeFloat(getData(DataSampler, KEY_ROW+3, i));

        if(dist > MAX_SIGHT || dist > fixedDist || dist <= 0.1) {
            continue;
        }

        float rotDist = decodeFloat(getData(DataSampler, KEY_ROW+2, i)) + rotOffset;
        float keySize = (1.0/(dist));
        if(abs(rotDist) < keySize/2) {
            float texX = (rotDist + keySize/2) / keySize / 4.;
            float texY = (0.5*(((1.0-texCoord.y)-0.5)/keySize + 0.5));

            if(abs(texCoord.y-0.5)*2.0 > keySize) {
                continue;
            }

            if(found && dist > closestDistance) {
                continue;
            }

            vec4 keyColor = texture(KeySampler, vec2(texX, texY) + currentAnimationOffset);

            if(keyColor.a == 0.0) {
                continue;
            }

            vec4 dataColor = getData(DataSampler, KEY_ROW+1, i);
            keyColor.rgb = rgb2hsv(keyColor.rgb);
            keyColor.r = rgb2hsv(dataColor.rgb).r;
            keyColor.rgb = hsv2rgb(keyColor.rgb);
            
            found = true;
            closestDistance = dist;
            color = keyColor;
        }

    }

    if(found) {
        fragColor = mix(texture(MinecraftSampler, texCoord), fog(color, closestDistance), color.a);
        return;
    }

    fragColor = texture(MinecraftSampler, texCoord);
}
