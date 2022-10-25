module hip.graphics.g2d.renderer2d;
import hip.graphics.g2d.spritebatch;
import hip.graphics.g2d.geometrybatch;
import hip.graphics.orthocamera;
import hip.hiprenderer;
import hip.bind.interpreters;
public import hip.api.graphics.color;
public import hip.api.graphics.g2d.hipsprite;
public import hip.api.math.random;
public import hip.graphics.g2d.sprite;
public import hip.graphics.g2d.textrenderer;
public import hip.api.renderer.viewport;

public import hip.api.data.font;

private __gshared
{
    IHipTexture defaultTexture;
    HipSpriteBatch spBatch;
    GeometryBatch geoBatch;
    HipTextRenderer dbgText;
    HipOrthoCamera camera;
    Viewport viewport;
    HipTextRenderer textRenderer;
    bool autoUpdateCameraAndViewport;
}


void initialize(HipInterpreterEntry entry, bool shouldAutoUpdateCameraAndViewport = true)
{
    autoUpdateCameraAndViewport = shouldAutoUpdateCameraAndViewport;
    viewport = new Viewport(0, 0, HipRenderer.width, HipRenderer.height);
    viewport.setWorldSize(HipRenderer.width, HipRenderer.height);
    viewport.setType(ViewportType.fit, HipRenderer.width, HipRenderer.height);
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
            sendInterpreterFunc!(renderSprites)(entry.intepreter);
            sendInterpreterFunc!(renderGeometries)(entry.intepreter);
            sendInterpreterFunc!(renderTexts)(entry.intepreter);
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
            // sendInterpreterFunc!(drawText)(entry.intepreter); not supported yet
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
            HipRenderer.setViewport(viewport);
        }
        if(camera !is null)
            camera.setSize(cast(int)viewport.worldWidth,cast(int)viewport.worldHeight);
            
    }
}

export extern(C):

int[2] getWindowSize(){return [HipRenderer.width, HipRenderer.height];}
void setCameraSize(uint width, uint height){camera.setSize(width, height);}
void setViewport(Viewport v)
{
    HipRenderer.setViewport(v);
}
Viewport getCurrentViewport()
{
    import hip.util.lifetime;
    return cast(typeof(return))hipSaveRef(HipRenderer.getCurrentViewport());
}
void renderSprites(){spBatch.render;}
void renderGeometries(){geoBatch.flush;}
void renderTexts(){dbgText.render();}
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
void drawRegion(IHipTextureRegion reg, int x, int y, int z = 0, const HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0){spBatch.draw(reg, x, y, z, color, scaleX, scaleY, rotation);}
void drawTexture(IHipTexture texture, int x, int y, int z = 0, const HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0){spBatch.draw(texture, x, y, z, color, scaleX, scaleY, rotation);}

public import hip.util.data_structures : Array2D, Array2D_GC;
Array2D_GC!IHipTextureRegion _cropSpritesheet(
    IHipTexture t,
    uint frameWidth, uint frameHeight,
    uint width, uint height,
    uint offsetX, uint offsetY,
    uint offsetXPerFrame, uint offsetYPerFrame
)
{
    import hip.assets.texture;
    import hip.util.lifetime;
    return cast(typeof(return))hipSaveRef(HipTextureRegion.spritesheet(t, 
        frameWidth, frameHeight, 
        width, height, 
        offsetX, offsetY, 
        offsetXPerFrame, offsetYPerFrame
    ).toGC());
}

void setFontNull(typeof(null) _)
{
    import hip.global.gamedef;
    dbgText.setFont(cast(IHipFont)HipDefaultAssets.font);
}
void setFont(IHipFont font)
{
    if(font is null)
        setFontNull(null);
    else
        dbgText.setFont(font);
}
void setFontDeferred(IHipAssetLoadTask task)
{
    if(task is null)
        setFontNull(null);
    else
        dbgText.setFont(task);
}

void drawText(string text, int x, int y, HipColor color = HipColor.white, HipTextAlign alignH = HipTextAlign.LEFT, HipTextAlign alignV = HipTextAlign.CENTER)
{
    dbgText.setColor(color);
    dbgText.draw(text, x, y, alignH, alignV);
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

