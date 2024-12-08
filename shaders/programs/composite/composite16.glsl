#include "/lib/utils.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH

in vec2 texcoord;

/* RENDERTARGETS: 0,5,6,7 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 prevIllum;
layout(location = 2) out vec4 prevPos;
layout(location = 3) out vec4 prevNormal;

void main() {
    // Final pass for Bloom, Tonemapping, and Gamma correction
	vec3 col = texture(colortex0, texcoord).rgb * getColorRange();

    // Bloom
    col += getBloom(texcoord, colortex15);
    
    // Tonemapping & Gamma correction
    float expo = exposure();
    col = jodieReinhardTonemap(col, expo);
    col = toLinearSpace(col);

    // Final color output to screen
	color = vec4(col, 1.0);

    // Save (previous) screen resolution and time (useful for resolution changes)
    screenData.width = viewWidth;
    screenData.height = viewHeight;
    screenData.worldtime = worldTime;

    screenData.seed += 1.0;

    // Save (previous) frame data (normal, illumination, depth, position, ...)
    vec4 currIllum = texture(colortex4, texcoord);
    vec4 currNormal = texture(colortex2, texcoord);
    float currDepth = texture(depthtex0, texcoord).r;
    vec3 currPos = texture(colortex1, texcoord).xyz;

    prevIllum = currIllum; // Illumination + variance
    prevNormal = currNormal; // Normal + mesh ID
    prevPos = vec4(currPos, currDepth + 1.0); // Position + depth


    // ------------- Debug SVGF -------------
    // // Moments
    // vec2 moments = texture(colortex8, texcoord).rg;
    // color.rgb = vec3(moments.r, 0.0, 0.0);

    // Illumination + Variance
    // vec4 illumination = texture(colortex5, texcoord);
    // float variance = illumination.w;
    // color.rgb = illumination.rgb;
    // color.rgb = vec3(variance);

    // color.rgb = vec3(texture(colortex8, texcoord).b);


    // color.rgb = vec3(getMaxBrightness());

	// vec3 rdOffset = texture(noisetex, texcoord).rgb;
    // color.rgb = rdOffset;

    // color.rgb = vec3((gl_FragCoord.xy - (texcoord * iresolution), 0.0));


    // color.rgb = decodeNormal(currNormal.xyz);
    // color.rgb = decodeNormal(texture(colortex2, texcoord).xyz);
    // color.rgb = decodeNormal(texture(gnormal, texcoord).xyz);

    // Debug
    // vec2 m1 = texcoord + getMotion(texcoord);
    // vec2 m2 = reprojection(texcoord, currDepth);
    // color.rgb = vec3(m1 - m2, 0.0);
    // color.rgb = vec3(reprojection(texcoord, currDepth), 0.0);
    // color.rgb = vec3(texcoord + getMotion(texcoord), 0.0);

    // color.rgb = vec3(gl_FragCoord.xy / iresolution, 0.0);
    // color.rgb = texture(colortex3, texcoord).rgb;
    // vec2 currUV = texcoord;
    // vec2 oldUV = reprojection(texcoord, currDepth);
    // color.rgb = vec3(texcoord - oldUV, 0.0);
    // color.rgb = vec3(max(vec2(0.0), currUV - oldUV), 0.0);
    // float g = mapRange(texture(colortex7, texcoord).a, 10000.0, 16500.0, 0.0, 1.0);
    // float r = mapRange(texture(gnormal, texcoord).a, 10000.0, 16500.0, 0.0, 1.0);
    // float g = texture(colortex7, texcoord).a;
    // float r = texture(gnormal, texcoord).a;
    // float res = (int(g + 0.5) == int(r + 0.5)) ? 1.0 : 0.0;
    // color.rgb = vec3(res);
    // color.rgb = vec3(screenData.seed / 1000.0);
    // color.rgb = vec3(texture(colortex5, texcoord).a);
    // color.rgba = vec4(vec3(texture(colortex1, texcoord).a) * 100, 1.0);
    // color.rgb = texture(colortex5, texcoord).rgb;
    // color.rgb = vec3(texture(colortex5, texcoord).a);
    // color.rgb = vec3(texture(colortex8, texcoord).rg, 1.0);
    // color.rgba = vec4(vec3(texture(colortex6, texcoord).r) / 60, 1.0);
    // color.rgb = texture(colortex10, texcoord).rgb;
    // if (isTerrain(texcoord)) {
    // float r = mapRange(texture(gnormal, texcoord).a, 10000.0, 16100.0, 0.0, 1.0);
    // color.rgba = vec4(vec3(r), 1.0);
    // color.rgb = vec3(texture(colortex8, texcoord).b / 400.0);
    // color.rgb = vec3(texture(colortex8, texcoord).rg, 0.0);
    // color.rgb = decodeNormal(texture(colortex7, texcoord).rgb);
    // color.rgb = decodeNormal(texture(gnormal, texcoord).rgb);
    // color.rgb = decodeNormal(texture(colortex7, texcoord).rgb) - decodeNormal(texture(gnormal, texcoord).rgb);
    // color.rgb = decodeNormal(texture(colortex3, texcoord).rgb) - decodeNormal(texture(colortex1, texcoord).rgb);
    // vec3 pos = texture(colortex1, texcoord).rgb;
    // // vec3 dir = normalize(pos);
    // vec3 dir = getRayDir(texcoord);

    // RayHit hit = voxelTrace(vec3(0.0), dir);

    // if (hit.hit) {
    //     color.rgb = vec3(decodeNormal(hit.color.rgb));
    // } else {
    //     color.rgb = vec3(0.0);
    // }

    // color.rgb = vec3(1.0 - wetness);

    // }
    // color.rgb = texture(colortex5, texcoord).rgb;
    // color.rgb = texture(colortex14, texcoord).rgb;
    // color.rgb = texture(colortex15, texcoord).rgb;
    // color.rgb = texture(colortex5, texcoord).rgb;
    // color.rgb = vec3(texture(colortex6, texcoord).g);
    // color.rgb = texture(colortex1, texcoord).rgb;
    // color.rgb = texture(colortex1, texcoord).rgb;
    // color.rgb = decodeNormal(texture(colortex2, texcoord).rgb);
    // float r = mapRange(texture(colortex9, texcoord).r, 10000.0, 16050.0, 0.0, 1.0);
    // color.rgb = vec3(r);
    // if (int(texture(colortex2, texcoord).a + 0.5) == 10150 - 10000) {
    //     color.rgb = vec3(1.0);
    // } else {
    //     color.rgb = vec3(0.0);
    // }
    // if (isTerrain(texcoord)) {
    //     color.rgb = vec3(1.0);
    // }
}

#endif