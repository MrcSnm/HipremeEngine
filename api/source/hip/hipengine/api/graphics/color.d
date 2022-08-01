/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.hipengine.api.graphics.color;

/**
*   This construct is compatible with float[4] when setting a shader variable.
*/
struct HipColor
{
    union
    {
        struct
        {
            float r =0, g = 0, b = 0, a = 0;
        }
        float[4] values;
    }

    this(float r, float g, float b, float a)
    {
        this.r=r;this.g=g;this.b=b;this.a=a;
    }

    ubyte[4] unpackRGBA()
    {
        return [cast(ubyte)(r*255), cast(ubyte)(g*255), cast(ubyte)(b*255), cast(ubyte)(a*255)];
    }

    static HipColor fromInt(int color)
    {
        return HipColor(
            cast(float)(color >> 24)/255,
            cast(float)((color >> 16) & 255)/255,
            cast(float)((color >> 8) & 255)/255,
            cast(float)(color & 255)/255
        );
    }
    
    static immutable white   = HipColor(1,1,1,1);
    static immutable black   = HipColor(0,0,0,0);
    static immutable red     = HipColor(1,0,0,1);
    static immutable green   = HipColor(0,1,0,1);
    static immutable blue    = HipColor(0,0,1,1);
    static immutable yellow  = HipColor(1,1,0,1);
    static immutable purple  = HipColor(1,0,1,1);
    static immutable teal    = HipColor(0,1,1,1);

    alias values this;
}
