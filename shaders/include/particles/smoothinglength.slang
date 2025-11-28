public module SmoothingLength;

static const float32_t slEta = 4.0f;
static const float32_t slD = 2.0f;
static const float32_t maxSmoothingLength = 1000.0f;

float32_t CalculateSmoothingLength(in float32_t mass, in float32_t density) {
    precise float32_t sLength = slEta * pow(mass / density, 1.0f/slD);
    return clamp(sLength, 0.1f, maxSmoothingLength);
}
float32_t CalculateSmoothingLengthDerivative(in float32_t mass, in float32_t density) {
    precise float32_t sLength = -(slEta * pow(mass / density, 1.0f/slD) / (slD * density));
    if (sLength < -maxSmoothingLength) {
        return -maxSmoothingLength;
    }
    return min(sLength, -0.1f);
}
