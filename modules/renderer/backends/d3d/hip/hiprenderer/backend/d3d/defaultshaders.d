module hip.hiprenderer.backend.d3d.defaultshaders;
import hip.api.renderer.core;
import hip.config.renderer;

private enum D3DDefaultShadersPath = __MODULE__;

static if(!HasDirect3D)
    immutable DefaultShader[] DefaultShaders;
else:

immutable DefaultShader[] DefaultShaders = [
    HipShaderPresets.FRAME_BUFFER: DefaultShader(D3DDefaultShadersPath, &getFrameBufferShader),
    HipShaderPresets.GEOMETRY_BATCH: DefaultShader(D3DDefaultShadersPath, &getGeometryBatchShader),
    HipShaderPresets.SPRITE_BATCH: DefaultShader(D3DDefaultShadersPath, &getSpriteBatchShader, &isSpriteBatchInstanced),
    HipShaderPresets.NONE: DefaultShader(D3DDefaultShadersPath)
];

private {

    string getFrameBufferShader(ShaderEffect){return import("d3d11/framebuffer.hlsl");}
    string getGeometryBatchShader(ShaderEffect){return import("d3d11/geometrybatch.hlsl");}

    bool isSpriteBatchInstanced() {
        return true;
    }
    /**
    *   Creates a massive switch case for supporting array of textures.
    *   D3D11 causes an error if trying to access texture with a variable
    *   instead of a literal.
    */
    string getSpriteBatchShader(ShaderEffect fx)
    {
        import hip.util.conv:to;
        import hip.hiprenderer.renderer;
        int sup = HipRenderer.getMaxSupportedShaderTextures();
        string textureSlotSwitchCase = "\tswitch(tid)\n\t{\n"; //Switch textureID
        for(int i = 1; i < sup; i++)
        {
            textureSlotSwitchCase~= "\t\tcase "~ to!string(i)~": "~
            "fx.textureColor = uTex["~to!string(i)~"].Sample(state["~to!string(i)~"], texST);\n break;\n";
        }
        textureSlotSwitchCase~= "\t\tdefault: fx.textureColor = uTex[0].Sample(state[0], texST);\nbreak;\n";
        textureSlotSwitchCase~= "\n\t}";

        string ret = `
        struct VSOut
            {
                float4 inColor : inColor;
                float2 inTexST : inTexST;
                float  inTexID : inTexID;
                float4 vPosition: SV_POSITION;
            };

            cbuffer Cbuf
            {
                float4x4 uMVP: uMVP;
            };

#if INSTANCED == 0
            VSOut vertexMain(
                float3 pos   : vPosition,
                float4 col   : vColor,
                float2 texST : vTexST,
                float  texID : vTexID
                )
            {
                VSOut output;
                float4 position = float4(pos.x, pos.y, pos.z, 1.0f);
                output.vPosition = mul(position, uMVP);

                output.inTexST = texST;
                output.inColor = col;
                output.inTexID = texID;
                return output;
            }
#else
            VSOut vertexMain(
                float2 pos    : vPosition,
                int2   xy     : vXY,
                uint2 size    : vSize,
                float4 col    : vColor,
                float rotation: vRotation,
                uint z       : vZ,
                uint texID   : vTexID,
                float2 uvMin  : vUVMin,
                float2 uvMax  : vUVMax
                )
            {
                VSOut output;
                float s = sin(rotation);
                float c = cos(rotation);
                float2 actualPos = float2(
                    pos.x * c - pos.y * s,
                    pos.x * s + pos.y * c
                ) * size + xy;
                
                float4 position = float4(actualPos.x, actualPos.y, z, 1.0f);
                output.vPosition = mul(position, uMVP);
                output.inTexST = pos * uvMax + uvMin;
                output.inColor = col;
                output.inTexID = texID;
                return output;
            }

#endif

        `~ "Texture2D uTex["~to!string(sup)~"];
    SamplerState state["~to!string(sup)~"];"~q{

    struct FragmentUniformsBuffer
    {
        float4 uBatchColor;
        float2 uScreenSize;
        float uTime;
    };

    cbuffer FragmentUniforms
    {
        FragmentUniformsBuffer cbuf;
    };

    struct EffectInput
    {
        float4 textureColor;
        float4 vertexColor;
        float4 uBatchColor;
        float2 worldPosition;
    };

    /* GLOBALS_DEFINITION */
    /* EFFECT_PARAMS_DEFINITION */
    /* USER_FUNCTION */

    float4 fragmentMain(float4 inVertexColor : inColor, float2 texST : inTexST, float inTexID : inTexID) : SV_TARGET
    }~"{"~
    q{
            // return uBatchColor * uTex.Sample(state, inTexST);
            int tid = int(inTexID);
            bool isText = (tid & (1 << 15)) != 0;
            tid = tid & 0xff;
            EffectInput fx;
            fx.vertexColor = inVertexColor;
            fx.uBatchColor = cbuf.uBatchColor;

            //switch(tid)...
            //case 1:
                //return uTex[1].Sample(state[1], texST) * inVertexColor * uBatchColor;
    } ~ textureSlotSwitchCase ~ 
    q{
        if(isText)
            fx.textureColor = float4(1, 1, 1, fx.textureColor.r);
        return effect(/* EFFECT_PARAMS_CALL */); 
    } ~
    "\n}";

        import hip.util.string;
        ret = ret.replace("/* GENERATED_EXTRA_BUFFERS */", fx.getMainArguments());
        ret = ret.replace("/* EFFECT_PARAMS_DEFINITION */", fx.getEffectParamsDefinition());
        ret = ret.replace("/* EFFECT_PARAMS_CALL */", fx.getEffectParamsCall());
        ret = ret.replace("/* GLOBALS_DEFINITION */", fx.getGlobalDefinitions());
        ret = ret.replace("/* USER_FUNCTION */", fx.getSource());

        return ret;
    }
}
