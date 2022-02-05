/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hipengine.api.graphics.g2d.renderer2d;
import hipengine.internal;
public import hipengine.api.data.image;
public import hipengine.api.graphics.color;
public import hipengine.api.renderer.texture;
public import hipengine.api.graphics.g2d.hipsprite;


version(Script)
{
    extern(C) void function() beginSprite;
    extern(C) void function() endSprite;
    extern(C) void function() beginGeometry;
    extern(C) void function() endGeometry;
    extern(C) void function(HipColor color) setGeometryColor;
    extern(C) void function(int x, int y) drawPixel;
    extern(C) void function(int x, int y, int w, int h) drawRectangle;
    extern(C) void function(int x1, int y1, int x2, int y2, int x3, int y3) drawTriangle;
    extern(C) void function(int x, int y, int w, int h) fillRectangle;
    extern(C) void function(int x1, int y1, int x2, int y2, int x3, int y3) fillTriangle;
    extern(C) void function(int x1, int y1, int x2, int y2) drawLine;
    extern(C) void function(IHipSprite sprite) drawSprite;
    extern(C) IHipSprite function(string texturePath) newSprite;
    extern(C) void function(ref IHipSprite sprite) destroySprite;
}
else version(Have_hipreme_engine)
{
    public import graphics.g2d.renderer2d;
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