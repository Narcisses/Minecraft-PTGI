#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/screen.glsl"
#include "/lib/common/reprojection.glsl"
#include "/lib/antialiasing/taa.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH

in vec2 texcoord;

/* RENDERTARGETS: 0,14,9 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 currFrame;
layout(location = 2) out vec4 pastFrame;

void main() {
    color = texture(colortex0, texcoord);

	#ifdef TAA
		vec3 color = texture2DLod(colortex14, texcoord, 0.0).rgb;
		vec4 prev = temporalAA(texcoord, color, 0.0);

		currFrame = vec4(color, 1.0);
		pastFrame = vec4(prev);
	#else
		currFrame = texture(colortex14, texcoord);
	#endif
}

#endif