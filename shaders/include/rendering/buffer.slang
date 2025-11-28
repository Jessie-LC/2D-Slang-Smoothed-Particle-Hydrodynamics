public module RenderBuffer;

struct PixelData {
    /*
        aaaa aaaa aaaa aaaa bbbb bbbb bbbb bbbb gggg gggg gggg gggg rrrr rrrr rrrr rrrr
    */
    uint32_t pixel;

    float4 UnpackPixelColor() {
        float red = float(uint32_t(pixel & 0xFFu)) / 255.0;
        float green = float(uint32_t((pixel >> 8u) & 0xFFu)) / 255.0;
        float blue = float(uint32_t((pixel >> 16u) & 0xFFu)) / 255.0;
        float alpha = float(uint32_t((pixel >> 24u) & 0xFFu)) / 255.0; // Currently empty, will be used later
        return float4(red, green, blue, alpha);
    }
    [mutating]
    void PackPixelColor(in float4 color) {
        uint32_t red = uint32_t(min(color.r * 255.0, 255.0)) & 0xFFu;
        uint32_t green = uint32_t(min(color.g * 255.0, 255.0)) & 0xFFu;
        uint32_t blue = uint32_t(min(color.b * 255.0, 255.0)) & 0xFFu;
        uint32_t alpha = uint32_t(min(color.a * 255.0, 255.0)) & 0xFFu;
        pixel = red | green << 8u | blue << 16u | alpha << 24u;
    }
};

uint32_t PackPixelColor(in float4 color) {
    uint32_t red = uint32_t(min(color.r * 255.0, 255.0)) & 0xFFu;
    uint32_t green = uint32_t(min(color.g * 255.0, 255.0)) & 0xFFu;
    uint32_t blue = uint32_t(min(color.b * 255.0, 255.0)) & 0xFFu;
    uint32_t alpha = uint32_t(min(color.a * 255.0, 255.0)) & 0xFFu;
    return red | green << 8u | blue << 16u | alpha << 24u;
}

RWStructuredBuffer<PixelData> pixelbuffer;