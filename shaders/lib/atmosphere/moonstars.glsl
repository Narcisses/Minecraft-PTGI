// Created by Vinicius Graciano Santos - vgs/2015
// Mostly based on iq's presentation at Function 2009.
// https://iquilezles.org/www/material/function2009/function2009.htm
mat2 m = mat2(0.8, -0.6, 0.6, 0.8);

vec3 moonNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    // Quintic because everyone else is using the cubic! :D
    vec2 df = 30.0 * f * f * (f * (f - 2.0) + 1.0);
    f = f * f * f * (f * (f * 6. - 15.) + 10.);

    float a = texture(noisetex, (i + vec2(0.5, 0.5)) / 256., -100.0).r;
    float b = texture(noisetex, (i + vec2(1.5, 0.5)) / 256., -100.0).r;
    float c = texture(noisetex, (i + vec2(0.5, 1.5)) / 256., -100.0).r;
    float d = texture(noisetex, (i + vec2(1.5, 1.5)) / 256., -100.0).r;

    float k = a - b - c + d;
    float n = mix(mix(a, b, f.x), mix(c, d, f.x), f.y);

    return vec3(n, vec2(b - a + k * f.y, c - a + k * f.x) * df);
}

float fbmSimple(vec2 p) {
    float f = 0.0;
    f += 0.5 * moonNoise(p).x;
    p = 2.0 * m * p;
    f += 0.25 * moonNoise(p).x;
    p = 2.0 * m * p;
    f += 0.125 * moonNoise(p).x;
    p = 2.0 * m * p;
    f += 0.0625 * moonNoise(p).x;
    return f / 0.9375;
}

float getMoonMask(vec3 rd, vec3 moondir) {
	float moondot = clamp(dot(rd, moondir), 0.0, 1.0);
    return (pow(moondot, 512.0) - 0.15 > 0) ? 1.0 : 0.0;
}

vec3 moonAndStars(vec3 rd, vec3 moondir) {
    vec3 col = vec3(0.0);
    float t = getNightAmount();

    // Stars
    float f = fbmSimple(100.0 * rd.xy / rd.z);
    vec3 stars = vec3(smoothstep(0.90, 0.95, f));
    col += stars * easeOutCirc(t);

    // Moon
    vec2 size = rd.yz - moondir.yz;
    if (worldTime > 12000 && worldTime < 16000) {
        size = rd.yz - moondir.yz;
    } else if (worldTime >= 16000 && worldTime < 21000) {
        size = rd.xz - moondir.xz;
    } else if (worldTime >= 21000) {
        size = rd.yz - moondir.yz;
    }
    
    float moonMask = getMoonMask(rd, moondir);

    col += vec3(MOON_BRIGHTNESS) * moonMask;
    col *= pow(fbmSimple(31.0 * size.xy), 1.8);

    return col;
}
