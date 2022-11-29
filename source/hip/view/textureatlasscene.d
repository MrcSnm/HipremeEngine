/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.view.textureatlasscene;
version(Test):
import hip.hiprenderer;
import hip.assets.textureatlas;
import hip.graphics.g2d.spritebatch;
import hip.graphics.g2d.animation;
import hip.view;

class TextureAtlasScene : Scene
{
    HipTextureAtlas atlas;
    HipAnimation emerald;
    HipSpriteBatch batch;
    this()
    {
        atlas = HipTextureAtlas.readJSON("graphics/atlases/UI.json");
        batch = new HipSpriteBatch();
        emerald = HipAnimation.fromAtlas(atlas, "emerald", 12, true);
    }
    override void update(float dt)
    {
        emerald.update(dt);
    }

    override void render()
    {
        batch.camera.setScale(4,4);
        batch.draw(emerald.getCurrentFrame().region, 0, 0);
        batch.render();
    }
}