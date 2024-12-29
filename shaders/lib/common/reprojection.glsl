// Motion buffer velocity calculation
vec2 calcVelocity(vec4 newPos, vec4 oldPos) {
	oldPos /= oldPos.w;
	oldPos.xy = (oldPos.xy + 1) / 2.0;
	oldPos.y = 1 - oldPos.y;

	newPos /= newPos.w;
	newPos.xy = (newPos.xy + 1) / 2.0;
	newPos.y = 1 - newPos.y;

	return (oldPos - newPos).xy;
}

// Standard previous frame reprojection from uv and depth
vec2 reprojection(vec2 uv, float depth) {
    vec4 frag = gbufferProjectionInverse * vec4(vec3(uv, depth) * 2.0 - 1.0, 1.0);
    frag /= frag.w;
    frag = gbufferModelViewInverse * frag;

    vec4 prevPos = frag + vec4(cameraPosition - previousCameraPosition, 0.0) * float(depth > 0.56);
    prevPos = gbufferPreviousModelView * prevPos;
    prevPos = gbufferPreviousProjection * prevPos;

    return prevPos.xy / prevPos.w * 0.5 + 0.5;
}

// Reprojection for clouds
vec2 reprojectPos(in vec3 pos) {
    // Reproject 3D world position into 2D uv coordinates
    // From previous frame
    vec4 wpos = vec4(pos, 1.0);
    vec4 cpos = (gbufferPreviousProjection * gbufferPreviousModelView * wpos).xyzw;
    cpos = cpos / cpos.w;
    
    return (0.5 + 0.5 * cpos).xy;
}