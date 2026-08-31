#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>

uniform sampler2D DataSampler;

in vec2 texCoord;

out vec4 fragColor;

void main(){
    ivec2 dataCoord = getDataCoords(texCoord);
    if(dataCoord.y != GAME_META_ROW) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }

    if(dataCoord.x == GAME_INITIALIZED_INDEX) {
        fragColor = encodeFloat(1.0);
        return;
    }

    if(dataCoord.x == LAST_GAME_TIME_INDEX) {
        fragColor = encodeFloat(GameTime);
        return;
    }

    if(dataCoord.x == END_SCREEN_INDEX) {

        float health = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_HEALTH_INDEX));
        if(health <= 0.) {
            fragColor = encodeFloat(2.0);
            return;
        }

        float x = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_X_INDEX));
        float y = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_Y_INDEX));

        ivec2 hitCoord;
        float xDist = round(x) - x;
        if(abs(xDist) > HITBOX_RADIUS+0.05) {
            float yDist = round(y) - y;
            if(abs(yDist) < HITBOX_RADIUS+0.05) {
                fragColor = texture(DataSampler, texCoord);
                return;
            }
            if(yDist > 0) {
                hitCoord = translateMapCoordToDataCoord(ivec2(int(x), int(y+1)));
            } else {
                hitCoord = translateMapCoordToDataCoord(ivec2(int(x), int(y-1)));
            }
            ivec4 color = getIntegerColor(getData(DataSampler, hitCoord.y, hitCoord.x));
            if(closeEnoughRGBA(color, WALL_WIN)) {
                fragColor = encodeFloat(1.0);
                return;
            }
            if(closeEnoughRGBA(color, WALL_WIN_ALT)) {
                fragColor = encodeFloat(3.0);
                return;
            }
        }
        if(xDist > 0) {
            hitCoord = translateMapCoordToDataCoord(ivec2(int(x + 1), int(y)));
        } else {
            hitCoord = translateMapCoordToDataCoord(ivec2(int(x - 1), int(y)));
        }
        ivec4 color = getIntegerColor(getData(DataSampler, hitCoord.y, hitCoord.x));
        if(closeEnoughRGBA(color, WALL_WIN)) {
            fragColor = encodeFloat(1.0);
            return;
        }
    }

    fragColor = texture(DataSampler, texCoord);
}
