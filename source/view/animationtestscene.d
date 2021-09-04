module view.animationtestscene;
import view.scene;
import hiprenderer.viewport;
import hiprenderer.renderer;
import util.tween;
import graphics.g2d.animation;
import graphics.g2d.sprite;
import graphics.g2d.spritebatch;

class AnimationTestScene : Scene
{
    HipAnimation anim;
    HipSpriteBatch batch;
    HipSpriteAnimation spr;
    HipAnimationFrame frame;

    HipTween tween;
    this()
    {
        batch = new HipSpriteBatch();
        anim = new HipAnimation("Character");
        Texture t = new Texture("graphics/sprites/sprite.png");
        Array2D!TextureRegion sheet = TextureRegion.spritesheet(t, 32, 32);
        anim.addTrack(new HipAnimationTrack("Walk", 12, false)
        .addFrames(HipAnimationFrame(new TextureRegion("graphics/sprites/sprite.png"))));

        spr = new HipSpriteAnimation(anim);

        frame = HipAnimationFrame(sheet[2,0]);
        spr.setFrame(&frame);

        tween = HipTween.by!(["x"])(2, spr, 700).play().setEasing(HipEasing.easeInQuad);
        import console.log;
        rawlog(spr.x);
    }

    override void update(float dt)
    {
        // spr.update(0.01);
        tween.tick(0.01);
        // import console.log;
        // rawlog(tween.getProgress());
    }

    override void render()
    {
        super.render();
        // Viewport v = HipRenderer.getCurrentViewport();
        // v.setSize(800, 600);
        // v.update();
        // batch.camera.setScale(2, 2);
        batch.begin();
        batch.draw(spr);
        batch.end();
    }
}