#include "/lib/utils.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH

in vec2 texcoord;

/* RENDERTARGETS: 0,4,5 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 foutput;
layout(location = 2) out vec4 historyIllumination;

void main() {
    color = texture(colortex0, texcoord);

    vec4 filteredIllumination;
    #ifdef FILTER_1
        filteredIllumination = spatialFilter(colortex4, texcoord, 1); // colortex5
    #else
        filteredIllumination = texture(colortex5, texcoord);
    #endif

    foutput = filteredIllumination;
    historyIllumination = filteredIllumination;
}

#endif