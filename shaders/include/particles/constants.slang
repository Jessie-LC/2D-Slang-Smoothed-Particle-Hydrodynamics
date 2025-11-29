public module ParticleConstants;

static const float2 boundSize = float2(100.0f, 100.0f) * 1.0f;
static const float2 halfBoundSize = boundSize / 2.0f - float2(1.0f) * 0.25f;

static const float32_t deltaTime = 1.0f / 60.0f;

static const float32_t kinematicTransferCoefficient = 0.4f;
static const float32_t microinertiaCoefficient = 1.0f;