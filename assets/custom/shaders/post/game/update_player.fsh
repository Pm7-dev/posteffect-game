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

    ivec2 dataCoord = getDataCoords(texCoord);

    if(dataCoord.y != PLAYER_DATA_ROW) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }

    int initialized = int(decodeFloat(getData(DataSampler, GAME_META_ROW, GAME_INITIALIZED_INDEX)));
    if(initialized != 1.0) {
        if(dataCoord.x == PLAYER_X_INDEX || dataCoord.x == PLAYER_Y_INDEX) {

            //TODO: THIS IS BROKEN... FIX THIS
            // bool found = false;
            // int row = 0;
            // int column = 0;
            // for(row=0; row<MAP_SIZE; row++) {
            //     for(column=0; column<MAP_SIZE; column++) {
            //         vec4 color = getMapData(MapSampler, row, column);
            //         if(color == vec4(1.0, 1.0, 1.0, 1.0)) {
            //             found = true;
            //         }
            //     }
            // }
            // if(found) {
            //     vec2 pos = vec2(column + 0.5, row + 0.5);
            //     if(dataCoord.x == PLAYER_X_INDEX) {
            //         fragColor = encodeFloat(pos.x);
            //     } else {
            //         fragColor = encodeFloat(pos.y);
            //     }
            // } else {
                if(dataCoord.x == PLAYER_X_INDEX) {
                    fragColor = encodeFloat((MAP_SIZE/2.0) + 0.5);
                } else {
                    fragColor = encodeFloat((MAP_SIZE/2.0) + 0.5);
                }
            // }

            return;
        }

        if(dataCoord.x == PLAYER_DIRECTION_INDEX) {
            fragColor = encodeFloat(0.0); // 30 degrees in radians
            return;
        }

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
