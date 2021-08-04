module view.spritetestscene;
import bindbc.sdl;
import bindbc.opengl;
import implementations.renderer.shader;
import implementations.renderer.sprite;
import implementations.renderer.spritebatch;
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

        logln(sprite.getVertices());
    }

    public override void render()
    {
        super.render();
        batch.camera.setScale(4, 4);
        batch.begin();
        batch.draw(sprite);
        batch.end();
    }
}