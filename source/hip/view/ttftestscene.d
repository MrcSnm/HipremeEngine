module hip.view.ttftestscene;

import hip.font.ttf;
import hip.view.scene;
import hip.event.handlers.keyboard_layout;
import hip.hiprenderer;
import hip.graphics.g2d;
import hip.graphics.mesh;
import hip.event.handlers.keyboard;
import hip.console.log;


class TTFTestScene : Scene
{
    static KeyboardLayout abnt2;
    HipTextRenderer txt;

    this()
    {
        abnt2 = new KeyboardLayoutABNT2();
        txt = new HipTextRenderer();
        import hip.extensions.file;
        auto fnt = new Hip_TTF_Font("fonts/arial.ttf");
        fnt.load();
        ubyte[] texture = fnt.generateTexture(32);
        fnt.loadTexture;
        txt.setFont(fnt);
    }

    override void render()
    {
        HipRenderer.setColor(0,0,0,255);
        HipRenderer.clear(); 
        // string _txt = txt.text;
        // string input = KeyboardHandler.getInputText(abnt2);
        // _txt~= input;
        // txt.setText(_txt);
        txt.addText(100, 100, "Hello World");
        txt.addText(200, 200, "Reft Aligned", HipTextAlign.LEFT);
        txt.addText(300, 300, "Right Aligned", HipTextAlign.RIGHT);
        txt.render;
        txt.mesh.shader.setFragmentVar("FragBuf.uColor", cast(float[4])[1.0, 1.0, 0.0, 1.0]);
    }
}
