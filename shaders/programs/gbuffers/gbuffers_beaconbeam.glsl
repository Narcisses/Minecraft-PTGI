#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"

#ifdef VSH

out vec2 texcoord;
out vec4 glcolor;
out vec3 position;

void main() {
	gl_Position = ftransform();
	position = gl_Vertex.xyz;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
}

#endif

#ifdef FSH

uniform sampler2D gtexture;

in vec2 texcoord;
in vec4 glcolor;
in vec3 position;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	if (color.a < alphaTestRef) {
		discard;
	}

	// depth = vec4(position, 1.0);
}

#endif