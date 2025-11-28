public module WendlandC6;

float32_t WendlandKernelC6(in float32_t dist, in float32_t radius) {
    precise float32_t normalization = (78.0f / (7.0f * (3.14159))) / (radius * radius); // h^2 for 2D

    precise float32_t q = dist / radius;
    if (q > 1.0f) {
        return 0.0f;
    }
    if (q <= 0.0f) {
        return normalization;
    }

    precise float32_t oneMinus_q = 1.0f - q;
    precise float32_t qPolynomial = 32.0f * pow(q, 3.0f) + 25.0f * pow(q, 2.0f) + 8.0f * q + 1.0f;
    precise float32_t kernel = max(pow(oneMinus_q, 8.0f), 0.0f) * qPolynomial;

    return normalization * kernel;
}

float32_t WendlandKernelC6_Derivative(in float32_t dist, in float32_t radius) {
    precise float32_t normalization = (78.0f / (7.0f * (3.14159))) / (radius * radius);

    precise float32_t q = dist / radius;
    if (q > 1.0f) {
        return 0.0f;
    }
    if (q <= 0.0f) {
        return 0.0f;
    }

    precise float32_t oneMinus_q = 1.0f - q;
    precise float32_t qPolynomial = 32.0f * pow(q, 3.0f) + 25.0f * pow(q, 2.0f) + 8.0f * q + 1.0;
    precise float32_t term_qD = 96.0f * pow(q, 2.0f) + 50.0f * q + 8.0f;
    precise float32_t kernel = (-8.0f * max(pow(oneMinus_q, 7.0f), 0.0f) * qPolynomial) + (max(pow(oneMinus_q, 8.0f), 0.0f) * term_qD);

    return normalization * kernel;
}

float32_t WendlandKernelC6_DerivativeRadius(in float32_t dist, in float32_t radius) {
    precise float32_t normalization = (78.0f / (7.0f * (3.14159))) / (radius * radius); // h^2 for 2D

    precise float32_t q = dist / radius;
    precise float32_t qD = -(dist / (radius*radius));
    if (q > 1.0f) {
        return 0.0f;
    }
    if (q <= 0.0f) {
        return 0.0f;
    }

    precise float32_t oneMinus_q = 1.0f - q;
    precise float32_t qPolynomial = 32.0f * pow(q, 3.0f) + 25.0f * pow(q, 2.0f) + 8.0f * q + 1.0;
    precise float32_t qPolynomialD = -(96.0f * pow(dist, 3.0f) / pow(radius, 4.0f)) - (50.0f * pow(dist, 2.0f) / pow(radius, 3.0f)) - (8.0f * dist / pow(radius, 2.0f));
    precise float32_t t1 = (8.0f * dist * pow(oneMinus_q, 7.0f) * qPolynomial) / (radius*radius);
    precise float32_t t2 = pow(oneMinus_q, 8.0f) * qPolynomialD;
    precise float32_t kernel = t1 + t2;

    return normalization * kernel;
}
