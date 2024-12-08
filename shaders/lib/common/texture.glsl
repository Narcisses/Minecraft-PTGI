bool isOutOfTexture(vec2 uv) {
    return uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0;
}

bool isWithinTexture(vec2 uv) {
    return uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0;
}

bool isWithinShadowTexture(ivec2 uv) {
    return uv.x >= 0 && uv.x <= shadowMapResolution && uv.y >= 0 && uv.y <= shadowMapResolution;
}