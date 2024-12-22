vec3 randomDirectionOnHemisphere(vec3 normal, inout float seed) {
	// Implementation from: https://columbusutrigas.com/posts/rtgi/
    // For a random diffuse bounce direction, we follow the approach of
    // Ray Tracing in One Weekend, and generate a random point on a sphere
    // of radius 1 centered at the normal. This uses the random_unit_vector
    // function from chapter 8.5:   

    vec2 xi = hash2(seed);
    float theta = 6.2831853 * xi.x;  // Random in [0, 2pi]
    float u = 2.0 * xi.y - 1.0;  // Random in [-1, 1]
    float r = sqrt(1.0 - u * u);
    vec3 direction = normal + vec3(r * cos(theta), r * sin(theta), u);

    return normalize(direction);
}

// vec3 cosWeightedRandomHemisphereDirection(const vec3 n, inout float seed) {
//     vec2 r = hash2(seed);

//     vec3 uu = normalize(cross(n, vec3(0.0, 1.0, 1.0)));
//     vec3 vv = cross(uu, n);

//     float ra = sqrt(r.y);
//     float rx = ra * cos(6.2831 * r.x);
//     float ry = ra * sin(6.2831 * r.x);
//     float rz = sqrt(1.0 - r.y);
//     vec3 rr = vec3(rx * uu + ry * vv + rz * n);

//     return normalize(rr);
// }

vec3 cosineSampleHemisphere(vec3 n, inout float seed) {
    vec2 u = hash2(seed);

    float r = sqrt(u.x);
    float theta = 2.0 * 3.14 * u.y;

    vec3 B = normalize(cross(n, vec3(0.0, 1.0, 1.0)));
    vec3 T = cross(B, n);

    return normalize(r * sin(theta) * B + sqrt(1.0 - u.x) * n + r * cos(theta) * T);
}

vec3 BRDF(vec3 normal, inout float seed, inout float pdf) {
    // vec3 rd = randomDirectionOnHemisphere(normal, seed);
    // pdf = (1.0 / 2.0 * 3.14);

    vec3 rd;
    if (false) {
        rd = randomDirectionOnHemisphere(normal, seed);
        pdf = (1.0 / 2.0 * 3.14);
    } else {
        rd = cosineSampleHemisphere(normal, seed);
        pdf = dot(normal, rd) / 3.14;
    }

    return rd;
}
