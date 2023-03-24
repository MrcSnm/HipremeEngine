#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct VertexInput
{
    float3 vPosition [[attribute(0)]];
    float4 vColor    [[attribute(1)]];
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
}; 

vertex FragmentInput vertex_main(
    VertexInput v [[stage_in]],
    constant VertexUniforms& u [[buffer(0)]]
)
{
    FragmentInput out;
    out.position = u.uProj*u.uView*u.uModel*float4(v.vPosition, 1.0);
    out.inVertexColor = v.vColor;
    return out;
}


struct FragmentUniforms
{
    float4 uGlobalColor;
};

fragment float4 fragment_main(
    FragmentInput in [[stage_in]],
    constant FragmentUniforms& uniforms [[buffer(0)]]
)
{
    return in.inVertexColor * uniforms.uGlobalColor;
}