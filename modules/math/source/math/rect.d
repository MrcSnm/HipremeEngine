/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module math.rect;

version(Have_hipengine_api)
    public import hipengine.api.math.rect;
else
{

    struct Size
    {
        uint w, h;

        alias width = w;
        alias height = h;
    }

    struct Rect
    {
        float x, y, w, h;
        alias width = w;
        alias height = h;
    }


    pure nothrow @nogc @safe
    bool overlaps(Rect r1, Rect r2)
    {
        const float r1x2 = r1.x+r1.w;
        const float r2x2 = r2.x+r2.w;
        const float r1y2 = r1.y+r1.h;
        const float r2y2 = r2.y+r2.h;
        return !(r1x2 < r2.x || r1.x > r2x2 || r1y2 < r2.y || r1.y > r2y2);
    }
}