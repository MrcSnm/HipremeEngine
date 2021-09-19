// D import file generated from 'source\view\pathfindingtest.d'
module view.pathfindingtest;
import ai.pathfinding;
import hiprenderer;
import graphics.g2d.geometrybatch;
import view;
ubyte[] map = [1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1];
uint rectSize = 64;
class PathFindingTest : Scene
{
	GeometryBatch batch;
	AStarResult!ubyte ret;
	this()
	{
		batch = new GeometryBatch;
		ret = AStar2D_4Way(map, 1, 1, 8, 6, 5, 1);
	}
	override void update(float dt);
	override void render();
}
