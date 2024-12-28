#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/rand.glsl"
#include "/lib/mblur/dither.glsl"
#include "/lib/mblur/mblur.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH

in vec2 texcoord;

/* RENDERTARGETS: 0,5,7,8,12 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 prevIllum;
layout(location = 2) out vec4 prevNormal;
layout(location = 3) out vec4 prevMoments;
layout(location = 4) out vec4 prevPositions;

void main() {
	color = texture(colortex0, texcoord);

	// Motion blur
	float depth = texture(depthtex0, texcoord).r;
    float dither = Bayer64(gl_FragCoord.xy) + rand(texcoord * frameTimeCounter);
	vec3 col = motionBlur(colortex0, texcoord, color.rgb, depth, dither);
	color.rgb = col;

    // Save (previous) screen resolution and time (useful for resolution changes)
    screenData.width = viewWidth;
    screenData.height = viewHeight;
    screenData.worldtime = worldTime;
    screenData.seed = screenData.seed + 1.0;

    // Save (previous) frame data (normal, illumination, depth, position, ...)
    vec4 currIllum = texture(colortex4, texcoord);
    vec4 currNormal = texture(colortex2, texcoord);
    float currDepth = texture(depthtex0, texcoord).r;
    vec3 currMoments = texture(colortex8, texcoord).xyz;
    vec3 currPosition = texture(colortex1, texcoord).xyz;

    prevIllum = currIllum; // Illumination + variance
    prevNormal = currNormal; // Normal + mesh ID
    prevMoments = vec4(currMoments, currDepth); // Moments + depth
    prevPositions = vec4(currPosition, 1.0);
}

#endif