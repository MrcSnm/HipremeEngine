module implementations.renderer.backend.gl.texture;
import implementations.renderer.texture;
import bindbc.opengl;
import bindbc.sdl;

class Hip_GL3_Texture : ITexture
{
    GLuint textureID = 0;
    int width, height;
    this()
    {
        glGenTextures(1, &textureID);
    }
    protected int getGLWrapMode(TextureWrapMode mode)
    {
        switch(mode)
        {
            case TextureWrapMode.CLAMP_TO_EDGE: return GL_CLAMP_TO_EDGE;
            case TextureWrapMode.CLAMP_TO_BORDER: return GL_CLAMP_TO_BORDER;
            case TextureWrapMode.REPEAT: return GL_REPEAT;
            case TextureWrapMode.MIRRORED_REPEAT: return GL_MIRRORED_REPEAT;
            case TextureWrapMode.MIRRORED_CLAMP_TO_EDGE: return GL_MIRROR_CLAMP_TO_EDGE;
            default: return -1;
        }
    }
    protected int getGLMinMagFilter(TextureFilter filter)
    {
        switch(filter) with(TextureFilter)
        {
            case LINEAR:
                return GL_LINEAR;
            case NEAREST:
                return GL_NEAREST;
            case NEAREST_MIPMAP_NEAREST:
                return GL_NEAREST_MIPMAP_NEAREST;
            case LINEAR_MIPMAP_NEAREST:
                return GL_LINEAR_MIPMAP_NEAREST;
            case NEAREST_MIPMAP_LINEAR:
                return GL_NEAREST_MIPMAP_LINEAR;
            case LINEAR_MIPMAP_LINEAR:
                return GL_LINEAR_MIPMAP_LINEAR;
            default:
                return -1;
        }
    }

    void bind()
    {
        glBindTexture(GL_TEXTURE_2D, textureID);
    }
    void setWrapMode(TextureWrapMode mode)
    {
        int mod = getGLWrapMode(mode);
        glBindTexture(GL_TEXTURE_2D, textureID);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mod);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mod);
    }
    
    void setTextureFilter(TextureFilter min, TextureFilter mag)
    {
        bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    }

    bool load(SDL_Surface* surface)
    {
        int mode = GL_RGB;
        if(surface.format.BytesPerPixel==4)
            mode = GL_RGBA;
        bind();
        glTexImage2D(GL_TEXTURE_2D, 0, mode, surface.w, surface.h, 0, mode, GL_UNSIGNED_BYTE, surface.pixels);
        width = surface.w;
        height = surface.h;

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        setWrapMode(TextureWrapMode.REPEAT);
        return true;
    }
}