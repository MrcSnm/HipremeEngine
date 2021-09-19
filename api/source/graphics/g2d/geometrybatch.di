// D import file generated from 'source\graphics\g2d\geometrybatch.d'
module graphics.g2d.geometrybatch;
import hiprenderer.renderer;
import hiprenderer.shader;
import error.handler;
import graphics.mesh;
import math.matrix;
import graphics.color;
import std.format : format;
public import graphics.color;
class GeometryBatch
{
	protected Mesh mesh;
	protected Shader currentShader;
	protected index_t currentIndex;
	protected index_t currentVertex;
	protected index_t verticesCount;
	protected index_t indicesCount;
	protected HipColor currentColor;
	HipRendererMode mode;
	float[] vertices;
	index_t[] indices;
	this(index_t verticesCount = 19000, index_t indicesCount = 19000)
	{
		Shader s = HipRenderer.newShader(HipShaderPresets.GEOMETRY_BATCH);
		s.addVarLayout((new ShaderVariablesLayout("Geom", ShaderTypes.VERTEX, 0)).append("uModel", Matrix4.identity).append("uView", Matrix4.identity).append("uProj", Matrix4.identity));
		s.addVarLayout((new ShaderVariablesLayout("FragVars", ShaderTypes.FRAGMENT, 0)).append("uGlobalColor", cast(float[4])[1, 1, 1, 1]));
		mesh = new Mesh(HipVertexArrayObject.getXYZ_RGBA_VAO(), s);
		setShader(s);
		vertices = new float[verticesCount * 7];
		indices = new index_t[indicesCount];
		indices[] = 0;
		vertices[] = 0;
		mesh.createVertexBuffer(verticesCount, HipBufferUsage.DYNAMIC);
		mesh.createIndexBuffer(indicesCount, HipBufferUsage.DYNAMIC);
		mesh.vao.bind();
		mesh.setIndices(indices);
		mesh.setVertices(vertices);
		mesh.sendAttributes();
		this.setColor(HipColor(1, 1, 1, 1));
	}
	void setShader(Shader s);
	index_t addVertex(float x, float y, float z);
	pragma (inline, true)void addIndex(index_t index);
	void setColor(HipColor c);
	pragma (inline, true)protected void triangleVertices(int x1, int y1, int x2, int y2, int x3, int y3);
	void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3);
	void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3, HipColor color);
	void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3);
	void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3, HipColor color);
	void drawLine(int x1, int y1, int x2, int y2);
	void drawLine(int x1, int y1, int x2, int y2, HipColor color);
	void drawPixel(int x, int y);
	void drawPixel(int x, int y, HipColor color);
	pragma (inline, true)protected void rectangleVertices(int x, int y, int w, int h);
	void drawRectangle(int x, int y, int w, int h);
	void drawRectangle(int x, int y, int w, int h, HipColor color);
	void fillRectangle(int x, int y, int w, int h);
	void fillRectangle(int x, int y, int w, int h, HipColor color);
	void flush();
}
