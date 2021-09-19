// D import file generated from 'source\view\testscene.d'
module view.testscene;
import graphics.g2d.geometrybatch;
import hiprenderer.shader;
import hiprenderer;
import hiprenderer.viewport;
import graphics.color;
import std.math;
import view.scene;
class TestScene : Scene
{
	GeometryBatch geom;
	Shader shader;
	float a;
	override void init();
	override void update(float dt);
	override void render();
}
