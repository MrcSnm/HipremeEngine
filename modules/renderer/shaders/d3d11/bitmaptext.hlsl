cbuffer Cbuf
{
    float4x4 uMVP;
};

struct VSOut
{
    float2 inTexST : inTexST;
    float4 outPosition : SV_POSITION;
};

VSOut vertexMain(float2 vPosition : vPosition, float2 vTexST : vTexST)
{
    VSOut ret;
    ret.outPosition = mul(float4(vPosition, 1.0, 1.0), uMVP);
    ret.inTexST = vTexST;
    return ret;
}

cbuffer FragVars
{
    float4 uColor : uColor;
};

Texture2D uSampler1;
SamplerState state;

float4 fragmentMain(float2 inTexST : inTexST) : SV_TARGET
{
    //The texture is read as monochromatic
    float r = uSampler1.Sample(state, inTexST)[0];

    return float4(r,r,r,r) * uColor;
}