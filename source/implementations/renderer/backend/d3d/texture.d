module implementations.renderer.backend.d3d.texture;
import implementations.renderer.backend.d3d.renderer;
import directx.d3d11;
import bindbc.sdl;
import implementations.renderer.texture;

class Hip_D3D11_Texture : ITexture
{
    ID3D11Texture2D texture;
    ID3D11SamplerState sampler;
    float[4] borderColor;
    int filter;
    int wrap;

    this()
    {
        D3D11_TEXTURE2D_DESC desc;
        _hip_d3d_device.CreateTexture2D(&desc, null, &texture);
    }

    protected int getTextureFilter(TextureFilter min, TextureFilter mag)
    {
        with(TextureFilter)
        {
            switch(min)
            {
                case LINEAR:
                    if(mag == LINEAR)
                        return D3D11_FILTER_MIN_MAG_MIP_LINEAR;
                    break;
                case NEAREST:
                    if(mag == LINEAR)
                        return D3D11_FILTER_MIN_POINT_MAG_MIP_LINEAR;
                    return D3D11_FILTER_MIN_MAG_MIP_POINT;
                case NEAREST_MIPMAP_LINEAR:
                    return D3D11_FILTER_MIN_POINT_MAG_MIP_LINEAR;
                default:break;
            }
        }
        return D3D11_FILTER_MIN_MAG_MIP_LINEAR;
    }

    void setTextureFilter(TextureFilter mag, TextureFilter min)
    {
        filter = getTextureFilter(min, mag);
        updateSamplerState();
    }
    protected void updateSamplerState()
    {
        D3D11_SAMPLER_DESC desc;
        desc.Filter = filter;
        desc.AddressU = wrap;
        desc.AddressV = wrap;
        desc.AddressW = wrap;
        desc.BorderColor = [1, 1, 1, 1];
        desc.ComparisonFunc = D3D11_COMPARISON_ALWAYS;
        desc.MinLOD = 0;
        desc.MaxLOD = D3D11_FLOAT32_MAX;
        desc.MipLODBias = 0f;
        desc.MaxAnisotropy = 1;
        _hip_d3d_device.CreateSamplerState(&desc, &sampler);
    }
    public int getWrapMode(TextureWrapMode mode)
    {
        switch(mode) with(TextureWrapMode)
        {
            case CLAMP_TO_EDGE:
                return D3D11_TEXTURE_ADDRESS_BORDER;
            case CLAMP_TO_BORDER:
                return D3D11_TEXTURE_ADDRESS_BORDER;
            case REPEAT:
                return D3D11_TEXTURE_ADDRESS_WRAP;
            case MIRRORED_REPEAT:
                return D3D11_TEXTURE_ADDRESS_MIRROR;
            case MIRRORED_CLAMP_TO_EDGE:
                return D3D11_TEXTURE_ADDRESS_MIRROR_ONCE;
            case UNKNOWN:
            default:
                return D3D11_TEXTURE_ADDRESS_WRAP;
        }
    }
    public void setWrapMode(TextureWrapMode mode)
    {
        wrap = getWrapMode(mode);
        updateSamplerState();
    }
    public bool load(SDL_Surface* surface)
    {
        return false;
    }
    void bind()
    {
        _hip_d3d_context.PSSetSamplers(0, 1, &sampler);
    }
}