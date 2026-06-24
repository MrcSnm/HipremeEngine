module hip.hiprenderer.backend.metal.mtlshader;

version(AppleOS):

import hip.hiprenderer;
import hip.console.log;
import metal;
import metal.metal;
import hip.hiprenderer.backend.metal.mtlrenderer;
import hip.hiprenderer.backend.metal.mtltexture;

struct BufferedMTLBuffer
{
    MTLBuffer[] buffer;
    ShaderVariablesLayout layout;
    uint currentBuffer;

    MTLBuffer getBuffer() => buffer[currentBuffer];
    void reset(){currentBuffer = 0;}
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


class HipMTLShader : HipShaderProgram
{
    MTLDevice device;
    HipMTLRenderer mtlRenderer;

    MTLLibrary library;
    MTLFunction vertexShaderFunction;
    MTLFunction fragmentShaderFunction;
    BufferedMTLBuffer* uniformBufferVertex;
    BufferedMTLBuffer* uniformBufferFragment;



    MTLRenderPipelineDescriptor pipelineDescriptor;
    MTLRenderPipelineState pipelineState;
    HipBlendFunction blendSrc, blendDst;
    HipBlendEquation blendEq;

    this(MTLDevice device, HipMTLRenderer mtlRenderer)
    {
        this.device = device;
        this.mtlRenderer = mtlRenderer;

        pipelineDescriptor = MTLRenderPipelineDescriptor.alloc.initialize;

    }

    void createPipelineState(MTLDevice device, MTLVertexDescriptor descriptor)
    {
        if(pipelineState)
        {
            pipelineState.release();
            // assert(pipelineState is null, "Pipeline State was already created.");
        }
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
    override void dispose()
    {
        import hip.util.data_structures;
        foreach(BufferedMTLBuffer* buff; [uniformBufferFragment, uniformBufferVertex].staticArray)
        {
            foreach(MTLBuffer mtlbuffer; buff.buffer)
                mtlbuffer.release();
        }
    }

    HipShaderProgram createShaderProgram(){return new HipMTLShader(device, mtlRenderer);}
   
    override bool buildShader(string shaderSource, string shaderPath, bool isInstanced)
    {
        name = shaderPath;

        NSError err;
        MTLCompileOptions opts = MTLCompileOptions.alloc.initialize;
        ///Macros
        opts.preprocessorMacros = cast(NSDictionary)(["ARGS_TIER2": 0, "INSTANCED": isInstanced].ns);

        library = device.newLibraryWithSource(shaderSource.ns, opts, &err);

        if(library is null || err !is null)
        {
            loglnError("Could not compile shader.");
            err.print();
            return false;
        }
        fragmentShaderFunction = library.newFunctionWithName("fragmentMain".ns);
        if(fragmentShaderFunction is null)
        {
            loglnError("fragmentMain() not found.");
            return false;
        }
        vertexShaderFunction = library.newFunctionWithName("vertexMain".ns);
        if(vertexShaderFunction is null)
        {
            loglnError("vertexMain() not found.");
            return false;
        }

        pipelineDescriptor.label = shaderPath.ns;
        pipelineDescriptor.vertexFunction = vertexShaderFunction;
        pipelineDescriptor.fragmentFunction = fragmentShaderFunction;
        pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.RGBA8Unorm;
        pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormat.Depth32Float_Stencil8;
        pipelineDescriptor.stencilAttachmentPixelFormat = MTLPixelFormat.Depth32Float_Stencil8;

        return true;
    }

    override bool setShaderVar(ShaderVar* sv, void* value)
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
    override void setBlending(HipBlendFunction src, HipBlendFunction dest, HipBlendEquation eq)
    {
        blendSrc = src;
        blendDst = dest;
        blendEq = eq;

        MTLBlendFactor mtlSrc = src.fromHipBlendFunction;
        MTLBlendFactor mtlDest = dest.fromHipBlendFunction;
        MTLBlendOperation mtlOp = eq.fromHipBlendEquation;
        pipelineDescriptor.colorAttachments[0].blendingEnabled = eq != HipBlendEquation.DISABLED;
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = mtlOp;
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = mtlOp;
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = mtlSrc;
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = mtlDest;
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = mtlSrc;
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = mtlDest;
        
        if(pipelineState !is null)
            createPipelineState(device, pipelineDescriptor.vertexDescriptor);
    }

    override void bind()
    {
        assert(pipelineState !is null);
        mtlRenderer.getEncoder.setRenderPipelineState(pipelineState);
        if(uniformBufferVertex)
            mtlRenderer.getEncoder.setVertexBuffer(uniformBufferVertex.getBuffer, 0, 0);
        if(uniformBufferFragment)
            mtlRenderer.getEncoder.setFragmentBuffer(uniformBufferFragment.getBuffer, 0, 0);
    }

    override void unbind()
    {
        mtlRenderer.getEncoder.setVertexBuffer(null, 0, 0);
        mtlRenderer.getEncoder.setFragmentBuffer(null, 0, 0);
    }


    override int getId(string name, ShaderVariablesLayout layout)
    {
        return int.init; // TODO: implement
    }

    private MTLBuffer getNewMTLBuffer(ShaderVariablesLayout layout)
    {
        return device.newBuffer(layout.getLayoutSize(), MTLResourceOptions.DefaultCache);
    }
    override void createVariablesBlock(ref ShaderVariablesLayout layout)
    {
        MTLBuffer buffer = getNewMTLBuffer(layout);
        BufferedMTLBuffer* buffered;
        layout.setAdditionalData(buffered = new BufferedMTLBuffer([buffer], layout), true);
        final switch(layout.shaderType)
        {
            case ShaderTypes.vertex:
                uniformBufferVertex = buffered;
                break;
            case ShaderTypes.fragment:
                uniformBufferFragment = buffered;
                break;
            case ShaderTypes.geometry:
            case ShaderTypes.none:
                break;
        }
    }

    override void sendVars(ShaderVariablesLayout[] layouts)
    {
        import core.stdc.string;
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

    override void bindArrayOfTextures(IHipTexture[] textures, string varName)
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
    override void onRenderFrameEnd()
    {
        uniformBufferFragment.reset;
        uniformBufferVertex.reset;
    }
}