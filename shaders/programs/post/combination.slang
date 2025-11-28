import aperture;
import include.particles.buffer;
import include.particles.constants;
import include.particles.smoothinglength;
import include.kernels.wendland;
import include.boundary.toroidal;

extern static const int PARTICLE_COUNT;
extern static const int PARTICLE_GROUP_SIZE;

[[shader("fragment")]]
float4 main(float2 pos : SV_Position) : SV_Target0 {
    float3 color = float3(0.0f, 0.0f, 0.0f);
    for(int32_t i = 0; i < PARTICLE_COUNT; ++i) {
        particle_t found = particles[i]; 
        float2 position = found.position;
        //position = position + boundSize / 2.0;
        //position = fmod(position, boundSize);
        //position = position - boundSize / 2.0;
        //position = (position + boundSize / 2.0f) / boundSize;
        float32_t dist = ToroidalDistance(position, (pos/ap.game.screenSize * boundSize) - boundSize/2.0f);
        float3 velocityColor = normalize(float3(found.velocity, 0.0f)) * 0.5f + 0.5f;
        color += found.color * found.mass * WendlandKernelC6(dist, CalculateSmoothingLength(found.mass, found.density)) / found.density;
    }
    return float4(color * 0.5f, 1.0f);
}