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
#include "/lib/mblur/dither.glsl"
#include "/lib/mblur/mblur.glsl"
#include "/lib/antialiasing/jitter.glsl"

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

		// Sky
		// vec3 dir = getRayDir(texcoord);
		// vec3 col = getSkyColor(dir, false, false);

		// float expo = exposure();
		// col = jodieReinhardTonemap(col, expo);
		// col = toLinearSpace(col);
		// color.rgb = col;

		// Illumination
		// color = texture(colortex4, texcoord);

		// Motion blur on illumination
        // float depth = texture(depthtex0, texcoord).r;
        // float dither = Bayer256(gl_FragCoord.xy) + rand(texcoord * frameTimeCounter);
        // vec3 col = motionBlur(colortex4, texcoord, texture(colortex4, texcoord).rgb, depth, dither);
		// color.rgb = col;

		// Noise
		// color.rgb = texture(noisetex, texcoord).rgb;
		// color.rgb = blueNoise(noisetex, gl_FragCoord.xy);

		// Hand
		// vec3 hand = texture(colortex6, texcoord).rgb;
		// color.rgb = hand;
		
		// Distance
		// color.rgb = vec3(linearDepth(texture(depthtex0, texcoord).r));

		// Jitter
		// color.rgb = vec3(newframemod8 - framemod8);
		// color.rgb = vec3(TAAJitter())

		// int f0 = (frameCounter) % 8;
		// int f1 = (frameCounter + 1) % 8;
		// color.rgb = vec3(float(abs(f1 - f0)) / 8.0);

		// Distance
		// color = texture(colortex1, texcoord);
		// color = texture(colortex12, texcoord);

		// color.rgb = vec3(texture(colortex1, texcoord) - texture(colortex12, texcoord));

		// Velocity buffer
		// color.rgb = vec3(texture(colortex3, texcoord).rg * 1000, 0.0);
		// color.rgb = vec3(texture(colortex3, texcoord).rg * 1000, 0.0);
		// color.rgb = vec3(texture(colortex3, texcoord).g * 1000, 0.0, 0.0);
		// color.rgb = vec3(texture(colortex3, texcoord).r * 1000, 0.0, 0.0);

		// Multiplier
		// float depth = linearDepth(texture(depthtex0, texcoord).r);
		// color.rgb = vec3(depth);

		// vec3 position = texture(colortex1, texcoord).xyz;
		// vec3 normal = decodeNormal(texture(gnormal, texcoord).rgb);
		// float id = texture(gnormal, texcoord).a;
		// vec3 dir = getRayDir(texcoord);
		// float alikeness = abs(dot(-dir, normal));

		// // if (alikeness - 0.05 <= 0)
		// // 	alikeness = 0;
		// // else
		// // 	alikeness = 1;

		// // if (id < 10000)
		// // 	alikeness = 1.0;

		// float depth = texture(depthtex0, texcoord).r;
		// // float alikenessDerivative = max(abs(dFdx(alikeness)), abs(dFdy(alikeness)));
		// float alikenessDerivative = max(abs(dFdx(length(position))), abs(dFdy(length(position))));
		// if (alikenessDerivative > 0.50 && linearDepth(depth) < 0.15) // && dot(normal, vec3(0, 1.0, 0)) >= 0.5
		// 	alikenessDerivative = 1.0;
		// else
		// 	alikenessDerivative = 0.0;
		// color.rgb = vec3(alikenessDerivative);

		// float depth = texture(depthtex0, texcoord).r;
		// float depthDerivative = max(abs(dFdx(depth)), abs(dFdy(depth)));

		// color.rgb = vec3(depthDerivative);

		// Fract
		// vec3 dir = getRayDir(texcoord);

		// RayHit hit = voxelTrace(vec3(0.0), dir);

		// if (hit.hit) {
		// 	vec3 withinVoxel = hit.position + fract(cameraPosition) - hit.normal * 0.1;
		// 	vec3 roundedVoxel = floor(withinVoxel) + vec3(0.5);
		// 	float d = distance(hit.position + fract(cameraPosition), roundedVoxel);
		// 	d = clamp(d, 0.0, 1.0);
		// 	d = easeOutCirc(d);
		// 	d = 1.0 - d;
		// 	color.rgb = vec3(d);
		// 	// color.rgb = hit.normal.rgb;
		// }
		// 			
		// color.rgb = position;
	#else
		color = texture(colortex0, texcoord);
	#endif
}

#endif