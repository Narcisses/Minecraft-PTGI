#include "/lib/utils.glsl"

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

float rand(vec2 co) {
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt = dot(co.xy ,vec2(a,b));
    float sn = mod(dt,3.14);

    return fract(sin(sn) * c);
}

vec2 rand2D(vec2 texcoord) {
	float x0 = rand(texcoord.xy * (float(worldTime) + 1.0) * screenData.seed);
	float x1 = rand((texcoord.yx + 1.0) * (float(worldTime + 1.0)) * screenData.seed);

	return vec2(x0, x1);
}

float getEpsilon(float blockID) {
	float l[1] = float[1](10124);

	// Check for special blocks (e.g. dirt path)
	for (int i = 0; i < 1; i++) {
		if (abs(l[i] - blockID) < 0.99) {
			return EPSILON_2;
		}
	}

	// Stairs-like blocks
	if (blockID >= 15000 && blockID <= 16000) {
		return EPSILON_3;
	}

	// Normal block
	return EPSILON;
}

vec3 randomDirectionOnHemisphere(vec2 xi, vec3 normal) {
	// Implementation from: https://columbusutrigas.com/posts/rtgi/
    // For a random diffuse bounce direction, we follow the approach of
    // Ray Tracing in One Weekend, and generate a random point on a sphere
    // of radius 1 centered at the normal. This uses the random_unit_vector
    // function from chapter 8.5:
    float theta    = 6.2831853 * xi.x;  // Random in [0, 2pi]
    float u        = 2.0 * xi.y - 1.0;  // Random in [-1, 1]
    float r        = sqrt(1.0 - u * u);
    vec3 direction = normal + vec3(r * cos(theta), r * sin(theta), u);
    return normalize(direction);
}

vec3 brdf(vec2 texcoord, vec3 normal, float seed) {
	vec2 uv = rand2D(texcoord);
	return randomDirectionOnHemisphere(uv, normal);
}

vec3 biasedBRDF(vec2 texcoord, vec3 normal) {
	vec2 randUV = rand2D(texcoord);
	vec3 randDir = randomDirectionOnHemisphere(randUV, normal);
	vec3 lightDir = getLightCasterDir();
	vec3 biasedDir = mix(randDir, lightDir, 0.35);

	return normalize(biasedDir);
}

vec3 directLighting(vec2 texcoord, vec3 ro, vec3 n) {
	vec3 dir = biasedBRDF(texcoord, n);
	RayHit hit = voxelTrace(ro, dir);

	if (!hit.hit) {
		return getSkyColor(dir, true);
	}

	return vec3(0.0);
}

vec3 indirectLighting(vec2 texcoord, vec3 ro, vec3 n) { //vec2 texcoord, vec3 ro, vec3 n
	float seed = texcoord.x + texcoord.y * 3.43121412313 + fract(1.12345314312 * worldTime);
	vec3 unbiased = brdf(texcoord, n, seed);

	RayHit firstHit = voxelTrace(ro, unbiased);

	if (!firstHit.hit) {
		return getSkyColor(unbiased, true);
	} else {
		vec3 biased = biasedBRDF(texcoord, firstHit.normal);
		float epsilon = getEpsilon(firstHit.blockID);
		vec3 nudgedPos = firstHit.position + firstHit.normal * epsilon;
		RayHit secondHit = voxelTrace(nudgedPos, biased);

		if (!secondHit.hit) {
			return vec3(0.0);//getSkyColor(biased, true);
		} else {
			float dist = length(secondHit.position - firstHit.position);

			// AO
			float amountAO = 0.0;
			int n = 4;
			int acc = 0;
			for (int i = 0; i < n; i++) {
				vec3 lightDir = getLightCasterDir();
				vec3 d = brdf(texcoord, secondHit.normal, seed);
				d = normalize(mix(lightDir, d, 0.5));
				RayHit hit = voxelTrace(nudgedPos, d);

				if (hit.hit) {
					acc += 1;
				}
			}

			amountAO = 1.0 - acc / n;

			return secondHit.color.rgb * firstHit.color.rgb * amountAO * clamp(dist, 0.0, 4.0);
		}
	}

	return vec3(0.0);
}

// vec4 pathTrace() {
// 	vec3 accumulated = vec3(0.0);

// 	vec2 uv = texcoord * RESOLUTION;

// 	// Primary ray
// 	vec3 color = vec3(1.0); // Albedo demodulation
// 	float blockID = texture(gnormal, uv).w;
// 	vec3 normal = decodeNormal(texture(gnormal, uv).rgb);
// 	vec3 position = texture(colortex1, uv).rgb;
// 	float depth = texture(depthtex0, uv).r;
// 	vec3 dir = getRayDir(uv);
// 	float epsilon = getEpsilon(blockID);

// 	// vec3 nudgedPos = position + normal * epsilon;
// 	float e = 1.0;

// 	if (depth > 0.0) {
// 		accumulated += directLighting(uv, position, normal);

// 		if (length(accumulated) < e) {
// 			accumulated += indirectLighting(uv, position, normal); //uv, nudgedPos, normal
// 		}
// 	}

// 	return vec4(accumulated, 1.0);
// }


vec4 pathTrace() {
	// Final color for this frame
	vec3 finalColor = vec3(0.0);
	vec2 uv = texcoord * RESOLUTION;
	float seed = uv.x + uv.y * 3.43121412313 + fract(1.12345314312 * worldTime);

	for (int j = 0; j < NB_SAMPLES; j++) {
		// Primary ray
		vec3 color = vec3(1.0); // Albedo demodulation
		float blockID = texture(gnormal, uv).w;
		vec3 normal = decodeNormal(texture(gnormal, uv).rgb);
		vec3 position = texture(colortex1, uv).rgb;
		vec3 dir = getRayDir(uv);
		float epsilon = getEpsilon(blockID);

		int i;
		// First bounce: Block is not an emitter, can ray trace scene
		dir = brdf(uv, normal, seed);

		// Trace scene
		for (i = 0; i < NB_BOUNCES; i++) {
			vec3 nudgedPos = position + normal * epsilon;
			RayHit hit = voxelTrace(nudgedPos, dir);

			if (hit.hit) {
				// Hit light (glowstone, ...), then stop tracing
				if (isEmitter(int(hit.blockID + 0.5))) {
					color *= hit.color.rgb * hit.emission.rgb;
					break;
				}

				// Continue tracing
				epsilon = getEpsilon(hit.blockID);
				color *= (hit.color.rgb + hit.emission.rgb);
				position = hit.position;
				normal = hit.normal.rgb;

				dir = brdf(uv, normal, seed);
			} else {
				// Sample sky, samle sly and stop tracing
				color *= getSkyColor(dir, true);
				break;
			}
		}

		if (i == NB_BOUNCES) {
			// Assume contribution too small
			color = vec3(0.0);
		}

		finalColor += color;
	}

	finalColor = max(vec3(0.0), finalColor);
	return vec4(finalColor / NB_SAMPLES, 1.0);
}

void main() {
	// Ray trace all scene but sky and hand
	// Here, only the voxelized objects are taken into account by the ray tracer
	vec2 uv = texcoord * RESOLUTION;
	if (isTerrain(uv) && gl_FragCoord.x <= viewWidth / RESOLUTION && gl_FragCoord.y <= viewHeight / RESOLUTION) {
		rayTracedIllumination = pathTrace();
	}
}

#endif