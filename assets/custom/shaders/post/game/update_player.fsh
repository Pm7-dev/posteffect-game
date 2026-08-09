#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>

uniform sampler2D DataSampler;
uniform sampler2D MapSampler;

in vec2 texCoord;

out vec4 fragColor;

void main(){
    float lastGameTime = decodeFloat(getData(DataSampler, GAME_META_ROW, LAST_GAME_TIME_INDEX));
    float delta = GameTime - lastGameTime; // Change in GameTime since the last frame update
    if(delta < 0) delta += 1.0; // if GameTime loops back to 0, prevent the animation from going back.
    float deltaTime = delta * 1200.0; // 1 GameTime is 20 minutes, which is 1200 seconds
    if(deltaTime > 0.15) deltaTime = 0.15; // Cap deltaTime to prevent large jumps in time

    ivec2 dataCoord = getDataCoords(texCoord);

    int initialized = int(decodeFloat(getData(DataSampler, GAME_META_ROW, GAME_INITIALIZED_INDEX)));
    if(initialized != 1.0) {

        // Remove the pixel that determines where the player spawns.
        if(dataCoord.y != PLAYER_DATA_ROW) {
            if(dataCoord.y > MAP_DATA_ROW && dataCoord.y < MAP_DATA_ROW + 128) {
                int index = getIndex(texCoord) - MAP_DATA_ROW * MEMORY_PAGE_SIZE;
                vec4 color = getMapData(MapSampler, index);
                ivec4 icolor = getIntegerColor(color);
                if(icolor == PLAYER_SPAWN) {
                    fragColor = vec4(0.0, 0.0, 0.0, 0.0);
                } else {
                    fragColor = color;
                }
                return;
            }
            fragColor = texture(DataSampler, texCoord);
            return;
        }

        
        // Load the player's initial X and Y position from the white pixel.
        if(dataCoord.x == PLAYER_X_INDEX || dataCoord.x == PLAYER_Y_INDEX) {
            int found = 0;
            int foundX = 0;
            int foundY = 0;
            int samples = 0;
            for(int row = 0; row < MAP_SIZE; ++row) {
                for(int col = 0; col < MAP_SIZE; ++col) {
                    vec4 color = getMapData(MapSampler, row, col);
                    samples++;
                    ivec4 icolor = getIntegerColor(color);
                    if(icolor == PLAYER_SPAWN) {
                        found = 1;
                        foundX = col;
                        foundY = row;
                        break;
                    }
                }
                if(found == 1) {
                    break;
                }
            }
            if(found == 1) {
                if(dataCoord.x == PLAYER_X_INDEX) {
                    fragColor = encodeFloat(float(foundX) + 0.5);
                } else {
                    fragColor = encodeFloat(float(foundY+2) + 0.5);
                }
            } else {
                // fallback to center of the map if nothing found or search capped
                float center = (MAP_SIZE/2.0) + 0.5;
                fragColor = encodeFloat(center);
            }

            return;
        }

        if(dataCoord.x == PLAYER_DIRECTION_INDEX) {
            fragColor = encodeFloat(0.0); // 30 degrees in radians
            return;
        }
    }

    if(dataCoord.y != PLAYER_DATA_ROW) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }


    if(dataCoord.x == PLAYER_X_INDEX) {
        float rot = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_DIRECTION_INDEX));
        float x = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_X_INDEX));
        x += MOVE_SPEED * deltaTime * decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, MOVEMENT_INDEX)) * cos(rot);
        fragColor = encodeFloat(x);
        return;
    }
    if(dataCoord.x == PLAYER_Y_INDEX) {
        float rot = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_DIRECTION_INDEX));
        float y = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_Y_INDEX));
        y += MOVE_SPEED * deltaTime * decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, MOVEMENT_INDEX)) * sin(rot);
        fragColor = encodeFloat(y);
        return;
    }
    if(dataCoord.x == PLAYER_DIRECTION_INDEX) {
        float rot = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_DIRECTION_INDEX));
        rot += decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, ROTATION_INDEX)) * radians(ROT_SPEED) * deltaTime;
        rot = mod(rot, 2*PI);
        fragColor = encodeFloat(rot);
        return;
    }


    fragColor = texture(DataSampler, texCoord);
}
