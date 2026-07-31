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

    void initWithFormat(uint width, uint height, TextureFormat format)
    {
        this.width = width;
        this.height = height;
        glCall(() => glGenTextures(1, &textureID));
        bind();
        glCall(() => glTexImage2D(GL_TEXTURE_2D, 0, getInternalFormat(format), width, height, 0, getFormat(format), GL_UNSIGNED_BYTE, null));
        setTextureFilter(TextureFilter.linear, TextureFilter.linear);
        unbind();

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
        textureBinder.unbind(this, false, slot);
    }

    void setWrapMode(TextureWrapMode mode)
    {
        int mod = getGLWrapMode(mode);
        version(GLES2)
        {
            assert((isPowerOf2(width) && isPowerOf2(height)) || mod  == TextureWrapMode.clampToEdge,
                "OpenGL ES 2.0/WebGL 1.0 must use Textures using Power of 2 size. If you wish to use "~
                "a non Power of 2, you must use the TextureWrapMode.clampToEdge"
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
        setTextureFilter(TextureFilter.nearest, TextureFilter.nearest);
        setWrapMode(TextureWrapMode.repeat);

        version(GLES20)
        if(!isPowerOf2(image.getWidth) || !isPowerOf2(image.getHeight))
        {
            setWrapMode(TextureWrapMode.clampToEdge);
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

    void dispose()
    {
        glCall(() => glDeleteTextures(1, &this.textureID));
        width = height = 0;
        this.textureID = 0;
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
        case TextureWrapMode.clampToBorder: return GL_CLAMP_TO_EDGE;
        case TextureWrapMode.repeat: return GL_REPEAT;
        case TextureWrapMode.mirroredRepeat: return GL_MIRRORED_REPEAT;
        static if(!UseGLES)
        {
            //assert here would be better, as simply returning a default can be misleading.
            case TextureWrapMode.mirroredClampToEdge: return GL_MIRROR_CLAMP_TO_EDGE;
        }
        default: return GL_REPEAT;
    }
}

private int getGLMinMagFilter(TextureFilter filter)
{
    switch(filter) with(TextureFilter)
    {
        case linear:
            return GL_LINEAR;
        case nearest:
            return GL_NEAREST;
        case nearestMipNearest:
            return GL_NEAREST_MIPMAP_NEAREST;
        case linearMipNearest:
            return GL_LINEAR_MIPMAP_NEAREST;
        case nearestMipLinear:
            return GL_NEAREST_MIPMAP_LINEAR;
        case linearMipLinear:
            return GL_LINEAR_MIPMAP_LINEAR;
        default:
            return -1;
    }
}

static if(StaticGLES20)
private int getInternalFormatGLES20(TextureFormat f)
{
    import hip.util.conv;
    switch(f)
    {
        case TextureFormat.r8: return GL_LUMINANCE;
        case TextureFormat.rgb8: return GL_RGB;
        case TextureFormat.rgba8: return GL_RGBA;
        default:
            throw new Error("No support to internalFormat "~f.to!string);
    }
}
else
private int getInternalFormat(TextureFormat f)
{
    import hip.hiprenderer.backend.gl.glconfig;
    import hip.util.conv;
    switch(f)
    {
        case TextureFormat.r8: 
            static if(UseWebGL)
                return hipGlCapabilities.gles3Features ? GL_R8 : GL_LUMINANCE;
            return GL_R8;
        case TextureFormat.rgb8:
            return hipGlCapabilities.gles3Features ? GL_RGB8 : GL_RGB;
        case TextureFormat.rgba8:
            return hipGlCapabilities.gles3Features ? GL_RGBA8 : GL_RGBA;
        default:
            throw new Error("No support to internalFormat "~f.to!string);
    }
}

private int getFormat(TextureFormat f)
{
    import hip.util.conv;
    import hip.hiprenderer.backend.gl.glconfig;
    switch(f)
    {
        case TextureFormat.r8:
            static if(StaticGLES20)
                return GL_LUMINANCE;
            else static if(UseWebGL)
                return hipGlCapabilities.gles3Features ? GL_RED : GL_LUMINANCE;
            return GL_RED;
        case TextureFormat.rgb8:
            return GL_RGB;
        case TextureFormat.rgba8:
            return GL_RGBA;
        default:
            throw new Error("No support for format "~f.to!string);
    }
}


private void formatsFromImage(const IImage image, out int internalFormat, out int mode, ref const(ubyte)[] pixels)
{
    if(pixels is null)
        pixels = image.getPixels();
    
    TextureFormat format;
    if(image.hasPalette)
    {
        pixels = image.convertPalettizedToRGBA();
        format = TextureFormat.rgba8;
    }
    else
        format = image.getTextureFormat();
    internalFormat = getInternalFormat(format);
    mode = getFormat(format);
}
