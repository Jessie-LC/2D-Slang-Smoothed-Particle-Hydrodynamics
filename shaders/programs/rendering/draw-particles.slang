import aperture;
import include.particles.buffer;
import include.particles.constants;
import include.particles.smoothinglength;
import include.boundary.toroidal;
import include.kernels.wendland;
import include.rendering.buffer;

extern static const int PARTICLE_COUNT;
extern static const int PARTICLE_GROUP_SIZE;

struct ComputeInput {
    uint groupIndex : SV_GroupIndex;
    uint3 groupID : SV_GroupID;
    uint3 localID : SV_GroupThreadID;
    uint3 globalID : SV_DispatchThreadID;
};

void DrawCircle(in particle_t particle) {
    float32_t smoothingLength = CalculateSmoothingLength(particle.mass, particle.density);
    
    int2 particlePixelPosition = int2(((particle.position + boundSize / 2.0f) / boundSize) * 512.0f);
    int32_t sLength = int32_t((smoothingLength / length(boundSize)) * 512.0f);

    if (sLength == 0) {
        return;
    }

    if (particlePixelPosition.x < 0 || particlePixelPosition.x > 511) {
        return;
    }
    if (particlePixelPosition.y < 0 || particlePixelPosition.y > 511) {
        return;
    }

    for(int32_t y = -sLength; y <= sLength; ++y) {
        int32_t xSquared = sLength*sLength - y*y;
        int32_t width = int32_t(sqrt(float32_t(xSquared)));
        for(int32_t x = -width; x <= width; ++x) {
            int2 pixelCoordinate = (particlePixelPosition + int2(x, y)) % int2(512, 512);

            float2 coord = float2(pixelCoordinate.x, pixelCoordinate.y) / 512.0f;
            coord = coord - float2((512.0f / 2.0f) / 512.0f);

            float2 spatialPosition = coord * boundSize;
            float2 clampedPosition = clamp(spatialPosition, -boundSize/2.0f, boundSize/2.0f);

            if ((spatialPosition.x != clampedPosition.x) || (spatialPosition.y != clampedPosition.y)) {
                continue;
            }

            float2 tmpPosition = particle.position;
            tmpPosition = tmpPosition + boundSize / 2.0f;
            tmpPosition = fmod(tmpPosition, boundSize);
            tmpPosition = tmpPosition - boundSize / 2.0f;

            float2 dx = ToroidalDifference(spatialPosition, tmpPosition);
            float32_t dist = ToroidalDistance(spatialPosition, tmpPosition);

            float32_t centerKernel = WendlandKernelC6(0.0f, smoothingLength);
            float32_t kernel = WendlandKernelC6(dist, smoothingLength);
            float32_t reNormalizedKernel = kernel / centerKernel;

            float32_t alpha = reNormalizedKernel;

            float3 color;
            color = particle.color * reNormalizedKernel;
            color = color * 3.0f;
            color = color / (1.0f + color);

            int32_t pixelIndex = pixelCoordinate.x + pixelCoordinate.y * 512;
            int32_t og;
            InterlockedMax<uint32_t>(pixelbuffer[pixelIndex].pixel, PackPixelColor(float4(color, alpha)), og);
        }
    }
}

[[shader("compute")]]
[numthreads(PARTICLE_GROUP_SIZE, 1, 1)]
void DrawParticles(ComputeInput input) {
    uint32_t particleID = input.globalID.x;

    particle_t particle = particles[particleID];

    DrawCircle(particle);
}