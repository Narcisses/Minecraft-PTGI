#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/atmosphere/cycle.glsl"
#include "/lib/grading/colors.glsl"
#include "/lib/materials/materials.glsl"

#ifdef VSH

attribute vec4 mc_Entity;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 position;
out vec3 normal;
out vec4 entity;
out vec4 currPosNDC;
out vec4 prevPosNDC;

void main() {
	gl_Position = ftransform();
	position = gl_Vertex.xyz;
	currPosNDC = gbufferProjection * gbufferModelView * vec4(gl_Vertex.xyz, 1.0);
	prevPosNDC = gbufferPreviousProjection * gbufferPreviousModelView * vec4(gl_Vertex.xyz, 1.0);
	normal = gl_Normal.xyz;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	entity = mc_Entity;
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
in vec4 entity;
in vec4 currPosNDC;
in vec4 prevPosNDC;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 positions;
layout(location = 2) out vec4 normals;

void main() {
	color = texture(gtexture, texcoord) * glcolor;

	// Get emission (for glow stone emission)
	vec3 emission = getEmission(entity.x, color.rgb);
	color.rgb += emission;

	color *= texture(lightmap, lmcoord);
	if (color.a < alphaTestRef) {
		discard;
	}

	positions = vec4(position, 1.0);

	// For all foliage and flowers
	if (entity.x < 10000) {
		normals = vec4(encodeNormal(vec3(0.0, 1.0, 0.0)), entity.x);
	} else {
		normals = vec4(encodeNormal(normal), entity.x);
	}
}

#endif