module view.ninepatchtest;
import graphics.g2d.renderer2d;
import graphics.g2d.spritebatch;
import graphics.g2d.ninepatch;
import hipengine;
import view.scene;

class NinePatchSceneTest : Scene
{
    NinePatch ninepatch;
    HipSpriteBatch batch;
    Vector2 lastPos;
    this()
    {
        ninepatch = new NinePatch(800, 600, new Texture("graphics/sprites/nineSlicePanel.png"));
        batch = new HipSpriteBatch();
    }

    override void update(float dt)
    {
        import console.log;
        if(HipInput.isMouseButtonJustPressed())
        {
            lastPos = HipInput.getMousePosition();
            ninepatch.setPosition(lastPos.x, lastPos.y);
        }
        
    }

    override void render()
    {
        batch.begin();
        batch.draw(ninepatch.texture, ninepatch.getVertices());
        // foreach(sp; ninepatch.sprites)
            // batch.draw(sp);
        batch.end();
    }
}