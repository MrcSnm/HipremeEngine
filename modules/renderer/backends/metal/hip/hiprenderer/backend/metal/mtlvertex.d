module hip.hiprenderer.backend.metal.mtlvertex;

version(AppleOS):
import metal;
import hip.hiprenderer;
import hip.error.handler;
import hip.hiprenderer.backend.metal.mtlrenderer;
import hip.hiprenderer.backend.metal.mtlshader;


MTLResourceOptions mtlOptions(HipBufferUsage usage)
{
    final switch(usage)
    {
        case HipBufferUsage.DYNAMIC:
            return MTLResourceOptions.StorageModeShared;
        case HipBufferUsage.STATIC:
            return MTLResourceOptions.StorageModePrivate;
        case HipBufferUsage.DEFAULT:
            return MTLResourceOptions.DefaultCache;
    }
}


__gshared MTLBuffer boundIndexBuffer;
final class HipMTLBuffer : IHipRendererBuffer
{
    MTLBuffer buffer;
    MTLCommandQueue cmdQueue;
    MTLResourceOptions options;
    MTLDevice device;
    HipRendererBufferType _type;
    size_t size;

    this(MTLDevice device, MTLCommandQueue cmdQueue, size_t size, HipBufferUsage usage, HipRendererBufferType type)
    {
        this.device = device;
        this.cmdQueue = cmdQueue;
        options = usage.mtlOptions;
        this.size = size;
        buffer = device.newBuffer(size, options);
        buffer.retain();
        _type = type;
    }
    HipRendererBufferType type() const { return _type; }
    void bind()
    {
        if(type == HipRendererBufferType.index)
            boundIndexBuffer = buffer;
    }
    void unbind()
    {
        if(type == HipRendererBufferType.index && boundIndexBuffer is buffer) boundIndexBuffer = null;
    }
    void setData(const void[] data)
    {
        if(options == MTLResourceOptions.StorageModePrivate)
        {
            MTLBuffer temp = device.newBuffer(data.ptr, data.length, MTLResourceOptions.StorageModeShared);
            MTLCommandBuffer cmdBuffer = cmdQueue.defaultCommandBuffer();
            MTLBlitCommandEncoder cmdEncoder = cmdBuffer.blitCommandEncoder;
            cmdEncoder.copyFromBuffer(temp, 0, buffer, 0, data.length);
            cmdEncoder.endEncoding();
            cmdBuffer.commit();
            cmdBuffer.waitUntilCompleted();
            if(cmdBuffer.error)
                NSLog("Command Buffer Error: %@".ns, cmdBuffer.error);
        }
        else
        {
            if(buffer) buffer.release();
            buffer = device.newBuffer(data.ptr, data.length, options);
            buffer.retain();
            size = data.length;
        }
    }

    ubyte[] getBuffer(){return cast(ubyte[])buffer.contents[0..size];}
    void unmapBuffer(){}

    void updateData(int offset, const void[] data)
    {
        buffer.contents[offset..offset+data.length] = data[];
    }
}

MTLVertexFormat mtlVertexFormatFromAttributeInfo(HipVertexAttributeInfo i)
{
    final switch(i.valueType)
    {
        case HipAttributeType.Rgba32: return MTLVertexFormat.uchar4Normalized;
        case HipAttributeType.Float:
            final switch(i.count)
            {
                case 1: return MTLVertexFormat.float1;
                case 2: return MTLVertexFormat.float2;
                case 3: return MTLVertexFormat.float3;
                case 4: return MTLVertexFormat.float4;
            }
        case HipAttributeType.Int:
            final switch(i.count)
            {
                case 1: return MTLVertexFormat.int1;
                case 2: return MTLVertexFormat.int2;
                case 3: return MTLVertexFormat.int3;
                case 4: return MTLVertexFormat.int4;
            }
        case HipAttributeType.Uint:
            final switch(i.count)
            {
                case 1: return MTLVertexFormat.uint1;
                case 2: return MTLVertexFormat.uint2;
                case 3: return MTLVertexFormat.uint3;
                case 4: return MTLVertexFormat.uint4;
            }
        case HipAttributeType.Bool:
            final switch(i.count)
            {
                case 1: return MTLVertexFormat.char1;
                case 2: return MTLVertexFormat.char2;
                case 3: return MTLVertexFormat.char3;
                case 4: return MTLVertexFormat.char4;
            }
    }
    assert(false, "Unknown format");
}

final class HipMTLVertexArray : IHipVertexArrayImpl
{
    MTLVertexDescriptor descriptor;
    HipMTLBuffer vBuffer;
    HipMTLBuffer iBuffer;

    HipMTLRenderer mtlRenderer;
    MTLDevice device;

    this(MTLDevice device, HipMTLRenderer mtlRenderer)
    {
        this.device = device;
        this.mtlRenderer = mtlRenderer;
        descriptor = MTLVertexDescriptor.vertexDescriptor();
        descriptor.layouts[1].stepFunction = MTLVertexStepFunction.PerVertex;
        descriptor.layouts[1].stepRate = 1;
    }

    void bind(IHipRendererBuffer vbo, IHipRendererBuffer ebo)
    {
        if(vbo is null || ebo is null)
            return;
        vBuffer = cast(HipMTLBuffer)vbo;
        iBuffer = cast(HipMTLBuffer)ebo;
        vbo.bind();
        ebo.bind();
        mtlRenderer.getEncoder.setVertexBuffer(vBuffer.buffer, 0, 1);
    }

    void unbind(IHipRendererBuffer vbo, IHipRendererBuffer ebo)
    {
        mtlRenderer.getEncoder.setVertexBuffer(null, 0, 1);
        vbo.unbind();
        ebo.unbind();
        vBuffer = null;
        iBuffer = null;
    }

    /** 
     * HipMTLRenderer will ALWAYS assume that:
     *  Buffer 0 is for uniforms
     *  Buffer 1 is for vertex attributes
     */
    void createInputLayout(
        IHipRendererBuffer, IHipRendererBuffer,
        HipVertexAttributeInfo[] attInfos, uint stride,
        VertexShader vertexShader, ShaderProgram shaderProgram
    )
    {
        descriptor.layouts[1].stride = stride;
        foreach(info; attInfos)
        {
            MTLVertexAttributeDescriptor attribute = descriptor.attributes[info.index];
            attribute.format = mtlVertexFormatFromAttributeInfo(info);
            attribute.offset = info.offset;
            attribute.bufferIndex = 1;
        }

        HipMTLShaderProgram shader = (cast(HipMTLShaderProgram)shaderProgram);
        shader.createInputLayout(device, descriptor);
    }
}