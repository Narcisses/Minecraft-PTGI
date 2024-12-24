#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/common/motion.glsl"
#include "/lib/atmosphere/cycle.glsl"
#include "/lib/grading/colors.glsl"
#include "/lib/materials/materials.glsl"
#include "/lib/antialiasing/jitter.glsl"

#ifdef VSH

attribute vec4 mc_Entity;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 position;
out vec3 normal;
flat out int blockID;
out vec4 currNDCPos;
out vec4 prevNDCPos;
out vec2 newJitteredPos;
out vec2 prevJitteredPos;

void main() {
	gl_Position = ftransform();
	position = gl_Vertex.xyz;
	normal = gl_Normal.xyz;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	blockID = int(mc_Entity.x);
	vec3 camOff = previousCameraPosition - cameraPosition;
	currNDCPos = gbufferProjection * gbufferModelView * (vec4(camOff, 0.0) + gl_Vertex);
	prevNDCPos = gbufferPreviousProjection * gbufferPreviousModelView * gl_Vertex;
	#ifdef TAA
		newJitteredPos = TAAJitter(gl_Position.xy, gl_Position.w);
		prevJitteredPos = TAAJitterOld(prevNDCPos.xy, prevNDCPos.w);
		gl_Position.xy = newJitteredPos;
	#else
		newJitteredPos = vec2(0.0);
		prevJitteredPos = vec2(0.0);
	#endif
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
flat in int blockID;
in vec4 currNDCPos;
in vec4 prevNDCPos;
in vec2 newJitteredPos;
in vec2 prevJitteredPos;

/* RENDERTARGETS: 0,1,2,3 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 positions;
layout(location = 2) out vec4 normals;
layout(location = 3) out vec4 motions;

void main() {
	color = texture(gtexture, texcoord) * glcolor;

	// Get emission (for glow stone emission)
	vec3 emission = getEmission(blockID, color.rgb);
	// color.rgb += emission;

	color *= texture(lightmap, lmcoord);
	if(color.a < alphaTestRef) {
		discard;
	}

	positions = vec4(position, 1.0);

	// For all foliage and flowers
	if (blockID < 10000) {
		normals = vec4(encodeNormal(vec3(0.0, 1.0, 0.0)), encodeID(blockID));
	} else {
		normals = vec4(encodeNormal(normal), encodeID(blockID));
	}

	vec2 velocity = calcVelocity(currNDCPos, prevNDCPos); // + jitterVelocity;
	motions = vec4(vec2(velocity.x, -velocity.y), 0.0, 1.0);
}

#endif