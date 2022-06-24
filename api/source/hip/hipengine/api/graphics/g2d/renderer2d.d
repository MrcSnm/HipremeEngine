/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.hipengine.api.graphics.g2d.renderer2d;

version(HipGraphicsAPI):

import hip.hipengine.internal;
public import hip.hipengine.api.data.image;
public import hip.hipengine.api.graphics.color;
public import hip.hipengine.api.renderer.texture;
public import hip.hipengine.api.graphics.g2d.hipsprite;


version(Script)
{
    extern(C)
    {
        void function() beginSprite;
        void function() endSprite;
        void function() beginGeometry;
        void function() endGeometry;
        void function(HipColor color) setGeometryColor;
        void function(int x, int y) drawPixel;
        void function(int x, int y, int w, int h) drawRectangle;
        void function(int x1, int y1, int x2, int y2, int x3, int y3) drawTriangle;
        void function(int x, int y, int w, int h) fillRectangle;
        void function(int x1, int y1, int x2, int y2, int x3, int y3) fillTriangle;
        void function(int x1, int y1, int x2, int y2) drawLine;
        void function(IHipSprite sprite) drawSprite;
        IHipSprite function(string texturePath) newSprite;
        void function(ref IHipSprite sprite) destroySprite;
    }
}
else version(Have_hipreme_engine)
{
    public import hip.graphics.g2d.renderer2d;
}


void initG2D()
{
    version(Script)
    {
        loadSymbols!
        (
            beginSprite,
            endSprite,
            beginGeometry,
            endGeometry,
            setGeometryColor,
            drawPixel,
            drawRectangle,
            drawTriangle,
            fillRectangle,
            fillTriangle,
            drawLine,
            drawSprite,
            newSprite,
            destroySprite
        );
    }

}