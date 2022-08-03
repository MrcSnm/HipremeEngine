module hip.view.geometrytestscene;
import hip.hiprenderer.renderer;
import hip.api;
import hip.console.log;
import hip.api.math.forces;

import hip.math.vector;
import hip.math.quaternion;
import hip.math.matrix;
import hip.view.scene;
import hip.graphics.g2d.renderer2d;
import hip.util.conv;

class GeometryTestScene : Scene
{
    this()
    {
    }

    override void render()
    {
        setGeometryColor(HipColor.white);
        fillRectangle(0, 0, 200, 200);
        renderGeometries();

        
    }

    override void update(float dt)
    {
        
    }
}