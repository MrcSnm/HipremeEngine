module view.spritetestscene;
import bindbc.sdl;
import bindbc.opengl;
import implementations.renderer.shader;
import graphics.g2d;
import implementations.renderer.renderer;
import view.scene;


class SpriteTestScene : Scene
{
    HipSpriteBatch batch;
    HipSprite sprite;
    this()
    {
        batch = new HipSpriteBatch();
        sprite = new HipSprite("D:\\HipremeEngine\\assets\\graphics\\sprites\\sprite.png");
        import def.debugging.log;
    }

    public override void render()
    {
        super.render();
        Viewport v = HipRenderer.getCurrentViewport();
        v.setSize(800, 600);
        v.update();
        batch.camera.setScale(2, 2);
        batch.begin();
        batch.draw(sprite);
        batch.end();
    }

    public override void onResize(uint width, uint height)
    {
        import def.debugging.log;
        Viewport v = HipRenderer.getCurrentViewport();
        v.update();
        rawlog(v.w, " ", v.h);
    }
}