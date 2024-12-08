bool isFirstFrame() {
	return frameCounter == 1;
}

bool hasResolutionChanged() {
    float epsilon = 10.0;
    vec2 oldSize = vec2(screenData.width, screenData.height);
    return (abs(viewWidth - oldSize.x) > epsilon) || (abs(viewHeight - oldSize.y) > epsilon);
}

bool hasWorldTimeChanged() {
    float epsilon = 100.0;
    float oldWorlTime = screenData.worldtime;
    return abs(worldTime - oldWorlTime) > epsilon;
}

bool isTerrain(vec2 texcoord) {
    // Return true if not fragment from sky, stars, sun, moon, or hand
	vec3 normal = decodeNormal(texture(gnormal, texcoord).rgb);
    float depth = texture(depthtex0, texcoord).r;
    float NdotN = dot(normal, normal);
    float Ndot1 = dot(normal, vec3(1.0));
    return NdotN > 0.1 && Ndot1 < 1.1 && depth / far < 1.0;
}

vec2 reprojection(vec2 uv, float depth) {
    vec4 frag = gbufferProjectionInverse * vec4(vec3(uv, depth) * 2.0 - 1.0, 1.0);
    frag /= frag.w;
    frag = gbufferModelViewInverse * frag;

    vec4 prevPos = frag + vec4(cameraPosition - previousCameraPosition, 0.0) * float(depth > 0.56);
    prevPos = gbufferPreviousModelView * prevPos;
    prevPos = gbufferPreviousProjection * prevPos;

    return prevPos.xy / prevPos.w * 0.5 + 0.5;
}

vec2 getMotion(vec2 uv) {
    // Return velocity of pixel
    return texture(colortex3, uv).rg - 10.0;// * vec2(0.5, -0.5) - 0.5;// * 2.0 - 1.0;
}

vec3 getPosition(vec2 uv, float depth) {
    vec4 fragpos0 = gbufferProjectionInverse * (vec4(texcoord, depth, 1.0) * 2.0 - 1.0);
    fragpos0.xyz /= fragpos0.w;
    vec3 worldPos = mat3(gbufferModelViewInverse) * fragpos0.xyz;
    worldPos = worldPos + eyeCameraPosition;

	return worldPos;
}

vec2 getDepthAndDerivative(vec2 texcoord) {
    vec2 depth = vec2(0.0);
    depth.x = texture(depthtex0, texcoord).r;
    depth.y = texture(colortex1, texcoord).w;

    return depth;
}

vec2 igetDepthAndDerivative(ivec2 fragCoord) {
    vec2 depth = vec2(0.0);
    // depth.x = texture(depthtex0, texcoord).r;
    // depth.y = texture(colortex1, texcoord).w;
    depth.x = texelFetch(depthtex0, fragCoord.xy, 0).x;
    depth.y = texelFetch(colortex1, fragCoord.xy, 0).w;

    return depth;
}