#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>
#moj_import <custom:raycast.glsl>

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
    int realIndex = (((dataCoord.y-RAYCAST_ROW)%4)) * MEMORY_PAGE_SIZE + dataCoord.x;

    if(realRow < 0 || realRow > 2) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }

    // If the pixel is in the second row, it is there to store a wall distance, so send a ray in the pixel's direction to get the distance to wall.
    float rotOffset = -((float(realIndex)/float(SCREEN_WIDTH) - 0.5) * radians(FOV));
    float rot = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_DIRECTION_INDEX)) + rotOffset;
    vec2 originalPos = vec2(
        decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_X_INDEX)), 
        decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_Y_INDEX))
    );

    // Collect the raycast result for this pixel's direction.
    struct raycast ray = sendRay(originalPos, rot, DataSampler, MAX_SIGHT);
    
    if(realRow == 0) { // Store color of hit wall
        fragColor = ray.color;
    } else if(realRow == 1) { // Store x of hit wall
        fragColor = encodeFloat(ray.position.x);
    } else { // Store y of hit wall
        fragColor = encodeFloat(ray.position.y);
    }
}