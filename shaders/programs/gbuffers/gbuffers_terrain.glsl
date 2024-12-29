#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/common/reprojection.glsl"
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

vec4 wavingVegetation(vec4 position, float blockID) {
	// Make vegetation (except tree leaves) move in the wind
	// Implementation from: https://www.9minecraft.net/waving-plants-shaders-mod/
	float pi = 3.14;
	float tick = frameTimeCounter;

	float grassWeight = mod(texcoord.t * 16.0f, 1.0f / 16.0f);

	if (grassWeight < 0.01f) {
	  	grassWeight = 1.0f;
	} else {
	  	grassWeight = 0.0f;
	}

	if (int(blockID + 0.5) < 10000) {
		float speed = 0.1;
		
		float magnitude = sin((tick * pi / (28.0)) + position.x + position.z) * 0.22 + 0.02;
		magnitude *= grassWeight * 0.2f;
		float d0 = sin(tick * pi / (122.0 * speed)) * 3.0 - 1.5 + position.z;
		float d1 = sin(tick * pi / (152.0 * speed)) * 3.0 - 1.5 + position.x;
		float d2 = sin(tick * pi / (122.0 * speed)) * 3.0 - 1.5 + position.x;
		float d3 = sin(tick * pi / (152.0 * speed)) * 3.0 - 1.5 + position.z;
		position.x += sin((tick * pi / (28.0 * speed)) + (position.x + d0) * 0.1 + (position.z + d1) * 0.1) * magnitude;
		position.z += sin((tick * pi / (28.0 * speed)) + (position.z + d2) * 0.1 + (position.x + d3) * 0.1) * magnitude;
	}

	return position;
}

void main() {
	// gl_Position = ftransform();
	vec4 modelPosition = gl_Vertex.xyzw;
	position = gl_Vertex.xyz;
	normal = gl_Normal.xyz;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	blockID = int(mc_Entity.x);
	vec3 camOff = previousCameraPosition - cameraPosition;
	currNDCPos = gbufferProjection * gbufferModelView * (vec4(camOff, 0.0) + gl_Vertex);
	prevNDCPos = gbufferPreviousProjection * gbufferPreviousModelView * gl_Vertex;
	modelPosition = wavingVegetation(modelPosition, mc_Entity.x);
	gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * modelPosition);
	#ifdef TAA
		vec2 nJitteredPos = TAAJitter(gl_Position.xy, gl_Position.w, false);
		vec2 pJitteredPos = TAAJitter(prevNDCPos.xy, prevNDCPos.w, true);
		newJitteredPos = nJitteredPos - gl_Position.xy;
		prevJitteredPos = pJitteredPos - prevNDCPos.xy;
		gl_Position.xy = nJitteredPos.xy;
	#else
		newJitteredPos = vec2(0);
		prevJitteredPos = vec2(0);
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
	color.rgb += emission;

	color *= texture(lightmap, lmcoord);
	if (color.a < alphaTestRef) {
		discard;
	}

	positions = vec4(position, 1.0);

	// For all foliage and flowers
	if (blockID < 10000) {
		normals = vec4(encodeNormal(vec3(0.0, 1.0, 0.0)), encodeID(blockID));
	} else {
		normals = vec4(encodeNormal(normal), encodeID(blockID));
	}

	vec4 cNDCPos = currNDCPos;
	vec4 pNDCPos = prevNDCPos;

	cNDCPos.xy += newJitteredPos;// / cNDCPos.w;
	pNDCPos.xy += prevJitteredPos;// / cNDCPos.w;

	vec2 velocity = calcVelocity(cNDCPos, pNDCPos);
	velocity = vec2(velocity.x, -velocity.y);
	motions = vec4(velocity, 0.0, 1.0);
}

#endif