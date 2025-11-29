import aperture;
import include.particles.buffer;
import include.particles.constants;
import include.particles.smoothinglength;
import include.kernels.wendland;
import include.boundary.toroidal;
import include.rendering.buffer;

extern static const int PARTICLE_COUNT;
extern static const int PARTICLE_GROUP_SIZE;
extern static const int RENDER_WIDTH;
extern static const int RENDER_HEIGHT;

[[shader("fragment")]]
float4 CopyPixelbuffer(float2 pos : SV_Position) : SV_Target0 {
    int32_t pixelIndex = int32_t(pos.x) + int32_t(pos.y) * RENDER_WIDTH;
    return pixelbuffer[pixelIndex].UnpackPixelColor();
}