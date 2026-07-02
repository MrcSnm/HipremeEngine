module hip.hiprenderer.backend.metal.mtlrenderer;

version(AppleOS):

import metal;
import hip.hiprenderer.renderer;
import hip.windowing.window;
import hip.hiprenderer.backend.metal.mtlshader;
import hip.hiprenderer.backend.metal.mtlvertex;
import hip.hiprenderer.backend.metal.mtltexture;

MTLCompareFunction fromHipDepthTestingFunction(HipDepthTestingFunction fn)
{
    final switch(fn) with(HipDepthTestingFunction)
    {
        case Always: return MTLCompareFunction.Always;
        case Never: return MTLCompareFunction.Never;
        case Equal: return MTLCompareFunction.Equal;
        case NotEqual: return MTLCompareFunction.NotEqual;
        case Less: return MTLCompareFunction.Less;
        case LessEqual: return MTLCompareFunction.LessEqual;
        case Greater: return MTLCompareFunction.Greater;
        case GreaterEqual: return MTLCompareFunction.GreaterEqual;
    }
}

package MTLCommandBuffer defaultCommandBuffer(MTLCommandQueue cQueue)
{
    static MTLCommandBufferDescriptor desc;
    if(desc is null)
    {
        desc = MTLCommandBufferDescriptor.alloc.initialize;
        desc.errorOptions = MTLCommandBufferErrorOption.EncoderExecutionStatus;
    }
    return cQueue.commandBuffer(desc);
}

private string getGPUFamily(MTLDevice device)
{
    string ret = "";
    static foreach(mem; __traits(allMembers, MTLGPUFamily))
    {
        if(device.supportsFamily(__traits(getMember, MTLGPUFamily, mem)))
        {
            if(ret != "") ret~= ", ";
            ret~= mem;
        }
    }
    if(ret == "")
        return "unknown";
    return ret;
}

/**
 * Used to be sent as a way to interface with ShaderVar uniforms.
 * Whenever needing to bind more than one texture.
 */
package struct HipMTLShaderVarTexture
{
    MTLTexture[16] textures;
    MTLSamplerState[16] samplers;
}

struct HipMetalBlendState
{
    HipBlendFunction blendSrc, blendDst;
    HipBlendEquation blendEq;
}

struct HipMetalRenderPipelineState
{
    MTLRenderPipelineDescriptor descriptor;
    MTLRenderPipelineState pipelineState;
    
    void create(MTLDevice device, 
        MTLVertexDescriptor vertexDescriptor,
        HipMTLShader shader)
    {
        descriptor = MTLRenderPipelineDescriptor.alloc.initialize;
        descriptor.vertexDescriptor = vertexDescriptor;
        descriptor.label = shader.shaderPath.ns;
        descriptor.vertexFunction = shader.vertexShaderFunction;
        descriptor.fragmentFunction = shader.fragmentShaderFunction;
        pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.RGBA8Unorm;
        pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormat.Depth32Float_Stencil8;
        pipelineDescriptor.stencilAttachmentPixelFormat = MTLPixelFormat.Depth32Float_Stencil8;

        HipMetalBlendState blend;
        shader.getBlending(blend.blendSrc, blend.blendDst, blend.blendEq);

        MTLBlendFactor mtlSrc = blend.blendSrc.fromHipBlendFunction;
        MTLBlendFactor mtlDest = blend.blendDst.fromHipBlendFunction;
        MTLBlendOperation mtlOp = blend.blendEq.fromHipBlendEquation;
        
        //Blending
        pipelineDescriptor.colorAttachments[0].blendingEnabled = eq != HipBlendEquation.DISABLED;
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = mtlOp;
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = mtlOp;
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = mtlSrc;
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = mtlDest;
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = mtlSrc;
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = mtlDest;

        NSError err;
        pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineDescriptor, &err);
        if(err !is null || pipelineState is null)
        {
            import hip.error.handler;
            ErrorHandler.showErrorMessage("Creating Input Layout",  "Could not create RenderPipelineState");
            err.print();
        }
    }

    void dispose()
    {
        descriptor.release();
        pipelineState.release();
    }
}

struct HipMetalRenderPipelineStateCache
{
    HipMetalRenderPipelineState[HipMetalBlendState][HipMTLShader] pipelines;

    HipMetalRenderPipelineState get(HipMTLVertexArray vao, HipMTLSHader shader)
    {
        HipMetalBlendState bs;
        shader.getBlending(bs.blendSrc, bs.blendDst, bs.blendEq);
        HipMetalRenderPipelineState[HipMetalBlendState]* pipelinesPerBlend = shader in pipelines;
        if(!pipelinesPerBlend)
        {
            pipelines[shader] = new HipMetalRenderPipelineState[HipMetalBlendState];
            pipelinesPerBlend = shader in pipelines;
        }
        HipMetalRenderPipelineState* st = bs in *pipelinesPerBlend;
        if(!st)
        {
            (*pipelinesPerBlend)[bs] = new HipMetalRenderPipelineState();
            st  = bs in *pipelinesPerBlend; 
            st.create(device, vao.descriptor, shader);
        }
        return st.pipelineState;
    }
}

class HipMTLRenderer : IHipRendererImpl
{
    MTKView view;
    MTLDevice device;
    MTLCommandBuffer cmdBuffer;
    MTLCommandQueue cmdQueue;
    MTLRenderPassDescriptor renderPassDescriptor;
    MTLRenderCommandEncoder cmdEncoder;
    MTLPrimitiveType primitiveType;
    HipMetalRenderPipelineStateCache pipelinesCache;

    MTLBuffer boundIndexBuffer;
    HipMTLShader boundShader;

    package __gshared MTLArgumentBuffersTier argsTier;

    //Descriptors
        MTLDepthStencilDescriptor depthStencilDescriptor;
    //

    public bool init(IHipWindow windowInterface)
    {
        HipWindow window = cast(HipWindow)windowInterface;
        view = cast(MTKView)window.MTKView;
        device = view.device();
        cmdQueue = device.newCommandQueue();
        cmdQueue.label = "HipremeRendererQueue".ns;
        // argsTier = device.argumentBuffersSupport;
        ///Experimental Tier2 conditionals support, since I can't test them.
        argsTier = MTLArgumentBuffersTier.Tier1;

        import hip.console.log;
        {
            MTLCompileOptions _temp = MTLCompileOptions.alloc.ini;

            loglnInfo(
                "GPU Name: ", device.name, "\n",
                "GPU Family: ", getGPUFamily(device), "\n",
                "Metal Version: ", _temp.languageVersion, "\n",
                "ArgumentBuffer: ", argsTier
            );
            _temp.dealloc;
        }


        depthStencilDescriptor = MTLDepthStencilDescriptor.alloc.ini;
        renderPassDescriptor = view.currentRenderPassDescriptor;
        if(renderPassDescriptor is null)
            throw new Error("Could not get a render pass descriptor.");
        renderPassDescriptor.depthAttachment.clearDepth = 1.0;

        hiplog(renderPassDescriptor.depthAttachment.level);
        renderPassDescriptor.depthAttachment.loadAction = MTLLoadAction.Clear;

        return cmdQueue !is null;
    }

    /**
     * Util for creating MTLResourceOptions.StorageModePrivate buffer with initial data.
     */
    package static MTLBuffer createPrivateBufferWithData(MTLCommandQueue cQueue, const(void)* data, size_t size)
    {
        MTLDevice d = cQueue.device;
        MTLBuffer temp = d.newBuffer(data, size, MTLResourceOptions.StorageModeShared);
        MTLBuffer ret = d.newBuffer(size, MTLResourceOptions.StorageModePrivate);
        MTLCommandBuffer _cmdBuffer = cQueue.defaultCommandBuffer();
        MTLBlitCommandEncoder _cmdEncoder = _cmdBuffer.blitCommandEncoder;

        _cmdEncoder.copyFromBuffer(temp, 0, ret, 0, size);
        _cmdEncoder.endEncoding();
        _cmdBuffer.commit();
        _cmdBuffer.waitUntilCompleted();

        _cmdEncoder.release();
        if(_cmdBuffer.error)
        {
            NSLog("Command Buffer Error %@".ns, _cmdBuffer.error);
        }
        return ret;
    }


    public bool initExternal()
    {
        return bool.init; // TODO: implement
    }

    public bool isRowMajor(){return true;}
    void setErrorCheckingEnabled(bool enable = true){}
    public HipShaderProgram createShader()
    {
        return new HipMTLShader(device, this);
    }

    size_t function(ShaderTypes shaderType, UniformType uniformType) getShaderVarMapper()
    {
        return (ShaderTypes shaderType, UniformType uniformType)
        {
            if(argsTier == MTLArgumentBuffersTier.Tier1) return 0;

            switch(uniformType) with(UniformType)
            {
                case texture_array:
                {
                    return MTLTexture.sizeof + MTLSamplerState.sizeof;
                }
                default: return 0;
            }
        };
    }


    void bind(HipMTLVertexArray vao, HipMTLShader shader)
    {
        getEncoder.setRenderPipelineState(cache.get(vao, shader));
        foreach(i, b; shader.uniformBufferVertex)
            getEncoder.setVertexBuffer(b.getBuffer, 0, i);
        foreach(i, b; shader.uniformBufferFragment)
            getEncoder.setFragmentBuffer(b.getBuffer, 0, i);
    }

    void unbind()
    {
        if(boundShader !is null)
        {
            foreach(i, b; boundShader.uniformBufferVertex)
                mtlRenderer.getEncoder.setVertexBuffer(null, 0, i);
            foreach(i, b; boundShader.uniformBufferFragment)
                mtlRenderer.getEncoder.setFragmentBuffer(null, 0, 0);
        }
    }

    public IHipFrameBuffer createFrameBuffer(int width, int height)
    {
        return IHipFrameBuffer.init; // TODO: implement
    }

    public IHipVertexArrayImpl createVertexArray()
    {
        return new HipMTLVertexArray(device, this);
    }

    public IHipTexture createTexture(HipResourceUsage usage, HipTextureType type)
    {
        return new HipMTLTexture(device,cmdQueue, this, usage, type);
    }

    public IHipRendererBuffer createBuffer(size_t size, HipResourceUsage usage, HipRendererBufferType type)
    {
        return new HipMTLBuffer(device, cmdQueue, size, usage, type);
    }
    public IHipRendererBuffer createBuffer(const(ubyte)[] data, HipResourceUsage usage, HipRendererBufferType type)
    {
        return new HipMTLBuffer(device, cmdQueue, data, usage, type);
    }

    package pragma(inline, true) MTLRenderCommandEncoder getEncoder() { return cmdEncoder; }

    public int queryMaxSupportedPixelShaderTextures()
    {
        return 8;///Max used in SpritebatchShader.
    }

    public void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
            r/255.0f,
            g/255.0f,
            b/255.0f,
            a/255.0f
        );
    }

    public void setViewport(Viewport v)
    {
        cmdEncoder.setViewport(MTLViewport(v.x, v.y, v.width, v.height, 0, 1));
    }

    public bool setWindowMode(HipWindowMode mode)
    {
        return bool.init; // TODO: implement
    }

    public bool isBlendingEnabled() const
    {
        return bool.init; // TODO: implement
    }

    public void setDepthTestingEnabled(bool enabled)
    {
        depthStencilDescriptor.depthWriteEnabled = enabled;
    }
    public void setDepthTestingFunction(HipDepthTestingFunction d)
    {
        assert(HipRenderer.isDepthTestingEnabled, "DepthTesting must be enabled before setting the function.");
        depthStencilDescriptor.depthCompareFunction = d.fromHipDepthTestingFunction;
        cmdEncoder.setDepthStencilState(
            device.newDepthStencilStateWithDescriptor(depthStencilDescriptor)
        );
    }
    public void setStencilTestingEnabled(bool bEnable)
    {
    }

    public void setStencilTestingMask(uint mask)
    {
    }
    public void setColorMask(ubyte r, ubyte g, ubyte b, ubyte a)
    {

    }

    public void setStencilTestingFunction(HipStencilTestingFunction passFunc, uint reference, uint mask)
    {
    }

    public void setStencilOperation(HipStencilOperation stencilFail, HipStencilOperation depthFail, HipStencilOperation stencilAndDephPass)
    {
    }

    public bool hasErrorOccurred(out string err, string file = __FILE__, size_t line = __LINE__)
    {
        return bool.init; // TODO: implement
    }

    public void begin()
    {
        cmdBuffer = cmdQueue.defaultCommandBuffer();
        cmdBuffer.label = "HipremeRenderer".ns;
        cmdEncoder = cmdBuffer.renderCommandEncoderWithDescriptor(view.currentRenderPassDescriptor);
        renderPassDescriptor = view.currentRenderPassDescriptor;
    }

    public void setRendererMode(HipRendererMode mode)
    {
        final switch(mode)
        {
            case HipRendererMode.line:
                primitiveType = MTLPrimitiveType.Line; break;
            case HipRendererMode.lineStrip:
                primitiveType = MTLPrimitiveType.LineStrip; break;
            case HipRendererMode.point:
                primitiveType = MTLPrimitiveType.Point; break;
            case HipRendererMode.triangles:
                primitiveType = MTLPrimitiveType.Triangle; break;
            case HipRendererMode.triangleStrip:
                primitiveType = MTLPrimitiveType.TriangleStrip; break;
        }
    }

    public void drawIndexed(index_t count, uint offset = 0)
    {
        enum IndexType = is(index_t == ushort) ? MTLIndexType.UInt16 : MTLIndexType.UInt32;
        cmdEncoder.drawIndexedPrimitives(primitiveType, count, IndexType, boundIndexBuffer, offset*index_t.sizeof);
    }

    public void drawIndexedInstanced(uint instanceCount, index_t count, uint indexOffset = 0, uint baseInstance = 0)
    {
        enum IndexType = is(index_t == ushort) ? MTLIndexType.UInt16 : MTLIndexType.UInt32;
        cmdEncoder.drawIndexedPrimitives(primitiveType, count, IndexType, boundIndexBuffer, indexOffset*index_t.sizeof, instanceCount, 0, baseInstance);
    }

    public void drawVertices(index_t count, uint offset = 0)
    {
        cmdEncoder.drawPrimitives(primitiveType, offset, count);
    }

    public void end()
    {
        cmdEncoder.endEncoding();
        cmdBuffer.presentDrawable(view.currentDrawable);
        cmdBuffer.commit();
        cmdBuffer.waitUntilCompleted();
    }

    public void clear()
    {
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadAction.Clear;
        cmdEncoder.endEncoding();
        cmdEncoder.release();
        cmdEncoder = null;
        cmdBuffer.commit();
        begin();
    }

    public void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        // setColor(r,g,b,a);
        // renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadAction.Clear;
        // cmdEncoder.endEncoding();
        // cmdBuffer.commit();
        // begin();
    }

    public void dispose()
    {

    }
}