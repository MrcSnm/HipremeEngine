module gamescript.text;
import hip.api;

class Text
{
    float x, y;
    string text;
    HipColor color = HipColor.white;
    IHipFont font;

    int boundsWidth, boundsHeight;

    HipTextAlign hAlign = HipTextAlign.CENTER;
    HipTextAlign vAlign = HipTextAlign.BOTTOM;

    this(string text, float x, float y, IHipFont font = null, int boundsWidth = -1, int boundsHeight = -1)
    {
        this.text = text;
        this.x = x;
        this.y = y;
        this.font = font;
        this.boundsWidth = boundsWidth;
        this.boundsHeight = boundsHeight;
    }

    void setAlign(HipTextAlign hAlign, HipTextAlign vAlign)
    {
        this.hAlign = hAlign;
        this.vAlign = vAlign;
    }

    void setText(Args...)(string text, Args args)
    {
        import hip.util.conv;
        foreach(arg; args)
            text~= arg.to!string;
        this.text = text;
    }

    void draw()
    {
        if(font !is null)
        {
            // setFont(font);
            drawText(text, cast(int)x, cast(int)y, color, hAlign, vAlign, boundsWidth, boundsHeight);
            // setFont(null);
        }
        else
            drawText(text, cast(int)x, cast(int)y, color, hAlign, vAlign, boundsWidth, boundsHeight);
    }
}