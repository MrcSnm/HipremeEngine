module hip.hiprenderer.backend.metal.mtltexture;
version(AppleOS):
import metal;
import hip.hiprenderer;
import hip.hiprenderer.backend.metal.mtlrenderer;
import hip.console.log;
import metal.texture;


MTLPixelFormat getPixelFormat(in IImage img)
{
    final switch(img.getBytesPerPixel)
    {
        case 1: return MTLPixelFormat.R8Unorm;
        case 4: return MTLPixelFormat.RGBA8Unorm;
        case 2:
        case 3:
    }
    assert(0);
}


MTLSamplerAddressMode fromHipTextureWrapMode(TextureWrapMode m)
{
    final switch(m)
    {
        case TextureWrapMode.CLAMP_TO_EDGE:
            return MTLSamplerAddressMode.ClampToEdge;
        case TextureWrapMode.MIRRORED_CLAMP_TO_EDGE:
            return MTLSamplerAddressMode.MirrorClampToEdge;
        case TextureWrapMode.REPEAT:
            return MTLSamplerAddressMode.Repeat;
        case TextureWrapMode.MIRRORED_REPEAT:
            return MTLSamplerAddressMode.MirrorRepeat;
        case TextureWrapMode.CLAMP_TO_BORDER:
            return MTLSamplerAddressMode.ClampToBorderColor;
        case TextureWrapMode.UNKNOWN: assert(false, "Don't use that");

    }
}

class HipMTLTexture : IHipTexture
{
    MTLTextureDescriptor desc;
    MTLTexture texture;
    MTLDevice device;
    MTLSamplerState sampler;
    MTLSamplerDescriptor samplerDesc = null;

    HipMTLRenderer mtlRenderer;
    MTLCommandQueue cmdQueue;

    uint width, height;

    IHipTexture getBackendHandle(){return this;}

    this(MTLDevice device, MTLCommandQueue cmdQueue, HipMTLRenderer mtlRenderer)
    {
        this.device = device;
        this.cmdQueue = cmdQueue;
        this.mtlRenderer = mtlRenderer;
        samplerDesc = MTLSamplerDescriptor.alloc.initialize;

        setWrapMode(TextureWrapMode.REPEAT);
        setTextureFilter(TextureFilter.NEAREST, TextureFilter.NEAREST);
    }

    void setWrapMode(TextureWrapMode mode)
    {
        MTLSamplerAddressMode wrap = mode.fromHipTextureWrapMode;
        samplerDesc.rAddressMode = wrap;
        samplerDesc.sAddressMode = wrap;
        samplerDesc.tAddressMode = wrap;
        if(sampler) sampler.release();
        sampler = device.newSamplerStateWithDescriptor(samplerDesc);
    }

    void setTextureFilter(TextureFilter min, TextureFilter mag)
    {
        final switch ( min ) with(TextureFilter)
        {
            case LINEAR:
                samplerDesc.minFilter = MTLSamplerMinMagFilter.Linear;
                samplerDesc.mipFilter = MTLSamplerMipFilter.NotMipmapped;
                break;
            case NEAREST:
                samplerDesc.minFilter = MTLSamplerMinMagFilter.Nearest;
                samplerDesc.mipFilter = MTLSamplerMipFilter.NotMipmapped;
                break;
            case NEAREST_MIPMAP_NEAREST:
                samplerDesc.minFilter = MTLSamplerMinMagFilter.Nearest;
                samplerDesc.mipFilter = MTLSamplerMipFilter.Nearest;
                break;
            case LINEAR_MIPMAP_NEAREST:
                samplerDesc.minFilter = MTLSamplerMinMagFilter.Linear;
                samplerDesc.mipFilter = MTLSamplerMipFilter.Nearest;
                break;
            case NEAREST_MIPMAP_LINEAR:
                samplerDesc.minFilter = MTLSamplerMinMagFilter.Nearest;
                samplerDesc.mipFilter = MTLSamplerMipFilter.Linear;
                break;
            case LINEAR_MIPMAP_LINEAR:
                samplerDesc.minFilter = MTLSamplerMinMagFilter.Linear;
                samplerDesc.mipFilter = MTLSamplerMipFilter.Linear;
                break;
        }
        final switch ( mag ) with(TextureFilter)
        {
            case LINEAR:
                samplerDesc.magFilter = MTLSamplerMinMagFilter.Linear;
                samplerDesc.mipFilter = MTLSamplerMipFilter.NotMipmapped;
                break;
            case NEAREST:
                samplerDesc.magFilter = MTLSamplerMinMagFilter.Nearest;
                samplerDesc.mipFilter = MTLSamplerMipFilter.NotMipmapped;
                break;
            case NEAREST_MIPMAP_NEAREST:
                samplerDesc.magFilter = MTLSamplerMinMagFilter.Nearest;
                samplerDesc.mipFilter = MTLSamplerMipFilter.Nearest;
                break;
            case LINEAR_MIPMAP_NEAREST:
                samplerDesc.magFilter = MTLSamplerMinMagFilter.Linear;
                samplerDesc.mipFilter = MTLSamplerMipFilter.Nearest;
                break;
            case NEAREST_MIPMAP_LINEAR:
                samplerDesc.magFilter = MTLSamplerMinMagFilter.Nearest;
                samplerDesc.mipFilter = MTLSamplerMipFilter.Linear;
                break;
            case LINEAR_MIPMAP_LINEAR:
                samplerDesc.magFilter = MTLSamplerMinMagFilter.Linear;
                samplerDesc.mipFilter = MTLSamplerMipFilter.Linear;
                break;
        }
        if(sampler) sampler.release();
        sampler = device.newSamplerStateWithDescriptor(samplerDesc);
    }

    private static bool textureToSquare(out ubyte[] ret, const ubyte[] textureData, uint width, uint height)
    {
        uint nWidth = width;
        if(nWidth < height) nWidth = height;
        else return false;
        ret = new ubyte[nWidth*height];
        
        for(size_t i = 0; i < height; i++)
            ret[i*nWidth..i*nWidth+width] = textureData[i*width..(i+1)*width];
        return true;
    }

    protected bool loadImpl(in IImage img)
    {
        desc = MTLTextureDescriptor.alloc.initialize;
        desc.pixelFormat = getPixelFormat(img);
        desc.width = img.getWidth();
        desc.height = img.getHeight();
        desc.textureType = MTLTextureType._2D;
        desc.storageMode = MTLStorageMode.Private;

        if(desc is null)
            return false;
        
        width = img.getWidth;
        height = img.getHeight;

        const ubyte[] data = img.getPixels;
        ubyte[] squareData; 

        MTLCommandBuffer b = cmdQueue.defaultCommandBuffer();
        MTLBlitCommandEncoder blit = b.blitCommandEncoder();
        MTLBuffer imageBuffer;
        NSUInteger bytesPerRow;
        NSUInteger bytesPerImage;

        texture = device.newTextureWithDescriptor(desc);

        if(textureToSquare(squareData, data, img.getWidth, img.getHeight))
        {
            assert(img.getHeight > img.getWidth);
            imageBuffer = device.newBuffer(squareData.ptr, squareData.length, MTLResourceOptions.StorageModeShared);
            bytesPerRow = img.getHeight * img.getBytesPerPixel;
            bytesPerImage = squareData.length;
        }
        else
        {
            imageBuffer = device.newBuffer(img.getPixels.ptr, img.getPixels.length, MTLResourceOptions.StorageModeShared);
            bytesPerRow = img.getWidth * img.getBytesPerPixel;
            bytesPerImage = img.getPixels.length;
        }
        blit.copyFromBuffer(
            imageBuffer, 0, bytesPerRow, bytesPerImage,
            MTLSize(desc.width, desc.height, 1),
            texture, 0, 0, MTLOrigin(0,0,0)
        );
        blit.optimizeContentsForGPUAccess(texture);
        blit.endEncoding();
        b.commit();
        b.waitUntilCompleted();
        // imageBuffer.dealloc();
        if(squareData.ptr !is null)
        {
            import core.memory;
            GC.free(squareData.ptr);
        }

        return texture !is null;
    }

    void bind(int slot = 0)
    {
        mtlRenderer.getEncoder.setFragmentSamplerState(sampler, slot);
        mtlRenderer.getEncoder.setFragmentTexture(texture, slot);
    }

    void unbind(int slot = 0)
    {
        mtlRenderer.getEncoder.setFragmentSamplerState(null, slot);
        mtlRenderer.getEncoder.setFragmentTexture(null, slot);
    }
    bool hasSuccessfullyLoaded(){return width != 0;}
    int getWidth() const{return width;}
    int getHeight() const{return height;}
}
