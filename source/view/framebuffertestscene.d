/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module view.framebuffertestscene;
import view.scene;
import console.log;
import graphics.g2d;
import hiprenderer.renderer;
import hiprenderer.framebuffer;

class FrameBufferTestScene : Scene
{
    HipFrameBuffer fb;
    HipSpriteBatch batch;
    HipSprite sp;
    this()
    {
        batch = new HipSpriteBatch();
        sp = new HipSprite("graphics/sprites/sprite.png");
        fb = HipRenderer.newFrameBuffer(800, 600);
    }
    override void render()
    {
        fb.bind();
        batch.begin();
        batch.draw(sp);
        batch.end();
        fb.unbind();

        batch.begin();
        batch.draw(new TextureRegion(fb.getTexture), 0, 0);
        batch.end();
        // fb.currentShader.bind();
        // fb.currentShader.setFragmentVar("uColor", cast(float[4])[1.0, 1.0, 1.0, 1.0]);
        // fb.draw();  
    }
}