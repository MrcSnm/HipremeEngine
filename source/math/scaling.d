module math.scaling;
import std.algorithm:min;
import math.vector;

class Scaling
{
    private static Vector2 temp;
    static Vector2 fit(float width, float height, float targetWidth, float targetHeight)
    {
        float ratio = height/width;
        float targetRatio = targetHeight/targetWidth;

        //Scale must be the greatest side scaled to its target
        float scale = (ratio > targetRatio) ? targetHeight/height : targetWidth/width;
        temp.x = width*scale;
        temp.y = height*scale;
        return temp;
    }
}