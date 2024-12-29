#define SIGMA 10
#define BSIGMA 0.1
#define MSIZE 10

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
