module implementations.renderer.backend.d3d.shader;

version(Windows):
import implementations.renderer.shader;
import implementations.renderer.backend.d3d.renderer;
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
}
class Hip_D3D11_ShaderProgram : ShaderProgram
{
    Hip_D3D11_VertexShader vs;
    Hip_D3D11_FragmentShader fs;
}

class D3D11_ShaderImpl : IShader
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
        Hip_D3D11_ShaderProgram prog;
        return prog;
    }

    bool compileShader(ref ID3DBlob shaderPtr, string shaderPrefix, string shaderSource)
    {
        shaderSource~="\0";
        char* source = cast(char*)shaderSource.ptr; 

        //No #includes

        uint compile_flags = 0;
        uint effects_flags = 0;
        ID3DBlob shader = null;
        ID3DBlob error = null;
        shaderPrefix~= "_3_0\0"; //Append version on shader type


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

        if(ErrorHandler.assertErrorMessage(!FAILED(hr), "Shader compilation error", "Compilation failed"))
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
        auto vs = cast(Hip_D3D11_VertexShader)_vs;
        bool ret = compileShader(vs.shader, "vs", shaderSource);
        if(ret)
        {
            auto res = _hip_d3d_device.CreateVertexShader(vs.shader.GetBufferPointer(), vs.shader.GetBufferSize(), null, &vs.vs);
            ErrorHandler.assertErrorMessage(!FAILED(res), "Vertex shader creation error", "Creation failed");
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
            ErrorHandler.assertErrorMessage(!FAILED(res), "Fragment/Pixel shader creation error", "Creation failed");
        }
        return ret;
    }

    bool linkProgram(ref ShaderProgram _program, VertexShader vs,  FragmentShader fs)
    {
        auto program = cast(Hip_D3D11_ShaderProgram)_program;
        program.vs = cast(Hip_D3D11_VertexShader)vs;
        program.fs = cast(Hip_D3D11_FragmentShader)fs;
        return true;
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

        _hip_d3d_context.OMSetRenderTargets(1u, &_hip_d3d_mainRenderTarget, null);
    }

    void useShader(ShaderProgram program){setCurrentShader(program);}
    void deleteShader(FragmentShader* _fs)
    {
        auto fs = cast(Hip_D3D11_FragmentShader)*_fs;
        fs.shader.Release();
        fs.shader = null;
        fs.fs.Release();
        fs.fs = null;
    }
    void deleteShader(VertexShader* _vs)
    {
        auto vs = cast(Hip_D3D11_VertexShader)*_vs;
        vs.shader.Release();
        vs.shader = null;
        vs.vs.Release();
        vs.vs = null;
    }
}