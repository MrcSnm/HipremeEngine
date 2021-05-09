module graphics.color;

struct Color
{
    float r, g, b, a;

    static Color fromInt(int color)
    {
        return Color(
            cast(float)color >> 24,
            cast(float)((color >> 16) & 255)/255,
            cast(float)((color >> 8) & 255)/255,
            cast(float)(color & 255)/255
        );
    }
}
static enum White   = Color(1,1,1,1);
static enum Black   = Color(0,0,0,0);
static enum Red     = Color(1,0,0,1);
static enum Green   = Color(0,1,0,1);
static enum Blue    = Color(0,0,1,1);
static enum Yellow  = Color(1,1,0,1);
static enum Purple  = Color(1,0,1,1);
static enum Teal    = Color(0,1,1,1);