import aperture;
import include.particles.buffer;
import include.particles.constants;
import include.particles.smoothinglength;

extern static const int PARTICLE_COUNT;
extern static const int PARTICLE_GROUP_SIZE;

struct ComputeInput {
    uint groupIndex : SV_GroupIndex;
    uint3 groupID : SV_GroupID;
    uint3 localID : SV_GroupThreadID;
    uint3 globalID : SV_DispatchThreadID;
};

struct rngLB32 {
    [mutating]
    void SetSeed(uint32_t _seed) {
        seed = _seed;
    }

    [mutating]
    uint32_t GetUintValue() {
        return (seed = lowbias32(seed + 1u));
    }
    [mutating]
    float32_t GetFloatValue() {
        return (float32_t)GetUintValue() / (float32_t)0xFFFFFFFFFFFFFFFFu;
    }
    [mutating]
    float64_t GetDoubleValue() {
        return (float64_t)GetUintValue() / (float64_t)0xFFFFFFFFFFFFFFFFu;
    }

    uint32_t lowbias32(uint32_t x) {
        x ^= x >> 16;
        x *= 0x7feb352du;
        x ^= x >> 15;
        x *= 0x846ca68bu;
        x ^= x >> 16;
        return x;
    }

    uint32_t seed;
};

[[shader("compute")]]
[numthreads(PARTICLE_GROUP_SIZE, 1, 1)]
void InitializeParticles(ComputeInput input) {
    uint32_t particleID = input.globalID.x;

    rngLB32 rng;

    rng.SetSeed(particleID * PARTICLE_COUNT * 47672051724u);

    const int32_t height = 96;

    int32_t x = int32_t(particleID) / height;
    int32_t y = int32_t(particleID) % height;

    particle_t particle;
    particle.color = float3(1.0f, 0.0f, 0.0f);
    particle.position = (float2(x, y) / float2(height, height)) * boundSize - boundSize / 2.0f;
    particle.velocity = float2(-particle.position.y, particle.position.x) * 0.0f;

    if (particle.position.y <= 10.0f && particle.position.y >= -10.0f) {
        particle.color = (float3(rng.GetDoubleValue(), rng.GetDoubleValue(), rng.GetDoubleValue()) * 0.7f + 0.3f) * float3(0.2f, 1.0f, 0.5f) * 3.0f;
        particle.velocity = float2(100.0f, 0.0f);
    }

    particle.acceleration = float2(0.0f, 0.0f);

    particle.torque = 0.0f;
    particle.angularMomentum = 0.0f;

    particle.density = 1.0f;
    particle.mass = 0.1f;
    particle.charge = 0.0f;
    particle.gradH = 1.0f;

    particle.status = 1;

    particles[particleID] = particle;
}