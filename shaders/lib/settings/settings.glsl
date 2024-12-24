// Path tracing
#define NB_SAMPLES 1         // Number of samples per pixel per frame (1)
#define NB_BOUNCES 2         // Number of times the ray bounces off of blocks (2)

// Voxelization
#define MAX_STEP 24         // Maximum number of steps allowed when tracing the uniform grid of voxels (up to 128, 24 good)
#define VOXEL_SIZE 256      // Size of the voxel map (powers of 2, requires tweaking shadowMapResolution)

// Filtering
#define HISTORY_SAMPLE_COUNT 60 // Maximum number of accumulated samples (SVGF) (24, 48, 60, 90)
#define PHI_COLOUR 10.0
#define PHI_NORMAL 128.0

// Pipeline
// #define SSR
#define RAYTRACE
#define TEMPORAL_ACCUMULATION
#define FILTER_1
#define FILTER_2
#define FILTER_3
#define FILTER_4
#define FILTER_5
#define TAA

// Resolution
#define RESOLUTION 1.0      // Ray tracing resolution (half resolution good => 2.0, needs shaders.properties modification)

// Gamma
#define GAMMA 2.2           // Gamma correction coefficient

// Bloom
#define COLOR_RANGE 1.0     // Bloom power (range)

// Exposure
#define MAX_EXPOSURE 2.0    // Maximum exposure (impacts brightness)

// Emission
#define EMISSION 2.5        // Emission power of bright blocks (glowstone, ...) 96.0
#define DIRECT_EMISSION 2.0 // Emission power of bright blocks (glowstone, ...)

// Moon
#define MOON_BRIGHTNESS 2.0

// TAA
#define CAS_AMOUNT 1.0      // Sharpening amount for CAS. [0.1...1.0]