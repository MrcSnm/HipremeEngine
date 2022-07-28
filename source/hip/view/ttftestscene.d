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

    this()
    {
        // HipAssetManager.getAsset!Hip_TTF_Font("fonts/arial.ttf");
        batch = new HipSpriteBatch();
        abnt2 = new KeyboardLayoutABNT2();
        txt = new HipTextRenderer();

        sprite = new HipSprite();

        sprite.setTexture(HipAssetManager.loadTexture("graphics/sprites/sprite.png"));

        // txt.setFont(HipAssetManager.getAsset!Hip_TTF_Font("fonts/arial.ttf"));

        //fonts/arial.ttf referenced
        //sprites/char.png referenced

        import hip.extensions.file;
        auto fnt = new Hip_TTF_Font("fonts/arial.ttf");

        fnt.load();
        ubyte[] texture = fnt.generateTexture(48);
        fnt.loadTexture;

    }
    //foreach referenced
    //  startLoading(ref)
    //  loadTask
    // if(path.extension == ".png")
    //      asset = new Image(path)
    //  return loadTask(asset, loading)
    //


    override void render()
    {
        // if(HipAssetManager.isLoading)
            // return;
        
        HipRenderer.setColor(0,0,0,255);
        HipRenderer.clear(); 
        txt.addText(300, 100, "Hello World{}??");
        txt.addText(300, 200, "Left", HipTextAlign.LEFT);
        txt.addText(300, 300, "Right", HipTextAlign.RIGHT);
        txt.addText(300, 400, "abcdefghijklmnopqrstuvwxyz");
        txt.addText(300, 500, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
        txt.addText(300, 600, "0123456789");
        txt.addText(300, 700, "1 + 1 - 1 * 1 / 1 = 1");
        txt.setColor(HipColor.green);
        txt.render;

        batch.begin;
        if(sprite.texture)
            batch.draw(sprite);
        batch.end;
    }
}
