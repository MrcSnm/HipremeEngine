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
    HipShaderPresets.SPRITE_BATCH: DefaultShader(D3DDefaultShadersPath, &getSpriteBatchShader),
    HipShaderPresets.BITMAP_TEXT: DefaultShader(D3DDefaultShadersPath, &getBitmapTextShader),
    HipShaderPresets.NONE: DefaultShader(D3DDefaultShadersPath)
];

private {

    string getFrameBufferShader()
    {
        return q{
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
        };
    }
    string getGeometryBatchShader()
    {
        return q{
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
        };
    }
    /**
    *   Creates a massive switch case for supporting array of textures.
    *   D3D11 causes an error if trying to access texture with a variable
    *   instead of a literal.
    */
    string getSpriteBatchShader()
    {
        import hip.util.conv:to;
        import hip.hiprenderer.renderer;
        int sup = HipRenderer.getMaxSupportedShaderTextures();
        string textureSlotSwitchCase = "\tswitch(tid)\n\t{\n"; //Switch textureID
        for(int i = 1; i < sup; i++)
        {
            textureSlotSwitchCase~= "\t\tcase "~ to!string(i)~": "~
            "return uTex["~to!string(i)~"].Sample(state["~to!string(i)~"], texST) * inVertexColor * uBatchColor;\n";
        }
        textureSlotSwitchCase~= "\t\tdefault: return uTex[0].Sample(state[0], texST) * inVertexColor * uBatchColor;";
        textureSlotSwitchCase~= "\n\t}";

        return q{
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
        }~ "Texture2D uTex["~to!string(sup)~"];
    SamplerState state["~to!string(sup)~"];"~q{
    cbuffer input
    {
        float4 uBatchColor: uBatchColor;
    };

    float4 fragmentMain(float4 inVertexColor : inColor, float2 texST : inTexST, float inTexID : inTexID) : SV_TARGET
    }~"{"~
    q{
            // return uBatchColor * uTex.Sample(state, inTexST);
            int tid = int(inTexID);

            //switch(tid)...
            //case 1:
                //return uTex[1].Sample(state[1], texST) * inVertexColor * uBatchColor;
    } ~ textureSlotSwitchCase ~ "\n}";
    }


    string getBitmapTextShader()
    {
        return q{

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
        };
    }
}
