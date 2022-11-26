module hip.api.graphics.g2d.g2d_binding;

import hip.api.graphics.g2d.animation;
import hip.api.graphics.color;
import hip.api.graphics.g2d.hipsprite;
import hip.api.renderer.viewport;
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

version(Have_util)
{
    public import hip.util.data_structures : Array2D, Array2D_GC;
    public alias Spritesheet = Array2D_GC!IHipTextureRegion;
}

version(Script)
{
    extern(System) //All functions there will be loaded
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
        ///Draws a texture at a specified place
        void function(IHipTexture reg, int x, int y, int z = 0, HipColor = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0) drawTexture;
        ///Draws a texture region at a specified place
        void function(IHipTextureRegion reg, int x, int y, int z = 0, HipColor = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0) drawRegion;
        ///Sets the font for the next drawText commands
        package void function (IHipFont font) setFont;
        package void function (typeof(null)) setFontNull;
        ///Sets the font using HipAssetManager.loadFont
        package void function (IHipAssetLoadTask font) setFontDeferred;
        ///Draws a text using the last font set
        void function(string text, int x, int y, HipColor color = HipColor.white, HipTextAlign alignH = HipTextAlign.CENTER, HipTextAlign alignV = HipTextAlign.CENTER, int boundsWidth = -1, int boundsHeight = -1) drawText;
        ///Gets a sprite instance
        IHipSprite function(string texturePath) newSprite;
        ///Destroy a sprite instance
        void function(ref IHipSprite sprite) destroySprite;

        ///Sets active the viewport passed
        void function(Viewport v) setViewport;
        ///Gets the active viewport
        Viewport function() getCurrentViewport;

        ///Width, Height
        int[2] function() getWindowSize;

        void function(uint width, uint height) setWindowSize;

        void function(uint width, uint height) setCameraSize;

        ///Creates a track for the animation controller
        IHipAnimationTrack function(string name, uint framesPerSecond, bool shouldLoop) newHipAnimationTrack;
        ///Creates an animation to be iterated 
        IHipAnimation function(string name) newHipAnimation;


        version(Have_util)
        {
            package Array2D_GC!IHipTextureRegion function(
                IHipTexture t,
                uint frameWidth, uint frameHeight,
                uint width = 0, uint height = 0,
                uint offsetX = 0, uint offsetY = 0,
                uint offsetXPerFrame = 0, uint offsetYPerFrame = 0
            ) cropSpritesheet;
        }
    }
        
    version(Have_util) 
    Array2D_GC!IHipTextureRegion cropSpritesheetRowsAndColumns(IHipTexture t, uint rows, uint columns)
    {
        uint frameWidth = t.getWidth() / columns;
        uint frameHeight = t.getHeight() / rows;
        return cropSpritesheet(t,frameWidth,frameHeight, t.getWidth, t.getHeight, 0, 0, 0, 0);
    }
}
//Use directly 
else version(Have_hipreme_engine)
{
    public import hip.graphics.g2d.renderer2d;
}