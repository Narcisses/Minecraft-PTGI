#define SIGMA 10
#define BSIGMA 0.1
#define MSIZE 15

float normpdf(in float x, in float sigma) {
    return 0.39894 * exp(-0.5 * x * x / (sigma * sigma)) / sigma;
}

float normpdf3(in vec3 v, in float sigma) {
    return 0.39894 * exp(-0.5 * dot(v, v) / (sigma * sigma)) / sigma;
}

vec3 bilateralBlur(sampler2D tex, vec2 uv) {
    vec3 c = texture(tex, uv).rgb;

	//declare stuff
    const int kSize = (MSIZE - 1) / 2;
    float kernel[MSIZE];
    vec3 final_colour = vec3(0.0);

	//create the 1-D kernel
    float Z = 0.0;
    for (int j = 0; j <= kSize; ++j) {
        kernel[kSize + j] = kernel[kSize - j] = normpdf(float(j), SIGMA);
    }

    vec3 cc;
    float factor;
    float bZ = 1.0 / normpdf(0.0, BSIGMA);
	//read out the texels
    for (int i = -kSize; i <= kSize; ++i) {
        for (int j = -kSize; j <= kSize; ++j) {
            vec2 uv = uv + (vec2(float(i), float(j))) / iresolution.xy;
            if (isWithinTexture(uv) && isTerrain(uv)) {
                cc = texture(tex, uv).rgb;
                factor = normpdf3(cc - c, BSIGMA) * bZ * kernel[kSize + j] * kernel[kSize + i];
                Z += factor;
                final_colour += factor * cc;
            }
        }
    }

    return max(vec3(0.0), final_colour / Z);
}

// #define HW 5
// #define sigmaSpace 15.0
// #define sigmaColor 25.0

// vec3 bilateralBlur(sampler2D tex, vec2 uv) {
//     vec4 I = texture(tex, uv);
//     if (isWithinTexture(uv) && isTerrain(uv)) {
//         // Bilateral Filter
//         // Caluclate the 2*sigma^2 of both
//         float Ss = pow(sigmaSpace, 2.0) * 2.0;
//         float Sc = pow(sigmaColor, 2.0) * 2.0;

//         highp vec4 TW = vec4(0.0); // Sum of Weights
//         highp vec4 WI = vec4(0.0); // Sum of Weighted Intensities
//         highp vec4 w;
        
//         for (int i = -HW; i <= HW; i++) {
//             for (int j = -HW; j <= HW; j++) {
//                 vec2 dx = vec2(float(i), float(j));
//                 vec2 tc = uv + dx / iresolution.xy;
//                 if (isWithinTexture(tc) && isTerrain(tc)) {
//                     vec4 Iw = texture(tex, tc);
//                     vec4 dc = (I - Iw) * 255.0;

//                     w = exp(-dot(dx, dx) / Ss - dc * dc / Sc);
//                     TW += w;
//                     WI += Iw * w;
//                 }
//             }
//         }

//         return max(vec3(0.0), (WI / TW).rgb);
//     }
// }