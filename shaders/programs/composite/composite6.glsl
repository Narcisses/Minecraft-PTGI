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
#include "/lib/geom/geom.glsl"
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

vec3 randomSphereDirection(inout float seed) {
	vec2 r = hash2(seed);
	vec2 h = r * vec2(2., 6.28318530718) - vec2(1, 0);
	float phi = h.y;

	return vec3(sqrt(1. - h.x * h.x) * vec2(sin(phi), cos(phi)), h.x);
}

vec3 sampleLight(inout float seed, float radius) {
	vec3 n = randomSphereDirection(seed) * radius;
	return getSunPosition() + n;
}

vec3 directLighting(inout float seed, int i, vec3 position, vec3 normal, vec3 color) {
	float radius = 40;
	vec3 outColor;

	// Direct light sampling
	vec3 ld = sampleLight(seed, radius) - position;
	vec3 nld = normalize(ld);
	RayHit lightHit = voxelTrace(position, nld);

	if (!lightHit.hit && i < NB_BOUNCES - 1) {
		vec3 sunPos = getSunPosition();
		float cos_a_max = sqrt(1. - clamp(radius * radius / dot(sunPos.xyz - position, sunPos.xyz - position), 0., 1.));
		float weight = 2. * (1. - cos_a_max);
		outColor += (color * getSkyColor(nld, true, true)) * (weight * clamp(dot(nld, normal), 0., 1.));// / (2.0 * 3.14);
	}

	return outColor;
}

float computeAmbientLight(vec2 uv) {
	// Day / night
	float dayAmbient = 0.125;
	float nightAmbient = 0.005;
	
	// Inside / outside
	float maxAmbientLight = 1.285;
	float minAmbientLight = 1.035;

	// Time and brightness
	float timeOfDayAmbientLight = mix(dayAmbient, nightAmbient, getNightAmount2());
	float brightnessAmbientLight = mix(minAmbientLight, maxAmbientLight, getMaxBrightness());

	// Sides of screen ambient light
	float minAmbientLightAtSide = 1.0;
	float maxAmbientLightAtSide = 1.3;
	float xlength = 0.2;
	float x;
	if (uv.x < 0.5) {
		x = mix(1.0, 0.0, uv.x / xlength);
	} else {
		x = mix(0.0, 1.0, (uv.x - (1.0 - xlength)) / xlength);
	}
	float ambientAtSide = mix(minAmbientLightAtSide, maxAmbientLightAtSide, x);

	// Faraway light
	float minFaraway = 1.0;
	float maxFaraway = 1.5;
	float farawayAmbientLight = mix(minFaraway, maxFaraway, linearDepth(texture(depthtex0, uv).r));

	// Ambient light
	float ambientLight = timeOfDayAmbientLight * brightnessAmbientLight * max(1.0, ambientAtSide);//+ farawayAmbientLight;

	return ambientLight;
}

vec4 pathTrace() {
	// Final color for this frame
	vec2 uv = texcoord * RESOLUTION;
	vec3 finalColor = vec3(computeAmbientLight(uv));

	float time = 981;
	#ifdef TEMPORAL_ACCUMULATION
		time = worldTime;
	#endif
	float seed = uv.x + uv.y * 3.43121412313 + fract(1.12345314312 * time);

	for (int j = 0; j < NB_SAMPLES; j++) {
		// Color
		vec3 outColor = vec3(0); // color with light added
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
				inrd = getRayDir(uv);
				hit = getPrimaryRay(uv);
			} else {
				// Ray trace
				inrd = rd;
				hit = voxelTrace(position, rd);
			}

			normal = hit.normal;
			epsilon = getEpsilon(float(hit.blockID));
			position = hit.position + normal * epsilon;
			rd = BRDF(normal, seed, pdf);

			if (hit.hit) {
				// We hit the terrain
				if (isEmitter(int(hit.blockID + 0.5))) {
					// Block hit emits light
					outColor += (hit.color.rgb / (2.0 * 3.14)) * getRayTracedEmission(hit.blockID);
					// break;
				} else {
					// Block diffuse
					color *= (hit.color.rgb / (2.0 * 3.14)) * max(1e-7, abs(dot(normal, rd)) / pdf);
				}
			} else {
				// We missed the terrain, so we hit the sky
				outColor += color * getSkyColor(inrd, true, true);
				break;
			}

			// NEE
			outColor += directLighting(seed, i, position, normal, color);
		}

		finalColor += outColor;

		// Modify seed
        seed = mod(seed * 1.1234567893490423, 13.0);
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