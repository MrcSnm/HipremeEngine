module hip.hiprenderer.backend.metal.mtltexture;
version(AppleOS):
import metal;
import hip.hiprenderer;
import metal.texture;


MTLPixelFormat getPixelFormat(in IImage img)
{
    switch(img.getBytesPerPixel)
    {
        case 1: return MTLPixelFormat.R8Uint;
        case 4: return MTLPixelFormat.RGBA8Uint;
        case 2:
        case 3:
        default:
    }
}


MTLSamplerAddressMode fromHipTextureWrapMode(TextureWrapMode m)
{
    switch(m)
    {
        case TextureWrapMode.CLAMP_TO_EDGE:
            return MTLSamplerAddressMode.ClampToEdge;
        case TextureWrapMode.MIRRORED_CLAMP_TO_EDGE:
            return MTLSamplerAddressMode.MirrorClampToEdge;
        case TextureWrapMode.REPEAT:
            return MTLSamplerAddressMode.Repeat;
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
    MTLSamplerStateDescriptor samplerDesc;

    MTLRenderCommandEncoder cmdEncoder;

    uint width, height;

    this(MTLDevice device, MTLRenderCommandEncoder cmdEncoder)
    {
        this.device = device;
        this.cmdEncoder = cmdEncoder;
        samplerDesc = MTLSamplerStateDescriptor.alloc.init;
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
        final switch ( max ) with(TextureFilter)
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

        width = img.getWidth;
        height = img.getHeight;

        texture = device.newBuffer(img.getPixels.ptr, img.getPixels.length, MTLResourceOptions.StorageModePrivate)
            .newTextureWithDescriptor(desc, 0, img.getWidth * img.getBytesPerPixel);
        return texture !is null;
    }

    void bind(int slot = 0)
    {
        cmdEncoder.setFragmentTexture(texture, slot);
    }

    void unbind(int slot = 0)
    {
        cmdEncoder.setFragmentTexture(null, slot);
    }
    bool hasSuccessfullyLoaded(){return width != 0;}
    int getWidth() const{return width;}
    int getHeight() const{return height;}
}
