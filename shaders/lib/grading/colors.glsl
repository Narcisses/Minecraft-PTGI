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

vec3 tint() {
    // Tints / colors
    vec3 middayColor = vec3(0.43, 0.63, 1.0);
    vec3 sunriseColor = vec3(1.0, 0.72, 0.32);
    vec3 nightColor = vec3(0.15, 0.27, 0.51);
    vec3 neutralTint = vec3(1.0);

    // Day night cycle
    vec3 dayTint = mix(sunriseColor, middayColor, getMidDayFastFrac01());
    vec3 nightTint = nightColor;
    vec3 tint = mix(dayTint, nightTint, getNightAmount());

    // If in caves, no tint
    tint = mix(neutralTint, tint, getMaxBrightness());

    return tint;
}