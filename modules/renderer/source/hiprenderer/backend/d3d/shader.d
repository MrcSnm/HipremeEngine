/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hiprenderer.backend.d3d.shader;

version(Windows):
import config.opts;
import hiprenderer.renderer;
import hiprenderer.shader;
import hiprenderer.backend.d3d.renderer;
import util.system:getWindowsErrorMessage;
import directx.d3d11;
import directx.d3dcompiler;
import directx.d3d11shader;
import util.conv:to;
import error.handler;


class Hip_D3D11_FragmentShader : FragmentShader
{
    ID3DBlob shader;
    ID3D11PixelShader fs;
    override final string getDefaultFragment()
    {
        return q{
        float4 main() : SV_TARGET
        {
            return float4(1.0f, 1.0f, 1.0f, 1.0f);
        }};
    }
    override final string getFrameBufferFragment()
    {
        return q{
            Texture2D uTex1;
            SamplerState state;

            float4 main(float2 inTexST : inTexST) : SV_TARGET
            {
                return uTex1.Sample(state, inTexST);
            }
        };
    }
    override final string getGeometryBatchFragment()
    {
        return q{

            cbuffer FragVars
            {
                float4 uGlobalColor : uGlobalColor;
            };

            float4 main(float4 inVertexColor : inVertexColor) : SV_TARGET
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
    override final string getSpriteBatchFragment()
    {
        int sup = HipRenderer.getMaxSupportedShaderTextures();
        string textureSlotSwitchCase = "switch(tid)\n{\n"; //Switch textureID
        for(int i = 1; i < sup; i++)
        {
            textureSlotSwitchCase~= "case "~ to!string(i)~": "~
            "return uTex1["~to!string(i)~"].Sample(state["~to!string(i)~"], texST) * inVexterColor * uBatchColor";
        }
        textureSlotSwitchCase~= "\ndefault:\n\treturn uTex1[0].Sample(state[0], texST) * inVertexColor * uBatchColor;";
        textureSlotSwitchCase~= "}";

        return "Texture2D uTex1["~to!string(sup)~"];
        SamplerState state["~to!string(sup)~q{

            cbuffer input
            {
                float4 uBatchColor: uBatchColor;
            };

            float4 main(float4 inVertexColor : inColor, float2 texST : inTexST, float inTexID : inTexID) : SV_TARGET
        }~"{"~
        q{
                // return uBatchColor * uTex1.Sample(state, inTexST);
                int tid = int(inTexID);

                //switch(tid)...
                //case 1:
                    //return uTex1[1].Sample(state[1], texST) * inVertexColor * uBatchColor;
        } ~ textureSlotSwitchCase ~ "}";
    }
    override final string getBitmapTextFragment()
    {
        return q{

            Texture2D uSampler1;
            SamplerState state;

            float4 main(float2 inTexST : inTexST) : SV_TARGET
            {
                return uSampler1.Sample(state, inTexST);
            }
        };
    }
}
class Hip_D3D11_VertexShader : VertexShader
{
    ID3DBlob shader;
    ID3D11VertexShader vs;

    override final string getDefaultVertex()
    {
        return q{
        float4 main(float2 pos : Position) : SV_POSITION
        {
            return float4(pos.x, pos.y, 0.0f, 1.0f);
        }};
    }
    override final string getFrameBufferVertex()
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
        };
    }
    override final string getGeometryBatchVertex()
    {
        return q{

            cbuffer Geom
            {
                float4x4 uModel: uModel;
                float4x4 uView : uView;
                float4x4 uProj : uProj;
            };
            struct VSOut
            {
                float4 inVertexColor : inVertexColor;
                float4 outPosition : SV_POSITION;
            };

            VSOut main(float3 vPosition: vPosition, float4 vColor: vColor)
            {
                VSOut ret;
                ret.outPosition = mul(float4(vPosition, 1.0), mul(mul(uModel, uView), uProj));
                ret.inVertexColor = vColor;
                return ret;
            }
        };
    }
    override final string getSpriteBatchVertex()
    {
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
                float4x4 uProj;
                float4x4 uModel;
                float4x4 uView;
            };

            VSOut main(
                float3 pos   : vPosition,
                float4 col   : vColor,
                float2 texST : vTexST,
                float  texID : vTexID
                )
            {
                VSOut output;
                float4 position = float4(pos.x, pos.y, pos.z, 1.0f);
                output.vPosition = mul(position, mul(mul(uModel, uView), uProj));

                output.inTexST = texST;
                output.inColor = col;
                output.inTexID = texID;
                return output;
            }
        };
    }
    override final string getBitmapTextVertex()
    {
        return q{

            cbuffer Cbuf
            {
                float4x4 uModel;
                float4x4 uView;
                float4x4 uProj;
            };

            struct VSOut
            {
                float2 inTexST : inTexST;
                float4 outPosition : SV_POSITION;
            };

            VSOut main(float2 vPosition : vPosition, float2 vTexST : vTexST)
            {
                VSOut ret;
                ret.outPosition = mul(float4(vPosition, 1.0, 1.0), mul(mul(uModel, uView), uProj));
                ret.inTexST = vTexST;
                return ret;
            }
        };
    }
}
class Hip_D3D11_ShaderProgram : ShaderProgram
{
    Hip_D3D11_VertexShader vs;
    Hip_D3D11_FragmentShader fs;

    ID3D11ShaderReflection vReflector;
    ID3D11ShaderReflection pReflector;

    bool initialize()
    {
        import hiprenderer;
        auto hres = D3DReflect(vs.shader.GetBufferPointer(),
        vs.shader.GetBufferSize(), &IID_ID3D11ShaderReflection, cast(void**)&vReflector);
        if(FAILED(hres))
        {
            ErrorHandler.showErrorMessage("D3D11 ShaderProgram initialization", 
            "Could not get the reflection interface from the vertex shader, error: "~ getWindowsErrorMessage(hres));
            return false;
        }
        hres = D3DReflect(fs.shader.GetBufferPointer(),
        fs.shader.GetBufferSize(), &IID_ID3D11ShaderReflection, cast(void**)&pReflector);
        if(FAILED(hres))
        {
            ErrorHandler.showErrorMessage("D3D11 ShaderProgram initialization", 
            "Could not get the reflection interface from the pixel shader, error: "~ getWindowsErrorMessage(hres));
            return false;
        }
        return true;
    }
}

struct Hip_D3D11_ShaderVarAdditionalData
{
    ID3D11Buffer buffer;
    uint id;
}

class Hip_D3D11_ShaderImpl : IShader
{
    import util.data_structures:Pair;
    FragmentShader createFragmentShader()
    {
        Hip_D3D11_FragmentShader fs = new Hip_D3D11_FragmentShader();
        fs.shader = null;
        fs.fs = null;
        return cast(FragmentShader)fs;
    }
    VertexShader createVertexShader()
    {
        Hip_D3D11_VertexShader vs = new Hip_D3D11_VertexShader();
        vs.shader = null;
        vs.vs = null;
        return cast(VertexShader)vs;
    }
    ShaderProgram createShaderProgram()
    {
        Hip_D3D11_ShaderProgram prog = new Hip_D3D11_ShaderProgram();
        return prog;
    }

    bool compileShader(ref ID3DBlob shaderPtr, string shaderPrefix, string shaderSource)
    {
        shaderSource~="\0";
        char* source = cast(char*)shaderSource.ptr; 

        //No #includes

        uint compile_flags = D3DCOMPILE_ENABLE_STRICTNESS;
        uint effects_flags = 0;
        ID3DBlob shader = null;
        ID3DBlob error = null;
        shaderPrefix~= "_5_0\0"; //Append version on shader type


        static if(HIP_DEBUG)
        {
            compile_flags|= D3DCOMPILE_WARNINGS_ARE_ERRORS;
            compile_flags|= D3DCOMPILE_DEBUG;
            compile_flags|= D3DCOMPILE_SKIP_OPTIMIZATION;
        }
        else static if(HIP_OPTIMIZE)
            compile_flags|= D3DCOMPILE_OPTIMIZATION_LEVEL3;

        const D3D_SHADER_MACRO[] defines = 
        [
            cast(D3D_SHADER_MACRO)null, cast(D3D_SHADER_MACRO)null
        ];

        HRESULT hr = D3DCompile(source, shaderSource.length+1, null,
        defines.ptr, null, "main",  shaderPrefix.ptr, compile_flags, effects_flags, &shader, &error);
        shaderPtr = shader;

        if(ErrorHandler.assertErrorMessage(SUCCEEDED(hr), "Shader compilation error", "Compilation failed"))
        {
            if(error !is null)
            {
                string errMessage = to!string(cast(char*)error.GetBufferPointer());
                ErrorHandler.showErrorMessage("Compilation error:", errMessage);
                error.Release();
            }
            if(shader)
                shader.Release();
            return false;
        }
        return true;
    }
    bool compileShader(VertexShader _vs, string shaderSource)
    {
        Hip_D3D11_VertexShader vs = cast(Hip_D3D11_VertexShader)_vs;
        bool ret = compileShader(vs.shader, "vs", shaderSource);
        if(ret)
        {
            auto res = _hip_d3d_device.CreateVertexShader(vs.shader.GetBufferPointer(),
            vs.shader.GetBufferSize(), null, &vs.vs);
            if(ErrorHandler.assertErrorMessage(SUCCEEDED(res), "Vertex shader creation error", "Creation failed"))
            {
                ErrorHandler.showErrorMessage("Vertex Shader Error:", getWindowsErrorMessage(res));
                res = false;
            }
        }
        return ret;
    }
    bool compileShader(FragmentShader _fs, string shaderSource)
    {
        auto fs = cast(Hip_D3D11_FragmentShader)_fs;
        bool ret = compileShader(fs.shader, "ps", shaderSource);
        if(ret)
        {
            auto res = _hip_d3d_device.CreatePixelShader(fs.shader.GetBufferPointer(), fs.shader.GetBufferSize(), null, &fs.fs);
            if(ErrorHandler.assertErrorMessage(SUCCEEDED(res), "Fragment/Pixel shader creation error", "Creation failed"))
            {
                ErrorHandler.showErrorMessage("Fragment Shader Error:", getWindowsErrorMessage(res));
                ret = false;
            }
        }
        return ret;
    }

    bool linkProgram(ref ShaderProgram _program, VertexShader vs,  FragmentShader fs)
    {
        auto program = cast(Hip_D3D11_ShaderProgram)_program;
        program.vs = cast(Hip_D3D11_VertexShader)vs;
        program.fs = cast(Hip_D3D11_FragmentShader)fs;
        return program.initialize();
    }


    /**
    *   params:
    *       layoutIndex: The layout index defined on shader
    *       valueAmount: How many values using, for 3 vertices, you can use 3
    *       dataType: Which data type to send
    *       normalize: If it will normalize
    *       stride: Target value amount in bytes, for instance, vec3 is float.sizeof*3
    *       offset: It will be calculated for each value index
    *       
    */
    void sendVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset)
    {
        // glVertexAttribPointer(layoutIndex, valueAmount, dataType, normalize, stride, cast(void*)offset);
        // glEnableVertexAttribArray(layoutIndex);
    }

    void setCurrentShader(ShaderProgram _program)
    {
        auto program = cast(Hip_D3D11_ShaderProgram)_program;
        _hip_d3d_context.VSSetShader(program.vs.vs, cast(ID3D11ClassInstance*)0, 0u);
        _hip_d3d_context.PSSetShader(program.fs.fs, cast(ID3D11ClassInstance*)0, 0u);
    }

    void useShader(ShaderProgram program){setCurrentShader(program);}
    int getId(ref ShaderProgram prog, string name)
    {
        Hip_D3D11_ShaderProgram p = cast(Hip_D3D11_ShaderProgram)prog;
        D3D11_SHADER_INPUT_BIND_DESC output;
        p.vReflector.GetResourceBindingDescByName(name.ptr, &output);
        return output.BindPoint;
    }

    void sendVars(ref ShaderProgram prog, in ShaderVariablesLayout[string] layouts)
    {
        D3D11_SHADER_INPUT_BIND_DESC desc;
        Hip_D3D11_ShaderProgram p = cast(Hip_D3D11_ShaderProgram)prog;
        foreach(k, _; layouts)
        {
            import core.stdc.string:memcpy;
            ShaderVariablesLayout l = cast(ShaderVariablesLayout)layouts[k];
            Hip_D3D11_ShaderVarAdditionalData* data = cast(Hip_D3D11_ShaderVarAdditionalData*)l.getAdditionalData();
            D3D11_MAPPED_SUBRESOURCE resource;
            _hip_d3d_context.Map(data.buffer, 0, D3D11_MAP_WRITE_DISCARD, 0, &resource);
            memcpy(resource.pData, l.getBlockData(), l.getLayoutSize());
            _hip_d3d_context.Unmap(data.buffer,  0);
            
            ErrorHandler.assertExit(data != null, "D3D11 ShaderVarAdditionalData is null, can't send variables");
            
            final switch(l.shaderType)
            {
                case ShaderTypes.FRAGMENT:
                    p.pReflector.GetResourceBindingDescByName((l.name~"\0").ptr, &desc);
                    _hip_d3d_context.PSSetConstantBuffers(desc.BindPoint, 1, &data.buffer);
                    break;
                case ShaderTypes.VERTEX:
                    p.vReflector.GetResourceBindingDescByName((l.name~"\0").ptr, &desc);
                    _hip_d3d_context.VSSetConstantBuffers(desc.BindPoint, 1, &data.buffer);
                    break;
                case ShaderTypes.GEOMETRY:
                case ShaderTypes.NONE:
                    break;
            }
        }
    }

    void initTextureSlots(ref ShaderProgram prog, Texture texture, string varName, int slotsCount)
    {
        for(int i = 0; i < slotsCount; i++)
            texture.bind(i);
            
    }

    void createVariablesBlock(ref ShaderVariablesLayout layout)
    {
        import core.stdc.stdlib:malloc;
        D3D11_BUFFER_DESC desc;
        desc.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
        desc.StructureByteStride=0;
        desc.MiscFlags = 0;
        desc.Usage = D3D11_USAGE_DYNAMIC;
        desc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
        desc.ByteWidth = cast(uint)layout.getLayoutSize();
        D3D11_SUBRESOURCE_DATA data;
        data.pSysMem = layout.getBlockData();

        Hip_D3D11_ShaderVarAdditionalData* d = cast(Hip_D3D11_ShaderVarAdditionalData*)
            malloc(Hip_D3D11_ShaderVarAdditionalData.sizeof);
        HRESULT res = _hip_d3d_device.CreateBuffer(&desc, &data, &d.buffer);
        layout.setAdditionalData(cast(void*)d, true);

        if(FAILED(res))
            ErrorHandler.showErrorMessage("D3D11 Error while creating variables block",
            "Error while creating variable buffer for Shader with type "~to!string(layout.shaderType));
    }

    void deleteShader(FragmentShader* _fs){}
    void deleteShader(VertexShader* _vs){}
    void dispose(ref ShaderProgram prog)
    {
        Hip_D3D11_ShaderProgram p = cast(Hip_D3D11_ShaderProgram)prog;
        auto fs = p.fs;
        if(fs.shader !is null)
            fs.shader.Release();
        fs.shader = null;
        if(fs.fs !is null)
            fs.fs.Release();
        fs.fs = null;
        auto vs = p.vs;
        if(vs.shader !is null)
            vs.shader.Release();
        vs.shader = null;
        if(vs.vs !is null)
            vs.vs.Release();
        vs.vs = null;
    }
}