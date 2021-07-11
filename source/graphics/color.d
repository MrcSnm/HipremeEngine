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
}
static enum White   = HipColor(1,1,1,1);
static enum Black   = HipColor(0,0,0,0);
static enum Red     = HipColor(1,0,0,1);
static enum Green   = HipColor(0,1,0,1);
static enum Blue    = HipColor(0,0,1,1);
static enum Yellow  = HipColor(1,1,0,1);
static enum Purple  = HipColor(1,0,1,1);
static enum Teal    = HipColor(0,1,1,1);