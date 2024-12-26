const float DEPTH_THRESHOLD = 0.66;
#define MOTION_BLUR_STRENGTH 0.40
#define MOTION_BLUR_SAMPLES 6

vec3 motionBlur(sampler2D tex, vec2 texcoord, vec3 color, float z, float dither) {
    if (z <= DEPTH_THRESHOLD) return color;

    vec2 velocity = -texture(colortex3, texcoord).xy;
    velocity = velocity / (1.0 + length(velocity)) * MOTION_BLUR_STRENGTH;

    vec3 mblur = vec3(0.0);
    float totalWeight = 0.0;

    for (int i = 0; i < MOTION_BLUR_SAMPLES; i++) {
        float t = (float(i) + dither) / float(MOTION_BLUR_SAMPLES - 1);
        vec2 offset = velocity * (t - 0.5);
        vec2 sampleCoord = texcoord + offset;
        
        vec3 sampleColor = texture2D(tex, sampleCoord).rgb;
        float noiseValue = rand(sampleCoord * frameTimeCounter);
        float weight = mix(0.5, 1.0, noiseValue);
        
        mblur += sampleColor * weight;
        totalWeight += weight;
    }

    return mblur / totalWeight;
}
