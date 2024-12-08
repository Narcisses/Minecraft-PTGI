#include "/lib/utils.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0]*gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH

in vec2 texcoord;

/* RENDERTARGETS: 5,8 */
layout(location = 0) out vec4 accIllumination;
layout(location = 1) out vec4 accMoments;

void temporalFilter() {
    // Current sample (this frame)
    vec3 currColor = texture(colortex4, texcoord).rgb;
    float currDepth = texture(depthtex0, texcoord).r;
    vec3 currNormal = decodeNormal(texture(gnormal, texcoord).xyz);
    float currID = texture(gnormal, texcoord).a;
    vec3 currPos = texture(colortex1, texcoord).xyz;

    vec2 neighborhood[18] = vec2[18](
        vec2(0.0),

        vec2(1.0, 0.0), 
        vec2(-1.0, 0.0), 
        vec2(0.0, 1.0),
        vec2(0.0, -1.0), 
        vec2(1.0, 1.0), 
        vec2(1.0, -1.0), 
        vec2(-1.0, 1.0), 
        vec2(-1.0, -1.0), 

        2.0 * vec2(1.0, 0.0), 
        2.0 * vec2(-1.0, 0.0), 
        2.0 * vec2(0.0, 1.0),
        2.0 * vec2(0.0, -1.0), 
        2.0 * vec2(1.0, 1.0), 
        2.0 * vec2(1.0, -1.0), 
        2.0 * vec2(-1.0, 1.0), 
        2.0 * vec2(-1.0, -1.0), 

        vec2(0.0)
    );
    
    vec3 histIllumination;
    vec2 histMoments;

    // Suppose fragment is dissocluded (new fragment)
    float alpha = 1.0;
    float newSampleCount = 1.0;
    bool couldLoad = false;

    for (int i = 0; i < 18; i++) {
        // Reprojection (get previous uv coord) // texcoord - getMotion(texcoord); //
        vec2 oldUV = reprojection(texcoord + neighborhood[i] / iresolution, currDepth);
        histIllumination = texture(colortex5, oldUV).rgb;
        histMoments = texture(colortex8, oldUV).rg;
        float historyAcc = texture(colortex8, oldUV).b;
        vec3 histNormal = decodeNormal(texture(colortex7, oldUV).rgb);
        float histID = texture(colortex7, oldUV).a;
        vec3 histPos = texture(colortex6, oldUV).rgb;
        float histDepth = texture(colortex6, oldUV).a - 1.0;

        // If valid, then reuse data
        if (isFragmentValid(oldUV, currNormal, currID, histNormal, currDepth, histDepth, currPos, histPos, histID)) {
            newSampleCount = min(HISTORY_SAMPLE_COUNT, historyAcc + 1);
            alpha = 1.0 / newSampleCount;
            couldLoad = true;
            break;
        }
    }

    // If could not load, then restart accumulation process
    if (!couldLoad || isFirstFrame()) {
        histIllumination = vec3(0.0);
        histMoments = vec2(0.0);
        newSampleCount = 1.0;
        alpha = 1.0;
    }

    // Compute moments & variance
    vec2 moments = vec2(0.0);
    moments.x = luminance(currColor);
    moments.y = moments.x * moments.x;

    // Compute new moments
    moments = mix(histMoments, moments, alpha);
    float variance = max(0.0, moments.g - moments.r * moments.r);

    // Compute new color
    vec3 newColor = mix(histIllumination, currColor, alpha);

    // Save previous data (illumination, variance, moment, and pixel age)
    accIllumination = vec4(newColor, variance);
    accMoments = vec4(moments, newSampleCount, 1.0);
}

void main() {
    // SVGF: filter the noise by accumulating previous frame samples
    // And blurring noisy regions
    // In this pass, we temporally accumulate samples over time/frames to reduce variance
    if (isTerrain(texcoord)) {
        temporalFilter();
    }
}

#endif