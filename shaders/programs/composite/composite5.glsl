#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/atmosphere/cycle.glsl"
#include "/lib/bloom/bloom.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH

in vec2 texcoord;

/* RENDERTARGETS: 0,15 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 bloomTiles;

void main() {
    color = texture(colortex0, texcoord);

    // Compute bloom
	// Make the actual bloom tiles
	vec3 blur = makeBloom(1., vec2(0.0, 0.0), texcoord, iresolution, colortex14);
	blur += makeBloom(2., vec2(0.5, 0.5), texcoord, iresolution, colortex14);
	blur += makeBloom(3., vec2(0.75, 0.0), texcoord, iresolution, colortex14);
	blur += makeBloom(4., vec2(0.875, 0.5), texcoord, iresolution, colortex14);
	blur += makeBloom(5., vec2(0.9375, 0.0), texcoord, iresolution, colortex14);

	// Temporal accumulation (smoothing)
	// To remove annoying flickering when moving the player around
	// Low alpha => delay/lag
	// Big alpha => flickering
	vec4 prev = texture(colortex15, texcoord);
	vec4 new = vec4(pow(blur, vec3(1.0)), 1.0);
	bloomTiles = mix(prev, new, 0.65);
}

#endif