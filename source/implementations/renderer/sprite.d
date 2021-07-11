module implementations.renderer.sprite;
import implementations.renderer.spritebatch;
import implementations.renderer.texture;
import graphics.color;



class HipSprite
{
    TextureRegion texture;
    HipColor color;
    float x, y;
    float scaleX, scaleY;
    float scrollX, scrollY;
    float rotation;
    uint width, height;

    protected bool isDirty;

    static assert(cast(ulong)(HipSpriteVertex.sizeof/float.sizeof) == 9,  "SpriteVertex should contain 9 floats");
    protected float[cast(ulong)(HipSpriteVertex.sizeof/float.sizeof * 4)] vertices;


    this(string texturePath)
    {
        this.texture = new TextureRegion(texturePath);
        this.scaleX = 1f;
        this.scaleY = 1f;
    }


    void setPosition(float x, float y)
    {
        this.x = x;
        this.y = y;

        if(isDirty)return;

        if(rotation != 0 || scaleX != 1 || scaleY != 1)
        {
            isDirty = true;
            return;
        }

        float x2 = x+width;
        float y2 = y+height;

        //Top left
        vertices[X1] = x;
        vertices[Y1] = y;

        //Top right
        vertices[X2] = x2;
        vertices[Y2] = y1;

        //Bot right
        vertices[X3] = x2;
        vertices[Y3] = y2;

        //Bot left
        vertices[X4] = x1;
        vertices[Y4] = y2;
    }

    ref float[vertices.length] getVertices()
    {

        if(isDirty)
        {
            float x2 = x+width*scaleX;
            float y2 = y+height*scaleY;

            //Top left
            vertices[X1] = x;
            vertices[Y1] = y;

            //Top right
            vertices[X2] = x2;
            vertices[Y2] = y1;

            //Bot right
            vertices[X3] = x2;
            vertices[Y3] = y2;

            //Bot left
            vertices[X4] = x1;
            vertices[Y4] = y2;
        }

        return vertices;
    }

    pure void setColor()(auto ref HipColor color)
    {
        this.color = color;
        vertices[R1] = color.r;
        vertices[G1] = color.g;
        vertices[B1] = color.b;
        vertices[A1] = color.a;

        vertices[R2] = color.r;
        vertices[G2] = color.g;
        vertices[B2] = color.b;
        vertices[A2] = color.a;

        vertices[R3] = color.r;
        vertices[G3] = color.g;
        vertices[B3] = color.b;
        vertices[A3] = color.a;

        vertices[R4] = color.r;
        vertices[G4] = color.g;
        vertices[B4] = color.b;
        vertices[A4] = color.a;
    }

    void setScale(float scaleX, float scaleY)
    {
        this.scaleX = scaleX;
        this.scaleY = scaleY;
        isDirty = true;
    }
    void setRotation(float rotation)
    {
        this.rotation = rotation;
        isDirty = true;
    }

    void setScroll(float x, float y)
    {
        scrollX = x;
        scrollY = y;
    }

}