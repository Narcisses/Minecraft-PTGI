#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/common/screen.glsl"
#include "/lib/common/easing.glsl"
#include "/lib/common/texture.glsl"
#include "/lib/common/vmath.glsl"
#include "/lib/atmosphere/ray.glsl"
#include "/lib/atmosphere/cycle.glsl"
#include "/lib/grading/colors.glsl"
#include "/lib/materials/materials.glsl"
#include "/lib/filtering/svgf.glsl"
#include "/lib/antialiasing/jitter.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH

in vec2 texcoord;

/* RENDERTARGETS: 5,8 */
layout(location = 0) out vec4 accIllumination;
layout(location = 1) out vec4 accMoments;

vec2 computeMoments(vec3 color) {
    vec2 moments = vec2(0.0);
    moments.x = luminance(color);
    moments.y = moments.x * moments.x;

    return moments;
}

void temporalFilter() {
    // Current sample (this frame)
    vec3 currColor = texture(colortex4, texcoord).rgb;
    vec3 currPos = texture(colortex1, texcoord).rgb;
    float currDepth = texture(depthtex0, texcoord).r;
    vec4 normalAndID = texture(gnormal, texcoord);
    vec3 currNormal = decodeNormal(normalAndID.xyz);
    float currID = decodeID(normalAndID.a);
    
    vec3 histIllumination;
    vec2 histMoments;

    // Suppose fragment is dissocluded (new fragment)
    float alpha = 1.0;
    float newSampleCount = 1.0;
    bool couldLoad = false;

    // Search for the previous data at pixel and around
    vec2 neighbors[10] = {
        vec2(0.0, 0.0),

        vec2( 0.125,-0.375),
        vec2(-0.125, 0.375),
        vec2( 0.625, 0.125),
        vec2( 0.375,-0.625),
        vec2(-0.625, 0.625),
        vec2(-0.875,-0.125),
        vec2( 0.375,-0.875),
        vec2( 0.875, 0.875),

        vec2(0.0, 0.0),
    };

    vec2 oldUV;
    vec3 momentsHist;
    float historyAcc;
    vec3 histPosition;
    vec3 histNormal;
    float histID;
    float histDepth;

    for (int i = 0; i < 10; i++) {
        // Reprojection (get previous uv coord)
        vec2 uv = texcoord + neighbors[i] / (iresolution * 1.0);
        vec2 oldUV = uv + texture(colortex3, uv).xy;
        // oldUV = reprojection(texcoord, currDepth);
        histIllumination = texture(colortex5, oldUV).rgb;
        histPosition = texture(colortex12, oldUV).rgb;
        momentsHist = texture(colortex8, oldUV).rga;
        histMoments = momentsHist.rg;
        historyAcc = texture(colortex8, oldUV).b;
        vec4 nNID = texelFetch(colortex7, ivec2(oldUV * iresolution), 0);
        histNormal = decodeNormal(nNID.rgb);
        histID = decodeID(nNID.a);
        histDepth = momentsHist.b;

        if (isFragmentValid(oldUV, currNormal, currID, histNormal, currDepth, histDepth, histID, currPos, histPosition)) {
            break;
        }
    }

    // If valid, then reuse data
    if (isFragmentValid(oldUV, currNormal, currID, histNormal, currDepth, histDepth, histID, currPos, histPosition)) {
        newSampleCount = min(HISTORY_SAMPLE_COUNT, historyAcc + 1);
        alpha = 1.0 / newSampleCount;
        couldLoad = true;
    }

    // If could not load, then restart accumulation process
    if (!couldLoad || isFirstFrame()) {
        histIllumination = vec3(0.0);
        histMoments = vec2(0.0);
        newSampleCount = 1.0;
        alpha = 1.0;
    }

    // Compute moments & variance
    vec2 moments = computeMoments(currColor);

    // Compute new moments
    moments = mix(histMoments, moments, alpha);
    float variance = max(0.0, moments.g - moments.r * moments.r);

    // Compute new color
    vec3 newColor = mix(histIllumination, currColor, alpha);

    // Save previous data (illumination, variance, moment, and pixel age)
    accIllumination = vec4(newColor, variance);
    accMoments = vec4(moments, newSampleCount, 1.0);
}

void pass(vec2 texcoord) {
    vec3 currColor = texture(colortex4, texcoord).rgb;
    vec2 moments = computeMoments(currColor);
    float variance = max(0.0, moments.g - moments.r * moments.r);

    accIllumination = vec4(currColor, variance);
    accMoments = vec4(moments, 1.0, 1.0);
}

void main() {
    // SVGF: filter the noise by accumulating previous frame samples
    // And blurring noisy regions
    // In this pass, we temporally accumulate samples over time/frames to reduce variance
    if (isTerrain(texcoord)) {
        #ifdef TEMPORAL_ACCUMULATION
            temporalFilter();
        #else
            pass(texcoord);
        #endif
    }
}

#endif
