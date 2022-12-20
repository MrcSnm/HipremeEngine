module hip.view.ttftestscene;
version(Test):

import hip.font.ttf;
import hip.view.scene;
import hip.event.handlers.keyboard_layout;
import hip.hiprenderer;
import hip.graphics.g2d;
import hip.graphics.mesh;
import hip.event.handlers.keyboard;
import hip.console.log;

import hip.assetmanager;


class TTFTestScene : Scene
{
    HipTextRenderer txt;
    HipSpriteBatch batch;
    HipSprite sprite;

    override void initialize()
    {
        batch = new HipSpriteBatch();
        txt = new HipTextRenderer(null);
        sprite = new HipSprite();
        sprite.x = 200;
        txt.setFont(HipAssetManager.loadFont("fonts/consolas.fnt", 48));
        sprite.setTexture(HipAssetManager.loadTexture("graphics/sprites/default.png"));

    }

    override void render()
    {
        if(HipAssetManager.isLoading)
            return;
        
        HipRenderer.clear(HipColor.black); 
        txt.setColor(HipColor.green);
        txt.draw("Hello World{}??", 300, 100);
        txt.draw("Left", 300, 200, HipTextAlign.LEFT);
        txt.draw("Right",300, 300,  HipTextAlign.RIGHT);
        // txt.draw("abcdefghijklmnopqrstuvwxyz", 300, 400);
        // txt.draw("ABCDEFGHIJKLMNOPQRSTUVWXYZ", 300, 500);
        // txt.draw("0123456789", 300, 600);
        // txt.draw("1 + 1 - 1 * 1 / 1 = 1", 300, 700);
        txt.render;

        if(sprite.texture)
            batch.draw(sprite);
        batch.render;
    }
}
