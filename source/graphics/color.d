module graphics.color;

struct Color
{
    ubyte r, g, b, a;

    static Color fromInt(int color, ubyte alpha)
    {
        return Color(
            cast(ubyte)color >> 16,
            cast(ubyte)((color >> 8) & 255),
            cast(ubyte)color & 255,
            alpha);
    }
}
static enum White   = Color(255,255,255,255);
static enum Black   = Color(0,0,0,0);
static enum Red     = Color(255,0,0,255);
static enum Green   = Color(0,255,0,255);
static enum Blue    = Color(0,0,255,255);
static enum Yellow  = Color(255,255,0,255);
static enum Purple  = Color(255,0,255,255);
static enum Teal    = Color(0,255,255,255);