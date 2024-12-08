/* Implementation from https://antongerdelan.net/opengl/raycasting.html */
vec3 getRayDir(vec2 uv) {
    // Return direction for ray at UV [0.0-1.0] with focal length of 1.0.
    // Right-handed coordinate system (Z points negative inside scene).

    // NDC
    float x = (2.0f * uv.x) - 1.0;
    float y = (2.0f * uv.y) - 1.0;

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

vec2 reprojectPos(in vec3 pos) {
    // Reproject 3D world position into 2D uv coordinates
    // From previous frame
    vec4 wpos = vec4(pos, 1.0);
    vec4 cpos = (gbufferPreviousProjection * gbufferPreviousModelView * wpos).xyzw;
    cpos = cpos / cpos.w;
    return (0.5 + 0.5 * cpos).xy;
}