module hip.view.ttftestscene;

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
    static KeyboardLayout abnt2;
    HipTextRenderer txt;
    HipSpriteBatch batch;
    HipSprite sprite;

    override void initialize()
    {
        // HipAssetManager.getAsset!Hip_TTF_Font("fonts/arial.ttf");
        batch = new HipSpriteBatch();
        abnt2 = new KeyboardLayoutABNT2();
        txt = new HipTextRenderer();
        sprite = new HipSprite();
        sprite.x = 200;
        import hip.extensions.file;
        auto fnt = new Hip_TTF_Font("fonts/arial.ttf", 48);
        fnt.load();
            

        sprite.setTexture(HipAssetManager.loadTexture("graphics/sprites/default.png"));

    }

    override void render()
    {
        if(HipAssetManager.isLoading)
            return;
        
        HipRenderer.clear(HipColor.black); 
        txt.setColor(HipColor.green);
        txt.draw(300, 100, "Hello World{}??");
        txt.draw(300, 200, "Left", HipTextAlign.LEFT);
        txt.draw(300, 300, "Right", HipTextAlign.RIGHT);
        txt.draw(300, 400, "abcdefghijklmnopqrstuvwxyz");
        txt.draw(300, 500, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
        txt.draw(300, 600, "0123456789");
        txt.draw(300, 700, "1 + 1 - 1 * 1 / 1 = 1");
        txt.render;

        if(sprite.texture)
            batch.draw(sprite);
        batch.render;
    }
}
