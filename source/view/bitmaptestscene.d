module view.bitmaptestscene;
import std.stdio;
import implementations.renderer.tilemap;
import sdl.event.handlers.input.keyboard_layout;
import implementations.renderer;
import sdl.event.handlers.keyboard;
import def.debugging.log;
import view.scene;


class BitmapTestScene : Scene
{
    HipBitmapText txt;
    static KeyboardLayout abnt2;
    this()
    {
        txt = new HipBitmapText();
        abnt2 = new KeyboardLayoutABNT2();
        txt.setBitmapFont(HipBitmapFont.fromFile("assets/fonts/arial.fnt"));
        txt.x = 1280/2;
        txt.alignh = HipTextAlign.CENTER;
    }

    override void render()
    {
        HipRenderer.setColor(0,0,0,255);
        HipRenderer.clear(); 
        string _txt = txt.text;
        string input = KeyboardHandler.getInputText(abnt2);
        _txt~= input;
        txt.setText(_txt);
        txt.render();
        txt.mesh.shader.setFragmentVar("uColor", cast(float[4])[1.0, 1.0, 0.0, 1.0]);
    }
}