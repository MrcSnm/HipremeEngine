
module graphics.mesh;
import hiprenderer.renderer;
import hiprenderer.shader;
import hiprenderer.vertex;

interface IMesh
{
	void createVertexBuffer(index_t count, HipBufferUsage usage);
	void createIndexBuffer(index_t count, HipBufferUsage usage);
	void sendAttributes();
	public void setIndices(ref index_t[] indices);
	public void setVertices(ref float[] vertices);
	public void updateIndices(ref index_t[] indices);
	public void updateVertices(ref float[] vertices);
	public void setShader(Shader s);
	public void draw(T)(T count);
}

abstract class AMesh : IMesh
{
	protected index_t[] indices;
	protected float[] vertices;
	protected Shader currentShader;
	bool isInstanced;
	HipVertexArrayObject vao;
	Shader shader;
	this(HipVertexArrayObject vao, Shader shader)
	{
		this.vao = vao;
		this.shader = shader;
	}
}
