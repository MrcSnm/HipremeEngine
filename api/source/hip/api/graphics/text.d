module hip.api.graphics.text;

enum HipTextAlign
{
    CENTER,
    TOP,
    LEFT,
    RIGHT,
    BOTTOM
}

void getPositionFromAlignment(
    int x, int y, int width, int height, HipTextAlign alignh, HipTextAlign alignv, 
    out int newX, out int newY, int boundsWidth, int boundsHeight
)
{
    newX = x;
    newY = y;
    with(HipTextAlign)
    {
        switch(alignh)
        {
            case CENTER:
                if(boundsWidth != -1)
                {
                    newX = (x + (boundsWidth)/2) - (width / 2);
                }
                else
                    newX-= width/2;
                break;
            case RIGHT:
                newX-= width;
                break;
            case LEFT:
            default:
                break;
        }
        switch(alignv)
        {
            case CENTER:
                if(boundsHeight != -1)
                    newY = newY + (boundsHeight/2) - height/4;
                else
                    newY-= height/4;
                break;
            case BOTTOM:
                newY-= height/2;
                break;
            case TOP:
            default:
                break;
        }
    }
}