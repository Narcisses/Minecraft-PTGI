#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/common/screen.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	// #define DEBUG
	#ifdef DEBUG
		// // Positions
		// color = texture(colortex1, texcoord);

		// Normals
		// color.rgb = decodeNormal(texture(gnormal, texcoord).rgb);

		// // // Voxel Map
		// vec3 dir = getRayDir(texcoord);

		// RayHit hit = voxelTrace(vec3(0.0), dir);

		// if (hit.hit) {
		// 	color.rgb = hit.color.rgb;
		// 	// color.rgb = hit.normal.rgb;
		// }

		// Block ID
		// color.rgb = vec3(texture(gnormal, texcoord).a);
	#else
		color = texture(colortex0, texcoord);
	#endif
}

#endif