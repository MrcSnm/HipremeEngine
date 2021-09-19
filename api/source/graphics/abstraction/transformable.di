// D import file generated from 'source\graphics\abstraction\transformable.d'
module graphics.abstraction.transformable;
private import std.math : cos, sin, tan, PI;
enum DEGREE_RATIO = PI / 180;
template Positionable()
{
	int x;
	int y;
	void setPosition(int x, int y)
	{
		this.x = x;
		this.y = y;
	}
}
template Rotationable()
{
	real rotation;
	void setRotationDegrees(real degrees)
	{
		rotation = graphics.abstraction.transformable.DEGREE_RATIO * degrees;
	}
	void setRotation(real radians)
	{
		rotation = radians;
	}
}
template Scalable()
{
	float scaleX;
	float scaleY;
	void setScale(float scaleX, float scaleY = scaleX)
	{
		this.scaleX = scaleX;
		this.scaleY = scaleY;
	}
}
