// D import file generated from 'source\hiprenderer\primitives.d'
module hiprenderer.primitives;
import bindbc.opengl;
struct Geometry
{
	uint vbo;
	float* vertexData;
	static Geometry opCall();
	void assignVertexes(float* vertexData, GLsizei vertexDataLength);
	void dispose();
}
float[] triangleVertices = [-0.5F, -0.5F, 0.0F, 0.5F, -0.5F, 0.0F, 0.0F, 0.5F, 0.0F];
public static class Primitives
{
	public static void drawTriangle();
	public static void drawRectangle();
	public static void fillTriangle();
	public static void fillRectangle();
	public static void drawPixel();
}
