float mapRange(float x, float in_min, float in_max, float out_min, float out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

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

float encodeID(float ID) {
    ID = max(0, ID - 9999);
    ID /= 1100.0;
    return ID;
}

float decodeID(float ID) {
    ID = ID + 9999;
    ID *= 1100.0;
    return float(round(ID));
}