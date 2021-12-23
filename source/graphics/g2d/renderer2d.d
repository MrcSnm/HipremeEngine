module graphics.g2d.renderer2d;
import graphics.g2d.spritebatch;
import graphics.g2d.geometrybatch;
public import hipengine.api.graphics.color;
public import hipengine.api.graphics.g2d.hipsprite;
public import graphics.g2d.sprite;

private __gshared HipSpriteBatch spBatch;
private __gshared GeometryBatch geoBatch;


void initialize()
{
    // spBatch = new HipSpriteBatch();
    geoBatch = new GeometryBatch();

    version(HipremeEngineLua)
    {
        import bind.interpreters;

        sendInterpreterFunc!(beginSprite)(HipInterpreter.lua);
        sendInterpreterFunc!(endSprite)(HipInterpreter.lua);
        sendInterpreterFunc!(beginGeometry)(HipInterpreter.lua);
        sendInterpreterFunc!(endGeometry)(HipInterpreter.lua);
        sendInterpreterFunc!(setGeometryColor)(HipInterpreter.lua);
        sendInterpreterFunc!(drawPixel)(HipInterpreter.lua);
        sendInterpreterFunc!(drawRectangle)(HipInterpreter.lua);
        sendInterpreterFunc!(drawTriangle)(HipInterpreter.lua);
        sendInterpreterFunc!(fillRectangle)(HipInterpreter.lua);
        sendInterpreterFunc!(fillTriangle)(HipInterpreter.lua);
        sendInterpreterFunc!(drawLine)(HipInterpreter.lua);
        sendInterpreterFunc!(drawSprite)(HipInterpreter.lua);
        sendInterpreterFunc!(newSprite)(HipInterpreter.lua);
        sendInterpreterFunc!(destroySprite)(HipInterpreter.lua);
        setGeometryColor(HipColor.white);
    }

}

export extern(C) void beginSprite(){spBatch.begin;}
export extern(C) void endSprite(){spBatch.end;}
export extern(C) void beginGeometry(){geoBatch.flush;}
export extern(C) void endGeometry(){geoBatch.flush;}
export extern(C) void setGeometryColor(HipColor color){geoBatch.setColor(color);}
export extern(C) void drawPixel(int x, int y){geoBatch.drawPixel(x, y);}
export extern(C) void drawRectangle(int x, int y, int w, int h){geoBatch.drawRectangle(x,y,w,h);}
export extern(C) void drawTriangle(int x1, int y1, int x2,  int y2, int x3, int y3){geoBatch.drawTriangle(x1,y1,x2,y2,x3,y3);}
export extern(C) void fillRectangle(int x, int y, int w, int h)
{
    geoBatch.fillRectangle(x,y,w,h);
}
export extern(C) void fillTriangle(int x1, int y1, int x2,  int y2, int x3, int y3){geoBatch.fillTriangle(x1,y1,x2,y2,x3,y3);}
export extern(C) void drawLine(int x1, int y1, int x2, int y2){geoBatch.drawLine(x1,y1,x2,y2);}
export extern(C) void drawSprite(IHipSprite sprite){spBatch.draw(cast(HipSprite)sprite);}

private __gshared IHipSprite[] _sprites;
export extern(C) IHipSprite newSprite(string texturePath)
{
    _sprites~= new HipSprite(texturePath);
    return _sprites[$-1];
}
export extern(C) void destroySprite(ref IHipSprite sprite)
{
    import util.array:remove;
    _sprites.remove(sprite);
    sprite = null;
}

