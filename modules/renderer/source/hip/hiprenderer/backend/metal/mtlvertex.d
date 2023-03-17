module hip.hiprenderer.backend.metal.mtlvertex;

import metal;
import hip.hiprenderer;
import hip.error.handler;
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
class HipMTLIndexBuffer : IHipIndexBufferImpl
{
    MTLBuffer buffer;
    MTLResourceOptions options;
    MTLCommandQueue cmdQueue;
    MTLDevice device;

    this(MTLDevice device, MTLCommandQueue cmdQueue, size_t length, HipBufferUsage usage)
    {
        this.device = device;
        this.cmdQueue = cmdQueue;
        options = usage.mtlOptions;
        buffer = device.newBuffer(length, options);
    }
    void bind()
    {
        boundIndexBuffer = buffer;
    }

    void unbind()
    {
        if(boundIndexBuffer is buffer) boundIndexBuffer = null;
    }

    void setData(index_t count, const index_t* data)
    {
        if(options == MTLResourceOptions.StorageModePrivate)
        {
            MTLBuffer temp = device.newBuffer(data, count*index_t.sizeof, MTLResourceOptions.StorageModeShared);
            MTLCommandBuffer cmdBuffer = cmdQueue.commandBuffer;
            MTLBlitCommandEncoder cmdEncoder = cmdBuffer.blitCommandEncoder;
            cmdEncoder.copyFromBuffer(temp, 0, buffer, 0, count*index_t.sizeof);
            cmdEncoder.endEncoding();
            cmdBuffer.commit();
        }
        else
        {
            if(buffer) buffer.dealloc();
            buffer = device.newBuffer(data, count*index_t.sizeof, options);
        }
    }

    void updateData(int offset, index_t count, const index_t* data)
    {
        buffer.contents[offset..count*index_t.sizeof] = cast(void[])data[0..count];
    }
}

class HipMTLVertexBuffer : IHipVertexBufferImpl
{
    MTLBuffer buffer;
    MTLCommandQueue cmdQueue;
    MTLResourceOptions options;
    MTLDevice device;

    this(MTLDevice device, MTLCommandQueue cmdQueue, size_t size, HipBufferUsage usage)
    {
        this.device = device;
        this.cmdQueue = cmdQueue;
        options = usage.mtlOptions;
        buffer = device.newBuffer(size, options);
    }
    void bind()
    {
        
    }

    void unbind()
    {
        
    }

    void setData(size_t size, const void* data)
    {
        if(options == MTLResourceOptions.StorageModePrivate)
        {
            MTLBuffer temp = device.newBuffer(data, size, MTLResourceOptions.StorageModeShared);
            MTLCommandBuffer cmdBuffer = cmdQueue.commandBuffer;
            MTLBlitCommandEncoder cmdEncoder = cmdBuffer.blitCommandEncoder;
            cmdEncoder.copyFromBuffer(temp, 0, buffer, 0, size);
            cmdEncoder.endEncoding();
            cmdBuffer.commit();
        }
        else
        {
            if(buffer) buffer.dealloc();
            buffer = device.newBuffer(data, size, options);
        }
    }

    void updateData(int offset, size_t size, const void* data)
    {
        buffer.contents[offset..size] = data[0..size];
    }
}

MTLVertexFormat mtlVertexFormatFromAttributeInfo(HipVertexAttributeInfo i)
{
    final switch(i.valueType)
    {
        case HipAttributeType.FLOAT:
            final switch(i.count)
            {
                case 1: return MTLVertexFormat.float1;
                case 2: return MTLVertexFormat.float2;
                case 3: return MTLVertexFormat.float3;
                case 4: return MTLVertexFormat.float4;
            }
        case HipAttributeType.INT:
            final switch(i.count)
            {
                case 1: return MTLVertexFormat.int1;
                case 2: return MTLVertexFormat.int2;
                case 3: return MTLVertexFormat.int3;
                case 4: return MTLVertexFormat.int4;
            }
        case HipAttributeType.BOOL:
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

class HipMTLVertexArray : IHipVertexArrayImpl
{
    MTLVertexDescriptor descriptor;
    HipMTLVertexBuffer vBuffer;
    HipMTLIndexBuffer iBuffer;

    MTLRenderCommandEncoder cmdEncoder;
    MTLDevice device;

    this(MTLDevice device, MTLRenderCommandEncoder cmdEncoder)
    {
        this.device = device;
        this.cmdEncoder = cmdEncoder;
        descriptor = MTLVertexDescriptor.vertexDescriptor();
        descriptor.layouts[0].stepFunction = MTLVertexStepFunction.PerVertex;
        descriptor.layouts[0].stepRate = 1;
    }

    void bind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo)
    {
        vBuffer = cast(HipMTLVertexBuffer)vbo;
        iBuffer = cast(HipMTLIndexBuffer)ebo;
        vbo.bind();
        ebo.bind();
        cmdEncoder.setVertexBuffer(vBuffer.buffer, 0, 1);
    }

    void unbind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo)
    {
        cmdEncoder.setVertexBuffer(null, 0, 1);
        vbo.unbind();
        ebo.unbind();
        vBuffer = null;
        iBuffer = null;
    }

    void setAttributeInfo(ref HipVertexAttributeInfo info, uint stride)
    {
        MTLVertexAttributeDescriptor attribute = descriptor.attributes[info.index];
        descriptor.layouts[0].stride = stride;
        attribute.format = mtlVertexFormatFromAttributeInfo(info);
        attribute.offset = info.offset;

    }

    void createInputLayout(Shader s)
    {
        HipMTLShaderProgram shader = (cast(HipMTLShaderProgram)s.shaderProgram);
        shader.pipelineDescriptor.vertexDescriptor = descriptor;
        NSError err;
        shader.pipelineState = device.newRenderPipelineStateWithDescriptor(shader.pipelineDescriptor, &err);
        if(err !is null || shader.pipelineState is null)
        {
            ErrorHandler.showErrorMessage("Creating Input Layout",  "Could not create RenderPipelineState");
        }
    }
}