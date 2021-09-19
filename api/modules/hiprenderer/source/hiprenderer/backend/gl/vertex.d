
module hiprenderer.backend.gl.vertex;
import hiprenderer.backend.gl.renderer;
import error.handler;
import std.format : format;
import hiprenderer.shader;
import hiprenderer.vertex;
private int getGLUsage(HipBufferUsage usage);
private int getGLAttributeType(HipAttributeType _t);
class Hip_GL3_VertexBufferObject : IHipVertexBufferImpl
{
	immutable int usage;
	ulong size;
	uint vbo;
	this(ulong size, HipBufferUsage usage)
	{
		this.size = size;
		this.usage = getGLUsage(usage);
		glGenBuffers(1, &this.vbo);
	}
	void bind();
	void unbind();
	void setData(ulong size, const void* data);
	void updateData(int offset, ulong size, const void* data);
	~this();
}
class Hip_GL3_IndexBufferObject : IHipIndexBufferImpl
{
	immutable int usage;
	ulong size;
	index_t count;
	uint ebo;
	this(index_t count, HipBufferUsage usage)
	{
		this.size = index_t.sizeof * count;
		this.count = count;
		this.usage = getGLUsage(usage);
		glGenBuffers(1, &this.ebo);
	}
	void bind();
	void unbind();
	void setData(index_t count, const index_t* data);
	void updateData(int offset, index_t count, const index_t* data);
	~this();
}
class Hip_GL3_VertexArrayObject : IHipVertexArrayImpl
{
	uint vao;
	this()
	{
		glGenVertexArrays(1, &this.vao);
	}
	void bind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo);
	void unbind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo);
	void setAttributeInfo(ref HipVertexAttributeInfo info, uint stride);
	void createInputLayout(Shader s);
	~this();
}
