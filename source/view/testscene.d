/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module view.testscene;

import graphics.g2d.geometrybatch;
import implementations.renderer.shader;
import implementations.renderer;
import graphics.g2d.viewport;
import graphics.color;
import view.scene;

class TestScene : Scene
{
    GeometryBatch geom;
    Shader shader;
    override void init()
    {
        geom = new GeometryBatch(5000, 5000);
        geom.setColor(HipColor(0, 1, 0, 1));
        HipRenderer.setViewport(new Viewport(0,0, 800, 600));
    }

    override void render()
    {
        super.render();
        // geom.setColor(Color(1, 1, 1, 1));
        // geom.drawRectangle(0, 0, 200, 200);
        // geom.setColor(HipColor(0, 1, 0, 1));
        // geom.drawRectangle(0, 0, 200, 200);
        geom.setColor(HipColor(1, 1, 0, 1));
        geom.drawLine(0, 0, 200, 200);
        // geom.drawRectangle(800/2, 600/2, 800/2, 600/2);
        geom.flush();
        
    }
}