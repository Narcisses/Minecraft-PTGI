/* Implementation from https://www.shadertoy.com/view/MdGfzh */
#define CLOUD_MARCH_STEPS 12
#define CLOUD_SELF_SHADOW_STEPS 12

#define EARTH_RADIUS 1500000.0
#define CLOUDS_BOTTOM 1350.0
#define CLOUDS_TOP 2350.0

#define CLOUDS_COVERAGE_DRY 0.52
#define CLOUDS_COVERAGE_WET 0.72

#define CLOUDS_DETAIL_STRENGTH 0.225
#define CLOUDS_BASE_EDGE_SOFTNESS 0.1
#define CLOUDS_BOTTOM_SOFTNESS 0.25
#define CLOUDS_DENSITY 0.35
#define CLOUDS_SHADOW_MARGE_STEP_SIZE 10.0
#define CLOUDS_SHADOW_MARGE_STEP_MULTIPLY 1.3
#define CLOUDS_FORWARD_SCATTERING_G 0.8
#define CLOUDS_BACKWARD_SCATTERING_G -0.2
#define CLOUDS_SCATTERING_LERP 0.5

#define CLOUDS_AMBIENT_COLOR_TOP_DAY vec3(0.87, 0.98, 1.17)
#define CLOUDS_AMBIENT_COLOR_BOTTOM_DAY vec3(0.22, 0.39, 0.51)
#define CLOUDS_AMBIENT_COLOR_TOP_NIGHT vec3(0.0039, 0.0196, 0.0353)
#define CLOUDS_AMBIENT_COLOR_BOTTOM_NIGHT vec3(0.0, 0.0, 0.0)
#define CLOUDS_MIN_TRANSMITTANCE 0.1

#define CLOUDS_BASE_SCALE 1.01
#define CLOUDS_DETAIL_SCALE 16.0

#define CLOUD_SPEED 0.00125

// Cloud shape modelling and rendering 
float HenyeyGreenstein(float sundotrd, float g) {
    float gg = g * g;
    return (1. - gg) / pow(1.0 + gg - 2.0 * g * sundotrd, 1.5);
}

float interectCloudSphere(vec3 rd, float r) {
    float b = EARTH_RADIUS * rd.y;
    float d = b * b + r * r + 2. * EARTH_RADIUS * r;
    return -b + sqrt(d);
}

float linearstep(const float s, const float e, float v) {
    return clamp((v - s) * (1.0 / (e - s)), 0.0, 1.0);
}

float linearstep0(const float e, float v) {
    return min(v * (1.0 / e), 1.0);
}

float remap(float v, float s, float e) {
    return (v - s) / (e - s);
}

float cloudMapBase(vec3 p, float norY) {
    vec3 uv = p * (0.00005 * CLOUDS_BASE_SCALE);

    vec3 cloud = texture(colortex10, mod(uv.xz + vec2(frameTimeCounter * CLOUD_SPEED), vec2(1.0))).rgb;

    float n = norY * norY;
    n *= cloud.b;
    n += pow(1.0 - norY, 16.0);
    return remap(cloud.r - n, cloud.g, 1.0);
}

float cloudMapDetail(vec3 p) { 
    // 3d lookup in 2d texture :(
    p = abs(p) * (0.0016 * CLOUDS_BASE_SCALE * CLOUDS_DETAIL_SCALE);

    float yi = mod(p.y, 32.);
    ivec2 offset = ivec2(mod(yi, 8.), mod(floor(yi / 8.0), 4.0)) * 34 + 1;
    float a = texture(colortex11, (mod(p.xz, 32.) + vec2(offset.xy) + 1.) / iresolution).r;

    yi = mod(p.y + 1., 32.);
    offset = ivec2(mod(yi, 8.0), mod(floor(yi / 8.0), 4.0)) * 34 + 1;
    float b = texture(colortex11, (mod(p.xz, 32.0) + vec2(offset.xy) + 1.0) / iresolution).r;

    return mix(a, b, fract(p.y));
}

float cloudGradient(float norY) {
    return linearstep(0.0, 0.05, norY) - linearstep(0.8, 1.2, norY);
}

float smoothstep(float edge0, float edge1, float x) {
    float t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
}

float cloudMap(vec3 pos, vec3 rd, float norY) {
    vec3 ps = pos;

    float m = cloudMapBase(ps, norY);
    m *= cloudGradient(norY);

    float dstrength = smoothstep(1.0, 0.5, m);

    // erode with detail
    if (dstrength > 0.0) {
        m -= cloudMapDetail(ps) * dstrength * CLOUDS_DETAIL_STRENGTH;
    }

    float cloudsCoverage = mix(CLOUDS_COVERAGE_DRY, CLOUDS_COVERAGE_WET, wetness);

    m = smoothstep(0., CLOUDS_BASE_EDGE_SOFTNESS, m + (cloudsCoverage - 1.));
    m *= linearstep0(CLOUDS_BOTTOM_SOFTNESS, norY);

    return clamp(m * CLOUDS_DENSITY * (1.0 + max((ps.x - 7000.0) * 0.005, 0.0)), 0.0, 1.0);
}

float volumetricShadow(in vec3 from, in float sundotrd) {
    float dd = CLOUDS_SHADOW_MARGE_STEP_SIZE;
    vec3 sunDir = getLightCasterDir();
    vec3 rd = sunDir;
    float d = dd * 0.5;
    float shadow = 1.0;

    for (int s = 0; s < CLOUD_SELF_SHADOW_STEPS; s++) {
        vec3 pos = from + rd * d;
        float norY = (length(pos) - (EARTH_RADIUS + CLOUDS_BOTTOM)) * (1.0 / (CLOUDS_TOP - CLOUDS_BOTTOM));

        if (norY > 1.0)
            return shadow;

        float muE = cloudMap(pos, rd, norY);
        shadow *= exp(-muE * dd);

        dd *= CLOUDS_SHADOW_MARGE_STEP_MULTIPLY;
        d += dd;
    }
    return shadow;
}

vec4 renderClouds(vec3 ro, vec3 rd, inout float dist) {
    ro.y = sqrt(EARTH_RADIUS * EARTH_RADIUS - dot(ro.xz, ro.xz));

    float start = interectCloudSphere(rd, CLOUDS_BOTTOM);
    float end = interectCloudSphere(rd, CLOUDS_TOP);

    vec3 light_color = getLightCasterColor();
    float sunAmount = getSunAmount();
    float cloudClearColorAmount = max(0.0, sunAmount - wetness * 0.33);

    end = min(end, dist);

    vec3 sunDir = getSunDir();
    float sundotrd = dot(rd, -sunDir);

    // raymarch
    float d = start;
    float dD = (end - start) / float(CLOUD_MARCH_STEPS);

    float h = hash13(rd + fract(frameTimeCounter));
    d -= dD * h;

    float scattering = mix(HenyeyGreenstein(sundotrd, CLOUDS_FORWARD_SCATTERING_G), HenyeyGreenstein(sundotrd, CLOUDS_BACKWARD_SCATTERING_G), CLOUDS_SCATTERING_LERP);

    float transmittance = 1.0;
    vec3 scatteredLight = vec3(0.0, 0.0, 0.0);

    dist = EARTH_RADIUS;

    for (int s = 0; s < CLOUD_MARCH_STEPS; s++) {
        vec3 p = ro + d * rd;

        float norY = clamp((length(p) - (EARTH_RADIUS + CLOUDS_BOTTOM)) * (1.0 / (CLOUDS_TOP - CLOUDS_BOTTOM)), 0.0, 1.0);

        float alpha = cloudMap(p, rd, norY);

        if (alpha > 0.0) {
            dist = min(dist, d);
            vec3 cloudColorBottom = mix(CLOUDS_AMBIENT_COLOR_BOTTOM_NIGHT, CLOUDS_AMBIENT_COLOR_BOTTOM_DAY, cloudClearColorAmount);
            vec3 cloudColorTop = mix(CLOUDS_AMBIENT_COLOR_TOP_NIGHT, CLOUDS_AMBIENT_COLOR_TOP_DAY, cloudClearColorAmount);
            vec3 ambientLight = mix(cloudColorTop, cloudColorBottom, norY);

            vec3 S = (ambientLight + light_color * (scattering * volumetricShadow(p, sundotrd))) * alpha;
            float dTrans = exp(-alpha * dD);
            vec3 Sint = (S - S * dTrans) * (1.0 / alpha);
            scatteredLight += transmittance * Sint;
            transmittance *= dTrans;
        }

        if (transmittance <= CLOUDS_MIN_TRANSMITTANCE)
            break;

        d += dD;
    }

    return vec4(scatteredLight, transmittance);
}
