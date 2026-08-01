#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>

uniform sampler2D DataSampler;
uniform sampler2D MapSampler;
uniform sampler2D MinecraftSampler;

layout(std140) uniform SamplerInfo {
    vec2 DataSize;
};

in vec2 texCoord;

out vec4 fragColor;

vec4 getDataAtIndex(int index) {
    return texture(DataSampler, vec2((1.0/DataSize.x)*(index + 0.5), 0.25));
}

int getPixelIndex() {
    int index = int(floor((texCoord.x*DataSize.x)) + int((DataSize.x * floor(texCoord.y*DataSize.y))));
    return index;
}

//TODO: supposedly, this isn't even helping with stopping the crashes. Surely there's some divide by zero then, right?
vec4 safeTexture(sampler2D samplr, vec2 coords) {
    float x = coords.x/MAP_SIZE;
    if(x > 1.0 || x < 0.0) return vec4(0.0, 0.0, 0.0, 0.0);
    float y = coords.y/MAP_SIZE;
    if(y > 1.0 || y < 0.0) return vec4(0.0, 0.0, 0.0, 0.0);
    return texture(samplr, coords/MAP_SIZE);
}

vec2 rotationToVector(float rot) {
    return vec2(cos(rot), sin(rot));
}

void main(){
    int dataPointIndex = getPixelIndex();

    // Check if the game has been loaded. if not, load and return.
    float started = decodeFloat(getDataAtIndex(0));
    if(started == 0.0) {
        switch(dataPointIndex) {
            case 0: { // Set game to started
                fragColor = encodeFloat(1.0);
                break;
            }
            case 1: { // Player starts with no motion
                fragColor = encodeFloat(0.0);
                break;
            }
            case 2: { // Camera starts with no motion
                fragColor = encodeFloat(0.0);
                break;
            }

            //TODO: Loading start position from map
            case 3: { // Pos x initializes to the center of the arena
                fragColor = encodeFloat(MAP_SIZE/2.);
                break;
            }
            case 4: {// Pos y initializes to the center of the arena
                fragColor = encodeFloat(MAP_SIZE/2.);
                break;
            }
            case 5: { // Camera rotation starts at zero radians
                fragColor = encodeFloat(0.523599);
                break;
            }
            case 6: { // Gametime initializes to the current gametime
                fragColor = encodeFloat(GameTime);
                break;
            }
            default: {
                fragColor = encodeFloat(texCoord.x * 3.0);//vec4(0.0, 0.0, 0.0, 0.0);
                break;
            }
        }
        return;
    }

    if(dataPointIndex == 0) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }

    // If the pixel is in the second row, it is there to store a wall distance, so send a ray in the pixel's direction to get the distance to wall.
    if(dataPointIndex >= DataSize.x) {
        float rotOffset = -((texCoord.x - 0.5) * radians(FOV));
        float rot = decodeFloat(getDataAtIndex(5)) + rotOffset;
        vec2 originalPos = vec2(decodeFloat(getDataAtIndex(3)), decodeFloat(getDataAtIndex(4)));
        vec2 pos = originalPos;
        vec2 mapPos = vec2(floor(pos.x), floor(pos.y));
        vec2 rotVec = vec2(cos(rot), sin(rot));
        vec2 stepDir = sign(rotVec);
        vec2 totalDist = vec2(0.0, 0.0);
        while (abs(pos.x-originalPos.x) < MAX_SIGHT && abs(pos.y-originalPos.y) < MAX_SIGHT) {
            vec2 distToNext = vec2(0.0, 0.0);
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

            if(distToNext.x / abs(rotVec.x) < distToNext.y / abs(rotVec.y)) {
                float t = distToNext.x / abs(rotVec.x);
                pos += rotVec * t;
                mapPos.x += stepDir.x;
            } else {
                float t = distToNext.y / abs(rotVec.y);
                pos += rotVec * t;
                mapPos.y += stepDir.y;
            }

            if(safeTexture(MapSampler, mapPos+vec2(0.5,0.5)).a > 0.1) {
                break;
            }


        }
        fragColor = encodeFloat(distance(pos, originalPos));
        return;
    }

    float lastGameTime = decodeFloat(getDataAtIndex(6));
    float delta = GameTime - lastGameTime; // Change in GameTime since the last frame update
    if(delta < 0) delta += 1.0; // if GameTime loops back to 0, prevent the animation from going back.
    float deltaTime = delta * 1200.0; // 1 GameTime is 20 minutes, which is 1200 seconds
    if(dataPointIndex == 6) { // If it's time to update GameTime, update it and return.
        fragColor = encodeFloat(GameTime);
        return;
    }

    // Gather player input from Minecraft
    vec4 minecraftInput = texture(MinecraftSampler, vec2(0.5, 0.5)); // get color at the middle of the screen
    if(dataPointIndex == 1) { // movement comes from the red channel
        if(minecraftInput.r > 0.75) {
            fragColor = encodeFloat(1.0);
        } else if(minecraftInput.r < 0.25) {
            fragColor = encodeFloat(-1.0);
        } else {
            fragColor = encodeFloat(0.0);
        }
        return;
    }
    if(dataPointIndex == 2) { // turn comes from the green channel
        if(minecraftInput.g > 0.75) {
            fragColor = encodeFloat(1.0);
        } else if(minecraftInput.g < 0.25) {
            fragColor = encodeFloat(-1.0);
        } else {
            fragColor = encodeFloat(0.0);
        }
        return;
    }

    // Move Player and adjust camera
    float rotation = decodeFloat(getDataAtIndex(5));
    if(dataPointIndex == 3) {
        float x = decodeFloat(getDataAtIndex(3));
        x += cos(rotation) * decodeFloat(getDataAtIndex(1)) * MOVE_SPEED * deltaTime;
        fragColor = encodeFloat(x);
        return;
    }
    if(dataPointIndex == 4) {
        float y = decodeFloat(getDataAtIndex(4));
        y += sin(rotation) * decodeFloat(getDataAtIndex(1)) * MOVE_SPEED * deltaTime;
        fragColor = encodeFloat(y);
        return;
    }    
    if(dataPointIndex == 5) {
        rotation += decodeFloat(getDataAtIndex(2)) * radians(ROT_SPEED) * deltaTime;
        fragColor = encodeFloat(rotation);
        return;
    }

    fragColor = vec4(0.0, 0.0, 0.0, 0.0);
}

/*
    DataPoint table
    0 - Game started (0.0 if not started, 1.0 if started)
    1 - Player input forward/backward (1.0, 0.0, or -1.0 for player movement)
    2 - Player input camera turn (1.0, 0.0, or -1.0 for camera rotation)
    3 - Player position x
    4 - Player position y
    5 - Player rotation radians
    6 - GameTime (current timestamp, travels from 0.0 to 1.0 every twenty minutes before looping)

*/
