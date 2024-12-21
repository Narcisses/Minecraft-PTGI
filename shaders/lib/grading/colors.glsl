// ------------- Tonemapping -------------
vec3 jodieReinhardTonemap(vec3 c, float exposure) {
    float l = dot(c, vec3(0.2126, 0.7152, 0.0722));
    vec3 tc = c / (c + exposure);
    return mix(c / (l + 1.0), tc, tc);
}

vec3 aces(vec3 v) {
    v *= 0.6f;
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return clamp((v*(a*v+b))/(v*(c*v+d)+e), 0.0f, 1.0f);
}

// ------------- Gamma -------------
vec3 toGammaSpace(vec3 color) {
    return pow(color, vec3(GAMMA));
}

vec3 toLinearSpace(vec3 color) {
    return pow(color, vec3(1.0 / GAMMA));
}

// ------------- Grading -------------
float getColorRange() {
    float t = getMidDayFrac01();
    return t * 1.2 + COLOR_RANGE;
}

float getMaxBrightness() {
    return max(eyeBrightnessSmooth.x, eyeBrightnessSmooth.y) / 240.0;
}

float exposure() {
    float expo = (1.0 - (1.0 - getMaxBrightness()) * MAX_EXPOSURE);
    expo *= 1.0 - getSunAmount() * 0.65;
    float sunnyExpo = clamp(expo, 0.05, MAX_EXPOSURE);
    float rainyExpo = 1.0;
    return mix(sunnyExpo, rainyExpo, wetness);
}

float luminance(vec3 color) {
    return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
}

float saturate(float x) {
    return clamp(x, 0.0, 1.0);
}

// vec3 vibranceSaturation(vec3 color) {
//     float lum   = dot(color, lumacoeffAP1);
//     float mn    = min(min(color.r, color.g), color.b);
//     float mx    = max(max(color.r, color.g), color.b);
//     float sat   = (1.0 - saturate(mx-mn)) * saturate(1.0-mx) * lum * 5.0;
//     vec3 light  = vec3((mn + mx) / 2.0);

//     color   = mix(color, mix(light, color, vibranceInt), saturate(sat));

//     color   = mix(color, light, saturate(1.0-light) * (1.0-vibranceInt) / 2.0 * abs(vibranceInt));

//     color   = mix(vec3(lum), color, saturationInt);

//     return color;
// }

// vec3 brightnessContrast(vec3 color) {
//     return (color - 0.5) * constrastInt + 0.5 + brightnessInt;
// }

// vec3 vignette(vec3 color) {
//     float fade      = length(uv*2.0-1.0);
//         fade        = linStep(abs(fade) * 0.5, vignetteStart, vignetteEnd);
//         fade        = 1.0 - pow(fade, vignetteExponent) * vignetteIntensity;

//     return color * fade;
// }