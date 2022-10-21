/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.graphics.abstraction.transformable;
enum DEGREE_RATIO = 3.14159/180;

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