#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/common/reprojection.glsl"
#include "/lib/antialiasing/jitter.glsl"

#ifdef VSH

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 position;
out vec3 normal;
out vec4 currNDCPos;
out vec4 prevNDCPos;

void main() {
	gl_Position = ftransform();
	#ifdef TAA
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w, false);
	#endif
	position = gl_Vertex.xyz;
	normal = gl_Normal.xyz;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	vec3 camOff = previousCameraPosition - cameraPosition;
	currNDCPos = gbufferProjection * gbufferModelView * (vec4(camOff, 0.0) + gl_Vertex);
	prevNDCPos = gbufferPreviousProjection * gbufferPreviousModelView * gl_Vertex;
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
in vec4 currNDCPos;
in vec4 prevNDCPos;

/* RENDERTARGETS: 0 */ //,3,6,12
layout(location = 0) out vec4 color;
// layout(location = 1) out vec4 motions;
// layout(location = 2) out vec4 positions;
// layout(location = 3) out vec4 normals;

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

	color.a *= 0.30;

	// positions = vec4(positions, 1.0),
	// normals = vec4(encodeNormal(normal), encodeID(blockID));
	
	// vec2 velocity = calcVelocity(currNDCPos, prevNDCPos);
	// motions = vec4(vec2(velocity.x, -velocity.y), 0.0, 1.0);
}

#endif