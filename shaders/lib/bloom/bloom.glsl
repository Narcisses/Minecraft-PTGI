// Implementation from: https://www.shadertoy.com/view/lsBfRc
vec3 makeBloom(float lod, vec2 offset, vec2 bCoord, vec2 iResolution, sampler2D tex) {
    vec2 pixelSize = 1.0 / iResolution;

    offset += pixelSize;

    float lodFactor = exp2(lod);

    vec3 bloom = vec3(0.0);
    vec2 scale = lodFactor * pixelSize;

    vec2 coord = (bCoord.xy - offset) * lodFactor;
    float totalWeight = 0.0;

    if (any(greaterThanEqual(abs(coord - 0.5), scale + 0.5)))
        return vec3(0.0);

    for (int i = -5; i < 5; i++) {
        for (int j = -5; j < 5; j++) {
            float wg = pow(1.0 - length(vec2(i, j)) * 0.125, 6.0);

            bloom = texture(tex, vec2(i, j) * scale + lodFactor * pixelSize + coord, lod).rgb * wg + bloom;
            totalWeight += wg;
        }
    }

    bloom /= totalWeight;

    return bloom;
}

vec3 bloomTile(float lod, vec2 offset, vec2 uv, sampler2D tex) {
    return texture(tex, uv * exp2(-lod) + offset).rgb;
}

vec3 getBloom(vec2 uv, sampler2D tex) {
    float alpha = getBloomAlphaAmount();
    
    // Bloom with multiple bloom tiles
    // Make sure tiles do not overlap (0.5 in Y just to avoid weird samplin bug)
    vec3 blur = vec3(0.0);
    blur = bloomTile(1., vec2(0.0, 0.0), uv, tex) * alpha + blur;
    blur = bloomTile(2., vec2(0.5, 0.5), uv, tex) * alpha + blur;
    blur = bloomTile(3., vec2(0.75, 0.0), uv, tex) * alpha + blur;
    blur = bloomTile(4., vec2(0.875, 0.5), uv, tex) * alpha + blur;
    blur = bloomTile(5., vec2(0.9375, 0.0), uv, tex) * alpha + blur;

    return blur * getColorRange();
}
