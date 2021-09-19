// D import file generated from 'source\graphics\g2d\ninepatch.d'
module graphics.g2d.ninepatch;
import hiprenderer.texture;
import graphics.g2d.spritebatch;
import graphics.g2d.sprite;
class NinePatch
{
	uint width;
	uint height;
	float x;
	float y;
	TextureRegion[9] regions;
	Texture texture;
	this(uint width, uint height, Texture tex)
	{
		this.width = width;
		this.height = height;
		texture = tex;
		build();
	}
	void build();
	void setTopLeft(uint u1, uint v1, uint u2, uint v2);
	void setTopMid(uint u1, uint v1, uint u2, uint v2);
	void setTopRight(uint u1, uint v1, uint u2, uint v2);
	void setMidLeft(uint u1, uint v1, uint u2, uint v2);
	void setMidMid(uint u1, uint v1, uint u2, uint v2);
	void setMidRight(uint u1, uint v1, uint u2, uint v2);
	void setBotLeft(uint u1, uint v1, uint u2, uint v2);
	void setBotMid(uint u1, uint v1, uint u2, uint v2);
	void setBotRight(uint u1, uint v1, uint u2, uint v2);
	void setPosition(float x, float y);
}
private enum : ulong
{
	TOP_LEFT = 0,
	TOP_MID,
	TOP_RIGHT,
	MID_LEFT,
	MID_MID,
	MID_RIGHT,
	BOT_LEFT,
	BOT_MID,
	BOT_RIGHT,
}
