// D import file generated from 'source\graphics\mesh.d'
module graphics.mesh;
import hiprenderer.renderer;
import hiprenderer.shader;
import hiprenderer.vertex;
import error.handler;
import std.traits;
class Mesh
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
	void createVertexBuffer(index_t count, HipBufferUsage usage);
	void createIndexBuffer(index_t count, HipBufferUsage usage);
	void sendAttributes();
	public void setIndices(ref index_t[] indices);
	public void setVertices(ref float[] vertices);
	public void updateIndices(ref index_t[] indices);
	public void updateVertices(ref float[] vertices);
	public void setShader(Shader s);
	public void draw(T)(T count)
	{
		static assert(isUnsigned!T, "Mesh must receive an integral type in its draw");
		ErrorHandler.assertExit(count < T.max, "Can't draw more than T.max");
		this.shader.bind();
		this.vao.bind();
		HipRenderer.drawIndexed(cast(index_t)count);
	}
}
