#include "/lib/settings/settings.glsl"
#include "/lib/settings/uniforms.glsl"
#include "/lib/settings/buffers.glsl"
#include "/lib/common/screen.glsl"
#include "/lib/common/easing.glsl"
#include "/lib/common/encoding.glsl"
#include "/lib/atmosphere/cycle.glsl"
#include "/lib/atmosphere/moonstars.glsl"
#include "/lib/atmosphere/ray.glsl"
#include "/lib/geom/geom.glsl"
#include "/lib/atmosphere/sky.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    color = texture(colortex0, texcoord);

    // The minecraft sky (+ moon + stars, ...)
    // Should have color less than 0.0 to differenciate
    if ((color.r <= 0.0)) {
        // Draw clouds instead of normal sky
        vec3 rd = getRayDir(texcoord);
        vec3 col = getSkyColor(rd, true, false);
        vec4 clouds = texture(colortex13, texcoord);
        color.rgb = clouds.rgb + col.rgb * clouds.a;
    }
}

#endif