module hip.graphics.g2d.renderer2d;
public import hip.api.data.commons;
public import hip.api.renderer.operations;
public import hip.api.graphics.color;
public import hip.api.graphics.g2d.animation;
public import hip.api.renderer.viewport;
public import hip.api.data.font;
public import hip.api.data.tilemap;
public import hip.api.graphics.text;

version(Have_util) version = ImportSpritesheet;

version(ImportSpritesheet)
{
    public import hip.util.data_structures : Array2D, Array2D_GC;
    public alias Spritesheet = Array2D_GC!IHipTextureRegion;
}

extern(System):
///Use this only when you're sure you don't need!
void setRendererErrorCheckingEnabled(bool enable = true);

///Will change the color for the next calls to drawPixel, drawRectangle, drawTriangle, fillRectangle, fillTriangle, drawLine, drawQuadraticBezierLine
void setGeometryColor(HipColor color);
///Draw a pixel at (x, y) with the color specified at setGeometryColor
void drawPixel(int x, int y, HipColor color = HipColor.no);
///Draws an unfilled rectangle
void drawRectangle(int x, int y, int w, int h, HipColor color = HipColor.no);
///Draws an unfilled triangle
void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3, HipColor color = HipColor.no);
///Draws a filled rectangle
void fillRectangle(int x, int y, int w, int h, HipColor color = HipColor.no);
///Draws a filled rectangle with rounded borders
void fillRoundRect(int x, int y, int w, int h, int radius = 4, HipColor color = HipColor.no, int precision = 16);
///Draws a filled triangle
void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3, HipColor color = HipColor.no);
///Draws unfilled circle
void drawEllipse(int x, int y, int radiusW, int radiusH, int degrees = 360, HipColor color = HipColor.no, int precision = 24);
///Draws a filled circle
void fillEllipse(int x, int y, int radiusW, int radiusH, int degrees = 360, HipColor color = HipColor.no, int precision = 24);
///Draws a line from (x1, y1) to (x2, y2)
void drawLine(int x1, int y1, int x2, int y2, HipColor color = HipColor.no);
///Draws a line using bezier points. The higher the precision, the smoother the line, the heavier it is to execute
void drawQuadraticBezierLine(int x0, int y0, int x1, int y1, int x2, int y2, int precision=24, HipColor color = HipColor.no);
///Draws the target sprite instance
void drawSprite(IHipTexture texture, ubyte[] vertices);
///Draws a texture at a specified place
void drawTexture(IHipTexture reg, int x, int y, int z = 0, HipColor = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0);
///Draws a texture region at a specified place
void drawRegion(IHipTextureRegion reg, int x, int y, int z = 0, HipColor = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0);
void drawMap(IHipTilemap reg);
///Sets the font for the next drawText commands
void setFont (IHipFont font);
///Sets the font using HipAssetManager.loadFont
package void setFontDeferred (IHipAssetLoadTask font);
///Draws a text using the last font set
void drawText(string text, int x, int y, HipColor color = HipColor.white, HipTextAlign alignH = HipTextAlign.CENTER, HipTextAlign alignV = HipTextAlign.CENTER, int boundsWidth = -1, int boundsHeight = -1, bool wordWrap = false);
///Draw text using those vertices. Low level API
void drawTextVertices(void[] vertices, IHipFont font) ;



///Sets active the viewport passed
void setViewport(Viewport v);
///Gets the active viewport
Viewport getCurrentViewport();

void setStencilTestingEnabled(bool bEnable);
void setStencilTestingMask(uint mask);
void setRendererColorMask(ubyte r, ubyte g, ubyte b, ubyte a);
void setStencilTestingFunction(HipStencilTestingFunction passFunc, uint reference, uint mask);
void setStencilOperation(HipStencilOperation stencilFail, HipStencilOperation depthFail, HipStencilOperation stencilAndDephPass);

///Width, Height
int[2] getWindowSize();

void setWindowSize(uint width, uint height);
void setCameraSize(uint width, uint height);

///Creates a track for the animation controller
IHipAnimationTrack newHipAnimationTrack(string name, uint framesPerSecond, HipAnimationLoopingMode loopingMode = HipAnimationLoopingMode.none);
///Creates an animation to be iterated 
IHipAnimation newHipAnimation(string name);


version(ImportSpritesheet)
package Array2D_GC!IHipTextureRegion cropSpritesheet(
    IHipTexture t,
    uint frameWidth, uint frameHeight,
    uint width = 0, uint height = 0,
    uint offsetX = 0, uint offsetY = 0,
    uint offsetXPerFrame = 0, uint offsetYPerFrame = 0
);
version(ImportSpritesheet)
Array2D_GC!IHipTextureRegion cropSpritesheetRowsAndColumns(IHipTexture t, uint rows, uint columns)
{
    uint frameWidth = t.getWidth() / columns;
    uint frameHeight = t.getHeight() / rows;
    return cropSpritesheet(t,frameWidth,frameHeight, t.getWidth, t.getHeight, 0, 0, 0, 0);
}