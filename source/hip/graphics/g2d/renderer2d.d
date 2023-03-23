module hip.graphics.g2d.renderer2d;

version(Have_bindbc_lua) version = HipremeEngineLua;

import hip.graphics.g2d.spritebatch;
import hip.graphics.g2d.tilemap;
import hip.graphics.g2d.geometrybatch;
import hip.graphics.orthocamera;
import hip.hiprenderer;
import hip.bind.interpreters;
public import hip.api.graphics.color;
public import hip.api.data.commons:IHipAssetLoadTask;
public import hip.graphics.g2d.textrenderer;
public import hip.api.renderer.viewport;

public import hip.api.data.font;

private __gshared
{
    IHipTexture defaultTexture;
    HipSpriteBatch spBatch;
    GeometryBatch geoBatch;
    HipTextRenderer textBatch;
    HipOrthoCamera camera;
    Viewport viewport;
    HipTextRenderer textRenderer;
    IHipBatch lastBatch;
    bool autoUpdateCameraAndViewport;
}


import hip.console.log;
void initialize(HipInterpreterEntry entry = HipInterpreterEntry.init, bool shouldAutoUpdateCameraAndViewport = true)
{
    autoUpdateCameraAndViewport = shouldAutoUpdateCameraAndViewport;
    hiplog("2D Renderer: Initializing viewport");
    viewport = new Viewport(0, 0, HipRenderer.width, HipRenderer.height);
    viewport.setWorldSize(HipRenderer.width, HipRenderer.height);
    viewport.setType(ViewportType.fit, HipRenderer.width, HipRenderer.height);
    HipRenderer.setViewport(viewport);
    hiplog("2D Renderer: Initializing camera 1");
    hiplog("2D Renderer: Initializing camera 2");
    hiplog("2D Renderer: Initializing camera 3 ");
    hiplog("2D Renderer: Initializing camera 4");
    camera = new HipOrthoCamera();
    camera.setSize(viewport.worldWidth, viewport.worldHeight);

    hiplog("2D Renderer: Initializing spritebatch");
    spBatch = new HipSpriteBatch(camera);
    hiplog("2D Renderer: Initializing geometrybatch");
    geoBatch = new GeometryBatch(camera);
    hiplog("2D Renderer: Initializing text renderer");
    textBatch = new HipTextRenderer(camera);
    setGeometryColor(HipColor.white);


    version(HipremeEngineLua)
    {
        hiplog("2D Renderer: sending lua functions");
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
            HipRenderer.setViewport(viewport);
        if(camera !is null)
            camera.setSize(viewport.worldWidth, viewport.worldHeight);
    }
}

export extern(System):


int[2] getWindowSize(){return [HipRenderer.width, HipRenderer.height];}

void setWindowSize(uint width, uint height)
{
    HipRenderer.setWindowSize(width, height);
    HipRenderer.setViewport(viewport);
    camera.setSize(cast(int)viewport.worldWidth,cast(int)viewport.worldHeight);
}
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
void renderSprites()
{
    spBatch.render();
}
void setRendererErrorCheckingEnabled(bool enable)
{
    HipRenderer.setErrorCheckingEnabled(enable);
}
void renderGeometries()
{
    geoBatch.flush();
}
void renderTexts()
{
    textBatch.flush();
}
void setGeometryColor(in HipColor color){geoBatch.setColor(color);}
void drawPixel(int x, int y, in HipColor color = HipColor.invalid)
{
    if(lastBatch !is null && lastBatch !is geoBatch)
        lastBatch.flush();
    geoBatch.drawPixel(x, y,color);
    lastBatch = geoBatch;
}
void drawRectangle(int x, int y, int w, int h, in HipColor color = HipColor.invalid)
{
    if(lastBatch !is null && lastBatch !is geoBatch)
        lastBatch.flush();
    geoBatch.drawRectangle(x,y,w,h,color);
    lastBatch = geoBatch;
}
void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3, in HipColor color = HipColor.invalid)
{
    if(lastBatch !is null && lastBatch !is geoBatch)
        lastBatch.flush();
    geoBatch.drawTriangle(x1,y1,x2,y2,x3,y3,color);
    lastBatch = geoBatch;
}
void drawEllipse(int x, int y, int radiusW, int radiusH, int degrees = 360, in HipColor color = HipColor.invalid, int precision = 24)
{
    if(lastBatch !is null && lastBatch !is geoBatch)
        lastBatch.flush();
    geoBatch.drawEllipse(x,y,radiusW,radiusH,degrees,color,precision);
    lastBatch = geoBatch;
}
void drawLine(int x1, int y1, int x2, int y2, in HipColor color = HipColor.invalid)
{
    if(lastBatch !is null && lastBatch !is geoBatch)
        lastBatch.flush();
    geoBatch.drawLine(x1,y1,x2,y2,color);
    lastBatch = geoBatch;
}
void drawQuadraticBezierLine(int x0, int y0, int x1, int y1, int x2, int y2, int precision=24, in HipColor color = HipColor.invalid)
{
    if(lastBatch !is null && lastBatch !is geoBatch)
        lastBatch.flush();
    geoBatch.drawQuadraticBezierLine(x0,y0,x1,y1,x2,y2,precision,color);
    lastBatch = geoBatch;
}
void fillRectangle(int x, int y, int w, int h, in HipColor color = HipColor.invalid)
{
    if(lastBatch !is null && lastBatch !is geoBatch)
        lastBatch.flush();
    geoBatch.fillRectangle(x,y,w,h,color);
    lastBatch = geoBatch;
}
void fillEllipse(int x, int y, int radiusW, int radiusH = -1, int degrees = 360, in HipColor color = HipColor.invalid, int precision = 24)
{
    if(lastBatch !is null && lastBatch !is geoBatch)
        lastBatch.flush();
    geoBatch.fillEllipse(x,y,radiusW,radiusH,degrees,color,precision);
    lastBatch = geoBatch;
}
void fillTriangle(int x1, int y1, int x2,  int y2, int x3, int y3, in HipColor color = HipColor.invalid)
{
    if(lastBatch !is null && lastBatch !is geoBatch)
        lastBatch.flush();
    geoBatch.fillTriangle(x1,y1,x2,y2,x3,y3,color);
    lastBatch = geoBatch;
}

void drawSprite(IHipTexture texture, float[] vertices)
{
    if(lastBatch !is null && lastBatch !is spBatch)
        lastBatch.flush();
    lastBatch = spBatch;
    spBatch.draw(texture, vertices);
    lastBatch = spBatch;
}
void drawRegion(IHipTextureRegion reg, int x, int y, int z = 0, const HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
{
    if(lastBatch !is null && lastBatch !is spBatch)
        lastBatch.flush();
    spBatch.draw(reg, x, y, z, color, scaleX, scaleY, rotation);
    lastBatch = spBatch;
}
void drawMap(IHipTilemap map)
{
    if(lastBatch !is null && lastBatch !is spBatch)
        lastBatch.flush();
    map.render(spBatch, false);
    lastBatch = spBatch;
}

void drawTexture(IHipTexture texture, int x, int y, int z = 0, const HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
{
    if(lastBatch !is null && lastBatch !is spBatch)
        lastBatch.flush();
    spBatch.draw(texture, x, y, z, color, scaleX, scaleY, rotation);
}


public import hip.util.data_structures : Array2D, Array2D_GC;
Array2D_GC!IHipTextureRegion cropSpritesheet(
    IHipTexture t,
    uint frameWidth, uint frameHeight,
    uint width, uint height,
    uint offsetX, uint offsetY,
    uint offsetXPerFrame, uint offsetYPerFrame
)
{
    import hip.assets.texture;
    import hip.util.lifetime;
    return cast(typeof(return))hipSaveRef(HipTextureRegion.cropSpritesheet(t, 
        frameWidth, frameHeight, 
        width, height, 
        offsetX, offsetY, 
        offsetXPerFrame, offsetYPerFrame
    ).toGC());
}

void setFontNull(typeof(null))
{
    import hip.global.gamedef;
    textBatch.setFont(cast(IHipFont)HipDefaultAssets.font);
}
void setFont(IHipFont font)
{
    if(font is null)
        setFontNull(null);
    else
        textBatch.setFont(font);
}
void setFontDeferred(IHipAssetLoadTask task)
{
    if(task is null)
        setFontNull(null);
    else
        textBatch.setFont(task);
}

void drawText(string text, int x, int y, in HipColor color = HipColor.white, HipTextAlign alignH = HipTextAlign.LEFT, HipTextAlign alignV = HipTextAlign.CENTER, 
int boundsWidth = -1, int boundsHeight = -1)
{
    if(lastBatch !is null && lastBatch !is textBatch)
        lastBatch.flush();
    textBatch.setColor(color);
    textBatch.draw(text, x, y, alignH, alignV, boundsWidth, boundsHeight);
    lastBatch = textBatch;
}

Array2D_GC!IHipTextureRegion cropSpritesheetRowsAndColumns(IHipTexture t, uint rows, uint columns)
{
    uint frameWidth = t.getWidth() / columns;
    uint frameHeight = t.getHeight() / rows;
    return cropSpritesheet(t,frameWidth,frameHeight, t.getWidth, t.getHeight, 0, 0, 0, 0);
}

version(Standalone)
{
    public import exportd;
}