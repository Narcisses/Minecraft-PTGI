#define SSR_RAY_STEP_LENGTH 0.20
#define SSR_RAY_STEP_LENGTH_INCREASE 1.0
#define SSR_RAY_THICKNESS 25.0

vec3 getWorldPosition(vec2 texcoord, float depth) {
    vec3 clipSpace = vec3(texcoord, depth) * 2.0 - 1.0;
    vec4 viewW = gbufferProjectionInverse * vec4(clipSpace, 1.0);
    vec3 viewSpace = viewW.xyz / viewW.w;
    vec4 world = gbufferModelViewInverse * vec4(viewSpace, 1.0);

    return world.xyz;
}

vec3 getUVFromPosition(vec3 position) {
    vec4 projection = gbufferProjection * gbufferModelView * vec4(position, 1.0);
    projection.xyz /= projection.w;
    vec3 clipSpace = projection.xyz * 0.5 + 0.5;

    return clipSpace.xyz;
}

float cdist(vec2 coord) {
    return max(abs(coord.s - 0.5), abs(coord.t - 0.5)) * 3.0;
}

vec3 raytrace(vec3 startPosition, vec3 reflectionDir, vec2 uv) {
    vec3 sky_c = getSkyColor(reflectionDir, false, false) / 32.0;
    vec3 color = vec3(0);
    float step = SSR_RAY_STEP_LENGTH;

    vec3 currPos = startPosition + (SSR_RAY_STEP_LENGTH * reflectionDir * 28);
    vec3 currUV = vec3(0.0);
    int maxIter = 200;

    int j = 0;
    while (true) {
        if (j >= maxIter) {
            color += sky_c;
            break;
        }

        currPos += reflectionDir * step;
        currUV = getUVFromPosition(currPos);
        vec3 position = getWorldPosition(currUV.xy, getDepthAndDerivative(currUV.xy).r);
        float currDepth = length(position);

        if((length(currPos) - currDepth) > SSR_RAY_THICKNESS * step) {
            color += sky_c;
            break;
        }

        if((length(currPos) - currDepth) > 0) {
            float feather = clamp(pow(cdist(currUV.xy), 2.0), 0, 1);
            color += mix(texelFetch(colortex0, ivec2(currUV.xy * iresolution), 0).rgb, sky_c, feather);
            break;
        }

        step *= SSR_RAY_STEP_LENGTH_INCREASE;

        j++;
    }

    return color;
}

vec4 waterColor(vec3 normal, vec4 refractColor, vec2 texcoord) {
    // Fragment position
    vec3 origin = texture(colortex6, texcoord).xyz;

    // Compute view direction
    vec3 viewDir = getViewDir(texcoord);
    vec3 reflectedDir = reflect(viewDir, normal);

    // Distortion
    float minFrequency = 144.0;
    float maxFrequency = 96.0;
    float minDistortionAmount = 0.01;
    float maxDistortionAmount = 0.02;
    float minwsEffet = 3.0;
    float maxwsEffet = 4.9;

    float frequency = mix(minFrequency, maxFrequency, getDepthAndDerivative(texcoord).x);
    float distortionAmount = mix(minDistortionAmount, maxDistortionAmount, getDepthAndDerivative(texcoord).x);
    float wsEffet = mix(minwsEffet, maxwsEffet, getDepthAndDerivative(texcoord).x);

    float speed = 0.025;
    vec3 uv = vec3(vec2(texcoord * 0.2), getDepthAndDerivative(texcoord).x * 0.11);
    float X = uv.x * frequency + worldTime * speed;
    float Y = uv.y * frequency + worldTime * speed;
    float Z = uv.z * frequency + worldTime * speed;
    uv.y = cos((X + Y) * 1) * distortionAmount * cos(Y * wsEffet * 0.11 - Z * 0 * 0.1);
    uv.x = sin((X + Y) * 1) * distortionAmount * sin(X * wsEffet * 0.12 - Z * 0 * 0.1);
    uv.z = cos((X + Y) * 1) * distortionAmount * cos((X - Y)) * 0.01;

    reflectedDir = normalize(mix(reflectedDir, normalize(uv), 0.030));

    // Trace reflection
    vec3 reflectedColor = raytrace(origin, reflectedDir, texcoord);

    // Compute water color
    vec4 color = mix(vec4(reflectedColor, 1.0) / 1.0, refractColor, easeOutCirc(dot(normal, -viewDir)));

    return color;
}