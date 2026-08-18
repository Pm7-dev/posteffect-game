#version 330

#moj_import <custom:game_globals.glsl>

vec4 fog(vec4 inColor, float dist) {
    return mix(inColor, vec4(0.0, 0.0, 0.0, inColor.a), (dist-3)/5.);
}