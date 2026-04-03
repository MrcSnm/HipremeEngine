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

    this(ulong size, HipResourceUsage usage, HipRendererBufferType type)
    {
        this.size = size;
        this.usage = getD3D11Usage(usage);
        this._type = type;
        if(usage != HipResourceUsage.Immutable)
            createBuffer(size, null);
    }
    this(const(ubyte)[] data, HipResourceUsage usage, HipRendererBufferType type)
    {
        this.size = data.length;
        this.usage = getD3D11Usage(usage);
        this._type = type;
        createBuffer(data);
    }

    void bind()
    {
        final switch(type)
        {
            case HipRendererBufferType.vertex:
                d3dCall(_hip_d3d_context.IASetVertexBuffers(0, 0, null, null, null));
                break;
            case HipRendererBufferType.index:
                _hip_d3d_context.IASetIndexBuffer(buffer, is(index_t == uint) ? DXGI_FORMAT_R32_UINT : DXGI_FORMAT_R16_UINT, 0);
                break;
            case HipRendererBufferType.uniform:
                assert(false, "Unsupported on d3d");
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
                _hip_d3d_context.IASetIndexBuffer(null, is(index_t == uint) ? DXGI_FORMAT_R32_UINT : DXGI_FORMAT_R16_UINT, 0);
                break;
            case HipRendererBufferType.uniform:
                assert(false, "Unsupported on D3D");
        }
    }
    private void createBuffer(size_t size, const(void)* data)
    {
        D3D11_BUFFER_DESC bd;
        bd.BindFlags = type == HipRendererBufferType.vertex ? D3D11_BIND_VERTEX_BUFFER : D3D11_BIND_INDEX_BUFFER;
        bd.Usage = usage;
        bd.CPUAccessFlags = getD3D11_CPUUsage(usage);
        bd.MiscFlags = 0u;
        bd.ByteWidth = cast(uint)size;
        bd.StructureByteStride = 0;

        if(data is null)
            d3dCall(_hip_d3d_device.CreateBuffer(&bd, null, &buffer));
        else
        {
            D3D11_SUBRESOURCE_DATA sd;
            sd.pSysMem = cast(void*)data;
            d3dCall(_hip_d3d_device.CreateBuffer(&bd, &sd, &buffer));
        }
    }


    bool started = false;
    void createBuffer(const void[] data)
    {
        createBuffer(data.length, data.ptr);

    }
    void setData(const(void)[] data)
    {
        if(data == null || data.length == 0)
            return;
        if(buffer)
        {
            assert(data.length <= this.size, "Do not change the buffer size after creating, as the engine is not designed for that right now");
            updateData(0, data);
        }
        else
            createBuffer(data);
    }

    ubyte[] getBuffer()
    {
        D3D11_MAPPED_SUBRESOURCE resource;
        d3dCall(_hip_d3d_context.Map(buffer, 0, D3D11_MAP_WRITE_NO_OVERWRITE, 0, &resource));
        return cast(ubyte[])resource.pData[0..size];
    }
    void unmapBuffer()
    {
        d3dCall(_hip_d3d_context.Unmap(this.buffer, 0));
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
        HipVertexAttributeInfo[] attInfos, IHipRendererBuffer ebo, ShaderProgram shaderProgram
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
            vboBuffers[i] = (cast(Hip_D3D11_Buffer)att.vbo).buffer;
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