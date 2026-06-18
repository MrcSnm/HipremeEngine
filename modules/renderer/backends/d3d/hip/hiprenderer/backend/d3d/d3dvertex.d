/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.backend.d3d.d3dvertex;

import hip.config.renderer;
static if(HasDirect3D):

import hip.util.string:toStringz;
import core.stdc.string;
import hip.util.conv:to;
import hip.error.handler;
import directx.d3d11;
import hip.util.system;
import hip.hiprenderer;
import hip.hiprenderer.backend.d3d.d3drenderer;
import hip.api.renderer.shader;
import hip.hiprenderer.backend.d3d.d3dshader;
import hip.config.opts;
import hip.hiprenderer.backend.d3d.d3dbuffer;




final class Hip_D3D11_VertexArrayObject : IHipVertexArrayImpl
{
    ID3D11InputLayout inputLayout;
    IHipRendererBuffer ebo;
    HipVertexAttributeInfo[] attInfos;

    ID3D11Buffer[] vboBuffers;
    UINT[] strides;
    UINT[] offsets;
    

    this(){}
    void bind()
    {
        assert(inputLayout !is null, "D3D11 Input Layout wasn't created yet. Don't bind before calling createInputLayout");
        d3dCall(_hip_d3d_context.IASetInputLayout(inputLayout));
        d3dCall(_hip_d3d_context.IASetVertexBuffers(0u, cast(UINT)vboBuffers.length, vboBuffers.ptr, strides.ptr, offsets.ptr));
        this.ebo.bind();
    }
    void unbind()
    {
        if(ebo is null)
            return;
        d3dCall(_hip_d3d_context.IASetInputLayout(null));
        foreach(info; attInfos)
            info.vbo.unbind();
        ebo.unbind();
    }
    void createInputLayout(
        HipVertexAttributeInfo[] attInfos, IHipRendererBuffer ebo, HipShaderProgram shaderProgram
    )
    {
        if(ErrorHandler.assertErrorMessage(shaderProgram !is null, "D3D11 VAO Error", "Error at creating input layout"))
            return;
        this.ebo = ebo;
        this.attInfos = attInfos;
        HipD3D11VertexShader vs = (cast(Hip_D3D11_ShaderProgram)shaderProgram).vertex;

        int inputElementCount = 0;
        foreach(att; attInfos)
            foreach(field; att.fields)
                inputElementCount++;

        int index = 0;
        D3D11_INPUT_ELEMENT_DESC[] descs = new D3D11_INPUT_ELEMENT_DESC[inputElementCount];
        vboBuffers = new ID3D11Buffer[attInfos.length];
        strides = new UINT[attInfos.length];
        offsets = new UINT[attInfos.length];
        foreach(i, att; attInfos)
        {
            foreach(field; att.fields)
            {
                ref D3D11_INPUT_ELEMENT_DESC desc = descs[index++];
                desc.SemanticName = field.name.toStringz;
                desc.SemanticIndex = 0;
                // desc.SemanticIndex = field.index;
                desc.Format = _hip_d3d_getFormatFromInfo(field);
                desc.InputSlot = cast(int)i;
                desc.AlignedByteOffset = field.offset;
                // desc.InputSlotClass = D3D11_INPUT_PER_VERTEX_DATA;
                // desc.InstanceDataStepRate = 0;
                desc.InputSlotClass = att.isInstanced ? D3D11_INPUT_PER_INSTANCE_DATA : D3D11_INPUT_PER_VERTEX_DATA;
                desc.InstanceDataStepRate = att.isInstanced ? 1 : 0;
            }
            vboBuffers[i] = (cast(HipD3D11Buffer)att.vbo).buffer;
            assert(vboBuffers[i]);
            strides[i] = att.vboStride;
            offsets[i] = 0;
        }
        d3dCall(_hip_d3d_device.CreateInputLayout(descs.ptr, cast(uint)descs.length,
        vs.blob.GetBufferPointer(), vs.blob.GetBufferSize(), &inputLayout));
        import core.memory;
        GC.free(descs.ptr);

    }
}

private DXGI_FORMAT _hip_d3d_getFormatFromInfo(ref HipVertexAttributeFieldInfo info)
{
    DXGI_FORMAT ret;
    final switch(info.valueType)
    {
        case HipAttributeType.Rgba32:
            return DXGI_FORMAT_R8G8B8A8_UNORM;
        case HipAttributeType.Float:
            switch(info.count)
            {
                case 1: ret = DXGI_FORMAT_R32_FLOAT; break;
                case 2: ret = DXGI_FORMAT_R32G32_FLOAT; break;
                case 3: ret = DXGI_FORMAT_R32G32B32_FLOAT; break;
                case 4: ret = DXGI_FORMAT_R32G32B32A32_FLOAT; break;
                default:
                    ErrorHandler.showErrorMessage("DXGI Format Error",
                    "Unknown format type from float with length " ~ to!string(info.count));
            }
            break;
        case HipAttributeType.Uint:
            switch(info.count)
            {
                case 1: ret = DXGI_FORMAT_R32_UINT; break;
                default:
                    ErrorHandler.showErrorMessage("DXGI Format Error",
                    "Unknown format type from uint with length " ~ to!string(info.count));
            }
            break;
        case HipAttributeType.Ushort:
            if(info.isNormalized)
            {
                switch(info.count)
                {
                    case 1: ret = DXGI_FORMAT_R16_UNORM; break;
                    case 2: ret = DXGI_FORMAT_R16G16_UNORM; break;
                    case 4: ret = DXGI_FORMAT_R16G16B16A16_UNORM; break;
                    default: ErrorHandler.showErrorMessage("DXGI Format Error", "Unknown format with count "~to!string(info.count));
                }
            }
            else
            {
                switch(info.count)
                {
                    case 1: ret = DXGI_FORMAT_R16_UINT; break;
                    case 2: ret = DXGI_FORMAT_R16G16_UINT; break;
                    case 4: ret = DXGI_FORMAT_R16G16B16A16_UINT; break;
                    default: ErrorHandler.showErrorMessage("DXGI Format Error", "Unknown format with count "~to!string(info.count));
                }
            }
            break;
        case HipAttributeType.Short:
            if(info.isNormalized)
            {
                switch(info.count)
                {
                    case 1: ret = DXGI_FORMAT_R16_SNORM; break;
                    case 2: ret = DXGI_FORMAT_R16G16_SNORM; break;
                    case 4: ret = DXGI_FORMAT_R16G16B16A16_SNORM; break;
                    default: ErrorHandler.showErrorMessage("DXGI Format Error", "Unknown format with count "~to!string(info.count));
                }
            }
            else
            {
                switch(info.count)
                {
                    case 1: ret = DXGI_FORMAT_R16_SINT; break;
                    case 2: ret = DXGI_FORMAT_R16G16_SINT; break;
                    case 4: ret = DXGI_FORMAT_R16G16B16A16_SINT; break;
                    default: ErrorHandler.showErrorMessage("DXGI Format Error", "Unknown format with count "~to!string(info.count));
                }
            }
            break;
        case HipAttributeType.Bool:
        case HipAttributeType.Int:
            switch(info.count)
            {
                case 1: ret = DXGI_FORMAT_R32_SINT; break;
                case 2: ret = DXGI_FORMAT_R32G32_SINT; break;
                case 3: ret = DXGI_FORMAT_R32G32B32_SINT; break;
                case 4: ret = DXGI_FORMAT_R32G32B32A32_SINT; break;
                default:
                    ErrorHandler.showErrorMessage("DXGI Format Error",
                    "Unknown format type from int/bool with length " ~ to!string(info.count));
            }
            break;
    }
    return ret;
}