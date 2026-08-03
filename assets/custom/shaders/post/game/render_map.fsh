#version 330

#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>

uniform sampler2D DataSampler;

in vec2 texCoord;

out vec4 fragColor;

void main(){
    int rayIndex = int(texCoord.x * SCREEN_WIDTH);
    int row = (rayIndex / MEMORY_PAGE_SIZE) + RAYCAST_ROW;
    int index = rayIndex % MEMORY_PAGE_SIZE;

    // if(row + 8 >= MEMORY_PAGE_SIZE) {
    //     fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    //     return;
    // }

    //vec4 color = getData(row, index);     // TODO: TEXTURE LATER!!
    float rayX = decodeFloat(getData(DataSampler, row+4, index));
    float rayY = decodeFloat(getData(DataSampler, row+8, index));

    float x = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_X_INDEX));
    float y = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_Y_INDEX));

    float dist = distance(vec2(rayX, rayY), vec2(x, y));

    vec4 color = vec4(0.0, 0.0, 1.0, 1.0); // Placeholder wall color

    // Cut off ends of walls
         // This fixes a fish-eye effect
    float offsetFromMid = texCoord.x - 0.5;
    float rotOffset = -(offsetFromMid * radians(FOV));
    float unfishedDist = dist * cos(rotOffset);
    if(abs(texCoord.y-0.5) > 1/unfishedDist) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }


    color = mix(color, vec4(0.0, 0.0, 0.0, 1.0), (dist-3)/5.);

    fragColor = color;

}
