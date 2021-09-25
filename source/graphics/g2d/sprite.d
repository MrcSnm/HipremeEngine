/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module graphics.g2d.sprite;
import graphics.g2d.spritebatch;
import hiprenderer.texture;
import debugging.gui;
public import hipengine.api.graphics.g2d.hipsprite;

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
    TextureRegion texture;
    HipColor color;
    float x, y;
    float scaleX, scaleY;
    float scrollX, scrollY;
    float rotation;
    uint width, height;

    protected bool isDirty;

    static assert(HipSpriteVertex.floatCount == 10,  "SpriteVertex should contain 9 floats and 1 int");
    protected float[HipSpriteVertex.floatCount * 4] vertices;

    this()
    {
        vertices[] = 0;
        x = 0;
        y = 0;
        rotation = 0;
        scaleX = 1f;
        scaleY = 1f;
        isDirty = true;
        setColor(HipColor.white);
    }

    this(string texturePath)
    {
        this();
        texture = new TextureRegion(texturePath);
        width  = texture.regionWidth;
        height = texture.regionHeight;
        setRegion(texture.u1, texture.v1, texture.u2, texture.v2);
    }

    this(Texture texture)
    {
        this();
        this.texture = new TextureRegion(texture);
        width  = texture.width;
        height = texture.height;
        setRegion(this.texture.u1, this.texture.v1, this.texture.u2, this.texture.v2);
    }
    this(TextureRegion region)
    {
        this();
        this.texture = region;
        width  = texture.regionWidth;
        height = texture.regionHeight;
        setRegion(region.u1, region.v1, region.u2, region.v2);
    }
    void setRegion(float x1, float y1, float x2, float y2)
    {
        texture.setRegion(x1, y1, x2, y2);
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
            float x2 = x+width*scaleX;
            float y2 = y+height*scaleY;

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

    void setScroll(float x, float y)
    {
        scrollX = x;
        scrollY = y;
    }
}


class HipSpriteAnimation : HipSprite
{
    import graphics.g2d.animation;
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
        animation.setTrack(animName);
        setFrame(animation.getCurrentFrame());
    }

    void setBounds(uint width, uint height)
    {
        this.width = width;
        this.height = height;
    }

    void setFrame(HipAnimationFrame* frame)
    {
        this.currentFrame = frame;
        this.texture = frame.region;
        setBounds(frame.region.regionWidth, frame.region.regionHeight);
        setRegion(texture.u1, texture.v1, texture.u2, texture.v2);
    }

    void update(float dt)
    {
        animation.update(dt);
        setFrame(animation.getCurrentFrame());
    }
}