bool isEmitter(int blockID) {
    return blockID == 10146 || blockID == 10265;
}

vec3 getEmission(float blockID, vec3 color) {
    vec3 emission = vec3(0.0);
    if (isEmitter(int(blockID + 0.5))) {
		emission = color.rgb * DIRECT_EMISSION;
	}
    float b = getMaxBrightness();
    float s = 1.0 - getSunAmount();
    return emission * b * s;
}

vec3 getRayTracedEmission(float blockID) {
    vec3 emission = vec3(1.0);
    if (isEmitter(int(blockID + 0.5))) {
        emission = vec3(EMISSION);
	}
    return emission;
}
