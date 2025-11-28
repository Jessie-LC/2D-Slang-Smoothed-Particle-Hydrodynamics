public module ParticleBuffer;

struct Particle {
    float3 color;

    float2 position;

    float2 velocity;
    float2 acceleration;

    float32_t torque;
    float32_t angularMomentum;

    float32_t mass;
    float32_t density;
    float32_t charge;
    float32_t gradH;

    int32_t status;
};

typedef Particle particle_t;

RWStructuredBuffer<particle_t> particles;