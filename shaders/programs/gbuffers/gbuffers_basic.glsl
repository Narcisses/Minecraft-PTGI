#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/common/motion.glsl"
#include "/lib/antialiasing/jitter.glsl"

#ifdef VSH

out vec2 lmcoord;
out vec4 glcolor;
out vec3 position;
out vec3 normal;
out vec4 currNDCPos;
out vec4 prevNDCPos;

void main() {
	gl_Position = ftransform();
	#ifdef TAA
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif
	position = gl_Vertex.xyz;
	normal = gl_Normal.xyz;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	vec3 camOff = previousCameraPosition - cameraPosition;
	currNDCPos = gbufferProjection * gbufferModelView * (vec4(camOff, 0.0) + gl_Vertex);
	prevNDCPos = gbufferPreviousProjection * gbufferPreviousModelView * gl_Vertex;
}

#endif

#ifdef FSH

uniform sampler2D lightmap;

in vec2 lmcoord;
in vec4 glcolor;
in vec3 position;
in vec3 normal;
in vec4 currNDCPos;
in vec4 prevNDCPos;

/* RENDERTARGETS: 0,1,2,3 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 positions;
layout(location = 2) out vec4 normals;
layout(location = 3) out vec4 motions;

void main() {
	color = glcolor * texture(lightmap, lmcoord);
	if (color.a < alphaTestRef) {
		discard;
	}

	positions = vec4(position, 1.0);
	normals = vec4(encodeNormal(vec3(0.0, 1.0, 0.0)), 1.0);
	
	vec2 velocity = calcVelocity(currNDCPos, prevNDCPos);
	motions = vec4(vec2(velocity.x, -velocity.y), 0.0, 1.0);
}

#endif