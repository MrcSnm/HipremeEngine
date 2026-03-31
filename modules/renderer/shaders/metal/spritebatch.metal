#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;
struct VertexUniforms
{
    float4x4 uMVP;
};

#if INSTANCED == 1
struct VertexInput
{
    float2 vPosition [[attribute(0)]];
    float2 vXY       [[attribute(1)]];
    float2 vSize     [[attribute(2)]];
    float4 vColor    [[attribute(3)]];
    float vRotation  [[attribute(4)]];
    ushort vZ        [[attribute(5)]];
    ushort vTexID    [[attribute(6)]];
    float2 vUVMin    [[attribute(7)]];
    float2 vUVMax    [[attribute(8)]];
};

#else
struct VertexInput
{
    ushort2 vPosition [[attribute(0)]];
    float4 vColor     [[attribute(1)]];
    float2 vTexST     [[attribute(2)]];
    ushort vZ         [[attribute(3)]];
    ushort vTexID     [[attribute(4)]];
};
#endif

struct FragmentInput
{
    float4 position [[position]];
    float4 inVertexColor;
    float2 inTexST;
    float inTexID;
};

vertex FragmentInput vertexMain(
    VertexInput v [[stage_in]],
    constant VertexUniforms& u [[buffer(0)]]
)
{
    FragmentInput out;

    #if INSTANCED == 1
        float s = sin(v.vRotation);
        float c = cos(v.vRotation);
        float2 actualPos = float2(
            v.vPosition.x * c - v.vPosition.y * s,
            v.vPosition.x * s + v.vPosition.y * c            
        ) * v.vSize + v.vXY;
        out.position = u.uMVP*float4(actualPos, v.vZ, 1.0);
        out.inTexST = v.vPosition * v.vUVMax + v.vUVMin;
    #else
        out.position = u.uMVP*float4(float2(v.vPosition), float(v.vZ), 1.0);
        out.inTexST = v.vTexST;
    #endif

    out.inVertexColor = v.vColor;
    out.inTexID = v.vTexID;
    return out;
}

struct FragmentUniforms
{
    float4 uBatchColor;
};

// #if ARGS_TIER2
// float4 uBatchColor;
// array<texture2d<float>, 8> uTex;
// array<sampler, 8> uSampler;

// #if ARGS_TIER2
//     fragment float4 fragmentMain(
//         FragmentInput in [[stage_in]],
//         constant FragmentUniforms& u [[buffer(0)]]
//     )
//     {
//         int texID = int(in.inTexID);
//         return u.uTex[texID].sample(u.uSampler[texID], in.inTexST)* in.inVertexColor * u.uBatchColor;
//     }
// #else
fragment float4 fragmentMain(
    FragmentInput in [[stage_in]],
    constant FragmentUniforms& u [[buffer(0)]],
    texture2d<float> uTex0 [[texture(0)]],
    texture2d<float> uTex1 [[texture(1)]],
    texture2d<float> uTex2 [[texture(2)]],
    texture2d<float> uTex3 [[texture(3)]],
    texture2d<float> uTex4 [[texture(4)]],
    texture2d<float> uTex5 [[texture(5)]],
    texture2d<float> uTex6 [[texture(6)]],
    texture2d<float> uTex7 [[texture(7)]],
    sampler uSampler0 [[sampler(0)]],
    sampler uSampler1 [[sampler(1)]],
    sampler uSampler2 [[sampler(2)]],
    sampler uSampler3 [[sampler(3)]],
    sampler uSampler4 [[sampler(4)]],
    sampler uSampler5 [[sampler(5)]],
    sampler uSampler6 [[sampler(6)]],
    sampler uSampler7 [[sampler(7)]]
)
{
    int texID = int(in.inTexID);
    switch(texID)
    {
        case 0: return uTex0.sample(uSampler0, in.inTexST)* in.inVertexColor * u.uBatchColor;
        case 1: return uTex1.sample(uSampler1, in.inTexST)* in.inVertexColor * u.uBatchColor;
        case 2: return uTex2.sample(uSampler2, in.inTexST)* in.inVertexColor * u.uBatchColor;
        case 3: return uTex3.sample(uSampler3, in.inTexST)* in.inVertexColor * u.uBatchColor;
        case 4: return uTex4.sample(uSampler4, in.inTexST)* in.inVertexColor * u.uBatchColor;
        case 5: return uTex5.sample(uSampler5, in.inTexST)* in.inVertexColor * u.uBatchColor;
        case 6: return uTex6.sample(uSampler6, in.inTexST)* in.inVertexColor * u.uBatchColor;
        case 7: return uTex7.sample(uSampler7, in.inTexST)* in.inVertexColor * u.uBatchColor;
    };
    return float4(1.0, 0.0, 1.0, 1.0);
}

// #endif