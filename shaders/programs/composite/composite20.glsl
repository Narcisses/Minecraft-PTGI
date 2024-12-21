#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/antialiasing/sharpen.glsl"

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
	#ifdef TAA
		vec3 col = texture2DLod(colortex2, texcoord, 0).rgb;
		SharpenFilter(col, texcoord);
		color = vec4(col, 1.0);
	#else
		color = texture(colortex0, texcoord);
	#endif
}

#endif