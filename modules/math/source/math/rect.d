/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module math.rect;
// import bindbc.sdl;

struct Size
{
    uint w, h;

    alias width = w;
    alias height = h;
}

/**
*   Simple struct for running from SDL_Rect
*/
struct Rect
{
    float x, y, w, h;
    alias width = w;
    alias height = h;
}


bool overlaps(Rect r1, Rect r2)
{
    const float r1x2 = r1.x+r1.w;
    const float r2x2 = r2.x+r2.w;
    const float r1y2 = r1.y+r1.h;
    const float r2y2 = r2.y+r2.h;
    return !(r1x2 < r2.x || r1.x > r2x2 || r1y2 < r2.y || r1.y > r2y2);
}