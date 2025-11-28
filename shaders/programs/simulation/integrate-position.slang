import aperture;
import include.particles.buffer;
import include.particles.constants;
import include.particles.smoothinglength;
import include.boundary.toroidal;
import include.kernels.wendland;

extern static const int PARTICLE_COUNT;
extern static const int PARTICLE_GROUP_SIZE;

struct ComputeInput {
    uint groupIndex : SV_GroupIndex;
    uint3 groupID : SV_GroupID;
    uint3 localID : SV_GroupThreadID;
    uint3 globalID : SV_DispatchThreadID;
};

static const float32_t xsphEpsilon = 0.5f;

float2 SmoothVelocity(particle_t particle) {
    // This is also known as XSPH due to how I am applying it
    // The goal is to keep particles from going through each other since that is a non-physical behavior

    precise float32_t particleLength = CalculateSmoothingLength(particle.mass, particle.density);
    float2 smoothed = float2(0.0f);
    for(int32_t i = 0; i < PARTICLE_COUNT; ++i) {
        particle_t found = particles[i];

        precise float32_t dist = ToroidalDistance(found.position, particle.position);
        precise float2 dx = ToroidalDifference(found.position, particle.position);
        precise float2 direction = dx / dist;
        if (dist == 0.0f) {
            direction = float2(0.0f, 0.0f);
        }
        precise float32_t foundLength = CalculateSmoothingLength(found.mass, found.density);
        precise float32_t kernel = WendlandKernelC6(dist, (particleLength * foundLength) / 2.0f);

        precise float32_t averageDensity = (particle.density + found.density) / 2.0f;
        smoothed += (found.mass / averageDensity) * (found.velocity - particle.velocity) * kernel;
    }

    return particle.velocity + smoothed * xsphEpsilon;
}

[[shader("compute")]]
[numthreads(PARTICLE_GROUP_SIZE, 1, 1)]
void IntegratePosition(ComputeInput input) {
    uint32_t particleID = input.globalID.x;

    particle_t particle = particles[particleID];

    particle.position = particle.position + SmoothVelocity(particle) * deltaTime;

    float2 tmpPosition = particle.position;
    tmpPosition = tmpPosition + boundSize / 2.0;
    tmpPosition = fmod(tmpPosition, boundSize);
    tmpPosition = tmpPosition - boundSize / 2.0;
    particle.position = tmpPosition;

    particles[particleID] = particle;
}