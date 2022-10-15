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
    void setTexture(IHipTexture texture);
    void setPosition(float x, float y);
    void setScale(float x, float y);
    void setColor(HipColor color);
    void setRotation(float rotation);
    void setScroll(float x, float y);
    void setTiling(float x, float y);
    void setRegion(float x1, float y1, float x2, float y2);
    int getTextureWidth();
    int getTextureHeight();
}