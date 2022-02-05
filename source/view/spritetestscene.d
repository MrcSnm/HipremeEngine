/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module view.spritetestscene;
import hiprenderer.backend.gl.glrenderer;
import hiprenderer.shader;
import graphics.g2d;
import hiprenderer.renderer;
import view.scene;


class SpriteTestScene : Scene
{
    HipSpriteBatch batch;
    IHipSprite sprite;
    this()
    {
        import console.log;
        batch = new HipSpriteBatch();
        import data.hipfs;
        string output;


        // HipFS.readText("text/renderer.conf", output);
        // rawlog(output);
        // sprite = new HipSprite("graphics/sprites/sprite.png");
        sprite = HipRenderer2D.newSprite("graphics/sprites/sprite.png");
    }

    public override void render()
    {
        super.render();
        // Viewport v = HipRenderer.getCurrentViewport();
        // v.setSize(800, 600);
        // v.update();
        // batch.camera.setScale(2, 2);
        // batch.begin();
        // batch.draw(sprite);
        // batch.end();
        HipRenderer2D.beginSprite();
        HipRenderer2D.drawSprite(sprite);
        HipRenderer2D.endSprite();
    }

    public override void onResize(uint width, uint height)
    {
        import console.log;
        Viewport v = HipRenderer.getCurrentViewport();
        v.update();
        rawlog(v.w, " ", v.h);
    }
}