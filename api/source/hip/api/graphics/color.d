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

///This struct is ubyte[4] or uint depending on your usages
struct HipColor
{
    @"format" string toString() @nogc const {return "Color($r, $g, $b, $a)"; }
    union 
    {
        struct {ubyte r, g, b, a;}
        ubyte[4] values;
        uint value;
    }
    this(ubyte r, ubyte g, ubyte b){values = [r,g,b,255];}
    this(ubyte r, ubyte g, ubyte b, ubyte a){values = [r,g,b,a];}
    this(float r, float g, float b, float a){values = [cast(ubyte)(r*255),cast(ubyte)(g*255),cast(ubyte)(b*255),cast(ubyte)(a*255)];}
    this(ubyte[4] rgba){values = rgba;}
    this(uint rgba){values = unpackRGBA(rgba);}


    static HipColor alpha(ubyte alpha){return HipColor(255, 255, 255, alpha);}
    static HipColor alpha(float alpha){return HipColor(255, 255, 255, cast(ubyte)(alpha*255));}
    static enum white   = HipColor(0xffffffff);
    static enum black   = HipColor(0x000000ff);
    static enum red     = HipColor(0xff0000ff);
    static enum green   = HipColor(0x00ff00ff);
    static enum blue    = HipColor(0x0000ffff);
    static enum yellow  = HipColor(0xffff00ff);
    static enum purple  = HipColor(0xff00ffff);
    static enum teal    = HipColor(0x00ffffff);
    static enum no      = HipColor(0x00000000);

    alias values this;

    HipColor lerp(HipColor to, float t) const
    {
        float fromT = 1.0 - t;

        ushort nR = cast(ushort)(fromT*r + t*to.r);
        ushort nG = cast(ushort)(fromT*g + t*to.g);
        ushort nB = cast(ushort)(fromT*b + t*to.b);
        ushort nA = cast(ushort)(fromT*a + t*to.a);

        return HipColor(
            cast(ubyte)(nR > 255 ? 255 : nR),
            cast(ubyte)(nG > 255 ? 255 : nG),
            cast(ubyte)(nB > 255 ? 255 : nB),
            cast(ubyte)(nA > 255 ? 255 : nA),
        );
    }

}


/** 
 *  A struct containing a HipColor and a T which describes what color is in this T.
 *  This is useful for doing color interpolation and gradients.
 */
struct HipColorStop
{
    HipColor color;
    float t = 0;
}

/** 
 * 
 * Params:
 *   colorStops = A sorted array of color stops.
 *   t = What is the current T. Ranging from 0 to 1
 * Returns: The lerped color in the stop.
 */
HipColor gradientColor(const scope ref HipColorStop[] colorStops, float t)
{
    if(colorStops.length == 0) return HipColor.no;
    if(t >= 1) return colorStops[$-1].color;
    for(uint i = 1 ; i < colorStops.length; i++)
    {
        if(t > colorStops[i].t) continue;
        float currLerpT = t / (colorStops[i].t - colorStops[i-1].t);
        return colorStops[i-1].color.lerp(colorStops[i].color, currLerpT);
    }
    return colorStops[$-1].color;
}

/**
*   This construct is compatible with float[4] when setting a shader variable.
*/
struct HipColorf
{
    union
    {
        struct
        {
            float r =0, g = 0, b = 0, a = 0;
        }
        float[4] values;
    }
    this(HipColor c){values = [cast(float)c.r / 255, cast(float)c.g/255, cast(float)c.b/255, cast(float)c.a/255];}
    this(float r, float g, float b, float a){values = [r,g,b,a];}
    ubyte[4] unpackRGBA()
    {
        return [cast(ubyte)(r*255), cast(ubyte)(g*255), cast(ubyte)(b*255), cast(ubyte)(a*255)];
    }

    uint toInteger()
    {
        ubyte red = cast(ubyte)(r*255);
        ubyte green = cast(ubyte)(g*255);
        ubyte blue = cast(ubyte)(b*255);
        ubyte alpha = cast(ubyte)(a*255);
        return packRGBA(red,green,blue,alpha);
    }

    static HipColorf fromInt(uint color)
    {
        ubyte[4] c = hip.api.graphics.color.unpackRGBA(color);

        return HipColorf(
            (cast(float)c[0])/255,
            (cast(float)c[1])/255,
            (cast(float)c[2])/255,
            (cast(float)c[3])/255
        );
    }

    auto opAssign(in HipColorf color)
    {
        values[] = color.values[];
        return this;
    }
    
    static enum invalid = HipColorf(-1, -1, -1, -1);
    static enum white   = HipColorf(1,1,1,1);
    static enum black   = HipColorf(0,0,0,1);
    static enum red     = HipColorf(1,0,0,1);
    static enum green   = HipColorf(0,1,0,1);
    static enum blue    = HipColorf(0,0,1,1);
    static enum yellow  = HipColorf(1,1,0,1);
    static enum purple  = HipColorf(1,0,1,1);
    static enum teal    = HipColorf(0,1,1,1);
    static enum no      = HipColorf(0,0,0,0);

    alias values this;
}

uint packRGBA(ubyte r, ubyte g, ubyte b, ubyte a)
{
    return ((r << 24) + (g << 16) + (b << 8) + a);
}

ubyte[4] unpackRGBA(uint rgba)
{
    return
    [
        rgba >> 24,
        (rgba >> 16) & 255,
        (rgba >> 8) & 255,
        rgba & 255
    ];
}

pragma(inline, true)
{
    HipColorf color(float[4] c){ return HipColorf(c[0], c[1], c[2], c[3]); }
    HipColorf color(float r, float g, float b, float a = 1.0){ return HipColorf(r,g,b,a); }

    HipColor color(ubyte r, ubyte g, ubyte b, ubyte a = 255){return HipColor(r,g,b,a);}
    HipColor color(uint c)
    {
        ubyte[4] rgba = unpackRGBA(c);
        return HipColor(rgba[0], rgba[1], rgba[2], rgba[3]);
    }
}