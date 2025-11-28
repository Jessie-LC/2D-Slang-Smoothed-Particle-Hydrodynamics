import aperture;
import include.particles.buffer;
import include.particles.constants;
import include.particles.smoothinglength;
import include.boundary.toroidal;

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
void InitializeParticles(ComputeInput input) {
    uint32_t particleID = input.globalID.x;
}