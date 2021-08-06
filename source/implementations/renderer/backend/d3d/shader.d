module implementations.renderer.backend.d3d.shader;

version(Windows):
import global.consts;
import implementations.renderer.shader;
import implementations.renderer.backend.d3d.renderer;
import implementations.renderer.backend.d3d.utils;
import directx.d3d11;
import directx.d3dcompiler;
import std.conv:to;
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
    override final string getFrameBufferFragment(){return getDefaultFragment();}
    override final string getGeometryBatchFragment()
    {
        return this.getDefaultFragment();
    }
    override final string getSpriteBatchFragment()
    {
        return this.getDefaultFragment();
    }
    override final string getBitmapTextFragment(){return getDefaultFragment();}
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
    override final string getFrameBufferVertex(){return getDefaultVertex();}
    override final string getGeometryBatchVertex()
    {
        return this.getDefaultVertex();
    }
    override final string getSpriteBatchVertex()
    {
        return q{
            cbuffer Cbuf
            {
                float4x4 uProj;
                float4x4 uModel;
                float4x4 uView;
            };

            float4 main(float2 pos : Position) : SV_POSITION
            {
                return mul(mul(float4(pos.x, pos.y, 0.0f, 1.0f), uModel), uProj);
            }
        };
    }
    override final string getBitmapTextVertex(){return getDefaultVertex();}
}
class Hip_D3D11_ShaderProgram : ShaderProgram
{
    Hip_D3D11_VertexShader vs;
    Hip_D3D11_FragmentShader fs;

    ID3D11ShaderReflection vReflector;
    ID3D11ShaderReflection pReflector;

    bool initialize()
    {
        import implementations.renderer;
        import std.stdio;
        auto hres = D3DReflect(vs.shader.GetBufferPointer(),
        vs.shader.GetBufferSize(), &IID_ID3D11ShaderReflection, cast(void**)&vReflector);
        if(FAILED(hres))
        {
            ErrorHandler.showErrorMessage("D3D11 ShaderProgram initialization", 
            "Could not get the reflection interface from the vertex shader, error: "~ Hip_D3D11_GetErrorMessage(hres));
            return false;
        }
        hres = D3DReflect(fs.shader.GetBufferPointer(),
        fs.shader.GetBufferSize(), &IID_ID3D11ShaderReflection, cast(void**)&pReflector);
        if(FAILED(hres))
        {
            ErrorHandler.showErrorMessage("D3D11 ShaderProgram initialization", 
            "Could not get the reflection interface from the pixel shader, error: "~ Hip_D3D11_GetErrorMessage(hres));
            return false;
        }
        return true;
    }
}

class Hip_D3D11_ShaderImpl : IShader
{
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
            if(error)
            {
                ErrorHandler.showErrorMessage("Compilation error:", to!string(error.GetBufferPointer()));
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
                ErrorHandler.showErrorMessage("Vertex Shader Error:", Hip_D3D11_GetErrorMessage(res));
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
                ErrorHandler.showErrorMessage("Fragment Shader Error:", Hip_D3D11_GetErrorMessage(res));
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
        import std.stdio;
        Hip_D3D11_ShaderProgram p = cast(Hip_D3D11_ShaderProgram)prog;
        D3D11_SHADER_INPUT_BIND_DESC output;
        p.vReflector.GetResourceBindingDescByName("Cbuf", &output);
        writeln(output);
        return -1;
    }
    void setVertexVar(int id, int val){}
    void setVertexVar(int id, bool val){}
    void setVertexVar(int id, float val){}
    void setVertexVar(int id, double val){}
    void setVertexVar(int id, float[2] val){}
    void setVertexVar(int id, float[3] val){}
    void setVertexVar(int id, float[4] val){}
    void setVertexVar(int id, float[9] val){}
    void setVertexVar(int id, float[16] val){}
    

    void setFragmentVar(int id, int val){}
    void setFragmentVar(int id, bool val){}
    void setFragmentVar(int id, float val){}
    void setFragmentVar(int id, double val){}
    void setFragmentVar(int id, float[2] val){}
    void setFragmentVar(int id, float[3] val){}
    void setFragmentVar(int id, float[4] val){}
    void setFragmentVar(int id, float[9] val){}
    void setFragmentVar(int id, float[16] val){}

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