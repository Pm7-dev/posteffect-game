#version 330

#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>
#moj_import <custom:render_globals.glsl>

uniform sampler2D DataSampler;
uniform sampler2D WallSampler;

in vec2 texCoord;

out vec4 fragColor;

vec2 getTextureOffset(vec4 mapColor) {
    ivec4 icolor = getIntegerColor(mapColor);
    if(icolor == WALL_BRICK) {
        return vec2(0.0, 0.0);
    } else if(icolor == WALL_WOOD) {
        return vec2(0.25, 0.0);
    } else if(icolor == WALL_STONE) {
        return vec2(0.5, 0.0);
    } else if(icolor == WALL_DIRT) {
        return vec2(0.75, 0.0);
    }
    else if(icolor == WALL_WIN) {
        return vec2(0.5, 0.75);
    }
    return vec2(0.75, 0.75);
}

// gleefully stolen from someone smarter than me
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

void main(){
    int rayIndex = int(texCoord.x * SCREEN_WIDTH);
    int row = (rayIndex / MEMORY_PAGE_SIZE) + RAYCAST_ROW;
    int index = rayIndex % MEMORY_PAGE_SIZE;

    vec4 mapColor = getData(DataSampler, row, index);
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
    if(textureOffset == vec2(0.75, 0.75)) {
        color.rgb = rgb2hsv(color.rgb);
        mapColor.rgb = rgb2hsv(mapColor.rgb);
        color.r = mapColor.r;
        color.rgb = hsv2rgb(color.rgb);
    }

    if(abs(texCoord.y-0.5)*2.0 > wallHeight) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }


    color = fog(color, dist);

    fragColor = color;

}
