module graphics.abstraction.transformable;
private import std.math:cos, sin, tan, PI;
enum DEGREE_RATIO = PI/180;

mixin template Positionable()
{
    int x, y;
    void setPosition(int x, int y)
    {
        this.x = x;
        this.y = y;
    }
}



/**
*   Always use rads as it is the PC default
*/
mixin template Rotationable()
{
    real rotation;

    void setRotationDegrees(real degrees)
    {
        rotation = graphics.abstraction.transformable.DEGREE_RATIO*degrees;
    }
    void setRotation(real radians)
    {
        rotation = radians;
    }
}

mixin template Scalable()
{
    float scaleX, scaleY;

    void setScale(float scaleX, float scaleY = scaleX)
    {
        this.scaleX = scaleX;
        this.scaleY = scaleY;
    }
}