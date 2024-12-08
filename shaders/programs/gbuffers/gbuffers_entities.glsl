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

in vec2 mc_Entity;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 position;
in vec3 normal;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 positions;
layout(location = 2) out vec4 normals;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	color *= texture(lightmap, lmcoord);
	if (color.a < alphaTestRef) {
		discard;
	}

	positions = vec4(position, 1.0);
	normals = vec4(encodeNormal(vec3(normal)), mc_Entity.x); // normal vec3(0.0, 1.0, 0.0)
}

#endif