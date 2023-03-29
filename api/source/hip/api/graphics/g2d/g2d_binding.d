module hip.api.graphics.g2d.g2d_binding;
public import hip.api.data.commons;
import hip.api.graphics.g2d.animation;
import hip.api.graphics.color;
import hip.api.renderer.viewport;
import hip.api.data.font;
import hip.api.data.tilemap;
import hip.api.graphics.text;

version(Have_hipreme_engine) version = DirectCall;
version(Have_util) version = ImportSpritesheet;

version(ImportSpritesheet)
{
    public import hip.util.data_structures : Array2D, Array2D_GC;
    public alias Spritesheet = Array2D_GC!IHipTextureRegion;
}

version(DirectCall)
{
    public import hip.graphics.g2d.renderer2d;
}
else
{
    void initG2D()
    {
        import hip.api.internal;
        import hip.api.console;
        loadClassFunctionPointers!HipG2DBinding;
        log("HipengineAPI: Initialized G2D");
    }

    class HipG2DBinding
    {
        extern(System) __gshared //All functions there will be loaded
        {
            ///Use this only when you're sure you don't need!
            void function(bool enable = true) setRendererErrorCheckingEnabled;

            ///Will change the color for the next calls to drawPixel, drawRectangle, drawTriangle, fillRectangle, fillTriangle, drawLine, drawQuadraticBezierLine
            void function(in HipColorf color) setGeometryColor;
            ///Draw a pixel at (x, y) with the color specified at setGeometryColor
            void function(int x, int y, in HipColorf color = HipColorf.invalid) drawPixel;
            ///Draws an unfilled rectangle
            void function(int x, int y, int w, int h, in HipColorf color = HipColorf.invalid) drawRectangle;
            ///Draws an unfilled triangle
            void function(int x1, int y1, int x2, int y2, int x3, int y3, in HipColorf color = HipColorf.invalid) drawTriangle;
            ///Draws a filled rectangle
            void function(int x, int y, int w, int h, in HipColorf color = HipColorf.invalid) fillRectangle;
            ///Draws a filled triangle
            void function(int x1, int y1, int x2, int y2, int x3, int y3, in HipColorf color = HipColorf.invalid) fillTriangle;
            ///Draws unfilled circle
            void function(int x, int y, int radiusW, int radiusH, int degrees = 360, in HipColorf color = HipColorf.invalid, int precision = 24) drawEllipse;
            ///Draws a filled circle
            void function(int x, int y, int radiusW, int radiusH, int degrees = 360, in HipColorf color = HipColorf.invalid, int precision = 24) fillEllipse;
            ///Draws a line from (x1, y1) to (x2, y2)
            void function(int x1, int y1, int x2, int y2, in HipColorf color = HipColorf.invalid) drawLine;
            ///Draws a line using bezier points. The higher the precision, the smoother the line, the heavier it is to execute
            void function(int x0, int y0, int x1, int y1, int x2, int y2, int precision=24, in HipColorf color = HipColorf.invalid) drawQuadraticBezierLine;
            ///Draws the target sprite instance
            void function(IHipTexture texture, float[] vertices) drawSprite;
            ///Draws a texture at a specified place
            void function(IHipTexture reg, int x, int y, int z = 0, HipColorf = HipColorf.white, float scaleX = 1, float scaleY = 1, float rotation = 0) drawTexture;
            ///Draws a texture region at a specified place
            void function(IHipTextureRegion reg, int x, int y, int z = 0, HipColorf = HipColorf.white, float scaleX = 1, float scaleY = 1, float rotation = 0) drawRegion;
            void function(IHipTilemap reg) drawMap;
            ///Sets the font for the next drawText commands
            package void function (IHipFont font) setFont;
            package void function (typeof(null)) setFontNull;
            ///Sets the font using HipAssetManager.loadFont
            package void function (IHipAssetLoadTask font) setFontDeferred;
            ///Draws a text using the last font set
            void function(string text, int x, int y, HipColorf color = HipColorf.white, HipTextAlign alignH = HipTextAlign.CENTER, HipTextAlign alignV = HipTextAlign.CENTER, int boundsWidth = -1, int boundsHeight = -1) drawText;
            
            ///Sets active the viewport passed
            void function(Viewport v) setViewport;
            ///Gets the active viewport
            Viewport function() getCurrentViewport;

            ///Width, Height
            int[2] function() getWindowSize;

            void function(uint width, uint height) setWindowSize;

            void function(uint width, uint height) setCameraSize;

            ///Creates a track for the animation controller
            IHipAnimationTrack function(string name, uint framesPerSecond, HipAnimationLoopingMode loopingMode = HipAnimationLoopingMode.none) newHipAnimationTrack;
            ///Creates an animation to be iterated 
            IHipAnimation function(string name) newHipAnimation;


            version(ImportSpritesheet)
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
    }

    version(ImportSpritesheet)
    Array2D_GC!IHipTextureRegion cropSpritesheetRowsAndColumns(IHipTexture t, uint rows, uint columns)
    {
        uint frameWidth = t.getWidth() / columns;
        uint frameHeight = t.getHeight() / rows;
        return cropSpritesheet(t,frameWidth,frameHeight, t.getWidth, t.getHeight, 0, 0, 0, 0);
    }
    import hip.api.internal;
    mixin ExpandClassFunctionPointers!HipG2DBinding;
}


//Code suggestion
version(none)
{
    extern(System) __gshared //All functions there will be loaded
    {
        ///Use this only when you're sure you don't need!
        void function(bool enable = true) setRendererErrorCheckingEnabled;

        ///Will change the color for the next calls to drawPixel, drawRectangle, drawTriangle, fillRectangle, fillTriangle, drawLine, drawQuadraticBezierLine
        void function(in HipColor color) setGeometryColor;
        ///Draw a pixel at (x, y) with the color specified at setGeometryColor
        void function(int x, int y, in HipColor color = HipColor.invalid) drawPixel;
        ///Draws an unfilled rectangle
        void function(int x, int y, int w, int h, in HipColor color = HipColor.invalid) drawRectangle;
        ///Draws an unfilled triangle
        void function(int x1, int y1, int x2, int y2, int x3, int y3, in HipColor color = HipColor.invalid) drawTriangle;
        ///Draws a filled rectangle
        void function(int x, int y, int w, int h, in HipColor color = HipColor.invalid) fillRectangle;
        ///Draws a filled triangle
        void function(int x1, int y1, int x2, int y2, int x3, int y3, in HipColor color = HipColor.invalid) fillTriangle;
        ///Draws unfilled circle
        void function(int x, int y, int radiusW, int radiusH, int degrees = 360, in HipColor color = HipColor.invalid, int precision = 24) drawEllipse;
        ///Draws a filled circle
        void function(int x, int y, int radiusW, int radiusH, int degrees = 360, in HipColor color = HipColor.invalid, int precision = 24) fillEllipse;
        ///Draws a line from (x1, y1) to (x2, y2)
        void function(int x1, int y1, int x2, int y2, in HipColor color = HipColor.invalid) drawLine;
        ///Draws a line using bezier points. The higher the precision, the smoother the line, the heavier it is to execute
        void function(int x0, int y0, int x1, int y1, int x2, int y2, int precision=24, in HipColor color = HipColor.invalid) drawQuadraticBezierLine;
        ///Draws the target sprite instance
        void function(IHipTexture texture, float[] vertices) drawSprite;
        ///Draws a texture at a specified place
        void function(IHipTexture reg, int x, int y, int z = 0, HipColor = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0) drawTexture;
        ///Draws a texture region at a specified place
        void function(IHipTextureRegion reg, int x, int y, int z = 0, HipColor = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0) drawRegion;
        void function(IHipTilemap reg) drawMap;
        ///Sets the font for the next drawText commands
        package void function (IHipFont font) setFont;
        package void function (typeof(null)) setFontNull;
        ///Sets the font using HipAssetManager.loadFont
        package void function (IHipAssetLoadTask font) setFontDeferred;
        ///Draws a text using the last font set
        void function(string text, int x, int y, HipColor color = HipColor.white, HipTextAlign alignH = HipTextAlign.CENTER, HipTextAlign alignV = HipTextAlign.CENTER, int boundsWidth = -1, int boundsHeight = -1) drawText;
        
        ///Sets active the viewport passed
        void function(Viewport v) setViewport;
        ///Gets the active viewport
        Viewport function() getCurrentViewport;

        ///Width, Height
        int[2] function() getWindowSize;

        void function(uint width, uint height) setWindowSize;

        void function(uint width, uint height) setCameraSize;

        ///Creates a track for the animation controller
        IHipAnimationTrack function(string name, uint framesPerSecond, HipAnimationLoopingMode loopingMode = HipAnimationLoopingMode.none) newHipAnimationTrack;
        ///Creates an animation to be iterated 
        IHipAnimation function(string name) newHipAnimation;


        version(ImportSpritesheet)
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
}