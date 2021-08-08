module view.testscene;

import graphics.g2d.geometrybatch;
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
        geom = new GeometryBatch(5000, 5000, shader);
        // geom.setColor(Color(0, 1, 0, 1));
    }

    override void render()
    {
        super.render();
        // geom.setColor(Color(1, 1, 1, 1));
        // geom.drawRectangle(0, 0, 200, 200);
        geom.setColor(HipColor(0, 1, 0, 1));
        geom.drawRectangle(200, 200, 200, 200);

        // geom.drawRectangle(300, 300, 200, 200);
        geom.flush();
    }
}