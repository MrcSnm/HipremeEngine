/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.api.renderer.texture;

public import hip.api.data.image;
public import hip.api.graphics.color;

enum TextureWrapMode
{
    CLAMP_TO_EDGE,
    CLAMP_TO_BORDER,
    REPEAT,
    MIRRORED_REPEAT,
    MIRRORED_CLAMP_TO_EDGE,
    UNKNOWN
}

enum TextureFilter
{
    LINEAR,
    NEAREST,
    NEAREST_MIPMAP_NEAREST,
    LINEAR_MIPMAP_NEAREST,
    NEAREST_MIPMAP_LINEAR,
    LINEAR_MIPMAP_LINEAR
}

interface IHipTexture
{
    void setWrapMode(TextureWrapMode mode);
    void setTextureFilter(TextureFilter min, TextureFilter mag);
    IHipTexture getBackendHandle();

    protected bool loadImpl(in IImage img);
    final bool load(in IImage img)
    {
        if(img.hasLoadedData)
            return loadImpl(img);
        return false;
    }
    void bind(int slot = 0);
    void unbind(int slot = 0);

    bool hasSuccessfullyLoaded();

    int getWidth() const;
    int getHeight() const;
}


pragma(LDC_no_typeinfo)
struct TextureCoordinatesQuad
{
    float u1, v1, u2, v2;
}

interface IHipTexturizable
{
    void setTexture(IHipTexture texture);
}

interface IHipTextureRegion
{
    void setTexture(IHipTexture texture);
    const(IHipTexture) getTexture() const;
    IHipTexture getTexture();
    ///Returns this region width
    int getWidth() const;
    ///Returns this region height
    int getHeight() const;

    void setRegion(float u1, float v1, float u2, float v2);
    TextureCoordinatesQuad getRegion() const;
    ref float[8] getVertices();

    void setFlippedX(bool flip);
    void setFlippedY(bool flip);
    bool isFlippedX();
    bool isFlippedY();

    /**
    *   The uint variant from the setRegion receives arguments in a non normalized way to setup
    *   the UV coordinates.
    *   It is better if you wish to just pass where it start and ends.
    *   The region is divided by the width and height
    */
    final void setRegion(int width, int height, uint u1, uint v1, uint u2, uint v2)
    {
        float fu1 = u1/cast(float)width;
        float fu2 = u2/cast(float)width;
        float fv1 = v1/cast(float)height;
        float fv2 = v2/cast(float)height;
        setRegion(fu1, fv1, fu2, fv2);
    }

    /**
    *   The UV coordinates passed are divided by the current texture width and height
    */
    final void setRegion(uint u1, uint v1, uint u2, uint v2)
    {
        setRegion(getTextureWidth(), getTextureHeight(), u1, v1, u2, v2);
    }



    final void setTexture(IHipTexture texture, float u1, float v1, float u2, float v2)
    {
        setTexture(texture);
        setRegion(u1,v1,u2,v2);
    }
    
    final int getTextureWidth() const
    {
        const IHipTexture tex = getTexture();
        if(tex)
            return tex.getWidth();
        return 0;
    }
    final int getTextureHeight() const
    {
        const IHipTexture tex = getTexture();
        if(tex)
            return tex.getHeight();
        return 0;
    }
}
