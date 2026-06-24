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

import hip.api.renderer.vertex;

version(OpenGL):
public import hip.api.renderer.texture;
public import hip.api.data.commons:IReloadable;
import hip.config.renderer;
import hip.api.renderer.core;
import hip.hiprenderer.backend.gl.glrenderer;
import hip.error.handler;
import hip.assets.image;
import hip.math.utils;

final class Hip_GL3_Texture : IHipTexture, IReloadable
{
    import hip.util.data_structures;
    GLuint textureID = 0;
    int width, height;
    int glTexType = GL_TEXTURE_2D;
    uint currentSlot;

    private IImage loadedImage;
    alias activeTextureBinder = DelayedBindable!(int, NeedsUnbind, BindReplacesUnbind, 1, 
        (int slot){glCall(() => glActiveTexture(GL_TEXTURE0+slot));},
        (int){}
    );

    ///128 textures should be enough
    alias textureBinder = DelayedBindable!(Hip_GL3_Texture, NeedsUnbind, BindReplacesUnbind, 128,
        (Hip_GL3_Texture tex, int slot){glBindTexture(tex.glTexType, tex.textureID);},
        (Hip_GL3_Texture tex, int){glBindTexture(tex.glTexType, 0);}
    );

    
    this(HipResourceUsage usage, HipTextureType type)
    {
        glTexType = getGLTextureType(type);
    }
    bool hasSuccessfullyLoaded(){return width > 0;}


    void bind(int slot = 0)
    {
        activeTextureBinder.bind(slot);
        textureBinder.bind(this, slot);
        currentSlot = slot;
    }

    void unbind(int slot = 0)
    {
        activeTextureBinder.bind(currentSlot);
        textureBinder.unbind(this, slot);
    }

    void setWrapMode(TextureWrapMode mode)
    {
        int mod = getGLWrapMode(mode);
        version(GLES2)
        {
            assert((isPowerOf2(width) && isPowerOf2(height)) || mod  == TextureWrapMode.CLAMP_TO_EDGE,
                "OpenGL ES 2.0/WebGL 1.0 must use Textures using Power of 2 size. If you wish to use "~
                "a non Power of 2, you must use the TextureWrapMode.CLAMP_TO_EDGE"
            );
        }
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
        if(textureID == 0)
        {
            ErrorHandler.assertExit(false, "No texture was generated for image ", image.getName);
        }
        int mode;
        int internalFormat;
        const(ubyte)[] pixels;
        formatsFromImage(image, internalFormat, mode, pixels);
        width = image.getWidth;
        height = image.getHeight;
        bind(currentSlot);

        glCall(() => glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, image.getWidth, image.getHeight, 0, mode, GL_UNSIGNED_BYTE, cast(void*)pixels.ptr));
        glCall(() => glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST));
        glCall(() => glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST));
        setWrapMode(TextureWrapMode.REPEAT);

        version(GLES20)
        if(!isPowerOf2(image.getWidth) || !isPowerOf2(image.getHeight))
        {
            setWrapMode(TextureWrapMode.CLAMP_TO_EDGE);
        }
        return true;
    }

    void updatePixels(int x, int y, int width, int height, const(ubyte)[] pixels)
    {
        int internalFormat, mode;
        formatsFromImage(loadedImage, internalFormat, mode, pixels);
        glCall(() => glTexSubImage2D(GL_TEXTURE_2D, 0, x, y, width, height, mode, GL_UNSIGNED_BYTE, cast(void*)pixels.ptr));
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

private int getGLTextureType(HipTextureType type)
{
    final switch(type)
    {
        case HipTextureType.CubeMap: return GL_TEXTURE_CUBE_MAP;
        case HipTextureType.Texture2D: return GL_TEXTURE_2D;
    }
}

private int getGLWrapMode(TextureWrapMode mode)
{
    switch(mode)
    {
        case TextureWrapMode.CLAMP_TO_EDGE: return GL_CLAMP_TO_EDGE;
        case TextureWrapMode.REPEAT: return GL_REPEAT;
        case TextureWrapMode.MIRRORED_REPEAT: return GL_MIRRORED_REPEAT;
        static if(!UseGLES)
        {
            //assert here would be better, as simply returning a default can be misleading.
            case TextureWrapMode.MIRRORED_CLAMP_TO_EDGE: return GL_MIRROR_CLAMP_TO_EDGE;
            case TextureWrapMode.CLAMP_TO_BORDER: return GL_CLAMP_TO_BORDER;
        }
        default: return GL_REPEAT;
    }
}

private int getGLMinMagFilter(TextureFilter filter)
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

private void formatsFromImage(const IImage image, out int internalFormat, out int mode, ref const(ubyte)[] pixels)
{
    if(pixels is null)
        pixels = image.getPixels();
    switch(image.getBytesPerPixel)
    {
        case 1:
            if(image.hasPalette)
            {
                pixels = image.convertPalettizedToRGBA();
                version(GLES20)
                {
                    internalFormat = mode = GL_RGBA;
                }
                else
                {
                    mode = GL_RGBA;
                    internalFormat = GL_RGBA8;
                }
            }
            else
            {
                version(GLES20)
                {
                    internalFormat = mode = GL_LUMINANCE;
                }
                else
                {
                    mode = GL_RED;
                    internalFormat = GL_R8;
                }
            }
            break;
        case 3:
            version(GLES20)
            {
                internalFormat = mode = GL_RGB;
            }
            else
            {
                mode = GL_RGB;
                internalFormat = GL_RGB8;
            }
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
}
