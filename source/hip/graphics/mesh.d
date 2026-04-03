/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.graphics.mesh;
import hip.hiprenderer.renderer;
import hip.hiprenderer.shader;
import hip.hiprenderer.vertex;
import hip.error.handler;


class Mesh
{
    import hip.util.data_structures;
    
    alias meshBinder = DelayedBindable!(Mesh, !UseDelayedUnbind, BindReplacesUnbind, 1,
        (Mesh m) { m.shader.bind(); m.vao.bind(); },
        (Mesh m) { m.shader.unbind(); m.vao.unbind(); }
    );

    protected index_t[] indices;
    protected void[] vertices;
    ///Not yet supported
    bool isInstanced;
    protected HipVertexArrayObject vao;
    Shader shader;
    this(HipVertexArrayObject vao, Shader shader)
    {
        this.vao = vao;
        this.shader = shader;
    }
    void createIndexBuffer(index_t count, HipResourceUsage usage)
    {
        this.vao.createIndexBuffer(count, usage);
    }
    void sendAttributes()
    {
        this.vao.sendAttributes(shader);
    }
    void bind(){meshBinder.bind(this);}
    void unbind(){meshBinder.unbind(this);}

    /**
     * Use that function when the mesh doesn't hold ownership over the indices
     * Params:
     *   indexBuffer = The index buffer to be shared
     */
    public void setIndices(IHipRendererBuffer indexBuffer)
    {
        this.indices = null;
        this.vao.setIndexBuffer(indexBuffer);
    }

    /**
    *   Will choose between resizing buffer as needed or only updating it.
    */
    public void setIndices(index_t[] indices)
    {
        if(indices.length <  this.indices.length)
        {
            updateIndices(indices);
            return;
        }
        this.indices = indices;
        this.vao.setIndices(indices);
    }

    public void setVertices(const void[] vertices, ubyte vbo = 0)
    {
        if(vertices.length <= this.vertices.length)
        {
            updateVertices(vertices, 0, vbo);
            return;
        }
        this.vertices = cast(void[])vertices;
        this.vao.setVertices(vertices, vbo);
    }
    /**
    *   Updates the GPU internal buffer by using the buffer sent.
    *   The offset is always multiplied by the target vertex buffer stride.
    */
    public void updateVertices(const void[] vertices, int offset = 0, ubyte vbo = 0)
    {
        this.vao.updateVertices(vertices, offset, vbo);
    }
    public void updateIndices(const index_t[] indices, int offset = 0)
    {
        this.vao.updateIndices(indices, offset);
    }
    public void setShader(Shader s){this.shader = s;}

    /**
    *   How many indices should it draw
    */
    public void draw(T)(T indicesCount, HipRendererMode mode, uint offset = 0)
    {
        import std.traits:isUnsigned;
        static assert(isUnsigned!T, "Mesh must receive an integral type in its draw");
        ErrorHandler.assertExit(indicesCount < T.max, "Can't draw more than T.max");
        bind();
        HipRenderer.drawIndexed(mode, cast(index_t)indicesCount, offset);
    }

    
    /**
    *   How many indices should it draw
    */
    public void drawInstanced(HipRendererMode mode, uint instanceCount, index_t indicesCount, uint indicesOffset = 0)
    {
        bind();
        HipRenderer.drawIndexedInstanced(mode, instanceCount, indicesCount, indicesOffset);
    }

}
