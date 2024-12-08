#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"

#ifdef VSH

out vec2 lmcoord;
out vec4 glcolor;
out vec3 position;
out vec3 normal;

void main() {
	gl_Position = ftransform();
	position = gl_Vertex.xyz;
	normal = gl_Normal.xyz;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
}

#endif

#ifdef FSH

uniform sampler2D lightmap;

in vec2 lmcoord;
in vec4 glcolor;
in vec3 position;
in vec3 normal;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 positions;
layout(location = 2) out vec4 normals;

void main() {
	color = glcolor * texture(lightmap, lmcoord);
	if (color.a < alphaTestRef) {
		discard;
	}

	positions = vec4(position, 1.0);
	normals = vec4(encodeNormal(vec3(0.0, 1.0, 0.0)), 1.0);
}

#endif