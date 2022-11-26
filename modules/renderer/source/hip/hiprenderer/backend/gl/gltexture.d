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

version(OpenGL):
public import hip.api.renderer.texture;
public import hip.api.data.commons:IReloadable;

import hip.hiprenderer.backend.gl.glrenderer;
import hip.error.handler;
import hip.image;

class Hip_GL3_Texture : IHipTexture, IReloadable
{
    GLuint textureID = 0;
    int width, height;
    uint currentSlot;

    private IImage loadedImage;

    bool hasSuccessfullyLoaded(){return width > 0;}
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
        glCall(() => glActiveTexture(GL_TEXTURE0));
        glCall(() => glBindTexture(GL_TEXTURE_2D, textureID));
    }
    void unbind()
    {
        glCall(() => glActiveTexture(GL_TEXTURE0));
        glCall(() => glBindTexture(GL_TEXTURE_2D, 0));
    }

    void bind(int slot)
    {
        currentSlot = slot;
        glCall(() => glActiveTexture(GL_TEXTURE0+slot));
        glCall(() => glBindTexture(GL_TEXTURE_2D, textureID));
    }

    void unbind(int slot)
    {
        currentSlot = slot;
        glCall(() => glActiveTexture(GL_TEXTURE0+slot));
        glCall(() => glBindTexture(GL_TEXTURE_2D, 0));
    }

    void setWrapMode(TextureWrapMode mode)
    {
        int mod = getGLWrapMode(mode);
        bind(currentSlot);
        glCall(() => glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mod));
        glCall(() => glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mod));
    }

    void setTextureFilter(TextureFilter min, TextureFilter mag)
    {
        int min_filter = getGLMinMagFilter(min);
        int mag_filter = getGLMinMagFilter(mag);
        bind(currentSlot);
        glCall(() => glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, min_filter));
        glCall(() => glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, mag_filter));
    }

    protected bool loadImpl(in IImage image)
    {
        loadedImage = cast(IImage)image;
        glCall(() => glGenTextures(1, &textureID));
        int mode;
        int internalFormat;
        const(void)[] pixels = image.getPixels;
        switch(image.getBytesPerPixel)
        {
            case 1:
                if(image.hasPalette)
                {
                    pixels = image.convertPalettizedToRGBA();
                    mode = GL_RGBA;
                    internalFormat = GL_RGBA8;
                }
                else
                {
                    mode = GL_RED;
                    internalFormat = GL_R8;
                }
                break;
            case 3:
                mode = GL_RGB;
                internalFormat = GL_RGB8;
                break;
            case 4:
                mode = GL_RGBA;
                internalFormat = GL_RGBA;
                break;
            case 2:
            default:
                import hip.util.conv;
                ErrorHandler.assertExit(false, "GL Pixel format unsupported on image "~image.getName~", bytesPerPixel: "~to!string(image.getBytesPerPixel));
        }
        width = image.getWidth;
        height = image.getHeight;
        bind(currentSlot);

        glCall(() => glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, image.getWidth, image.getHeight, 0, mode, GL_UNSIGNED_BYTE, pixels.ptr));

        glCall(() => glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST));
        glCall(() => glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST));
        setWrapMode(TextureWrapMode.REPEAT);
        return true;
    }
    
    int getWidth() const {return width;}
    int getHeight() const {return height;}
    
    bool reload()
    {
        if(loadedImage !is null)
        {
            textureID = 0;
            return loadImpl(loadedImage);
        }
        return false;
    }
    
    
}