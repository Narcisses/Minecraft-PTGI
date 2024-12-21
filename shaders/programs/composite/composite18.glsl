#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH

in vec2 texcoord;

/* RENDERTARGETS: 0,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 currFrameData;

void main() {
    color = texture(colortex0, texcoord);

	// TAA
	#ifdef TAA
		currFrameData = texture2D(colortex0, texcoord);
	#else
		currFrameData = texture(gnormal, texcoord);
	#endif
}

#endif