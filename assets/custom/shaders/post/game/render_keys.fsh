#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>

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

struct Key {
    vec2 relativePosition;
    float distance;
    vec4 color;
    bool defined;
};

void main(){
    float playerRot = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_DIRECTION_INDEX));
    vec2 playerPos = vec2(
        decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_X_INDEX)), 
        decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_Y_INDEX))
    );
    
    // Load keys (since the last pixel in the key row determines when key initialization is finished, there can only be page size-1 keys)
    Key keys[MEMORY_PAGE_SIZE-1];
    for(int i=0; i<(MEMORY_PAGE_SIZE-1);i++) {
        vec4 keyCoordData = getData(DataSampler, KEY_ROW, i);

        // only the first key could have coords 0, 0. others must be empty.
        if(i>0 && keyCoordData==vec4(0.0)) {
            break;
        }

        ivec2 mapCoord = decodeMapCoord(keyCoordData);
        vec2 coords = vec2(mapCoord.x + 0.5, mapCoord.y + 0.5) - playerPos;
        
        vec4 color = getData(DataSampler, KEY_ROW+1, i);

        keys[i] = Key(coords, length(coords), color, true);
    }



    int rayIndex = int(texCoord.x * SCREEN_WIDTH);
    int row = (rayIndex / MEMORY_PAGE_SIZE) + RAYCAST_ROW;
    int index = rayIndex % MEMORY_PAGE_SIZE;
    vec2 rayPos = vec2(decodeFloat(getData(DataSampler, row+4, index)), decodeFloat(getData(DataSampler, row+8, index)));
    float dist = distance(rayPos, playerPos);
    float offsetFromMid = texCoord.x - 0.5;
    float rotOffset = -(offsetFromMid * radians(FOV));
    float fixedDist = dist * cos(rotOffset);

    float rayRot = playerRot + rotOffset;

    // for(int i=0; i<MEMORY_PAGE_SIZE+1; i++) {
    //     Key key = keys[i];

    //     if(key.defined == false) {
    //         break;
    //     }

    //     if(key.distance > MAX_SIGHT) {
    //         continue;
    //     }

    //     if(key.distance > fixedDist) {
    //         continue;
    //     }

    //     float keyAngle = atan(key.relativePosition.y, key.relativePosition.x);
    //     float angleDist = min(abs(keyAngle-rayRot), abs(rayRot-keyAngle));
    //     angleDist /= radians(FOV/2);

    //     float keySize = (1.0/(key.distance));
    //     if(angleDist < keySize) {
    //         fragColor = vec4(1.0, 0.0, 0.0, 1.0);
    //         return;
    //     }

    // }

    fragColor = texture(MinecraftSampler, texCoord);
}
