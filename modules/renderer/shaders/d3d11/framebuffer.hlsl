struct VSOut
{
    float2 inTexST : inTexST;
    float4 outPosition : SV_POSITION;
};

VSOut main(float2 pos : vPosition, float2 vTexST : vTexST)
{
    VSOut ret;
    ret.outPosition = float4(pos.x, pos.y, 0.0, 1.0);
    ret.inTexST = vTexST;
    return ret;
}

Texture2D uTex1;
SamplerState state;

float4 main(float2 inTexST : inTexST) : SV_TARGET
{
    return uTex1.Sample(state, inTexST);
}