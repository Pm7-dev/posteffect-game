#version 330

#moj_import <minecraft:globals.glsl>

uniform sampler2D InSampler;

in vec2 texCoord;

out vec4 fragColor;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main(){
    // if(texCoord.x >= 0.01 && texCoord.x <= 0.02) {
    //     fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    //     return;
    // }

    if(texCoord.x >= 0.00499 && texCoord.x < 0.005) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec2 coord = round(texCoord * 500) / 500.0;
    fragColor = vec4(vec3(random(coord + GameTime)), 1.0);
}
