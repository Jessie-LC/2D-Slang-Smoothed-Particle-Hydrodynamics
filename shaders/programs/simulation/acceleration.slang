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

precise float32_t IdealGasLaw(float32_t density) {
    return density * R_ideal * 273.0f;
}

static const float32_t alpha = 0.002f;
static const float32_t beta = alpha * 2.0f;

[[shader("compute")]]
[numthreads(PARTICLE_GROUP_SIZE, 1, 1)]
void CalculateAcceleration(ComputeInput input) {
    uint32_t particleID = input.globalID.x;

    particle_t particle = particles[particleID];
    precise float32_t particleLength = CalculateSmoothingLength(particle.mass, particle.density);
    precise float2 acceleration = float2(0.0f, 0.0f);
    precise float2 angularMomentumCurl = float2(0.0f, 0.0f);
    precise float32_t viscousAngularMonentum = 0.0f;
    precise float32_t velocityCurl = 0.0f;
    for(int32_t i = 0; i < PARTICLE_COUNT; ++i) {
        if (i == particleID) {
            continue;
        }

        particle_t found = particles[i];
        precise float32_t foundLength = CalculateSmoothingLength(found.mass, found.density);

        precise float32_t dist = ToroidalDistance(found.position, particle.position);
        precise float32_t da = found.angularMomentum - particle.angularMomentum;
        precise float2 dx = ToroidalDifference(found.position, particle.position);
        precise float2 dv = found.velocity - particle.velocity;
        precise float2 direction = dx / dist;
        if (dist == 0.0f) {
            direction = float2(0.0f, 0.0f);
        }
        precise float32_t slopeA = WendlandKernelC6_Derivative(dist, particleLength);
        precise float32_t slopeB = WendlandKernelC6_Derivative(dist, foundLength);

        precise float32_t viscPiA = 0.0f;
        precise float32_t viscPiB = 0.0f;
        if (dot(dx, dv) < 0.0f) {
            precise float32_t muA = (particleLength * dot(dx, dv)) / (pow(dist, 2.0) + 1e-5 * pow(particleLength, 2.0));
            precise float32_t muB = (foundLength * dot(dx, dv)) / (pow(dist, 2.0) + 1e-5 * pow(foundLength, 2.0));
            viscPiA = (-alpha * 331.0f * muA + beta * muA) / particle.density;
            viscPiB = (-alpha * 331.0f * muB + beta * muB) / found.density;
        }

        precise float32_t angularViscPiA = 0.0f;
        precise float32_t angularViscPiB = 0.0f;
        {
            precise float32_t muA = (particleLength * dot(dx, dv)) / (pow(dist, 2.0) + 1e-5 * pow(particleLength, 2.0));
            precise float32_t muB = (foundLength * dot(dx, dv)) / (pow(dist, 2.0) + 1e-5 * pow(foundLength, 2.0));
            angularViscPiA = (-alpha * 331.0f * muA + beta * muA) / particle.density;
            angularViscPiB = (-alpha * 331.0f * muB + beta * muB) / found.density;
        }

        viscousAngularMonentum += (particle.mass * angularViscPiA * slopeA) + (found.mass * angularViscPiB * slopeB);

        velocityCurl += found.mass * cross(float3(dv, 0.0f), float3(direction * slopeB, 0.0f)).z;
        angularMomentumCurl += found.mass * cross(float3(0.0f, 0.0f, da), float3(direction * slopeB, 0.0f)).xy;

        precise float32_t pressureA = IdealGasLaw(particle.density) / (particle.gradH * particle.density*particle.density);
        precise float32_t pressureB = IdealGasLaw(found.density) / (found.gradH * found.density*found.density);
        precise float2 pressureForce = (pressureA * slopeA * direction) + (pressureB * slopeB * direction);
        precise float2 viscosityForce = (particle.mass * viscPiA * direction * slopeA) + (found.mass * viscPiB * direction * slopeB);
        acceleration += (found.mass * pressureForce) + viscosityForce;
    }
    velocityCurl = (1.0 / particle.density) * velocityCurl;
    angularMomentumCurl = (1.0 / particle.density) * angularMomentumCurl;

    precise float2 transferAcceleration = kinematicTransferCoefficient * angularMomentumCurl;
    precise float32_t torque = particle.mass * kinematicTransferCoefficient * (velocityCurl - 2.0f * particle.angularMomentum) + viscousAngularMonentum;
    particle.acceleration = transferAcceleration + acceleration;
    particle.torque = torque;

    particles[particleID] = particle;
}