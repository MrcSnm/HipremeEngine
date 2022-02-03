/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module math.scaling;
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