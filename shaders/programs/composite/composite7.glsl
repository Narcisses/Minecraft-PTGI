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

/* RENDERTARGETS: 4 */
layout(location = 0) out vec4 rayTracedIllumination;

void main() {
	// Upscale GI texture
	rayTracedIllumination = texture(colortex4, texcoord / RESOLUTION);
}

#endif