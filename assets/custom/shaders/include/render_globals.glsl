#version 330

#moj_import <custom:game_globals.glsl>

vec4 fog(vec4 input, float dist) {
    return mix(input, vec4(0.0, 0.0, 0.0, input.a), (dist-3)/5.);
}