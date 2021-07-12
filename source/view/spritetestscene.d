module view.spritetestscene;
import bindbc.sdl;
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
        batch = new HipSpriteBatch(1);
        sprite = new HipSprite("D:\\HipremeEngine\\assets\\graphics\\sprites\\sprite.png");
        import def.debugging.log;

        logln(sprite.getVertices());
    }

    public override void render()
    {
        super.render();
        batch.begin();
        batch.draw(sprite);
        batch.end();
    }
}