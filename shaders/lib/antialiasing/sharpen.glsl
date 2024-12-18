vec2 sharpenOffsets[4] = vec2[4](
	vec2( 1.0,  0.0),
	vec2( 0.0,  1.0),
	vec2(-1.0,  0.0),
	vec2( 0.0, -1.0)
);


void SharpenFilter(inout vec3 color, vec2 coord) {
	float mult = MC_RENDER_QUALITY * 0.125;
	vec2 view = 1.0 / vec2(viewWidth, viewHeight);

	color *= MC_RENDER_QUALITY * 0.5 + 1.0;

	for(int i = 0; i < 4; i++) {
		vec2 offset = sharpenOffsets[i] * view;
		color -= texture2D(colortex1, coord + offset).rgb * mult;
	}
}
