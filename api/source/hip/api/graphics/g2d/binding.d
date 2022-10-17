module hip.api.graphics.g2d.binding;

import hip.api.graphics.color;
import hip.api.graphics.g2d.hipsprite;
import hip.api.data.font;
import hip.api.graphics.text;

private alias thisModule = __traits(parent, {});
void initG2D()
{
    version(Script)
    {
        import hip.api.internal;
        loadModuleFunctionPointers!thisModule;
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
        ///Draws a texture region at a specified place
        void function(IHipTextureRegion reg, int x, int y, int z = 0, HipColor = HipColor.white) drawRegion;
        ///Sets the font for the next drawText commands
        package void function (HipFont font) _setFont;
        package void function (typeof(null) _) setFontNull;
        ///Sets the font using HipAssetManager.loadFont
        package void function (IHipAssetLoadTask font) setFontDeferred;
        ///Draws a text using the last font set
        void function(dstring text, int x, int y, HipColor color = HipColor.white, HipTextAlign alignH = HipTextAlign.CENTER, HipTextAlign alignV = HipTextAlign.CENTER) drawText;
        ///Gets a sprite instance
        IHipSprite function(string texturePath) newSprite;
        ///Destroy a sprite instance
        void function(ref IHipSprite sprite) destroySprite;

        version(Have_util)
        {
            public import hip.util.data_structures : Array2D_GC;
            public alias Spritesheet = Array2D_GC!IHipTextureRegion;
            package Array2D_GC!IHipTextureRegion function(
                IHipTexture t,
                uint frameWidth, uint frameHeight,
                uint width, uint height,
                uint offsetX, uint offsetY,
                uint offsetXPerFrame, uint offsetYPerFrame
            ) _cropSpritesheet;
        }
    }
    
}
//Use directly 
else version(Have_hipreme_engine)
{
    public import hip.graphics.g2d.renderer2d;
}



version(Have_util)
{
    public import hip.util.data_structures : Array2D, Array2D_GC;

    extern(D) Array2D_GC!IHipTextureRegion cropSpritesheet(
            IHipTexture t,
            uint frameWidth, uint frameHeight,
            uint width, uint height,
            uint offsetX, uint offsetY,
            uint offsetXPerFrame, uint offsetYPerFrame
    )
    {
        return _cropSpritesheet(t, frameWidth, frameHeight,
            width, height,
            offsetX, offsetY,
            offsetXPerFrame, offsetYPerFrame);
    }
    extern(D) Array2D_GC!IHipTextureRegion cropSpritesheet(IHipTexture t, uint frameWidth, uint frameHeight)
    {
        return _cropSpritesheet(t,frameWidth,frameHeight, t.getWidth, t.getHeight, 0, 0, 0, 0);
    }

    extern(D) Array2D_GC!IHipTextureRegion cropSpritesheetRowsAndColumns(IHipTexture t, uint rows, uint columns)
    {
        uint frameWidth = t.getWidth() / columns;
        uint frameHeight = t.getHeight() / rows;
        return _cropSpritesheet(t,frameWidth,frameHeight, t.getWidth, t.getHeight, 0, 0, 0, 0);
    }
}