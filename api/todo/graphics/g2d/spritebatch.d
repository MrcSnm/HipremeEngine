
module graphics.g2d.spritebatch;
import graphics.mesh;
import core.stdc.string : memcpy;
import graphics.orthocamera;
import hiprenderer.renderer;
import math.matrix;
import error.handler;
import hiprenderer.shader;
import graphics.material;
import graphics.g2d.sprite;
import graphics.color;
import math.vector;

struct HipSpriteVertex
{
	Vector3 position;
	HipColor color;
	Vector2 tex_uv;
	int texID;
	static enum floatCount = cast(ulong)(HipSpriteVertex.sizeof / (float).sizeof);
	static enum quadCount = floatCount * 4;
}

interface IHipSpriteBatch
{
	void setShader(Shader s);
	void begin();
	void draw(Texture t, ref float[HipSpriteVertex.quadCount] vertices);
	void draw(HipSprite s);
	void draw(TextureRegion reg, int x, int y, int z = 0, HipColor color = HipColor.white);
	// static float[HipSpriteVertex.floatCount * 4] getTextureRegionVertices(TextureRegion reg, int x, int y, int z = 0, HipColor color = HipColor.white);
	void end();
	void flush();
}

abstract class HipSpriteBatch : IHipSpriteBatch
{
	index_t maxQuads;
	index_t[] indices;
	float[] vertices;
	bool hasBegun;
	protected bool hasInitTextureSlots;
	Shader shader;
	HipOrthoCamera camera;
	Mesh mesh;
	Material material;
	protected Texture[] currentTextures;
	int usingTexturesCount;
	uint quadsCount;
	// static float[HipSpriteVertex.floatCount * 4] getTextureRegionVertices(TextureRegion reg, int x, int y, int z = 0, HipColor color = HipColor.white);
}
enum 
{
	X1 = 0,
	Y1,
	Z1,
	R1,
	G1,
	B1,
	A1,
	U1,
	V1,
	T1,
	X2,
	Y2,
	Z2,
	R2,
	G2,
	B2,
	A2,
	U2,
	V2,
	T2,
	X3,
	Y3,
	Z3,
	R3,
	G3,
	B3,
	A3,
	U3,
	V3,
	T3,
	X4,
	Y4,
	Z4,
	R4,
	G4,
	B4,
	A4,
	U4,
	V4,
	T4,
}
