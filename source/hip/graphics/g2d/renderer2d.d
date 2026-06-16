module hip.graphics.g2d.renderer2d;

version(Have_bindbc_lua) version = HipremeEngineLua;

import hip.graphics.g2d.spritebatch;
import hip.graphics.g2d.tilemap;
import hip.graphics.g2d.geometrybatch;
import hip.game.orthocamera;
import hip.bind.interpreters;
import hip.hiprenderer;
public import hip.api.graphics.color;
public import hip.graphics.g2d.textrenderer;
public import hip.api.renderer.viewport;
public import hip.api.renderer.operations;
public import hip.api.data.font;

package __gshared
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
    float sharedDepth = 0;
}

void manageBatchChange(IHipBatch newBatch)
{
    if(lastBatch !is newBatch)
    {
        if(lastBatch !is null)
        {
            sharedDepth+= 0.1;
            lastBatch.draw();
        }

        if(newBatch !is null)
            newBatch.setCurrentDepth(sharedDepth);
    }
    lastBatch = newBatch;
}


import hip.console.log;
void initialize(HipInterpreterEntry entry = HipInterpreterEntry.init, bool shouldAutoUpdateCameraAndViewport = true)
{
    autoUpdateCameraAndViewport = shouldAutoUpdateCameraAndViewport;
    hiplog("2D Renderer: Initializing viewport");
    int[2] drawable = HipRenderer.window.getDrawableSize();
    viewport = new Viewport(0, 0, drawable[0], drawable[1]);
    viewport.setWorldSize(HipRenderer.width, HipRenderer.height);
    viewport.setType(ViewportType.fit, HipRenderer.window);
    HipRenderer.setViewport(viewport);
    hiplog("2D Renderer: Initializing camera");
    camera = new HipOrthoCamera();
    camera.setSize(viewport.worldWidth, viewport.worldHeight);

    hiplog("2D Renderer: Initializing text renderer");
    textBatch = new HipTextRenderer(camera);
    hiplog("2D Renderer: Initializing geometrybatch");
    geoBatch = new GeometryBatch(camera);
    hiplog("2D Renderer: Initializing spritebatch");
    spBatch = new HipSpriteBatch(camera);
    // setGeometryColor(HipColor.white);


    version(HipremeEngineLua)
    {
        hiplog("2D Renderer: sending lua functions");
        if(entry != HipInterpreterEntry.init)
        {
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

//TODO: Find a way to remove export from release
export extern(System):
// pragma(inline, true):


///WINDOW
int[2] getWindowSize(){return [viewport.worldWidth, viewport.worldHeight];}
int[2] getMaxScreenSize(){return HipRenderer.window.getMaxScreenSize();}

void setWindowTitle(string title){ HipRenderer.window.setName(title);}
void setFullscreen(bool bFullscreen){ HipRenderer.window.setFullscreen(bFullscreen);}
void setWindowSize(uint width, uint height, bool updateWorld = true)
{
    HipRenderer.setWindowSize(width, height);
    if(updateWorld)
        setWorldSize(width, height);
    HipRenderer.setViewport(viewport);
}

//End Window

void setWorldSize(uint width, uint height)
{
    viewport.setWorldSize(width, height);
    HipRenderer.setViewport(viewport);
    camera.setSize(width, height);
}

HipOrthoCamera getCamera() { return camera; }
void setViewport(Viewport v)
{
    HipRenderer.setViewport(v);
}
void setStencilTestingEnabled(bool bEnable)
{
    manageBatchChange(null);
    HipRenderer.setStencilTestingEnabled(bEnable);
}
void setStencilTestingMask(uint mask)
{
    manageBatchChange(null);
    HipRenderer.setStencilTestingMask(mask);
}
void setRendererColorMask(ubyte r, ubyte g, ubyte b, ubyte a)
{
    manageBatchChange(null);
    HipRenderer.setColorMask(r,g,b,a);
}
void setStencilTestingFunction(HipStencilTestingFunction passFunc, uint reference, uint mask)
{
    manageBatchChange(null);
    HipRenderer.setStencilTestingFunction(passFunc, reference, mask);
}
void setStencilOperation(HipStencilOperation stencilFail, HipStencilOperation depthFail, HipStencilOperation stencilAndDephPass)
{
    manageBatchChange(null);
    HipRenderer.setStencilOperation(stencilFail, depthFail, stencilAndDephPass);
}
Viewport getCurrentViewport()
{
    return HipRenderer.getCurrentViewport();
}

void setRendererErrorCheckingEnabled(bool enable)
{
    HipRenderer.setErrorCheckingEnabled(enable);
}
void setGeometryColor(const HipColor color){geoBatch.setColor(color);}
void drawPixel(int x, int y, const HipColor color = HipColor.no)
{
    manageBatchChange(geoBatch);
    geoBatch.drawPixel(x, y,color);
}
void drawRectangle(float x, float y, float w, float h, const HipColor color = HipColor.no, float rotation = 0)
{
    manageBatchChange(geoBatch);
    geoBatch.drawRectangle(x,y,w,h,color, rotation);
}
void drawTriangle(float x1, float y1, float x2, float y2, float x3, float y3, const HipColor color = HipColor.no)
{
    manageBatchChange(geoBatch);
    geoBatch.drawTriangle(x1,y1,x2,y2,x3,y3,color);
}
void drawEllipse(float x, float y, float radiusW, float radiusH, float degrees = 360, const HipColor color = HipColor.no, int precision = 24)
{
    manageBatchChange(geoBatch);
    geoBatch.drawEllipse(x,y,radiusW,radiusH,degrees,color,precision);
}
void drawLine(float x1, float y1, float x2, float y2, HipColor color = HipColor.no)
{
    manageBatchChange(geoBatch);
    geoBatch.drawLine(x1,y1,x2,y2,color);
}
void drawQuadraticBezierLine(float x0, float y0, float x1, float y1, float x2, float y2, int precision=24, const HipColor color = HipColor.no)
{
    manageBatchChange(geoBatch);
    geoBatch.drawQuadraticBezierLine(x0,y0,x1,y1,x2,y2,precision,color);
}
void fillRectangle(float x, float y, float w, float h, const HipColor color = HipColor.no, float rotation = 0)
{
    manageBatchChange(geoBatch);
    geoBatch.fillRectangle(x,y,w,h,color, rotation);
}
void fillRoundRect(float x, float y, float w, float h, float radius = 4, const HipColor color = HipColor.no, int precision = 16)
{
    manageBatchChange(geoBatch);
    geoBatch.fillRoundRect(x,y,w,h,radius, color, precision);
}
void fillEllipse(float x, float y, float radiusW, float radiusH = -1, float degrees = 360, const HipColor color = HipColor.no, int precision = 24)
{
    manageBatchChange(geoBatch);
    geoBatch.fillEllipse(x,y,radiusW,radiusH,degrees,color,precision);
}
void fillTriangle(float x1, float y1, float x2,  float y2, float x3, float y3, const HipColor color = HipColor.no)
{
    manageBatchChange(geoBatch);
    geoBatch.fillTriangle(x1,y1,x2,y2,x3,y3,color);
}

void drawSprite(IHipTexture texture, ubyte[] vertices)
{
    manageBatchChange(spBatch);
    spBatch.draw(texture, vertices);
}
void drawRegion(IHipTextureRegion reg, float x, float y, ushort z = 0, const HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
{
    manageBatchChange(spBatch);
    spBatch.draw(reg, cast(int)x, cast(int)y, z, color, scaleX, scaleY, rotation);
}
void drawMap(IHipTilemap map)
{
    manageBatchChange(spBatch);
    map.render(spBatch, false);
}

void drawTexture(IHipTexture texture, float x, float y, ushort z = 0, const HipColor color = HipColor.white, float scaleX = 1, float scaleY = 1, float rotation = 0)
{
    manageBatchChange(spBatch);
    spBatch.draw(texture, cast(int)x, cast(int)y, cast(int)z, color, scaleX, scaleY, rotation);
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

void setFont(IHipFont font)
{
    import hip.global.gamedef;
    if(font is null)
        textBatch.setFont(cast(IHipFont)HipDefaultAssets.font);
    else
        textBatch.setFont(font);
}

void setTextColor(HipColor color)
{
    manageBatchChange(textBatch);
    textBatch.setColor(color);
}
void drawText(string text, float x, float y, float scale = 1.0f, const HipColor color = HipColor.white, HipTextAlign align_ = HipTextAlign.centerLeft,
Size bounds = Size.init, bool wordWrap = false)
{
    manageBatchChange(textBatch);
    textBatch.setColor(color);
    textBatch.draw(text, cast(int)x, cast(int)y, scale, align_, bounds, wordWrap);
}

void drawTextVertices(void[] vertices, IHipFont font)
{
    manageBatchChange(textBatch);
    textBatch.addVertices(vertices, font);
}

Array2D_GC!IHipTextureRegion cropSpritesheetRowsAndColumns(IHipTexture t, uint rows, uint columns)
{
    uint frameWidth = t.getWidth() / columns;
    uint frameHeight = t.getHeight() / rows;
        return cropSpritesheet(t,frameWidth,frameHeight, t.getWidth, t.getHeight, 0, 0, 0, 0);
}

void beginRender2D(int frame)
{
    if(geoBatch) geoBatch.beginFrame(frame);
    if(spBatch) spBatch.beginFrame(frame);
    if(textBatch) textBatch.beginFrame(frame);
}

void finishRender2D()
{
    if(geoBatch) geoBatch.flush();
    if(spBatch) spBatch.flush();
    if(textBatch) textBatch.flush();
    lastBatch = null;
    sharedDepth = 0;
    if(geoBatch) geoBatch.setCurrentDepth(0);
    if(spBatch) spBatch.setCurrentDepth(0);
    if(textBatch) textBatch.setCurrentDepth(0);
}

void drawGCStats(float x = 0, float y = -1)
{
    import hip.graphics.g2d.profiling;
    hip.graphics.g2d.profiling.drawGCStats(cast(int)x, cast(int)y);
}

void drawTimings(float x = -1, float y = 0, bool clearTimings = false)
{
    import hip.graphics.g2d.profiling;
    hip.graphics.g2d.profiling.drawTimings(cast(int)x, cast(int)y, clearTimings);
}

version(Standalone)
{
    public import exportd;
}