#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <custom:data_storage.glsl>

uniform sampler2D DataSampler;

in vec2 texCoord;

out vec4 fragColor;

vec4 getMapData(vec2 pos) {

}

void main(){
    ivec2 dataCoord = getDataCoords(texCoord);

    if(dataCoord.y < RAYCAST_ROW || dataCoord.y >= RAYCAST_ROW+12) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }

    int realRow = (dataCoord.y-RAYCAST_ROW) / 4;
    int realIndex = ((dataCoord.y-RAYCAST_ROW)% 4) * MAP_SIZE + dataCoord.x;


//TODO: update player coords facing in this pass
    // If the pixel is in the second row, it is there to store a wall distance, so send a ray in the pixel's direction to get the distance to wall.
    float rotOffset = -(((realIndex/SCREEN_WIDTH) - 0.5) * radians(FOV));
    float rot = decodeFloat(getDataAtIndex(5)) + rotOffset;
    vec2 originalPos = vec2(decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_X_INDEX)), decodeFloat(DataSampler, PLAYER_DATA_ROW, PLAYER_Y_INDEX));
    vec2 pos = originalPos;
    ivec2 mapPos = vec2(int(pos.x), int(pos.y));
    vec2 rotVec = vec2(cos(rot), sin(rot));
    vec2 stepDir = sign(rotVec);
    float color;
    while (abs(pos.x-originalPos.x) < MAX_SIGHT && abs(pos.y-originalPos.y) < MAX_SIGHT) {
        vec2 distToNext = vec2(0.0, 0.0);
        if(stepDir.x > 0) {
            distToNext.x = mapPos.x + 1 - pos.x;
        } else {
            distToNext.x = pos.x - mapPos.x;
        }
        if(stepDir.y > 0) {
            distToNext.y = mapPos.y + 1 - pos.y;
        } else {
            distToNext.y = pos.y - mapPos.y;
        }

        if(distToNext.x / abs(rotVec.x) < distToNext.y / abs(rotVec.y)) {
            float t = distToNext.x / abs(rotVec.x);
            pos += rotVec * t;
            mapPos.x += stepDir.x;
        } else {
            float t = distToNext.y / abs(rotVec.y);
            pos += rotVec * t;
            mapPos.y += stepDir.y;
        }

        ivec2 translated = translateMapCoordToDataCoord(mapPos);
        color = getData(DataSampler, translated.y, translated.x);
        if(color.a > 0.1) {
            break;
        }
    }

    
    if(realRow == 0) { // Store color of hit wall
        fragColor = color;
    } else if(realRow == 1) { // Store x of hit wall
        fragColor = encodeFloat(pos.x)
    } else { // Store y of hit wall
        fragColor = encodeFloat(pos.y);
    }
}