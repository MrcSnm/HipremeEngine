/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.backend.d3d.d3dshader;

import hip.config.renderer;
static if(HasDirect3D):

import hip.config.opts;
import hip.hiprenderer.renderer;
import hip.api.renderer.texture;
import hip.hiprenderer.shader;
import hip.hiprenderer.backend.d3d.d3drenderer;
import hip.util.system:getWindowsErrorMessage;
import directx.d3d11;
import directx.d3dcompiler;
import directx.d3d11shader;
import hip.util.conv:to;
import hip.error.handler;

struct HipD3D11PixelShader
{
    ID3DBlob blob;
    ID3D11PixelShader shader;
}

struct HipD3D11VertexShader
{
    ID3DBlob blob;
    ID3D11VertexShader shader;
}

class Hip_D3D11_ShaderProgram : ShaderProgram
{
    HipD3D11VertexShader vertex;
    HipD3D11PixelShader pixel;

    protected HipBlendFunction blendSrc, blendDst;
    protected HipBlendEquation blendEq;
    protected ID3D11BlendState blendState;

    ID3D11ShaderReflection vReflector;
    ID3D11ShaderReflection pReflector;

    bool initialize()
    {
        import hip.hiprenderer;
        auto hres = D3DReflect(vertex.blob.GetBufferPointer(),
        vertex.blob.GetBufferSize(), &IID_ID3D11ShaderReflection, cast(void**)&vReflector);
        if(FAILED(hres))
        {
            ErrorHandler.showErrorMessage("D3D11 ShaderProgram initialization",
            "Could not get the reflection interface from the vertex shader, error: "~ getWindowsErrorMessage(hres));
            return false;
        }
        hres = D3DReflect(pixel.blob.GetBufferPointer(),
        pixel.blob.GetBufferSize(), &IID_ID3D11ShaderReflection, cast(void**)&pReflector);
        if(FAILED(hres))
        {
            ErrorHandler.showErrorMessage("D3D11 ShaderProgram initialization",
            "Could not get the reflection interface from the pixel shader, error: "~ getWindowsErrorMessage(hres));
            return false;
        }
        return true;
    }

    override void dispose()
    {
        if(vertex.blob !is null)    vertex.blob.Release();
        if(pixel.blob !is null)     pixel.blob.Release();
        if(vertex.shader !is null)  vertex.shader.Release();
        if(pixel.shader !is null)   pixel.shader.Release();
        pixel.blob = vertex.blob = null;
        vertex.shader = null;
        pixel.shader = null;
    }
}

struct Hip_D3D11_ShaderVarAdditionalData
{
    ID3D11Buffer buffer;
    uint id;
}

package D3D11_BLEND getD3DBlendFunc(HipBlendFunction func)
{
    final switch(func) with(HipBlendFunction)
    {
        case  ZERO: return D3D11_BLEND_ZERO;
        case  ONE: return D3D11_BLEND_ONE;

        case  SRC_COLOR: return D3D11_BLEND_SRC_COLOR;
        case  ONE_MINUS_SRC_COLOR: return D3D11_BLEND_INV_SRC_COLOR;

        case  DST_COLOR: return D3D11_BLEND_DEST_COLOR;
        case  ONE_MINUS_DST_COLOR: return D3D11_BLEND_INV_DEST_COLOR;

        case  SRC_ALPHA: return D3D11_BLEND_SRC_ALPHA;
        case  ONE_MINUS_SRC_ALPHA: return  D3D11_BLEND_INV_SRC_ALPHA;

        case  DST_ALPHA: return  D3D11_BLEND_DEST_ALPHA;
        case  ONE_MINUS_DST_ALPHA: return D3D11_BLEND_INV_DEST_ALPHA;

        case  CONSTANT_COLOR: return D3D11_BLEND_SRC1_COLOR;
        case  ONE_MINUS_CONSTANT_COLOR: return D3D11_BLEND_INV_SRC1_COLOR;

        case  CONSTANT_ALPHA: return D3D11_BLEND_SRC1_ALPHA;
        case  ONE_MINUS_CONSTANT_ALPHA: return D3D11_BLEND_INV_SRC1_ALPHA;
    }
}
package D3D11_BLEND_OP getD3DBlendEquation(HipBlendEquation eq)
{
    final switch(eq) with (HipBlendEquation)
    {
        case DISABLED:return D3D11_BLEND_OP_ADD;
        case ADD:return D3D11_BLEND_OP_ADD;
        case SUBTRACT:return D3D11_BLEND_OP_SUBTRACT;
        case REVERSE_SUBTRACT:return D3D11_BLEND_OP_REV_SUBTRACT;
        case MIN:return D3D11_BLEND_OP_MIN;
        case MAX:return D3D11_BLEND_OP_MAX;
    }
}

class Hip_D3D11_ShaderImpl : IShader
{
    import hip.util.data_structures:Pair;

    private bool compileShader(ref ID3DBlob shaderPtr, string shaderPrefix, string shaderSource)
    {
        string shaderType = shaderPrefix == "ps" ? "Pixel Shader" : "Vertex Shader";
        const(char)* func = shaderPrefix == "ps" ? "fragmentMain" : "vertexMain";

        //No #includes
        import hip.util.data_structures:staticArray;

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

        const defines =
        [
            cast(D3D_SHADER_MACRO)null, cast(D3D_SHADER_MACRO)null
        ].staticArray;

        HRESULT hr = D3DCompile(shaderSource.ptr, shaderSource.length, null,
        defines.ptr, null, func,  shaderPrefix.ptr, compile_flags, effects_flags, &shader, &error);
        shaderPtr = shader;

        if(ErrorHandler.assertLazyErrorMessage(SUCCEEDED(hr), shaderType~" compilation error", "Compilation failed"))
        {
            if(error !is null)
            {
                string errMessage = to!string(cast(char*)error.GetBufferPointer());
                ErrorHandler.showErrorMessage("Shader Source Error: ", shaderSource);
                ErrorHandler.showErrorMessage("Compilation error:", errMessage);
                error.Release();
            }
            if(shader)
                shader.Release();
            return false;
        }
        return true;
    }
    private bool compileShaderType(ref Hip_D3D11_ShaderProgram program, string shaderSource, ShaderTypes type)
    {
        assert(type == ShaderTypes.fragment || type == ShaderTypes.vertex, "Unsupported shader type.");
        HRESULT res = 0;
        ID3DBlob blob;
        switch(type)
        {
            case ShaderTypes.vertex:
                if(!compileShader(program.vertex.blob, "vs", shaderSource))
                    return false;
                blob = program.vertex.blob;
                res = _hip_d3d_device.CreateVertexShader(blob.GetBufferPointer(), blob.GetBufferSize(), null, &program.vertex.shader);
                break;
            case ShaderTypes.fragment:
                if(!compileShader(program.pixel.blob, "ps", shaderSource))
                    return false;
                blob = program.pixel.blob;
                res = _hip_d3d_device.CreatePixelShader(blob.GetBufferPointer(), blob.GetBufferSize(), null, &program.pixel.shader);
                break;
            default: throw new Exception("Unsupported shader type.");
        }

        if(ErrorHandler.assertErrorMessage(SUCCEEDED(res), "Shader creation error", "Creation failed"))
        {
            ErrorHandler.showErrorMessage("Shader Error:", getWindowsErrorMessage(res));
            return false;
        }
        return true;
    }

    ShaderProgram buildShader(string shaderSource, string shaderPath)
    {
        Hip_D3D11_ShaderProgram prog = new Hip_D3D11_ShaderProgram();
        prog.name = shaderPath;
        compileShaderType(prog, shaderSource, ShaderTypes.vertex);
        compileShaderType(prog, shaderSource, ShaderTypes.fragment);
        prog.initialize();
        return prog;
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

    void bind(ShaderProgram _program)
    {
        Hip_D3D11_ShaderProgram p = cast(Hip_D3D11_ShaderProgram)_program;
        if(p.blendState !is null &&
            (p.blendDst != currDst ||
            p.blendSrc != currSrc ||
            p.blendEq != currEq))
        {
            currEq  = p.blendEq;
            currSrc = p.blendSrc;
            currDst = p.blendDst;
            _hip_d3d_context.OMSetBlendState(p.blendState, null, 0xFF_FF_FF_FF);
        }
        _hip_d3d_context.VSSetShader(p.vertex.shader, cast(ID3D11ClassInstance*)0, 0u);
        _hip_d3d_context.PSSetShader(p.pixel.shader, cast(ID3D11ClassInstance*)0, 0u);
    }
    void unbind(ShaderProgram _program)
    {
        _hip_d3d_context.VSSetShader(null, cast(ID3D11ClassInstance*)0, 0u);
        _hip_d3d_context.PSSetShader(null, cast(ID3D11ClassInstance*)0, 0u);
    }

    int getId(ref ShaderProgram prog, string name, ShaderVariablesLayout layout)
    {
        import hip.error.handler;
        Hip_D3D11_ShaderProgram p = cast(Hip_D3D11_ShaderProgram)prog;
        D3D11_SHADER_INPUT_BIND_DESC output;


        if(!SUCCEEDED(p.vReflector.GetResourceBindingDescByName(name.ptr, &output)))
        {
            ErrorHandler.showErrorMessage("Error finding ID/Uniform for shader ", "For variable named "~name ~ " in shader " ~ prog.name);
        }


        return output.BindPoint;
    }

    void sendVars(ref ShaderProgram prog, ShaderVariablesLayout[string] layouts)
    {
        D3D11_SHADER_INPUT_BIND_DESC desc;
        Hip_D3D11_ShaderProgram p = cast(Hip_D3D11_ShaderProgram)prog;
        foreach(k, l; layouts)
        {
            import core.stdc.string:memcpy;
            Hip_D3D11_ShaderVarAdditionalData* data = cast(Hip_D3D11_ShaderVarAdditionalData*)l.getAdditionalData();

            if(l.isDirty)
            {
                D3D11_MAPPED_SUBRESOURCE resource;
                _hip_d3d_context.Map(data.buffer, 0, D3D11_MAP_WRITE_DISCARD, 0, &resource);
                memcpy(resource.pData, l.getBlockData(), l.getLayoutSize());
                _hip_d3d_context.Unmap(data.buffer,  0);
                l.isDirty = false;
            }


            ErrorHandler.assertExit(data != null, "D3D11 ShaderVarAdditionalData is null, can't send variables");

            final switch(l.shaderType)
            {
                case ShaderTypes.fragment:
                    p.pReflector.GetResourceBindingDescByName(l.nameStringz, &desc);
                    _hip_d3d_context.PSSetConstantBuffers(desc.BindPoint, 1, &data.buffer);
                    break;
                case ShaderTypes.vertex:
                    p.vReflector.GetResourceBindingDescByName(l.nameStringz, &desc);
                    _hip_d3d_context.VSSetConstantBuffers(desc.BindPoint, 1, &data.buffer);
                    break;
                case ShaderTypes.geometry:
                case ShaderTypes.none:
                    break;
            }
        }
    }

    void bindArrayOfTextures(ref ShaderProgram prog, IHipTexture[] textures, string varName)
    {
        foreach(i, texture; textures)
            texture.bind(cast(int)i);
    }

    void createVariablesBlock(ref ShaderVariablesLayout layout, ShaderProgram shaderProgram)
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

        Hip_D3D11_ShaderVarAdditionalData* d = new Hip_D3D11_ShaderVarAdditionalData;
        HRESULT res = _hip_d3d_device.CreateBuffer(&desc, &data, &d.buffer);
        layout.setAdditionalData(cast(void*)d, true);

        if(FAILED(res))
            ErrorHandler.showErrorMessage("D3D11 Error while creating variables block",
            "Error while creating variable buffer for Shader with type "~to!string(layout.shaderType));
    }

    protected __gshared HipBlendFunction currSrc, currDst;
    protected __gshared HipBlendEquation currEq;


    void setBlending(ShaderProgram prog, HipBlendFunction src, HipBlendFunction dest, HipBlendEquation eq)
    {
        Hip_D3D11_ShaderProgram p = cast(Hip_D3D11_ShaderProgram)prog;
        p.blendSrc = src;
        p.blendDst = dest;
        p.blendEq = eq;
        auto b = &Hip_D3D11_Renderer.blend.RenderTarget[0];

        if(eq == HipBlendEquation.DISABLED)
        {
            b.BlendEnable = cast(int)false;
        }
        else
        {
            b.BlendEnable = cast(int)true;
            b.SrcBlend = getD3DBlendFunc(src);
            b.DestBlend = getD3DBlendFunc(dest);
            b.BlendOp = getD3DBlendEquation(eq);
            b.BlendOpAlpha = getD3DBlendEquation(eq);

            b.SrcBlendAlpha = getD3DBlendFunc(HipBlendFunction.ZERO);
            b.DestBlendAlpha = getD3DBlendFunc(HipBlendFunction.ZERO);
            b.BlendOp = getD3DBlendEquation(HipBlendEquation.ADD);
            b.BlendOpAlpha = getD3DBlendEquation(HipBlendEquation.ADD);
            b.RenderTargetWriteMask = D3D11_COLOR_WRITE_ENABLE_ALL;
        }
        _hip_d3d_device.CreateBlendState(&Hip_D3D11_Renderer.blend, &p.blendState);
    }
    bool setShaderVar(ShaderVar* sv, ShaderProgram prog, void* value)
    {
        return false;
    }

    override void onRenderFrameEnd(ShaderProgram){}


}