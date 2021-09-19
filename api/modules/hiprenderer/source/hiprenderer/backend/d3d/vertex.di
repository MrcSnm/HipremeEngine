// D import file generated from 'source\hiprenderer\backend\d3d\vertex.d'
module hiprenderer.backend.d3d.vertex;
version (Windows)
{
	import std.format;
	import core.stdc.string;
	import std.conv : to;
	import error.handler;
	import directx.d3d11;
	import util.system;
	import core.sys.windows.windows;
	import hiprenderer;
	import hiprenderer.backend.d3d.renderer;
	import hiprenderer.backend.d3d.utils;
	import hiprenderer.shader;
	import hiprenderer.backend.d3d.shader;
	import hiprenderer.vertex;
	import config.opts;
	class Hip_D3D11_VertexBufferObject : IHipVertexBufferImpl
	{
		immutable D3D11_USAGE usage;
		ID3D11Buffer buffer;
		ulong size;
		this(ulong size, HipBufferUsage usage)
		{
			this.size = size;
			this.usage = getD3D11Usage(usage);
		}
		void bind();
		void unbind();
		void createBuffer(ulong size, const void* data);
		void setData(ulong size, const void* data);
		void updateData(int offset, ulong size, const void* data);
	}
	class Hip_D3D11_IndexBufferObject : IHipIndexBufferImpl
	{
		immutable D3D11_USAGE usage;
		ID3D11Buffer buffer;
		uint count;
		ulong size;
		this(uint count, HipBufferUsage usage)
		{
			this.size = count * index_t.sizeof;
			this.count = count;
			this.usage = getD3D11Usage(usage);
		}
		protected void createBuffer(uint count, void* data);
		void bind();
		void unbind();
		void setData(index_t count, const index_t* data);
		void updateData(int offset, index_t count, const index_t* data);
	}
	class Hip_D3D11_VertexArrayObject : IHipVertexArrayImpl
	{
		ID3D11InputLayout inputLayout;
		D3D11_INPUT_ELEMENT_DESC[] descs;
		uint stride;
		this()
		{
		}
		void bind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo);
		void unbind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo);
		void setAttributeInfo(ref HipVertexAttributeInfo info, uint stride);
		void createInputLayout(Shader s);
	}
	private int getD3D11Usage(HipBufferUsage usage);
	private int getD3D11_CPUUsage(D3D11_USAGE usage);
	private DXGI_FORMAT _hip_d3d_getFormatFromInfo(ref HipVertexAttributeInfo info);
}
