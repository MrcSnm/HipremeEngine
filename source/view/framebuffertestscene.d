/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module view.framebuffertestscene;
import view.scene;
import def.debugging.log;
import graphics.g2d;
import implementations.renderer.renderer;
import implementations.renderer.framebuffer;

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