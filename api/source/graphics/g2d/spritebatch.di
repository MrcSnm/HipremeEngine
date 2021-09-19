// D import file generated from 'source\graphics\g2d\spritebatch.d'
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
class HipSpriteBatch
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
	this(index_t maxQuads = 10900)
	{
		import std.conv : to;
		ErrorHandler.assertExit(index_t.max > maxQuads * 6, "Invalid max quads. Max is " ~ to!string(index_t.max / 6));
		this.maxQuads = maxQuads;
		indices = new index_t[maxQuads * 6];
		vertices = new float[maxQuads * HipSpriteVertex.quadCount];
		vertices[] = 0;
		currentTextures = new Texture[](HipRenderer.getMaxSupportedShaderTextures());
		usingTexturesCount = 0;
		Shader s = HipRenderer.newShader(HipShaderPresets.SPRITE_BATCH);
		mesh = new Mesh(HipVertexArrayObject.getXYZ_RGBA_ST_TID_VAO(), s);
		mesh.vao.bind();
		mesh.createVertexBuffer(cast(index_t)(maxQuads * HipSpriteVertex.quadCount), HipBufferUsage.DYNAMIC);
		mesh.createIndexBuffer(cast(index_t)(maxQuads * 6), HipBufferUsage.STATIC);
		mesh.sendAttributes();
		setShader(s);
		shader.addVarLayout((new ShaderVariablesLayout("Cbuf1", ShaderTypes.VERTEX, ShaderHint.NONE)).append("uModel", Matrix4.identity).append("uView", Matrix4.identity).append("uProj", Matrix4.identity));
		shader.addVarLayout((new ShaderVariablesLayout("Cbuf", ShaderTypes.FRAGMENT, ShaderHint.NONE)).append("uBatchColor", cast(float[4])[1, 1, 1, 1]));
		shader.useLayout.Cbuf;
		shader.bind();
		shader.sendVars();
		camera = new HipOrthoCamera;
		index_t offset = 0;
		for (index_t i = 0;
		 i < cast(index_t)(maxQuads * 6); i += 6)
		{
			{
				indices[i + 0] = cast(index_t)(0 + offset);
				indices[i + 1] = cast(index_t)(1 + offset);
				indices[i + 2] = cast(index_t)(2 + offset);
				indices[i + 3] = cast(index_t)(2 + offset);
				indices[i + 4] = cast(index_t)(3 + offset);
				indices[i + 5] = cast(index_t)(0 + offset);
				offset += 4;
			}
		}
		mesh.setVertices(vertices);
		mesh.setIndices(indices);
	}
	void setShader(Shader s);
	void begin();
	void addQuad(ref float[HipSpriteVertex.quadCount] quad, int slot);
	pragma (inline, true)private int getNextTextureID(Texture t);
	protected int setTexture(Texture texture);
	protected int setTexture(TextureRegion reg);
	void draw(Texture t, ref float[HipSpriteVertex.quadCount] vertices);
	void draw(HipSprite s);
	void draw(TextureRegion reg, int x, int y, int z = 0, HipColor color = HipColor.white);
	static float[HipSpriteVertex.floatCount * 4] getTextureRegionVertices(TextureRegion reg, int x, int y, int z = 0, HipColor color = HipColor.white);
	void end();
	void flush();
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
