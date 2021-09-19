
module graphics.g2d.sprite;
import graphics.g2d.spritebatch;
import hiprenderer.texture;
import debugging.gui;
import graphics.color;
@(InterfaceImplementation(function (ref void* data)
{
	version (CIMGUI)
	{
		import bindbc.cimgui;
		HipSprite* s = cast(HipSprite*)data;
		igBeginGroup();
		igSliderFloat2("Position", &s.x, -1000, 1000, null, 0);
		igSliderFloat2("Scale", &s.scaleX, -1, 1000, null, 0);
		igSliderFloat("Rotation", cast(float*)&s.rotation, 0, 360, null, 0);
		igEndGroup();
	}

}
))class HipSprite
{
	TextureRegion texture;
	HipColor color;
	float x;
	float y;
	float scaleX;
	float scaleY;
	float scrollX;
	float scrollY;
	float rotation;
	uint width;
	uint height;
	protected bool isDirty;
	static assert(HipSpriteVertex.floatCount == 10, "SpriteVertex should contain 9 floats and 1 int");
	protected float[HipSpriteVertex.floatCount * 4] vertices;
	this()
	{
		vertices[] = 0;
		x = 0;
		y = 0;
		rotation = 0;
		scaleX = 1.0F;
		scaleY = 1.0F;
		isDirty = true;
		setColor(HipColor.white);
	}
	this(string texturePath)
	{
		this();
		texture = new TextureRegion(texturePath);
		width = texture.regionWidth;
		height = texture.regionHeight;
		setRegion(texture.u1, texture.v1, texture.u2, texture.v2);
	}
	this(Texture texture)
	{
		this();
		this.texture = new TextureRegion(texture);
		width = texture.width;
		height = texture.height;
		setRegion(this.texture.u1, this.texture.v1, this.texture.u2, this.texture.v2);
	}
	this(TextureRegion region)
	{
		this();
		this.texture = region;
		width = texture.regionWidth;
		height = texture.regionHeight;
		setRegion(region.u1, region.v1, region.u2, region.v2);
	}
	void setRegion(float x1, float y1, float x2, float y2);
	void setPosition(float x, float y);
	ref float[HipSpriteVertex.quadCount] getVertices();
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
	void setScale(float scaleX, float scaleY);
	void setRotation(float rotation);
	void setScroll(float x, float y);
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
	void setAnimation(string animName);
	void setBounds(uint width, uint height);
	void setFrame(HipAnimationFrame* frame);
	void update(float dt);
}
