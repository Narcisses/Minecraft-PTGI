// vec2 sharpenOffsets[4] = vec2[4](
// 	vec2( 1.0,  0.0),
// 	vec2( 0.0,  1.0),
// 	vec2(-1.0,  0.0),
// 	vec2( 0.0, -1.0)
// );


// void SharpenFilter(inout vec3 color, vec2 coord) {
// 	float mult = MC_RENDER_QUALITY * 0.125;
// 	vec2 view = 1.0 / iresolution;

// 	color *= MC_RENDER_QUALITY * 0.5 + 1.0;

// 	for(int i = 0; i < 4; i++) {
// 		vec2 offset = sharpenOffsets[i] * view;
// 		color -= texture2D(colortex1, coord + offset).rgb * mult;
// 	}
// }


#define textureLod0Offset(img, coord, offset) textureLodOffset(img, coord, 0.0f, offset)
#define textureLod0(img, coord) textureLod(img, coord, 0.0f)

void SharpenFilter(inout vec3 color, vec2 textureCoord) {
    // fetch a 3x3 neighborhood around the pixel 'e',
    //  a b c
    //  d(e)f
    //  g h i
    vec3 a = textureLod0Offset(colortex2, textureCoord, ivec2(-1,-1)).rgb;
    vec3 b = textureLod0Offset(colortex2, textureCoord, ivec2( 0,-1)).rgb;
    vec3 c = textureLod0Offset(colortex2, textureCoord, ivec2( 1,-1)).rgb;
    vec3 d = textureLod0Offset(colortex2, textureCoord, ivec2(-1, 0)).rgb;
    vec3 e = color;
    vec3 f = textureLod0Offset(colortex2, textureCoord, ivec2( 1, 0)).rgb;
    vec3 g = textureLod0Offset(colortex2, textureCoord, ivec2(-1, 1)).rgb;
    vec3 h = textureLod0Offset(colortex2, textureCoord, ivec2( 0, 1)).rgb;
    vec3 i = textureLod0Offset(colortex2, textureCoord, ivec2( 1, 1)).rgb;

    // Soft min and max.
    //  a b c             b
    //  d e f * 0.5  +  d e f * 0.5
    //  g h i             h
    // These are 2.0x bigger (factored out the extra multiply).

    vec3 mnRGB  = min(min(min(d,e),min(f,b)),h);
    vec3 mnRGB2 = min(min(min(mnRGB,a),min(g,c)),i);
    mnRGB += mnRGB2;

    vec3 mxRGB  = max(max(max(d,e),max(f,b)),h);
    vec3 mxRGB2 = max(max(max(mxRGB,a),max(g,c)),i);
    mxRGB += mxRGB2;

    // Smooth minimum distance to signal limit divided by smooth max.

    vec3 rcpMxRGB = vec3(1)/mxRGB;
    vec3 ampRGB = clamp((min(mnRGB,2.0-mxRGB) * rcpMxRGB),0,1);

    // Shaping amount of sharpening.
    ampRGB = inversesqrt(ampRGB);
    float peak = 8.0 - 3.0 * CAS_AMOUNT;
    vec3 wRGB = -vec3(1)/(ampRGB * peak);
    vec3 rcpWeightRGB = vec3(1)/(1.0 + 4.0 * wRGB);

    //                          0 w 0
    //  Filter shape:           w 1 w
    //                          0 w 0  

    vec3 window = (b + d) + (f + h);
    vec3 outColor = clamp((window * wRGB + e) * rcpWeightRGB,0,1);

    color = outColor;
}