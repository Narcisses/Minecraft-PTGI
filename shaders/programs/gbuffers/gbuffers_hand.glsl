#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/common/motion.glsl"
#include "/lib/antialiasing/jitter.glsl"

#ifdef VSH

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
out vec4 currNDCPos;
out vec4 prevNDCPos;

void main() {
	gl_Position = ftransform();
	#ifdef TAA
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w, false);
	#endif
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
in vec3 normal;
in vec4 currNDCPos;
in vec4 prevNDCPos;

/* RENDERTARGETS: 6 */
// layout(location = 0) out vec4 color;
// layout(location = 1) out vec4 normals;
// layout(location = 2) out vec4 motions;
layout(location = 0) out vec4 handColor;

void main() {
	vec4 col = texture(gtexture, texcoord) * glcolor;
	col *= texture(lightmap, lmcoord);
	if (col.a < alphaTestRef) {
		discard;
	}
	
	// normals = vec4(encodeNormal(vec3(0.0)), 1.0);
	// vec2 velocity = calcVelocity(currNDCPos, prevNDCPos);
	// motions = vec4(vec2(velocity.x, -velocity.y), 0.0, 1.0);
	// color = col;
	// normals = texture(gnormal, texcoord);
	// motions = texture(colortex3, texcoord);
	// color = texture(colortex0, texcoord);
	handColor = col;
}

#endif