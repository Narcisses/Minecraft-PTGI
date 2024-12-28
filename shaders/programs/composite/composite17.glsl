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

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;
// layout(location = 1) out vec4 prevIllum;
// layout(location = 2) out vec4 prevNormal;
// layout(location = 3) out vec4 prevMoments;
// layout(location = 4) out vec4 prevPositions;

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

    // Final color output to screen before post-processing
	color = vec4(col, 1.0);
}

#endif