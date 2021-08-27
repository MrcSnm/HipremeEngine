/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module hiprenderer.backend.d3d.texture;
version(Windows):
import hiprenderer.backend.d3d.renderer;
import data.image;
import directx.d3d11;
import bindbc.sdl;
import hiprenderer.texture;

class Hip_D3D11_Texture : ITexture
{
    ID3D11Texture2D texture;
    ID3D11ShaderResourceView resource;
    ID3D11SamplerState sampler;
    float[4] borderColor;
    int filter = Hip_D3D11_getTextureFilter(TextureFilter.NEAREST, TextureFilter.NEAREST);
    int wrap = Hip_D3D11_getWrapMode(TextureWrapMode.REPEAT);

    void setTextureFilter(TextureFilter mag, TextureFilter min)
    {
        filter = Hip_D3D11_getTextureFilter(min, mag);
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
    public void setWrapMode(TextureWrapMode mode)
    {
        wrap = Hip_D3D11_getWrapMode(mode);
        updateSamplerState();
    }
    // protected DXGI_FORMAT getFromFromSurface(SDL_Surface* surface)
    // {
    //     return DXGI_FORMAT_R8G8B8A8_UNORM;
    // }
    public bool load(Image image)
    {
        D3D11_TEXTURE2D_DESC desc;
        // desc.Format = getFromFromSurface(surface);
        desc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
        desc.Usage = D3D11_USAGE_IMMUTABLE;
        desc.CPUAccessFlags = 0;
        desc.MipLevels = 1;
        desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
        desc.Width = image.w;
        desc.Height = image.h;

        D3D11_SUBRESOURCE_DATA data;
        data.pSysMem = image.pixels;
        data.SysMemPitch = image.w*image.bytesPerPixel;

        _hip_d3d_device.CreateTexture2D(&desc, &data, &texture);
        _hip_d3d_device.CreateShaderResourceView(texture, cast(D3D11_SHADER_RESOURCE_VIEW_DESC*)null, &resource);
        updateSamplerState();
        return false;
    }
    void bind()
    {
        _hip_d3d_context.PSSetSamplers(0, 1, &sampler);
        _hip_d3d_context.PSSetShaderResources(0, 1, &resource);
    }
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