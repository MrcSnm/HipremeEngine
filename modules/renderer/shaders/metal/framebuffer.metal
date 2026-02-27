#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct VertexInput
{
    float2 vPosition;
    float2 vTexST;
};
struct FragmentInput
{
    ///Unused
    float4 position [[position]];
    float2 inTexST;
}; 

vertex FragmentInput vertexMain(
    uint vertexID [[vertex_id]],
    VertexInput* input [[buffer(1)]]
)
{
    FragmentInput out;
    out.position = float4(input[vertexID].vPosition, 0.0, 1.0);
    out.inTexST = input[vertexID].vTexST;
    return out;
}

fragment float4 fragmentMain(
    FragmentInput in [[stage_in]],
    FragmentUniforms& u
    texture2d<float> uBufferTexture [[texture(0)]],
    sampler uBufferTextureSampler [[sampler(0)]]
)
{
    return uBufferTexture.sample(uBufferTextureSampler, in.inTexST) * u.uColor;
}