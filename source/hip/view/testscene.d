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

import hip.graphics.g2d.geometrybatch;
import hip.hiprenderer.shader;
import hip.hiprenderer;
import hip.hiprenderer.viewport;
import hip.api.graphics.color;
import hip.view.scene;
import hip.math.utils;

class TestScene : Scene
{
    GeometryBatch geom;
    Shader shader;
    float a;
    override void initialize()
    {
        geom = new GeometryBatch(null, 5000, 5000);
        a = 0;
        geom.setColor(HipColor(0, 1, 0, 1));
        HipRenderer.setViewport(new Viewport(0,0, 800, 600));
    }
    override void update(float dt)
    {
        super.update(dt);
    }

    override void render()
    {
        super.render();

        // geom.drawRectangle(0, 0, 200, 200);
        // geom.setColor(HipColor(0, 1, 0, 1));
        geom.setColor(HipColor(1, 1, 0, 1));
        geom.drawLine(0, 0, abs(cast(int)(cos(a)*200)), abs(cast(int)(sin(a)*200)));
        // geom.drawRectangle(0, 0, 800, 800);
        // geom.drawRectangle(800/2, 600/2, 800/2, 600/2);
        geom.flush();
        
    }
}