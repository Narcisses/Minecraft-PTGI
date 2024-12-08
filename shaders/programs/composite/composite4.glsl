#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
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

/* RENDERTARGETS: 0,14 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 bloomTexture;

void main() {
    color = texture(colortex0, texcoord);

    // Bloom texture (keep only bright pixels in it)
    // i.e. remove all non-emissive fragments (for later blur)
    bloomTexture = max(vec4(0.0), color - vec4(1.0));
    color.rgb = toGammaSpace(color.rgb);
}

#endif