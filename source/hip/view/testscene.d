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
import hip.api.graphics.color;
import hip.view.scene;
import hip.math.utils;

class TestScene : Scene
{
    //Lower Level API. Not available in the Scripting API
    GeometryBatch geom;
    Shader shader;


    override void initialize()
    {
        geom = new GeometryBatch(null, 5000, 5000);
        geom.setColor(HipColor(0, 1, 0, 1));
        HipRenderer.setViewport(new Viewport(0,0, 800, 600));
    }
    override void update(float dt)
    {
        super.update(dt);
        import hip.api;
        if(HipInput.isMouseButtonJustPressed(HipMouseButton.left))
        {
            logg("You just clicked me!");
        }

        if(HipInput.isKeyJustPressed(HipKey.ENTER))
        {
            logg("Don't press ENTER!");
        }
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


        ////////////////////////Higher Level////////////////////////
        import hip.api;
        setGeometryColor(HipColor.white);
        drawText("Hello World Test Scene (Default Font)", 300, 280, HipColor.white, HipTextAlign.LEFT, HipTextAlign.TOP);
        fillRectangle(300, 300, 100, 100);

        drawText("Null Textures uses that sprite over here", 300, 480, HipColor.white, HipTextAlign.LEFT, HipTextAlign.TOP);
        drawTexture(null, 300, 500);

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