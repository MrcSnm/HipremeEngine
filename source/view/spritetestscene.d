/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module view.spritetestscene;
import bindbc.sdl;
import hiprenderer.backend.gl.renderer;
import hiprenderer.shader;
import graphics.g2d;
import hiprenderer.renderer;
import view.scene;


class SpriteTestScene : Scene
{
    HipSpriteBatch batch;
    HipSprite sprite;
    this()
    {
        import console.log;
        batch = new HipSpriteBatch();
        import data.hipfs;
        string output;


        // HipFS.readText("text/renderer.conf", output);
        // rawlog(output);
        sprite = new HipSprite("assets/graphics/sprites/sprite.png");
    }

    public override void render()
    {
        super.render();
        Viewport v = HipRenderer.getCurrentViewport();
        v.setSize(800, 600);
        v.update();
        batch.camera.setScale(2, 2);
        batch.begin();
        batch.draw(sprite);
        batch.end();
    }

    public override void onResize(uint width, uint height)
    {
        import console.log;
        Viewport v = HipRenderer.getCurrentViewport();
        v.update();
        rawlog(v.w, " ", v.h);
    }
}