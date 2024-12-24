#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/common/screen.glsl"
#include "/lib/common/easing.glsl"
#include "/lib/common/texture.glsl"
#include "/lib/common/rand.glsl"
#include "/lib/atmosphere/cycle.glsl"
#include "/lib/grading/colors.glsl"
#include "/lib/atmosphere/moonstars.glsl"
#include "/lib/atmosphere/ray.glsl"
#include "/lib/geom/geom.glsl"
#include "/lib/atmosphere/sky.glsl"
#include "/lib/atmosphere/clouds.glsl"
#include "/lib/materials/materials.glsl"
#include "/lib/tracing/voxelization.glsl"
#include "/lib/tracing/raytrace.glsl"
#include "/lib/tracing/BRDF.glsl"

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

		// // Voxel Map
		// vec3 dir = getRayDir(texcoord);

		// RayHit hit = voxelTrace(vec3(0.0), dir);

		// if (hit.hit) {
		// 	color.rgb = hit.color.rgb;
		// 	// color.rgb = hit.normal.rgb;
		// }

		// Sky
		// vec3 dir = getRayDir(texcoord);
		// vec3 col = getSkyColor(dir, false, false);

		// float expo = exposure();
		// col = jodieReinhardTonemap(col, expo);
		// col = toLinearSpace(col);
		// color.rgb = col;

		// Illumination
		color = texture(colortex4, texcoord);

		// Noise
		// color.rgb = texture(noisetex, texcoord).rgb;
		// color.rgb = blueNoise(noisetex, gl_FragCoord.xy);

		// Hand
		// vec3 hand = texture(colortex6, texcoord).rgb;
		// color.rgb = hand;
		
		// Distance
		// color.rgb = vec3(linearDepth(texture(depthtex0, texcoord).r));
	#else
		color = texture(colortex0, texcoord);
	#endif
}

#endif