#version 330

// Encodes a float into four float rgba values (8 bits of precision)
vec4 encodeFloat(float timestamp) {
    int bits = floatBitsToInt(timestamp);

    int r = (bits >> 24) & 0xFF;
    int g = (bits >> 16) & 0xFF;
    int b = (bits >> 8) & 0xFF;
    int a = bits & 0xFF;

    return vec4(r / 255.0, g / 255.0, b / 255.0, a / 255.0);
}

// Decodes a float from four float rgba values. (These values are only stored with 8 bits of precision)
float decodeFloat(vec4 rgba) {
    int r = int(round(rgba.r * 255.0));
    int g = int(round(rgba.g * 255.0));
    int b = int(round(rgba.b * 255.0));
    int a = int(round(rgba.a * 255.0));

    int bits = (r & 0xFF) << 24;
    bits |= (g & 0xFF) << 16;
    bits |= (b & 0xFF) << 8;
    bits |= (a & 0xFF);

    return intBitsToFloat(bits);
}

