module view.bitmaptestscene;
import implementations.renderer;
import def.debugging.log;
import view.scene;


class BitmapTestScene : Scene
{
    HipBitmapText txt;
    this()
    {
        txt = new HipBitmapText();
        txt.setBitmapFont(HipBitmapFont.fromFile("assets/fonts/tnroman.fnt"));
        txt.setText("Esta eh uma frase inteiramente completa.\nTemos que testar, (amigo).");
        logln(txt.font.atlasTexturePath);
        // logln(txt.getVertices());
    }

    override void render()
    {
        HipRenderer.setColor(0,0,0,255);
        HipRenderer.clear();
        txt.render();
        txt.mesh.shader.setVar("uColor", cast(float[4])[1.0, 1.0, 0.0, 1.0]);
    }
}