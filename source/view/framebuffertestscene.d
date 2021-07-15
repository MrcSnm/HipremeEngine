module view.framebuffertestscene;
import view.scene;
import def.debugging.log;
import implementations.renderer.spritebatch;
import implementations.renderer.sprite;
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
        fb.currentShader.setVar("uColor", cast(float[4])[1.0, 1.0, 1.0, 1.0]);
        fb.draw();
    }
}