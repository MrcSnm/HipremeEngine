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
        case 1: return MTLPixelFormat.R8Uint;
        case 4: return MTLPixelFormat.RGBA8Uint;
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

    MTLRenderCommandEncoder cmdEncoder;
    MTLCommandQueue cmdQueue;

    uint width, height;

    this(MTLDevice device, MTLCommandQueue cmdQueue, MTLRenderCommandEncoder cmdEncoder)
    {
        this.device = device;
        this.cmdEncoder = cmdEncoder;
        this.cmdQueue = cmdQueue;
        samplerDesc = MTLSamplerDescriptor.alloc.initialize;
    }

    void setWrapMode(TextureWrapMode mode)
    {
        MTLSamplerAddressMode wrap = mode.fromHipTextureWrapMode;
        samplerDesc.rAddressMode = wrap;
        samplerDesc.sAddressMode = wrap;
        samplerDesc.tAddressMode = wrap;
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
    }

    protected bool loadImpl(in IImage img)
    {
        desc = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(
            getPixelFormat(img),
            img.getWidth(),
            img.getHeight(),
            NO
        );

        if(desc is null)
            return false;

        width = img.getWidth;
        height = img.getHeight;

        import hip.console.log;
        logln("Width: ", img.getWidth, " BytesPerPixel: ", img.getBytesPerPixel);

        texture = HipMTLRenderer.createPrivateBufferWithData(cmdQueue, img.getPixels.ptr, img.getPixels.length)
            .newTextureWithDescriptor(desc, 0, img.getWidth * img.getBytesPerPixel);
        return texture !is null;
    }

    void bind(int slot = 0)
    {
        cmdEncoder.setFragmentSamplerState(sampler, slot);
        cmdEncoder.setFragmentTexture(texture, slot);
    }

    void unbind(int slot = 0)
    {
        cmdEncoder.setFragmentSamplerState(null, slot);
        cmdEncoder.setFragmentTexture(null, slot);
    }
    bool hasSuccessfullyLoaded(){return width != 0;}
    int getWidth() const{return width;}
    int getHeight() const{return height;}
}