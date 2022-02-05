module hiprenderer.backend.d3d.d3dframebuffer;

version(Windows):

import directx.d3d11;

import error.handler;
import hiprenderer.texture;
import hiprenderer.renderer;
import hiprenderer.framebuffer;
import hiprenderer.shader;
import hiprenderer.backend.d3d.d3drenderer;
import hiprenderer.backend.d3d.d3dtexture;


private __gshared ID3D11RenderTargetView nullRenderTargetView = null;

class Hip_D3D11_FrameBuffer : IHipFrameBuffer
{
    Texture retTexture;
    ID3D11Texture2D renderTargetTexture;
	ID3D11RenderTargetView renderTargetView;
	ID3D11ShaderResourceView shaderResourceView;

    this(uint width, uint height)
    {
        create(width, height);
    }


    void create(uint width, uint height)
    {
        D3D11_TEXTURE2D_DESC textureDesc;
        HRESULT hres;
        D3D11_RENDER_TARGET_VIEW_DESC renderTargetViewDesc;
	    D3D11_SHADER_RESOURCE_VIEW_DESC shaderResourceViewDesc;

        textureDesc.Width = width;
        textureDesc.Height = height;
        textureDesc.MipLevels = 1;
        textureDesc.ArraySize = 1;
        textureDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
        textureDesc.SampleDesc.Count = 1;
        textureDesc.Usage = D3D11_USAGE_DEFAULT;
        textureDesc.BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE;
        textureDesc.CPUAccessFlags = 0;
        textureDesc.MiscFlags = 0;
        ErrorHandler.startListeningForErrors("D3D11 Framebuffer creation");
        
        hres = _hip_d3d_device.CreateTexture2D(&textureDesc, null, &renderTargetTexture);
        if(FAILED(hres))
            ErrorHandler.showErrorMessage("Texture creation failed",
            "Could not create a texture2D for D3D11 framebuffer");
        HipRenderer.exitOnError();

        renderTargetViewDesc.Format = textureDesc.Format;
        renderTargetViewDesc.ViewDimension = D3D11_RTV_DIMENSION_TEXTURE2D;
        renderTargetViewDesc.Texture2D.MipSlice = 0;

        hres = _hip_d3d_device.CreateRenderTargetView(renderTargetTexture, &renderTargetViewDesc, &renderTargetView);
        if(FAILED(hres))
            ErrorHandler.showErrorMessage("D3D11 RenderTargetView creation failure", "");
        HipRenderer.exitOnError();

        shaderResourceViewDesc.Format = textureDesc.Format;
        shaderResourceViewDesc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2D;
        shaderResourceViewDesc.Texture2D.MostDetailedMip = 0;
        shaderResourceViewDesc.Texture2D.MipLevels = 1;

        hres = _hip_d3d_device.CreateShaderResourceView(renderTargetTexture, &shaderResourceViewDesc, &shaderResourceView);
        if(FAILED(hres))
            ErrorHandler.showErrorMessage("D3D11 ShaderResourceView creation failure", "");
        HipRenderer.exitOnError();
        ErrorHandler.stopListeningForErrors();

        retTexture = new Texture();
        retTexture.width = width;
        retTexture.height = height;
        Hip_D3D11_Texture t = cast(Hip_D3D11_Texture)retTexture.textureImpl;

        t.resource = shaderResourceView;
        t.texture = renderTargetTexture;
        t.updateSamplerState();

        
    }
    void resize(uint width, uint height){}
    void bind()
    {
        _hip_d3d_context.OMSetRenderTargets(1, &renderTargetView, null);
    }
    void unbind()
    {
        _hip_d3d_context.OMSetRenderTargets(1, &_hip_d3d_mainRenderTarget, null);
    }
    void clear()
    {
        float[4] color;
        color[] = 0;
        color[3] = 1.0f;
        _hip_d3d_context.ClearRenderTargetView(renderTargetView, color.ptr);
    }

    Texture getTexture(){return retTexture;}
    void draw(){}
    void dispose()
    {
        if(shaderResourceView)
        {
            shaderResourceView.Release();
            shaderResourceView = null;
        }
        if(renderTargetView)
        {
            renderTargetView.Release();
            renderTargetView = null;
        }
        if(renderTargetTexture)
        {
            renderTargetTexture.Release();
            renderTargetTexture = null;
        }
    }


}