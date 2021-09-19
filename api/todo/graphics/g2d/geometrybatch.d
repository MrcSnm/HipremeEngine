
module graphics.g2d.geometrybatch;
import hiprenderer.renderer;
import hiprenderer.shader;
import graphics.mesh;
import math.matrix;
import graphics.color;
public import graphics.color;

interface IGeometryBatch
{
	void setShader(Shader s);
	index_t addVertex(float x, float y, float z);
	void setColor(HipColor c);
	void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3);
	void fillTriangle(int x1, int y1, int x2, int y2, int x3, int y3, HipColor color);
	void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3);
	void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3, HipColor color);
	void drawLine(int x1, int y1, int x2, int y2);
	void drawLine(int x1, int y1, int x2, int y2, HipColor color);
	void drawPixel(int x, int y);
	void drawPixel(int x, int y, HipColor color);
	void drawRectangle(int x, int y, int w, int h);
	void drawRectangle(int x, int y, int w, int h, HipColor color);
	void fillRectangle(int x, int y, int w, int h);
	void fillRectangle(int x, int y, int w, int h, HipColor color);
	void flush();
}

abstract class GeometryBatch : IGeometryBatch
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
}
