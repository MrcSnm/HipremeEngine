module view.textureatlasscene;
import graphics.g2d.textureatlas;
import view;

class TextureAtlasScene : Scene
{
    TextureAtlas atlas;
    this()
    {
        atlas = TextureAtlas.readJSON("graphics/atlases/UI.json");
        import std.stdio;
        writeln(atlas.frames);
    }

    override void render()
    {

    }
}