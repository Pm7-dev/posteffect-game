#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>

uniform sampler2D DataSampler;
uniform sampler2D MinecraftSampler;

in vec2 texCoord;

out vec4 fragColor;

void main() {
    ivec2 dataCoord = getDataCoords(texCoord);

    if(dataCoord.y != PLAYER_DATA_ROW) {
        fragColor = texture(DataSampler, texCoord);
        return;
    }

    //TODO: It'll be easier to just split this into three text displays :3
    // Gather player input from Minecraft
    if(dataCoord.x == MOVEMENT_INDEX) { // movement comes from the red channel
        vec4 minecraftInput = texture(MinecraftSampler, vec2(0.0, 0.5)); // get color at the middle of the screen
        if(minecraftInput.r > 0.9) {
            fragColor = encodeFloat(1.0);
        } else if(minecraftInput.r < 0.1) {
            fragColor = encodeFloat(-1.0);
        } else {
            fragColor = encodeFloat(0.0);
        }
        return;
    }
    if(dataCoord.x == ROTATION_INDEX) { // turn comes from the green channel
        vec4 minecraftInput = texture(MinecraftSampler, vec2(0.5, 0.5)); // get color at the middle of the screen
        if(minecraftInput.r > 0.9) {
            fragColor = encodeFloat(1.0);
        } else if(minecraftInput.r < 0.1) {
            fragColor = encodeFloat(-1.0);
        } else {
            fragColor = encodeFloat(0.0);
        }
        return;
    }
    if(dataCoord.x == ACTION_INDEX) { // action comes from the blue channel (jump input?)
        vec4 minecraftInput = texture(MinecraftSampler, vec2(1.0, 0.5)); // get color at the middle of the screen
        if(minecraftInput.r > 0.9) {
            fragColor = encodeFloat(1.0);
        } else {
            fragColor = encodeFloat(0.0);
        }
        return;
    }

    fragColor = texture(DataSampler, texCoord);
}
