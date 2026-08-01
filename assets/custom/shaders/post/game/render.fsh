#version 330

#moj_import <custom:data_storage.glsl>
#moj_import <custom:game_globals.glsl>

uniform sampler2D DataSampler;

in vec2 texCoord;

out vec4 fragColor;

layout(std140) uniform SamplerInfo {
    vec2 DataSize;
};

void main(){
    float dist = decodeFloat(texture(DataSampler, vec2(texCoord.x, 0.75)));
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
