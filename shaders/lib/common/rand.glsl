float rand(vec2 co) {
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt = dot(co.xy ,vec2(a,b));
    float sn = mod(dt,3.14);

    return fract(sin(sn) * c);
}

vec2 rand2D(vec2 texcoord) {
	#ifdef TEMPORAL_ACCUMULATION
		float x0 = rand(texcoord.xy * (float(worldTime) + 1.0) * frameCounter);
		float x1 = rand((texcoord.yx) * (float(worldTime + 1.0)) * frameCounter);
	#else
		float x0 = rand(texcoord.xy * (float(1) + 1.0) * 1);
		float x1 = rand((texcoord.yx + 1.0) * (float(1 + 1.0)) * 1);
	#endif

	return vec2(x0, x1);
}

float hash1(inout float seed) {
    return fract(sin(seed += 0.1)*43758.5453123);
}

vec2 hash2(inout float seed) {
    return fract(sin(vec2(seed+=0.1,seed+=0.1))*vec2(43758.5453123,22578.1459123));
}

vec3 hash3(inout float seed) {
    return fract(sin(vec3(seed+=0.1,seed+=0.1,seed+=0.1))*vec3(43758.5453123,22578.1459123,19642.3490423));
}
