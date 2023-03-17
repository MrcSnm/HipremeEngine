module hip.hiprenderer.backend.metal.mtlrenderer;

version(AppleOS):

import metal;
import hip.hiprenderer.renderer;
import hip.windowing.window;
import hip.hiprenderer.backend.metal.mtlshader;
import hip.hiprenderer.backend.metal.mtlvertex;
import hip.hiprenderer.backend.metal.mtltexture;



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
        cmdBuffer = cmdQueue.commandBuffer;
        cmdBuffer.label = "HipremeRenderer".ns;

        renderPassDescriptor = view.currentRenderPassDescriptor;
        cmdEncoder = cmdBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor);

        return cmdEncoder !is null;
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
        return ret;
    }


    public bool initExternal()
    {
        return bool.init; // TODO: implement
    }

    public bool isRowMajor(){return false;}
    void setErrorCheckingEnabled(bool enable = true){}
    public Shader createShader()
    {
        return new Shader(new HipMTLShader(device, cmdEncoder));
    }

    public IHipFrameBuffer createFrameBuffer(int width, int height)
    {
        return IHipFrameBuffer.init; // TODO: implement
    }

    public IHipVertexArrayImpl createVertexArray()
    {
        return new HipMTLVertexArray(device, cmdEncoder);
    }

    public IHipTexture createTexture()
    {
        return new HipMTLTexture(device,cmdQueue, cmdEncoder);
    }

    public IHipVertexBufferImpl createVertexBuffer(size_t size, HipBufferUsage usage)
    {
        return new HipMTLVertexBuffer(device, cmdQueue, size, usage);
    }

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

    public bool hasErrorOccurred(out string err, string file = __FILE__, size_t line = __LINE__)
    {
        return bool.init; // TODO: implement
    }

    public void begin()
    {
        
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