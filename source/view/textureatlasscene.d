module view.textureatlasscene;
import hiprenderer;
import graphics.g2d.textureatlas;
import graphics.g2d.spritebatch;
import graphics.g2d.animation;
import view;

class TextureAtlasScene : Scene
{
    TextureAtlas atlas;
    HipAnimation emerald;
    HipSpriteBatch batch;
    this()
    {
        atlas = TextureAtlas.readJSON("graphics/atlases/UI.json");
        batch = new HipSpriteBatch();
        emerald = HipAnimation.fromAtlas(atlas, "emerald", 12, true);
    }
    override void update(float dt)
    {
        emerald.update(dt);
    }

    override void render()
    {
        batch.camera.setScale(4,4);
        batch.begin();
        batch.draw(emerald.getCurrentFrame().region, 0, 0);
        batch.end();
    }
}