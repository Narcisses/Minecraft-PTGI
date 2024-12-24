#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/rand.glsl"
#include "/lib/mblur/dither.glsl"
#include "/lib/mblur/mblur.glsl"

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

void main() {
	color = texture(colortex0, texcoord);

	// Motion blur
	float depth = texture(depthtex0, texcoord).r;
    float dither = Bayer64(gl_FragCoord.xy) + rand(texcoord * frameTimeCounter);
	vec3 col = motionBlur(colortex0, texcoord, color.rgb, depth, dither);
	color.rgb = col;
}

#endif