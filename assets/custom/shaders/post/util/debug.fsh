#version 330
uniform sampler2D InSampler;
in vec2 texCoord;
out vec4 fragColor;
void main() {
    fragColor = texture(InSampler, vec2(texCoord.x, texCoord.y / 2));
}
