/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
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
        sp = new HipSprite("D:\\HipremeEngine\\assets\\graphics\\sprites\\sprite.png");
        fb = HipRenderer.newFrameBuffer(800, 600);
    }
    override void render()
    {
        super.render();
        fb.bind();
        batch.begin();
        batch.draw(sp);
        batch.end();
        fb.unbind();
        fb.currentShader.bind();
        fb.currentShader.setFragmentVar("uColor", cast(float[4])[1.0, 1.0, 1.0, 1.0]);
        fb.draw();
    }
}