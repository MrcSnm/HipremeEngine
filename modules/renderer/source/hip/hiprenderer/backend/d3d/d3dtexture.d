/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.backend.d3d.d3dtexture;
version(Windows):
version(DirectX):
import hip.hiprenderer.backend.d3d.d3drenderer;
public import hip.api.renderer.texture;

import hip.image;
import directx.d3d11;
import hip.error.handler;


private __gshared ID3D11ShaderResourceView nullSRV = null;
private __gshared ID3D11SamplerState nullSamplerState = null;

class Hip_D3D11_Texture : IHipTexture
{
    ID3D11Texture2D texture;
    ID3D11ShaderResourceView resource;
    ID3D11SamplerState sampler;
    int width, height;
    float[4] borderColor;
    int filter = Hip_D3D11_getTextureFilter(TextureFilter.NEAREST, TextureFilter.NEAREST);
    int wrap = Hip_D3D11_getWrapMode(TextureWrapMode.REPEAT);
    bool[] slotsBound;

    this()
    {
        import hip.hiprenderer:HipRenderer;
        slotsBound = new bool[HipRenderer.getMaxSupportedShaderTextures()];
    }


    bool hasSuccessfullyLoaded(){return width > 0;}

    void setTextureFilter(TextureFilter mag, TextureFilter min)
    {
        filter = Hip_D3D11_getTextureFilter(min, mag);
        updateSamplerState();
    }
    package void updateSamplerState()
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
    public void setWrapMode(TextureWrapMode mode)
    {
        wrap = Hip_D3D11_getWrapMode(mode);
        updateSamplerState();
    }

    protected bool loadImpl(in IImage image)
    {
        D3D11_TEXTURE2D_DESC desc;
        // desc.Format = getFromFromSurface(surface);
        desc.Usage = D3D11_USAGE_IMMUTABLE;
        desc.CPUAccessFlags = 0;
        desc.MipLevels = 1;
        desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
        desc.Width = width = image.getWidth;
        desc.Height = height = image.getHeight;

        D3D11_SUBRESOURCE_DATA data;

        const(void)[] pixels;
        ushort Bpp = 0;
        int format;

        switch(image.getBytesPerPixel)
        {
            case 1:
                if(image.hasPalette)
                {
                    pixels = image.convertPalettizedToRGBA();
                    Bpp = 4;
                    format = DXGI_FORMAT_R8G8B8A8_UNORM;
                }
                else
                {
                    pixels = image.getPixels;
                    Bpp = 1;
                    format = DXGI_FORMAT_R8_UNORM;
                }
                break;
            case 3:
            case 4:
                pixels = image.getPixels;
                Bpp = image.getBytesPerPixel;
                format = DXGI_FORMAT_R8G8B8A8_UNORM;
                break;
            case 2:
            default:
                ErrorHandler.assertLazyExit(false, 
                "Unsopported bytes per pixel for D3D11 Texture named '"~image.getName~"'");
        }
        desc.Format = format;
        data.pSysMem = cast(void*)pixels.ptr;
        data.SysMemPitch = image.getWidth*Bpp;

        _hip_d3d_device.CreateTexture2D(&desc, &data, &texture);
        _hip_d3d_device.CreateShaderResourceView(texture, cast(D3D11_SHADER_RESOURCE_VIEW_DESC*)null, &resource);
        updateSamplerState();
        bind();
        return false;
    }
    void bind()
    {
        bind(0);
    }
    ///Avoids rebinding to the same sl
    void bind (int slot)
    {
        // if(!slotsBound[slot])
        // {
            slotsBound[slot] = true;
            _hip_d3d_context.PSSetSamplers(slot, 1, &sampler);
            _hip_d3d_context.PSSetShaderResources(slot, 1, &resource);
        // }
    }

    void unbind (int slot)
    {
        // if(slotsBound[slot])
        // {
            slotsBound[slot] = false;
            _hip_d3d_context.PSSetSamplers(slot, 1, &nullSamplerState);
            _hip_d3d_context.PSSetShaderResources(slot, 1, &nullSRV);
        // }
    }
    void unbind(){unbind(0);}
    
    int getWidth() const {return width;}
    int getHeight() const {return height;}
    
}


pure int Hip_D3D11_getTextureFilter(TextureFilter min, TextureFilter mag)
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

pure int Hip_D3D11_getWrapMode(TextureWrapMode mode)
{
    switch(mode) with(TextureWrapMode)
    {
        case CLAMP_TO_EDGE:
            return D3D11_TEXTURE_ADDRESS_CLAMP;
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