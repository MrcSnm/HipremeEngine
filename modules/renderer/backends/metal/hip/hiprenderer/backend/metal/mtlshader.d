module hip.hiprenderer.backend.metal.mtlshader;

version(AppleOS):

import hip.hiprenderer;
import hip.console.log;
import metal;
import metal.metal;
import hip.hiprenderer.backend.metal.mtlrenderer;
import hip.hiprenderer.backend.metal.mtltexture;

class HipMTLFragmentShader : FragmentShader
{
    this(MTLDevice device){}
    string shaderSource;
}

struct BufferedMTLBuffer
{
    MTLBuffer[] buffer;
    ShaderVariablesLayout layout;
    uint currentBuffer;

    MTLBuffer getBuffer() => buffer[currentBuffer];
    void reset(){currentBuffer = 0;}
}

class HipMTLVertexShader : VertexShader
{
    this(MTLDevice device){}
    string shaderSource;
}

MTLBlendOperation fromHipBlendEquation(HipBlendEquation eq)
{
    final switch(eq) with(HipBlendEquation)
    {
        case DISABLED: return MTLBlendOperation.Add;
        case ADD: return MTLBlendOperation.Add;
        case SUBTRACT: return MTLBlendOperation.Subtract;
        case REVERSE_SUBTRACT: return MTLBlendOperation.ReverseSubtract;
        case MIN: return MTLBlendOperation.Min;
        case MAX: return MTLBlendOperation.Max;
    }
}

MTLBlendFactor fromHipBlendFunction(HipBlendFunction fn)
{
    final switch(fn) with(HipBlendFunction)
    {
        case ZERO: return MTLBlendFactor.Zero;
        case ONE: return MTLBlendFactor.One;
        case SRC_COLOR: return MTLBlendFactor.SourceColor;
        case ONE_MINUS_SRC_COLOR: return MTLBlendFactor.OneMinusSourceColor;
        case SRC_ALPHA: return MTLBlendFactor.SourceAlpha;
        case ONE_MINUS_SRC_ALPHA: return MTLBlendFactor.OneMinusSourceAlpha;
        case DST_COLOR: return MTLBlendFactor.DestinationColor;
        case ONE_MINUS_DST_COLOR: return MTLBlendFactor.OneMinusDestinationColor;
        case DST_ALPHA: return MTLBlendFactor.DestinationAlpha;
        case ONE_MINUS_DST_ALPHA: return MTLBlendFactor.OneMinusDestinationAlpha;
        case CONSTANT_COLOR: return MTLBlendFactor.Source1Color;
        case ONE_MINUS_CONSTANT_COLOR: return MTLBlendFactor.OneMinusSource1Color;
        case CONSTANT_ALPHA: return MTLBlendFactor.Source1Alpha;
        case ONE_MINUS_CONSTANT_ALPHA: return MTLBlendFactor.OneMinusSource1Alpha;
    }
}

class HipMTLShaderProgram : ShaderProgram
{
    MTLLibrary library;
    MTLFunction vertexShaderFunction;
    MTLFunction fragmentShaderFunction;
    BufferedMTLBuffer* uniformBufferVertex;
    BufferedMTLBuffer* uniformBufferFragment;



    MTLRenderPipelineDescriptor pipelineDescriptor;
    MTLRenderPipelineState pipelineState;
    HipBlendFunction blendSrc, blendDst;
    HipBlendEquation blendEq;
    this()
    {
        pipelineDescriptor = MTLRenderPipelineDescriptor.alloc.initialize;
    }

    void createInputLayout(MTLDevice device, MTLVertexDescriptor descriptor)
    {
        assert(pipelineState is null, "Pipeline State was already created.");
        NSError err;
        pipelineDescriptor.vertexDescriptor = descriptor;
        pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineDescriptor, &err);
        if(err !is null || pipelineState is null)
        {
            import hip.error.handler;
            ErrorHandler.showErrorMessage("Creating Input Layout",  "Could not create RenderPipelineState");
            err.print();
        }
    }
}



__gshared HipMTLShaderProgram boundShader;

class HipMTLShader : IShader
{
    MTLDevice device;
    HipMTLRenderer mtlRenderer;

    this(MTLDevice device, HipMTLRenderer mtlRenderer)
    {
        this.device = device;
        this.mtlRenderer = mtlRenderer;
    }

    VertexShader createVertexShader(){return new HipMTLVertexShader(device);}
    FragmentShader createFragmentShader(){return new HipMTLFragmentShader(device);}
    ShaderProgram createShaderProgram(){return new HipMTLShaderProgram();}
    bool compileShader(FragmentShader fs, string shaderSource)
    {
        (cast(HipMTLFragmentShader)fs).shaderSource = shaderSource;
        return true;
    }

    bool compileShader(VertexShader vs, string shaderSource)
    {
        (cast(HipMTLVertexShader)vs).shaderSource = shaderSource;
        return true;
    }

    bool linkProgram(ref ShaderProgram program, VertexShader vs, FragmentShader fs)
    {
        HipMTLShaderProgram p = cast(HipMTLShaderProgram)program;
        HipMTLVertexShader v = cast(HipMTLVertexShader)vs;
        HipMTLFragmentShader f = cast(HipMTLFragmentShader)fs;

        string shaderSource = v.shaderSource~f.shaderSource;
        scope(exit)
        {
            import core.memory;
            GC.free(cast(void*)shaderSource.ptr);
        }

        NSError err;
        MTLCompileOptions opts = MTLCompileOptions.alloc.initialize;
        ///Macros
        opts.preprocessorMacros = cast(NSDictionary)(["ARGS_TIER2": 0].ns);

        p.library = device.newLibraryWithSource(shaderSource.ns, opts, &err);

        if(p.library is null || err !is null)
        {
            loglnError("Could not compile shader.");
            err.print();
            return false;
        }
        p.fragmentShaderFunction = p.library.newFunctionWithName("fragment_main".ns);
        if(p.fragmentShaderFunction is null)
        {
            loglnError("fragment_main() not found.");
            return false;
        }
        p.vertexShaderFunction = p.library.newFunctionWithName("vertex_main".ns);
        if(p.vertexShaderFunction is null)
        {
            loglnError("vertex_main() not found.");
            return false;
        }

        p.pipelineDescriptor.label = "HipremeShader".ns;
        p.pipelineDescriptor.vertexFunction = p.vertexShaderFunction;
        p.pipelineDescriptor.fragmentFunction = p.fragmentShaderFunction;
        p.pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.BGRA8Unorm_sRGB;
        p.pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormat.Depth32Float_Stencil8;
        p.pipelineDescriptor.stencilAttachmentPixelFormat = MTLPixelFormat.Depth32Float_Stencil8;

        return true;
    }

    bool setShaderVar(ShaderVar* sv, ShaderProgram prog, void* value)
    {
        switch(sv.type) with(UniformType)
        {
            case texture_array:
            {
                import hip.util.algorithm;
                IHipTexture[] textures = *cast(IHipTexture[]*)value;
                HipMTLShaderVarTexture tempTex;
                foreach(size_t i, HipMTLTexture tex; textures.map((IHipTexture itex) => cast(HipMTLTexture)itex))
                {
                    tempTex.textures[i] = tex.texture;
                    tempTex.samplers[i] = tex.sampler;
                }
                sv.setBlackboxed(tempTex);
                return true;
            }
            default: return false;
        }
    }
    void setBlending(ShaderProgram prog, HipBlendFunction src, HipBlendFunction dest, HipBlendEquation eq)
    {
        HipMTLShaderProgram p = cast(HipMTLShaderProgram)prog;
        p.blendSrc = src;
        p.blendDst = dest;
        p.blendEq = eq;

        MTLBlendFactor mtlSrc = src.fromHipBlendFunction;
        MTLBlendFactor mtlDest = dest.fromHipBlendFunction;
        MTLBlendOperation mtlOp = eq.fromHipBlendEquation;
        p.pipelineDescriptor.colorAttachments[0].blendingEnabled = eq != HipBlendEquation.DISABLED;
        p.pipelineDescriptor.colorAttachments[0].rgbBlendOperation = mtlOp;
        p.pipelineDescriptor.colorAttachments[0].alphaBlendOperation = mtlOp;
        p.pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = mtlSrc;
        p.pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = mtlDest;
        p.pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = mtlSrc;
        p.pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = mtlDest;

        if(p.pipelineState !is null)
            p.createInputLayout(device, p.pipelineDescriptor.vertexDescriptor);
    }

    void bind(ShaderProgram program)
    {
        HipMTLShaderProgram mtlShader = cast(HipMTLShaderProgram)program;
        assert(mtlShader.pipelineState !is null);
        if(mtlShader.pipelineState !is null)
        {
            mtlRenderer.getEncoder.setRenderPipelineState(mtlShader.pipelineState);
            if(mtlShader.uniformBufferVertex)
                mtlRenderer.getEncoder.setVertexBuffer(mtlShader.uniformBufferVertex.getBuffer, 0, 0);
            if(mtlShader.uniformBufferFragment)
                mtlRenderer.getEncoder.setFragmentBuffer(mtlShader.uniformBufferFragment.getBuffer, 0, 0);
            boundShader = mtlShader;
        }
    }

    void unbind(ShaderProgram program)
    {
        // encoder.setRenderPipelineState(null);
        mtlRenderer.getEncoder.setVertexBuffer(null, 0, 0);
        mtlRenderer.getEncoder.setFragmentBuffer(null, 0, 0);
        if(boundShader is program) boundShader = null;
    }

    void sendVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset)
    {

    }

    int getId(ref ShaderProgram prog, string name)
    {
        return int.init; // TODO: implement
    }

    void deleteShader(FragmentShader* fs){}
    void deleteShader(VertexShader* vs){}

    private MTLBuffer getNewMTLBuffer(ShaderVariablesLayout layout)
    {
        return device.newBuffer(layout.getLayoutSize(), MTLResourceOptions.DefaultCache);
    }
    void createVariablesBlock(ref ShaderVariablesLayout layout, ShaderProgram shaderProgram)
    {
        MTLBuffer buffer = getNewMTLBuffer(layout);
        HipMTLShaderProgram s = cast(HipMTLShaderProgram)shaderProgram;
        BufferedMTLBuffer* buffered;
        layout.setAdditionalData(buffered = new BufferedMTLBuffer([buffer], layout), true);
        final switch(layout.shaderType)
        {
            case ShaderTypes.vertex:
                s.uniformBufferVertex = buffered;
                break;
            case ShaderTypes.fragment:
                s.uniformBufferFragment = buffered;
                break;
            case ShaderTypes.geometry:
            case ShaderTypes.none:
                break;
        }
    }
    void sendVars(ref ShaderProgram prog, ShaderVariablesLayout[string] layouts)
    {
        import core.stdc.string;

        HipMTLShaderProgram mtlShader = cast(HipMTLShaderProgram)prog;
        foreach(layout; layouts)
        {
            BufferedMTLBuffer* bufferedUniformBuffer = cast(BufferedMTLBuffer*)layout.getAdditionalData();
            MTLBuffer uniformBuffer = bufferedUniformBuffer.getBuffer;
            memcpy(uniformBuffer.contents, layout.getBlockData, layout.getLayoutSize);
            bufferedUniformBuffer.currentBuffer++;
            if(bufferedUniformBuffer.currentBuffer >= bufferedUniformBuffer.buffer.length)
                bufferedUniformBuffer.buffer~= getNewMTLBuffer(layout);
        }
    }

    void bindArrayOfTextures(ref ShaderProgram prog, IHipTexture[] textures, string varName)
    {
        __gshared MTLTexture[] mtlTextures;
        __gshared MTLSamplerState[] mtlSamplers;
        if(textures.length > mtlTextures.length)
        {
            import hip.util.memory;
            if(mtlTextures !is null)
            {
                free(mtlTextures.ptr);
                free(mtlSamplers.ptr);
            }
            mtlTextures = allocSlice!MTLTexture(textures.length);
            mtlSamplers = allocSlice!MTLSamplerState(textures.length);
        }

        foreach(i; 0..textures.length)
        {
            HipMTLTexture hMtl = cast(HipMTLTexture)textures[i];
            mtlTextures[i] = hMtl.texture;
            mtlSamplers[i] = hMtl.sampler;
        }

        mtlRenderer.getEncoder.setFragmentSamplerStates(mtlSamplers.ptr, NSRange(0, textures.length));
        mtlRenderer.getEncoder.setFragmentTextures(mtlTextures.ptr, NSRange(0, textures.length));

    }

    void dispose(ref ShaderProgram p)
    {
        HipMTLShaderProgram shader = cast(HipMTLShaderProgram)p;
        foreach(BufferedMTLBuffer* buff; [shader.uniformBufferFragment, shader.uniformBufferVertex])
        {
            foreach(MTLBuffer mtlbuffer; buff.buffer)
                mtlbuffer.release();
        }
    }
    override void onRenderFrameEnd(ShaderProgram p)
    {
        HipMTLShaderProgram shader = cast(HipMTLShaderProgram)p;
        shader.uniformBufferFragment.reset;
        shader.uniformBufferVertex.reset;
    }
}