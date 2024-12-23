#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/common/screen.glsl"
#include "/lib/common/easing.glsl"
#include "/lib/atmosphere/cycle.glsl"
#include "/lib/grading/colors.glsl"
#include "/lib/bloom/bloom.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH

in vec2 texcoord;

/* RENDERTARGETS: 0,5,7,8 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 prevIllum;
layout(location = 2) out vec4 prevNormal;
layout(location = 3) out vec4 prevMoments;

void main() {
    // Final pass for Bloom, Tonemapping, and Gamma correction
	vec3 col = texture(colortex0, texcoord).rgb * getColorRange();

    // Bloom
    col += getBloom(texcoord, colortex15);

    // Color grading
    if (isTerrain(texcoord)) {
        // Apply tint on terrain
        col *= tint();
    }
    
    // Tonemapping & Gamma correction
    float expo = exposure();
    col = jodieReinhardTonemap(col, expo);
    col = toLinearSpace(col);

    // Add hand
    vec3 handColor = texture(colortex6, texcoord).rgb;
	if (handColor.x > 0) {
    	col.rgb = handColor;
	}

    // Final color output to screen
	color = vec4(col, 1.0);

    // Save (previous) screen resolution and time (useful for resolution changes)
    screenData.width = viewWidth;
    screenData.height = viewHeight;
    screenData.worldtime = worldTime;
    screenData.seed = screenData.seed + 1.0;

    // Save (previous) frame data (normal, illumination, depth, position, ...)
    vec4 currIllum = texture(colortex4, texcoord);
    vec4 currNormal = texture(colortex2, texcoord);
    float currDepth = texture(depthtex0, texcoord).r;
    vec3 currMoments = texture(colortex8, texcoord).xyz;

    prevIllum = currIllum; // Illumination + variance
    prevNormal = currNormal; // Normal + mesh ID
    prevMoments = vec4(currMoments, currDepth); // Moments + depth
}

#endif