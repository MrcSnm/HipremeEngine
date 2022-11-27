/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.api.graphics.g2d.hipsprite;

version(HipGraphicsAPI):

public import hip.api.graphics.color;
public import hip.api.renderer.texture;
public import hip.api.data.commons;

interface IHipSprite : IHipDeferrableTexture
{
    final IHipTexture getTexture() { return getTextureRegion().getTexture();}
    IHipTextureRegion getTextureRegion();
    
    ///Will ignore the last TextureRegion and create a new one to contain the entire texture
    void setTexture(IHipTexture texture);
    void setPosition(float x, float y);
    void setScale(float x, float y);
    void setColor(HipColor color);
    void setRotation(float rotation);
    void setScroll(float x, float y);
    void setTiling(float x, float y);
    ///Sets the texture from the region
    void setRegion(IHipTextureRegion region);
    void setRegion(TextureCoordinatesQuad c);
    final void setRegion(float u1, float v1, float u2, float v2)
    {
        setRegion(TextureCoordinatesQuad(u1,v1,u2,v2));
    }
    int getWidth() const;
    int getHeight() const;
    int getTextureWidth() const;
    int getTextureHeight() const;
}