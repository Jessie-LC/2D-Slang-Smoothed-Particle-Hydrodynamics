import aperture;
import include.particles.buffer;
import include.particles.constants;
import include.particles.smoothinglength;
import include.kernels.wendland;
import include.boundary.toroidal;

extern static const int PARTICLE_COUNT;
extern static const int PARTICLE_GROUP_SIZE;

Sampler2D<float4> mainTexture;

[[shader("fragment")]]
float4 main(float2 pos : SV_Position) : SV_Target0 {
    float3 color = float3(0.0f, 0.0f, 0.0f);
    // vec2 halfTexelScreen = vec2(0.5) / ap.game.screenSize;
    // vec2 halfTexelRaster = vec2(1.0) / settings.renderResolution;
    // vec2 uv = (gl_FragCoord.xy + halfTexelScreen) / ap.game.screenSize;
    // uv = uv * 2.0 - 1.0;
    // uv.x *= ap.game.screenSize.x / ap.game.screenSize.y;
    // uv.x *= (settings.renderResolution / settings.renderResolution);
    // uv = uv * 0.5 + 0.5;
    // if (uv == clamp(uv, 0.0, 1.0)) {
    //     copy = texelFetch(rasterTexture, ivec2(uv * vec2(settings.renderResolution, settings.renderResolution) - halfTexelRaster), 0).rgb;
    // } else {
    //     discard;
    // }
    return mainTexture[int2(pos)];
}