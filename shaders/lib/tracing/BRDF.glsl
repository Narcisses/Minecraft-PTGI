vec3 cosineSampleWeightedHemisphere(vec3 n, vec2 u) {
    float r = sqrt(u.x);
    float theta = TWO_TIMES_PI * u.y;

    vec3 B = normalize(cross(n, vec3(0.0, 1.0, 1.0)));
    vec3 T = cross(B, n);

    return normalize(r * sin(theta) * B + sqrt(1.0 - u.x) * n + r * cos(theta) * T);
}

vec3 brdf(vec3 normal, inout float seed, inout float pdf) {
    vec2 uv = blueNoise(gl_FragCoord.xy, seed).xy;
    // vec2 uv = hash2(seed);
    vec3 rd = cosineSampleWeightedHemisphere(normal, uv);
    pdf = dot(normal, rd) / PI;

    return rd;
}
