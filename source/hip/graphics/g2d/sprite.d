/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.graphics.g2d.sprite;
import hip.graphics.g2d.spritebatch;
import hip.assets.texture;
import hip.math.utils:sin,cos;
import hip.assetmanager;
import hip.debugging.gui;
import hip.global.gamedef;
public import hip.api.graphics.g2d.hipsprite;

@InterfaceImplementation(function(ref void* data)
{
    version(CIMGUI)
    {
        import bindbc.cimgui;
        HipSprite* s = cast(HipSprite*)data;

        igBeginGroup();
        igSliderFloat2("Position", &s.x, -1000, 1000,  null, 0);
        igSliderFloat2("Scale", &s.scaleX, -1, 1000,  null, 0);
        igSliderFloat("Rotation", cast(float*)&s.rotation, 0, 360, null, 0);
        igEndGroup();
    }

})class HipSprite : IHipSprite
{
    IHipTextureRegion texture;
    HipColor color;
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

    protected bool isDirty;
    protected float[HipSpriteVertex.floatCount * 4] vertices;

    mixin(HipDeferredLoad);

    static IHipTexture getDefaultTexture()
    {
        static IHipTexture texture;
        if(texture is null)
        {
            texture = new HipTexture(HipDefaultAssets.texture);
        }
        return texture;
    }


    this()
    {
        vertices[] = 0;
        isDirty = true;
        setColor(HipColor.white);
    }

    this(string texturePath)
    {
        this();
        if(texturePath is null)
            texture = new HipTextureRegion(getDefaultTexture());
        else
            texture = new HipTextureRegion(texturePath);
        import hip.error.handler;
        if(!(cast(HipTextureRegion)texture).hasSuccessfullyLoaded)
        {
            ErrorHandler.showErrorMessage(
                "Error loading texture for Sprite",
                "Error loading texture at path: "~texturePath
            );
        }
        width  = texture.getWidth();
        height = texture.getHeight();
        setRegion(texture.getRegion());
    }

    this(IHipTexture texture)
    {
        this();
        setTexture(texture);
    }
    this(IHipTextureRegion region)
    {
        this();
        this.texture = region;
        width  = region.getWidth();
        height = region.getHeight();
        setRegion(region.getRegion());
    }

    void setTexture(IHipTexture texture)
    {
        this.texture = new HipTextureRegion(texture);
        width  = texture.getWidth;
        height = texture.getHeight;
        setRegion(this.texture.getRegion());
    }

    IHipTextureRegion getTextureRegion() {return texture;}

    alias setRegion = IHipSprite.setRegion;
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
        vertices[U1] = v[0];
        vertices[V1] = v[1];
        vertices[U2] = v[2];
        vertices[V2] = v[3];
        vertices[U3] = v[4];
        vertices[V3] = v[5];
        vertices[U4] = v[6];
        vertices[V4] = v[7];
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
        vertices[Y2] = y;

        //Bot right
        vertices[X3] = x2;
        vertices[Y3] = y2;

        //Bot left
        vertices[X4] = x;
        vertices[Y4] = y2;
    }

    ref float[HipSpriteVertex.quadCount] getVertices()
    {
        if(isDirty)
        {
            isDirty = false;
            if(rotation == 0)
            {
                float x2 = x+ (width*scaleX * tilingX);
                float y2 = y+ (height*scaleY * tilingY);
                //Top left
                vertices[X1] = x;
                vertices[Y1] = y;

                //Top right
                vertices[X2] = x2;
                vertices[Y2] = y;

                //Bot right
                vertices[X3] = x2;
                vertices[Y3] = y2;

                //Bot left
                vertices[X4] = x;
                vertices[Y4] = y2;
            }
            else
            {
                float x = -cast(float)width/2;
                float y = -cast(float)height/2;
                float x2 = x+(width * tilingX);
                float y2 = y+(height * tilingY); 
                float c = cos(rotation);
                float s = sin(rotation);
                //Top left
                vertices[X1] = c*x - s*y + this.x;
                vertices[Y1] = c*y + s*x + this.y;

                //Top right
                vertices[X2] = c*x2 - s*y + this.x;
                vertices[Y2] = c*y + s*x2 + this.y;

                //Bot right
                vertices[X3] = c*x2 - s*y2 + this.x;
                vertices[Y3] = c*y2 + s*x2 + this.y;

                //Bot left
                vertices[X4] = c*x - s*y2 + this.x;
                vertices[Y4] = c*y2 + s*x + this.y;
            }
        }

        return vertices;
    }

    pure void setColor(HipColor color)
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
}


class HipSpriteAnimation : HipSprite
{
    import hip.graphics.g2d.animation;
    HipAnimation animation;
    HipAnimationFrame* currentFrame;

    this(HipAnimation anim)
    {
        super("");
        animation = anim;
        this.setAnimation(anim.getCurrentTrackName());

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