/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

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
    ///Not yet supported
    bool isInstanced;
    HipVertexArrayObject vao;
    Shader shader;

    this(HipVertexArrayObject vao, Shader shader)
    {
        this.vao = vao;
        this.shader = shader;
    }
    void createVertexBuffer(index_t count, HipBufferUsage usage)
    {
        this.vao.createVertexBuffer(count, usage);
    }
    void createIndexBuffer(index_t count, HipBufferUsage usage)
    {
        this.vao.createIndexBuffer(count, usage);
    }
    void sendAttributes()
    {
        this.vao.sendAttributes(shader);
    }

    /**
    *   Use this function only for creation!
    *   inside loops, you must use updateIndices
    */
    
    public void setIndices(ref index_t[] indices)
    {
        if(indices.length <  this.indices.length)
        {
            updateIndices(indices);
            return;
        }
        this.indices = indices;
        this.vao.setIndices(cast(index_t)indices.length, indices.ptr);
    }
    /**''
    *   Use this function only for creation!
    *   Inside loops, you must use updateVertices
    */
    public void setVertices(ref float[] vertices)
    {
        if(vertices.length <  this.vertices.length)
        {
            updateVertices(vertices);
            return;
        }
        this.vertices = vertices;
        this.vao.setVertices(cast(uint)vertices.length/this.vao.dataCount, vertices.ptr);
    }
    public void updateIndices(ref index_t[] indices)
    {
        import console.log;
        this.indices = indices;
        this.vao.updateIndices(cast(index_t)indices.length, indices.ptr);
    }

    public void updateVertices(ref float[] vertices)
    {
        this.vertices = vertices;
        this.vao.updateVertices(cast(index_t)(vertices.length/this.vao.dataCount), vertices.ptr);
    }
    public void setShader(Shader s)
    {
        this.currentShader = s;
    }

    /**
    *   How many indices should it draw
    */
    public void draw(T)(T count)
    {
        static assert(isUnsigned!T, "Mesh must receive an integral type in its draw");
        ErrorHandler.assertExit(count < T.max, "Can't draw more than T.max");
        // if(isVertexArray)
        // {
            // HipRenderer.drawVertices()
        // }
        //else if(isInstanced)
        /*
        {
            HipRenderer.drawInstanced()
        }
        */
        this.shader.bind();
        this.vao.bind();
        HipRenderer.drawIndexed(cast(index_t)count);
    }

}