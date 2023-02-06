module gamescript.piece;
import hip.api;

class Piece
{
    float x, y;
    float scaleX, scaleY;
    int type;
    ubyte gridX, gridY;
    IHipTextureRegion region;

    this(int type, IHipTextureRegion region, float startX, float startY, ubyte gridX, ubyte gridY,
    float scaleX, float scaleY)
    {
        this.type = type;
        this.region = region;
        x = startX;
        y = startY;
        this.scaleX = scaleX;
        this.scaleY = scaleY;
        this.gridX = gridX;
        this.gridY = gridY;
    }

    void swapGridPosition(Piece piece)
    {
        import hip.util.algorithm;
        swap(gridX, piece.gridX);
        swap(gridY, piece.gridY);
    }

    void draw(int xOffset, int yOffset)
    {
        if(region !is null)
            drawRegion(region, cast(int)x+xOffset, cast(int)y+yOffset, 0, HipColor.white, scaleX, scaleY);
    }
}