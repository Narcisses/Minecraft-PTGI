#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/common/texture.glsl"
#include "/lib/common/screen.glsl"
#include "/lib/atmosphere/cycle.glsl"
#include "/lib/grading/colors.glsl"
#include "/lib/filtering/svgf.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH

in vec2 texcoord;

/* RENDERTARGETS: 0,4 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 foutput;

void main() {
	color = texture(colortex0, texcoord);

	#ifdef FILTER_4
    	foutput = spatialFilter(colortex4, texcoord, 8);
	#else
    	foutput = texture(colortex4, texcoord);
	#endif
}

#endif