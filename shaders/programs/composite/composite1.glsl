#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH

in vec2 texcoord;

/* RENDERTARGETS: 0,1 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 positionAndDepth;

void main() {
    color = texture(colortex0, texcoord);

	// Compute depth derivative and save it next to position
	float depth = texture(depthtex0, texcoord).r;
	float depthDerivative = max(abs(dFdx(depth)), abs(dFdy(depth)));
	positionAndDepth = vec4(texture(colortex1, texcoord).xyz, depthDerivative);
}

#endif