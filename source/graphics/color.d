/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module graphics.color;

struct HipColor
{
    float r, g, b, a;

    static HipColor fromInt(int color)
    {
        return HipColor(
            cast(float)(color >> 24)/255,
            cast(float)((color >> 16) & 255)/255,
            cast(float)((color >> 8) & 255)/255,
            cast(float)(color & 255)/255
        );
    }

    static enum white   = HipColor(1,1,1,1);
    static enum black   = HipColor(0,0,0,0);
    static enum red     = HipColor(1,0,0,1);
    static enum green   = HipColor(0,1,0,1);
    static enum blue    = HipColor(0,0,1,1);
    static enum yellow  = HipColor(1,1,0,1);
    static enum purple  = HipColor(1,0,1,1);
    static enum teal    = HipColor(0,1,1,1);
}
