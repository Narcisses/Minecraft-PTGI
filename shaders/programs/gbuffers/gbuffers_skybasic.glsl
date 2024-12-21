#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/common/motion.glsl"
#include "/lib/antialiasing/jitter.glsl"

#ifdef VSH

out vec4 glcolor;
out vec4 currNDCPos;
out vec4 prevNDCPos;

void main() {
	gl_Position = ftransform();
	#ifdef TAA
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif
	glcolor = gl_Color;
	vec3 camOff = previousCameraPosition - cameraPosition;
	currNDCPos = gbufferProjection * gbufferModelView * (vec4(camOff, 0.0) + gl_Vertex);
	prevNDCPos = gbufferPreviousProjection * gbufferPreviousModelView * gl_Vertex;
}

#endif

#ifdef FSH

in vec4 glcolor;
in vec4 currNDCPos;
in vec4 prevNDCPos;

/* RENDERTARGETS: 0,2,3 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 normals;
layout(location = 2) out vec4 motions;

varying vec4 starData;

void main() {
	color = vec4(vec3(-1.0), 1.0);
	normals = vec4(encodeNormal(vec3(0.0)), 1.0);
	
	vec2 velocity = calcVelocity(currNDCPos, prevNDCPos);
	motions = vec4(vec2(velocity.x, -velocity.y), 0.0, 1.0);
}


#endif