bool isFirstFrame() {
	return frameCounter == 1;
}

bool hasResolutionChanged() {
    float epsilon = 10.0;
    vec2 oldSize = vec2(screenData.width, screenData.height);
    
    return (abs(viewWidth - oldSize.x) > epsilon) || (abs(viewHeight - oldSize.y) > epsilon);
}

bool hasTimeChanged() {
    float epsilon = 100.0;
    float prevWorldTime = screenData.worldtime;

    return abs(prevWorldTime - worldTime) >= epsilon;
}

bool isGameAtHalfResolution() {
    return viewWidth <= 1920.0 / 2.0;
}

bool isGameAtMidResolution() {
    return viewWidth <= 1440.0 / 2.0 && !isGameAtHalfResolution();
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

vec3 getPosition(vec2 uv, float depth) {
    vec3 screenPos = vec3(uv, depth);
    vec3 ndcPos = screenPos * 2.0 - 1.0;

    vec4 homoCoord = gbufferProjectionInverse * vec4(ndcPos, 1.0);
    vec3 viewPos = homoCoord.xyz / homoCoord.w;

    vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos.xyz;
    vec3 worldPos = eyePlayerPos + eyeCameraPosition;

	return worldPos;
}

vec3 getViewDir(vec2 uv) {
    // Compute ray direction taking into account bob view (bobbing)
    float depth = texture(depthtex0, uv).r;
    vec4 fragPos = gbufferProjectionInverse * (vec4(uv, depth, 1.0) * 2.0 - 1.0);
    fragPos /= fragPos.w;
    vec3 viewPos = mat3(gbufferModelViewInverse) * fragPos.xyz;

    return normalize(eyeCameraPosition + viewPos);
}

/* Implementation from https://antongerdelan.net/opengl/raycasting.html */
vec3 getRayDir(vec2 uv) {
    // Return direction for ray at UV [0.0-1.0] with focal length of 1.0.
    // Right-handed coordinate system (Z points negative inside scene).

    // NDC
    float x = (2.0 * uv.x) - 1.0;
    float y = (2.0 * uv.y) - 1.0;

    // Clip
    vec4 rayClip = vec4(vec2(x, y), -1.0, 1.0);

    // Eye
    vec4 rayEye = gbufferProjectionInverse * rayClip;
    rayEye = vec4(rayEye.xy, -1.0, 0.0);

    // World
    vec3 rayWor = (gbufferModelViewInverse * rayEye).xyz;
    rayWor = normalize(rayWor);

    return rayWor;
}

vec2 getDepthAndDerivative(vec2 texcoord) {
    vec2 depth = vec2(0.0);
    depth.x = texture(depthtex0, texcoord).r;
    depth.y = texture(colortex1, texcoord).w;

    return depth;
}

vec2 igetDepthAndDerivative(ivec2 fragCoord) {
    vec2 depth = vec2(0.0);
    depth.x = texelFetch(depthtex0, fragCoord.xy, 0).x;
    depth.y = texelFetch(colortex1, fragCoord.xy, 0).w;

    return depth;
}