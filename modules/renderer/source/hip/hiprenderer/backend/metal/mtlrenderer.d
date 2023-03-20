module hip.hiprenderer.backend.metal.mtlrenderer;

version(AppleOS):

import metal;
import hip.hiprenderer.renderer;
import hip.windowing.window;
import hip.hiprenderer.backend.metal.mtlshader;
import hip.hiprenderer.backend.metal.mtlvertex;
import hip.hiprenderer.backend.metal.mtltexture;



MTLDepthStencilState fromHipDepthTestingFunction(HipDepthTestingFunction fn)
{
    MTLDepthStencilDescriptor desc = MTLDepthStencilDescriptor.alloc.ini;

    switch(fn) with(HipDepthTestingFunction)
    {
        case Always:
        case Never:
        case Equal:
        case NotEqual:
        case Less:
        case LessEqual:
        case Greater:
        case GreaterEqual:
            break;

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

    public bool init(HipWindow window)
    {
        view = cast(MTKView)window.MTKView;
        device = view.device();
        cmdQueue = device.newCommandQueue();
        cmdQueue.label = "HipremeRendererQueue".ns;

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
        MTLCommandBuffer _cmdBuffer = cQueue.commandBuffer;
        MTLBlitCommandEncoder _cmdEncoder = _cmdBuffer.blitCommandEncoder;

        _cmdEncoder.copyFromBuffer(temp, 0, ret, 0, size);
        _cmdEncoder.endEncoding();
        _cmdBuffer.commit();
        _cmdBuffer.waitUntilCompleted();
        return ret;
    }


    public bool initExternal()
    {
        return bool.init; // TODO: implement
    }

    public bool isRowMajor(){return true;}
    void setErrorCheckingEnabled(bool enable = true){}
    public Shader createShader()
    {
        return new Shader(new HipMTLShader(device, this));
    }

    public IHipFrameBuffer createFrameBuffer(int width, int height)
    {
        return IHipFrameBuffer.init; // TODO: implement
    }

    public IHipVertexArrayImpl createVertexArray()
    {
        return new HipMTLVertexArray(device, this);
    }

    public IHipTexture createTexture()
    {
        return new HipMTLTexture(device,cmdQueue, this);
    }

    public IHipVertexBufferImpl createVertexBuffer(size_t size, HipBufferUsage usage)
    {
        return new HipMTLVertexBuffer(device, cmdQueue, size, usage);
    }

    package pragma(inline, true) MTLRenderCommandEncoder getEncoder() { return cmdEncoder; }

    public IHipIndexBufferImpl createIndexBuffer(index_t count, HipBufferUsage usage)
    {
        return new HipMTLIndexBuffer(device, cmdQueue, count, usage);
    }

    public int queryMaxSupportedPixelShaderTextures()
    {
        return int.init; // TODO: implement
    }

    public void setColor(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        
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

    public void setBlendFunction(HipBlendFunction src, HipBlendFunction dst)
    {
        
    }

    public void setBlendingEquation(HipBlendEquation eq)
    {
        
    }
    public void setDepthTestingFunction(HipDepthTestingFunction d)
    {
        cmdEncoder.setDepthStencilState()
    }

    public bool hasErrorOccurred(out string err, string file = __FILE__, size_t line = __LINE__)
    {
        return bool.init; // TODO: implement
    }

    public void begin()
    {
        cmdBuffer = cmdQueue.commandBuffer;
        cmdBuffer.label = "HipremeRenderer".ns;
        cmdEncoder = cmdBuffer.renderCommandEncoderWithDescriptor(view.currentRenderPassDescriptor);
    }

    public void setRendererMode(HipRendererMode mode)
    {
        final switch(mode)
        {
            case HipRendererMode.LINE: 
                primitiveType = MTLPrimitiveType.Line;
                break;
            case HipRendererMode.LINE_STRIP: 
                primitiveType = MTLPrimitiveType.LineStrip;
                break;
            case HipRendererMode.POINT: 
                primitiveType = MTLPrimitiveType.Point;
                break;
            case HipRendererMode.TRIANGLES:
                primitiveType = MTLPrimitiveType.Triangle;
                break;
            case HipRendererMode.TRIANGLE_STRIP:
                primitiveType = MTLPrimitiveType.TriangleStrip;
                break;
        }
    }

    public void drawIndexed(index_t count, uint offset = 0)
    {
        static if(is(index_t == ushort))
            cmdEncoder.drawIndexedPrimitives(primitiveType, count, MTLIndexType.UInt16, boundIndexBuffer, offset);
        else 
            cmdEncoder.drawIndexedPrimitives(primitiveType, count, MTLIndexType.UInt32, boundIndexBuffer, offset);

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
        
    }

    public void clear(ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255)
    {
        
    }

    public void dispose()
    {
        
    }
}