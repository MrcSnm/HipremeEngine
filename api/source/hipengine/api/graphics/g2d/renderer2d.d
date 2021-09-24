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
        loadSymbol!beginSprite;
        loadSymbol!endSprite;
        loadSymbol!beginGeometry;
        loadSymbol!endGeometry;
        loadSymbol!setGeometryColor;
        loadSymbol!drawPixel;
        loadSymbol!drawRectangle;
        loadSymbol!drawTriangle;
        loadSymbol!fillRectangle;
        loadSymbol!fillTriangle;
        loadSymbol!drawLine;
        loadSymbol!drawSprite;
        loadSymbol!newSprite;
        loadSymbol!destroySprite;
    }
}