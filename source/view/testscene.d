module view.testscene;

import implementations.renderer.geometrybatch;
import implementations.renderer.shader;
import implementations.renderer.renderer;
import graphics.color;
import view.scene;

class TestScene : Scene
{
    GeometryBatch geom;
    Shader shader;
    override void init()
    {
        shader = HipRenderer.newShader(HipShaderPresets.GEOMETRY_BATCH);
        geom = new GeometryBatch(4, 24, shader);
        // geom.setColor(Color(0, 1, 0, 1));
    }

    override void render()
    {
        super.render();
        geom.drawRectangle(0, 0, 200, 200);
        // geom.drawRectangle(300, 300, 200, 200);
        geom.flush();
    }
}