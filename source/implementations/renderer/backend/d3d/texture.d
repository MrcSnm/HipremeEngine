module implementations.renderer.backend.d3d.texture;
import bindbc.sdl;
import implementations.renderer.texture;

class Hip_D3D11_Texture : ITexture
{
    ITexture textureImpl;
    this(string texturePath)
    {
        this.texturePath = texturePath;
    }
    public void setWrapMode(TextureWrapMode mode)
    {
        // setWrapMode(mode);
    }
    public bool load(SDL_Surface* surface)
    {
        return false;
    }
    void bind(){}
}