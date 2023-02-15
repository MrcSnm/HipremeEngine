/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.view.testscene;
version(Test):

import hip.graphics.g2d.geometrybatch;
import hip.hiprenderer.shader;
import hip.hiprenderer;
import hip.hiprenderer.viewport;
import hip.view.scene;
import hip.math.utils;

class TestScene : Scene, IHipPreloadable
{
    import hip.api;

    mixin Preload;

    //Lower Level API. Not available in the Scripting API
    GeometryBatch geom;
    Shader shader;

    IHipFont smallFont;
    IHipFont bigFont;


    override void initialize()
    {
        geom = new GeometryBatch(null, 5000, 5000);
        geom.setColor(HipColor(0, 1, 0, 1));
        HipRenderer.setViewport(new Viewport(0,0, 800, 600));

        // smallFont = HipDefaultAssets.getDefaultFontWithSize(20);
        // bigFont = HipDefaultAssets.getDefaultFontWithSize(64);
    }
    override void update(float dt)
    {
        super.update(dt);
        if(HipInput.areGamepadButtonsJustPressed([HipGamepadButton.psSquare, HipGamepadButton.psTriangle]))
            logg("Button combination pressed!");
        // {
            // logg("You just done a gamepad input combination!");
        // }
        // if(HipInput.isMouseButtonJustPressed(HipMouseButton.left))
        // {
        //     logg("You just clicked me!");
        // }

        // if(HipInput.isKeyJustPressed(HipKey.ENTER))
        // {
        //     logg("Don't press ENTER!");
        // }
    }

    override void render()
    {
        ////////////////////////Lower Level////////////////////////
        super.render();
        geom.setColor(HipColor.red);
        geom.fillRectangle(0, 0, 200, 200);
        geom.setColor(HipColor.green);
        geom.fillRectangle(0, 0, 100, 100);
        geom.flush();


        // //Use a non GC allocating string on render (String) for drawing the mousePosition
        // import hip.util.string;
        // float[2] mousePos = HipInput.getWorldMousePosition();
        // setFont(smallFont);
        // String s = String(mousePos);
        // drawText(s.toString, cast(int)mousePos[0], cast(int)mousePos[1]);

        

        ////////////////////////Higher Level////////////////////////
        setGeometryColor(HipColor.white);
        // setFont(null);
        // drawText("Hello World Test Scene (Default Font)", 300, 280, HipColor.white, HipTextAlign.LEFT, HipTextAlign.TOP);
        fillRectangle(300, 300, 100, 100);

        drawText("Null Textures uses that sprite over here", 300, 480, HipColor.white, HipTextAlign.LEFT, HipTextAlign.TOP);
        drawTexture(null, 300, 500);

        // logg("Render testscene.");

        /**
        *   For loading a texture you can execute
        *   IHipTexture myTexture = HipAssetManager.loadTexture("sprites/theTexture.png").awaitAs!IHipTexture;
        *
        *   TODO: Tutorial to play sounds
        */
        renderGeometries();
        renderTexts();
        renderSprites();
        
    }
}