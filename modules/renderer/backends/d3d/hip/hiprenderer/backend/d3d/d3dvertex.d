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
import hip.hiprenderer.shader;
import hip.hiprenderer.backend.d3d.d3dshader;
import hip.hiprenderer.vertex;
import hip.config.opts;



/**
* For reflecting OpenGL API, we create an accessor with the create functions, this is a locally
* managed array, but you're able to get it by using the private name, for flexibility.
*/

final class Hip_D3D11_Buffer : IHipRendererBuffer
{
    immutable D3D11_USAGE usage;
    ID3D11Buffer buffer;
    ulong size;
    HipRendererBufferType _type;

    HipRendererBufferType type() const { return _type; }

    this(ulong size, HipBufferUsage usage, HipRendererBufferType type)
    {
        this.size = size;
        this.usage = getD3D11Usage(usage);
        this._type = type;
    }
    void bind()
    {
        final switch(type)
        {
            case HipRendererBufferType.vertex:
                d3dCall(_hip_d3d_context.IASetVertexBuffers(0, 0, null, null, null));
                break;
            case HipRendererBufferType.index:
                static if(is(index_t == uint))
                    _hip_d3d_context.IASetIndexBuffer(buffer, DXGI_FORMAT_R32_UINT, 0);
                else
                    _hip_d3d_context.IASetIndexBuffer(buffer, DXGI_FORMAT_R16_UINT, 0);
                break;
        }
    }
    void unbind()
    {
        final switch(type)
        {
            case HipRendererBufferType.vertex:
                d3dCall(_hip_d3d_context.IASetVertexBuffers(0, 0, null, null, null));
                break;
            case HipRendererBufferType.index:
                static if(is(index_t == uint))
                    _hip_d3d_context.IASetIndexBuffer(null, DXGI_FORMAT_R32_UINT, 0);
                else
                    _hip_d3d_context.IASetIndexBuffer(null, DXGI_FORMAT_R16_UINT, 0);
                break;
        }
    }


    bool started = false;
    void createBuffer(const void[] data)
    {
        started = true;
        this.size = data.length;
        D3D11_BUFFER_DESC bd;
        bd.BindFlags = type == HipRendererBufferType.vertex ? D3D11_BIND_VERTEX_BUFFER : D3D11_BIND_INDEX_BUFFER;
        bd.Usage = usage;
        bd.CPUAccessFlags = getD3D11_CPUUsage(usage);
        bd.MiscFlags = 0u;
        bd.ByteWidth = cast(uint)size;
        bd.StructureByteStride = 0;

        D3D11_SUBRESOURCE_DATA sd;
        sd.pSysMem = cast(void*)data.ptr;

        //TODO: Check failure

        d3dCall(_hip_d3d_device.CreateBuffer(&bd, &sd, &buffer));

    }
    void setData(const(void)[] data)
    {
        if(data == null || data.length == 0)
            return;
        createBuffer(data);
    }
    void updateData(int offset, const (void)[] data)
    {
        if(data.length + offset > this.size)
        {
            ErrorHandler.assertExit(false,
            "Tried to set data with size "~to!string(size)~" and offset "~to!string(offset)~
            "for vertex buffer with size "~to!string(this.size));
        }

        D3D11_MAPPED_SUBRESOURCE resource;
        d3dCall(_hip_d3d_context.Map(buffer, 0, D3D11_MAP_WRITE_DISCARD, 0, &resource));
        memcpy(resource.pData+offset, data.ptr, data.length);
        d3dCall(_hip_d3d_context.Unmap(buffer, 0));
    }
}
final class Hip_D3D11_VertexArrayObject : IHipVertexArrayImpl
{
    ID3D11InputLayout inputLayout;
    uint stride;
    this(){}
    void bind(IHipRendererBuffer vbo, IHipRendererBuffer ebo)
    {
        static uint offset = 0;
        assert(inputLayout !is null, "D3D11 Input Layout wasn't created yet. Don't bind before calling createInputLayout");
        Hip_D3D11_Buffer v = cast(Hip_D3D11_Buffer)vbo;
        d3dCall(_hip_d3d_context.IASetInputLayout(inputLayout));
        d3dCall(_hip_d3d_context.IASetVertexBuffers(0u, 1u, &v.buffer, &stride, &offset));
        ebo.bind();
    }
    void unbind(IHipRendererBuffer vbo, IHipRendererBuffer ebo)
    {
        if(vbo is null)
            return;
        vbo.unbind();
        ebo.unbind();
        d3dCall(_hip_d3d_context.IASetInputLayout(null));
    }
    void createInputLayout(
        IHipRendererBuffer, IHipRendererBuffer,
        HipVertexAttributeInfo[] attInfos, uint stride,
        VertexShader vertexShader, ShaderProgram shaderProgram
    )
    {
        if(ErrorHandler.assertErrorMessage(shaderProgram !is null, "D3D11 VAO Error", "Error at creating input layout"))
            return;
        Hip_D3D11_VertexShader vs = cast(Hip_D3D11_VertexShader)vertexShader;
        this.stride = stride;

        D3D11_INPUT_ELEMENT_DESC[] descs = new D3D11_INPUT_ELEMENT_DESC[attInfos.length];
        foreach(i, ref desc; descs)
        {
            HipVertexAttributeInfo info = attInfos[i];
            desc.SemanticName = info.name.toStringz;
            desc.SemanticIndex = 0;
            // desc.SemanticIndex = info.index;
            desc.Format = _hip_d3d_getFormatFromInfo(info);
            desc.InputSlot = 0;
            desc.AlignedByteOffset = info.offset;
            desc.InputSlotClass = D3D11_INPUT_PER_VERTEX_DATA;
            desc.InstanceDataStepRate = 0;
        }
        d3dCall(_hip_d3d_device.CreateInputLayout(descs.ptr, cast(uint)descs.length,
        vs.shader.GetBufferPointer(), vs.shader.GetBufferSize(), &inputLayout));

        import core.memory;
        GC.free(descs.ptr);
    }
}

private int getD3D11Usage(HipBufferUsage usage)
{
    switch(usage) with(HipBufferUsage)
    {
        default:
        case DEFAULT:
            return D3D11_USAGE_DEFAULT;
        case DYNAMIC:
            return D3D11_USAGE_DYNAMIC;
        case STATIC:
            return D3D11_USAGE_IMMUTABLE;
    }
}

private int getD3D11_CPUUsage(D3D11_USAGE usage)
{
    switch(usage)
    {
        default:
        case D3D11_USAGE_DEFAULT:
            return D3D11_CPU_ACCESS_READ | D3D11_CPU_ACCESS_WRITE;
        case D3D11_USAGE_DYNAMIC:
            return D3D11_CPU_ACCESS_WRITE;
        case D3D11_USAGE_IMMUTABLE:
            return 0;
    }
}

private DXGI_FORMAT _hip_d3d_getFormatFromInfo(ref HipVertexAttributeInfo info)
{
    DXGI_FORMAT ret;
    switch(info.valueType)
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
        default:
            ErrorHandler.showErrorMessage("DXGI Format Error", "Unknown format type from info");
            break;
    }
    return ret;
}