module hip.api.graphics.g2d.g2d_binding;
public import hip.api.data.commons;
public import hip.api.renderer.operations;
public import hip.api.renderer.viewport;
public import hip.api.data.font;
public import hip.api.data.tilemap;
public import hip.api.graphics.text;
public import hip.api.renderer.shader:ShaderHandle, ShaderVar;

version(Have_util) version = ImportSpritesheet;

version(ImportSpritesheet)
{
    public import hip.util.data_structures : Array2D, Array2D_GC;
    public alias Spritesheet = Array2D_GC!IHipTextureRegion;
}

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
        void function(const HipColor color) setGeometryColor;
        ///Draw a pixel at (x, y) with the color specified at setGeometryColor
        void function(int x, int y, const HipColor color = HipColor.no) drawPixel;
        ///Draws an unfilled rectangle
        void function(float x, float y, float w, float h, const HipColor color = HipColor.no, float rotation = 0) drawRectangle;
        ///Draws an unfilled triangle
        void function(float x1, float y1, float x2, float y2, float x3, float y3, const HipColor color = HipColor.no) drawTriangle;
        ///Draws a filled rectangle
        void function(float x, float y, float w, float h, const HipColor color = HipColor.no, float rotation = 0) fillRectangle;
        ///Draws a filled rectangle with rounded borders
        void function(float x, float y, float w, float h, float radius = 4, const HipColor color = HipColor.no, int precision = 16) fillRoundRect;
        ///Draws a filled triangle
        void function(float x1, float y1, float x2, float y2, float x3, float y3, const HipColor color = HipColor.no) fillTriangle;
        ///Draws unfilled circle
        void function(float x, float y, float radiusW, float radiusH, float degrees = 360, const HipColor color = HipColor.no, int precision = 24) drawEllipse;
        ///Draws a filled circle
        void function(float x, float y, float radiusW, float radiusH, float degrees = 360, const HipColor color = HipColor.no, int precision = 24) fillEllipse;
        ///Draws a line from (x1, y1) to (x2, y2)
        void function(float x1, float y1, float x2, float y2, const HipColor color = HipColor.no) drawLine;
        ///Draws a line using bezier points. The higher the precision, the smoother the line, the heavier it is to execute
        void function(float x0, float y0, float x1, float y1, float x2, float y2, int precision=24, const HipColor color = HipColor.no) drawQuadraticBezierLine;
        ///Draws the target sprite instance
        void function(IHipTexture texture, ubyte[] vertices) drawSprite;
        ///Draws a texture at a specified place
        void function(IHipTexture reg, float x, float y, ushort z = 0, HipColor = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0) drawTexture;
        ///Draws a texture region at a specified place
        void function(IHipTextureRegion reg, float x, float y, ushort z = 0, HipColor = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0) drawRegion;
        void function(IHipTilemap reg) drawMap;
        ///Sets the font for the next drawText commands
        void function (IHipFont font) setFont;
        ///Changes textBatch state to use this color
        void function(HipColor) setTextColor;
        ///Draws a text using the last font set
        void function(string text, float x, float y, float scale = 1.0f, const HipColor color = HipColor.white, HipTextAlign align_ = HipTextAlign.topCenter, Size bounds = Size.init, bool wordWrap = false) drawText;
        ///Draw text using those vertices. Low level API
        void function(ubyte[] vertices, IHipFont font)  drawTextVertices;

        void function(IHipTexture texture, out int width, out int height, out ushort slot) setSpriteBatchTexture;
        bool function() isSpriteInstanced;


        
        ///Sets active the viewport passed
        void function(Viewport v) setViewport;
        ///Gets the active viewport
        Viewport function() getCurrentViewport;

        void function(bool bEnable) setStencilTestingEnabled;
        void function(uint mask) setStencilTestingMask;
        void function(ubyte r, ubyte g, ubyte b, ubyte a) setRendererColorMask;
        void function(HipStencilTestingFunction passFunc, uint reference, uint mask) setStencilTestingFunction;
        void function(HipStencilOperation stencilFail, HipStencilOperation depthFail, HipStencilOperation stencilAndDephPass) setStencilOperation;

        ///Width, Height
        int[2] function() getWindowSize;
        int[2] function() getMaxScreenSize;

        void function(uint width, uint height, bool updateWorld = true) setWindowSize;
        void function(string title) setWindowTitle;
        void function(bool bFullscreen) setFullscreen;
        void function(uint width, uint height) setWorldSize;
        ShaderHandle function() getSpriteBatchShader;
        void function(ShaderHandle handle) setSpriteBatchShader;
        ShaderHandle function(string effect, ShaderVar[] uniforms = null) createSpriteBatchShaderEffect;


        void function(float x = 0, float y = -1) drawGCStats;
        void function(float x = -1, float y = 0, bool clearTiming = false) drawTimings;



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
        void function(int x, int y, in HipColor color = HipColor.no) drawPixel;
        ///Draws an unfilled rectangle
        void function(int x, int y, int w, int h, in HipColor color = HipColor.no, float rotation = 0) drawRectangle;
        ///Draws an unfilled triangle
        void function(int x1, int y1, int x2, int y2, int x3, int y3, in HipColor color = HipColor.no) drawTriangle;
        ///Draws a filled rectangle
        void function(int x, int y, int w, int h, in HipColor color = HipColor.no, float rotation = 0) fillRectangle;
        ///Draws a filled rectangle with rounded borders
        void function(int x, int y, int w, int h, int radius = 4, HipColor color = HipColor.no, int precision = 16) fillRoundRect;
        ///Draws a filled triangle
        void function(int x1, int y1, int x2, int y2, int x3, int y3, in HipColor color = HipColor.no) fillTriangle;
        ///Draws unfilled circle
        void function(int x, int y, int radiusW, int radiusH, int degrees = 360, in HipColor color = HipColor.no, int precision = 24) drawEllipse;
        ///Draws a filled circle
        void function(int x, int y, int radiusW, int radiusH, int degrees = 360, in HipColor color = HipColor.no, int precision = 24) fillEllipse;
        ///Draws a line from (x1, y1) to (x2, y2)
        void function(int x1, int y1, int x2, int y2, in HipColor color = HipColor.no) drawLine;
        ///Draws a line using bezier points. The higher the precision, the smoother the line, the heavier it is to execute
        void function(int x0, int y0, int x1, int y1, int x2, int y2, int precision=24, in HipColor color = HipColor.no) drawQuadraticBezierLine;
        ///Draws the target sprite instance
        void function(IHipTexture texture, ubyte[] vertices) drawSprite;
        ///Draws a texture at a specified place
        void function(IHipTexture reg, int x, int y, ushort z = 0, HipColor = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0) drawTexture;
        ///Draws a texture region at a specified place
        void function(IHipTextureRegion reg, int x, int y, ushort z = 0, HipColor = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0) drawRegion;
        void function(IHipTilemap reg) drawMap;

        ///Changes textBatch state to use this color
        void function(HipColor) setTextColor;
        ///Sets the font for the next drawText commands
        package void function (IHipFont font) setFont;
        ///Draws a text using the last font set
        void function(string text, int x, int y, float scale = 1.0f, HipColor color = HipColor.white, HipTextAlign align_ = HipTextAlign.topCenter, Size bounds = Size.init, bool wordWrap = false) drawText;
        ///Draw text using those vertices. Low level API
        void function(ubyte[] vertices, IHipFont font)  drawTextVertices;
        void function(IHipTexture texture, out int width, out int height, out ushort slot) setSpriteBatchTexture;
        bool function() isSpriteInstanced;
        
        ///Sets active the viewport passed
        void function(Viewport v) setViewport;
        ///Gets the active viewport
        Viewport function() getCurrentViewport;
        void function(bool bEnable) setStencilTestingEnabled;
        void function(uint mask) setStencilTestingMask;
        void function(ubyte r, ubyte g, ubyte b, ubyte a) setRendererColorMask;
        void function(HipStencilTestingFunction passFunc, uint reference, uint mask) setStencilTestingFunction;
        void function(HipStencilOperation stencilFail, HipStencilOperation depthFail, HipStencilOperation stencilAndDephPass) setStencilOperation;

        ///Width, Height
        int[2] function() getWindowSize;
        int[2] function() getMaxScreenSize;

        void function(uint width, uint height, bool updateWorld = true) setWindowSize;
        void function(string title) setWindowTitle;
        void function(bool bFullscreen) setFullscreen;

        void function(uint width, uint height) setWorldSize;

        ShaderHandle function() getSpriteBatchShader;
        void function(ShaderHandle handle) setSpriteBatchShader;

        /** 
         * GLSL Effect example:
        ```d

        struct EffectInput
        {
            vec4 textureColor;
            vec4 uBatchColor;
            vec4 vertexColor;
            vec2 worldPosition;
        }

        //Available Uniforms:
            float uTime;
            float uScreenSize;
        //Access them via 'cbuf', e.g: cbuf.uTime

            
        vec4 effect(EffectInput fx)
        {
            return fx.textureColor * fx.vertexColor * fx.uBatchColor;
        }
        */
        ShaderHandle function(string effect, ShaderVar[] uniforms = null) createSpriteBatchShaderEffect;

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