#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/screen.glsl"
#include "/lib/common/easing.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/common/texture.glsl"
#include "/lib/atmosphere/cloudnoise.glsl"
#include "/lib/atmosphere/cycle.glsl"
#include "/lib/atmosphere/moonstars.glsl"
#include "/lib/atmosphere/ray.glsl"
#include "/lib/atmosphere/sky.glsl"
#include "/lib/atmosphere/clouds.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH

in vec2 texcoord;

/* RENDERTARGETS: 0,13 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 skyClouds;

void main() {
    color = texture(colortex0, texcoord);

    // Get ray
    vec3 ro = vec3(cameraPosition); // or 0.0
    vec3 rd = getRayDir(texcoord);

    float dist = 1000000.0;
    vec4 clouds = vec4(0.0, 0.0, 0.0, 1.0);

    if (rd.y > 0.0) {
        // Render clouds with fog
        clouds = renderClouds(ro, rd, dist);
        float fogAmount = 1.0 - (0.1 + exp(-dist * 0.0001));

        // Make sure clouds blend-in with sky background to bump-up clouds alpha far away
        float transparencyFarPlane = mix(0.0, 1.0, 1.0 - clamp(rd.y, 0.0, 0.5));
        transparencyFarPlane *= getFogAmount();
        clouds.a = clamp(clouds.a + transparencyFarPlane, 0.0, 1.0);
        fogAmount = clamp(fogAmount + transparencyFarPlane, 0.0, 1.0);
        clouds.rgb = mix(clouds.rgb, getSkyColor(rd, false, false) * (1.0 - clouds.a), fogAmount);
    }

    // Temporal Upsampling
    vec2 oldUV = reprojectPos(rd * dist); // ro

    if (!isFirstFrame() && !hasResolutionChanged() && !hasWorldTimeChanged()) {
        // Skip first frame to avoid black screen
        // Take into account blending during rain/clean events (avoid weird cloud self-shadows)
        float a = (isOutOfTexture(oldUV)) ? 1.0 : 0.01 + mix(0.0, 0.40, wetness);
        vec4 tempClouds = texture(colortex13, oldUV).xyzw;
        clouds = mix(tempClouds, clouds, a);
    }

    skyClouds = clouds;
}

#endif
