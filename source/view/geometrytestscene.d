module view.geometrytestscene;
import hiprenderer.renderer;
import hipengine;
import console.log;
import hipengine.api.math.forces;

import math.vector;
import math.quaternion;
import math.matrix;
import view.scene;
import graphics.g2d.renderer2d;
import util.conv;

class GeometryTestScene : Scene
{
    this()
    {
    }

    override void render()
    {
        setGeometryColor(HipColor.white);
        fillRectangle(0, 0, 200, 200);
        endGeometry();

        
    }

    override void update(float dt)
    {
        
    }
}