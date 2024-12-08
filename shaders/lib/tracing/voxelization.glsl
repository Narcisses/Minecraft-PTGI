// Define size of voxel map (256*256*256) blocks/pixels
// This texture size is the bottleneck
// More size => more pixels to stored more minecraft blocks
const float VOXEL_MAP_SIZE = 256;

vec2 voxelToTexture(vec3 voxel) {
	// Implementation from: https://blog.balintcsala.com/posts/voxelization/
    vec2 textureSize = vec2(float(shadowMapResolution));
    vec3 range = vec3(VOXEL_MAP_SIZE);

	// Calculate the start of the layer
	vec2 layerPos = vec2(
		// X should increase by range.x each time, but
		// should never go above textureSize.x
		mod(voxel.y * range.x, textureSize.x),
		// y will be as many times range.z, as the layer overflows on the x axis
		floor(voxel.y * range.x / textureSize.x) * range.z
	);

	// We offset the layerPos by the horizontal position
	return layerPos + voxel.xz;
}


bool isVoxelWithinBounds(vec3 voxel) {
    if (voxel.x > 0 && voxel.y > 0 && voxel.z > 0) {
        if (voxel.x < VOXEL_MAP_SIZE && voxel.y < VOXEL_MAP_SIZE && voxel.z < VOXEL_MAP_SIZE) {
            return true;
        }
    }
    return false;
}
