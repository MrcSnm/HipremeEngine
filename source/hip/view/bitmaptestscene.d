/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.view.bitmaptestscene;
import hip.graphics.g2d.tilemap;
import hip.event.handlers.keyboard_layout;
import hip.hiprenderer;
import hip.graphics.g2d;
import hip.graphics.mesh;
import hip.event.handlers.keyboard;
import hip.console.log;
import hip.view.scene;


class BitmapTestScene : Scene
{
    HipBitmapText txt;
    static KeyboardLayout abnt2;
    this()
    {
        txt = new HipBitmapText();
        abnt2 = new KeyboardLayoutABNT2();
        txt.setBitmapFont(HipBitmapFont.fromFile("assets/fonts/arial.fnt"));
        txt.x = HipRenderer.width/2;
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
        txt.mesh.shader.setFragmentVar("FragBuf.uColor", cast(float[4])[1.0, 1.0, 0.0, 1.0]);
    }
}