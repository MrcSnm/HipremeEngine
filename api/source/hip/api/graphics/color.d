/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.api.graphics.color;

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

    uint toInteger()
    {
        uint red = cast(uint)(r*255);
        uint green = cast(uint)(g*255);
        uint blue = cast(uint)(b*255);
        uint alpha = cast(uint)(a*255);
        return (red << 24 +
         green << 16 + 
         blue << 8 + 
         alpha);
    }

    static HipColor fromInt(uint color)
    {
        ubyte[4] c = *cast(ubyte[4]*)&color;

        return HipColor(
            (cast(float)c[0])/255,
            (cast(float)c[1])/255,
            (cast(float)c[2])/255,
            (cast(float)c[3])/255
        );
    }

    auto opAssign(in HipColor color)
    {
        values[] = color.values[];
        return this;
    }
    
    static enum invalid = HipColor(-1, -1, -1, -1);
    static enum white   = HipColor(1,1,1,1);
    static enum black   = HipColor(0,0,0,1);
    static enum red     = HipColor(1,0,0,1);
    static enum green   = HipColor(0,1,0,1);
    static enum blue    = HipColor(0,0,1,1);
    static enum yellow  = HipColor(1,1,0,1);
    static enum purple  = HipColor(1,0,1,1);
    static enum teal    = HipColor(0,1,1,1);
    static enum no      = HipColor(0,0,0,0);

    alias values this;
}
