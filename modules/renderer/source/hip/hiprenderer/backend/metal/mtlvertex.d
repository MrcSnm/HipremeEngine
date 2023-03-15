module hip.hiprenderer.backend.metal.mtlvertex;

import metal;
import hip.hiprenderer.vertex;
import hip.error.handler;
import metal.vertexdescriptor;
import metal.mtlshader;
import metal.metal;


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

    this(MTLDevice device, size_t count, HipBufferUsage usage)
    {
        options = usage.mtlOptions;
        buffer = device.newBuffer(length, options);
        buffer.label = "HipMTLIndexBuffer".ns;
    }
    void bind()
    {
        boundIndexBuffer = this;
    }

    void unbind()
    {
        if(boundIndexBuffer is this) boundIndexBuffer = null;
    }

    void setData(index_t count, const index_t* data)
    {
        buffer = device.newBuffer(data, count*index_t.sizeof, options);
    }

    void updateData(int offset, index_t count, const index_t* data)
    {
        buffer.contents[offset..count*index_t.sizeof] = data[0..index_t.sizeof*count];
    }
}

class HipMTLVertexBuffer : IHipVertexBufferImpl
{
    MTLBuffer buffer;
    MTLResourceOptions options;
    this(MTLDevice device, size_t size, HipBufferUsage usage)
    {
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
        buffer = newBufferWithBytes(data, size, options);
    }

    void updateData(int offset, size_t size, const void* data)
    {
        buffer.content[offset..size] = data[0..size];
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
            break;
        case HipAttributeType.INT:
            final switch(i.count)
            {
                case 1: return MTLVertexFormat.int1;
                case 2: return MTLVertexFormat.int2;
                case 3: return MTLVertexFormat.int3;
                case 4: return MTLVertexFormat.int4;
            }
            break;
        case HipAttributeType.BOOL:
            final switch(i.count)
            {
                case 1: return MTLVertexFormat.char1;
                case 2: return MTLVertexFormat.char2;
                case 3: return MTLVertexFormat.char3;
                case 4: return MTLVertexFormat.char4;
            }
            break;
    }
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
        vBuffer = vbo;
        iBuffer = ebo;
        vbo.bind();
        ebo.bind();
        cmdEncoder.setVertexBuffer(vBuffer.buffer, 0, 0);
    }

    void unbind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo)
    {
        cmdEncoder.setVertexBuffer(null, 0, 0);
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
        HipMTLShader shader = (cast(HipMTLShader)s.shaderProgram);
        shader.pipelineDescriptor.vertexDescriptor = descriptor;
        NSError err;
        shader.pipelineState = device.newRenderPipelineStateWithDescriptor(shader.pipelineState, &err);
        if(err !is null || shader.pipelineState is null)
        {
            ErrorHandler.showErrorMessage("Creating Input Layout",  "Could not create RenderPipelineState");
        }
    }
}