#version 330
uniform sampler2D MinecraftSampler;
uniform sampler2D DataSampler;
in vec2 texCoord;
out vec4 fragColor;
void main() {
    fragColor = mix(texture(MinecraftSampler, texCoord), texture(DataSampler, vec2(texCoord.x, texCoord.y / 2)), 0.0);
}
