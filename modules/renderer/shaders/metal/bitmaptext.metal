#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct VertexInput
{
    float3 vPosition [[attribute(0)]];
    float2 vTexST    [[attribute(1)]];
};
struct VertexUniforms
{
    float4x4 uModel;
    float4x4 uView;
    float4x4 uProj;
};
struct FragmentInput
{
    float4 position [[position]];
    float2 inTexST;
};
vertex FragmentInput vertex_main(
    VertexInput input [[stage_in]],
    constant VertexUniforms& u [[buffer(0)]]
)
{
    FragmentInput out;
    out.position = u.uProj * u.uView * u.uModel * float4(input.vPosition, 1.0);
    out.inTexST = input.vTexST;
    return out;
}

struct FragmentUniforms
{
    float4 uColor;
};
fragment float4 fragment_main(
    FragmentInput in [[stage_in]],
    constant FragmentUniforms& u [[buffer(0)]],
    texture2d<float> uTex [[texture(0)]],
    sampler uTexSampler [[sampler(0)]]
)
{
    float r = uTex.sample(uTexSampler,in.inTexST).r;
    return float4(r,r,r,r)*u.uColor;
}