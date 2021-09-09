/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module hiprenderer.backend.gl.texture;
import hiprenderer.texture;
import hiprenderer.backend.gl.renderer;
import error.handler;
import data.image;
import bindbc.sdl;

class Hip_GL3_Texture : ITexture
{
    GLuint textureID = 0;
    int width, height;
    uint currentSlot;
    this()
    {
        glGenTextures(1, &textureID);
    }
    protected int getGLWrapMode(TextureWrapMode mode)
    {
        switch(mode)
        {
            import gles.gl30;
            version(GLES30){}
            else
            {
                case TextureWrapMode.MIRRORED_CLAMP_TO_EDGE: return GL_MIRROR_CLAMP_TO_EDGE;
                case TextureWrapMode.CLAMP_TO_BORDER: return GL_CLAMP_TO_BORDER;
            }
            case TextureWrapMode.CLAMP_TO_EDGE: return GL_CLAMP_TO_EDGE;
            case TextureWrapMode.REPEAT: return GL_REPEAT;
            case TextureWrapMode.MIRRORED_REPEAT: return GL_MIRRORED_REPEAT;
            default: return GL_REPEAT;
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
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, textureID);
    }
    void bind(int slot)
    {
        currentSlot = slot;
        glActiveTexture(GL_TEXTURE0+slot);
        glBindTexture(GL_TEXTURE_2D, textureID);
    }

    void setWrapMode(TextureWrapMode mode)
    {
        int mod = getGLWrapMode(mode);
        bind(currentSlot);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mod);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mod);
    }

    void setTextureFilter(TextureFilter min, TextureFilter mag)
    {
        int min_filter = getGLMinMagFilter(min);
        int mag_filter = getGLMinMagFilter(mag);
        bind(currentSlot);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, min_filter);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, mag_filter);
    }

    bool load(Image image)
    {
        int mode;
        void* pixels = image.pixels;
        switch(image.bytesPerPixel)
        {
            case 1:
                pixels = image.convertPalettizedToRGBA();
                mode = GL_RGBA;
                break;
            case 3:
                mode = GL_RGB;
                break;
            case 4:
                mode = GL_RGBA;
                break;
            case 2:
            default:
                ErrorHandler.assertExit(false, "GL Pixel format unsupported");
        }
        bind(currentSlot);
        glTexImage2D(GL_TEXTURE_2D, 0, mode, image.w, image.h, 0, mode, GL_UNSIGNED_BYTE, pixels);
        width = image.w;
        height = image.h;

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        setWrapMode(TextureWrapMode.REPEAT);
        return true;
    }
}