module hip.hiprenderer.backend.metal.mtlvertex;

version(AppleOS):
import metal;
import hip.hiprenderer;
import hip.error.handler;
import hip.hiprenderer.backend.metal.mtlrenderer;
import hip.hiprenderer.backend.metal.mtlshader;


MTLResourceOptions mtlOptions(HipResourceUsage usage)
{
    final switch(usage)
    {
        case HipResourceUsage.Dynamic:
            return MTLResourceOptions.StorageModeShared;
        case HipResourceUsage.Immutable:
            return MTLResourceOptions.StorageModePrivate;
        case HipResourceUsage.Default:
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

    this(MTLDevice device, MTLCommandQueue cmdQueue, size_t size, HipResourceUsage usage, HipRendererBufferType type)
    {
        this.device = device;
        this.cmdQueue = cmdQueue;
        options = usage.mtlOptions;
        this.size = size;
        buffer = device.newBuffer(size, options);
        buffer.retain();
        _type = type;
    }
    this(MTLDevice device, MTLCommandQueue cmdQueue, const(ubyte)[] data, HipResourceUsage usage, HipRendererBufferType type)
    {
        _type = type;
        options = usage.mtlOptions;
        this.device = device;
        this.cmdQueue = cmdQueue;
        this.size = data.length;
        if(options == MTLResourceOptions.StorageModePrivate)
        {
            buffer = device.newBuffer(size, options);
            buffer.retain();
        }
        setData(data);
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

MTLVertexFormat mtlVertexFormatFromAttributeInfo(HipVertexAttributeFieldInfo i)
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
            if(i.isNormalized)
            {
                throw new Exception("Unsupported normalized uint on macOS");
                // final switch(i.count)
                // {
                //     case 1: return MTLVertexFormat.uint1Normalized;
                //     case 2: return MTLVertexFormat.uint2Normalized;
                //     case 3: return MTLVertexFormat.uint3Normalized;
                //     case 4: return MTLVertexFormat.uint4Normalized;
                // }
            }
            else
            {
                final switch(i.count)
                {
                    case 1: return MTLVertexFormat.uint1;
                    case 2: return MTLVertexFormat.uint2;
                    case 3: return MTLVertexFormat.uint3;
                    case 4: return MTLVertexFormat.uint4;
                }
            }
        case HipAttributeType.Ushort:
            if(i.isNormalized)
            {
                final switch(i.count)
                {
                    case 1: return MTLVertexFormat.ushortNormalized;
                    case 2: return MTLVertexFormat.ushort2Normalized;
                    case 3: return MTLVertexFormat.ushort3Normalized;
                    case 4: return MTLVertexFormat.ushort4Normalized;
                }
            }
            else
            {
                final switch(i.count)
                {
                    case 1: return MTLVertexFormat.ushort1;
                    case 2: return MTLVertexFormat.ushort2;
                    case 3: return MTLVertexFormat.ushort3;
                    case 4: return MTLVertexFormat.ushort4;
                }
            }
        case HipAttributeType.Short:
            if(i.isNormalized)
            {
                final switch(i.count)
                {
                    case 1: return MTLVertexFormat.shortNormalized;
                    case 2: return MTLVertexFormat.short2Normalized;
                    case 3: return MTLVertexFormat.short3Normalized;
                    case 4: return MTLVertexFormat.short4Normalized;
                }
            }
            else
            {
                final switch(i.count)
                {
                    case 1: return MTLVertexFormat.short1;
                    case 2: return MTLVertexFormat.short2;
                    case 3: return MTLVertexFormat.short3;
                    case 4: return MTLVertexFormat.short4;
                }
            }
        case HipAttributeType.Bool:
            if(i.isNormalized)
            {
                final switch(i.count)
                {
                    case 1: return MTLVertexFormat.charNormalized;
                    case 2: return MTLVertexFormat.char2Normalized;
                    case 3: return MTLVertexFormat.char3Normalized;
                    case 4: return MTLVertexFormat.char4Normalized;
                }
            }
            else
            {
                final switch(i.count)
                {
                    case 1: return MTLVertexFormat.char1;
                    case 2: return MTLVertexFormat.char2;
                    case 3: return MTLVertexFormat.char3;
                    case 4: return MTLVertexFormat.char4;
                }
            }
    }
    assert(false, "Unknown format");
}

final class HipMTLVertexArray : IHipVertexArrayImpl
{
    MTLVertexDescriptor descriptor;
    HipMTLBuffer iBuffer;

    HipMTLRenderer mtlRenderer;
    MTLDevice device;
    NSUInteger[] offsets;
    MTLBuffer[] buffers;
    HipVertexAttributeInfo[] attributes;

    this(MTLDevice device, HipMTLRenderer mtlRenderer)
    {
        this.device = device;
        this.mtlRenderer = mtlRenderer;
        descriptor = MTLVertexDescriptor.vertexDescriptor();
    }

    void bind()
    {
        if(iBuffer is null)
            return;
        iBuffer.bind();
        foreach(i, info; attributes)
            buffers[i] = (cast(HipMTLBuffer)info.vbo).buffer;
        mtlRenderer.getEncoder.setVertexBuffers(buffers.ptr, offsets.ptr, NSRange(1, attributes.length));
    }

    void unbind()
    {
        iBuffer.unbind();
        buffers[] = null;
        mtlRenderer.getEncoder.setVertexBuffers(buffers.ptr, offsets.ptr, NSRange(1, attributes.length));
    }

    /**
     * HipMTLRenderer will ALWAYS assume that:
     *  Buffer 0 is for uniforms
     *  Buffer 1 is for vertex attributes
     */
    void createInputLayout(
        HipVertexAttributeInfo[] attInfos, IHipRendererBuffer ebo,
        ShaderProgram shaderProgram
    )
    {
        import hip.console.log;
        //First buffer is reserved for uniform.
        iBuffer = cast(HipMTLBuffer)ebo;
        offsets = new NSUInteger[](attInfos.length);
        offsets[] = 0;
        attributes = attInfos;
        buffers = new MTLBuffer[attributes.length];
        hiplog("Creating input layout ");
        foreach(i, info; attInfos)
        {
            foreach(field; info.fields)
            {
                hiplog("\t",field.valueType, field.count, " ", field.isNormalized ? "@normalized " : "", field.name, " [", field.index, "]", );
                MTLVertexAttributeDescriptor attribute = descriptor.attributes[field.index];
                attribute.format = mtlVertexFormatFromAttributeInfo(field);
                attribute.offset = field.offset;
                attribute.bufferIndex = 1+i;
            }

            descriptor.layouts[1+i].stepFunction = info.isInstanced ? 
                MTLVertexStepFunction.PerInstance : 
                MTLVertexStepFunction.PerVertex;
            descriptor.layouts[1+i].stepRate = 1;
            descriptor.layouts[1+i].stride = info.vboStride;
        }

        HipMTLShaderProgram shader = (cast(HipMTLShaderProgram)shaderProgram);
        shader.createPipelineState(device, descriptor);
    }
}