// Structure for hit information
struct RayHit {
    bool hit;
    vec4 color;
    vec3 emission;
    vec3 position;
    vec3 normal;
    int blockID;
};

RayHit voxelTrace(vec3 origin, vec3 direction) {
    // Implementation from: https://github.com/coolq1000/vx-simple
    vec3 cameraOffset = fract(cameraPosition);
    origin += cameraOffset;

    ivec3 mapPos = ivec3(floor(origin));
    vec3 deltaDist = abs(vec3(length(direction)) / direction);
    ivec3 rayStep = ivec3(sign(direction));

    vec3 sideDist = (sign(direction) * (vec3(mapPos) - origin) + (sign(direction) * 0.5) + 0.5) * deltaDist;
    bvec3 mask;

    for (int s = 0; s < MAX_STEP; s++) {
        if (s != 0) {
            vec3 centeredVoxel = mapPos + vec3(VX_VOXEL_SIZE / 2.0f);
            vec2 samplePoint = voxelToTexture(centeredVoxel - vec3(1, 0, 1)) / shadowMapResolution;

            if (isVoxelWithinBounds(centeredVoxel) && isWithinTexture(samplePoint)) {
                if (texelFetch(shadow, ivec2(samplePoint * shadowMapResolution), 0).r < 0.8f) {
                    vec4 sampleColour = texelFetch(shadowcolor0, ivec2(samplePoint * shadowMapResolution), 0);
                    vec4 data = texelFetch(shadowcolor1, ivec2(samplePoint * shadowMapResolution), 0);
                    vec3 emission = getRayTracedEmission(data.a);
                    float dist = length(vec3(mask) * (sideDist - deltaDist)) / length(direction);
                    return RayHit(true, sampleColour, emission, (origin + direction * dist) - cameraOffset, vec3(mask) * -sign(direction), int(data.a));
                }
            } else {
                break;
            }
        }
        
        mask = lessThanEqual(sideDist.xyz, min(sideDist.yzx, sideDist.zxy));
        sideDist += vec3(mask) * deltaDist;
        mapPos += ivec3(vec3(mask)) * rayStep;
    }

    return RayHit(false, vec4(0), vec3(0), vec3(0), vec3(0), 0);
}
