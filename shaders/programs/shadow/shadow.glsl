#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/tracing/voxelization.glsl"

#ifdef VSH

attribute vec4 mc_Entity;

out vec3 position;
out vec3 normal;
out vec4 color;
out vec2 texcoord;
out vec4 entity;

void main() {
    position = gl_Vertex.xyz;
    normal = gl_Normal;
    color = gl_Color;
    texcoord = gl_MultiTexCoord0.xy;
    entity = mc_Entity;
}

#endif

#ifdef GSH

uniform sampler2D tex;

layout(triangles) in;
layout(points, max_vertices = 1) out;

in vec3 position[];
in vec3 normal[];
in vec4 color[];
in vec2 texcoord[];
in vec4 entity[];

out vec4 colorOut;
out float blockIDOut;

bool isVoxelizable(int blockID) {
    return !(blockID < 10000 || (blockID >= 12000 && blockID < 13000) || (blockID >= 15000 && blockID < 15500));
}

void main() {
    // Implementation from: https://github.com/coolq1000/vx-simple
    // Slighly modified version that uses more voxels, but the core principles are the same
    // Check if entity is voxelizable (if we have a solid black)
    // List of available blocks to voxelization in blocks.properties file
    int blockID = int(entity[0].x + 0.5);

    if (isVoxelizable(blockID)) {
        // Compute center of voxel using the normals
        // To find the center of the block/voxel
        vec3 triNormal = normalize(cross(position[1] - position[0], position[2] - position[0]));
        vec3 triCentroid = (position[0] + position[1] + position[2]) / 3.0;
        vec3 withinVoxel = triCentroid + fract(cameraPosition) - triNormal * 0.1;
        vec3 roundedVoxel = floor(withinVoxel);
        vec3 centeredVoxel = roundedVoxel + vec3(VOXEL_MAP_SIZE) / 2.0; // (x, y, z) between [-128, 128]

        // If voxel within our range, add it to voxel map (because voxel map is limited is size)
        // Our range is limited but the texture size/resolution
        if (isVoxelWithinBounds(centeredVoxel)) {
            vec2 uv = voxelToTexture(centeredVoxel) / vec2(shadowMapResolution); // [0;1]
            vec2 vw = uv * vec2(2.0) - vec2(1.0); // [-1;1]
            gl_Position = vec4(vw, 0.0, 1.0); // Output position in shadow map (coversion back to 0.0;1.0) automatic
        
            // Output the average color of the block in voxel map
            vec2 texcoord = (texcoord[0] + texcoord[1] + texcoord[2]) / 3.0;
            colorOut = ((color[0] + color[1] + color[2]) / 3.0) * texture2D(tex, texcoord);
            blockIDOut = float(blockID);
            // Only emit one vertex which is center of block/voxel
            // Discard the other vertices of the block
            EmitVertex();
            EndPrimitive();
        }
    }
}

#endif

#ifdef FSH

in vec4 colorOut;
in float blockIDOut;

void main() {
    // Write to shadow map voxel block avarage color
    // Computed from the geometry shader
    gl_FragData[0] = colorOut;
    gl_FragData[1] = vec4(vec3(0.0), blockIDOut);
}

#endif