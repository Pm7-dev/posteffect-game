#version 330

#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>

uniform sampler2D DataSampler;
uniform sampler2D WallSampler;

in vec2 texCoord;

out vec4 fragColor;

vec2 getTextureOffset(vec4 mapColor) {
    return vec2(0.0, 0.0); // TODO: change later
}

float getTextureX(vec4 color, float xPos, float yPos) {
    xPos = fract(xPos);
    yPos = fract(yPos);
    float progress = 0.0;
    if(xPos > yPos) {
        progress = xPos;
    } else {
        progress = yPos;
    }

    return progress * 0.25; // TODO: change later
}

void main(){
    int rayIndex = int(texCoord.x * SCREEN_WIDTH);
    int row = (rayIndex / MEMORY_PAGE_SIZE) + RAYCAST_ROW;
    int index = rayIndex % MEMORY_PAGE_SIZE;

    vec4 mapColor = getData(DataSampler, row, index);     // TODO: TEXTURE LATER!!
    float rayX = decodeFloat(getData(DataSampler, row+4, index));
    float rayY = decodeFloat(getData(DataSampler, row+8, index));

    float plrX = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_X_INDEX));
    float plrY = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_Y_INDEX));
    float dist = distance(vec2(rayX, rayY), vec2(plrX, plrY));
    float offsetFromMid = texCoord.x - 0.5;
    float rotOffset = -(offsetFromMid * radians(FOV));
    float fixedDist = dist * cos(rotOffset);

    vec2 textureOffset = getTextureOffset(mapColor);
    float textureX = textureOffset.x;
    if(fract(rayX) > fract(rayY)) {
        textureX += 0.25 * fract(rayX);
    } else {
        textureX += 0.25 * fract(rayY);
    }
    

    float wallHeight = (1.0/(fixedDist)) * 2.0;
    float textureY = (0.25*(((1.0-texCoord.y)-0.5)/wallHeight + 0.5)) + textureOffset.y;

    vec4 color = texture(WallSampler, vec2(textureX, textureY));

    // Cut off ends of walls
         // This fixes a fish-eye effect
    
    if(abs(texCoord.y-0.5)*2.0 > wallHeight) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }


    color = mix(color, vec4(0.0, 0.0, 0.0, 1.0), (dist-3)/5.);

    fragColor = color;

}
