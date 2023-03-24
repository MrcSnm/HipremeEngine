#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;
struct VertexInput
{
    float3 vPosition [[attribute(0)]];
    float4 vColor    [[attribute(1)]];
    float2 vTexST    [[attribute(2)]];
    float vTexID     [[attribute(3)]];
};
struct VertexUniforms
{
    float4x4 uProj;
    float4x4 uModel;
    float4x4 uView;
};
struct FragmentInput
{
    float4 position [[position]];
    float4 inVertexColor;
    float2 inTexST;
    float inTexID;
};

vertex FragmentInput vertex_main(
    VertexInput v [[stage_in]],
    constant VertexUniforms& u [[buffer(0)]]
)
{
    FragmentInput out;
    out.position = u.uProj*u.uView*u.uModel*float4(v.vPosition, 1.0);
    out.inVertexColor = v.vColor;
    out.inTexST = v.vTexST;
    out.inTexID = v.vTexID;
    return out;
}

struct FragmentUniforms
{
    float4 uBatchColor;
    // array<texture2d<float, access::sample>, 16> uTex;
    // array<sampler, 16> uSampler;
};
fragment float4 fragment_main(
    FragmentInput in [[stage_in]],
    constant FragmentUniforms& u [[buffer(0)]],
    array<texture2d<float>, 16> uTex [[texture(0)]],
    array<sampler, 16> uSampler [[sampler(0)]]
)
{
    int texID = int(in.inTexID);
    return uTex[texID].sample(uSampler[texID], in.inTexST)* in.inVertexColor * u.uBatchColor;
}