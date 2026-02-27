cbuffer Geom
{
    float4x4 uMVP: uMVP;
};
struct VSOut
{
    float4 inVertexColor : inVertexColor;
    float4 outPosition : SV_POSITION;
};

VSOut vertexMain(float3 vPosition: vPosition, float4 vColor: vColor)
{
    VSOut ret;
    ret.outPosition = mul(float4(vPosition, 1.0), uMVP);
    ret.inVertexColor = vColor;
    return ret;
}

cbuffer FragVars
{
    float4 uGlobalColor : uGlobalColor;
};

float4 fragmentMain(float4 inVertexColor : inVertexColor) : SV_TARGET
{
    return inVertexColor * uGlobalColor;
}