#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/screen.glsl"
#include "/lib/common/easing.glsl"
#include "/lib/atmosphere/cloudnoise.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH

in vec2 texcoord;

/* RENDERTARGETS: 0,10,11 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 voronoiColor;
layout(location = 2) out vec4 worleyNoiseColor;

void main() {
    color = texture(colortex0, texcoord);

    if (isFirstFrame() || hasResolutionChanged()) {
		// Create and save voronoi pattern in texture target
        // So it is only computed once and does not change
        vec2 vUV = texcoord;
        vec3 coord = fract(vec3(vUV + vec2(0.2, 0.62), 0.5));

        vec4 col = vec4(1);

        float mfbm = 0.9;
        float mvor = 0.7;

        col.r = mix(1.0, tilableFbm(coord, 7, 4.0), mfbm) *
            mix(1.0, tilableVoronoi(coord, 8, 9.0), mvor);
        col.g = 0.625 * tilableVoronoi(coord + 0.0, 3, 15.0) +
            0.250 * tilableVoronoi(coord + 0.0, 3, 19.0) +
            0.125 * tilableVoronoi(coord + 0.0, 3, 23.0) - 1.0;
        col.b = 1.0 - tilableVoronoi(coord + 0.5, 6, 9.0);

        voronoiColor = col;
    } else {
		// Retrieve varonoi pattern from saved texture
        voronoiColor = texture(colortex10, texcoord);
    }

    if (isFirstFrame() || hasResolutionChanged()) {
        // Pack 32x32x32 3d texture in 2d texture (with padding)
        // So it is only computed once and does not change
        ivec2 fragCoord = ivec2(gl_FragCoord.xy);
        float z = floor(fragCoord.x / 34.0) + 8.0 * floor(fragCoord.y / 34.0);
        vec2 uv = mod(fragCoord.xy, 34.0) - 1.0;
        vec3 coord = vec3(uv, z) / 32.;

        float r = tilableVoronoi(coord, 16, 3.0);
        float g = tilableVoronoi(coord, 4, 8.0);
        float b = tilableVoronoi(coord, 4, 16.0);
        float c = max(0.0, 1.0 - (r + g * 0.5 + b * 0.25) / 1.75);

        worleyNoiseColor = vec4(c, c, c, c);
    } else {
        // Retrieve worley pattern from saved texture
        worleyNoiseColor = texture(colortex11, texcoord);
    }
}

#endif