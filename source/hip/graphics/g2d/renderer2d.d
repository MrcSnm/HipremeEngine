module hip.graphics.g2d.renderer2d;
import hip.graphics.g2d.spritebatch;
import hip.graphics.g2d.geometrybatch;
import hip.graphics.orthocamera;
import hip.hiprenderer;
import hip.bind.interpreters;
public import hip.hipengine.api.graphics.color;
public import hip.hipengine.api.graphics.g2d.hipsprite;
public import hip.hipengine.api.math;
public import hip.graphics.g2d.sprite;
public import hip.graphics.g2d.textrenderer;

public import hip.hipengine.api.data.font;

private __gshared
{
    HipSpriteBatch spBatch;
    GeometryBatch geoBatch;
    HipTextRenderer dbgText;
    HipOrthoCamera camera;
    FitViewport viewport;
    HipTextRenderer textRenderer;
    bool autoUpdateCameraAndViewport;
}


void initialize(HipInterpreterEntry entry, bool shouldAutoUpdateCameraAndViewport = true)
{
    autoUpdateCameraAndViewport = shouldAutoUpdateCameraAndViewport;
    viewport = new FitViewport(0, 0, HipRenderer.width, HipRenderer.height);
    viewport.setSize(HipRenderer.width, HipRenderer.height);
    HipRenderer.setViewport(viewport);
    camera = new HipOrthoCamera();
    camera.setSize(viewport.worldWidth, viewport.worldHeight);

    spBatch = new HipSpriteBatch(camera);
    geoBatch = new GeometryBatch(camera);
    dbgText = new HipTextRenderer();
    setGeometryColor(HipColor.white);

    version(HipremeEngineLua)
    {
        if(entry != HipInterpreterEntry.init)
        {
            sendInterpreterFunc!(beginSprite)(entry.intepreter);
            sendInterpreterFunc!(endSprite)(entry.intepreter);
            sendInterpreterFunc!(beginGeometry)(entry.intepreter);
            sendInterpreterFunc!(endGeometry)(entry.intepreter);
            sendInterpreterFunc!(setGeometryColor)(entry.intepreter);
            sendInterpreterFunc!(drawPixel)(entry.intepreter);
            sendInterpreterFunc!(drawRectangle)(entry.intepreter);
            sendInterpreterFunc!(drawTriangle)(entry.intepreter);
            sendInterpreterFunc!(fillRectangle)(entry.intepreter);
            sendInterpreterFunc!(fillEllipse)(entry.intepreter);
            sendInterpreterFunc!(drawEllipse)(entry.intepreter);
            sendInterpreterFunc!(fillTriangle)(entry.intepreter);
            sendInterpreterFunc!(drawLine)(entry.intepreter);
            sendInterpreterFunc!(drawQuadraticBezierLine)(entry.intepreter);
            sendInterpreterFunc!(drawSprite)(entry.intepreter);
            sendInterpreterFunc!(newSprite)(entry.intepreter);
            sendInterpreterFunc!(destroySprite)(entry.intepreter);
        }
    }

}

/**
*   This resizes both the 2D renderer viewport and its Orthographic Camera, maintaining always the
*   correct aspect ratio
*/
void resizeRenderer2D(uint width, uint height)
{
    if(autoUpdateCameraAndViewport)
    {
        if(viewport !is null && HipRenderer.getCurrentViewport() == viewport)
        {
            viewport.setSize(width, height);
            HipRenderer.setViewport(viewport);
        }
        if(camera !is null)
            camera.setSize(cast(int)viewport.width,cast(int)viewport.height);
            
    }
}

export extern(C):

void beginSprite(){spBatch.begin;}
void endSprite(){spBatch.end;}
void beginGeometry(){geoBatch.flush;}
void endGeometry(){geoBatch.flush;}
void setGeometryColor(HipColor color){geoBatch.setColor(color);}
void drawPixel(int x, int y){geoBatch.drawPixel(x, y);}
void drawRectangle(int x, int y, int w, int h){geoBatch.drawRectangle(x,y,w,h);}
void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3){geoBatch.drawTriangle(x1,y1,x2,y2,x3,y3);}
void fillRectangle(int x, int y, int w, int h)
{
    geoBatch.fillRectangle(x,y,w,h);
}
void fillEllipse(int x, int y, int radiusW, int radiusH = -1, int degrees = 360, int precision = 24){geoBatch.fillEllipse(x,y,radiusW,radiusH,degrees,precision);}
void drawEllipse(int x, int y, int radiusW, int radiusH, int degrees = 360, int precision = 24){geoBatch.drawEllipse(x,y,radiusW,radiusH,degrees,precision);}
void fillTriangle(int x1, int y1, int x2,  int y2, int x3, int y3){geoBatch.fillTriangle(x1,y1,x2,y2,x3,y3);}
void drawLine(int x1, int y1, int x2, int y2){geoBatch.drawLine(x1,y1,x2,y2);}
void drawQuadraticBezierLine(int x0, int y0, int x1, int y1, int x2, int y2, int precision=24){geoBatch.drawQuadraticBezierLine(x0,y0,x1,y1,x2,y2,precision);}
void drawSprite(IHipSprite sprite){spBatch.draw(cast(HipSprite)sprite);}

void setFont(HipFont font){dbgText.setFont(font);}
void drawText(dstring text, int x, int y, HipColor color = HipColor.white, HipTextAlign alignH = HipTextAlign.CENTER, HipTextAlign alignV = HipTextAlign.CENTER)
{
    dbgText.x = x;
    dbgText.y = y;
    dbgText.alignh = alignH;
    dbgText.alignv = alignV;
    dbgText.setText(text);
    dbgText.render();
}

private __gshared IHipSprite[] _sprites;
IHipSprite newSprite(string texturePath)
{
    _sprites~= new HipSprite(texturePath);
    return _sprites[$-1];
}

void destroySprite(ref IHipSprite sprite)
{
    import hip.util.array:remove;
    _sprites.remove(sprite);
    sprite = null;
}

