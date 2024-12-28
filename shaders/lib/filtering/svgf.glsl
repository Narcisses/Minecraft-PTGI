// Checkcing functions for the temporal pass to check if fragment is valid (same as before)
bool checkID(float currID, float histID) {
    return int(currID + 0.5) == int(histID + 0.5);
}

bool checkNormal(vec3 currNormal, vec3 histNormal) {
    float normalThreshold = 0.95;
    return dot(currNormal, histNormal) >= normalThreshold;
}

bool checkDepth(float currDepth, float histDepth) {
    float depthThreshold = 0.50;
    return abs(histDepth - currDepth) <= depthThreshold;
}

bool checkPosition(vec3 currPos, vec3 histPos) {
    float distThreshold = 0.90;
    return distance(currPos, histPos) <= distThreshold;
}

bool isFragmentValid(vec2 uv, vec3 currNormal, float currID, 
    vec3 histNormal, float currDepth, float histDepth, float histID,
    vec3 currPos, vec3 histPos) {
    bool isID = checkID(currID, histID);
    bool inTex = isWithinTexture(uv);
    bool isNormal = checkNormal(currNormal, histNormal);
    bool isDepth = checkDepth(currDepth, histDepth);
    bool isPos = checkPosition(currPos, histPos);

    // If too far away, just consider position to be true (because of TAA jittering)
    // if (linearDepth(currDepth) > 0.25) {
    //     isPos = true;
    // }

    // if (isEmitter(int(currID + 0.5)) || isEmitter(int(histID + 0.5)))
    //     return false;

    // When looking at blocks from grazing angle, just assume we can return true (because of TAA jittering)
    vec3 dir = getRayDir(uv);
	float alikeness = abs(dot(-dir, currNormal));

    // float alikenessDerivative = max(abs(dFdx(alikeness)), abs(dFdy(alikeness)));
    // if (alikenessDerivative > 0.00001)
    //     return true;

    // float alikenessDerivative = max(abs(dFdx(length(currPos))), abs(dFdy(length(currPos))));
    // if (linearDepth(currDepth) > 0.1 && alikenessDerivative > 0.50 && linearDepth(currDepth) < 0.15 && (dot(currNormal, vec3(0, 1, 0)) > 0.90 || dot(histNormal, vec3(0, 1, 0)) > 0.90))
    //     return true;

    return isPos && isNormal && isDepth && inTex && isID;
}

float computeWeight(float depthCenter, 
                    float depthP, 
                    float phiDepth, 
                    vec3 normalCenter, 
                    vec3 normalP, 
                    float phiNormal, 
                    float luminanceIllumCenter, 
                    float luminanceP, 
                    float phiIllum) {
    float weightNormal = pow(saturate(dot(normalCenter, normalP)), phiNormal);
    float weightZ = (phiDepth == 0) ? 0.0 : abs(depthCenter - depthP) / phiDepth;
    float weightLillum = abs(luminanceIllumCenter - luminanceP) / phiIllum;
    float weightIllum = exp(0.0 - max(weightLillum, 0.0) - max(weightZ, 0.0)) * weightNormal;

    return weightIllum;
}

float computeVarianceCenter(sampler2D illuTex, ivec2 ipos) {
    float sum = 0.0;

    const float kernel[2][2] = {
        { 1.0 / 4.0, 1.0 / 8.0 },
        { 1.0 / 8.0, 1.0 / 16.0 }
    };

    const int radius = 1;
    for (int yy = -radius; yy <= radius; yy++) {
        for (int xx = -radius; xx <= radius; xx++) {
            ivec2 p = ipos + ivec2(xx, yy);
            float k = kernel[abs(xx)][abs(yy)];
            sum += texelFetch(illuTex, p, 0).a * k;
        }
    }

    return sum;
}

vec4 spatialFilter(sampler2D luminanceTexture, vec2 texcoord, int stepSize) {
    float epsilonVariance = 1e-10;
    float kernelg[3] = { 1.0, 2.0 / 3.0, 1.0 / 6.0 };

    ivec2 fragCoord = ivec2(gl_FragCoord.xy);

    // Get the luminance of the current pixel
    vec4 illuminationCenter = texelFetch(luminanceTexture, fragCoord, 0);
    float luminanceCenter = luminance(illuminationCenter.rgb);

    // Variance and depth
    float variance = illuminationCenter.w;
    // float variance = computeVarianceCenter(luminanceTexture, fragCoord);
    vec2 depthCenter = igetDepthAndDerivative(fragCoord).xy;

    // Return unchanged color if outside
    if (depthCenter.x >= 1e30 || depthCenter.x < 0.0 || !isTerrain(texcoord)) {
        return illuminationCenter;
    }

    vec3 normalCenter = decodeNormal(texelFetch(gnormal, fragCoord, 0).rgb);

    float phiIllumination = PHI_COLOUR * sqrt(max(0.0, epsilonVariance + variance));
    float phiDepth = max(depthCenter.y, 1e-6f) * float(stepSize);

    // Explicitly store/accumulate center pixel with weight 1 to prevent issues
    // with the edge-stopping functions
    float sumWeightIllum = 1.0;
    vec4 sumIllumination = illuminationCenter;

    int radius = 2;

    // Do the filtering
    for (int yy = -radius; yy <= radius; yy++) {
        for (int xx = -radius; xx <= radius; xx++) {
            vec2 pixelUV = texcoord + (vec2(xx, yy) * float(stepSize)) / iresolution;
            ivec2 pixelCoord = fragCoord + ivec2(xx, yy);
            // Weight of the kernel for this pixel (goes decreasing with distance from center)
            float kernel = kernelg[abs(xx)] * kernelg[abs(yy)];
            bool samePixel = (xx == 0 && yy == 0);

            // Skip center pixel, it is already accumulated
            if (isWithinTexture(pixelUV) && !samePixel && isTerrain(pixelUV)) {
                vec4 pixelColor = texelFetch(luminanceTexture, pixelCoord, 0);
                float luminanceP = luminance(pixelColor.rgb);
                float depthP = igetDepthAndDerivative(pixelCoord).x;
                vec3 normalP = decodeNormal(texelFetch(gnormal, pixelCoord, 0).rgb);

                // Compute the edge-stopping functions
                float w = computeWeight(
                    depthCenter.x,
                    depthP,
                    phiDepth * length(vec2(xx, yy)),
                    normalCenter,
                    normalP,
                    PHI_NORMAL,
                    luminanceCenter,
                    luminanceP,
                    phiIllumination
                );

                float illuminationWeight = w * kernel;

                // Alpha channel contains the variance, therefore the weights need to be squared
                sumWeightIllum += illuminationWeight;
                sumIllumination += vec4(vec3(illuminationWeight), illuminationWeight * illuminationWeight) * pixelColor;
            }
        }
    }

    // Renormalization is different for variance
    vec4 filteredIllumination = vec4(sumIllumination / vec4(vec3(sumWeightIllum), sumWeightIllum * sumWeightIllum));

    return filteredIllumination;
}

vec4 momentsFilter(sampler2D luminanceTexture, vec2 texcoord) {
    float pixelAge = texture(colortex8, texcoord).b;

    // Proceed only if enough temporal accumulation
    if (pixelAge < 4.0) {
        float sumIlluminationWeights = 0.0;
        vec3 sumIllumination = vec3(0.0, 0.0, 0.0);
        vec2 sumMoments = vec2(0.0, 0.0);

        // Get the luminance of the current pixel
        vec4 illuminationCenter = texture(luminanceTexture, texcoord);
        float luminanceCenter = luminance(illuminationCenter.rgb);

        // Depth
        vec2 depthCenter = getDepthAndDerivative(texcoord);

        // Return unchanged color if outside
        if (depthCenter.x < 0 || !isTerrain(texcoord)) {
            return illuminationCenter;
        }

        vec3 normalCenter = decodeNormal(texture(gnormal, texcoord).rgb);
        float phiLIllumination = PHI_COLOUR;
        float phiDepth = max(depthCenter.y, 1e-8) * 3.0;

        // Compute first and second moment spatially (Apply cross-bilateral filtering on input illumination).
        int radius = 3;

        for (int yy = -radius; yy <= radius; yy++) {
            for (int xx = -radius; xx <= radius; xx++) {
                vec2 pixelUV = texcoord + vec2(xx, yy) / iresolution;
                bool samePixel = (xx == 0 && yy == 0);

                if (isWithinTexture(pixelUV) && !samePixel && isTerrain(pixelUV)) {
                    vec3 illuminationPixel = texture(luminanceTexture, pixelUV).rgb;
                    vec2 momentsPixel = texture(colortex8, pixelUV).rg;
                    float luminanceP = luminance(illuminationPixel.rgb);
                    float depthP = getDepthAndDerivative(pixelUV).x;
                    vec3 normalP = decodeNormal(texture(gnormal, pixelUV).rgb);

                    float w = computeWeight(
                        depthCenter.x,
                        depthP,
                        phiDepth * length(vec2(xx, yy)),
                        normalCenter,
                        normalP,
                        PHI_NORMAL,
                        luminanceCenter,
                        luminanceP,
                        phiLIllumination
                    );

                    sumIlluminationWeights += w;
                    sumIllumination += illuminationPixel * w;
                    sumMoments += momentsPixel * w;
                }
            }
        }

        // Clamp sum to > 0 to avoid NaNs.
        sumIlluminationWeights = max(sumIlluminationWeights, 1e-6f);

        sumIllumination /= sumIlluminationWeights;
        sumMoments /= sumIlluminationWeights;

        // Compute variance using the first and second moments
        float variance = sumMoments.g - sumMoments.r * sumMoments.r;

        // Give the variance a boost for the first frames
        variance *= 4.0 / pixelAge;

        return vec4(sumIllumination, variance);
    } else {
        // Pass-through, do nothing if not enough samples
        return texture(luminanceTexture, texcoord);
    }

    return texture(luminanceTexture, texcoord);
}
