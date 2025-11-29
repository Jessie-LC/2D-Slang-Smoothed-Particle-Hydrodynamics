import aperture;
import include.particles.buffer;
import include.particles.constants;
import include.particles.smoothinglength;
import include.kernels.wendland;
import include.boundary.toroidal;

extern static const int PARTICLE_COUNT;
extern static const int PARTICLE_GROUP_SIZE;
extern static const int RENDER_WIDTH;
extern static const int RENDER_HEIGHT;

Sampler2D<float4> mainTexture;

float4 InterpolateTexture(in float2 uv) {
    uv -= 0.5f;
    int2 ip = int2(floor(uv));
    float2 fp = fract(uv);

    float4[4] samples;
    for (int i = 0; i < 4; ++i) {
        int2 o = int2(i % 2, i / 2);
        int2 p = (ip + o) % RENDER_WIDTH;
        samples[i] = mainTexture[p];
    }

    return lerp(
        lerp(samples[0], samples[1], fp.x),
        lerp(samples[2], samples[3], fp.x),
        fp.y
    );
}

float4 SampleDisplacementBicubic(in float2 coord) {
    coord = coord - 0.5;

    float2 f = fract(coord);
    coord -= f;

    float2 ff = f * f;
    float4 w0;
    float4 w1;
    w0.xz = 1 - f; w0.xz *= w0.xz * w0.xz;
    w1.yw = ff * f;
    w1.xz = 3 * w1.yw + 4 - 6 * ff;
    w0.yw = 6 - w1.xz - w1.yw - w0.xz;

    float4 s = w0 + w1;
    float4 c = coord.xxyy + float2(-0.5, 1.5).xyxy + w1 / s;
    //c /= res.xxyy;

    float2 m = s.xz / (s.xz + s.yw);
    return lerp(
        lerp(InterpolateTexture(c.yw), InterpolateTexture(c.xw), m.x),
        lerp(InterpolateTexture(c.yz), InterpolateTexture(c.xz), m.x),
        m.y);
}

[[shader("fragment")]]
float4 main(float2 pos : SV_Position) : SV_Target0 {
    float3 color = float3(0.0f, 0.0f, 0.0f);
    float2 halfTexelScreen = float2(0.5f, 0.5f) / ap.game.screenSize;
    float2 halfTexelRaster = float2(0.5f, 0.5f) / float2(RENDER_WIDTH, RENDER_HEIGHT);
    float2 uv = (pos + halfTexelScreen) / ap.game.screenSize;
    uv    = uv * 2.0f - 1.0f;
    uv.x *= ap.game.screenSize.x / ap.game.screenSize.y;
    uv.x *= float32_t(RENDER_HEIGHT) / float32_t(RENDER_WIDTH);
    uv    = uv * 0.5f + 0.5f;
    uv   *= float2(RENDER_WIDTH, RENDER_HEIGHT);

    return SampleDisplacementBicubic(uv);
}