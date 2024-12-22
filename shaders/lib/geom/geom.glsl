bool hitSphere(vec3 center, float radius, vec3 ro, vec3 rd) {
	vec3 oc = ro - center;
	float a = dot(rd, rd);
	float b = 2.0 * dot(oc, rd);
	float c = dot(oc, oc) - radius * radius;
	float discriminant = b * b - 4.0 * a * c;

	return discriminant > 0.0;
}