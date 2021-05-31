module implementations.renderer.mesh;
import implementations.renderer.renderer;
import implementations.renderer.shader;
import implementations.renderer.vertex;

class Mesh
{
    version(Android)
    {
        protected ushort[] indices;        
    }
    else
    {
        protected uint[] indices;
    }
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
    /**
    *   Use this function only for creation!
    *   inside loops, you must use updateIndices
    */
    public void setIndices(ref uint[] indices)
    {
        this.indices = indices;
        this.vao.setIndices(cast(uint)indices.length, indices.ptr);
    }
    /**
    *   Use this function only for creation!
    *   Inside loops, you must use updateVertices
    */
    public void setVertices(ref float[] vertices)
    {
        this.vertices = vertices;
        this.vao.setVertices(cast(uint)vertices.length/this.vao.stride, vertices.ptr);
    }
    public void updateIndices(ref uint[] indices)
    {
        this.indices = indices;
        this.vao.updateIndices(cast(uint)indices.length, indices.ptr);
    }

    public void updateVertices(ref float[] vertices)
    {
        this.vertices = vertices;
        this.vao.updateVertices(cast(uint)vertices.length/this.vao.stride, vertices.ptr);
    }
    public void setShader(Shader s)
    {
        this.currentShader = s;
    }

    public void draw()
    {
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
        HipRenderer.drawIndexed(cast(uint)this.indices.length);
    }


    
}