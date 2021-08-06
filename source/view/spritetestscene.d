module view.spritetestscene;
import bindbc.sdl;
import bindbc.opengl;
import implementations.renderer.shader;
import implementations.renderer.sprite;
import implementations.renderer.spritebatch;
import implementations.renderer.renderer;
import view.scene;
import graphics.g2d.viewport;


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
        v.setSize(5000, 2500);
        v.update();
        batch.camera.setScale(4, 4);
        batch.begin();
        batch.draw(sprite);
        batch.end();
    }

    public override void onResize(uint width, uint height)
    {
        import std.stdio;
        Viewport v = HipRenderer.getCurrentViewport();
        v.update();
        writeln(v.w, " ", v.h);
    }
}