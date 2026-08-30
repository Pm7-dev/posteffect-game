#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>
#moj_import <custom:raycast.glsl>

uniform sampler2D DataSampler;
uniform sampler2D MapSampler;

in vec2 texCoord;

out vec4 fragColor;

void main(){
    float deltaTime = getDeltaTime(DataSampler);
    
    ivec2 dataCoord = getDataCoords(texCoord);

    int initialized = int(decodeFloat(getData(DataSampler, GAME_META_ROW, GAME_INITIALIZED_INDEX)));
    if(initialized != 1.0) {

        // Remove the pixel that determines where the player spawns.
        if(dataCoord.y != PLAYER_DATA_ROW) {
            if(dataCoord.y >= MAP_DATA_ROW && dataCoord.y < MAP_DATA_ROW + 128) {
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
            for(int row = 0; row < MAP_SIZE; ++row) {
                for(int col = 0; col < MAP_SIZE; ++col) {
                    vec4 color = getMapData(MapSampler, row, col);
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
                    fragColor = encodeFloat(float(foundY) + 0.5);
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

        if(dataCoord.x == PLAYER_HEALTH_INDEX) {
            fragColor = encodeFloat(100.0);
            return;
        }
    }

    float health = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_HEALTH_INDEX));
    if(dataCoord.y != PLAYER_DATA_ROW || health <= 0.) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }



    float rot = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_DIRECTION_INDEX));
    float x = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_X_INDEX));
    float y = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, PLAYER_Y_INDEX));
    float movementInput = decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, MOVEMENT_INDEX));

    if(dataCoord.x == PLAYER_X_INDEX) {
        float movement = MOVE_SPEED * deltaTime * movementInput * cos(rot);
        float collisionCheck = movement + ((HITBOX_RADIUS*1.1) * sign(movement));
        ivec2 hitCoord = translateMapCoordToDataCoord(ivec2(int(x + collisionCheck), int(y)));
        ivec4 color = getIntegerColor(getData(DataSampler, hitCoord.y, hitCoord.x));
        if(color.a == WALL_DOOR.a) {
            if(sign(movement) > 0.0) {
                x = int(x) + 1.0 - HITBOX_RADIUS;
            } else {
                x = int(x) + HITBOX_RADIUS;
            }
        } else {
            x += movement;
        }
        fragColor = encodeFloat(x);
        return;
    }
    if(dataCoord.x == PLAYER_Y_INDEX) {
        float movement = MOVE_SPEED * deltaTime * movementInput * sin(rot);
        float collisionCheck = movement + ((HITBOX_RADIUS*1.1) * sign(movement));
        ivec2 hitCoord = translateMapCoordToDataCoord(ivec2(int(x), int(y+collisionCheck)));
        ivec4 color = getIntegerColor(getData(DataSampler, hitCoord.y, hitCoord.x));
        if(color.a == WALL_DOOR.a) {
            if(sign(movement) > 0.0) {
                y = int(y) + 1.0 - HITBOX_RADIUS;
            } else {
                y = int(y) + HITBOX_RADIUS;
            }
        } else {
            y += movement;
        }
        fragColor = encodeFloat(y);
        return;
    }
    if(dataCoord.x == PLAYER_DIRECTION_INDEX) {
        rot += decodeFloat(getData(DataSampler, PLAYER_DATA_ROW, ROTATION_INDEX)) * radians(ROT_SPEED) * deltaTime;
        rot = mod(rot, 2*PI);
        fragColor = encodeFloat(rot);
        return;
    }
    if(dataCoord.x == PLAYER_HEALTH_INDEX) {
        // search through enemy data row to check for damage
        for(int i=0; i<ENEMIES_LOADED_INDEX; i++) {
            ivec2 origin = decodeMapCoord(getData(DataSampler, ENEMY_ROW, i));
            if(origin == ivec2(-1, -1)) {
                break;
            }

            float dist = decodeFloat(getData(DataSampler, ENEMY_ROW+4, i));
            if(dist <= HITBOX_RADIUS) {
                health -= ENEMY_DAMAGE * deltaTime;
            }

            if(health <= 0.) {
                health = 0.;
                break;
            }
            
        }
        fragColor = encodeFloat(health);
        return;
    }
    if(dataCoord.x >= INVENTORY_INDEX && dataCoord.x < INVENTORY_POINTER_INDEX) {
        int keysLoaded = int(decodeFloat(getData(DataSampler, KEY_ROW, KEYS_LOADED_INDEX)));
        if(keysLoaded < 1.0) {
            fragColor = texture(DataSampler, texCoord);
            return;
        }

        vec4 color = getData(DataSampler, dataCoord.y, dataCoord.x);
        if(color == vec4(0.0)) {

            // Check to make sure that this is the FIRST open index in the inventory
            for(int i=INVENTORY_INDEX; i<dataCoord.x; i++) {
                vec4 prevColor = getData(DataSampler, PLAYER_DATA_ROW, i);
                if(prevColor == vec4(0.0)) {
                    fragColor = texture(DataSampler, texCoord);
                    return;
                }
            }

            for(int i = 0; i<KEYS_LOADED_INDEX; i++) {
                vec4 keyColor = getData(DataSampler, KEY_ROW+1, i);
                if(keyColor == vec4(0.0)) { // when keycolor is 0 it is no longer a key.....
                    continue;
                }
                float dist = decodeFloat(getData(DataSampler, KEY_ROW+3, i));
                if(dist < PICKUP_RADIUS) {
                    fragColor = keyColor;
                    return;
                }
            }
        }
    }
    if(dataCoord.x >= INVENTORY_POINTER_INDEX && dataCoord.x < INVENTORY_POINTER_INDEX + INVENTORY_SPACE) {
        int currentPointerIndex = dataCoord.x - INVENTORY_POINTER_INDEX;
        if(currentPointerIndex>0) {
            ivec2 prevPointer = decodePointer(getData(DataSampler, dataCoord.y, dataCoord.x-1));
            if(prevPointer == ivec2(-1, -1)) {
                fragColor = encodePointer(prevPointer);
                return;
            }
        }

        int indexToCheck = 0;
        int keysFound = 0;
        while(INVENTORY_INDEX + indexToCheck < INVENTORY_POINTER_INDEX) { 
            vec4 color = getData(DataSampler, PLAYER_DATA_ROW, INVENTORY_INDEX + indexToCheck);
            if(color != vec4(0.0)) {
                keysFound++;
                if(keysFound > currentPointerIndex) {
                    ivec2 coords = ivec2(INVENTORY_INDEX + indexToCheck, PLAYER_DATA_ROW);
                    fragColor = encodePointer(coords);
                    return;
                }
            }
            indexToCheck++;
        }
        fragColor = encodePointer(ivec2(-1, -1));
        return;

    }


    fragColor = texture(DataSampler, texCoord);
}
