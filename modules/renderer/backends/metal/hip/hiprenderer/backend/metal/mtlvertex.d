module hip.hiprenderer.backend.metal.mtlvertex;

version(AppleOS):
import metal;
import hip.hiprenderer;
import hip.error.handler;
import hip.hiprenderer.backend.metal.mtlrenderer;
import hip.hiprenderer.backend.metal.mtlshader;
public import hip.hiprenderer.backend.metal.mtlbuffer;

final class HipMTLVertexArray : IHipVertexArrayImpl
{
    MTLVertexDescriptor descriptor;
    HipMTLBuffer iBuffer;

    HipMTLRenderer mtlRenderer;
    MTLDevice device;
    NSUInteger[] offsets;
    MTLBuffer[] buffers;
    HipVertexAttributeInfo[] attributes;
    bool initialized;

    this(MTLDevice device, HipMTLRenderer mtlRenderer)
    {
        this.device = device;
        this.mtlRenderer = mtlRenderer;
    }

    void dispose()
    {
        foreach(b; buffers)
            b.release();
        descriptor.release();
    }

    void bind()
    {
        foreach(i, att; attributes)
        {
            buffers[i] = (cast(HipMTLBuffer)att.vbo).buffer;
        }
        mtlRenderer.bind(this, null);
    }
    void unbind(){mtlRenderer.unbind(this, null);}
    /**
     * HipMTLRenderer will ALWAYS assume that:
     *  Buffer 0 is for uniforms
     *  Buffer 1 is for vertex attributes
     */
    void createInputLayout(
        HipVertexAttributeInfo[] attInfos, IHipRendererBuffer ebo,
        HipShaderProgram shaderProgram
    )
    {
        import hip.console.log;
        if(attInfos.length == 0)
            throw new Error("Can't have 0 attribute infos.");
        //First buffer is reserved for uniform.
        descriptor = MTLVertexDescriptor.alloc.initialize();
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
            import std.stdio;
            writeln = (cast(HipMTLBuffer)info.vbo);
            if((cast(HipMTLBuffer)info.vbo).buffer is null)
                throw new Error("Can't be null.");
            buffers[i] = (cast(HipMTLBuffer)info.vbo).buffer;
        }
        initialized = true;
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
