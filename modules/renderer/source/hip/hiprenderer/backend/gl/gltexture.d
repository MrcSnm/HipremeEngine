/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.backend.gl.gltexture;
public import hip.api.renderer.texture;

import hip.hiprenderer.backend.gl.glrenderer;
import hip.error.handler;
import hip.image;

class Hip_GL3_Texture : ITexture
{
    GLuint textureID = 0;
    int width, height;
    uint currentSlot;

    protected int getGLWrapMode(TextureWrapMode mode)
    {
        switch(mode)
        {
            case TextureWrapMode.CLAMP_TO_EDGE: return GL_CLAMP_TO_EDGE;
            case TextureWrapMode.REPEAT: return GL_REPEAT;
            case TextureWrapMode.MIRRORED_REPEAT: return GL_MIRRORED_REPEAT;
            version(Android){}
            else version(PSVita){}
            else
            {
                //assert here would be better, as simply returning a default can be misleading.
                case TextureWrapMode.MIRRORED_CLAMP_TO_EDGE: return GL_MIRROR_CLAMP_TO_EDGE;
                case TextureWrapMode.CLAMP_TO_BORDER: return GL_CLAMP_TO_BORDER;
            }
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
    void unbind()
    {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, 0);
    }

    void bind(int slot)
    {
        currentSlot = slot;
        glActiveTexture(GL_TEXTURE0+slot);
        glBindTexture(GL_TEXTURE_2D, textureID);
    }

    void unbind(int slot)
    {
        currentSlot = slot;
        glActiveTexture(GL_TEXTURE0+slot);
        glBindTexture(GL_TEXTURE_2D, 0);
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

    bool load(in IImage image)
    {
        glGenTextures(1, &textureID);
        int mode;
        const(void)[] pixels = image.getPixels;
        switch(image.getBytesPerPixel)
        {
            case 1:
                if(image.hasPalette)
                {
                    pixels = image.convertPalettizedToRGBA();
                    mode = GL_RGBA;
                }
                else
                    mode = GL_RED;
                break;
            case 3:
                mode = GL_RGB;
                break;
            case 4:
                mode = GL_RGBA;
                break;
            case 2:
            default:
                import hip.util.conv;
                ErrorHandler.assertExit(false, "GL Pixel format unsupported on image "~image.getName~", bytesPerPixel: "~to!string(image.getBytesPerPixel));
        }
        bind(currentSlot);
        glTexImage2D(GL_TEXTURE_2D, 0, mode, image.getWidth, image.getHeight, 0, mode, GL_UNSIGNED_BYTE, pixels.ptr);
        width = image.getWidth;
        height = image.getHeight;

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        setWrapMode(TextureWrapMode.REPEAT);
        return true;
    }
    
    int getWidth(){return width;}
    int getHeight(){return height;}
    
}