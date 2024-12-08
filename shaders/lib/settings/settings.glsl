// Path tracing
#define NB_SAMPLES 1        // Number of samples per pixel per frame (max 2)
#define NB_BOUNCES 2        // Number of times the ray bounces off of blocks
#define EPSILON 0.001      // Nudging factor for avoiding self-collisions for common blocks (shadow bias)
#define EPSILON_2 0.075     // Nudging factor for non-voxelizable blocks and exceptions (dirt path, ...)
#define EPSILON_3 0.001    // Nudging factor for stairs-like blocks (wooden stairs, cobblestone stairs, ...)

// Voxelization
#define MAX_STEP 312        // Maximum number of steps allowed when tracing the uniform grid of voxels
#define VX_VOXEL_SIZE 256   // Size of the voxel map (powers of 2, requires tweaking shadowMapResolution)

// Filtering
#define HISTORY_SAMPLE_COUNT 90 // Maximum number of accumulated samples (SVGF)
#define PHI_COLOUR 10.0
#define PHI_NORMAL 128.0

// Filters
#define FILTER_1
#define FILTER_2
#define FILTER_3
#define FILTER_4
#define FILTER_5

// Resolution
#define RESOLUTION 1.0      // Ray tracing resolution (half resolution good)

// Gamma
#define GAMMA 2.2           // Gamma correction coefficient

// Bloom
#define COLOR_RANGE 1.0     // Bloom power (range)

// Exposure
#define MAX_EXPOSURE 2.0    // Maximum exposure (impacts brightness)

// Emission
#define EMISSION 2.0       // Emission power of bright blocks (glowstone, ...) 96.0
#define DIRECT_EMISSION 16.0 // Emission power of bright blocks (glowstone, ...)

// Moon
#define MOON_BRIGHTNESS 5.0

// TAA
#define SHARPENING 1        // Sharpening filter. [0 1 2]
#define CAS_AMOUNT 0.3      // Sharpening amount for CAS. [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]