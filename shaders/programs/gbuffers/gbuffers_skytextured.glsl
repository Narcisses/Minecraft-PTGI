#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/common/reprojection.glsl"
#include "/lib/antialiasing/jitter.glsl"

#ifdef VSH

out vec2 texcoord;
out vec4 glcolor;
out vec3 position;
out vec4 currNDCPos;
out vec4 prevNDCPos;

void main() {
	gl_Position = ftransform();
	#ifdef TAA
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w, false);
	#endif
	position = gl_Vertex.xyz;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
	vec3 camOff = previousCameraPosition - cameraPosition;
	currNDCPos = gbufferProjection * gbufferModelView * (vec4(camOff, 0.0) + gl_Vertex);
	prevNDCPos = gbufferPreviousProjection * gbufferPreviousModelView * gl_Vertex;
}

#endif

#ifdef FSH

uniform sampler2D gtexture;

in vec2 texcoord;
in vec4 glcolor;
in vec3 position;
in vec4 currNDCPos;
in vec4 prevNDCPos;

/* RENDERTARGETS: 0,3 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 motions;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	if (color.a < alphaTestRef) {
		discard;
	}

	// Remove moon halo
	float L = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
	if (L < 0.1) {
		discard;
	}
	
	vec2 velocity = calcVelocity(currNDCPos, prevNDCPos);
	motions = vec4(vec2(velocity.x, -velocity.y), 0.0, 1.0);
}

#endif