float linearDepth(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

float encodeDepth(float depth) {
    return depth / far;
}

float decodeDepth(float depth) {
    return depth * far;
}

vec3 encodeNormal(vec3 normal) {
    return (normal + 1.0) / 2.0;
}

vec3 decodeNormal(vec3 normal) {
    return (normal * 2.0) - 1.0;
}

float mapRange(float x, float in_min, float in_max, float out_min, float out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}