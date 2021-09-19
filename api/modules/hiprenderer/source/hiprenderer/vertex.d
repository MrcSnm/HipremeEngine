
module hiprenderer.vertex;
import hiprenderer.renderer;
import error.handler;
import console.log;
public import hiprenderer.backend.gl.vertex;
alias index_t = ushort;
enum InternalVertexAttribute 
{
	POSITION = 0,
	TEXTURE_COORDS,
	COLOR,
}
enum InternalVertexAttributeFlags 
{
	POSITION = 1 << InternalVertexAttribute.POSITION,
	TEXTURE_COORDS = 1 << InternalVertexAttribute.TEXTURE_COORDS,
	COLOR = 1 << InternalVertexAttribute.COLOR,
}
enum HipBufferUsage 
{
	DYNAMIC,
	STATIC,
	DEFAULT,
}
enum HipAttributeType 
{
	FLOAT,
	INT,
	BOOL,
}
struct HipVertexAttributeInfo
{
	uint index;
	uint count;
	uint offset;
	uint typeSize;
	HipAttributeType valueType;
	string name;
}
interface IHipVertexBufferImpl
{
	void bind();
	void unbind();
	void setData(ulong size, const void* data);
	void updateData(int offset, ulong size, const void* data);
}
interface IHipIndexBufferImpl
{
	void bind();
	void unbind();
	void setData(index_t count, const index_t* data);
	void updateData(int offset, index_t count, const index_t* data);
}
interface IHipVertexArrayImpl
{
	void bind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo);
	void unbind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo);
	void setAttributeInfo(ref HipVertexAttributeInfo info, uint stride);
	void createInputLayout(Shader s);
}
class HipVertexArrayObject
{
	IHipVertexArrayImpl VAO;
	IHipVertexBufferImpl VBO;
	IHipIndexBufferImpl EBO;
	uint stride;
	uint dataCount;
	HipVertexAttributeInfo[] infos;
	protected bool isBonded;
	this()
	{
		isBonded = false;
		this.VAO = HipRenderer.createVertexArray();
	}
	void createIndexBuffer(index_t count, HipBufferUsage usage);
	void createVertexBuffer(uint count, HipBufferUsage usage);
	HipVertexArrayObject appendAttribute(uint count, HipAttributeType valueType, uint typeSize, string infoName);
	void sendAttributes(Shader s);
	void bind();
	void unbind();
	void setVertices(uint count, const void* data);
	void updateVertices(index_t count, const void* data, int offset = 0);
	void setIndices(index_t count, const index_t* data);
	void updateIndices(index_t count, index_t* data, int offset = 0);
	static HipVertexArrayObject getXY_ST_VAO();
	static HipVertexArrayObject getXYZ_RGBA_VAO();
	static HipVertexArrayObject getXYZ_RGBA_ST_VAO();
	static HipVertexArrayObject getXYZ_RGBA_ST_TID_VAO();
	static HipVertexArrayObject getXY_RGBA_ST_VAO();
}
