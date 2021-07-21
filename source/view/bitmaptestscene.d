module view.bitmaptestscene;
import std.stdio;
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
        txt.setBitmapFont(HipBitmapFont.fromFile("assets/fonts/tnroman.fnt"));
        logln(abnt2.getKey('a', KeyboardLayout.KeyState.NONE));
        // logln(txt.getVertices());
    }

    override void render()
    {
        HipRenderer.setColor(0,0,0,255);
        HipRenderer.clear(); 
        string _txt = txt.text;
        string input = KeyboardHandler.getInputText(abnt2);
        writeln(input);
        _txt~= input;
        txt.setText(_txt);
        txt.render();
        txt.mesh.shader.setVar("uColor", cast(float[4])[1.0, 1.0, 0.0, 1.0]);
    }
}