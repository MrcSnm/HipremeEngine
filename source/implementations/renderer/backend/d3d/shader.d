module implementations.renderer.backend.d3d.shader;

version(Windows):
import implementations.renderer.backend.d3d.renderer;
import directx.d3d11;
import std.conv:to;
import error.handler;

struct FragmentShader
{
    ID3DBlob* shader;
    ID3D11PixelShader* fs;
}
struct VertexShader
{
    ID3DBlob* shader;
    ID3D11VertexShader* vs;
}
struct ShaderProgram
{
    VertexShader vs;
    FragmentShader fs;
}

enum DEFAULT_FRAGMENT = q{
    
    float4 main() : SV_TARGET
    {
        return float4(1.0f, 1.0f, 1.0f, 1.0f);
    }
};
enum DEFAULT_VERTEX = q{
   float4 main(float2 pos : Position) : SV_POSITION
   {
       return float4(pos.x, pos.y, 0.0f, 1.0f);
   }
};


FragmentShader createFragmentShader()
{
    FragmentShader fs;
    fs.shader = null;
    fs.fs = null;
    return fs;
}

VertexShader createVertexShader()
{
    VertexShader vs;
    vs.shader = null;
    vs.vs = null;
    return vs;
}


ShaderProgram createShaderProgram()
{
    ShaderProgram prog;
    return prog;
}

bool compileShader(ref ID3DBlob* shaderPtr, string shaderPrefix, string shaderSource)
{
    shaderSource~="\0";
    char* source = cast(char*)shaderSource.ptr; 

    //No #includes

    uint compile_flags = 0;
    uint effects_flags = 0;
    ID3DBlob* shader = null;
    ID3DBlob* error = null;
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
        null, null
    ];

    HRESULT hr = D3DCompile(source, shaderSource.length+1, defines.ptr,
    null, null, "main",  shaderPrefix.ptr, compile_flags, effects_flags, &shader, &errors);
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
bool compileShader(VertexShader vs, string shaderSource)
{
    bool ret = compileShader(vs.shader, "vs", shaderSource);
    if(ret)
    {
        auto res = _hip_d3d_device.CreateVertexShader(vs.shader.getBufferPointer(), vs.shader.getBufferSize(), null, &vs.vs);
        ErrorHandler.assertErrorMessage(!FAILED(res), "Vertex shader creation error", "Creation failed");
    }
    return ret;
}
bool compileShader(FragmentShader fs, string shaderSource)
{
    bool ret = compileShader(fs.shader, "ps", shaderSource);
    if(ret)
    {
        auto res = _hip_d3d_device.CreatePixelShader(fs.shader.getBufferPointer(), fs.shader.getBufferSize(), null, &fs.fs);
        ErrorHandler.assertErrorMessage(!FAILED(res), "Fragment/Pixel shader creation error", "Creation failed");
    }
    return ret;
}

bool linkProgram(ref ShaderProgram program, VertexShader vs,  FragmentShader fs)
{
    program.vs = vs;
    program.fs = fs;
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

void setCurrentShader(ShaderProgram program)
{
    _hip_d3d_context.VSSetShader(*program.vs.vs, cast(ID3D11ClassInstance*)0, 0u);
    _hip_d3d_context.PSSetShader(*program.fs.fs, cast(ID3D11ClassInstance*)0, 0u);

    _hip_d3d_context.OMSetRenderTargets(1u, &_hip_d3d_mainRenderTarget, null);
}

void useShader(ShaderProgram program){setCurrentShader(program);}
void deleteShader(FragmentShader* fs)
{
    fs.shader.Release();
    fs.shader = null;
    fs.fs.Release();
    fs.fs = null;
}
void deleteShader(VertexShader* vs)
{
    vs.shader.Release();
    vs.shader = null;
    vs.vs.Release();
    vs.vs = null;
    
}