module hip.hiprenderer.backend.d3d.d3dbuffer;
import hip.config.renderer;
import hip.api.renderer.vertex;
static if(HasDirect3D):
import hip.api.renderer.vertex;
import hip.hiprenderer.backend.d3d.d3drenderer;
import directx.d3d11;
/**
* For reflecting OpenGL API, we create an accessor with the create functions, this is a locally
* managed array, but you're able to get it by using the private name, for flexibility.
*/

final class HipD3D11Buffer : IHipRendererBuffer
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
        bd.BindFlags = getD3D11BufferType(type);
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
        import core.stdc.string;
        import hip.util.conv;
        import hip.error.handler;
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

int getD3D11BufferType(HipRendererBufferType type)
{
    final switch(type)
    {
        case HipRendererBufferType.index:
            return D3D11_BIND_INDEX_BUFFER;
        case HipRendererBufferType.vertex:
            return D3D11_BIND_VERTEX_BUFFER;
        case HipRendererBufferType.uniform: 
            return D3D11_BIND_CONSTANT_BUFFER;
    }
}