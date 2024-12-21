// ------------- All buffers -------------
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D colortex8;
uniform sampler2D colortex9;
uniform sampler2D colortex10;
uniform sampler2D colortex11;
uniform sampler2D colortex12;
uniform sampler2D colortex13;
uniform sampler2D colortex14;
uniform sampler2D colortex15;
uniform sampler2D shadow;
uniform sampler2D watershadow;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D noisetex;
uniform sampler2D gnormal;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

// ------------- Temporal buffers -------------
const bool colortex5Clear = false;  // History ray illumination data
const bool colortex7Clear = false;  // History normal data
const bool colortex8Clear = false;  // History moments
const bool colortex9Clear = false;  // History TAA
const bool colortex10Clear = false; // Voronoi noise texture for clouds
const bool colortex11Clear = false; // Worley noise texture for clouds
const bool colortex13Clear = false; // Clouds texture
const bool colortex15Clear = false; // Bloom tiles

// ------------- SSBOs -------------
layout(std430, binding = 0) buffer SSBOScreenSizeData {
    float width; // 4 bytes
    float height; // 4 bytes
    float worldtime; // 4 bytes
    float seed; // 4 bytes
} screenData;

// ------------- Buffers Formats -------------
/*
const int shadowcolor1Format = RGBA32F;
const int colortex0Format = RGBA16F;
const int colortex1Format = RGBA16F;
const int colortex2Format = RGBA32F;
const int colortex3Format = RGBA16F;
const int colortex4Format = RGBA16F;
const int colortex5Format = RGBA16F;
const int colortex6Format = RGBA32F;
const int colortex7Format = RGBA32F;
const int colortex8Format = RGBA16F;
const int colortex9Format = RGBA;
const int colortex10Format = RGBA16F;
const int colortex11Format = RGBA16F;
const int colortex12Format = RGBA;
const int colortex13Format = RGBA16F;
const int colortex14Format = RGBA16F;
const int colortex15Format = RGBA16F;
*/

/*
Texture Units for Composite:
noisetex: Default noise texture
shadowcolor0: Voxel map
depthtex0: GBuffer depth
colortex0: GBuffer color
colortex1: GBuffer position + depth derivative
colortex2: GBuffer normals + block ID
colortex3: Motion buffer
colortex4: Path traced illumination + variance (SVGF, Albedo Demodulation)
colortex5: History ray illumination + variance (SVGF, Temporal)
colortex6: Water position
colortex7: History normal data + block ID (SVGF, Temporal)
colortex8: History moments (luminance, square luminance) + pixel age + previous depth (SVGF, Temporal)
colortex9: History TAA (Temporal)
colortex10: Voronoi noise texture for clouds (Temporal)
colortex11: Worley noise texture for clouds (Temporal)
colortex12: Water normal
colortex13: Clouds texture (Temporal)
colortex14: Bloom texture (Mask)
colortex15: Bloom tiles (Temporal)
*/
