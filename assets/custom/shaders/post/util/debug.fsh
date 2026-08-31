#version 330
uniform sampler2D MinecraftSampler;
uniform sampler2D DataSampler;
in vec2 texCoord;
out vec4 fragColor;


/*

    This is used as a debug layer to render the current data buffer on top of the rendered game so you can see the visual data and the memory at once.
    It was helpful for some things, so if you think it'd be helpful just add a render pass with sampler inputs from minecraft:main and data in game.json

*/

void main() {
    fragColor = mix(texture(MinecraftSampler, texCoord), texture(DataSampler, vec2(texCoord.x, texCoord.y / 2)), 0.5);
}
