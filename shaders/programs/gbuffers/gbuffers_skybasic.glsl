#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"

#ifdef VSH

out vec4 glcolor;

void main() {
	gl_Position = ftransform();
	glcolor = gl_Color;
}

#endif

#ifdef FSH

in vec4 glcolor;

/* RENDERTARGETS: 0,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 normals;

varying vec4 starData;

void main() {
	color = vec4(vec3(-1.0), 1.0);
	normals = vec4(encodeNormal(vec3(0.0)), 1.0);
}


#endif