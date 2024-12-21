bool isEmitter(int blockID) {
    // Is the block a light emitter
    return  blockID == 10135 || // glowstone
            blockID == 10222 || // lit_redstone_lamp
            blockID == 10178 || // lantern
            blockID == 10326 || // redstone_lamp
            blockID == 10334;// || // shroomlight
            // blockID == 15391 || // redstone_torch
            // blockID == 15418 || // soul_torch
            // blockID == 15450 || // torch
            // blockID == 15465 || // underwater_torch
            // blockID == 15520 || // wall_torch
            // blockID == 15521 || // redstone_wall_torch
            // blockID == 15522; // soul_wall_torch
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
