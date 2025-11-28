import aperture;
import include.particles.buffer;
import include.particles.constants;
import include.particles.smoothinglength;
import include.boundary.toroidal;
import include.kernels.wendland;
import include.physics.constants;

extern static const int PARTICLE_COUNT;
extern static const int PARTICLE_GROUP_SIZE;

struct ComputeInput {
    uint groupIndex : SV_GroupIndex;
    uint3 groupID : SV_GroupID;
    uint3 localID : SV_GroupThreadID;
    uint3 globalID : SV_DispatchThreadID;
};

[[shader("compute")]]
[numthreads(PARTICLE_GROUP_SIZE, 1, 1)]
void CalculateGradH(ComputeInput input) {
    uint32_t particleID = input.globalID.x;

    particle_t particle = particles[particleID];

    precise float32_t gradH = float32_t(0.0f);
    for(int32_t i = 0; i < PARTICLE_COUNT; ++i) {
        particle_t found = particles[i];

        precise float32_t dist = ToroidalDistance(found.position, particle.position);
        precise float2 dx = ToroidalDifference(found.position, particle.position);
        precise float32_t kernel = WendlandKernelC6_DerivativeRadius(dist, CalculateSmoothingLength(particle.mass, particle.density));

        gradH += particle.mass * kernel;
    }
    gradH = 1.0f - (particle.mass / particle.mass) * CalculateSmoothingLengthDerivative(particle.mass, particle.density) * gradH;

    particle.gradH = gradH;

    particles[particleID] = particle;
}