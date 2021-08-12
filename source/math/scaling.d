/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

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