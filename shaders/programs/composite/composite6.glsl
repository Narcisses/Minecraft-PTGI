#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/common/screen.glsl"
#include "/lib/common/easing.glsl"
#include "/lib/common/texture.glsl"
#include "/lib/common/rand.glsl"
#include "/lib/atmosphere/cycle.glsl"
#include "/lib/atmosphere/moonstars.glsl"
#include "/lib/atmosphere/ray.glsl"
#include "/lib/atmosphere/sky.glsl"
#include "/lib/atmosphere/clouds.glsl"
#include "/lib/grading/colors.glsl"
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

/* RENDERTARGETS: 4 */
layout(location = 0) out vec4 rayTracedIllumination;

float getEpsilon(float blockID) {
	// Dirt path
	if(int(blockID + 0.5) == 10429) {
		return 0.1;
	}
	return 0.001;
}

RayHit getPrimaryRay(vec2 uv) {
	vec4 color = vec4(1.0); // Albedo demodulation
	float blockID = decodeID(texelFetch(gnormal, ivec2(gl_FragCoord.xy * RESOLUTION), 0).w);
	vec3 emission = getRayTracedEmission(blockID);
	vec3 normal = decodeNormal(texture(gnormal, uv).rgb);
	vec3 position = texture(colortex1, uv).xyz;

	return RayHit(true, color, emission, position, normal, int(blockID));
}

float radius = 40;

bool hitSphere(vec3 ro, vec3 rd) {
	vec3 center = getSunPosition();

	vec3 oc = ro - center;
	float a = dot(rd, rd);
	float b = 2.0 * dot(oc, rd);
	float c = dot(oc, oc) - radius * radius;
	float discriminant = b * b - 4.0 * a * c;

	return (discriminant > 0.0);
}

vec3 randomSphereDirection(inout float seed) {
	vec2 r = hash2(seed);
	vec2 h = r * vec2(2., 6.28318530718) - vec2(1, 0);
	float phi = h.y;

	return vec3(sqrt(1. - h.x * h.x) * vec2(sin(phi), cos(phi)), h.x);
}

vec3 sampleLight(inout float seed) {
	vec3 n = randomSphereDirection(seed) * radius;
	return getSunPosition() + n;
}

vec3 directLighting(inout float seed, int i, vec3 position, vec3 normal, vec3 color) {
	vec3 outColor;

	// Direct light sampling
	vec3 ld = sampleLight(seed) - position;
	vec3 nld = normalize(ld);
	RayHit lightHit = voxelTrace(position, nld);

	if (!lightHit.hit && i < NB_BOUNCES - 1) {
		vec3 sunPos = getSunPosition();
		float cos_a_max = sqrt(1. - clamp(radius * radius / dot(sunPos.xyz - position, sunPos.xyz - position), 0., 1.));
		float weight = 2. * (1. - cos_a_max);

		vec3 p = nld;
		outColor += (color * getSkyColor(nld, true, true)) * (weight * clamp(dot(nld, normal), 0., 1.));
	}

	return outColor;
}

vec4 pathTrace() {
	// Final color for this frame
	vec3 finalColor = vec3(0.0);
	vec2 uv = texcoord * RESOLUTION;

	for(int j = 0; j < NB_SAMPLES; j++) {
		float time = 981;
		#ifdef TEMPORAL_ACCUMULATION
			time = worldTime;
		#endif
		float seed = uv.x + uv.y * 3.43121412313 + fract(1.12345314312 * time) + j;

		// Color
		vec3 outColor = vec3(0.0); // color with light added
		vec3 color = vec3(1.0); // diffuse color

		RayHit hit;
		vec3 inrd;
		vec3 rd;
		float pdf;
		float epsilon;
		vec3 normal;
		vec3 position;

		for (int i = 0; i < NB_BOUNCES; i++) {
			if (i == 0) {
				// First ray given by rasterizer
				inrd = normalize(getRayDir(uv));
				hit = getPrimaryRay(uv);
				rd = BRDF(hit.normal, seed, pdf);
			} else {
				// Ray trace
				inrd = rd;
				hit = voxelTrace(position, rd);
				rd = BRDF(hit.normal, seed, pdf);
			}

			normal = hit.normal;
			epsilon = getEpsilon(float(hit.blockID));
			position = hit.position + normal * epsilon;

			if (hit.hit) {
				// We hit the terrain
				if (isEmitter(int(hit.blockID + 0.5))) {
					// Block hit emits light
					outColor += color * vec3(1.0);
					break;
				} else {
					// Block diffuse
					color *= (hit.color.rgb / 3.14) / pdf;
				}
			} else {
				// We missed the terrain, so we hit the sky
				outColor += color * getSkyColor(inrd, true, true);
				break;
			}

			// outColor += directLighting(seed, i, position, normal, color);
		}

		finalColor += outColor;
	}

	return vec4(finalColor / NB_SAMPLES, 1.0);
}

void main() {
	// Ray trace all scene but sky and hand
	// Here, only the voxelized objects are taken into account by the ray tracer
	vec2 uv = texcoord;
	if (isTerrain(uv * RESOLUTION) && uv.x <= 1.0 / RESOLUTION && uv.y <= 1.0 / RESOLUTION) { 
		#ifdef RAYTRACE
			rayTracedIllumination = pathTrace();
		#else
			rayTracedIllumination = vec4(1.0);
		#endif
	}
}

#endif