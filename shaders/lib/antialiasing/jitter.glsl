// Jitter offset from Chocapic13
vec2 jitterOffsets[8] = vec2[8](
							vec2( 0.125,-0.375),
							vec2(-0.125, 0.375),
							vec2( 0.625, 0.125),
							vec2( 0.375,-0.625),
							vec2(-0.625, 0.625),
							vec2(-0.875,-0.125),
							vec2( 0.375,-0.875),
							vec2( 0.875, 0.875)
						);

vec2 TAAJitter(vec2 coord, float w, bool previous) {
	int i = (previous) ? int(framemod8) : int(newframemod8);
	vec2 offset = jitterOffsets[i] * (w / iresolution);
	
	return coord + offset;
}