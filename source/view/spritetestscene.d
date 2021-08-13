/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module view.spritetestscene;
import bindbc.sdl;
import bindbc.opengl;
import implementations.renderer.shader;
import graphics.g2d;
import implementations.renderer.renderer;
import view.scene;


class SpriteTestScene : Scene
{
    HipSpriteBatch batch;
    HipSprite sprite;
    this()
    {
        batch = new HipSpriteBatch();
        sprite = new HipSprite("sprite.png");
        import def.debugging.log;
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
        import def.debugging.log;
        Viewport v = HipRenderer.getCurrentViewport();
        v.update();
        rawlog(v.w, " ", v.h);
    }
}