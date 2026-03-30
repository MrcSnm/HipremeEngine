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
    HipShaderPresets.BITMAP_TEXT: DefaultShader(D3DDefaultShadersPath, &getBitmapTextShader),
    HipShaderPresets.NONE: DefaultShader(D3DDefaultShadersPath)
];

private {

    string getFrameBufferShader(){return import("d3d11/framebuffer.hlsl");}
    string getGeometryBatchShader(){return import("d3d11/geometrybatch.hlsl");}
    string getBitmapTextShader(){return import("d3d11/bitmaptext.hlsl");}

    bool isSpriteBatchInstanced() {
        return true;
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

#ifndef INSTANCED
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
                float2 xy     : vXY,
                float2 size   : vSize,
                float4 col    : vColor,
                float  z      : vZ,
                float rotation: vRotation,
                float texID   : vTexID
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
                output.inTexST = pos;
                output.inColor = col;
                output.inTexID = texID;
                return output;
            }

#endif

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
}
