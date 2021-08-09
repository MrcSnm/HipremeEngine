module implementations.renderer.backend.d3d.vertex;

version(Windows):
import std.format;
import core.stdc.string;
import std.conv:to;
import error.handler;
import directx.d3d11;
import util.system;
import core.sys.windows.windows;
import implementations.renderer;
import implementations.renderer.backend.d3d.renderer;
import implementations.renderer.backend.d3d.utils;
import implementations.renderer.shader;
import implementations.renderer.backend.d3d.shader;
import implementations.renderer.vertex;
import global.consts;



/**
* For reflecting OpenGL API, we create an accessor with the create functions, this is a locally
* managed array, but you're able to get it by using the private name, for flexibility.
*/

class Hip_D3D11_VertexBufferObject : IHipVertexBufferImpl
{
    immutable D3D11_USAGE usage;
    ID3D11Buffer buffer;
    ulong size;
    this(ulong size, HipBufferUsage usage)
    {
        this.size = size;
        this.usage = getD3D11Usage(usage);
    }
    void bind(){}
    void unbind()
    {
        _hip_d3d_context.IASetVertexBuffers(0, 0, null, null, null);
    }
    void setData(ulong size, const void* data)
    {
        import std.stdio;
        this.size = size;
        D3D11_BUFFER_DESC bd;
        bd.BindFlags = D3D11_BIND_VERTEX_BUFFER;
        bd.Usage = usage;
        bd.CPUAccessFlags = getD3D11_CPUUsage(usage);
        bd.MiscFlags = 0u;
        bd.ByteWidth = cast(uint)size;
        bd.StructureByteStride = 0;

        D3D11_SUBRESOURCE_DATA sd;
        sd.pSysMem = cast(void*)data;
        //TODO: Check failure
        _hip_d3d_device.CreateBuffer(&bd, &sd, &buffer);
        HipRenderer.exitOnError();
        
        // writeln("Buffer created ", buffer);
        // _hip_d3d_context.IASetVertexBuffers(0u, 1u, &buffer, null, &obj.offset);
    }
    void updateData(int offset, ulong size, const void* data)
    {
        assert(size+offset <= this.size, format!"Tried to set data with size %s and offset %s for vertex buffer with size %s"(size, offset, this.size));
        D3D11_MAPPED_SUBRESOURCE resource;
        _hip_d3d_context.Map(buffer, 0, D3D11_MAP_WRITE_DISCARD, 0, &resource);
        memcpy(resource.pData+offset, data, size);
        _hip_d3d_context.Unmap(buffer, 0);
    }
}
class Hip_D3D11_IndexBufferObject : IHipIndexBufferImpl
{
    immutable D3D11_USAGE usage;
    ID3D11Buffer buffer;
    uint count;
    ulong size;
    this(uint count, HipBufferUsage usage)
    {
        this.size = count*uint.sizeof;
        this.count = count;
        this.usage = getD3D11Usage(usage);
    }
    void bind(){_hip_d3d_context.IASetIndexBuffer(buffer, DXGI_FORMAT_R32_UINT, 0);}
    void unbind(){_hip_d3d_context.IASetIndexBuffer(null, DXGI_FORMAT_R32_UINT, 0);}
    void setData(uint count, const uint* data)
    {
        this.size = count*uint.sizeof;
        D3D11_BUFFER_DESC bd;
        bd.BindFlags = D3D11_BIND_INDEX_BUFFER;
        bd.Usage = usage;
        bd.CPUAccessFlags = getD3D11_CPUUsage(usage);
        bd.MiscFlags = 0u;
        bd.ByteWidth = cast(uint)this.size;
        bd.StructureByteStride = 0;

        D3D11_SUBRESOURCE_DATA sd;
        sd.pSysMem = cast(void*)data;
        //TODO: Check failure
        _hip_d3d_device.CreateBuffer(&bd, &sd, &buffer);
    }
    void updateData(int offset, uint count, const uint* data)
    {
        assert(count*uint.sizeof+offset <= this.size, format!"Tried to set data with size %s and offset %s for vertex buffer with size %s"(count*uint.sizeof, offset, this.size));
        D3D11_MAPPED_SUBRESOURCE resource;
        _hip_d3d_context.Map(buffer, 0, D3D11_MAP_WRITE_DISCARD, 0, &resource);
        memcpy(resource.pData+offset, data, count*uint.sizeof);
        _hip_d3d_context.Unmap(buffer, 0);
    }
}

class Hip_D3D11_VertexArrayObject : IHipVertexArrayImpl
{
    ID3D11InputLayout inputLayout;
    D3D11_INPUT_ELEMENT_DESC[] descs;
    uint stride;
    this(){}
    void bind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo)
    {
        static uint offset = 0;
        /** It must return silently to support opengl VAO binding*/
        if(inputLayout is null)
            return;
        Hip_D3D11_VertexBufferObject v = cast(Hip_D3D11_VertexBufferObject)vbo;
        _hip_d3d_context.IASetInputLayout(inputLayout);
        _hip_d3d_context.IASetVertexBuffers(0u, 1u, &v.buffer, &stride, &offset);
        ebo.bind();
    }
    void unbind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo)
    {
        if(vbo is null)
            return;
        vbo.unbind();
        ebo.unbind();
        _hip_d3d_context.IASetInputLayout(null);
    }
    void setAttributeInfo(ref HipVertexAttributeInfo info, uint stride)
    {
        import std.string:toStringz;
        this.stride = stride;
        D3D11_INPUT_ELEMENT_DESC desc;
        desc.SemanticName = info.name.toStringz;
        desc.SemanticIndex = 0;
        // desc.SemanticIndex = info.index;
        desc.Format = _hip_d3d_getFormatFromInfo(info);
        desc.InputSlot = 0;
        desc.AlignedByteOffset = info.offset;
        desc.InputSlotClass = D3D11_INPUT_PER_VERTEX_DATA;
        desc.InstanceDataStepRate = 0;
        descs~= desc;
    }
    void createInputLayout(Shader s)
    {
        if(ErrorHandler.assertErrorMessage(s !is null, "D3D11 VAO Error", "Error at creating input layout"))
            return;
        Hip_D3D11_VertexShader vs = cast(Hip_D3D11_VertexShader)s.vertexShader;
        foreach (D3D11_INPUT_ELEMENT_DESC key; descs)
        {
            import std.conv:to;
            debug { import std.stdio : writeln; try { writeln(to!string(key.SemanticName)); } catch (Exception) {} }   
        }
        _hip_d3d_device.CreateInputLayout(descs.ptr, cast(uint)descs.length,
        vs.shader.GetBufferPointer(), vs.shader.GetBufferSize(), &inputLayout);
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
        case HipAttributeType.FLOAT:
            switch(info.count)
            {
                case 1:
                    ret = DXGI_FORMAT_R32_FLOAT;
                    break;
                case 2:
                    ret = DXGI_FORMAT_R32G32_FLOAT;
                    break;
                case 3:
                    ret = DXGI_FORMAT_R32G32B32_FLOAT;
                    break;
                case 4:
                    ret = DXGI_FORMAT_R32G32B32A32_FLOAT;
                    break;
                default:
                    ErrorHandler.showErrorMessage("DXGI Format Error",
                    "Unknown format type from float with length " ~ to!string(info.count));
            }
            break;
        case HipAttributeType.BOOL:
        case HipAttributeType.INT:
            switch(info.count)
            {
                case 1:
                    ret = DXGI_FORMAT_R32_SINT;
                    break;
                case 2:
                    ret = DXGI_FORMAT_R32G32_SINT;
                    break;
                case 3:
                    ret = DXGI_FORMAT_R32G32B32_SINT;
                    break;
                case 4:
                    ret = DXGI_FORMAT_R32G32B32A32_SINT;
                    break;
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