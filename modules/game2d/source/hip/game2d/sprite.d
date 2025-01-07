
/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.game2d.sprite;
public import hip.api.renderer.texture;
public import hip.api.graphics.color;
public import hip.api.data.commons;
import hip.math.vector;
import hip.game2d.renderer_data;
import hip.api.data.textureatlas;

/**
*   Encapsulates bunch of sprites to hold a contiguous list of vertices.
*   It has some advantages than creating manually an array of similar sprites such as:
*   - Copies only once to the SpriteBatch, which searches for the texture index once. 
*   - Boundary checks once
*   - Makes the sprites array vertices linear, reducing cache misses.
*   - Wraps the setTexture and draw process so no need to manually execute the foreach
*/
class HipMultiSprite
{
    protected HipSpriteVertex[] vertices;
    HipSprite[] sprites;
    IHipTexture texture;
    this(size_t spritesCount)
    {
        vertices = new HipSpriteVertex[4*spritesCount];
        sprites = new HipSprite[spritesCount];
        foreach(i; 0..spritesCount)
            sprites[i] = new HipSprite(vertices[i*4..(i+1)*4]);
    }

    ref HipSprite opIndex(size_t index){return sprites[index];}

    int opApply(scope int delegate(ref HipSprite) dg)
    {
        int result = 0;
        foreach (item; sprites)
        {
            result = dg(item);
            if (result)
                break;
        }
        return result;
    }

    
    int opApply(scope int delegate(size_t index, ref HipSprite) dg)
    {
        int result = 0;
        foreach (i, item; sprites)
        {
            result = dg(i, item);
            if (result)
                break;
        }
        return result;
    }


    void setTexture(IHipTexture texture)
    {
        this.texture = texture;
        foreach(sp; sprites)
            sp.setTexture(texture);
    }

    ref HipSpriteVertex[] getVertices()
    {
        //Vertices is already a data sink for the sprites, so no need to reassign.
        foreach(i, sp; sprites)
            sp.getVertices;
        return vertices;
    }

    void draw()
    {
        import hip.api.graphics.g2d.renderer2d;
        foreach(sp; sprites)
            sp.isDirty = true;
        drawSprite(texture, cast(ubyte[])getVertices());
    }
}

class HipSprite 
{
    IHipTextureRegion texture;
    HipColor color = HipColor.white;
    float x = 0, y = 0;
    float scrollX = 0, scrollY = 0;
    float rotation = 0;
    //Tiling == 1 for consistency, 0 the image would disappear
    float tilingX = 1, tilingY = 1;
    float scaleX = 1, scaleY = 1;

    float u1 = 0, v1 = 0, u2 = 0, v2 = 0;

    ///Width of the texture region, (u2-u1) * texture.width
    uint width;
    ///Height of the texture region, (v2-v1) * texture.height
    uint height;

    private bool flippedX, flippedY;

    protected bool isDirty = true;
    protected HipSpriteVertex[] vertices;

    package this(HipSpriteVertex[] sink)
    {
        this.vertices = sink;
        setColor(HipColor.white);
    }

    this()
    {
        import hip.api;
        vertices = new HipSpriteVertex[4];
        setColor(HipColor.white);
        setTexture(cast()HipDefaultAssets.getDefaultTexture());
    }
    this(IHipAssetLoadTask task)
    {
        this();
        setTexture(task);
    }

    /**
    *   Synchronous texture loading based on a string.
    */
    this(string texturePath)
    {
        import hip.api;
        this(HipAssetManager.createTextureRegion(HipAssetManager.loadTexture(texturePath).awaitAs!IHipTexture));
    }

    this(IHipTexture texture)
    {
        vertices = new HipSpriteVertex[4];
        setTexture(texture);
    }
    this(IHipTextureRegion region)
    {
        vertices = new HipSpriteVertex[4];
        this.texture = region;
        width  = region.getWidth();
        height = region.getHeight();
        setRegion(region.getRegion());
    }

    void setTexture(IHipTexture texture)
    {
        import hip.api;
        this.texture = HipAssetManager.createTextureRegion(texture);
        width  = texture.getWidth;
        height = texture.getHeight;
        setRegion(this.texture.getRegion());
    }
    void setTexture(IHipAssetLoadTask task)
    {
        import hip.api;
        HipAssetManager.addOnCompleteHandler(task, (asset)
        {
            this.setTexture(cast(IHipTexture)asset);
        });
    }

    final IHipTexture getTexture() { return texture.getTexture();}

    final void setRegion(float u1, float v1, float u2, float v2)
    {
        setRegion(TextureCoordinatesQuad(u1,v1,u2,v2));
    }
    void setRegion(IHipTextureRegion region)
    {
        width = region.getWidth();
        height = region.getHeight();
        texture = region;
        setRegion(region.getRegion());
    }
    void setRegion(TextureCoordinatesQuad c)
    {
        this.u1 = c.u1;
        this.u2 = c.u2;
        this.v1 = c.v1;
        this.v2 = c.v2;
        texture.setRegion(c.u1, c.v1, c.u2, c.v2);
        const float[] v = texture.getVertices();

        vertices[0].vTexST = Vector2(v[0], v[1]);
        vertices[1].vTexST = Vector2(v[2], v[3]);
        vertices[2].vTexST = Vector2(v[4], v[5]);
        vertices[3].vTexST = Vector2(v[6], v[7]);
        if(flippedX)
        {
            flippedX = false;
            setFlippedX(true);
        }
        if(flippedY)
        {
            flippedY = false;
            setFlippedY(true);
        }
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
        vertices[0].vPosition = Vector3(x, y,0);

        //Top right
        vertices[1].vPosition = Vector3(x2, y,0);

        //Bot right
        vertices[2].vPosition = Vector3(x2, y2,0);

        //Bot left
        vertices[3].vPosition = Vector3(x, y2,0);
    }

    ref HipSpriteVertex[] getVertices()
    {
        if(isDirty)
        {
            isDirty = false;
            float _x = -cast(float)width/2 * scaleX;
            float _y = -cast(float)height/2 * scaleY;
            float x2 = _x+(width * scaleX);
            float y2 = _y+(height * scaleY); 
            if(rotation == 0)
            {
                //Top left
                vertices[0].vPosition = Vector3(_x+x, _y+y,0);

                //Top right
                vertices[1].vPosition = Vector3(x2+x, _y+y,0);

                //Bot right
                vertices[2].vPosition = Vector3(x2+x, y2+y,0);

                //Bot left
                vertices[3].vPosition = Vector3(_x+x, y2+y,0);
            }
            else
            {
                import core.math:sin,cos;
                float c = cos(rotation);
                float s = sin(rotation);

                //Top left
                vertices[0].vPosition = Vector3(c*_x - s*_y + this.x, c*_y + s*_x + this.y,0);

                //Top right
                vertices[1].vPosition = Vector3(c*x2 - s*_y + this.x, c*_y + s*x2 + this.y,0);

                //Bot right
                vertices[2].vPosition = Vector3(c*x2 - s*y2 + this.x, c*y2 + s*x2 + this.y,0);

                //Bot left
                vertices[3].vPosition = Vector3(c*_x - s*y2 + this.x, c*y2 + s*_x + this.y,0);
            }
        }
        return vertices;
    }

    void setColor(HipColor color)
    {
        this.color = color;
        vertices[0].vColor = color;
        vertices[1].vColor = color;
        vertices[2].vColor = color;
        vertices[3].vColor = color;
    }

    void setScale(float scaleX, float scaleY)
    {
        this.scaleX = scaleX;
        this.scaleY = scaleY;
        isDirty = true;
    }
    void setRotation(float rotation)
    {
        import hip.math.utils;
        this.rotation = rotation % (PI * 2);
        isDirty = true;
    }
    ///Same thing as setRotation, but receives in Degrees
    void setAngle(float angle)
    {
        import hip.math.utils:degToRad;
        setRotation(degToRad(angle));
    }

    int getWidth() const {return width;}
    int getHeight() const {return height;}
    int getTextureWidth() const {return texture.getTextureWidth();}
    int getTextureHeight() const {return texture.getTextureHeight();}

    /**
    * This function is most useful for single images. For instance backgrounds, probably, if you have a
    * texture atlas or a spritesheet, this function is not useful
    */
    void setScroll(float x, float y)
    {
        setRegion(
            -scrollX + x + u1,
            -scrollY + y + v1,
            -scrollX + x + u2,
            -scrollY + y + v2
        );
        scrollX = x;
        scrollY = y;
    }

    void setFlippedX(bool flip)
    {
        if(flip != flippedX)
        {
            auto reg = texture.getRegion;
            flippedX = flip;
            vertices[0].vTexST.x = flip ? reg.u2 : reg.u1;
            vertices[1].vTexST.x = flip ? reg.u1 : reg.u2;
            vertices[2].vTexST.x = flip ? reg.u1 : reg.u2;
            vertices[3].vTexST.x = flip ? reg.u2 : reg.u1;
        }
    }
    void setFlippedY(bool flip)
    {
        if(flip != flippedY)
        {
            auto reg = texture.getRegion;
            flippedY = flip;
            vertices[0].vTexST.y = flip ? reg.v2 : reg.v1;
            vertices[1].vTexST.y = flip ? reg.v2 : reg.v1;
            vertices[2].vTexST.y = flip ? reg.v1 : reg.v2;
            vertices[3].vTexST.y = flip ? reg.v1 : reg.v2;
        }
    }
    bool isFlippedX() => flippedX;
    bool isFlippedY() => flippedY;


    /**
    *   Sets the tiling factor for this sprite. Default is 1.
    */
    void setTiling(float x = 1, float y = 1)
    {
        assert(x != 0 && y != 0, "Tiling factor equals 0 will disappear the sprite image");

        setRegion(
            u1 / tilingX * x,
            v1 / tilingY * y,
            u2 / tilingX * x,
            v2 / tilingY * y
        );
        tilingX = x;
        tilingY = y;
    }

    void draw()
    {
        import hip.api.graphics.g2d.renderer2d;
        this.isDirty = true;
        drawSprite(texture.getTexture, cast(ubyte[])getVertices[]);
    }
}


class HipSpriteAnimation : HipSprite
{
    import hip.api.graphics.g2d.animation;
    private IHipAnimation animation;
    HipAnimationFrame* currentFrame;

    this(){super();}

    this(IHipAnimation anim)
    {
        super();
        animation = anim;
        this.setAnimation(anim.getCurrentTrackName());
    }

    IHipAnimationTrack getAnimation(string animName)
    {
        return animation.getTrack(animName);
    }
    /**
    *   Sets internal animation data.
    */
    void setAnimation(IHipAnimation anim)
    {
        animation = anim;
        setAnimation(animation.getCurrentTrackName());
    }
    void setAnimation(string animName)
    {
        animation.play(animName);
        setFrame(animation.getCurrentFrame());
    }

    void setBounds(int width, int height)
    {
        this.width = width;
        this.height = height;
    }

    void setFrame(HipAnimationFrame* frame)
    {
        this.currentFrame = frame;
        this.texture = frame.region;
        setBounds(frame.region.getWidth(), frame.region.getHeight());
        setRegion(texture.getRegion());
    }

    void update(float dt)
    {
        animation.update(dt);
        setFrame(animation.getCurrentFrame());
    }
}
