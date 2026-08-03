#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>

uniform sampler2D DataSampler;

in vec2 texCoord;

out vec4 fragColor;

void main(){
    ivec2 dataCoord = getDataCoords(texCoord);

    if(dataCoord.y < RAYCAST_ROW || dataCoord.y >= RAYCAST_ROW+12) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }

    int realRow = (dataCoord.y-RAYCAST_ROW) / 4;
    int realIndex = (((dataCoord.y-RAYCAST_ROW)%4)-1) * MEMORY_PAGE_SIZE + dataCoord.x;

    if(realRow < 0 || realRow > 2) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }

    //TODO: update player coords facing in this pass
    // If the pixel is in the second row, it is there to store a wall distance, so send a ray in the pixel's direction to get the distance to wall.
    float rotOffset = -((float(realIndex)/float(SCREEN_WIDTH) - 0.5) * radians(FOV));
    float rot = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_DIRECTION_INDEX)) + rotOffset;
    vec2 originalPos = vec2(
        decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_X_INDEX)), 
        decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_Y_INDEX))
    );
    vec2 pos = originalPos;
    ivec2 mapPos = ivec2(int(pos.x), int(pos.y));
    vec2 rotVec = vec2(cos(rot), sin(rot));
    ivec2 stepDir = ivec2(sign(rotVec.x), sign(rotVec.y));
    vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
    float eps = 1e-6;
    while (abs(pos.x-originalPos.x) < MAX_SIGHT && abs(pos.y-originalPos.y) < MAX_SIGHT) {
        vec2 distToNext = vec2(0.0, 0.0);
        float denomX = max(abs(rotVec.x), eps);
        float denomY = max(abs(rotVec.y), eps);

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

        if(distToNext.x / denomX < distToNext.y / denomY) {
            float t = distToNext.x / denomX;
            pos += rotVec * t;
            mapPos.x += stepDir.x;
        } else {
            float t = distToNext.y / denomY;
            pos += rotVec * t;
            mapPos.y += stepDir.y;
        }

        if(mapPos.x < 0 || mapPos.x >= MAP_SIZE || mapPos.y < 0 || mapPos.y >= MAP_SIZE) {
            color = vec4(1.0, 0.0, 0.0, 1.0); /// something is SOOOOOO borkey here.
            break;
        }

        ivec2 translated = translateMapCoordToDataCoord(mapPos);
        color = getData(DataSampler, translated.y, translated.x);
        if(color.a > 0.5) {
            break;
        }
    }

    
    if(realRow == 0) { // Store color of hit wall
        fragColor = color;
        //fragColor = vec4(1.0, 1.0, 1.0, 1.0);
    } else if(realRow == 1) { // Store x of hit wall
        fragColor = encodeFloat(pos.x);
    } else { // Store y of hit wall
        fragColor = encodeFloat(pos.y);
    }
}