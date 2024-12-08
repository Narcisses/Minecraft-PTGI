#include "/lib/utils.glsl"

#ifdef VSH

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 position;
out vec3 normal;

void main() {
	gl_Position = ftransform();
	position = gl_Vertex.xyz;
	normal = gl_Normal.xyz;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
}

#endif

#ifdef FSH

uniform sampler2D lightmap;
uniform sampler2D gtexture;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 position;
in vec3 normal;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	color *= texture(lightmap, lmcoord);
	if (color.a < 0.5) {
		discard;
	}
	else {
		// Transparent glass problem quick fix but unnatural
		color.a = 1.0;
	}

	color.a *= 0.5;
}

#endif