module hip.view.ninepatchtest;
version(Test):
import hip.graphics.g2d.renderer2d;
import hip.graphics.g2d.spritebatch;
import hip.graphics.g2d.ninepatch;
import hip.api;
import hip.math.vector;
import hip.view.scene;

class NinePatchSceneTest : Scene
{
    NinePatch ninepatch;
    HipSpriteBatch batch;
    Vector2 startPatch;
    this()
    {
        ninepatch = new NinePatch(800, 600, new HipTexture("graphics/sprites/nineSlicePanel.png"));
        batch = new HipSpriteBatch();
    }

    override void update(float dt)
    {
        // import hip.console.log;
        // logln(ninepatch.width);
        if(HipInput.isMouseButtonJustPressed())
        {
            startPatch = HipInput.getMousePosition();
            ninepatch.setPosition(startPatch.x, startPatch.y);
        }
        else if(HipInput.isMouseButtonPressed())
        {
            Vector2 delta = Vector2(HipInput.getMousePosition()) - startPatch;
            ninepatch.setSize(cast(int)delta.x, cast(int)delta.y);
        }
        
    }

    override void render()
    {
        batch.draw(ninepatch.texture, ninepatch.getVertices());
        // foreach(sp; ninepatch.sprites)
            // batch.draw(sp);
        batch.render();
    }
}