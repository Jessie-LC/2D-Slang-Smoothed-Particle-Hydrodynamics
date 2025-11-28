public module ToroidalDistance;

import include.particles.buffer;
import include.particles.constants;

float32_t ToroidalDistance(float2 p1, float2 p2) {
    float2 dp = abs(p1 - p2);
    dp = lerp(dp, boundSize - dp, float2(dp > (boundSize / 2.0f)));
    return length(dp);
}
float2 ToroidalDifference(float2 p1, float2 p2) {
    float2 offs = p1 - p2;
    float2 absOffs = abs(offs);
    return lerp(absOffs, absOffs - boundSize, float2(absOffs > (boundSize / 2.0f))) * sign(offs);
}