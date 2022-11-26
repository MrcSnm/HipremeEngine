/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.view.spritetestscene;
version(Test):
import hip.hiprenderer.backend.gl.glrenderer;
import hip.hiprenderer.shader;
import hip.graphics.g2d;
import hip.hiprenderer.renderer;
import hip.view.scene;


class SpriteTestScene : Scene
{
    HipSpriteBatch batch;
    IHipSprite sprite;
    this()
    {
        import hip.console.log;
        batch = new HipSpriteBatch();
        import hip.filesystem.hipfs;
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
        HipRenderer2D.drawSprite(sprite);
        HipRenderer2D.renderSprites();
    }

    public override void onResize(uint width, uint height)
    {
        import hip.console.log;
        Viewport v = HipRenderer.getCurrentViewport();
        v.updateForWindowSize(width, height);
        HipRenderer.setViewport(v);
        rawlog(v.width, " ", v.height);
    }
}