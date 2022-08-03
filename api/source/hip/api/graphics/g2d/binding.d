module hip.api.graphics.g2d.binding;

import hip.api.graphics.color;
import hip.api.graphics.g2d.hipsprite;
import hip.api.data.font;
import hip.api.graphics.text;

void initG2D()
{
    version(Script)
    {
        import hip.api.internal;
        loadSymbols!
        (
            renderSprites,
            renderGeometries,
            renderTexts,
            setGeometryColor,
            drawPixel,
            drawRectangle,
            drawTriangle,
            fillRectangle,
            fillTriangle,
            drawLine,
            drawQuadraticBezierLine,
            drawSprite,
            setFont,
            drawText,
            newSprite,
            destroySprite
        );
    }
}

version(Script)
{
    extern(C)
    {
        ///Call this function when finishing to add sprites to the scene
        void function() renderSprites;
        ///Call this function when finishing to add geometries to the scene
        void function() renderGeometries;
        ///Call this function when finishing to add texts to the scene
        void function() renderTexts;
        ///Will change the color for the next calls to drawPixel, drawRectangle, drawTriangle, fillRectangle, fillTriangle, drawLine, drawQuadraticBezierLine
        void function(HipColor color) setGeometryColor;
        ///Draw a pixel at (x, y) with the color specified at setGeometryColor
        void function(int x, int y) drawPixel;
        ///Draws an unfilled rectangle
        void function(int x, int y, int w, int h) drawRectangle;
        ///Draws an unfilled triangle
        void function(int x1, int y1, int x2, int y2, int x3, int y3) drawTriangle;
        ///Draws a filled rectangle
        void function(int x, int y, int w, int h) fillRectangle;
        ///Draws a filled triangle
        void function(int x1, int y1, int x2, int y2, int x3, int y3) fillTriangle;
        ///Draws a line from (x1, y1) to (x2, y2)
        void function(int x1, int y1, int x2, int y2) drawLine;
        ///Draws a line using bezier points. The higher the precision, the smoother the line, the heavier it is to execute
        void function(int x0, int y0, int x1, int y1, int x2, int y2, int precision=24) drawQuadraticBezierLine;
        ///Draws the target sprite instance
        void function(IHipSprite sprite) drawSprite;
        ///Sets the font for the next drawText commands
        void function (HipFont font) setFont;
        ///Draws a text using the last font set
        void function(dstring text, int x, int y, HipColor color = HipColor.white, HipTextAlign alignH = HipTextAlign.LEFT, HipTextAlign alignV = HipTextAlign.CENTER) drawText;
        ///Gets a sprite instance
        IHipSprite function(string texturePath) newSprite;
        ///Destroy a sprite instance
        void function(ref IHipSprite sprite) destroySprite;
    }
}
//Use directly 
else version(Have_hipreme_engine)
{
    public import hip.graphics.g2d.renderer2d;
}

