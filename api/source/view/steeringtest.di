// D import file generated from 'source\view\steeringtest.d'
module view.steeringtest;
import hiprenderer.texture;
import graphics.g2d.sprite;
import graphics.g2d.spritebatch;
import ai.steering;
import view;
enum Tests 
{
	Arrive,
	Wander,
	PathFollow,
}
enum TEST = Tests.PathFollow;
class SteeringTest : Scene
{
	HipSpriteBatch b;
	HipSprite main;
	HipSprite target;
	static if (TEST == Tests.Wander)
	{
		float wa = 0;
	}
	static if (TEST == Tests.PathFollow)
	{
		PathFollowerStatus status = PathFollowerStatus([Vector3(200, 0, 0), Vector3(200, 200, 0), Vector3(0, 200, 0), Vector3(0, 0, 0)]);
	}
	this()
	{
		main = new HipSprite("graphics/sprites/sprite.png");
		target = new HipSprite("graphics/sprites/sprite.png");
		target.setPosition(500, 330);
		b = new HipSpriteBatch;
	}
	override void update(float dt);
	override void render();
}
