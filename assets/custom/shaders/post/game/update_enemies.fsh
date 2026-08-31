#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>

uniform sampler2D DataSampler;
uniform sampler2D MapSampler;

in vec2 texCoord;

out vec4 fragColor;

void main(){
    ivec2 dataCoord = getDataCoords(texCoord);

    if(dataCoord.y < ENEMY_ROW || dataCoord.y >= ENEMY_ROW+5) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }

    int enemiesLoaded = int(decodeFloat(getData(DataSampler, ENEMY_ROW, ENEMIES_LOADED_INDEX)));

    // Load enemy locations from map image
    if(dataCoord.y == ENEMY_ROW) { // ENEMY_ROW stores original location, ENEMY_ROW+1 is xPos, ENEMY_ROW+2 is yPos

        // exit early if enemies are already loaded
        int loaded = int(decodeFloat(getData(DataSampler, ENEMY_ROW, ENEMIES_LOADED_INDEX)));
        if(loaded == 1) {
            fragColor = getData(DataSampler, dataCoord.y, dataCoord.x);
            return;
        }

        bool found = false;
        int foundX = -1;
        int foundY = -1;
        for(int row = 0; row < MAP_SIZE; row++) {
            for(int col = 0; col < MAP_SIZE; col++) {
                vec4 color = getMapData(MapSampler, row, col);
                ivec4 icolor = getIntegerColor(color);
                if(closeEnoughRGBA(icolor, ENEMY_COLOR)) { // enemy color is red & 100a
                    found = true;
                    ivec2 coords = ivec2(col, row);
                    int index=0;
                    while(index<dataCoord.x) {
                        vec4 loadedEnemyPositionColor = getData(DataSampler, ENEMY_ROW, index);
                        ivec2 enemyCoordinates = decodeMapCoord(loadedEnemyPositionColor);
                        if(enemyCoordinates == coords) {
                            found = false;
                            break;
                        }
                        index++;
                    }
                    if(found) {
                        foundX = col;
                        foundY = row;
                        break;
                    }
                }
                if(found) {
                    break;
                }
            }
        }
        if(dataCoord.x == ENEMIES_LOADED_INDEX) {
            if(found) {
                fragColor = encodeFloat(0.0);
            } else {
                fragColor = encodeFloat(1.0);
            }
        } else {
            if(found) {
                fragColor = encodeMapCoord(ivec2(foundX, foundY));
            } else {
                fragColor = vec4(0.0, 0.0, 0.0, 0.0);
            }
        }
        return;
    }

    // update enemy x position
    if(dataCoord.y == ENEMY_ROW + 1) {
        ivec2 origin = decodeMapCoord(getData(DataSampler, ENEMY_ROW, dataCoord.x));
        if(origin == ivec2(-1, -1)) {
            fragColor = vec4(0.0);
            return;
        }

        if(enemiesLoaded == 0.0) {
            fragColor = encodeFloat(origin.x + 0.5);
            return;
        }

        float dist = decodeFloat(getData(DataSampler, ENEMY_ROW+4, dataCoord.x));
        if(dist > ENEMY_SIGHT) {
            fragColor = texture(DataSampler, texCoord);
            return;
        }

        float currentX = decodeFloat(getData(DataSampler, ENEMY_ROW+1, dataCoord.x));
        float currentY = decodeFloat(getData(DataSampler, ENEMY_ROW+2, dataCoord.x));

        float deltaTime = getDeltaTime(DataSampler);
        float distanceToPlayer = decodeFloat(getData(DataSampler, ENEMY_ROW+4, dataCoord.x));
        float rotation = decodeFloat(getData(DataSampler, ENEMY_ROW+3, dataCoord.x));
        float idealMovement = distanceToPlayer > HITBOX_RADIUS ? -cos(rotation) * ENEMY_SPEED * deltaTime : 0.0;

        ivec2 hitCoord = translateMapCoordToDataCoord(ivec2(int(currentX + idealMovement + (HITBOX_RADIUS*1.1*sign(idealMovement))), int(currentY)));
        ivec4 color = getIntegerColor(getData(DataSampler, hitCoord.y, hitCoord.x));
        if(color.a == WALL_DOOR.a) { 
            if(sign(idealMovement) > 0.0) {
                currentX = int(currentX) + 1.0 - HITBOX_RADIUS;
            } else {
                currentX = int(currentX) + HITBOX_RADIUS;
            }
        } else {
            currentX += idealMovement;
        }
        fragColor = encodeFloat(currentX);
        return;
    }

    // update enemy y position
    if(dataCoord.y == ENEMY_ROW + 2) {
        ivec2 origin = decodeMapCoord(getData(DataSampler, ENEMY_ROW, dataCoord.x));
        if(origin == ivec2(-1, -1)) {
            fragColor = vec4(0.0);
            return;
        }

        if(enemiesLoaded == 0.0) {
            fragColor = encodeFloat(origin.y + 0.5);
            return;
        }

        float dist = decodeFloat(getData(DataSampler, ENEMY_ROW+4, dataCoord.x));
        if(dist > ENEMY_SIGHT) {
            fragColor = texture(DataSampler, texCoord);
            return;
        }

        float currentX = decodeFloat(getData(DataSampler, ENEMY_ROW+1, dataCoord.x));
        float currentY = decodeFloat(getData(DataSampler, ENEMY_ROW+2, dataCoord.x));

        float deltaTime = getDeltaTime(DataSampler);
        float distanceToPlayer = decodeFloat(getData(DataSampler, ENEMY_ROW+4, dataCoord.x));
        float rotation = decodeFloat(getData(DataSampler, ENEMY_ROW+3, dataCoord.x));
        float idealMovement = distanceToPlayer > HITBOX_RADIUS ? -sin(rotation) * ENEMY_SPEED * deltaTime : 0.0;

        ivec2 hitCoord = translateMapCoordToDataCoord(ivec2(int(currentX), int(currentY + idealMovement + (HITBOX_RADIUS*1.1*sign(idealMovement)))));
        ivec4 color = getIntegerColor(getData(DataSampler, hitCoord.y, hitCoord.x));
        if(color.a == WALL_DOOR.a) { 
            if(sign(idealMovement) > 0.0) {
                currentY = int(currentY) + 1.0 - HITBOX_RADIUS;
            } else {
                currentY = int(currentY) + HITBOX_RADIUS;
            }
        } else {
            currentY += idealMovement;
        }
        fragColor = encodeFloat(currentY);
        return;
    }

    // update enemy rotation
    if(dataCoord.y == ENEMY_ROW + 3) {
        ivec2 origin = decodeMapCoord(getData(DataSampler, ENEMY_ROW, dataCoord.x));
        if(origin == ivec2(-1, -1)) {
            fragColor = vec4(0.0);
            return;
        }

        float dist = decodeFloat(getData(DataSampler, ENEMY_ROW+4, dataCoord.x));
        if(dist > ENEMY_SIGHT + ENEMY_SPEED) {
            fragColor = texture(DataSampler, texCoord);
            return;
        }

        vec2 posOffset = vec2(
            decodeFloat(getData(DataSampler, ENEMY_ROW+1, dataCoord.x)) -
            decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_X_INDEX)), 
            decodeFloat(getData(DataSampler, ENEMY_ROW+2, dataCoord.x)) -
            decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_Y_INDEX))
        );

        float angle = length(posOffset) > 0.0
            ? atan(posOffset.y, posOffset.x)
            : decodeFloat(getData(DataSampler, ENEMY_ROW+3, dataCoord.x));
        fragColor = encodeFloat(angle);
        return;
    }

    // Load the relative distances
    if(dataCoord.y == ENEMY_ROW + 4) {
        ivec2 origin = decodeMapCoord(getData(DataSampler, ENEMY_ROW, dataCoord.x));
        if(origin == ivec2(-1, -1)) {
            fragColor = encodeFloat(0.0);
            return;
        }
    
        vec2 posOffset = vec2(
            decodeFloat(getData(DataSampler, ENEMY_ROW+1, dataCoord.x)) -
            decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_X_INDEX)), 
            decodeFloat(getData(DataSampler, ENEMY_ROW+2, dataCoord.x)) -
            decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_Y_INDEX))
        );

        fragColor = encodeFloat(length(posOffset));
        return;
    }

    if(dataCoord.y >= MAP_DATA_ROW && dataCoord.y <= MAP_DATA_ROW + MAP_SIZE) {
        if(enemiesLoaded == 1.0) {
            vec4 color = texture(DataSampler, texCoord);
            ivec4 icolor = getIntegerColor(color);
            if(closeEnoughRGBA(ENEMY_COLOR, icolor)) {
                fragColor = vec4(0.0, 0.0, 0.0, 0.0);
                return;
            }
        }
    }

    fragColor = texture(DataSampler, texCoord);
}
