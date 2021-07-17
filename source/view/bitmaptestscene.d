module view.bitmaptestscene;
import implementations.renderer.bitmaptext;
import def.debugging.log;
import view.scene;


class BitmapTestScene : Scene
{
    HipBitmapText txt;
    this()
    {
        txt = new HipBitmapText();
        txt.setBitmapFont(HipBitmapFont.fromFile("assets/fonts/arial.fnt"));
        txt.setText("DEFAULT");
        logln(txt.font.atlasTexturePath);
        logln(txt.getVertices());
    }

    override void render()
    {

    }
}